<?php

namespace App\Services;

use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;

class OtpDeliveryService
{
    public function send(string $destinationType, string $destination, string $message, array $context = []): bool
    {
        if ($destinationType !== 'email') {
            Log::warning('OTP delivery is configured for email only.', [
                'type' => $destinationType,
            ]);
            return false;
        }

        return $this->sendEmail($destination, $message, $context);
    }

    public function sendEmail(string $email, string $message, array $context = []): bool
    {
        $subject = (string) config('otp.email_subject', 'Your OTP Code');
        $payload = $this->buildEmailPayload($message, $context);

        return $this->sendViaMailer($email, $subject, $payload['text'], $payload['html'], $payload['data']);
    }

    private function sendViaMailer(
        string $email,
        string $subject,
        string $textMessage,
        string $htmlMessage,
        array $data
    ): bool
    {
        try {
            Mail::send(
                ['html' => 'emails.otp', 'text' => 'emails.otp_text'],
                $data,
                function ($m) use ($email, $subject) {
                    $m->to($email)->subject($subject);
                }
            );

            return true;
        } catch (\Throwable $exception) {
            Log::warning('OTP email send failed.', [
                'message' => $exception->getMessage(),
            ]);

            return false;
        }
    }

    private function buildEmailPayload(string $message, array $context): array
    {
        $appName = (string) config('app.name', 'KneaYerng');
        $code = (string) ($context['code'] ?? '');
        $expiresMinutes = (int) ($context['expires_minutes'] ?? 5);

        $data = [
            'appName' => $appName,
            'otpCode' => $code,
            'expiresMinutes' => $expiresMinutes,
            'supportEmail' => (string) config('mail.from.address', ''),
            'year' => (int) date('Y'),
        ];

        $text = $message;
        if ($code !== '') {
            $text = sprintf(
                '[%s] Your OTP code is %s. It expires in %d minutes.',
                $appName,
                $code,
                $expiresMinutes
            );
        }

        $html = view('emails.otp', $data)->render();

        return [
            'text' => $text,
            'html' => $html,
            'data' => $data,
        ];
    }
}
