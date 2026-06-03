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

        // 1. Try S3/R2 disk. Any connection failure (bad credentials, network
        //    error) falls through to the local-file fallback below.
        $disk   = null;
        $stream = null;
        $mime   = 'application/octet-stream';
        $size   = 0;

        try {
            $cloudDisk = Storage::disk('public');
            if ($cloudDisk->exists($clean)) {
                $stream = $cloudDisk->readStream($clean);
                if (is_resource($stream)) {
                    $mime = $cloudDisk->mimeType($clean) ?: 'application/octet-stream';
                    $size = $cloudDisk->size($clean);
                    $disk = $cloudDisk;
                }
            }
        } catch (\Throwable $e) {
            // R2 / S3 unreachable — try local storage below
        }

        // 2. Local fallback: files uploaded before cloud-storage migration live
        //    at storage/app/public/{path}.
        if ($disk === null) {
            $localAbsPath = storage_path('app/public/' . $clean);

            if (file_exists($localAbsPath) && is_file($localAbsPath)) {
                $mime = mime_content_type($localAbsPath) ?: 'application/octet-stream';
                return response()->file($localAbsPath, [
                    'Content-Type'        => $mime,
                    'Content-Disposition' => 'inline; filename="' . basename($clean) . '"',
                    'Cache-Control'       => 'public, max-age=86400',
                ]);
            }

            abort(404);
        }

        return response()->stream(
            function () use ($stream): void {
                fpassthru($stream);
                fclose($stream);
            },
            Response::HTTP_OK,
            [
                'Content-Type' => $mime,
                'Content-Length' => (string) $size,
                'Content-Disposition' => 'inline; filename="'.basename($clean).'"',
                'Cache-Control' => 'public, max-age=86400',
            ]
        );
    }
}
