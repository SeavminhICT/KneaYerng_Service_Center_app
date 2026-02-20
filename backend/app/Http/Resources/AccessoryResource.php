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
        if (str_starts_with($path, 'public/storage/')) {
            $path = substr($path, strlen('public/'));
        }
        if (! str_starts_with($path, 'storage/')) {
            $path = 'storage/'.$path;
        }

        return '/'.$path;
    }
}
