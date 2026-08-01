<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProductTypeResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'slug' => $this->slug,
            'fields' => $this->normalizedFields(),
            'required_fields' => $this->normalizedRequiredFields(),
            'sort_order' => (int) $this->sort_order,
            'products_count' => $this->when(isset($this->products_count), $this->products_count),
        ];
    }
}
