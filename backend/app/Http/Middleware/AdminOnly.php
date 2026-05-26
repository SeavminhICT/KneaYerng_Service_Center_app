<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AdminOnly
{
    /**
     * @param  \Closure(\Illuminate\Http\Request): \Symfony\Component\HttpFoundation\Response  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user()
            ?? $request->user('sanctum')
            ?? auth('web')->user();

        if (! $user) {
            return $this->unauthenticated($request);
        }

        if (! $user->isAdmin()) {
            return $this->forbidden($request);
        }

        return $next($request);
    }

    private function forbidden(Request $request): Response
    {
        if ($request->expectsJson()) {
            return response()->json(['message' => 'Forbidden.'], 403);
        }

        abort(403);
    }

    private function unauthenticated(Request $request): Response
    {
        if ($request->expectsJson()) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        abort(401);
    }
}
