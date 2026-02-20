<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Services\OtpService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function __construct(private OtpService $otpService)
    {
    }

    public function register(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'first_name' => ['required', 'string', 'max:255'],
            'last_name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'lowercase', 'email', 'max:255', 'unique:users,email'],
            'phone' => ['nullable', 'string', 'max:20', 'unique:users,phone'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
            'avatar' => ['nullable', 'image', 'max:2048'],
        ]);

        $avatarPath = null;
        if ($request->hasFile('avatar')) {
            $storedPath = $request->file('avatar')->store('avatars', 'public');
            $avatarPath = 'storage/'.$storedPath;
        }

        $user = User::create([
            'first_name' => $validated['first_name'],
            'last_name' => $validated['last_name'],
            'email' => $validated['email'],
            'phone' => $validated['phone'] ?? null,
            'password' => Hash::make($validated['password']),
            'avatar' => $avatarPath,
            'otp_verified_at' => null,
        ]);

        $otpResult = $this->otpService->requestOtp(
            destinationType: 'email',
            destination: $user->email,
            purpose: 'signup',
            userId: $user->id,
            requestIp: $request->ip(),
            deviceId: $request->header('X-Device-Id')
        );

        return response()->json([
            'message' => 'User registered. OTP sent for verification.',
            'user' => $user,
            'otp_sent' => $otpResult['ok'] ?? false,
            'expires_in_sec' => $otpResult['expires_in_sec'] ?? (int) config('otp.ttl_seconds', 300),
            'resend_in_sec' => $otpResult['resend_in_sec'] ?? (int) config('otp.resend_cooldown_seconds', 60),
        ], 201);
    }

    public function resendOtp(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email' => ['nullable', 'string', 'lowercase', 'email', 'max:255'],
            'phone' => ['nullable', 'string', 'max:20'],
        ]);

        if (empty($validated['email']) && empty($validated['phone'])) {
            throw ValidationException::withMessages([
                'email' => ['Email or phone is required.'],
            ]);
        }

        $user = $this->findUserForOtp($validated['email'] ?? null, $validated['phone'] ?? null);

        if (! $user) {
            return response()->json([
                'message' => 'User not found.',
            ], 404);
        }

        $destinationType = ! empty($validated['phone']) ? 'phone' : 'email';
        $destination = $destinationType === 'phone' ? (string) $user->phone : (string) $user->email;
        $otp = $this->otpService->requestOtp(
            destinationType: $destinationType,
            destination: $destination,
            purpose: 'signup',
            userId: $user->id,
            requestIp: $request->ip(),
            deviceId: $request->header('X-Device-Id')
        );

        return response()->json([
            'message' => $otp['message'] ?? 'OTP processed.',
            'otp_sent' => $otp['ok'] ?? false,
            'expires_in_sec' => $otp['expires_in_sec'] ?? (int) config('otp.ttl_seconds', 300),
            'resend_in_sec' => $otp['resend_in_sec'] ?? (int) config('otp.resend_cooldown_seconds', 60),
        ], $otp['status'] ?? 200);
    }

    public function verifyOtp(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email' => ['nullable', 'string', 'lowercase', 'email', 'max:255'],
            'phone' => ['nullable', 'string', 'max:20'],
            'code' => ['required', 'string'],
        ]);

        if (empty($validated['email']) && empty($validated['phone'])) {
            throw ValidationException::withMessages([
                'email' => ['Email or phone is required.'],
            ]);
        }

        $user = $this->findUserForOtp($validated['email'] ?? null, $validated['phone'] ?? null);

        if (! $user) {
            return response()->json([
                'message' => 'User not found.',
            ], 404);
        }

        $destinationType = ! empty($validated['phone']) ? 'phone' : 'email';
        $destination = $destinationType === 'phone'
            ? $this->otpService->normalizeDestination('phone', (string) ($validated['phone'] ?? $user->phone))
            : $this->otpService->normalizeDestination('email', (string) ($validated['email'] ?? $user->email));
        $verify = $this->otpService->verifyOtp(
            destinationType: $destinationType,
            destination: $destination,
            purpose: 'signup',
            otp: (string) $validated['code']
        );
        if (! ($verify['ok'] ?? false)) {
            return response()->json([
                'message' => $verify['message'] ?? 'Invalid OTP code.',
            ], $verify['status'] ?? 422);
        }

        $user->otp_verified_at = now();
        $user->email_verified_at = $user->email_verified_at ?? now();
        $user->save();

        $token = $user->createToken('api')->plainTextToken;

        return response()->json([
            'message' => 'OTP verified successfully.',
            'token' => $token,
            'user' => $user,
        ]);
    }

    public function login(Request $request): JsonResponse
    {
        $credentials = $request->validate([
            'email' => ['required', 'string', 'email'],
            'password' => ['required', 'string'],
        ]);

        $user = User::where('email', $credentials['email'])->first();

        if (! $user || ! Hash::check($credentials['password'], $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        $token = $user->createToken('api')->plainTextToken;

        return response()->json([
            'message' => 'Login successfully',
            'token' => $token,
            'user' => $user,
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()?->currentAccessToken()?->delete();

        return response()->json([
            'message' => 'Logged out Successfully',
        ]);
    }


    public function update(Request $request): JsonResponse
    {
        $user = $request->user();

        $validated = $request->validate([
            'first_name' => ['sometimes', 'required', 'string', 'max:255'],
            'last_name' => ['sometimes', 'required', 'string', 'max:255'],
            'email' => ['sometimes', 'required', 'string', 'lowercase', 'email', 'max:255', 'unique:users,email,'.$user->id],
            'phone' => ['sometimes', 'required', 'string', 'max:20', 'unique:users,phone,'.$user->id],
            'current_password' => ['required_with:password', 'string'],
            'password' => ['required_with:current_password', 'string', 'min:8', 'confirmed'],
            'avatar' => ['sometimes', 'nullable', 'image', 'max:2048'],
        ]);

        if (array_key_exists('first_name', $validated)) {
            $user->first_name = $validated['first_name'];
        }

        if (array_key_exists('last_name', $validated)) {
            $user->last_name = $validated['last_name'];
        }

        if (array_key_exists('email', $validated)) {
            $user->email = $validated['email'];
        }

        if (array_key_exists('phone', $validated)) {
            $user->phone = $validated['phone'];
        }

        if (array_key_exists('password', $validated)) {
            if (! Hash::check($validated['current_password'] ?? '', $user->password)) {
                throw ValidationException::withMessages([
                    'current_password' => ['The current password is incorrect.'],
                ]);
            }
            $user->password = Hash::make($validated['password']);
        }

        if ($request->hasFile('avatar')) {
            if ($user->avatar) {
                $oldAvatarPath = $user->getRawOriginal('avatar');
                if ($oldAvatarPath) {
                    $oldAvatarPath = str_replace('storage/', '', $oldAvatarPath);
                    Storage::disk('public')->delete($oldAvatarPath);
                }
            }

            $storedPath = $request->file('avatar')->store('avatars', 'public');
            $user->avatar = 'storage/'.$storedPath;
        }

        $user->save();

        return response()->json([
            'message' => 'User updated successfully',
            'user' => $user,
        ]);
    }
    private function findUserForOtp(?string $email, ?string $phone): ?User
    {
        if ($email && $phone) {
            return User::where('email', $email)->orWhere('phone', $phone)->first();
        }

        if ($email) {
            return User::where('email', $email)->first();
        }

        if ($phone) {
            return User::where('phone', $phone)->first();
        }

        return null;
    }
}
