<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\OtpService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class PhoneAuthController extends Controller
{
    private const OTP_PURPOSE = 'phone_auth';

    public function __construct(
        private OtpService $otpService
    ) {
    }

    public function requestOtp(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'phone' => ['required', 'string', 'max:30'],
            'device_id' => ['nullable', 'string', 'max:191'],
        ]);

        $phone = $this->normalizePhoneOrFail($validated['phone']);

        if ($limited = $this->rateLimitRequest($request, $phone)) {
            return $limited;
        }

        $result = $this->otpService->requestOtp(
            'phone',
            $phone,
            self::OTP_PURPOSE,
            $this->findUserByPhone($phone)?->id,
            $request->ip(),
            $validated['device_id'] ?? null
        );

        return response()->json([
            'message' => $result['message'] ?? 'OTP request processed.',
            'expires_in_sec' => $result['expires_in_sec'] ?? (int) config('otp.ttl_seconds', 300),
            'resend_in_sec' => $result['resend_in_sec'] ?? (int) config('otp.resend_cooldown_seconds', 60),
        ], $result['status'] ?? 200);
    }

    public function verifyOtp(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'phone' => ['required', 'string', 'max:30'],
            'otp' => ['required', 'string', 'regex:/^\d{4,10}$/'],
            'first_name' => ['nullable', 'string', 'max:255'],
            'last_name' => ['nullable', 'string', 'max:255'],
            'email' => ['nullable', 'string', 'lowercase', 'email', 'max:255'],
            'password' => [
                'nullable',
                'string',
                'min:8',
                'regex:/[A-Z]/',
                'regex:/[0-9]/',
                'confirmed',
            ],
        ]);

        $phone = $this->normalizePhoneOrFail($validated['phone']);
        $verify = $this->otpService->verifyOtp('phone', $phone, self::OTP_PURPOSE, $validated['otp']);

        if (! ($verify['ok'] ?? false)) {
            return response()->json([
                'message' => $verify['message'] ?? 'OTP verification failed.',
            ], $verify['status'] ?? 422);
        }

        $user = $this->findUserByPhone($phone);
        $accountCreated = false;

        if (! $user) {
            $user = $this->createPhoneUser($phone, $validated);
            $accountCreated = true;
        } else {
            $dirty = false;
            if (! $user->otp_verified_at) {
                $user->otp_verified_at = now();
                $dirty = true;
            }

            if ($user->phone !== $phone && ! User::where('phone', $phone)->where('id', '!=', $user->id)->exists()) {
                $user->phone = $phone;
                $dirty = true;
            }

            if ($dirty) {
                $user->save();
            }
        }

        $token = $user->createToken('api')->plainTextToken;

        return response()->json([
            'verified' => true,
            'approved' => true,
            'account_created' => $accountCreated,
            'message' => $accountCreated ? 'Account created successfully.' : 'Login successfully.',
            'token' => $token,
            'user' => $user,
        ]);
    }

    /**
     * @param array<string, mixed> $validated
     */
    private function createPhoneUser(string $phone, array $validated): User
    {
        $email = strtolower(trim((string) ($validated['email'] ?? '')));
        if ($email !== '' && User::where('email', $email)->exists()) {
            throw ValidationException::withMessages([
                'email' => ['The email has already been taken.'],
            ]);
        }

        $firstName = trim((string) ($validated['first_name'] ?? ''));
        $lastName = trim((string) ($validated['last_name'] ?? ''));

        return User::create([
            'first_name' => $firstName !== '' ? $firstName : 'Customer',
            'last_name' => $lastName !== '' ? $lastName : substr($phone, -4),
            'email' => $email !== '' ? $email : null,
            'phone' => $phone,
            'password' => Hash::make((string) ($validated['password'] ?? Str::random(40))),
            'role' => 'user',
            'status' => 'active',
            'is_admin' => false,
            'otp_verified_at' => now(),
        ]);
    }

    private function normalizePhoneOrFail(string $phone): string
    {
        $normalized = $this->otpService->normalizeDestination('phone', $phone);

        if ($normalized === '' || strlen($normalized) < 8 || strlen($normalized) > 15) {
            throw ValidationException::withMessages([
                'phone' => ['Please enter a valid phone number.'],
            ]);
        }

        return $normalized;
    }

    private function findUserByPhone(string $phone): ?User
    {
        $candidates = array_values(array_unique(array_filter([
            $phone,
            '+'.$phone,
            ltrim($phone, '+'),
        ])));

        return User::query()
            ->whereIn('phone', $candidates)
            ->first();
    }

    private function rateLimitRequest(Request $request, string $phone): ?JsonResponse
    {
        $ip = (string) $request->ip();
        $ipLimit = (int) config('otp.rate_limit_per_ip_10m', 10);
        $destLimit = (int) config('otp.rate_limit_per_destination_per_hour', 5);
        $cooldown = max(15, (int) config('otp.resend_cooldown_seconds', 60));

        if ($ip !== '' && RateLimiter::tooManyAttempts('phone-auth:ip:'.$ip, $ipLimit)) {
            $retry = RateLimiter::availableIn('phone-auth:ip:'.$ip);

            return response()->json([
                'message' => 'Too many OTP requests. Please retry later.',
                'resend_in_sec' => $retry,
            ], 429);
        }

        if (RateLimiter::tooManyAttempts('phone-auth:dest:'.$phone, $destLimit)) {
            $retry = RateLimiter::availableIn('phone-auth:dest:'.$phone);

            return response()->json([
                'message' => 'Too many OTP requests for this phone number.',
                'resend_in_sec' => $retry,
            ], 429);
        }

        if (RateLimiter::tooManyAttempts('phone-auth:cooldown:'.$phone, 1)) {
            $retry = RateLimiter::availableIn('phone-auth:cooldown:'.$phone);

            return response()->json([
                'message' => 'Please wait before requesting another OTP.',
                'resend_in_sec' => $retry,
            ], 429);
        }

        if ($ip !== '') {
            RateLimiter::hit('phone-auth:ip:'.$ip, 600);
        }
        RateLimiter::hit('phone-auth:dest:'.$phone, 3600);
        RateLimiter::hit('phone-auth:cooldown:'.$phone, $cooldown);

        return null;
    }
}
