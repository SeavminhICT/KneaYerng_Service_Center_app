<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Third Party Services
    |--------------------------------------------------------------------------
    |
    | This file is for storing the credentials for third party services such
    | as Mailgun, Postmark, AWS and more. This file provides the de facto
    | location for this type of information, allowing packages to have
    | a conventional file to locate the various service credentials.
    |
    */

    'postmark' => [
        'key' => env('POSTMARK_API_KEY'),
    ],

    'resend' => [
        'key' => env('RESEND_API_KEY'),
    ],

    'ses' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    ],

    'slack' => [
        'notifications' => [
            'bot_user_oauth_token' => env('SLACK_BOT_USER_OAUTH_TOKEN'),
            'channel' => env('SLACK_BOT_USER_DEFAULT_CHANNEL'),
        ],
    ],

    'bakong' => [
        'merchant_id' => env('BAKONG_MERCHANT_ID', 'DEMO_MERCHANT'),
        'merchant_name' => env('BAKONG_MERCHANT_NAME', 'KneaYerng Service Center'),
    ],

    'bakong_open' => [
        'base_url' => env('BAKONG_OPEN_BASE_URL', env('BAKONG_BASE_URL', '')),
        'token' => env('BAKONG_OPEN_TOKEN', env('BAKONG_TOKEN', '')),
        'timeout' => (int) env('BAKONG_OPEN_TIMEOUT', 12),
        'verify' => env('BAKONG_OPEN_VERIFY', true),
        'ca_bundle' => env('BAKONG_OPEN_CA_BUNDLE', ''),
    ],

    'payment' => [
        'callback_secret' => env('PAYMENT_CALLBACK_SECRET', ''),
    ],

    'easysendsms' => [
        'base_url' => env('EASYSENDSMS_BASE_URL', 'https://api.easysendsms.app/bulksms'),
        'username' => env('EASYSENDSMS_USERNAME', ''),
        'password' => env('EASYSENDSMS_PASSWORD', ''),
        'from' => env('EASYSENDSMS_FROM', 'OTP'),
    ],

];
