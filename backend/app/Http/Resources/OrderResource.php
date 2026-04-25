<?php

namespace App\Http\Resources;

use App\Services\OrderTrackingService;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class OrderResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $expiresAt = $this->pickup_qr_expires_at;
        if (! $expiresAt && $this->pickup_qr_generated_at) {
            $expiresAt = $this->pickup_qr_generated_at->copy()->addHours(24);
        }

        $ticketId = null;
        if ($this->order_number) {
            $ticketId = 'TCK-'.$this->order_number;
        } elseif ($this->id) {
            $ticketId = 'TCK-'.$this->id;
        }

        $ticketStatus = null;
        if ($this->order_type === 'pickup' && $this->pickup_qr_token) {
            if ($this->pickup_verified_at) {
                $ticketStatus = 'used';
            } elseif ($expiresAt && $expiresAt->isPast()) {
                $ticketStatus = 'expired';
            } else {
                $ticketStatus = 'active';
            }
        }

        $trackingService = app(OrderTrackingService::class);
        $isTrackedDelivery = $trackingService->isTrackedDelivery($this->resource);
        $trackingHistories = $this->relationLoaded('trackingHistories')
            ? OrderTrackingHistoryResource::collection($this->trackingHistories)
            : [];
        $trackingTimeline = $isTrackedDelivery && $this->relationLoaded('trackingHistories')
            ? $trackingService->buildTimeline($this->resource)
            : [];

        return [
            'id' => $this->id,
            'order_number' => $this->order_number,
            'customer_name' => $this->customer_name,
            'customer_email' => $this->customer_email,
            'order_type' => $this->order_type,
            'assigned_staff_id' => $this->assigned_staff_id,
            'assigned_staff_name' => $this->assignedStaff?->name,
            'payment_method' => $this->payment_method,
            'delivery_address' => $this->delivery_address,
            'delivery_phone' => $this->delivery_phone,
            'delivery_note' => $this->delivery_note,
            'delivery_lat' => $this->delivery_lat,
            'delivery_lng' => $this->delivery_lng,
            'subtotal' => $this->subtotal,
            'delivery_fee' => $this->delivery_fee,
            'voucher_id' => $this->voucher_id,
            'voucher_code' => $this->voucher_code,
            'discount_type' => $this->discount_type,
            'discount_value' => $this->discount_value,
            'discount_amount' => $this->discount_amount,
            'total_amount' => $this->total_amount,
            'payment_status' => $this->payment_status,
            'status' => $this->status,
            'order_status' => $this->status,
            'current_status_at' => $this->current_status_at?->toISOString(),
            'approved_at' => $this->approved_at?->toISOString(),
            'approved_by' => $this->approved_by,
            'approved_by_name' => $this->approver?->name,
            'rejected_at' => $this->rejected_at?->toISOString(),
            'rejected_by' => $this->rejected_by,
            'rejected_by_name' => $this->rejector?->name,
            'rejected_reason' => $this->rejected_reason,
            'cancelled_at' => $this->cancelled_at?->toISOString(),
            'cancelled_by' => $this->cancelled_by,
            'cancelled_by_name' => $this->canceller?->name,
            'cancelled_reason' => $this->cancelled_reason,
            'inventory_deducted' => $this->inventory_deducted,
            'placed_at' => $this->placed_at?->toISOString(),
            'pickup_ticket_id' => $ticketId,
            'pickup_ticket_status' => $ticketStatus,
            'pickup_qr_token' => $this->pickup_qr_token,
            'pickup_qr_generated_at' => $this->pickup_qr_generated_at?->toISOString(),
            'pickup_qr_expires_at' => $expiresAt?->toISOString(),
            'pickup_verified_at' => $this->pickup_verified_at?->toISOString(),
            'pickup_verified_by' => $this->pickup_verified_by,
            'pickup_verified_by_name' => $this->pickupVerifier?->name,
            'tracking_timeline' => $trackingTimeline,
            'tracking_history' => $trackingHistories,
            'tracking_status_options' => $isTrackedDelivery
                ? $trackingService->allowedTransitions($this->resource, $request->user() ?? $request->user('sanctum'))
                : [],
            'items' => OrderItemResource::collection($this->whenLoaded('items')),
            'payments' => PaymentResource::collection($this->whenLoaded('payments')),
            'created_at' => $this->created_at?->toISOString(),
        ];
    }
}
