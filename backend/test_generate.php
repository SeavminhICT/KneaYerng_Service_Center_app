<?php
require __DIR__ . '/vendor/autoload.php';

$apiKey = 'ak_6cf80eb7e370d786f47270db926534294222a48e4ec6a9f5';
$url = 'https://khpay.site/api/v1/bakong/generate';

$payload = [
    'amount' => 1.00,
    'currency' => 'USD',
    'note' => 'Test PHP Script API check',
    'success_url' => 'https://example.com/success',
    'cancel_url' => 'https://example.com/cancel',
    'callback_url' => 'https://kneayerng.seavminh.com/api/payments/khpay-callback'
];

$ch = curl_init($url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Authorization: Bearer ' . $apiKey,
    'Content-Type: application/json',
    'X-Test-Mode: true'
]);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);

$response = curl_exec($ch);
if (curl_errno($ch)) {
    echo 'Curl error: ' . curl_error($ch) . "\n";
} else {
    echo "Response:\n" . $response . "\n";
}
curl_close($ch);
