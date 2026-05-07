<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class OrderItemResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'product_id' => $this->product_id,
            'item_type' => $this->item_type,
            'item_id' => $this->item_id,
            'product_variant_id' => $this->product_variant_id,
            'variant_label' => $this->variant_label,
            'product_name' => $this->product_name,
            'display_name' => trim(implode(' ', array_filter([
                $this->product_name,
                $this->variant_label ? '('.$this->variant_label.')' : null,
            ]))),
            'quantity' => $this->quantity,
            'unit_price' => $this->price,
            'price' => $this->price,
            'line_total' => $this->line_total ?? ($this->quantity * $this->price),
            'total' => $this->line_total ?? ($this->quantity * $this->price),
        ];
    }
}
