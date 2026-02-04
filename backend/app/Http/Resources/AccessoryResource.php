<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AccessoryResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $price = $this->price ?? 0;
        $discount = $this->discount ?? 0;

        return [
            'id' => $this->id,
            'brand' => $this->brand,
            'name' => $this->name,
            'price' => $this->price,
            'discount' => $this->discount,
            'final_price' => max($price - $discount, 0),
            'stock' => $this->stock,
            'tag' => $this->tag,
            'description' => $this->description,
            'warranty' => $this->warranty,
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
