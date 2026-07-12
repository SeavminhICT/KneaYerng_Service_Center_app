<?php

use App\Models\Permission;
use App\Models\Role;
use App\Models\User;

function seedManagerRole(): Role
{
    $role = Role::create(['name' => 'Manager', 'description' => 'Manages things']);

    foreach (['view_user', 'create_user', 'update_user', 'delete_user'] as $name) {
        $role->permissions()->attach(Permission::create(['name' => $name])->id);
    }

    return $role;
}

it('lists role-based and legacy staff accounts in admin user management', function () {
    $managerRole = seedManagerRole();

    $admin = User::factory()->create([
        'first_name' => 'Admin',
        'role' => 'admin',
        'is_admin' => true,
    ]);
    $manager = User::factory()->create([
        'first_name' => 'Manager',
        'role' => 'webadmin',
        'is_admin' => false,
    ]);
    $manager->roles()->attach($managerRole->id);
    $staff = User::factory()->create([
        'first_name' => 'Staff',
        'role' => 'staff',
        'is_admin' => false,
    ]);
    $technician = User::factory()->create([
        'first_name' => 'Technician',
        'role' => 'technician',
        'is_admin' => false,
    ]);
    $customer = User::factory()->create([
        'first_name' => 'Customer',
        'role' => 'user',
        'is_admin' => false,
    ]);

    $response = $this
        ->actingAs($admin)
        ->getJson('/api/admin/users');

    $ids = collect($response->json('data'))->pluck('id');

    $response->assertOk();
    expect($ids)
        ->toContain($staff->id)
        ->toContain($technician->id)
        ->toContain($manager->id)
        ->not->toContain($admin->id)
        ->not->toContain($customer->id);
});

it('creates a web admin user with a role from the roles table', function () {
    $managerRole = seedManagerRole();

    $admin = User::factory()->create([
        'role' => 'admin',
        'is_admin' => true,
    ]);

    $response = $this
        ->actingAs($admin)
        ->postJson('/api/admin/users', [
            'first_name' => 'New',
            'last_name' => 'Manager',
            'email' => 'new-manager@example.test',
            'phone' => null,
            'role_id' => $managerRole->id,
            'password' => 'Password123',
        ]);

    $response
        ->assertCreated()
        ->assertJsonPath('data.role_name', 'Manager');

    $user = User::where('email', 'new-manager@example.test')->firstOrFail();

    expect($user->is_admin)->toBeFalse()
        ->and($user->role)->toBe('webadmin')
        ->and($user->roles()->pluck('roles.id')->all())->toBe([$managerRole->id])
        ->and($user->hasPermission('view_user'))->toBeTrue()
        ->and($user->canAccessAdminPanel())->toBeTrue();
});

it('rejects creating a user without a valid role', function () {
    $admin = User::factory()->create([
        'role' => 'admin',
        'is_admin' => true,
    ]);

    $response = $this
        ->actingAs($admin)
        ->postJson('/api/admin/users', [
            'first_name' => 'Blocked',
            'last_name' => 'Account',
            'email' => 'blocked@example.test',
            'phone' => null,
            'role_id' => 999999,
            'password' => 'Password123',
        ]);

    $response
        ->assertStatus(422)
        ->assertInvalid(['role_id']);
});

it('never grants super admin through user management', function () {
    $adminRole = Role::create(['name' => 'Admin', 'description' => 'Full access']);

    $admin = User::factory()->create([
        'role' => 'admin',
        'is_admin' => true,
    ]);

    $response = $this
        ->actingAs($admin)
        ->postJson('/api/admin/users', [
            'first_name' => 'Role',
            'last_name' => 'Admin',
            'email' => 'role-admin@example.test',
            'phone' => null,
            'role_id' => $adminRole->id,
            'password' => 'Password123',
        ]);

    $response->assertCreated();

    $user = User::where('email', 'role-admin@example.test')->firstOrFail();

    // Access comes from the role's permissions, never the super admin bypass.
    expect($user->is_admin)->toBeFalse()
        ->and($user->role)->not->toBe('admin')
        ->and($user->isAdmin())->toBeFalse();
});

it('blocks users without permission from managing users', function () {
    $role = Role::create(['name' => 'Viewer', 'description' => 'No user management']);
    Permission::create(['name' => 'view_dashboard']);
    $role->permissions()->attach(Permission::where('name', 'view_dashboard')->first()->id);

    $viewer = User::factory()->create([
        'role' => 'webadmin',
        'is_admin' => false,
    ]);
    $viewer->roles()->attach($role->id);

    $this
        ->actingAs($viewer)
        ->getJson('/api/admin/users')
        ->assertForbidden();

    $this
        ->actingAs($viewer)
        ->postJson('/api/admin/users', [
            'first_name' => 'X',
            'email' => 'x@example.test',
            'role_id' => $role->id,
            'password' => 'Password123',
        ])
        ->assertForbidden();
});
