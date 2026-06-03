<?php

namespace App\Providers;

use App\Models\Order;
use App\Models\User;
use App\Observers\OrderObserver;
use App\Support\AuthRedirect;
use Illuminate\Auth\Middleware\RedirectIfAuthenticated;
use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Gate;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Order::observe(OrderObserver::class);

        Gate::define('admin-access', function (User $user): bool {
            return $user->isAdmin();
        });

        RedirectIfAuthenticated::redirectUsing(function ($request) {
            return AuthRedirect::destination($request->user());
        });

        // Override the S3/public disk URL at runtime so it always points to the
        // current server — regardless of what AWS_URL is in the config cache.
        // This fixes "image unknown" caused by a stale ngrok URL in config:cache.
        if (! $this->app->runningInConsole()) {
            $request   = $this->app->make('request');
            $mediaBase = rtrim($request->getSchemeAndHttpHost(), '/') . '/api/media';
            config(['filesystems.disks.s3.url'     => $mediaBase]);
            config(['filesystems.disks.public.url' => $mediaBase]);
        }
    }
}
