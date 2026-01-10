<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Services\InfobipService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    private int $otpTtlMinutes = 10;

    public function __construct(private InfobipService $infobip)
    {
    }

    public function register(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'first_name' => ['required', 'string', 'max:255'],
            'last_name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'lowercase', 'email', 'max:255', 'unique:users,email'],
            'phone' => ['required', 'string', 'max:20', 'unique:users,phone'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
            'avatar' => ['nullable', 'image', 'max:2048'],
        ]);

        $avatarPath = null;
        if ($request->hasFile('avatar')) {
            $storedPath = $request->file('avatar')->store('avatars', 'public');
            $avatarPath = 'storage/'.$storedPath;
        }

        $otp = $this->generateOtp();
        $otpExpiresAt = now()->addMinutes($this->otpTtlMinutes);

        $user = User::create([
            'first_name' => $validated['first_name'],
            'last_name' => $validated['last_name'],
            'email' => $validated['email'],
            'phone' => $validated['phone'],
            'password' => Hash::make($validated['password']),
            'avatar' => $avatarPath,
            'otp_code' => Hash::make($otp),
            'otp_expires_at' => $otpExpiresAt,
            'otp_verified_at' => null,
        ]);

        $token = $user->createToken('api')->plainTextToken;
        $otpSent = $this->attemptSendOtp($user, $otp);

        return response()->json([
            'message' => $otpSent
                ? 'User registered successfully'
                : 'User registered successfully, but OTP could not be sent.',
            'token' => $token,
            'user' => $user,
            'otp_sent' => $otpSent,
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

        $otp = $this->generateOtp();
        $user->otp_code = Hash::make($otp);
        $user->otp_expires_at = now()->addMinutes($this->otpTtlMinutes);
        $user->otp_verified_at = null;
        $user->save();

        $otpSent = $this->attemptSendOtp($user, $otp);

        return response()->json([
            'message' => $otpSent ? 'OTP sent successfully.' : 'OTP could not be sent.',
            'otp_sent' => $otpSent,
        ]);
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

        if (! $user->otp_code || ! $user->otp_expires_at) {
            return response()->json([
                'message' => 'No OTP is pending for this user.',
            ], 422);
        }

        if (now()->greaterThan($user->otp_expires_at)) {
            return response()->json([
                'message' => 'OTP has expired.',
            ], 422);
        }

        if (! Hash::check($validated['code'], $user->otp_code)) {
            return response()->json([
                'message' => 'Invalid OTP code.',
            ], 422);
        }

        $user->otp_verified_at = now();
        $user->otp_code = null;
        $user->otp_expires_at = null;
        $user->email_verified_at = $user->email_verified_at ?? now();
        $user->save();

        return response()->json([
            'message' => 'OTP verified successfully.',
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
            'password' => ['sometimes', 'required', 'string', 'min:8', 'confirmed'],
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
            $user->password = Hash::make($validated['password']);
        }

        if ($request->hasFile('avatar')) {
            if ($user->avatar) {
                $oldAvatarPath = str_replace('storage/', '', $user->avatar);
                Storage::disk('public')->delete($oldAvatarPath);
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

    private function attemptSendOtp(User $user, string $otp): bool
    {
        try {
            $message = 'Your verification code is '.$otp.'. It expires in '.$this->otpTtlMinutes.' minutes.';
            $smsSent = $this->infobip->sendSms($user->phone, $message);
            $emailSent = $this->infobip->sendEmail($user->email, 'Your verification code', $message);

            return $smsSent && $emailSent;
        } catch (\Throwable $exception) {
            report($exception);

            return false;
        }
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

    private function generateOtp(): string
    {
        return (string) random_int(100000, 999999);
    }
}
