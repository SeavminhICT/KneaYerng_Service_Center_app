<?php

namespace App\Services;

use Illuminate\Support\Facades\Log;
use Twilio\Rest\Client;

class TwilioOtpService
{
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
