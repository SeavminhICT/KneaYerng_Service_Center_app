<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Services\GoogleIdTokenVerifier;
use App\Services\OtpService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function __construct(
        private OtpService $otpService,
        private GoogleIdTokenVerifier $googleIdTokenVerifier
    ) {}

    public function register(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'first_name' => ['required', 'string', 'max:255'],
            'last_name' => ['required', 'string', 'max:255'],
            'email' => ['nullable', 'string', 'lowercase', 'email', 'max:255', 'unique:users,email', 'required_without:phone'],
            'phone' => ['nullable', 'string', 'max:20', 'required_without:email'],
            'password' => [
                'required',
                'string',
                'min:8',
                'regex:/[A-Z]/',
                'regex:/[0-9]/',
                'confirmed',
            ],
            'avatar' => ['nullable', 'image', 'max:2048'],
            'otp_destination_type' => ['nullable', 'in:email,phone'],
        ]);

        $normalizedPhone = null;
        if (! empty($validated['phone'])) {
            $normalizedPhone = $this->otpService->normalizeDestination('phone', $validated['phone']);
            if ($normalizedPhone !== '' && User::where('phone', $normalizedPhone)->exists()) {
                throw ValidationException::withMessages([
                    'phone' => ['The phone number has already been taken.'],
                ]);
            }
        }

        $avatarPath = null;
        if ($request->hasFile('avatar')) {
            $storedPath = $request->file('avatar')->store('avatars', 'public');
            if ($storedPath) {
                $avatarPath = 'storage/'.$storedPath;
            }
        }

        $user = User::create([
            'first_name' => $validated['first_name'],
            'last_name' => $validated['last_name'],
            'email' => $validated['email'] ?? null,
            'phone' => $normalizedPhone,
            'password' => Hash::make($validated['password']),
            'avatar' => $avatarPath,
            'role' => 'user',
            'status' => 'active',
            'is_admin' => false,
            'otp_verified_at' => null,
        ]);

        return response()->json([
            'message' => 'User registered. Verify your account via OTP.',
            'user' => $user,
            'otp_sent' => false,
            'otp_destination_type' => $normalizedPhone ? 'phone' : 'email',
            'otp_destination' => $normalizedPhone ? '+'.$normalizedPhone : (string) ($user->email ?? ''),
        ], 201);
    }

    public function resendOtp(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email' => ['required', 'string', 'lowercase', 'email', 'max:255'],
        ]);
        $user = $this->findUserForOtp($validated['email'] ?? null, null);

        if (! $user) {
            return response()->json([
                'message' => 'User not found.',
            ], 404);
        }

        $destinationType = 'email';
        $destination = (string) $user->email;
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
            'email' => ['required', 'string', 'lowercase', 'email', 'max:255'],
            'code' => ['required', 'string'],
        ]);
        $user = $this->findUserForOtp($validated['email'] ?? null, null);

        if (! $user) {
            return response()->json([
                'message' => 'User not found.',
            ], 404);
        }

        $destinationType = 'email';
        $destination = $this->otpService->normalizeDestination(
            'email',
            (string) ($validated['email'] ?? $user->email)
        );
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
            'email' => ['required', 'string', 'max:255'],
            'password' => ['required', 'string'],
        ]);

        $identifier = trim((string) $credentials['email']);
        if (str_contains($identifier, '@')) {
            $user = User::where('email', strtolower($identifier))->first();
        } else {
            $normalizedPhone = $this->otpService->normalizeDestination('phone', $identifier);
            $phoneCandidates = array_values(array_unique(array_filter([
                $identifier,
                ltrim($identifier, '+'),
                $normalizedPhone,
            ])));

            $user = User::query()
                ->whereIn('phone', $phoneCandidates)
                ->first();
        }

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
            'current_password' => ['required_with:password', 'string'],
            'password' => [
                'required_with:current_password',
                'string',
                'min:8',
                'regex:/[A-Z]/',
                'regex:/[0-9]/',
                'confirmed',
            ],
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
            if ($storedPath) {
                $user->avatar = 'storage/'.$storedPath;
            }
        }

        $user->save();

        return response()->json([
            'message' => 'User updated successfully',
            'user' => $user,
        ]);
    }

    public function requestPhoneChangeOtp(Request $request): JsonResponse
    {
        $user = $request->user();

        $validated = $request->validate([
            'phone' => ['required', 'string', 'max:20'],
        ]);

        $normalizedPhone = $this->otpService->normalizeDestination('phone', $validated['phone']);
        if ($normalizedPhone === '') {
            throw ValidationException::withMessages([
                'phone' => ['Please enter a valid phone number.'],
            ]);
        }

        if (User::where('phone', $normalizedPhone)->where('id', '!=', $user->id)->exists()) {
            throw ValidationException::withMessages([
                'phone' => ['The phone number has already been taken.'],
            ]);
        }

        $result = $this->otpService->requestOtp(
            'phone',
            $normalizedPhone,
            'change_phone',
            $user->id,
            $request->ip(),
            $request->header('X-Device-Id')
        );

        return response()->json([
            'message' => $result['message'] ?? 'OTP request processed.',
            'expires_in_sec' => $result['expires_in_sec'] ?? (int) config('otp.ttl_seconds', 300),
            'resend_in_sec' => $result['resend_in_sec'] ?? (int) config('otp.resend_cooldown_seconds', 60),
        ], $result['status'] ?? 200);
    }

    public function confirmPhoneChangeOtp(Request $request): JsonResponse
    {
        $user = $request->user();

        $validated = $request->validate([
            'phone' => ['required', 'string', 'max:20'],
            'otp' => ['required', 'string', 'max:12'],
        ]);

        $normalizedPhone = $this->otpService->normalizeDestination('phone', $validated['phone']);
        if ($normalizedPhone === '') {
            throw ValidationException::withMessages([
                'phone' => ['Please enter a valid phone number.'],
            ]);
        }

        $verify = $this->otpService->verifyOtp('phone', $normalizedPhone, 'change_phone', $validated['otp']);
        if (! ($verify['ok'] ?? false)) {
            return response()->json(['message' => $verify['message'] ?? 'OTP verification failed.'], $verify['status'] ?? 422);
        }

        if (User::where('phone', $normalizedPhone)->where('id', '!=', $user->id)->exists()) {
            throw ValidationException::withMessages([
                'phone' => ['The phone number has already been taken.'],
            ]);
        }

        $user->phone = $normalizedPhone;
        $user->save();

        return response()->json([
            'message' => 'Phone number updated successfully',
            'user' => $user,
        ]);
    }

    public function googleLogin(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'id_token' => ['nullable', 'string'],
            'email' => ['required_without:id_token', 'nullable', 'string', 'email', 'max:255'],
            'first_name' => ['nullable', 'string', 'max:255'],
            'last_name' => ['nullable', 'string', 'max:255'],
            'avatar' => ['nullable', 'string'],
        ]);

        $claims = null;
        if (! empty($validated['id_token'])) {
            try {
                $claims = $this->googleIdTokenVerifier->verify($validated['id_token']);
            } catch (\Throwable $e) {
                Log::error('Google ID token verification error: '.$e->getMessage(), [
                    'exception' => $e,
                ]);
                return response()->json([
                    'message' => 'Google login could not be verified. Please try again.',
                ], 401);
            }
        }

        $email = strtolower(trim((string) ($claims['email'] ?? $validated['email'] ?? '')));
        if ($email === '') {
            return response()->json([
                'message' => 'Google account email is missing.',
            ], 422);
        }

        $emailVerified = $claims === null
            ? true
            : filter_var($claims['email_verified'] ?? false, FILTER_VALIDATE_BOOLEAN);
        if (! $emailVerified) {
            return response()->json([
                'message' => 'Google account email is not verified.',
            ], 403);
        }

        $fullName = trim((string) ($claims['name'] ?? ''));
        $firstName = trim((string) ($claims['given_name'] ?? ''));
        $lastName = trim((string) ($claims['family_name'] ?? ''));

        if ($claims === null) {
            $firstName = trim((string) ($validated['first_name'] ?? ''));
            $lastName = trim((string) ($validated['last_name'] ?? ''));
        }

        if ($firstName === '' && $fullName !== '') {
            $nameParts = preg_split('/\s+/', $fullName, 2);
            $firstName = $nameParts[0] ?? '';
            $lastName = $lastName !== '' ? $lastName : ($nameParts[1] ?? '');
        }

        if ($firstName === '') {
            $emailName = trim((string) explode('@', $email, 2)[0]);
            $firstName = $emailName !== '' ? $emailName : 'Google';
        }

        if ($lastName === '') {
            $lastName = 'User';
        }

        $avatar = $claims['picture'] ?? ($validated['avatar'] ?? null);
        if (! is_string($avatar) || trim($avatar) === '') {
            $avatar = null;
        }

        $user = User::where('email', $email)->first();

        if (! $user) {
            $user = User::create([
                'first_name' => $firstName,
                'last_name' => $lastName,
                'email' => $email,
                'password' => Hash::make(bin2hex(random_bytes(16))),
                'avatar' => $avatar,
                'otp_verified_at' => now(),
                'email_verified_at' => now(),
            ]);
        } else {
            if (empty($user->avatar) && $avatar !== null) {
                $user->avatar = $avatar;
            }

            if (! $user->email_verified_at) {
                $user->email_verified_at = now();
            }

            if (! $user->otp_verified_at) {
                $user->otp_verified_at = now();
            }

            if ($user->isDirty()) {
                $user->save();
            }
        }

        $token = $user->createToken('api')->plainTextToken;

        return response()->json([
            'message' => 'Login successfully via Google',
            'token' => $token,
            'user' => $user,
        ]);
    }

    public function facebookLogin(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'facebook_id' => ['required', 'string'],
            'email' => ['nullable', 'string', 'email', 'max:255'],
            'first_name' => ['required', 'string', 'max:255'],
            'last_name' => ['required', 'string', 'max:255'],
            'avatar' => ['nullable', 'string'],
        ]);

        $email = $validated['email'] ? strtolower($validated['email']) : 'fb_'.$validated['facebook_id'].'@facebook.com';

        $user = User::where('email', $email)->first();

        if (! $user) {
            $user = User::create([
                'first_name' => $validated['first_name'],
                'last_name' => $validated['last_name'],
                'email' => $email,
                'password' => Hash::make(bin2hex(random_bytes(16))),
                'avatar' => $validated['avatar'] ?? null,
                'otp_verified_at' => now(),
                'email_verified_at' => now(),
            ]);
        } else {
            if (empty($user->avatar) && ! empty($validated['avatar'])) {
                $user->avatar = $validated['avatar'];
                $user->save();
            }
        }

        $token = $user->createToken('api')->plainTextToken;

        return response()->json([
            'message' => 'Login successfully via Facebook',
            'token' => $token,
            'user' => $user,
        ]);
    }

    private function findUserForOtp(?string $email, ?string $phone): ?User
    {
        $emailValue = $email ? strtolower(trim($email)) : null;
        $phoneRaw = $phone ? trim($phone) : null;
        $phoneNormalized = $phoneRaw
            ? $this->otpService->normalizeDestination('phone', $phoneRaw)
            : null;

        if ($emailValue && $phoneRaw) {
            $query = User::where('email', $emailValue)->orWhere('phone', $phoneRaw);
            if ($phoneNormalized && $phoneNormalized !== $phoneRaw) {
                $query->orWhere('phone', $phoneNormalized);
            }

            return $query->first();
        }

        if ($emailValue) {
            return User::where('email', $emailValue)->first();
        }

        if ($phoneRaw) {
            $query = User::where('phone', $phoneRaw);
            if ($phoneNormalized && $phoneNormalized !== $phoneRaw) {
                $query->orWhere('phone', $phoneNormalized);
            }

            return $query->first();
        }

        return null;
    }
}
