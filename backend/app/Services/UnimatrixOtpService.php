<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\Str;

class UnimatrixOtpService
{
    public function sendOtp(string $phone, string $purpose, ?string $requestIp = null): array
    {
        $normalizedPhone = $this->normalizePhone($phone);
        if ($normalizedPhone === null) {
            return [
                'ok' => false,
                'status' => 422,
                'message' => 'Enter a valid international phone number.',
            ];
        }

        $purpose = strtolower(trim($purpose));
        $ttl = min(1800, max(60, (int) config('otp.ttl_seconds', 300)));
        $cooldown = max(15, (int) config('otp.resend_cooldown_seconds', 60));
        $ipLimit = (int) config('otp.rate_limit_per_ip_10m', 10);
        $destLimit = (int) config('otp.rate_limit_per_destination_per_hour', 5);

        if ($requestIp && RateLimiter::tooManyAttempts('otp:ip:'.$requestIp, $ipLimit)) {
            $retry = RateLimiter::availableIn('otp:ip:'.$requestIp);

            return [
                'ok' => false,
                'status' => 429,
                'message' => 'Too many OTP requests. Please retry later.',
                'retry_in' => $retry,
            ];
        }

        $destKey = 'otp:dest:phone:'.$normalizedPhone;
        if (RateLimiter::tooManyAttempts($destKey, $destLimit)) {
            $retry = RateLimiter::availableIn($destKey);

            return [
                'ok' => false,
                'status' => 429,
                'message' => 'Too many OTP requests for this phone number.',
                'retry_in' => $retry,
            ];
        }

        $cooldownKey = 'otp:cooldown:phone:'.$normalizedPhone.':'.$purpose;
        if (RateLimiter::tooManyAttempts($cooldownKey, 1)) {
            return [
                'ok' => false,
                'status' => 429,
                'message' => 'Please wait before requesting another OTP.',
                'resend_in' => RateLimiter::availableIn($cooldownKey),
            ];
        }

        $response = $this->post('otp.send', [
            'to' => $normalizedPhone,
            'channel' => (string) config('services.unimatrix.channel', 'sms'),
            'digits' => max(4, min(8, (int) config('otp.code_length', 6))),
            'ttl' => $ttl,
            'intent' => substr($purpose, 0, 36),
        ]);

        if (! ($response['ok'] ?? false)) {
            return [
                'ok' => false,
                'status' => $response['status'] ?? 502,
                'message' => $response['message'] ?? 'OTP could not be sent. Please try again.',
                'expires_in_sec' => $ttl,
                'resend_in_sec' => $cooldown,
            ];
        }

        if ($requestIp) {
            RateLimiter::hit('otp:ip:'.$requestIp, 600);
        }
        RateLimiter::hit($destKey, 3600);
        RateLimiter::hit($cooldownKey, $cooldown);

        return [
            'ok' => true,
            'status' => 200,
            'message' => 'If this destination exists, an OTP was sent.',
            'expires_in_sec' => $ttl,
            'resend_in_sec' => $cooldown,
        ];
    }

    public function verifyOtp(string $phone, string $otp): array
    {
        $normalizedPhone = $this->normalizePhone($phone);
        if ($normalizedPhone === null) {
            return [
                'ok' => false,
                'status' => 422,
                'message' => 'Enter a valid international phone number.',
            ];
        }

        $response = $this->post('otp.verify', [
            'to' => $normalizedPhone,
            'code' => trim($otp),
            'ttl' => min(1800, max(60, (int) config('otp.ttl_seconds', 300))),
        ]);

        if (($response['ok'] ?? false) && ($response['valid'] ?? false)) {
            return [
                'ok' => true,
                'status' => 200,
                'message' => 'OTP verified successfully.',
            ];
        }

        return [
            'ok' => false,
            'status' => $response['status'] ?? 422,
            'message' => $response['message'] ?? 'Invalid OTP code.',
        ];
    }

    public function normalizePhone(string $phone): ?string
    {
        $trimmed = trim($phone);
        if ($trimmed === '') {
            return null;
        }

        $digits = preg_replace('/\D+/', '', $trimmed) ?? '';
        if ($digits === '') {
            return null;
        }

        if (str_starts_with($digits, '00')) {
            $digits = substr($digits, 2);
        } elseif (! str_starts_with($trimmed, '+') && str_starts_with($digits, '0')) {
            $country = preg_replace('/\D+/', '', (string) config('otp.default_phone_country_code', '+855')) ?? '';
            $local = ltrim($digits, '0');
            $digits = $country.($local !== '' ? $local : '');
        }

        if (strlen($digits) < 8 || strlen($digits) > 15) {
            return null;
        }

        return '+'.$digits;
    }

    private function post(string $action, array $payload): array
    {
        $baseUrl = rtrim((string) config('services.unimatrix.base_url', ''), '/');
        $accessKeyId = trim((string) config('services.unimatrix.access_key_id', ''));

        if ($baseUrl === '' || $accessKeyId === '') {
            return [
                'ok' => false,
                'status' => 500,
                'message' => 'Unimatrix SMS is not configured.',
            ];
        }

        $query = [
            'action' => $action,
            'accessKeyId' => $accessKeyId,
        ];

        $accessKeySecret = trim((string) config('services.unimatrix.access_key_secret', ''));
        if ($accessKeySecret !== '') {
            $query['algorithm'] = 'hmac-sha256';
            $query['timestamp'] = (string) round(microtime(true) * 1000);
            $query['nonce'] = Str::random(16);
            $query['signature'] = $this->sign($query, $accessKeySecret);
        }

        try {
            $options = [
                'verify' => (bool) config('services.unimatrix.verify', true),
            ];
            $caBundle = trim((string) config('services.unimatrix.ca_bundle', ''));
            if ($caBundle !== '') {
                $options['verify'] = $caBundle;
            }

            $response = Http::acceptJson()
                ->asJson()
                ->timeout((int) config('services.unimatrix.timeout', 15))
                ->withOptions($options)
                ->post($baseUrl.'/?'.http_build_query($query, '', '&', PHP_QUERY_RFC3986), $payload);
        } catch (\Throwable $exception) {
            Log::warning('Unimatrix OTP request failed.', [
                'action' => $action,
                'message' => $exception->getMessage(),
            ]);

            return [
                'ok' => false,
                'status' => 502,
                'message' => 'Unable to reach the SMS gateway right now.',
            ];
        }

        $body = $response->json();
        $message = is_array($body)
            ? (string) ($body['message'] ?? $body['error'] ?? 'OTP request failed.')
            : 'OTP request failed.';
        $code = is_array($body) ? ($body['code'] ?? null) : null;

        if ($response->successful() && ($code === 0 || $code === '0' || $code === null)) {
            $data = is_array($body['data'] ?? null) ? $body['data'] : [];

            return [
                'ok' => true,
                'status' => 200,
                'message' => $message,
                'valid' => (bool) ($data['valid'] ?? true),
            ];
        }

        Log::warning('Unimatrix OTP API returned an error.', [
            'action' => $action,
            'status' => $response->status(),
            'body' => $body,
        ]);

        return [
            'ok' => false,
            'status' => $response->status() >= 400 ? $response->status() : 422,
            'message' => $message,
        ];
    }

    private function sign(array $query, string $accessKeySecret): string
    {
        ksort($query);

        $pairs = [];
        foreach ($query as $key => $value) {
            $pairs[] = $key.'='.(string) $value;
        }

        return base64_encode(hash_hmac('sha256', implode('&', $pairs), $accessKeySecret, true));
    }
}
