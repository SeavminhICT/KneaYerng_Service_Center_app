<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class RemoveBgService
{
    public function isEnabled(): bool
    {
        return (bool) config('services.remove_bg.enabled')
            && filled(config('services.remove_bg.api_key'));
    }

    /**
     * Send raw image bytes to remove.bg and return the background-removed
     * PNG bytes. Returns null when disabled, unconfigured, or on failure —
     * callers should fall back to the original image in that case.
     */
    public function removeBackground(string $imageContents): ?string
    {
        if (! $this->isEnabled() || $imageContents === '') {
            return null;
        }

        try {
            $response = Http::withHeaders([
                'X-Api-Key' => config('services.remove_bg.api_key'),
            ])
                ->timeout((int) config('services.remove_bg.timeout', 30))
                ->attach('image_file', $imageContents, 'image.png')
                ->post(config('services.remove_bg.base_url'), [
                    'size' => config('services.remove_bg.size', 'auto'),
                    'format' => 'png',
                ]);

            if ($response->successful()) {
                return $response->body();
            }

            Log::warning('remove.bg request failed.', [
                'status' => $response->status(),
                'body' => $response->body(),
            ]);
        } catch (\Throwable $e) {
            Log::warning('remove.bg request error.', ['error' => $e->getMessage()]);
        }

        return null;
    }
}
