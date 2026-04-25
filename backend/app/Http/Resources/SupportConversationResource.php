<?php

namespace App\Http\Resources;

use App\Models\Order;
use App\Models\RepairRequest;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SupportConversationResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'customer_id' => $this->customer_id,
            'assigned_to' => $this->assigned_to,
            'status' => $this->status,
            'context_type' => $this->context_type,
            'context_id' => $this->context_id,
            'subject' => $this->subject,
            'context_summary' => $this->buildContextSummary(),
            'last_message_at' => $this->last_message_at?->toISOString(),
            'customer_last_read_at' => $this->customer_last_read_at?->toISOString(),
            'support_last_read_at' => $this->support_last_read_at?->toISOString(),
            'resolved_at' => $this->resolved_at?->toISOString(),
            'unread_for_customer' => method_exists($this->resource, 'unreadForCustomerCount')
                ? $this->resource->unreadForCustomerCount()
                : 0,
            'unread_for_support' => method_exists($this->resource, 'unreadForSupportCount')
                ? $this->resource->unreadForSupportCount()
                : 0,
            'customer' => $this->whenLoaded('customer', function () {
                return [
                    'id' => $this->customer?->id,
                    'name' => $this->customer?->name,
                    'email' => $this->customer?->email,
                    'phone' => $this->customer?->phone,
                ];
            }),
            'assignee' => $this->whenLoaded('assignee', function () {
                return [
                    'id' => $this->assignee?->id,
                    'name' => $this->assignee?->name,
                    'email' => $this->assignee?->email,
                    'phone' => $this->assignee?->phone,
                    'role' => $this->assignee?->role,
                ];
            }),
            'latest_message' => $this->whenLoaded('latestMessage', function () {
                return new SupportMessageResource($this->latestMessage);
            }),
            'messages' => SupportMessageResource::collection($this->whenLoaded('messages')),
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }

    protected function buildContextSummary(): ?array
    {
        if (! $this->context_type || ! $this->context_id) {
            return [
                'type' => 'general',
                'label' => 'General',
                'title' => $this->subject ?: 'General support',
                'subtitle' => 'Customer support conversation',
                'status' => $this->status,
                'payment_status' => null,
                'eta' => null,
                'admin_url' => null,
            ];
        }

        if ($this->context_type === 'order') {
            $order = Order::query()->with('items')->find($this->context_id);

            if (! $order) {
                return null;
            }

            $firstItem = $order->items->first();

            return [
                'type' => 'order',
                'label' => $order->order_number ? 'Order #'.$order->order_number : 'Order #'.$order->id,
                'title' => $firstItem?->product_name ?: $order->customer_name ?: 'Order support',
                'subtitle' => $order->order_type ? ucfirst((string) $order->order_type) : 'Order',
                'status' => $order->status,
                'payment_status' => $order->payment_status,
                'eta' => $order->current_status_at?->toISOString(),
                'admin_url' => route('admin.orders.show', $order),
            ];
        }

        if ($this->context_type === 'repair') {
            $repair = RepairRequest::query()->find($this->context_id);

            if (! $repair) {
                return null;
            }

            return [
                'type' => 'repair',
                'label' => 'Repair #'.$repair->id,
                'title' => $repair->device_model ?: 'Repair support',
                'subtitle' => $repair->service_type ?: $repair->issue_type ?: 'Repair',
                'status' => $repair->status,
                'payment_status' => null,
                'eta' => $repair->appointment_datetime?->toISOString(),
                'admin_url' => route('admin.repairs.show', $repair),
            ];
        }

        return [
            'type' => (string) $this->context_type,
            'label' => ucfirst((string) $this->context_type).' #'.$this->context_id,
            'title' => $this->subject ?: 'Support context',
            'subtitle' => 'Linked conversation',
            'status' => $this->status,
            'payment_status' => null,
            'eta' => null,
            'admin_url' => null,
        ];
    }
}
