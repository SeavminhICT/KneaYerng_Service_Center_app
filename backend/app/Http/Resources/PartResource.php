<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PartResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'type' => $this->type,
            'brand' => $this->brand,
            'sku' => $this->sku,
            'stock' => $this->stock,
            'unit_cost' => $this->unit_cost,
            'price' => $this->unit_cost,
            'status' => $this->status,
            'created_at' => $this->created_at?->toISOString(),
        ];
    }
}
