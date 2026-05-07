<?php

namespace App\Services;

use App\Models\Order;
use App\Models\Payment;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class OrderPaymentService
{
    public function markOrderPaid(
        Order $order,
        ?string $paymentMethod = null,
        array $paymentAttributes = []
    ): void {
        $wasPaid = $order->payment_status === 'paid';

        DB::transaction(function () use ($order, $paymentMethod, $paymentAttributes) {
            $order->refresh();
            $order->loadMissing('items', 'payments');

            $method = $paymentMethod ?: ($order->payment_method ?: 'aba');
            $amount = array_key_exists('amount', $paymentAttributes)
                ? (float) $paymentAttributes['amount']
                : (float) ($order->total_amount ?? 0);
            $transactionId = $paymentAttributes['transaction_id'] ?? null;
            $provider = $paymentAttributes['provider'] ?? null;
            $paidAt = $paymentAttributes['paid_at'] ?? now();

            $payment = $order->payments()->latest()->lockForUpdate()->first();
            if (! $payment) {
                $payment = new Payment([
                    'order_id' => $order->id,
                ]);
            }

            $payment->method = $method;
            $payment->status = 'success';
            $payment->transaction_id = $transactionId ?: $payment->transaction_id;
            $payment->provider = $provider ?: $payment->provider;
            $payment->amount = $amount;
            $payment->paid_at = $paidAt;
            $payment->save();

            $order->payment_method = $method;
            $order->payment_status = 'paid';
            app(OrderInventoryService::class)->deductInventoryForOrder($order);
            $order->save();
        });

        $order->refresh();

        if ($order->order_type === 'pickup') {
            try {
                app(PickupTicketService::class)->issueForOrder($order);
            } catch (\RuntimeException $exception) {
                Log::warning('Unable to issue pickup ticket after payment.', [
                    'order_id' => $order->id,
                    'message' => $exception->getMessage(),
                ]);
            }
        }

        if (! $wasPaid) {
            app(TelegramOrderService::class)->handlePaymentSuccess($order);
        }
    }
}
