<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class OtpMail extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(
        public string $otpCode,
        public int $expiresMinutes = 5
    ) {}

    public function build()
    {
        return $this->subject('Your OTP Code')
            ->text('emails.otp_text')
            ->with([
                'otpCode' => $this->otpCode,
                'expiresMinutes' => $this->expiresMinutes,
            ]);
    }
}
