<?php

use App\Models\User;
use App\Services\TwilioOtpService;

test('phone auth requests a Twilio Verify OTP', function () {
    $this->mock(TwilioOtpService::class, function ($mock) {
        $mock->shouldReceive('sendVerification')
            ->once()
            ->with('+85512345678', 'sms')
            ->andReturn([
                'ok' => true,
                'status' => 200,
                'message' => 'OTP sent to your phone.',
            ]);
    });

    $this->postJson('/api/auth/phone/request-otp', [
        'phone' => '012 345 678',
    ])
        ->assertOk()
        ->assertJsonPath('message', 'OTP sent to your phone.')
        ->assertJsonStructure(['expires_in_sec', 'resend_in_sec']);
});

test('phone auth verifies and logs in an existing user', function () {
    $user = User::factory()->create([
        'phone' => '85512345678',
        'otp_verified_at' => null,
    ]);

    $this->mock(TwilioOtpService::class, function ($mock) {
        $mock->shouldReceive('checkVerification')
            ->once()
            ->with('+85512345678', '123456')
            ->andReturn([
                'ok' => true,
                'status' => 200,
                'message' => 'OTP verified successfully.',
                'approved' => true,
            ]);
    });

    $this->postJson('/api/auth/phone/verify', [
        'phone' => '012 345 678',
        'otp' => '123456',
    ])
        ->assertOk()
        ->assertJsonPath('account_created', false)
        ->assertJsonPath('user.id', $user->id)
        ->assertJsonStructure(['token']);

    expect($user->refresh()->otp_verified_at)->not->toBeNull();
});

test('phone auth verifies and creates an account for a new phone', function () {
    $this->mock(TwilioOtpService::class, function ($mock) {
        $mock->shouldReceive('checkVerification')
            ->once()
            ->with('+85512345678', '123456')
            ->andReturn([
                'ok' => true,
                'status' => 200,
                'message' => 'OTP verified successfully.',
                'approved' => true,
            ]);
    });

    $this->postJson('/api/auth/phone/verify', [
        'phone' => '012 345 678',
        'otp' => '123456',
        'first_name' => 'Dara',
        'last_name' => 'Customer',
        'email' => 'dara@example.com',
        'password' => 'Password1',
        'password_confirmation' => 'Password1',
    ])
        ->assertOk()
        ->assertJsonPath('account_created', true)
        ->assertJsonPath('user.phone', '85512345678')
        ->assertJsonStructure(['token']);

    $this->assertDatabaseHas('users', [
        'phone' => '85512345678',
        'first_name' => 'Dara',
        'last_name' => 'Customer',
        'email' => 'dara@example.com',
    ]);
});
