<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\FirebaseAuthService;
use App\Services\OtpService;
use App\Services\UnimatrixOtpService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Kreait\Firebase\Exception\Auth\FailedToVerifyToken;
use Kreait\Firebase\Exception\FirebaseException;

class OtpController extends Controller
{
    public function __construct(
        private OtpService $otpService,
        private FirebaseAuthService $firebaseAuth,
        private UnimatrixOtpService $unimatrixOtp
    )
    {
    }

    public function request(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'destination' => ['required', 'string', 'max:255'],
            'type' => ['required', 'in:email,phone'],
            'purpose' => ['required', 'in:signup,login,reset_password,change_phone,change_email'],
            'device_id' => ['nullable', 'string', 'max:191'],
        ]);

        $type = $this->otpService->normalizeType($validated['type']);
        $destination = $this->otpService->normalizeDestination($type, $validated['destination']);
        $purpose = strtolower($validated['purpose']);

        $user = $this->findUserByDestination($type, $destination);
        if ($purpose !== 'signup' && ! $user) {
            return response()->json([
                'message' => 'If this destination exists, an OTP was sent.',
                'expires_in_sec' => (int) config('otp.ttl_seconds', 300),
                'resend_in_sec' => (int) config('otp.resend_cooldown_seconds', 60),
            ]);
        }

        if ($purpose === 'signup' && ! $user) {
            return response()->json([
                'message' => 'Account not found for signup verification.',
            ], 404);
        }

        if ($type === 'phone') {
            $result = $this->unimatrixOtp->sendOtp($destination, $purpose, $request->ip());
        } else {
            $result = $this->otpService->requestOtp(
                destinationType: $type,
                destination: $destination,
                purpose: $purpose,
                userId: $user?->id,
                requestIp: $request->ip(),
                deviceId: $validated['device_id'] ?? null,
                silentIfUserMissing: true
            );
        }

        return response()->json([
            'message' => $result['message'] ?? 'OTP request processed.',
            'expires_in_sec' => $result['expires_in_sec'] ?? (int) config('otp.ttl_seconds', 300),
            'resend_in_sec' => $result['resend_in_sec'] ?? (int) config('otp.resend_cooldown_seconds', 60),
        ], $result['status'] ?? 200);
    }

    public function verify(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'destination' => ['required', 'string', 'max:255'],
            'type' => ['required', 'in:email,phone'],
            'purpose' => ['required', 'in:signup,login,reset_password,change_phone,change_email'],
            'otp' => ['required', 'string', 'max:12'],
        ]);

        $type = $this->otpService->normalizeType($validated['type']);
        $destination = $this->otpService->normalizeDestination($type, $validated['destination']);
        $purpose = strtolower($validated['purpose']);

        $verify = $type === 'phone'
            ? $this->unimatrixOtp->verifyOtp($destination, $validated['otp'])
            : $this->otpService->verifyOtp($type, $destination, $purpose, $validated['otp']);
        if (! ($verify['ok'] ?? false)) {
            return response()->json(['message' => $verify['message'] ?? 'OTP verification failed.'], $verify['status'] ?? 422);
        }

        $user = $this->findUserByDestination($type, $destination);

        if ($purpose === 'signup') {
            if (! $user) {
                return response()->json(['message' => 'Account not found.'], 404);
            }
            $user->otp_verified_at = now();
            if ($type === 'email' && ! $user->email_verified_at) {
                $user->email_verified_at = now();
            }
            $user->save();

            $token = $user->createToken('api')->plainTextToken;

            return response()->json([
                'verified' => true,
                'message' => 'Signup OTP verified.',
                'token' => $token,
                'user' => $user,
            ]);
        }

        if ($purpose === 'login') {
            if (! $user) {
                return response()->json(['message' => 'Invalid login destination.'], 404);
            }

            $token = $user->createToken('api')->plainTextToken;

            return response()->json([
                'verified' => true,
                'message' => 'Login OTP verified.',
                'token' => $token,
                'user' => $user,
            ]);
        }

        if ($purpose === 'reset_password') {
            if (! $user) {
                return response()->json(['message' => 'Invalid destination.'], 404);
            }

            $resetToken = Str::random(64);
            Cache::put('otp_reset_token:'.$resetToken, [
                'user_id' => $user->id,
                'destination' => $destination,
                'type' => $type,
            ], now()->addMinutes(15));

            return response()->json([
                'verified' => true,
                'message' => 'OTP verified. You can reset your password.',
                'reset_token' => $resetToken,
            ]);
        }

        return response()->json([
            'verified' => true,
            'message' => 'OTP verified successfully.',
        ]);
    }

    public function verifyFirebasePhone(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'id_token' => ['required', 'string'],
            'purpose' => ['required', 'in:signup,login,reset_password,change_phone,change_email'],
            'destination' => ['nullable', 'string', 'max:255'],
        ]);

        if ((string) config('services.firebase.project_id', '') === '' ||
            (string) config('services.firebase.credentials', '') === '') {
            return response()->json(['message' => 'Firebase is not configured.'], 500);
        }

        try {
            $claims = $this->firebaseAuth->verifyIdToken($validated['id_token']);
        } catch (FailedToVerifyToken|FirebaseException|\Throwable $exception) {
            return response()->json(['message' => 'Invalid or expired Firebase token.'], 401);
        }

        $phoneNumber = (string) ($claims['phone_number'] ?? '');
        if ($phoneNumber === '') {
            return response()->json(['message' => 'Phone number not available in Firebase token.'], 422);
        }

        $normalized = $this->otpService->normalizeDestination('phone', $phoneNumber);
        $requested = null;
        if (! empty($validated['destination'])) {
            $requested = $this->otpService->normalizeDestination('phone', $validated['destination']);
        }

        $purpose = strtolower($validated['purpose']);
        $user = User::where('phone', $normalized)->first();
        if (! $user && $requested) {
            $user = User::where('phone', $requested)->first();
        }

        if (! $user) {
            return response()->json([
                'message' => $purpose === 'signup'
                    ? 'Account not found for signup verification.'
                    : 'Invalid destination.',
            ], 404);
        }

        if ($purpose === 'signup') {
            $user->otp_verified_at = now();
            $user->save();

            $token = $user->createToken('api')->plainTextToken;

            return response()->json([
                'verified' => true,
                'message' => 'Signup OTP verified.',
                'token' => $token,
                'user' => $user,
            ]);
        }

        if ($purpose === 'login') {
            $token = $user->createToken('api')->plainTextToken;

            return response()->json([
                'verified' => true,
                'message' => 'Login OTP verified.',
                'token' => $token,
                'user' => $user,
            ]);
        }

        if ($purpose === 'reset_password') {
            $resetToken = Str::random(64);
            Cache::put('otp_reset_token:'.$resetToken, [
                'user_id' => $user->id,
                'destination' => $normalized,
                'type' => 'phone',
            ], now()->addMinutes(15));

            return response()->json([
                'verified' => true,
                'message' => 'OTP verified. You can reset your password.',
                'reset_token' => $resetToken,
            ]);
        }

        return response()->json([
            'verified' => true,
            'message' => 'OTP verified successfully.',
        ]);
    }

    public function resetPassword(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'reset_token' => ['required', 'string', 'min:20'],
            'password' => [
                'required',
                'string',
                'min:8',
                'regex:/[A-Z]/',
                'regex:/[0-9]/',
                'confirmed',
            ],
        ]);

        $payload = Cache::get('otp_reset_token:'.$validated['reset_token']);
        if (! $payload || ! is_array($payload) || empty($payload['user_id'])) {
            return response()->json(['message' => 'Invalid or expired reset token.'], 422);
        }

        $user = User::find($payload['user_id']);
        if (! $user) {
            return response()->json(['message' => 'User not found.'], 404);
        }

        $user->password = Hash::make($validated['password']);
        $user->save();

        Cache::forget('otp_reset_token:'.$validated['reset_token']);

        return response()->json([
            'message' => 'Password reset successfully.',
        ]);
    }

    private function findUserByDestination(string $type, string $destination): ?User
    {
        if ($type === 'phone') {
            $candidates = array_values(array_unique(array_filter([
                $destination,
                ltrim($destination, '+'),
                $this->otpService->normalizeDestination('phone', $destination),
            ])));

            return User::query()
                ->whereIn('phone', $candidates)
                ->first();
        }

        return User::where('email', $destination)->first();
    }
}
