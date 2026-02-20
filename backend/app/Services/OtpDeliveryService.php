<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;

class OtpDeliveryService
{
    public function send(string $destinationType, string $destination, string $message): bool
    {
        if ($destinationType === 'phone') {
            return $this->sendSms($destination, $message);
        }

        return $this->sendEmail($destination, $message);
    }

    public function sendSms(string $phone, string $message): bool
    {
        $baseUrl = (string) config('services.easysendsms.base_url', '');
        $username = (string) config('services.easysendsms.username', '');
        $password = (string) config('services.easysendsms.password', '');
        $from = (string) config('services.easysendsms.from', 'OTP');

        if ($baseUrl === '' || $username === '' || $password === '') {
            Log::warning('EasySendSMS credentials are missing.');
            return false;
        }

        $response = Http::asForm()
            ->timeout(10)
            ->post($baseUrl, [
                'username' => $username,
                'password' => $password,
                'from' => $from,
                'to' => $this->normalizeSmsDestination($phone),
                'text' => $message,
                'type' => 0,
            ]);

        $body = trim((string) $response->body());
        if ($response->failed() || ! str_starts_with($body, 'OK:')) {
            Log::warning('EasySendSMS send failed.', [
                'status' => $response->status(),
                'body' => $body,
            ]);
            return false;
        }

        return true;
    }

    public function sendEmail(string $email, string $message): bool
    {
        try {
            Mail::raw($message, function ($m) use ($email) {
                $m->to($email)->subject((string) config('otp.email_subject', 'Your OTP Code'));
            });

            return true;
        } catch (\Throwable $exception) {
            Log::warning('OTP email send failed.', [
                'message' => $exception->getMessage(),
            ]);

            return false;
        }
    }

    private function normalizeSmsDestination(string $raw): string
    {
        $value = preg_replace('/\D+/', '', $raw) ?? '';
        if (str_starts_with($value, '00')) {
            $value = substr($value, 2);
        }
        return $value;
    }
}
