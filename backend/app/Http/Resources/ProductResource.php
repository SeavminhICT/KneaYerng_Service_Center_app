<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProductResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $primaryImage = $this->firstNonEmptyPath($this->thumbnail, $this->image);
        $gallery = is_array($this->image_gallery) ? $this->image_gallery : [];
        $baseUrl = $this->resolveBaseUrl($request);
        $variants = $this->whenLoaded(
            'variants',
            function () use ($baseUrl) {
                return $this->variants
                    ->map(function ($variant) use ($baseUrl) {
                        $storage = trim((string) ($variant->storage_capacity ?? ''));
                        $color = trim((string) ($variant->color ?? ''));
                        $condition = trim((string) ($variant->condition ?? ''));
                        $label = implode(' / ', array_values(array_filter([$storage, $color, $condition])));

                        return [
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
                            'sort_order' => (int) $variant->sort_order,
                            'label' => $label,
                        ];
                    })
                    ->values()
                    ->all();
            },
            []
        );

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
            'image_gallery' => array_map(fn ($image) => $this->formatMediaUrl($image, $baseUrl), $gallery),
            'storage_capacity' => $this->storage_capacity,
            'color' => $this->color,
            'condition' => $this->condition,
            'ram' => $this->ram,
            'ssd' => $this->ssd,
            'cpu' => $this->cpu,
            'display' => $this->display,
            'country' => $this->country,
            'variants' => $variants,
            'category' => $this->whenLoaded('category', fn () => [
                'id' => $this->category?->id,
                'name' => $this->category?->name,
            ]),
            'created_at' => $this->created_at?->toISOString(),
        ];
    }

    private function firstNonEmptyPath(?string ...$paths): ?string
    {
        foreach ($paths as $path) {
            if (is_string($path) && trim($path) !== '') {
                return $path;
            }
        }

        return null;
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

        $path = trim($path);
        $path = str_replace('\\', '/', $path);
        $path = rtrim($path, '/');

        if ($path === '') {
            return null;
        }

        if (str_starts_with($path, 'http://') || str_starts_with($path, 'https://')) {
            $parsedPath = parse_url($path, PHP_URL_PATH);
            if (is_string($parsedPath)) {
                $path = $parsedPath;
            }
        }

        $path = ltrim($path, '/');

        if (config('filesystems.default') === 's3') {
            $cleanPath = $path;
            if (str_starts_with($cleanPath, 'public/storage/')) {
                $cleanPath = substr($cleanPath, strlen('public/storage/'));
            } elseif (str_starts_with($cleanPath, 'storage/')) {
                $cleanPath = substr($cleanPath, strlen('storage/'));
            }
            $cleanPath = ltrim(preg_replace('/\/{2,}/', '/', $cleanPath), '/');
            return $baseUrl.'/api/media/'.$cleanPath;
        }

        if (str_starts_with($path, 'public/storage/')) {
            $path = substr($path, strlen('public/'));
        }
        if (! str_starts_with($path, 'storage/')) {
            $path = 'storage/'.$path;
        }

        return '/'.$path;
    }
}
