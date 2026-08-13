<?php

use App\Models\User;
use App\Support\AuthRedirect;

it('creates technician login accounts that do not show the admin notification prompt', function () {
    $admin = User::factory()->create([
        'role' => 'admin',
        'is_admin' => true,
    ]);

    $createResponse = $this
        ->actingAs($admin)
        ->postJson('/api/technicians', [
            'name' => 'LY LY',
            'skill_set' => ['Phone repair'],
            'availability_status' => 'available',
            'email' => 'adminlyyy@example.test',
            'phone' => '012345678',
            'password' => 'Password123',
        ]);

    $createResponse
        ->assertCreated()
        ->assertJsonPath('data.email', 'adminlyyy@example.test')
        ->assertJsonPath('data.has_login', true);

    $technicianUser = User::where('email', 'adminlyyy@example.test')->firstOrFail();

    expect($technicianUser->role)->toBe('technician')
        ->and($technicianUser->is_admin)->toBeFalse()
        ->and($technicianUser->roles()->exists())->toBeFalse()
        ->and($technicianUser->canAccessAdminPanel())->toBeFalse();

    $this->post('/logout');

    $loginResponse = $this->post('/login', [
        'email' => 'adminlyyy@example.test',
        'password' => 'Password123',
    ]);

    $this->assertAuthenticatedAs($technicianUser);
    $loginResponse
        ->assertRedirect(route('technician.jobs'))
        ->assertSessionMissing('just_logged_in');

    expect(AuthRedirect::destination($technicianUser))->toBe(route('technician.jobs'));

    $this->get('/technician/jobs')
        ->assertOk()
        ->assertSee('My Repair Jobs')
        ->assertSee('Assigned Repairs')
        ->assertSee('Process');
});

it('blocks non technician users from technician jobs page', function () {
    $user = User::factory()->create([
        'role' => 'user',
        'is_admin' => false,
    ]);

    $this->actingAs($user)
        ->get('/technician/jobs')
        ->assertForbidden();
});
