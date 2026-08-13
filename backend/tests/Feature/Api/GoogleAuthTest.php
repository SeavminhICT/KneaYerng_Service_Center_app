<?php

use App\Models\User;
use App\Services\GoogleIdTokenVerifier;

function fakeGoogleIdToken(array $claims, bool $valid = true): void
{
    app()->bind(GoogleIdTokenVerifier::class, fn () => new class($claims, $valid) extends GoogleIdTokenVerifier
    {
        public function __construct(private array $claims, private bool $valid) {}

        public function verify(string $idToken): array
        {
            if (! $this->valid || $idToken !== 'valid-id-token') {
                throw new RuntimeException('Invalid Google ID token.');
            }

            return $this->claims;
        }
    });
}

test('google login accepts gmail accounts without a last name', function () {
    fakeGoogleIdToken([
        'email' => 'SingleName@gmail.com',
        'email_verified' => true,
        'given_name' => 'SingleName',
        'picture' => 'https://lh3.googleusercontent.com/avatar.jpg',
    ]);

    $this->postJson('/api/auth/google', [
        'id_token' => 'valid-id-token',
        'email' => 'spoofed@gmail.com',
        'first_name' => 'Spoofed',
        'last_name' => 'Name',
    ])
        ->assertOk()
        ->assertJsonPath('message', 'Login successfully via Google')
        ->assertJsonStructure(['token', 'user'])
        ->assertJsonPath('user.email', 'singlename@gmail.com')
        ->assertJsonPath('user.first_name', 'SingleName')
        ->assertJsonPath('user.last_name', 'User');

    $user = User::where('email', 'singlename@gmail.com')->firstOrFail();

    expect($user->otp_verified_at)->not->toBeNull()
        ->and($user->email_verified_at)->not->toBeNull();
});

test('google login marks an existing matching account as verified', function () {
    fakeGoogleIdToken([
        'email' => 'existing@gmail.com',
        'email_verified' => true,
        'given_name' => 'Existing',
    ]);

    $user = User::factory()->unverified()->create([
        'email' => 'existing@gmail.com',
        'otp_verified_at' => null,
    ]);

    $this->postJson('/api/auth/google', [
        'id_token' => 'valid-id-token',
        'email' => 'existing@gmail.com',
        'first_name' => 'Existing',
        'last_name' => '',
    ])
        ->assertOk()
        ->assertJsonPath('user.id', $user->id)
        ->assertJsonStructure(['token']);

    $user->refresh();

    expect($user->email_verified_at)->not->toBeNull()
        ->and($user->otp_verified_at)->not->toBeNull();
});

test('google login rejects an invalid id token', function () {
    fakeGoogleIdToken([], valid: false);

    $this->postJson('/api/auth/google', [
        'id_token' => 'invalid-id-token',
        'email' => 'attacker@gmail.com',
        'first_name' => 'Attacker',
        'last_name' => 'User',
    ])
        ->assertUnauthorized()
        ->assertJsonPath('message', 'Google login could not be verified. Please try again.');
});

test('google login remains compatible with older app builds without id token', function () {
    $this->postJson('/api/auth/google', [
        'email' => 'oldapp@gmail.com',
        'first_name' => 'Old',
        'last_name' => '',
        'avatar' => 'https://lh3.googleusercontent.com/old.jpg',
    ])
        ->assertOk()
        ->assertJsonPath('message', 'Login successfully via Google')
        ->assertJsonStructure(['token', 'user'])
        ->assertJsonPath('user.email', 'oldapp@gmail.com')
        ->assertJsonPath('user.first_name', 'Old')
        ->assertJsonPath('user.last_name', 'User');
});
