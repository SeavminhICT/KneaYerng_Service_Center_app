<?php

namespace App\Services;

use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;

class OtpDeliveryService
{
    public function __construct(
        private UnimatrixOtpService $unimatrix,
        private InfobipService $infobip,
        private TwilioOtpService $twilio,
    ) {
    }

    public function send(string $destinationType, string $destination, string $message, array $context = []): bool
    {
        if ($destinationType === 'email') {
            return $this->sendEmail($destination, $message, $context);
        }

        if ($destinationType === 'phone') {
            $provider = strtolower(trim((string) config('services.otp.sms_provider', 'unimatrix')));

            if ($provider === 'infobip') {
                return $this->sendViaInfobip($destination, $message);
            }

            if ($provider === 'twilio') {
                $to = str_starts_with($destination, '+') ? $destination : '+'.$destination;

                return $this->twilio->sendSms($to, $message);
            }

            $code = (string) ($context['code'] ?? '');
            if ($code !== '') {
                return $this->unimatrix->sendOtpCode(
                    phone: $destination,
                    code: $code,
                    ttlSeconds: (int) ($context['ttl_seconds'] ?? config('otp.ttl_seconds', 300)),
                    purpose: (string) ($context['purpose'] ?? 'otp')
                );
            }

            return $this->unimatrix->sendSms($destination, $message);
        }

        Log::warning('Unsupported OTP destination type.', [
            'type' => $destinationType,
        ]);

        return false;
    }

    private function sendViaInfobip(string $phone, string $message): bool
    {
        $to = ltrim($phone, '+');

        try {
            return $this->infobip->sendSms($to, $message);
        } catch (\Throwable $exception) {
            Log::warning('Infobip OTP SMS send failed.', [
                'message' => $exception->getMessage(),
            ]);

            return false;
        }
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
