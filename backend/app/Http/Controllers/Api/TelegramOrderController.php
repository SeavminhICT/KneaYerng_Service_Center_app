<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Services\TelegramOrderService;

class TelegramOrderController extends Controller
{
    public function notify(Order $order, TelegramOrderService $telegram)
    {
        if (! $telegram->sendOrderMessage($order, true)) {
            return response()->json(['message' => 'Telegram is not configured.'], 503);
        }

        return response()->json(['message' => 'Telegram notification sent.']);
    }
}
