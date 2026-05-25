<?php

namespace App\Events;

use App\Models\Order;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class AdminOrderCreated implements ShouldBroadcastNow
{
    use Dispatchable, SerializesModels;

    public array $order;

    public function __construct(Order $order)
    {
        $orderNumber = $order->order_number ?: ('#'.$order->id);
        $customerName = $order->customer_name ?: 'Customer';

        $this->order = [
            'id' => $order->id,
            'order_number' => $order->order_number,
            'customer_name' => $order->customer_name,
            'total_amount' => (float) ($order->total_amount ?? 0),
            'payment_status' => $order->payment_status,
            'status' => $order->status,
            'placed_at' => $order->placed_at?->toISOString(),
            'created_at' => $order->created_at?->toISOString(),
            'message' => "New order {$orderNumber} from {$customerName}",
        ];
    }

    public function broadcastOn(): array
    {
        return [new PrivateChannel('admin.notifications')];
    }

    public function broadcastAs(): string
    {
        return 'admin.order.created';
    }
}
