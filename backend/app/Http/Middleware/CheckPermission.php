<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckPermission
{
    /**
     * @param  \Closure(\Illuminate\Http\Request): \Symfony\Component\HttpFoundation\Response  $next
     */
    /**
     * Multiple permissions act as OR: the request passes when the user holds
     * at least one of them.
     */
    public function handle(Request $request, Closure $next, string ...$permissions): Response
    {
        $user = $request->user()
            ?? $request->user('sanctum')
            ?? auth('web')->user();

        if (! $user) {
            if ($request->expectsJson()) {
                return response()->json(['message' => 'Unauthenticated.'], 401);
            }

            return redirect()->route('login');
        }

        if (! $user->hasAnyPermission(...$permissions)) {
            $message = 'Access Denied. Missing permission: '.implode(' or ', $permissions);

            if ($request->expectsJson()) {
                return response()->json(['message' => $message], 403);
            }

            abort(403, $message);
        }

        return $next($request);
    }
}
