<?php

return [
    'code_length' => (int) env('OTP_CODE_LENGTH', 6),
    'ttl_seconds' => (int) env('OTP_TTL_SECONDS', 300),
    'resend_cooldown_seconds' => (int) env('OTP_RESEND_COOLDOWN_SECONDS', 60),
    'max_attempts' => (int) env('OTP_MAX_ATTEMPTS', 5),
    'lock_seconds' => (int) env('OTP_LOCK_SECONDS', 600),
    'rate_limit_per_destination_per_hour' => (int) env('OTP_DEST_RATE_PER_HOUR', 5),
    'rate_limit_per_ip_10m' => (int) env('OTP_IP_RATE_PER_10M', 10),
    'email_subject' => env('OTP_EMAIL_SUBJECT', 'Your OTP Code'),
];
