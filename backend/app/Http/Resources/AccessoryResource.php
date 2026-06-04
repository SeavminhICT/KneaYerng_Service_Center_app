<?php

namespace App\Http\Resources;

use App\Http\Resources\Concerns\FormatsMediaUrl;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AccessoryResource extends JsonResource
{
    use FormatsMediaUrl;

    public function toArray(Request $request): array
    {
        $price = $this->price ?? 0;
        $discount = $this->discount ?? 0;
        $baseUrl = $this->resolveBaseUrl($request);

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
            'image' => $this->formatMediaUrl($this->image, $baseUrl),
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
