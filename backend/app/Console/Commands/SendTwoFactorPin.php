<?php

namespace App\Console\Commands;

use App\Services\TwilioOtpService;
use Illuminate\Console\Command;

class SendTwoFactorPin extends Command
{
    protected $signature = 'otp:send-2fa-pin {phone=85581515245}';

    protected $description = 'Generate a 2FA pin and send it via Twilio SMS using the otp.pin_sms_template.';

    public function handle(TwilioOtpService $twilio): int
    {
        $to = (string) $this->argument('phone');
        $to = str_starts_with($to, '+') ? $to : '+'.ltrim($to, '+');

        $length = max(4, (int) config('otp.pin_length', 4));
        $pin = (string) random_int(10 ** ($length - 1), (10 ** $length) - 1);

        $message = str_replace('{{pin}}', $pin, (string) config('otp.pin_sms_template', 'Your pin is {{pin}}'));

        $this->info("Sending to {$to}: \"{$message}\"");

        if (! $twilio->sendSms($to, $message)) {
            $this->error('Send failed — check storage/logs/laravel.log for the Twilio error.');

            return self::FAILURE;
        }

        $this->info("Sent. Generated pin: {$pin}");

        return self::SUCCESS;
    }
}
