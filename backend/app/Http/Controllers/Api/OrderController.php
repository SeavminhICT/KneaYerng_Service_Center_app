<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\StoreOrderRequest;
use App\Http\Requests\Api\UpdateOrderRequest;
use App\Http\Resources\OrderResource;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Payment;
use Illuminate\Contracts\Encryption\DecryptException;
use Illuminate\Support\Facades\Crypt;
use Illuminate\Support\Facades\Log;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class OrderController extends Controller
{
    public function index(Request $request)
    {
        $query = Order::query()->orderByDesc('placed_at')->orderByDesc('id');

        if ($request->filled('q')) {
            $q = $request->string('q');
            $query->where(function ($builder) use ($q) {
                $builder->where('order_number', 'like', "%{$q}%")
                    ->orWhere('customer_name', 'like', "%{$q}%")
                    ->orWhere('customer_email', 'like', "%{$q}%");
            });
        }

        if ($request->filled('status')) {
            $query->where('status', $request->string('status'));
        }

        if ($request->filled('payment_status')) {
            $query->where('payment_status', $request->string('payment_status'));
        }

        if ($request->filled('order_type')) {
            $query->where('order_type', $request->string('order_type'));
        }

        $perPage = (int) $request->input('per_page', 10);
        $perPage = max(1, min(50, $perPage));

        $orders = $query->paginate($perPage)->withQueryString();

        return OrderResource::collection($orders);
    }

    public function store(StoreOrderRequest $request)
    {
        $validated = $request->validated();
        $items = $validated['items'] ?? [];
        $actor = $request->user() ?? $request->user('sanctum');

        $orderNumber = $validated['order_number'] ?? $this->generateOrderNumber();
        $totalAmount = collect($items)->sum(fn ($item) => $item['price'] * $item['quantity']);
        $orderType = $validated['order_type'] ?? 'pickup';
        $paymentMethod = $validated['payment_method'] ?? 'cash';
        $paymentStatus = $validated['payment_status'] ?? null;
        $status = $validated['status'] ?? 'pending';

        if (! $paymentStatus) {
            $paymentStatus = $paymentMethod === 'bank' ? 'processing' : 'pending';
        }

        $order = Order::create([
            'order_number' => $orderNumber,
            'user_id' => $this->resolveUserId($actor, $validated),
            'customer_name' => $validated['customer_name'],
            'customer_email' => $validated['customer_email'] ?? null,
            'order_type' => $orderType,
            'payment_method' => $paymentMethod,
            'delivery_address' => $validated['delivery_address'] ?? null,
            'delivery_phone' => $validated['delivery_phone'] ?? null,
            'total_amount' => $totalAmount,
            'payment_status' => $paymentStatus,
            'status' => $status,
            'placed_at' => $validated['placed_at'] ?? now(),
        ]);

        $payment = Payment::create([
            'order_id' => $order->id,
            'method' => $paymentMethod,
            'status' => $paymentStatus,
            'amount' => $totalAmount,
        ]);

        Log::info('Payment created for order.', [
            'order_id' => $order->id,
            'payment_id' => $payment->id,
            'status' => $payment->status,
            'method' => $payment->method,
        ]);

        foreach ($items as $item) {
            OrderItem::create([
                'order_id' => $order->id,
                'product_id' => $item['product_id'] ?? null,
                'product_name' => $item['product_name'],
                'quantity' => $item['quantity'],
                'price' => $item['price'],
            ]);
        }

        return new OrderResource($order->load(['items', 'payments']));
    }

    public function show(Request $request, Order $order)
    {
        $actor = $request->user() ?? $request->user('sanctum');

        if ($actor && method_exists($actor, 'isAdmin') && ! $actor->isAdmin()) {
            if ((int) $order->user_id !== (int) $actor->id) {
                return response()->json(['message' => 'Forbidden.'], 403);
            }
        }

        return new OrderResource($order->load(['items', 'payments']));
    }

    public function update(UpdateOrderRequest $request, Order $order)
    {
        $validated = $request->validated();
        $paymentStatus = $validated['payment_status'] ?? null;
        $paymentMethod = $validated['payment_method'] ?? null;

        $order->fill(collect($validated)->except('items')->toArray());

        if (array_key_exists('items', $validated)) {
            $order->items()->delete();

            foreach ($validated['items'] as $item) {
                OrderItem::create([
                    'order_id' => $order->id,
                    'product_id' => $item['product_id'] ?? null,
                    'product_name' => $item['product_name'],
                    'quantity' => $item['quantity'],
                    'price' => $item['price'],
                ]);
            }
        }

        if (array_key_exists('items', $validated)) {
            $order->total_amount = collect($validated['items'])->sum(fn ($item) => $item['price'] * $item['quantity']);
        }

        if ($paymentMethod || $paymentStatus) {
            $payment = $order->payments()->latest()->first();
            if (! $payment) {
                $payment = Payment::create([
                    'order_id' => $order->id,
                    'method' => $paymentMethod ?? ($order->payment_method ?? 'cash'),
                    'status' => 'pending',
                    'amount' => $order->total_amount,
                ]);
            }

            if ($paymentMethod) {
                $payment->method = $paymentMethod;
                $order->payment_method = $paymentMethod;
                if ($paymentMethod === 'bank' && $payment->status === 'pending') {
                    $payment->status = 'processing';
                }
            }

            if ($paymentStatus) {
                $transitionError = $this->applyPaymentStatusTransition($payment, $paymentStatus);
                if ($transitionError) {
                    return response()->json(['message' => $transitionError], 422);
                }
            }

            $payment->save();
            $order->payment_status = $payment->status;
        }

        $order->save();

        return new OrderResource($order->load(['items', 'payments']));
    }

    public function destroy(Order $order)
    {
        $order->delete();

        return response()->noContent();
    }

    public function generatePickupQr(Request $request, Order $order)
    {
        if ($order->order_type !== 'pickup') {
            return response()->json(['message' => 'QR is only available for pickup orders.'], 422);
        }

        $payload = [
            'order_id' => $order->id,
            'nonce' => Str::random(16),
            'expires_at' => now()->addHours(24)->timestamp,
        ];

        $token = Crypt::encryptString(json_encode($payload));

        $order->pickup_qr_token = $token;
        $order->pickup_qr_generated_at = now();
        $order->save();

        return response()->json([
            'order_id' => $order->id,
            'token' => $token,
        ]);
    }

    public function verifyPickupQr(Request $request)
    {
        $validated = $request->validate([
            'token' => ['required', 'string'],
        ]);

        try {
            $decoded = json_decode(Crypt::decryptString($validated['token']), true);
        } catch (DecryptException $exception) {
            return response()->json(['message' => 'Invalid QR token.'], 422);
        }

        if (! is_array($decoded) || empty($decoded['order_id']) || empty($decoded['expires_at'])) {
            return response()->json(['message' => 'Invalid QR token.'], 422);
        }

        if ((int) $decoded['expires_at'] < now()->timestamp) {
            return response()->json(['message' => 'QR token expired.'], 422);
        }

        $order = Order::find($decoded['order_id']);

        if (! $order || $order->order_type !== 'pickup') {
            return response()->json(['message' => 'Order not eligible for pickup.'], 422);
        }

        if ($order->pickup_qr_token !== $validated['token']) {
            return response()->json(['message' => 'QR token mismatch.'], 422);
        }

        if ($order->status === 'completed') {
            return response()->json(['message' => 'Order already completed.'], 422);
        }

        $order->status = 'completed';
        $order->pickup_verified_at = now();

        if ($order->payment_method === 'cod' && $order->payment_status !== 'paid') {
            $order->payment_status = 'paid';
        }

        $order->save();

        return new OrderResource($order->load(['items', 'payments']));
    }

    private function generateOrderNumber(): string
    {
        return 'ORD-'.Str::upper(Str::random(6));
    }

    private function applyPaymentStatusTransition(Payment $payment, string $newStatus): ?string
    {
        $current = $payment->status;
        $allowed = [
            'pending' => ['processing'],
            'processing' => ['success', 'failed'],
            'success' => [],
            'failed' => [],
        ];

        if (! isset($allowed[$current])) {
            return 'Invalid current payment status.';
        }

        if (! in_array($newStatus, $allowed[$current], true)) {
            return "Invalid payment status transition: {$current} to {$newStatus}.";
        }

        $payment->status = $newStatus;
        if ($newStatus === 'success') {
            $payment->paid_at = now();
            Log::info('Payment marked success and pushed to payments system.', [
                'payment_id' => $payment->id,
                'order_id' => $payment->order_id,
            ]);
        }

        if ($newStatus === 'failed') {
            $payment->paid_at = null;
        }

        return null;
    }

    private function resolveUserId($actor, array $validated): ?int
    {
        if (! $actor) {
            return $validated['user_id'] ?? null;
        }

        if (method_exists($actor, 'isAdmin') && $actor->isAdmin()) {
            return $validated['user_id'] ?? $actor->id;
        }

        return $actor->id;
    }
}

