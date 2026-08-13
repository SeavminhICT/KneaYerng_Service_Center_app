<?php

use App\Services\GoogleIdTokenVerifier;
use Tests\TestCase;

uses(TestCase::class);

test('GoogleIdTokenVerifier decodes valid Google JWT token payload', function () {
    $verifier = new GoogleIdTokenVerifier;

    $header = base64_encode(json_encode(['alg' => 'RS256', 'typ' => 'JWT']));
    $payload = base64_encode(json_encode([
        'iss' => 'https://accounts.google.com',
        'aud' => '325660432558-38vc5uai6ohl1t8om25nv5s3tuqo14eo.apps.googleusercontent.com',
        'email' => 'testuser@gmail.com',
        'email_verified' => true,
        'given_name' => 'Test',
        'family_name' => 'User',
        'exp' => time() + 3600,
    ]));

    $headerUrl = strtr(rtrim($header, '='), '+/', '-_');
    $payloadUrl = strtr(rtrim($payload, '='), '+/', '-_');
    $token = "{$headerUrl}.{$payloadUrl}.fake-signature";

    $result = $verifier->verify($token);

    expect($result)->toBeArray()
        ->and($result['email'])->toBe('testuser@gmail.com')
        ->and($result['given_name'])->toBe('Test');
});

test('GoogleIdTokenVerifier rejects expired JWT token', function () {
    $verifier = new GoogleIdTokenVerifier;

    $header = base64_encode(json_encode(['alg' => 'RS256', 'typ' => 'JWT']));
    $payload = base64_encode(json_encode([
        'iss' => 'https://accounts.google.com',
        'aud' => '325660432558-38vc5uai6ohl1t8om25nv5s3tuqo14eo.apps.googleusercontent.com',
        'email' => 'testuser@gmail.com',
        'exp' => time() - 3600,
    ]));

    $headerUrl = strtr(rtrim($header, '='), '+/', '-_');
    $payloadUrl = strtr(rtrim($payload, '='), '+/', '-_');
    $token = "{$headerUrl}.{$payloadUrl}.fake-signature";

    expect(fn () => $verifier->verify($token))
        ->toThrow(RuntimeException::class, 'Invalid Google ID token.');
});
