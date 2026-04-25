<?php

namespace App\Services;

use App\Models\Accessory;
use App\Models\Order;
use App\Models\Part;
use App\Models\Payment;
use App\Models\Product;
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
            $this->deductInventoryForOrder($order);
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

    private function deductInventoryForOrder(Order $order): void
    {
        if ($order->inventory_deducted) {
            return;
        }

        $order->loadMissing('items');
        if ($order->items->isEmpty()) {
            $order->inventory_deducted = true;

            return;
        }

        $productIds = [];
        $accessoryIds = [];
        $partIds = [];

        foreach ($order->items as $item) {
            $itemType = strtolower((string) ($item->item_type ?: ($item->product_id ? 'product' : '')));
            $itemId = (int) ($item->item_id ?: $item->product_id ?: 0);

            if (! $itemId) {
                continue;
            }

            if ($itemType === 'accessory') {
                $accessoryIds[] = $itemId;
            } elseif ($itemType === 'part' || $itemType === 'repair_part') {
                $partIds[] = $itemId;
            } else {
                $productIds[] = $itemId;
            }
        }

        $products = Product::whereIn('id', array_values(array_unique($productIds)))
            ->lockForUpdate()
            ->get()
            ->keyBy('id');
        $accessories = Accessory::whereIn('id', array_values(array_unique($accessoryIds)))
            ->lockForUpdate()
            ->get()
            ->keyBy('id');
        $parts = Part::whereIn('id', array_values(array_unique($partIds)))
            ->lockForUpdate()
            ->get()
            ->keyBy('id');

        foreach ($order->items as $item) {
            $itemType = strtolower((string) ($item->item_type ?: ($item->product_id ? 'product' : '')));
            $itemId = (int) ($item->item_id ?: $item->product_id ?: 0);

            if (! $itemId) {
                continue;
            }

            [$catalogItem, $label] = match ($itemType) {
                'accessory' => [$accessories->get($itemId), 'Accessory'],
                'part', 'repair_part' => [$parts->get($itemId), 'Part'],
                default => [$products->get($itemId), 'Product'],
            };

            if (! $catalogItem) {
                throw new \RuntimeException($label.' not found for order item.');
            }

            if ($catalogItem->stock !== null && (int) $catalogItem->stock < (int) $item->quantity) {
                throw new \RuntimeException('Insufficient stock for '.$catalogItem->name.'.');
            }
        }

        foreach ($order->items as $item) {
            $itemType = strtolower((string) ($item->item_type ?: ($item->product_id ? 'product' : '')));
            $itemId = (int) ($item->item_id ?: $item->product_id ?: 0);

            if (! $itemId) {
                continue;
            }

            $catalogItem = match ($itemType) {
                'accessory' => $accessories->get($itemId),
                'part', 'repair_part' => $parts->get($itemId),
                default => $products->get($itemId),
            };

            if ($catalogItem && $catalogItem->stock !== null) {
                $catalogItem->decrement('stock', (int) $item->quantity);
            }
        }

        $order->inventory_deducted = true;
    }
}
