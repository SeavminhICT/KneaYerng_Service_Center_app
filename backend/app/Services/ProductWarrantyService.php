<?php

namespace App\Services;

use App\Models\Order;
use App\Models\OrderItem;
use App\Models\ProductWarranty;
use Carbon\Carbon;

class ProductWarrantyService
{
    private const PERIOD_DAYS = [
        'NO_WARRANTY' => 0,
        '1_DAYS'      => 1,
        '7_DAYS'      => 7,
        '14_DAYS'     => 14,
        '1_MONTH'     => 30,
        '3_MONTHS'    => 90,
        '6_MONTHS'    => 180,
        '1_YEAR'      => 365,
    ];

    public const PERIOD_LABELS = [
        'NO_WARRANTY' => 'No Warranty',
        '1_DAYS'      => '1 Day',
        '7_DAYS'      => '7 Days',
        '14_DAYS'     => '14 Days',
        '1_MONTH'     => '1 Month',
        '3_MONTHS'    => '3 Months',
        '6_MONTHS'    => '6 Months',
        '1_YEAR'      => '1 Year',
    ];

    /**
     * Create warranty records for all eligible items in a completed order.
     * Uses the real completion date as warranty start.
     * Safe to call multiple times — uses updateOrCreate on order_item_id.
     */
    public function createForOrder(Order $order): int
    {
        if (! $order->user_id) {
            return 0;
        }

        // Determine the real completion date
        $startDate = $this->resolveCompletionDate($order);
        $created   = 0;

        $items = $order->items()->with('product')->get();

        foreach ($items as $item) {
            $warrantyPeriod = $this->resolveWarrantyPeriod($item);

            if ($warrantyPeriod === 'NO_WARRANTY') {
                continue;
            }

            $days = self::PERIOD_DAYS[$warrantyPeriod] ?? 0;
            if ($days === 0) {
                continue;
            }

            $endDate = $startDate->copy()->addDays($days);

            ProductWarranty::updateOrCreate(
                ['order_item_id' => $item->id],
                [
                    'order_id'        => $order->id,
                    'user_id'         => $order->user_id,
                    'product_id'      => $item->product_id,
                    'product_name'    => $item->product_name ?? ($item->product?->name ?? 'Unknown Product'),
                    'variant_label'   => $item->variant_label,
                    'warranty_period' => $warrantyPeriod,
                    'duration_days'   => $days,
                    'start_date'      => $startDate->toDateString(),
                    'end_date'        => $endDate->toDateString(),
                    'status'          => 'active',
                ]
            );

            $created++;
        }

        return $created;
    }

    /**
     * Sync all missing warranty records for a specific user.
     * Catches orders that were completed before the observer was registered.
     */
    public function syncForUser(int $userId): void
    {
        // Find all completed/delivered orders that have at least one item without a warranty record
        $completedOrders = Order::query()
            ->where('user_id', $userId)
            ->where(function ($q) {
                $q->whereIn('status', ['completed', 'delivered'])
                  ->orWhereNotNull('pickup_verified_at');
            })
            ->whereHas('items', function ($q) {
                $q->whereNotExists(function ($sub) {
                    $sub->from('product_warranties')
                        ->whereColumn('product_warranties.order_item_id', 'order_items.id');
                });
            })
            ->with(['items.product'])
            ->get();

        foreach ($completedOrders as $order) {
            $this->createForOrder($order);
        }
    }

    /**
     * Determine when the warranty clock should start:
     * - pickup orders   → pickup_verified_at
     * - delivery orders → current_status_at (when status changed to 'completed')
     * - fallback        → today
     */
    private function resolveCompletionDate(Order $order): Carbon
    {
        if ($order->pickup_verified_at) {
            return Carbon::parse($order->pickup_verified_at)->startOfDay();
        }

        // Treat both 'completed' and 'delivered' as the warranty start
        if ($order->current_status_at && in_array($order->status, ['completed', 'delivered'], true)) {
            return Carbon::parse($order->current_status_at)->startOfDay();
        }

        return Carbon::now()->startOfDay();
    }

    private function resolveWarrantyPeriod(OrderItem $item): string
    {
        $product = $item->product;
        if ($product && ! empty($product->warranty)) {
            $period = strtoupper(trim($product->warranty));
            if (array_key_exists($period, self::PERIOD_DAYS)) {
                return $period;
            }
        }

        return 'NO_WARRANTY';
    }

    public static function periodDays(string $period): int
    {
        return self::PERIOD_DAYS[strtoupper($period)] ?? 0;
    }
}

