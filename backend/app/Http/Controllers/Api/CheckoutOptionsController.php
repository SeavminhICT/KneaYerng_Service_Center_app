<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class CheckoutOptionsController extends Controller
{
    public function __invoke(Request $request)
    {
        return response()->json([
            'data' => [
                'delivery_fee' => (float) config('orders.delivery_fee', 0),
                'tax_rate' => (float) config('orders.tax_rate', 0),
                'payment_methods' => config('orders.payment_methods', []),
                'delivery_slots' => config('orders.delivery_slots', []),
            ],
        ]);
    }
}
