<?php

namespace App\Http\Resources\Concerns;

use Illuminate\Http\Request;

trait FormatsMediaUrl
{
    protected function resolveBaseUrl(Request $request): string
    {
        $baseUrl = $request->getSchemeAndHttpHost();

        if (! $baseUrl) {
            $baseUrl = config('app.url', '');
        }

        return rtrim($baseUrl, '/');
    }

    /**
     * Always returns an /api/media/{path} URL so MediaController handles serving,
     * regardless of whether FILESYSTEM_DISK is local or s3. This avoids any
     * dependency on the public/storage symlink existing in the container.
     */
    protected function formatMediaUrl(?string $path, string $baseUrl): ?string
    {
        if (! $path) {
            return null;
        }

        $path = trim(str_replace('\\', '/', $path));
        $path = rtrim($path, '/');

        if ($path === '') {
            return null;
        }

        // Strip domain from full URLs stored in DB (e.g. https://server/api/media/categories/x.png)
        if (str_starts_with($path, 'http://') || str_starts_with($path, 'https://')) {
            $parsedPath = parse_url($path, PHP_URL_PATH);
            if (is_string($parsedPath)) {
                $path = $parsedPath;
            }
        }

        $path = ltrim($path, '/');

        // Strip any known prefix so we always have the bare storage key
        if (str_starts_with($path, 'public/storage/')) {
            $path = substr($path, strlen('public/storage/'));
        } elseif (str_starts_with($path, 'storage/')) {
            $path = substr($path, strlen('storage/'));
        } elseif (str_starts_with($path, 'api/media/')) {
            $path = substr($path, strlen('api/media/'));
        }

        // Collapse double slashes and strip any remaining leading slash
        $path = ltrim(preg_replace('/\/{2,}/', '/', $path), '/');

        if ($path === '') {
            return null;
        }

        return $baseUrl . '/api/media/' . $path;
    }
}
