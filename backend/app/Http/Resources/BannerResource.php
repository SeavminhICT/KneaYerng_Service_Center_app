<?php

namespace App\Http\Resources;

use App\Http\Resources\Concerns\FormatsMediaUrl;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class BannerResource extends JsonResource
{
    use FormatsMediaUrl;

    public function toArray(Request $request): array
    {
        $baseUrl = $this->resolveBaseUrl($request);

        return [
            'id' => $this->id,
            'image' => $this->formatMediaUrl($this->image, $baseUrl),
            'badge_label' => $this->badge_label,
            'title' => $this->title,
            'subtitle' => $this->subtitle,
            'cta_label' => $this->cta_label,
            'created_at' => $this->created_at?->toISOString(),
        ];
    }
}
