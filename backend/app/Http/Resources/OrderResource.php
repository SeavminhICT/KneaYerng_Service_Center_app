<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class OrderResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'order_number' => $this->order_number,
            'customer_name' => $this->customer_name,
            'customer_email' => $this->customer_email,
            'order_type' => $this->order_type,
            'payment_method' => $this->payment_method,
            'delivery_address' => $this->delivery_address,
            'delivery_phone' => $this->delivery_phone,
            'total_amount' => $this->total_amount,
            'payment_status' => $this->payment_status,
            'status' => $this->status,
            'placed_at' => $this->placed_at?->toISOString(),
            'pickup_qr_generated_at' => $this->pickup_qr_generated_at?->toISOString(),
            'pickup_verified_at' => $this->pickup_verified_at?->toISOString(),
            'items' => OrderItemResource::collection($this->whenLoaded('items')),
            'payments' => PaymentResource::collection($this->whenLoaded('payments')),
            'created_at' => $this->created_at?->toISOString(),
        ];
    }
}

