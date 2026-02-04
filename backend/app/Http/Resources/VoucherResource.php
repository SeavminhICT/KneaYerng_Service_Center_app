<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class VoucherResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'code' => $this->code,
            'name' => $this->name,
            'discount_type' => $this->discount_type,
            'discount_value' => $this->discount_value !== null ? (float) $this->discount_value : 0,
            'min_order_amount' => $this->min_order_amount !== null ? (float) $this->min_order_amount : 0,
            'starts_at' => $this->starts_at?->toISOString(),
            'expires_at' => $this->expires_at?->toISOString(),
            'usage_limit_total' => $this->usage_limit_total,
            'usage_limit_per_user' => $this->usage_limit_per_user,
            'is_active' => (bool) $this->is_active,
            'is_stackable' => (bool) $this->is_stackable,
            'description' => $this->description,
            'redemptions_count' => $this->when(isset($this->redemptions_count), $this->redemptions_count),
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
