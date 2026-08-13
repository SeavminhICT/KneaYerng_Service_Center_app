<?php

use App\Models\Role;
use App\Models\User;
use App\Support\AuthRedirect;

test('login screen can be rendered', function () {
    $response = $this->get('/login');

    $response->assertStatus(200);
});

test('users can authenticate using the login screen', function () {
    $user = User::factory()->create();

    $response = $this->post('/login', [
        'email' => $user->email,
        'password' => 'password',
    ]);

    $this->assertAuthenticated();
    $response->assertRedirect(AuthRedirect::destination($user));
});

test('admin panel users see the login notification prompt flag', function () {
    $role = Role::create(['name' => 'Staff']);
    $user = User::factory()->create(['role' => 'staff']);
    $user->roles()->attach($role->id);

    $response = $this->post('/login', [
        'email' => $user->email,
        'password' => 'password',
    ]);

    $this->assertAuthenticatedAs($user);
    $response
        ->assertRedirect(AuthRedirect::destination($user))
        ->assertSessionHas('just_logged_in', true);
});

test('technician login skips the notification prompt flag', function () {
    $role = Role::create(['name' => 'Technician']);
    $user = User::factory()->create(['role' => 'technician']);
    $user->roles()->attach($role->id);

    $response = $this->post('/login', [
        'email' => $user->email,
        'password' => 'password',
    ]);

    $this->assertAuthenticatedAs($user);
    $response
        ->assertRedirect(AuthRedirect::destination($user))
        ->assertSessionMissing('just_logged_in');
});

test('users can not authenticate with invalid password', function () {
    $user = User::factory()->create();

    $this->post('/login', [
        'email' => $user->email,
        'password' => 'wrong-password',
    ]);

    $this->assertGuest();
});

test('users can logout', function () {
    $user = User::factory()->create();

    $response = $this->actingAs($user)->post('/logout');

    $this->assertGuest();
    $response->assertRedirect('/');
});
