<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\Response;

class MediaController extends Controller
{
    public function __invoke(Request $request, string $path)
    {
        $clean = trim(str_replace('\\', '/', $path), '/');

        if ($clean === '' || str_contains($clean, '..')) {
            abort(404);
        }

        if (str_starts_with($clean, 'storage/')) {
            $clean = substr($clean, strlen('storage/'));
        }

        if (str_starts_with($clean, 'public/storage/')) {
            $clean = substr($clean, strlen('public/storage/'));
        }

        $disk = Storage::disk('public');
        if (! $disk->exists($clean)) {
            abort(404);
        }

        $mime = $disk->mimeType($clean) ?: 'application/octet-stream';
        $size = $disk->size($clean);
        $content = $disk->get($clean);

        return response($content, Response::HTTP_OK, [
            'Content-Type' => $mime,
            'Content-Length' => (string) $size,
            'Content-Disposition' => 'inline; filename="'.basename($clean).'"',
            'Cache-Control' => 'public, max-age=86400',
        ]);
    }
}
