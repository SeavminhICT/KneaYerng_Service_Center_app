<?php

use App\Models\User;

test('facebook login registers a new user when email is provided', function () {
    $this->postJson('/api/auth/facebook', [
        'facebook_id' => '1234567890',
        'email' => 'fbnew@example.com',
        'first_name' => 'John',
        'last_name' => 'Doe',
        'avatar' => 'https://facebook.com/avatar.jpg',
    ])
        ->assertOk()
        ->assertJsonPath('message', 'Login successfully via Facebook')
        ->assertJsonStructure(['token', 'user'])
        ->assertJsonPath('user.email', 'fbnew@example.com');

    $this->assertDatabaseHas('users', [
        'email' => 'fbnew@example.com',
        'first_name' => 'John',
        'last_name' => 'Doe',
    ]);
});

test('facebook login logs in an existing user with matching email', function () {
    $user = User::factory()->create([
        'email' => 'existing@example.com',
        'first_name' => 'Jane',
        'last_name' => 'Smith',
    ]);

    $this->postJson('/api/auth/facebook', [
        'facebook_id' => '987654321',
        'email' => 'existing@example.com',
        'first_name' => 'Jane',
        'last_name' => 'Smith',
        'avatar' => 'https://facebook.com/avatar.jpg',
    ])
        ->assertOk()
        ->assertJsonPath('user.id', $user->id)
        ->assertJsonStructure(['token']);
});

test('facebook login handles missing email by generating a fallback', function () {
    $facebookId = '555666777';
    $fallbackEmail = "fb_{$facebookId}@facebook.com";

    $this->postJson('/api/auth/facebook', [
        'facebook_id' => $facebookId,
        'email' => null,
        'first_name' => 'NoEmail',
        'last_name' => 'User',
    ])
        ->assertOk()
        ->assertJsonPath('user.email', $fallbackEmail)
        ->assertJsonStructure(['token']);

    $this->assertDatabaseHas('users', [
        'email' => $fallbackEmail,
        'first_name' => 'NoEmail',
        'last_name' => 'User',
    ]);
});
