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
        'account_id' => env('BAKONG_ACCOUNT_ID', ''),
        'merchant_id' => env('BAKONG_MERCHANT_ID', 'DEMO_MERCHANT'),
        'merchant_name' => env('BAKONG_MERCHANT_NAME', 'KneaYerng Service Center'),
        'merchant_city' => env('BAKONG_MERCHANT_CITY', 'Phnom Penh'),
        'merchant_category' => env('BAKONG_MERCHANT_CATEGORY', '5999'),
        'country_code' => env('BAKONG_COUNTRY_CODE', 'KH'),
        'qr_expires_minutes' => (int) env('BAKONG_QR_EXPIRES_MINUTES', 10),
    ],

    'bakong_open' => [
        'base_url' => env('BAKONG_OPEN_BASE_URL', env('BAKONG_BASE_URL', '')),
        'token' => env('BAKONG_OPEN_TOKEN', env('BAKONG_TOKEN', '')),
        'timeout' => (int) env('BAKONG_OPEN_TIMEOUT', 12),
        'verify' => filter_var(env('BAKONG_OPEN_VERIFY', true), FILTER_VALIDATE_BOOLEAN),
        'ca_bundle' => env('BAKONG_OPEN_CA_BUNDLE', ''),
    ],

    'payment' => [
        'callback_secret' => env('PAYMENT_CALLBACK_SECRET', ''),
    ],

    'telegram' => [
        'bot_token' => env('TELEGRAM_BOT_TOKEN', ''),
        'group_chat_id' => env('TELEGRAM_GROUP_CHAT_ID', ''),
        'webhook_secret' => env('TELEGRAM_WEBHOOK_SECRET', ''),
        'deep_link_base' => env('TELEGRAM_DEEP_LINK_BASE', ''),
        'admin_user_ids' => env('TELEGRAM_ADMIN_USER_IDS', ''),
        'verify' => filter_var(env('TELEGRAM_VERIFY', true), FILTER_VALIDATE_BOOLEAN),
        'ca_bundle' => env('TELEGRAM_CA_BUNDLE', ''),
    ],

    'easysendsms' => [
        'base_url' => env('EASYSENDSMS_BASE_URL', 'https://api.easysendsms.app/bulksms'),
        'username' => env('EASYSENDSMS_USERNAME', ''),
        'password' => env('EASYSENDSMS_PASSWORD', ''),
        'from' => env('EASYSENDSMS_FROM', 'OTP'),
    ],

    'sendgrid' => [
        'api_key' => env('SENDGRID_API_KEY', ''),
        'from_email' => env('SENDGRID_FROM_EMAIL', env('MAIL_FROM_ADDRESS', '')),
        'from_name' => env('SENDGRID_FROM_NAME', env('MAIL_FROM_NAME', '')),
        'verify' => filter_var(env('SENDGRID_VERIFY', true), FILTER_VALIDATE_BOOLEAN),
        'ca_bundle' => env('SENDGRID_CA_BUNDLE', ''),
    ],

    'twilio' => [
        'account_sid' => env('TWILIO_ACCOUNT_SID', ''),
        'auth_token' => env('TWILIO_AUTH_TOKEN', ''),
        'from' => env('TWILIO_FROM', ''),
    ],

    'firebase' => [
        'project_id' => env('FIREBASE_PROJECT_ID', ''),
        'credentials' => env('FIREBASE_CREDENTIALS', ''),
    ],

    'unimatrix' => [
        'base_url' => env('UNIMATRIX_BASE_URL', 'https://api.unimtx.com'),
        'access_key_id' => env('UNIMATRIX_ACCESS_KEY_ID', ''),
        'access_key_secret' => env('UNIMATRIX_ACCESS_KEY_SECRET', ''),
        'channel' => env('UNIMATRIX_CHANNEL', 'sms'),
        'timeout' => (int) env('UNIMATRIX_TIMEOUT', 15),
        'verify' => filter_var(env('UNIMATRIX_VERIFY', true), FILTER_VALIDATE_BOOLEAN),
        'ca_bundle' => env('UNIMATRIX_CA_BUNDLE', ''),
    ],

];
