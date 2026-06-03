<?php

namespace App\Observers;

use App\Models\Order;
use App\Services\ProductWarrantyService;

class OrderObserver
{
    public function __construct(private ProductWarrantyService $warrantyService)
    {
    }

    public function updated(Order $order): void
    {
        // Trigger 1: order marked "completed" (pickup QR verified) or "delivered" (delivery order)
        if ($order->wasChanged('status') && in_array($order->status, ['completed', 'delivered'], true)) {
            $this->warrantyService->createForOrder($order);
            return;
        }

        // Trigger 2: pickup order — QR code scanned at store (pickup_verified_at set)
        if ($order->wasChanged('pickup_verified_at') && $order->pickup_verified_at !== null) {
            $this->warrantyService->createForOrder($order);
        }
    }
}
