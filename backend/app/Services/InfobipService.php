<?php

namespace App\Services;

use Illuminate\Http\Client\PendingRequest;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use RuntimeException;

class InfobipService
{
    public function sendSms(string $to, string $message): bool
    {
        $sender = config('infobip.sms.sender');

        if (! $sender) {
            throw new RuntimeException('Infobip SMS sender is not configured.');
        }

        $response = $this->client()->post('/sms/2/text/advanced', [
            'messages' => [
                [
                    'from' => $sender,
                    'destinations' => [
                        ['to' => $to],
                    ],
                    'text' => $message,
                ],
            ],
        ]);

        if ($response->failed()) {
            Log::warning('Infobip SMS send failed.', [
                'status' => $response->status(),
                'body' => $response->body(),
            ]);

            return false;
        }

        return true;
    }

    public function sendEmail(string $to, string $subject, string $message): bool
    {
        $sender = config('infobip.email.from');

        if (! $sender) {
            throw new RuntimeException('Infobip email sender is not configured.');
        }

        $fromName = config('infobip.email.from_name');
        $senderValue = $fromName ? $fromName.' <'.$sender.'>' : $sender;

        $response = $this->client()->post('/email/4/messages', [
            'messages' => [
                [
                    'destinations' => [
                        [
                            'to' => [
                                ['destination' => $to],
                            ],
                        ],
                    ],
                    'sender' => $senderValue,
                    'content' => [
                        'subject' => $subject,
                        'text' => $message,
                    ],
                ],
            ],
        ]);

        if ($response->failed()) {
            Log::warning('Infobip email send failed.', [
                'status' => $response->status(),
                'body' => $response->body(),
            ]);

            return false;
        }

        return true;
    }

    private function client(): PendingRequest
    {
        $baseUrl = config('infobip.base_url');
        $apiKey = config('infobip.api_key');

        if (! $baseUrl || ! $apiKey) {
            throw new RuntimeException('Infobip is not configured.');
        }

        if (! str_starts_with($baseUrl, 'http://') && ! str_starts_with($baseUrl, 'https://')) {
            $baseUrl = 'https://'.$baseUrl;
        }

        return Http::baseUrl(rtrim($baseUrl, '/'))
            ->withHeaders([
                'Authorization' => 'App '.$apiKey,
                'Accept' => 'application/json',
            ])
            ->timeout(10);
    }
}
