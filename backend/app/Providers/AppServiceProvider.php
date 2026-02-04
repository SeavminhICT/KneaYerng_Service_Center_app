<?php

namespace App\Providers;

use App\Models\User;
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
        Gate::define('admin-access', function (User $user): bool {
            return $user->isAdmin();
        });

        RedirectIfAuthenticated::redirectUsing(function ($request) {
            return AuthRedirect::destination($request->user());
        });
    }
}
