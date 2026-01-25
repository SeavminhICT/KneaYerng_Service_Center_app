<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CartResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $items = $this->relationLoaded('items') ? $this->items : collect();
        $subtotal = $items->sum('line_total');

        return [
            'id' => $this->id,
            'user_id' => $this->user_id,
            'subtotal' => $subtotal,
            'items' => CartItemResource::collection($items),
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
