<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\BinaryFileResponse;
use Symfony\Component\HttpFoundation\StreamedResponse;

class ETagMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @return mixed
     */
    public function handle(Request $request, Closure $next)
    {
        // Only hash GET or HEAD requests
        if (!$request->isMethod('GET') && !$request->isMethod('HEAD')) {
            return $next($request);
        }

        $response = $next($request);

        // Do not process streamed or binary file responses to avoid buffering files in memory
        if ($response instanceof StreamedResponse || $response instanceof BinaryFileResponse) {
            return $response;
        }

        if ($response->isSuccessful()) {
            $content = $response->getContent();
            if ($content !== false && strlen($content) > 0) {
                $etag = md5($content);
                $response->headers->set('ETag', '"' . $etag . '"');

                $ifNoneMatch = $request->header('If-None-Match');
                if ($ifNoneMatch) {
                    $cleanIfNoneMatch = trim($ifNoneMatch, '"');
                    if ($cleanIfNoneMatch === $etag) {
                        $response->setStatusCode(304);
                        $response->setContent('');
                    }
                }
            }
        }

        return $response;
    }
}
