<?php

use App\Models\User;

it('lists all app customers and excludes dashboard accounts', function () {
    $admin = User::factory()->create([
        'first_name' => 'Admin',
        'last_name' => 'Account',
        'role' => 'admin',
        'is_admin' => true,
    ]);
    $customer = User::factory()->create([
        'first_name' => 'Verified',
        'last_name' => 'Customer',
        'email' => null,
        'role' => 'user',
        'status' => 'active',
        'is_admin' => false,
        'otp_verified_at' => now(),
    ]);
    $pendingCustomer = User::factory()->create([
        'first_name' => 'Pending',
        'last_name' => 'Customer',
        'email' => null,
        'role' => 'user',
        'status' => 'active',
        'is_admin' => false,
        'otp_verified_at' => null,
    ]);
    $staff = User::factory()->create([
        'first_name' => 'Staff',
        'last_name' => 'Account',
        'role' => 'staff',
        'status' => 'active',
        'is_admin' => false,
    ]);

    $response = $this
        ->actingAs($admin)
        ->get('/admin/customers');

    $response
        ->assertOk()
        ->assertViewHas('customers', function ($customers) use (
            $customer,
            $pendingCustomer,
            $staff
        ) {
            $ids = $customers->pluck('id');

            return $ids->contains($customer->id)
                && $ids->contains($pendingCustomer->id)
                && ! $ids->contains($staff->id);
        });
});

it('creates mobile registrations as active non-admin customers', function () {
    $response = $this->postJson('/api/auth/register', [
        'first_name' => 'New',
        'last_name' => 'Customer',
        'phone' => '012345678',
        'password' => 'Password1',
        'password_confirmation' => 'Password1',
    ]);

    $response
        ->assertCreated()
        ->assertJsonPath('user.role', 'user')
        ->assertJsonPath('user.status', 'active')
        ->assertJsonPath('user.is_admin', false);

    $this->assertDatabaseHas('users', [
        'phone' => '85512345678',
        'role' => 'user',
        'status' => 'active',
        'is_admin' => false,
    ]);
});
