<?php

namespace Tests\Feature\Admin;

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
            'status' => 'waiting_diagnosis',
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
            'status' => 'waiting_diagnosis',
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
