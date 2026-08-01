<?php

return [
    'delivery_fee' => (float) env('DELIVERY_FEE', 0),
    'tax_rate' => (float) env('ORDER_TAX_RATE', 0),

    // Shop pin shown on the mobile app's delivery map, and the origin point
    // used to compute distance-based delivery fees below.
    'shop_location' => [
        'name' => env('SHOP_NAME', 'KneaYerng VIP'),
        'lat' => (float) env('SHOP_LAT', 11.5664368),
        'lng' => (float) env('SHOP_LNG', 104.8923294),
    ],

    // Distance-based delivery fee tiers (Phnom Penh only). Each tier's
    // "max_km" is inclusive; a delivery distance beyond the last tier is
    // charged the last tier's fee. Evaluated in App\Services\DeliveryFeeService.
    'delivery_fee_tiers' => [
        ['max_km' => 10, 'fee' => 0],
        ['max_km' => 15, 'fee' => 2],
        ['max_km' => 20, 'fee' => 3],
        ['max_km' => 25, 'fee' => 5],
    ],
    'payment_methods' => [
        [
            'code' => 'aba',
            'label' => 'ABA Pay',
            'description' => 'Fast payment with ABA mobile app',
        ],
        [
            'code' => 'cash',
            'label' => 'Cash on Delivery',
            'description' => 'Pay in cash when your order arrives',
        ],
        [
            'code' => 'card',
            'label' => 'Card Payment',
            'description' => 'Visa / MasterCard',
        ],
    ],
    'delivery_slots' => [
        [
            'code' => 'slot_0900_1700',
            'label' => 'Today, 9:00 AM - 5:00 PM',
            'description' => 'Available',
        ],
        [
            'code' => 'slot_1800_2100',
            'label' => 'Today, 6:00 PM - 9:00 PM',
            'description' => 'Limited',
        ],
        [
            'code' => 'slot_tomorrow',
            'label' => 'Tomorrow, 10:00 AM - 2:00 PM',
            'description' => 'Available',
        ],
    ],
];
