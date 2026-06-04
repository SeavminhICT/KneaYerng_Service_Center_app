<?php

namespace App\Http\Resources;

use App\Http\Resources\Concerns\FormatsMediaUrl;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CategoryResource extends JsonResource
{
    use FormatsMediaUrl;

    public function toArray(Request $request): array
    {
        $baseUrl = $this->resolveBaseUrl($request);

        return [
            'id' => $this->id,
            'name' => $this->name,
            'slug' => $this->slug,
            'image' => $this->formatMediaUrl($this->image, $baseUrl),
            'sort_order' => $this->sort_order,
            'status' => $this->status,
            'products_count' => $this->when(isset($this->products_count), $this->products_count),
            'created_at' => $this->created_at?->toISOString(),
        ];
    }
}
