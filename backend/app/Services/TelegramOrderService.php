<?php

namespace App\Services;

use App\Models\Order;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class TelegramOrderService
{
    public function handlePaymentSuccess(Order $order): void
    {
        $this->updateStatusAfterPayment($order);

        if (! $this->isConfigured()) {
            return;
        }

        if ($order->telegram_message_id) {
            return;
        }

        $this->sendOrderMessage($order);
    }

    public function sendOrderMessage(Order $order, bool $force = false): bool
    {
        if (! $this->isConfigured()) {
            return false;
        }

        if ($order->telegram_message_id && ! $force) {
            return true;
        }

        $order->loadMissing(['items', 'user']);

        $payload = [
            'chat_id' => $this->chatId(),
            'text' => $this->buildOrderMessage($order),
            'disable_web_page_preview' => true,
        ];

        $keyboard = $this->buildInlineKeyboard($order);
        if ($keyboard) {
            $payload['reply_markup'] = $keyboard;
        }

        $response = $this->postTelegram('sendMessage', $payload);
        if (! ($response['ok'] ?? false)) {
            Log::warning('Telegram order message failed.', [
                'order_id' => $order->id,
                'response' => $response,
            ]);
            return false;
        }

        $messageId = $response['result']['message_id'] ?? null;
        if ($messageId) {
            $order->telegram_chat_id = (string) $this->chatId();
            $order->telegram_message_id = (string) $messageId;
            $order->telegram_last_action = 'notified';
            $order->telegram_last_action_at = now();
            $order->telegram_message_sent_at = now();
            $order->save();
        }

        return true;
    }

    public function handleWebhook(array $update): void
    {
        if (! isset($update['callback_query'])) {
            return;
        }

        $callback = $update['callback_query'];
        $callbackId = $callback['id'] ?? null;
        $data = $callback['data'] ?? '';

        if (! $callbackId || ! is_string($data) || $data === '') {
            return;
        }

        [$action, $orderId] = array_pad(explode('|', $data, 2), 2, null);
        if (! $action || ! $orderId || ! ctype_digit((string) $orderId)) {
            $this->answerCallback($callbackId, 'Invalid action.');
            return;
        }

        $telegramUser = $callback['from'] ?? [];
        $telegramUserId = (string) ($telegramUser['id'] ?? '');

        if (! $this->isAdminAllowed($telegramUserId)) {
            $this->answerCallback($callbackId, 'Unauthorized.');
            return;
        }

        $order = Order::find((int) $orderId);
        if (! $order) {
            $this->answerCallback($callbackId, 'Order not found.');
            return;
        }

        $action = strtoupper(trim($action));
        if ($action === 'LOC') {
            $this->handleLocationRequest($order, $callbackId);
            return;
        }

        if (! $this->applyAction($order, $action, $telegramUser)) {
            $this->answerCallback($callbackId, 'Action not allowed.');
            return;
        }

        $this->answerCallback($callbackId, 'Updated.');
        $this->editOrderMessage($order, $telegramUser);
    }

    public function isWebhookAuthorized(?string $secretHeader): bool
    {
        $secret = trim((string) config('services.telegram.webhook_secret'));
        if ($secret === '') {
            return true;
        }
        return hash_equals($secret, (string) $secretHeader);
    }

    private function handleLocationRequest(Order $order, string $callbackId): void
    {
        $sent = false;
        $lat = $order->delivery_lat;
        $lng = $order->delivery_lng;
        if ($lat !== null && $lng !== null) {
            $sent = $this->sendLocation($order, (float) $lat, (float) $lng);
        }

        if (! $sent) {
            $text = $order->delivery_address
                ? 'Delivery address: '.$order->delivery_address
                : 'Delivery address not available.';
            $response = $this->postTelegram('sendMessage', [
                'chat_id' => $this->chatId(),
                'text' => $text,
                'disable_web_page_preview' => true,
            ]);
            $sent = (bool) ($response['ok'] ?? false);
        }

        $this->answerCallback($callbackId, $sent ? 'Location sent.' : 'Unable to send location.');
    }

    private function applyAction(Order $order, string $action, array $telegramUser): bool
    {
        if ($order->order_type !== 'delivery') {
            return false;
        }

        if (! in_array($action, ['APP', 'REJ'], true)) {
            return false;
        }

        if (in_array($order->status, ['approved', 'rejected', 'delivered'], true)) {
            return true;
        }

        $status = $action === 'APP' ? 'approved' : 'rejected';
        $order->status = $status;
        $order->telegram_last_action = $status;
        $order->telegram_last_action_by = $this->formatAdminLabel($telegramUser);
        $order->telegram_last_action_at = now();
        $order->save();

        return true;
    }

    private function editOrderMessage(Order $order, array $telegramUser): void
    {
        if (! $order->telegram_message_id || ! $order->telegram_chat_id) {
            return;
        }

        $order->loadMissing(['items', 'user']);

        $statusLabel = $order->status === 'approved' ? '✅ Approved' : '❌ Rejected';
        $adminLabel = $this->formatAdminLabel($telegramUser);
        $timeLabel = now()->format('Y-m-d H:i');

        $text = $this->buildOrderMessage($order);
        $text .= "\n\nStatus: {$statusLabel}\nBy: {$adminLabel}\nTime: {$timeLabel}";
        $text = $this->truncateMessage($text);

        $this->postTelegram('editMessageText', [
            'chat_id' => $order->telegram_chat_id,
            'message_id' => (int) $order->telegram_message_id,
            'text' => $text,
            'disable_web_page_preview' => true,
            'reply_markup' => ['inline_keyboard' => []],
        ]);
    }

    private function sendLocation(Order $order, float $lat, float $lng): bool
    {
        $response = $this->postTelegram('sendLocation', [
            'chat_id' => $this->chatId(),
            'latitude' => $lat,
            'longitude' => $lng,
        ]);

        return (bool) ($response['ok'] ?? false);
    }

    private function buildOrderMessage(Order $order): string
    {
        $lines = [];
        $lines[] = 'លោកអ្នកទទួលបានការកម្មង់';
        $lines[] = '---------------------------------------';

        $customerName = $order->customer_name ?? 'Customer';
        $phone = $order->delivery_phone
            ?? $order->user?->phone
            ?? '-';

        $lines[] = 'Customer Name: '.$customerName;
        $lines[] = 'Phone Number: '.$phone;
        $lines[] = '';
        $lines[] = 'Items:';

        $totalQty = 0;
        $index = 1;
        foreach ($order->items as $item) {
            $name = $item->product_name ?: 'Item';
            $qty = (int) ($item->quantity ?? 0);
            $price = (float) ($item->price ?? 0);
            $lineTotal = (float) ($item->line_total ?? ($price * $qty));
            $totalQty += $qty;

            $lines[] = sprintf(
                '%d) %s  x%d  @ %s = %s',
                $index,
                $name,
                $qty,
                $this->formatMoney($price),
                $this->formatMoney($lineTotal)
            );
            $index++;
        }

        $lines[] = '';
        $lines[] = 'Total QTY: '.$totalQty;
        $lines[] = 'Total: '.$this->formatMoney((float) $order->total_amount).' USD';
        $lines[] = '';
        $lines[] = 'Payment Method: '.$this->formatPaymentMethod($order->payment_method);
        $lines[] = 'Delivery Method: '.$this->formatDeliveryMethod($order->order_type);

        if ($order->order_type === 'delivery') {
            if ($order->delivery_address) {
                $lines[] = 'Address: '.$order->delivery_address;
            }
            if ($order->delivery_note) {
                $lines[] = 'Note: '.$order->delivery_note;
            }
            $mapLink = $this->googleMapsLink($order);
            if ($mapLink) {
                $lines[] = 'Location: '.$mapLink;
            }
        }

        $lines[] = '';
        $lines[] = 'Order ID: '.$this->orderIdentifier($order);

        $time = $order->placed_at ?? $order->created_at;
        if ($time) {
            $lines[] = 'Order Time: '.$time->timezone(config('app.timezone'))->format('Y-m-d H:i');
        }

        return $this->truncateMessage(implode("\n", $lines));
    }

    private function buildInlineKeyboard(Order $order): ?array
    {
        if ($order->order_type !== 'delivery') {
            return null;
        }

        if (in_array($order->status, ['approved', 'rejected', 'delivered'], true)) {
            return null;
        }

        $buttons = [
            [
                ['text' => '✅ Approve', 'callback_data' => 'APP|'.$order->id],
                ['text' => '❌ Reject', 'callback_data' => 'REJ|'.$order->id],
            ],
        ];

        $mapLink = $this->googleMapsLink($order);
        if ($mapLink) {
            $buttons[] = [
                ['text' => '📍 Send Location', 'url' => $mapLink],
            ];
        } else {
            $buttons[] = [
                ['text' => '📍 Send Location', 'callback_data' => 'LOC|'.$order->id],
            ];
        }

        $deepLink = $this->deepLink($order);
        if ($deepLink) {
            $buttons[] = [
                ['text' => '🔎 View Order in App', 'url' => $deepLink],
            ];
        }

        return ['inline_keyboard' => $buttons];
    }

    private function updateStatusAfterPayment(Order $order): void
    {
        if ($order->payment_status !== 'paid') {
            return;
        }

        if ($order->order_type === 'delivery') {
            if (in_array($order->status, ['pending', 'processing'], true)) {
                $order->status = 'pending_confirmation';
                $order->save();
            }
            return;
        }

        if (in_array($order->status, ['pending', 'processing'], true)) {
            $order->status = 'ready';
            $order->save();
        }
    }

    private function formatPaymentMethod(?string $method): string
    {
        $method = strtolower(trim((string) $method));
        return match ($method) {
            'aba' => 'ABA',
            'cash', 'cod' => 'Cash',
            'card' => 'Card',
            'wallet' => 'Wallet',
            'bank' => 'Bank',
            default => $method === '' ? 'Unknown' : strtoupper($method),
        };
    }

    private function formatDeliveryMethod(?string $type): string
    {
        return strtolower((string) $type) === 'delivery' ? 'Home Delivery' : 'Pickup';
    }

    private function formatMoney(float $value): string
    {
        return number_format($value, 2, '.', '');
    }

    private function orderIdentifier(Order $order): string
    {
        return $order->order_number ?: (string) $order->id;
    }

    private function googleMapsLink(Order $order): ?string
    {
        if ($order->delivery_lat === null || $order->delivery_lng === null) {
            return null;
        }

        $lat = (float) $order->delivery_lat;
        $lng = (float) $order->delivery_lng;
        return 'https://maps.google.com/?q='.rawurlencode($lat.','.$lng);
    }

    private function deepLink(Order $order): ?string
    {
        $base = trim((string) config('services.telegram.deep_link_base'));
        if ($base === '') {
            return null;
        }

        return rtrim($base, '/').'/'.$order->id;
    }

    private function formatAdminLabel(array $telegramUser): string
    {
        $username = trim((string) ($telegramUser['username'] ?? ''));
        if ($username !== '') {
            return '@'.$username;
        }

        $name = trim((string) ($telegramUser['first_name'] ?? ''));
        $last = trim((string) ($telegramUser['last_name'] ?? ''));
        $full = trim($name.' '.$last);
        if ($full !== '') {
            return $full;
        }

        return 'Admin';
    }

    private function truncateMessage(string $text, int $max = 3800): string
    {
        if (mb_strlen($text) <= $max) {
            return $text;
        }

        return mb_substr($text, 0, $max - 3).'...';
    }

    private function isConfigured(): bool
    {
        return $this->botToken() !== '' && $this->chatId() !== '';
    }

    private function botToken(): string
    {
        return trim((string) config('services.telegram.bot_token'));
    }

    private function chatId(): string
    {
        return trim((string) config('services.telegram.group_chat_id'));
    }

    private function postTelegram(string $method, array $payload): array
    {
        $token = $this->botToken();
        if ($token === '') {
            return ['ok' => false, 'error' => 'Missing bot token'];
        }

        $verify = config('services.telegram.verify', true);
        $caBundle = trim((string) config('services.telegram.ca_bundle', ''));
        $verifyOption = $caBundle !== '' ? $caBundle : (bool) $verify;

        try {
            $response = Http::timeout(8)
                ->withOptions(['verify' => $verifyOption])
                ->post(
                    'https://api.telegram.org/bot'.$token.'/'.$method,
                    $payload
                );
            return $response->json() ?? ['ok' => false];
        } catch (\Throwable $exception) {
            Log::warning('Telegram API error.', [
                'method' => $method,
                'message' => $exception->getMessage(),
            ]);
            return ['ok' => false];
        }
    }

    private function answerCallback(string $callbackId, string $text): void
    {
        $this->postTelegram('answerCallbackQuery', [
            'callback_query_id' => $callbackId,
            'text' => $text,
        ]);
    }

    private function isAdminAllowed(string $telegramUserId): bool
    {
        $raw = trim((string) config('services.telegram.admin_user_ids', ''));
        if ($raw === '') {
            return true;
        }

        $allowed = array_filter(array_map('trim', explode(',', $raw)));
        return in_array($telegramUserId, $allowed, true);
    }
}
