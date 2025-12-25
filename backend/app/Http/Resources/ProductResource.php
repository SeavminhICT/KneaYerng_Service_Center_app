<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProductResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'description' => $this->description,
            'sku' => $this->sku,
            'price' => $this->price,
            'discount' => $this->discount,
            'stock' => $this->stock,
            'status' => $this->status,
            'brand' => $this->brand,
            'thumbnail' => $this->thumbnail ?? $this->image,
            'image' => $this->thumbnail ?? $this->image,
            'image_gallery' => $this->image_gallery,
            'storage_capacity' => $this->storage_capacity,
            'color' => $this->color,
            'condition' => $this->condition,
            'category' => $this->whenLoaded('category', fn () => [
                'id' => $this->category?->id,
                'name' => $this->category?->name,
            ]),
            'created_at' => $this->created_at?->toISOString(),
        ];
    }
}

