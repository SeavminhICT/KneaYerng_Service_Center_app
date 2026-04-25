<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\TelegramOrderService;
use Illuminate\Http\Request;

class TelegramWebhookController extends Controller
{
    public function __invoke(Request $request, TelegramOrderService $telegram)
    {
        $secretHeader = $request->header('X-Telegram-Bot-Api-Secret-Token');
        if (! $telegram->isWebhookAuthorized($secretHeader)) {
            return response()->json(['message' => 'Unauthorized.'], 403);
        }

        $telegram->handleWebhook($request->all());

        return response()->json(['ok' => true]);
    }
}
