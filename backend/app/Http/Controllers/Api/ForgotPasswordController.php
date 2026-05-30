<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\OtpVerification;
use App\Models\User;
use App\Services\OtpService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class ForgotPasswordController extends Controller
{
    private const PURPOSE = 'forgot_password';
    private const RESET_TOKEN_TTL_MINUTES = 15;

    public function __construct(private OtpService $otpService)
    {
    }

    public function sendOtp(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'identifier' => ['required', 'string', 'max:255'],
        ]);

        $resolved = $this->resolveIdentifier($validated['identifier']);
        if (! $resolved) {
            return $this->invalidIdentifierResponse();
        }

        [$type, $destination] = $resolved;
        $user = $this->findUserByDestination($type, $destination);

        if (! $user) {
            return response()->json($this->otpSentPayload());
        }

        $result = $this->otpService->requestOtp(
            destinationType: $type,
            destination: $destination,
            purpose: self::PURPOSE,
            userId: $user->id,
            requestIp: $request->ip(),
            deviceId: $request->header('X-Device-Id')
        );

        return response()->json([
            'message' => $result['message'] ?? 'If this account exists, an OTP was sent.',
            'expiresInSec' => $result['expires_in_sec'] ?? (int) config('otp.ttl_seconds', 300),
            'expires_in_sec' => $result['expires_in_sec'] ?? (int) config('otp.ttl_seconds', 300),
            'resendInSec' => $result['resend_in_sec'] ?? (int) config('otp.resend_cooldown_seconds', 60),
            'resend_in_sec' => $result['resend_in_sec'] ?? (int) config('otp.resend_cooldown_seconds', 60),
        ], $result['status'] ?? 200);
    }

    public function verifyOtp(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'identifier' => ['required', 'string', 'max:255'],
            'otp' => ['required', 'string', 'regex:/^\d{6}$/'],
        ]);

        $resolved = $this->resolveIdentifier($validated['identifier']);
        if (! $resolved) {
            return $this->invalidIdentifierResponse();
        }

        [$type, $destination] = $resolved;
        $user = $this->findUserByDestination($type, $destination);
        if (! $user) {
            return response()->json([
                'message' => 'Invalid OTP. Please try again.',
            ], 422);
        }

        $verify = $this->otpService->verifyOtp($type, $destination, self::PURPOSE, $validated['otp']);
        if (! ($verify['ok'] ?? false)) {
            return response()->json([
                'message' => $this->otpErrorMessage($verify['message'] ?? null),
            ], $verify['status'] ?? 422);
        }

        $resetToken = Str::random(64);
        Cache::put($this->resetTokenCacheKey($resetToken), [
            'user_id' => $user->id,
            'destination' => $destination,
            'type' => $type,
        ], now()->addMinutes(self::RESET_TOKEN_TTL_MINUTES));

        return response()->json([
            'message' => 'OTP verified. You can reset your password.',
            'resetPasswordToken' => $resetToken,
            'reset_token' => $resetToken,
            'expiresInSec' => self::RESET_TOKEN_TTL_MINUTES * 60,
            'expires_in_sec' => self::RESET_TOKEN_TTL_MINUTES * 60,
        ]);
    }

    public function resetPassword(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'resetPasswordToken' => ['required', 'string', 'min:20'],
            'newPassword' => [
                'required',
                'string',
                'min:8',
                'regex:/[A-Z]/',
                'regex:/[0-9]/',
            ],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => $validator->errors()->first(),
                'errors' => $validator->errors(),
            ], 422);
        }

        $validated = $validator->validated();
        $payload = Cache::get($this->resetTokenCacheKey($validated['resetPasswordToken']));
        if (! $payload || ! is_array($payload) || empty($payload['user_id'])) {
            return response()->json([
                'message' => 'Invalid or expired reset token.',
            ], 422);
        }

        $user = User::find($payload['user_id']);
        if (! $user) {
            return response()->json([
                'message' => 'User not found.',
            ], 404);
        }

        $user->password = Hash::make($validated['newPassword']);
        $user->save();

        Cache::forget($this->resetTokenCacheKey($validated['resetPasswordToken']));

        OtpVerification::query()
            ->where('user_id', $user->id)
            ->where('purpose', self::PURPOSE)
            ->when(! empty($payload['type']), fn ($query) => $query->where('destination_type', $payload['type']))
            ->when(! empty($payload['destination']), fn ($query) => $query->where('destination', $payload['destination']))
            ->delete();

        return response()->json([
            'message' => 'Password reset successfully. Please login.',
        ]);
    }

    private function resolveIdentifier(string $identifier): ?array
    {
        $identifier = trim($identifier);

        if (filter_var($identifier, FILTER_VALIDATE_EMAIL)) {
            return ['email', $this->otpService->normalizeDestination('email', $identifier)];
        }

        $phone = $this->otpService->normalizeDestination('phone', $identifier);
        if ($phone !== '' && strlen($phone) >= 8 && strlen($phone) <= 15) {
            return ['phone', $phone];
        }

        return null;
    }

    private function findUserByDestination(string $type, string $destination): ?User
    {
        if ($type === 'phone') {
            $candidates = array_values(array_unique(array_filter([
                $destination,
                '+'.$destination,
                ltrim($destination, '+'),
                $this->otpService->normalizeDestination('phone', $destination),
            ])));

            return User::query()
                ->whereIn('phone', $candidates)
                ->first();
        }

        return User::where('email', $destination)->first();
    }

    private function resetTokenCacheKey(string $token): string
    {
        return 'forgot_password_reset_token:'.hash_hmac('sha256', $token, (string) config('app.key'));
    }

    private function otpSentPayload(): array
    {
        return [
            'message' => 'If this account exists, an OTP was sent.',
            'expiresInSec' => (int) config('otp.ttl_seconds', 300),
            'expires_in_sec' => (int) config('otp.ttl_seconds', 300),
            'resendInSec' => (int) config('otp.resend_cooldown_seconds', 60),
            'resend_in_sec' => (int) config('otp.resend_cooldown_seconds', 60),
        ];
    }

    private function invalidIdentifierResponse(): JsonResponse
    {
        return response()->json([
            'message' => 'Enter a valid phone number or email address.',
            'errors' => [
                'identifier' => ['Enter a valid phone number or email address.'],
            ],
        ], 422);
    }

    private function otpErrorMessage(?string $message): string
    {
        $text = strtolower((string) $message);

        if (str_contains($text, 'expired')) {
            return 'OTP expired. Please request a new code.';
        }

        if (str_contains($text, 'locked') || str_contains($text, 'too many')) {
            return 'Too many invalid attempts. Please request a new code.';
        }

        return 'Invalid OTP. Please try again.';
    }
}
