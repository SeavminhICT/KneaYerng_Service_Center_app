<?php

namespace App\Http\Resources;

use App\Http\Resources\Concerns\FormatsMediaUrl;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CartItemResource extends JsonResource
{
    use FormatsMediaUrl;

    public function toArray(Request $request): array
    {
        $product = $this->relationLoaded('product') ? $this->product : null;
        $variant = $this->relationLoaded('productVariant') ? $this->productVariant : null;
        $baseUrl = $this->resolveBaseUrl($request);

        return [
            'id' => $this->id,
            'product_id' => $this->product_id,
            'item_type' => $this->item_type,
            'item_id' => $this->item_id,
            'product_variant_id' => $this->product_variant_id,
            'variant_label' => $this->variant_label,
            'product_name' => $this->product_name,
            'unit_price' => $this->unit_price,
            'quantity' => $this->quantity,
            'line_total' => $this->line_total,
            'product' => $product
                ? (new ProductResource($product))->toArray($request)
                : [
                    'id' => $this->item_id ?? $this->product_id,
                    'name' => $this->product_name,
                    'price' => $this->unit_price,
                ],
            'product_variant' => $variant ? [
                'id' => $variant->id,
                'storage_capacity' => $variant->storage_capacity,
                'color' => $variant->color,
                'condition' => $variant->condition,
                'ram' => $variant->ram,
                'ssd' => $variant->ssd,
                'price' => (float) $variant->price,
                'stock' => (int) $variant->stock,
                'sku' => $variant->sku,
                'image' => $this->formatMediaUrl($variant->image, $baseUrl),
                'is_active' => (bool) $variant->is_active,
                'label' => $variant->label(),
            ] : null,
        ];
    }
}
