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
        $sender = trim((string) config('infobip.sms.sender'));

        if (! $sender) {
            throw new RuntimeException('Infobip SMS sender is not configured.');
        }

        $to = $this->formatSmsDestination($to);

        $response = $this->client()->post('/sms/3/messages', [
            'messages' => [
                [
                    'sender' => $sender,
                    'destinations' => [
                        ['to' => $to],
                    ],
                    'content' => [
                        'text' => $message,
                    ],
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

        $messageId = $response->json('messages.0.messageId');
        if (! $messageId) {
            return true;
        }

        return $this->confirmNotRejected($messageId);
    }

    private function formatSmsDestination(string $to): string
    {
        $raw = trim($to);
        $digits = preg_replace('/\D+/', '', $raw) ?? '';

        if (str_starts_with($digits, '00')) {
            $digits = substr($digits, 2);
        } elseif (! str_starts_with($raw, '+') && str_starts_with($digits, '0')) {
            $countryCode = preg_replace('/\D+/', '', (string) config('otp.default_phone_country_code', '+855')) ?? '';
            $digits = $countryCode.ltrim($digits, '0');
        }

        if ($digits === '' || strlen($digits) < 8 || strlen($digits) > 15) {
            throw new RuntimeException('Infobip SMS destination is not a valid international phone number.');
        }

        return $digits;
    }

    // Infobip's send endpoint only confirms the message was accepted into its
    // queue, not that it was actually deliverable (e.g. trial accounts
    // silently reject unwhitelisted destinations moments later). A short
    // follow-up check on the delivery report catches that case so callers
    // don't treat a rejected message as sent.
    private function confirmNotRejected(string $messageId): bool
    {
        if (! config('infobip.check_delivery_report', true)) {
            return true;
        }

        try {
            $delayMs = max(0, (int) config('infobip.delivery_report_delay_ms', 600));
            if ($delayMs > 0) {
                usleep($delayMs * 1000);
            }

            $report = $this->client(
                max(1, (int) config('infobip.delivery_report_timeout_seconds', 2))
            )->get('/sms/3/reports', ['messageId' => $messageId]);
            if ($report->failed()) {
                Log::warning('Infobip delivery report request failed.', [
                    'messageId' => $messageId,
                    'status' => $report->status(),
                    'body' => $report->body(),
                ]);

                return true;
            }

            $status = $report->json('results.0.status');
            $groupId = $status['groupId'] ?? null;

            if (in_array($groupId, [2, 4, 5], true)) {
                Log::warning('Infobip SMS rejected after being accepted.', [
                    'messageId' => $messageId,
                    'status' => $status,
                    'error' => $report->json('results.0.error'),
                ]);

                return false;
            }
        } catch (\Throwable $exception) {
            Log::warning('Infobip delivery report check failed.', [
                'messageId' => $messageId,
                'message' => $exception->getMessage(),
            ]);
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

    private function client(int $timeoutSeconds = 10): PendingRequest
    {
        $baseUrl = trim((string) config('infobip.base_url'));
        $apiKey = trim((string) config('infobip.api_key'));

        if (! $baseUrl || ! $apiKey) {
            throw new RuntimeException('Infobip is not configured.');
        }

        if (! str_starts_with($baseUrl, 'http://') && ! str_starts_with($baseUrl, 'https://')) {
            $baseUrl = 'https://'.$baseUrl;
        }

        $options = [
            'verify' => (bool) config('infobip.verify', true),
        ];
        $caBundle = trim((string) config('infobip.ca_bundle', ''));
        if ($caBundle !== '') {
            $options['verify'] = $caBundle;
        }

        return Http::baseUrl(rtrim($baseUrl, '/'))
            ->asJson()
            ->withHeaders([
                'Authorization' => 'App '.$apiKey,
                'Accept' => 'application/json',
            ])
            ->withOptions($options)
            ->timeout($timeoutSeconds);
    }
}
