<?php

use App\Models\User;
use App\Services\OtpDeliveryService;

function mockPhoneOtpDeliveryAndCaptureCode(): stdClass
{
    $captured = new stdClass;
    $captured->code = null;

    test()->mock(OtpDeliveryService::class, function ($mock) use ($captured) {
        $mock->shouldReceive('send')
            ->once()
            ->with('phone', '85512345678', Mockery::type('string'), Mockery::type('array'))
            ->andReturnUsing(function (string $type, string $destination, string $message, array $context) use ($captured) {
                $captured->code = $context['code'];

                return true;
            });
    });

    return $captured;
}

test('phone auth requests an OTP via the delivery service', function () {
    mockPhoneOtpDeliveryAndCaptureCode();

    $this->postJson('/api/auth/phone/request-otp', [
        'phone' => '012 345 678',
    ])
        ->assertOk()
        ->assertJsonPath('message', 'OTP code sent successfully.')
        ->assertJsonStructure(['expires_in_sec', 'resend_in_sec']);
});

test('phone auth hides local fallback details from the api response', function () {
    config([
        'app.debug' => true,
        'otp.local_fallback' => true,
    ]);

    test()->mock(OtpDeliveryService::class, function ($mock) {
        $mock->shouldReceive('send')
            ->once()
            ->with('phone', '85512345678', Mockery::type('string'), Mockery::type('array'))
            ->andReturn(false);
    });

    $this->postJson('/api/auth/phone/request-otp', [
        'phone' => '012 345 678',
    ])
        ->assertOk()
        ->assertJsonPath('message', 'OTP code sent successfully.');
});

test('phone auth verifies and logs in an existing user', function () {
    $user = User::factory()->create([
        'phone' => '85512345678',
        'otp_verified_at' => null,
    ]);

    $captured = mockPhoneOtpDeliveryAndCaptureCode();

    $this->postJson('/api/auth/phone/request-otp', [
        'phone' => '012 345 678',
    ])->assertOk();

    $this->postJson('/api/auth/phone/verify', [
        'phone' => '012 345 678',
        'otp' => $captured->code,
    ])
        ->assertOk()
        ->assertJsonPath('account_created', false)
        ->assertJsonPath('user.id', $user->id)
        ->assertJsonStructure(['token']);

    expect($user->refresh()->otp_verified_at)->not->toBeNull();
});

test('phone auth verifies and creates an account for a new phone', function () {
    $captured = mockPhoneOtpDeliveryAndCaptureCode();

    $this->postJson('/api/auth/phone/request-otp', [
        'phone' => '012 345 678',
    ])->assertOk();

    $this->postJson('/api/auth/phone/verify', [
        'phone' => '012 345 678',
        'otp' => $captured->code,
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

test('phone auth rejects an incorrect OTP', function () {
    mockPhoneOtpDeliveryAndCaptureCode();

    $this->postJson('/api/auth/phone/request-otp', [
        'phone' => '012 345 678',
    ])->assertOk();

    $this->postJson('/api/auth/phone/verify', [
        'phone' => '012 345 678',
        'otp' => '000000',
    ])->assertStatus(422);
});
