<?php

return [
    'base_url' => env('INFOBIP_BASE_URL'),
    'api_key' => env('INFOBIP_API_KEY'),
    'sms' => [
        'sender' => env('INFOBIP_SMS_SENDER'),
    ],
    'email' => [
        'from' => env('INFOBIP_EMAIL_FROM'),
        'from_name' => env('INFOBIP_EMAIL_FROM_NAME', 'OTP'),
    ],
];
