<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProductResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $primaryImage = $this->thumbnail ?? $this->image;
        $gallery = $this->image_gallery;
        $baseUrl = $this->resolveBaseUrl($request);

        return [
            'id' => $this->id,
            'name' => $this->name,
            'description' => $this->description,
            'sku' => $this->sku,
            'price' => $this->price,
            'discount' => $this->discount,
            'stock' => $this->stock,
            'status' => $this->status,
            'tag' => $this->tag,
            'brand' => $this->brand,
            'warranty' => $this->warranty,
            'thumbnail' => $this->formatMediaUrl($primaryImage, $baseUrl),
            'image' => $this->formatMediaUrl($primaryImage, $baseUrl),
            'image_gallery' => $gallery === null
                ? null
                : array_map(fn ($image) => $this->formatMediaUrl($image, $baseUrl), $gallery),
            'storage_capacity' => $this->storage_capacity,
            'color' => $this->color,
            'condition' => $this->condition,
            'ram' => $this->ram,
            'ssd' => $this->ssd,
            'cpu' => $this->cpu,
            'display' => $this->display,
            'country' => $this->country,
            'category' => $this->whenLoaded('category', fn () => [
                'id' => $this->category?->id,
                'name' => $this->category?->name,
            ]),
            'created_at' => $this->created_at?->toISOString(),
        ];
    }

    private function resolveBaseUrl(Request $request): string
    {
        $baseUrl = $request->getSchemeAndHttpHost();

        if (! $baseUrl) {
            $baseUrl = config('app.url', '');
        }

        return rtrim($baseUrl, '/');
    }

    private function formatMediaUrl(?string $path, string $baseUrl): ?string
    {
        if (! $path) {
            return null;
        }

        if (str_starts_with($path, 'http://') || str_starts_with($path, 'https://')) {
            return $path;
        }

        return $baseUrl.'/'.ltrim($path, '/');
    }
}
