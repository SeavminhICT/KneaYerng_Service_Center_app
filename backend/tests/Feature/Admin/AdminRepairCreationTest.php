<?php

namespace Tests\Feature\Admin;

use App\Models\Invoice;
use App\Models\RepairProblem;
use App\Models\RepairRequest;
use App\Models\Technician;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminRepairCreationTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_can_create_repair_job_and_assign_technician()
    {
        $admin = User::factory()->create([
            'is_admin' => true,
            'role' => 'admin',
        ]);

        $customer = User::factory()->create([
            'phone' => '012345678',
            'role' => 'user',
        ]);

        $technician = Technician::create([
            'name' => 'John Service Tech',
            'availability_status' => 'available',
            'active_jobs_count' => 0,
        ]);

        $response = $this->actingAs($admin)
            ->postJson('/api/repairs', [
                'customer_id' => $customer->id,
                'device_model' => 'iPhone 16 Pro Max',
                'issue_type' => 'Screen Replacement',
                'service_type' => 'drop_off',
                'appointment_datetime' => '2026-08-01T10:00:00',
                'technician_id' => $technician->id,
            ]);

        $response->assertCreated();
        $this->assertDatabaseHas('repair_requests', [
            'customer_id' => $customer->id,
            'technician_id' => $technician->id,
            'device_model' => 'iPhone 16 Pro Max',
            'issue_type' => 'Screen Replacement',
            'status' => 'assigned',
        ]);

        $technician->refresh();
        $this->assertEquals(1, $technician->active_jobs_count);
    }

    public function test_admin_can_create_repair_job_with_auto_assign_technician()
    {
        $admin = User::factory()->create([
            'is_admin' => true,
            'role' => 'admin',
        ]);

        $customer = User::factory()->create([
            'phone' => '098765432',
            'role' => 'user',
        ]);

        $technician = Technician::create([
            'name' => 'Auto Assigned Tech',
            'availability_status' => 'available',
            'active_jobs_count' => 0,
        ]);

        $response = $this->actingAs($admin)
            ->postJson('/api/repairs', [
                'customer_id' => $customer->id,
                'device_model' => 'MacBook Air M3',
                'issue_type' => 'Battery Service',
                'service_type' => 'pickup',
                'auto_assign' => true,
            ]);

        $response->assertCreated();
        $this->assertDatabaseHas('repair_requests', [
            'customer_id' => $customer->id,
            'technician_id' => $technician->id,
            'device_model' => 'MacBook Air M3',
            'status' => 'assigned',
        ]);
    }

    public function test_technician_assignment_list_only_shows_available_technicians_without_active_repairs()
    {
        $admin = User::factory()->create([
            'is_admin' => true,
            'role' => 'admin',
        ]);

        $customer = User::factory()->create([
            'phone' => '011111111',
            'role' => 'user',
        ]);

        $freeTechnician = Technician::create([
            'name' => 'Free Tech',
            'availability_status' => 'available',
            'active_jobs_count' => 0,
        ]);

        $busyTechnician = Technician::create([
            'name' => 'Busy Tech',
            'availability_status' => 'available',
            'active_jobs_count' => 0,
        ]);

        $completedTechnician = Technician::create([
            'name' => 'Done Tech',
            'availability_status' => 'available',
            'active_jobs_count' => 2,
        ]);

        RepairRequest::create([
            'customer_id' => $customer->id,
            'technician_id' => $busyTechnician->id,
            'device_model' => 'Apple iPhone 13',
            'issue_type' => 'Screen',
            'service_type' => 'drop_off',
            'status' => 'in_progress',
        ]);

        RepairRequest::create([
            'customer_id' => $customer->id,
            'technician_id' => $completedTechnician->id,
            'device_model' => 'Apple iPhone 14',
            'issue_type' => 'Battery',
            'service_type' => 'drop_off',
            'status' => 'delivered',
        ]);

        $response = $this->actingAs($admin)
            ->getJson('/api/technicians?per_page=100&free_for_assignment=1');

        $response->assertOk();

        $ids = collect($response->json('data'))->pluck('id')->all();
        $this->assertContains($freeTechnician->id, $ids);
        $this->assertContains($completedTechnician->id, $ids);
        $this->assertNotContains($busyTechnician->id, $ids);
    }

    public function test_admin_cannot_assign_new_repair_to_technician_with_active_repair()
    {
        $admin = User::factory()->create([
            'is_admin' => true,
            'role' => 'admin',
        ]);

        $customer = User::factory()->create([
            'phone' => '012222222',
            'role' => 'user',
        ]);

        $technician = Technician::create([
            'name' => 'Already Working Tech',
            'availability_status' => 'available',
            'active_jobs_count' => 0,
        ]);

        RepairRequest::create([
            'customer_id' => $customer->id,
            'technician_id' => $technician->id,
            'device_model' => 'Apple iPhone 15',
            'issue_type' => 'Camera',
            'service_type' => 'drop_off',
            'status' => 'diagnosing',
        ]);

        $response = $this->actingAs($admin)
            ->postJson('/api/repairs', [
                'customer_id' => $customer->id,
                'device_model' => 'MacBook Pro M4',
                'issue_type' => 'Keyboard',
                'service_type' => 'drop_off',
                'technician_id' => $technician->id,
            ]);

        $response->assertStatus(422)
            ->assertJsonPath('message', 'Selected technician already has an active repair job.');

        $this->assertDatabaseMissing('repair_requests', [
            'device_model' => 'MacBook Pro M4',
            'issue_type' => 'Keyboard',
        ]);
    }

    public function test_admin_repair_creation_from_problem_fees_generates_customer_invoice()
    {
        $admin = User::factory()->create([
            'is_admin' => true,
            'role' => 'admin',
        ]);

        $customer = User::factory()->create([
            'phone' => '010202030',
            'role' => 'user',
        ]);

        $screen = RepairProblem::create([
            'name' => 'Screen broken',
            'service_fee' => 15.00,
            'status' => 'active',
        ]);

        $battery = RepairProblem::create([
            'name' => 'Battery drains fast',
            'service_fee' => 12.50,
            'status' => 'active',
        ]);

        $response = $this->actingAs($admin)
            ->postJson('/api/repairs', [
                'customer_id' => $customer->id,
                'device_model' => 'Apple iPhone 12',
                'problem_ids' => [$screen->id, $battery->id],
                'service_type' => 'drop_off',
            ]);

        $response->assertCreated()
            ->assertJsonPath('data.issue_type', 'Screen broken, Battery drains fast')
            ->assertJsonPath('data.invoice.subtotal', '27.50')
            ->assertJsonPath('data.invoice.total', '27.50')
            ->assertJsonPath('data.invoice.payment_status', 'pending');

        $repair = RepairRequest::firstOrFail();
        $invoice = Invoice::where('repair_id', $repair->id)->firstOrFail();

        $this->assertDatabaseHas('repair_request_problems', [
            'repair_id' => $repair->id,
            'problem_id' => $screen->id,
        ]);
        $this->assertDatabaseHas('repair_request_problems', [
            'repair_id' => $repair->id,
            'problem_id' => $battery->id,
        ]);
        $this->assertSame('27.50', $invoice->subtotal);
        $this->assertSame('27.50', $invoice->total);

        $this->assertDatabaseHas('repair_notifications', [
            'user_id' => $customer->id,
            'repair_id' => $repair->id,
            'type' => 'invoice',
            'title' => 'Invoice generated',
        ]);

        $this->actingAs($admin)
            ->get('/admin/repairs/'.$repair->id.'/invoice')
            ->assertOk()
            ->assertSee('INVOICE')
            ->assertSee($invoice->invoice_number)
            ->assertSee('Screen broken')
            ->assertSee('Battery drains fast')
            ->assertSee('$27.50');
    }

    public function test_admin_assigning_repair_notifies_linked_technician_user()
    {
        $admin = User::factory()->create([
            'is_admin' => true,
            'role' => 'admin',
        ]);

        $customer = User::factory()->create([
            'phone' => '011222333',
            'role' => 'user',
        ]);

        $technicianUser = User::factory()->create([
            'role' => 'technician',
            'is_admin' => false,
        ]);

        $technician = Technician::create([
            'user_id' => $technicianUser->id,
            'name' => 'Assigned Mobile Tech',
            'availability_status' => 'available',
            'active_jobs_count' => 0,
        ]);

        $repair = RepairRequest::create([
            'customer_id' => $customer->id,
            'device_model' => 'Apple iPhone 12',
            'issue_type' => 'Screen Replacement',
            'service_type' => 'drop_off',
            'status' => 'new',
        ]);

        $response = $this->actingAs($admin)
            ->postJson('/api/repairs/'.$repair->id.'/assign-technician', [
                'technician_id' => $technician->id,
            ]);

        $response->assertOk();

        $this->assertDatabaseHas('repair_requests', [
            'id' => $repair->id,
            'technician_id' => $technician->id,
        ]);

        $this->assertDatabaseHas('repair_notifications', [
            'user_id' => $technicianUser->id,
            'repair_id' => $repair->id,
            'type' => 'assignment',
            'title' => 'New repair assignment',
            'body' => 'Repair #'.$repair->id.' was assigned to you.',
        ]);

        $this->assertDatabaseHas('repair_notifications', [
            'user_id' => $customer->id,
            'repair_id' => $repair->id,
            'type' => 'assignment',
            'title' => 'Technician assigned',
        ]);

        $this->actingAs($technicianUser)
            ->getJson('/api/notifications')
            ->assertOk()
            ->assertJsonPath('data.0.title', 'New repair assignment')
            ->assertJsonPath('data.0.repair_id', $repair->id)
            ->assertJsonPath('data.0.payload.deep_link', '/technician/repairs/'.$repair->id);
    }

    public function test_technician_accepting_repair_notifies_customer()
    {
        $customer = User::factory()->create([
            'phone' => '016555444',
            'role' => 'user',
        ]);

        $technicianUser = User::factory()->create([
            'role' => 'technician',
            'is_admin' => false,
        ]);

        $technician = Technician::create([
            'user_id' => $technicianUser->id,
            'name' => 'Accepting Tech',
            'availability_status' => 'available',
            'active_jobs_count' => 1,
        ]);

        $repair = RepairRequest::create([
            'customer_id' => $customer->id,
            'technician_id' => $technician->id,
            'device_model' => 'Apple iPhone 13',
            'issue_type' => 'Battery',
            'service_type' => 'drop_off',
            'status' => 'assigned',
        ]);

        $this->actingAs($technicianUser)
            ->postJson('/api/technician/repairs/'.$repair->id.'/accept')
            ->assertOk()
            ->assertJsonPath('data.status', 'accepted');

        $this->assertDatabaseHas('repair_notifications', [
            'user_id' => $customer->id,
            'repair_id' => $repair->id,
            'type' => 'status',
            'title' => 'Repair accepted by technician',
        ]);
    }

    public function test_technician_can_update_status_through_process_repair_done_buttons()
    {
        $customer = User::factory()->create([
            'phone' => '016555445',
            'role' => 'user',
        ]);

        $technicianUser = User::factory()->create([
            'role' => 'technician',
            'is_admin' => false,
        ]);

        $technician = Technician::create([
            'user_id' => $technicianUser->id,
            'name' => 'Button Flow Tech',
            'availability_status' => 'available',
            'active_jobs_count' => 1,
        ]);

        $repair = RepairRequest::create([
            'customer_id' => $customer->id,
            'technician_id' => $technician->id,
            'device_model' => 'Apple iPhone 15',
            'issue_type' => 'Charging',
            'service_type' => 'drop_off',
            'status' => 'assigned',
        ]);

        $this->actingAs($technicianUser)
            ->postJson('/api/technician/repairs/'.$repair->id.'/accept')
            ->assertOk()
            ->assertJsonPath('data.status', 'accepted');

        $this->actingAs($technicianUser)
            ->postJson('/api/technician/repairs/'.$repair->id.'/status', [
                'status' => 'diagnosing',
                'note' => 'Technician started processing this repair.',
            ])
            ->assertOk()
            ->assertJsonPath('data.status', 'diagnosing');

        $this->actingAs($technicianUser)
            ->postJson('/api/technician/repairs/'.$repair->id.'/status', [
                'status' => 'in_progress',
                'note' => 'Technician started repair work.',
            ])
            ->assertOk()
            ->assertJsonPath('data.status', 'in_progress');

        $this->actingAs($technicianUser)
            ->postJson('/api/technician/repairs/'.$repair->id.'/status', [
                'status' => 'repair_completed',
                'note' => 'Repair work is done.',
            ])
            ->assertOk()
            ->assertJsonPath('data.status', 'repair_completed');

        $this->assertDatabaseHas('repair_requests', [
            'id' => $repair->id,
            'status' => 'repair_completed',
        ]);
    }

    public function test_technician_rejecting_repair_notifies_customer_and_returns_job()
    {
        $customer = User::factory()->create([
            'phone' => '017555444',
            'role' => 'user',
        ]);

        $technicianUser = User::factory()->create([
            'role' => 'technician',
            'is_admin' => false,
        ]);

        $technician = Technician::create([
            'user_id' => $technicianUser->id,
            'name' => 'Rejecting Tech',
            'availability_status' => 'available',
            'active_jobs_count' => 1,
        ]);

        $repair = RepairRequest::create([
            'customer_id' => $customer->id,
            'technician_id' => $technician->id,
            'device_model' => 'Apple iPhone 14',
            'issue_type' => 'Camera',
            'service_type' => 'drop_off',
            'status' => 'assigned',
        ]);

        $this->actingAs($technicianUser)
            ->postJson('/api/technician/repairs/'.$repair->id.'/reject', [
                'reason' => 'Busy with another repair.',
            ])
            ->assertOk()
            ->assertJsonPath('data.status', 'new')
            ->assertJsonPath('data.technician_id', null);

        $this->assertDatabaseHas('repair_requests', [
            'id' => $repair->id,
            'technician_id' => null,
            'status' => 'new',
        ]);

        $this->assertDatabaseHas('repair_notifications', [
            'user_id' => $customer->id,
            'repair_id' => $repair->id,
            'type' => 'assignment',
            'title' => 'Repair assignment update',
        ]);
    }

    public function test_admin_can_create_customer_with_only_phone_number()
    {
        $admin = User::factory()->create([
            'is_admin' => true,
            'role' => 'admin',
        ]);

        $response = $this->actingAs($admin)
            ->postJson('/api/admin/customers', [
                'phone' => '077123456',
            ]);

        $response->assertCreated();
        $this->assertDatabaseHas('users', [
            'phone' => '077123456',
            'role' => 'user',
        ]);
    }
}
