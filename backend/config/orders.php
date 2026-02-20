<?php

return [
    'delivery_fee' => (float) env('DELIVERY_FEE', 0),
    'tax_rate' => (float) env('ORDER_TAX_RATE', 0),
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
