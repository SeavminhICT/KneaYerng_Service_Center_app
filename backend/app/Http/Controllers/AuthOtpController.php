<?php

namespace App\Http\Controllers;

use App\Mail\OtpMail;
use App\Models\EmailOtp;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Validation\ValidationException;

class AuthOtpController extends Controller
{
    public function sendOtp(Request $request)
    {
        $request->validate([
            'email' => ['required', 'email', 'max:255'],
        ]);

        $email = strtolower((string) $request->email);

        $row = EmailOtp::firstOrNew(['email' => $email]);
        if ($row->exists && $row->last_sent_at && $row->last_sent_at->gt(now()->subSeconds(45))) {
            return response()->json([
                'message' => 'Please wait before requesting another OTP.',
            ], 429);
        }

        $otp = (string) random_int(100000, 999999);
        $row->otp_hash = Hash::make($otp);
        $row->expires_at = now()->addMinutes(5);
        $row->verified_at = null;
        $row->attempts = 0;
        $row->last_sent_at = now();
        $row->save();

        Mail::to($email)->send(new OtpMail($otp, 5));

        return response()->json([
            'message' => 'OTP sent to email.',
            'expires_in_seconds' => 300,
        ]);
    }

    public function verifyOtp(Request $request)
    {
        $request->validate([
            'email' => ['required', 'email', 'max:255'],
            'otp' => ['required', 'digits:6'],
        ]);

        $email = strtolower((string) $request->email);
        $otp = (string) $request->otp;

        $row = EmailOtp::where('email', $email)->first();
        if (! $row) {
            throw ValidationException::withMessages(['otp' => 'OTP not found.']);
        }

        if ($row->verified_at) {
            return response()->json(['message' => 'Already verified.']);
        }

        if (now()->gt($row->expires_at)) {
            throw ValidationException::withMessages(['otp' => 'OTP expired.']);
        }

        if ($row->attempts >= 5) {
            return response()->json([
                'message' => 'Too many attempts. Request a new OTP.',
            ], 429);
        }

        $row->attempts += 1;
        $row->save();

        if (! Hash::check($otp, $row->otp_hash)) {
            throw ValidationException::withMessages(['otp' => 'Invalid OTP.']);
        }

        $row->verified_at = now();
        $row->save();

        return response()->json(['message' => 'OTP verified.']);
    }

    public function register(Request $request)
    {
        $request->validate([
            'name' => ['nullable', 'string', 'max:120'],
            'first_name' => ['nullable', 'string', 'max:255'],
            'last_name' => ['nullable', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255'],
            'password' => ['required', 'string', 'min:8'],
        ]);

        $email = strtolower((string) $request->email);
        $fullName = trim((string) ($request->name ?? ''));
        if ($fullName === '') {
            $fullName = trim(((string) $request->first_name).' '.((string) $request->last_name));
        }
        if ($fullName === '') {
            throw ValidationException::withMessages(['name' => 'Name is required.']);
        }

        $otpRow = EmailOtp::where('email', $email)->first();
        if (! $otpRow || ! $otpRow->verified_at) {
            return response()->json(['message' => 'Email not verified by OTP.'], 403);
        }

        if (User::where('email', $email)->exists()) {
            return response()->json(['message' => 'Email already registered.'], 409);
        }

        $user = User::create([
            'name' => $fullName,
            'email' => $email,
            'password' => Hash::make((string) $request->password),
            'otp_verified_at' => now(),
            'email_verified_at' => now(),
        ]);

        $otpRow->delete();

        return response()->json([
            'message' => 'Registered successfully.',
            'user' => $user,
        ], 201);
    }
}
