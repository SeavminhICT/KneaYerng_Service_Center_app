<?php

namespace App\Services;

use App\Models\OtpVerification;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\RateLimiter;

class OtpService
{
    public function __construct(private OtpDeliveryService $delivery)
    {
    }

    public function requestOtp(
        string $destinationType,
        string $destination,
        string $purpose,
        ?int $userId,
        ?string $requestIp,
        ?string $deviceId = null,
        bool $silentIfUserMissing = false
    ): array {
        $destinationType = $this->normalizeType($destinationType);
        $destination = $this->normalizeDestination($destinationType, $destination);
        $purpose = trim(strtolower($purpose));

        $ipLimit = (int) config('otp.rate_limit_per_ip_10m', 10);
        $destLimit = (int) config('otp.rate_limit_per_destination_per_hour', 5);

        if ($requestIp && RateLimiter::tooManyAttempts('otp:ip:'.$requestIp, $ipLimit)) {
            $retry = RateLimiter::availableIn('otp:ip:'.$requestIp);
            return ['ok' => false, 'status' => 429, 'message' => 'Too many OTP requests. Please retry later.', 'retry_in' => $retry];
        }

        if (RateLimiter::tooManyAttempts('otp:dest:'.$destinationType.':'.$destination, $destLimit)) {
            $retry = RateLimiter::availableIn('otp:dest:'.$destinationType.':'.$destination);
            return ['ok' => false, 'status' => 429, 'message' => 'Too many OTP requests for this destination.', 'retry_in' => $retry];
        }

        if ($requestIp) {
            RateLimiter::hit('otp:ip:'.$requestIp, 600);
        }
        RateLimiter::hit('otp:dest:'.$destinationType.':'.$destination, 3600);

        $latestActive = OtpVerification::query()
            ->where('destination_type', $destinationType)
            ->where('destination', $destination)
            ->where('purpose', $purpose)
            ->whereIn('status', ['active', 'locked'])
            ->orderByDesc('id')
            ->first();

        if ($latestActive?->cooldown_until && now()->lt($latestActive->cooldown_until)) {
            return [
                'ok' => false,
                'status' => 429,
                'message' => 'Please wait before requesting another OTP.',
                'resend_in' => now()->diffInSeconds($latestActive->cooldown_until, false) * -1,
            ];
        }

        $codeLength = max(4, (int) config('otp.code_length', 6));
        $ttl = max(60, (int) config('otp.ttl_seconds', 300));
        $cooldown = max(15, (int) config('otp.resend_cooldown_seconds', 60));
        $maxAttempts = max(3, (int) config('otp.max_attempts', 5));

        $otpCode = $this->generateOtp($codeLength);
        $otpHash = $this->hashOtp($otpCode);

        DB::transaction(function () use ($destinationType, $destination, $purpose, $otpHash, $userId, $requestIp, $deviceId, $ttl, $cooldown, $maxAttempts) {
            OtpVerification::query()
                ->where('destination_type', $destinationType)
                ->where('destination', $destination)
                ->where('purpose', $purpose)
                ->where('status', 'active')
                ->update(['status' => 'expired']);

            OtpVerification::create([
                'destination_type' => $destinationType,
                'destination' => $destination,
                'purpose' => $purpose,
                'user_id' => $userId,
                'otp_hash' => $otpHash,
                'status' => 'active',
                'attempts' => 0,
                'max_attempts' => $maxAttempts,
                'expires_at' => now()->addSeconds($ttl),
                'cooldown_until' => now()->addSeconds($cooldown),
                'request_ip' => $requestIp,
                'device_id' => $deviceId,
            ]);
        });

        $message = sprintf('Your OTP code is %s. It expires in %d minutes.', $otpCode, (int) ceil($ttl / 60));
        $sent = $this->delivery->send($destinationType, $destination, $message);

        return [
            'ok' => $sent,
            'status' => $sent ? 200 : 500,
            'message' => $sent
                ? 'If this destination exists, an OTP was sent.'
                : 'OTP could not be sent. Please try again.',
            'expires_in_sec' => $ttl,
            'resend_in_sec' => $cooldown,
        ];
    }

    public function verifyOtp(string $destinationType, string $destination, string $purpose, string $otp): array
    {
        $destinationType = $this->normalizeType($destinationType);
        $destination = $this->normalizeDestination($destinationType, $destination);
        $purpose = trim(strtolower($purpose));

        $record = OtpVerification::query()
            ->where('destination_type', $destinationType)
            ->where('destination', $destination)
            ->where('purpose', $purpose)
            ->orderByDesc('id')
            ->first();

        if (! $record) {
            return ['ok' => false, 'status' => 422, 'message' => 'Invalid OTP request.'];
        }

        if ($record->status === 'used') {
            return ['ok' => false, 'status' => 422, 'message' => 'OTP already used.'];
        }

        if ($record->locked_until && now()->lt($record->locked_until)) {
            return ['ok' => false, 'status' => 423, 'message' => 'OTP is locked. Please try later.'];
        }

        if (now()->gt($record->expires_at)) {
            $record->status = 'expired';
            $record->save();
            return ['ok' => false, 'status' => 422, 'message' => 'OTP has expired.'];
        }

        if (! hash_equals($record->otp_hash, $this->hashOtp($otp))) {
            $record->attempts++;
            if ($record->attempts >= $record->max_attempts) {
                $record->status = 'locked';
                $record->locked_until = now()->addSeconds(max(60, (int) config('otp.lock_seconds', 600)));
            }
            $record->save();
            return ['ok' => false, 'status' => 422, 'message' => 'Invalid OTP code.'];
        }

        DB::transaction(function () use ($record, $destinationType, $destination, $purpose) {
            OtpVerification::query()
                ->where('destination_type', $destinationType)
                ->where('destination', $destination)
                ->where('purpose', $purpose)
                ->where('status', 'active')
                ->update(['status' => 'expired']);

            $record->status = 'used';
            $record->consumed_at = now();
            $record->save();
        });

        return ['ok' => true, 'status' => 200, 'message' => 'OTP verified successfully.', 'record' => $record];
    }

    public function normalizeType(string $type): string
    {
        $normalized = strtolower(trim($type));
        return $normalized === 'phone' ? 'phone' : 'email';
    }

    public function normalizeDestination(string $type, string $destination): string
    {
        $raw = trim($destination);
        if ($type === 'email') {
            return strtolower($raw);
        }

        $digits = preg_replace('/\D+/', '', $raw) ?? '';
        if (str_starts_with($digits, '00')) {
            $digits = substr($digits, 2);
        }

        return $digits;
    }

    private function generateOtp(int $length): string
    {
        $max = (10 ** $length) - 1;
        $min = 10 ** ($length - 1);
        return (string) random_int($min, $max);
    }

    private function hashOtp(string $otp): string
    {
        return hash_hmac('sha256', $otp, (string) config('app.key'));
    }
}
