<?php

return [
    'base_url' => env('INFOBIP_BASE_URL'),
    'api_key' => env('INFOBIP_API_KEY'),
    'verify' => filter_var(env('INFOBIP_VERIFY', true), FILTER_VALIDATE_BOOLEAN),
    'ca_bundle' => env('INFOBIP_CA_BUNDLE', ''),
    'check_delivery_report' => filter_var(env('INFOBIP_CHECK_DELIVERY_REPORT', true), FILTER_VALIDATE_BOOLEAN),
    'delivery_report_delay_ms' => (int) env('INFOBIP_DELIVERY_REPORT_DELAY_MS', 600),
    'delivery_report_timeout_seconds' => (int) env('INFOBIP_DELIVERY_REPORT_TIMEOUT_SECONDS', 2),
    'sms' => [
        'sender' => env('INFOBIP_SMS_SENDER'),
    ],
    'email' => [
        'from' => env('INFOBIP_EMAIL_FROM'),
        'from_name' => env('INFOBIP_EMAIL_FROM_NAME', 'OTP'),
    ],
];
