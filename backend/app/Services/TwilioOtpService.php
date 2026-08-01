<?php

namespace App\Services;

use Illuminate\Support\Facades\Log;
use Twilio\Rest\Client;

class TwilioOtpService
{
    public function sendVerification(string $phone, ?string $channel = null): array
    {
        $accountSid = trim((string) config('services.twilio.account_sid', ''));
        $authToken = trim((string) config('services.twilio.auth_token', ''));
        $serviceSid = trim((string) config('services.twilio.verify_service_sid', ''));
        $channel = trim((string) ($channel ?: config('services.twilio.verify_channel', 'sms')));

        if ($accountSid === '' || $authToken === '' || $serviceSid === '') {
            Log::warning('Twilio Verify request skipped because credentials are not configured.');

            return [
                'ok' => false,
                'status' => 500,
                'message' => 'Twilio Verify is not configured.',
            ];
        }

        try {
            $verification = (new Client($accountSid, $authToken))
                ->verify
                ->v2
                ->services($serviceSid)
                ->verifications
                ->create($phone, $channel);

            return [
                'ok' => true,
                'status' => 200,
                'message' => 'OTP sent to your phone.',
                'twilio_status' => $verification->status,
                'verification_sid' => $verification->sid,
            ];
        } catch (\Throwable $exception) {
            Log::warning('Twilio Verify request failed.', [
                'message' => $exception->getMessage(),
            ]);

            return [
                'ok' => false,
                'status' => 502,
                'message' => 'Unable to send OTP right now.',
            ];
        }
    }

    public function checkVerification(string $phone, string $code): array
    {
        $accountSid = trim((string) config('services.twilio.account_sid', ''));
        $authToken = trim((string) config('services.twilio.auth_token', ''));
        $serviceSid = trim((string) config('services.twilio.verify_service_sid', ''));

        if ($accountSid === '' || $authToken === '' || $serviceSid === '') {
            Log::warning('Twilio Verify check skipped because credentials are not configured.');

            return [
                'ok' => false,
                'status' => 500,
                'message' => 'Twilio Verify is not configured.',
            ];
        }

        try {
            $check = (new Client($accountSid, $authToken))
                ->verify
                ->v2
                ->services($serviceSid)
                ->verificationChecks
                ->create([
                    'to' => $phone,
                    'code' => $code,
                ]);

            $approved = $check->status === 'approved';

            return [
                'ok' => $approved,
                'status' => $approved ? 200 : 422,
                'message' => $approved
                    ? 'OTP verified successfully.'
                    : 'Invalid OTP. Please try again.',
                'twilio_status' => $check->status,
                'approved' => $approved,
            ];
        } catch (\Throwable $exception) {
            Log::warning('Twilio Verify check failed.', [
                'message' => $exception->getMessage(),
            ]);

            return [
                'ok' => false,
                'status' => 422,
                'message' => 'Invalid or expired OTP. Please request a new code.',
            ];
        }
    }

    public function sendSms(string $phone, string $message): bool
    {
        $accountSid = trim((string) config('services.twilio.account_sid', ''));
        $authToken = trim((string) config('services.twilio.auth_token', ''));
        $from = trim((string) config('services.twilio.from', ''));

        if ($accountSid === '' || $authToken === '' || $from === '') {
            Log::warning('Twilio SMS skipped because credentials are not configured.');

            return false;
        }

        try {
            $client = new Client($accountSid, $authToken);
            $client->messages->create($phone, [
                'from' => $from,
                'body' => $message,
            ]);

            return true;
        } catch (\Throwable $exception) {
            Log::warning('Twilio SMS send failed.', [
                'message' => $exception->getMessage(),
            ]);

            return false;
        }
    }
}
