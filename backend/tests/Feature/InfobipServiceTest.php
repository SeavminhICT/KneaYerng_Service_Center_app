<?php

use App\Services\InfobipService;
use Illuminate\Http\Client\Request;
use Illuminate\Support\Facades\Http;

beforeEach(function () {
    config()->set('infobip.base_url', '552z1y.api.infobip.com');
    config()->set('infobip.api_key', 'test-api-key');
    config()->set('infobip.sms.sender', '447491163443');
    config()->set('infobip.check_delivery_report', true);
    config()->set('infobip.delivery_report_delay_ms', 0);
    config()->set('infobip.delivery_report_timeout_seconds', 2);
    config()->set('otp.default_phone_country_code', '+855');
});

test('infobip sms service sends the sms v3 otp payload', function () {
    Http::fake([
        'https://552z1y.api.infobip.com/sms/3/messages' => Http::response([
            'messages' => [
                ['messageId' => 'message-1'],
            ],
        ]),
        'https://552z1y.api.infobip.com/sms/3/reports*' => Http::response([
            'results' => [
                [
                    'status' => [
                        'groupId' => 1,
                        'name' => 'PENDING',
                    ],
                ],
            ],
        ]),
    ]);

    $sent = app(InfobipService::class)->sendSms('+855 85 515 245', 'Your OTP code is 123456. It expires in 5 minutes.');

    expect($sent)->toBeTrue();

    Http::assertSent(function (Request $request) {
        return $request->url() === 'https://552z1y.api.infobip.com/sms/3/messages'
            && $request->hasHeader('Authorization', 'App test-api-key')
            && $request->hasHeader('Accept', 'application/json')
            && $request->data() === [
                'messages' => [
                    [
                        'sender' => '447491163443',
                        'destinations' => [
                            ['to' => '85585515245'],
                        ],
                        'content' => [
                            'text' => 'Your OTP code is 123456. It expires in 5 minutes.',
                        ],
                    ],
                ],
            ];
    });
});

test('infobip sms service returns false when the send request fails', function () {
    Http::fake([
        'https://552z1y.api.infobip.com/sms/3/messages' => Http::response([
            'requestError' => [
                'serviceException' => [
                    'text' => 'Invalid login details',
                ],
            ],
        ], 401),
    ]);

    expect(app(InfobipService::class)->sendSms('085515245', 'Your OTP code is 123456. It expires in 5 minutes.'))->toBeFalse();
});
