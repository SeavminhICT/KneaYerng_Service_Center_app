<?php

return [
    'base_url' => env('INFOBIP_BASE_URL'),
    'api_key' => env('INFOBIP_API_KEY'),
    'verify' => filter_var(env('INFOBIP_VERIFY', true), FILTER_VALIDATE_BOOLEAN),
    'ca_bundle' => env('INFOBIP_CA_BUNDLE', ''),
    'sms' => [
        'sender' => env('INFOBIP_SMS_SENDER'),
    ],
    'email' => [
        'from' => env('INFOBIP_EMAIL_FROM'),
        'from_name' => env('INFOBIP_EMAIL_FROM_NAME', 'OTP'),
    ],
];
