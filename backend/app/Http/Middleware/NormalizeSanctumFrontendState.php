<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class NormalizeSanctumFrontendState
{
    /**
     * Ensure same-host browser API calls remain stateful for Sanctum.
     *
     * Some browsers / environments can omit Referer/Origin on same-origin
     * fetches, which causes Sanctum to skip session auth middleware and
     * admin API calls may return Forbidden.
     *
     * @param  \Closure(\Illuminate\Http\Request): \Symfony\Component\HttpFoundation\Response  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $this->appendCurrentHostToStatefulDomains($request);
        $this->injectRefererWhenSessionCookiesExist($request);

        return $next($request);
    }

    private function appendCurrentHostToStatefulDomains(Request $request): void
    {
        $host = strtolower((string) $request->getHttpHost());
        $hostname = strtolower((string) $request->getHost());

        if ($host === '' && $hostname === '') {
            return;
        }

        $stateful = collect((array) config('sanctum.stateful', []))
            ->map(fn ($value) => strtolower(trim((string) $value)))
            ->filter()
            ->values();

        foreach ([$host, $hostname] as $candidate) {
            if ($candidate === '' || $stateful->contains($candidate)) {
                continue;
            }
            $stateful->push($candidate);
        }

        config(['sanctum.stateful' => $stateful->all()]);
    }

    private function injectRefererWhenSessionCookiesExist(Request $request): void
    {
        if ($request->headers->has('referer') || $request->headers->has('origin')) {
            return;
        }

        $sessionCookieName = (string) config('session.cookie', 'laravel_session');
        $hasSessionCookie = $request->cookies->has($sessionCookieName);
        $hasXsrfCookie = $request->cookies->has('XSRF-TOKEN');

        if (! $hasSessionCookie && ! $hasXsrfCookie) {
            return;
        }

        $request->headers->set('referer', rtrim($request->getSchemeAndHttpHost(), '/').'/');
    }
}

