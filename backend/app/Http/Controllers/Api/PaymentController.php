<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\PaymentResource;
use App\Models\Order;
use App\Models\Payment;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class PaymentController extends Controller
{
    public function store(Request $request)
    {
        $validated = $request->validate([
            'order_id' => ['required', 'exists:orders,id'],
            'method' => ['required', 'in:bank,cash'],
            'provider' => ['nullable', 'string', 'max:50'],
            'transaction_id' => ['nullable', 'string', 'max:255'],
            'amount' => ['required', 'numeric', 'min:0'],
        ]);

        $order = Order::findOrFail($validated['order_id']);
        $actor = $request->user() ?? $request->user('sanctum');

        if ($actor && method_exists($actor, 'isAdmin') && ! $actor->isAdmin()) {
            if ((int) $order->user_id !== (int) $actor->id) {
                return response()->json(['message' => 'Forbidden.'], 403);
            }
        }

        $status = $validated['method'] === 'bank' ? 'processing' : 'pending';

        $payment = Payment::create([
            'order_id' => $order->id,
            'method' => $validated['method'],
            'status' => $status,
            'transaction_id' => $validated['transaction_id'] ?? null,
            'provider' => $validated['provider'] ?? null,
            'amount' => $validated['amount'],
        ]);

        $order->payment_method = $validated['method'];
        $order->payment_status = $status;
        $order->save();

        Log::info('Payment created via API.', [
            'payment_id' => $payment->id,
            'order_id' => $order->id,
            'status' => $payment->status,
            'method' => $payment->method,
        ]);

        return response()->json([
            'payment' => new PaymentResource($payment),
            'order_payment_status' => $order->payment_status,
        ]);
    }

    public function callback(Request $request)
    {
        $secret = config('services.payment.callback_secret');
        $signature = $request->header('X-Signature') ?? $request->input('signature');

        if ($secret && ! $signature) {
            return response()->json(['message' => 'Missing signature.'], 403);
        }

        if ($secret && $signature) {
            $expected = hash_hmac('sha256', $request->getContent(), $secret);

            if (! hash_equals($expected, $signature)) {
                return response()->json(['message' => 'Invalid signature.'], 403);
            }
        }

        $validated = $request->validate([
            'order_id' => ['required', 'exists:orders,id'],
            'status' => ['required', 'in:success,failed'],
            'transaction_id' => ['required', 'string', 'max:255'],
            'provider' => ['nullable', 'string', 'max:50'],
            'amount' => ['nullable', 'numeric', 'min:0'],
        ]);

        $payment = Payment::where('transaction_id', $validated['transaction_id'])->first();

        if (! $payment) {
            $payment = Payment::create([
                'order_id' => $validated['order_id'],
                'method' => 'bank',
                'status' => 'processing',
                'transaction_id' => $validated['transaction_id'],
                'provider' => $validated['provider'] ?? null,
                'amount' => $validated['amount'] ?? 0,
                'callback_payload' => $request->all(),
                'paid_at' => null,
            ]);
        }

        $transitionError = $this->applyPaymentStatusTransition($payment, $validated['status']);
        if ($transitionError) {
            Log::warning('Payment callback rejected.', [
                'payment_id' => $payment->id,
                'order_id' => $payment->order_id,
                'from' => $payment->status,
                'to' => $validated['status'],
                'error' => $transitionError,
            ]);
            return response()->json(['message' => $transitionError], 422);
        }

        $payment->provider = $validated['provider'] ?? $payment->provider;
        $payment->callback_payload = $request->all();
        $payment->save();

        $order = Order::find($validated['order_id']);

        if ($order) {
            $order->payment_status = $payment->status;
            $order->save();
        }

        if ($payment->status === 'success') {
            Log::info('Payment pushed to payments system.', [
                'payment_id' => $payment->id,
                'order_id' => $payment->order_id,
            ]);
        }

        return response()->json([
            'payment' => new PaymentResource($payment),
            'order_payment_status' => $order?->payment_status,
        ]);
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
        }

        if ($newStatus === 'failed') {
            $payment->paid_at = null;
        }

        return null;
    }
}
