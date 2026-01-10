<x-guest-layout>
    <div class="space-y-6">
        <div>
            <h1 class="text-2xl font-semibold text-slate-900 dark:text-white">Welcome back</h1>
            <p class="mt-2 text-sm text-slate-500">Sign in to manage orders, products, and admin workflows.</p>
        </div>

        <x-auth-session-status class="mb-4" :status="session('status')" />

        <form method="POST" action="{{ route('login') }}" class="space-y-5">
            @csrf

            <div>
                <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="email">Email address</label>
                <input id="email" name="email" type="email" value="{{ old('email') }}" required autofocus autocomplete="username" placeholder="you@example.com" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                <x-input-error :messages="$errors->get('email')" class="mt-2" />
            </div>

            <div>
                <div class="flex items-center justify-between">
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="password">Password</label>
                    @if (Route::has('password.request'))
                        <a class="text-xs font-semibold text-primary-600" href="{{ route('password.request') }}">
                            Forgot password?
                        </a>
                    @endif
                </div>
                <input id="password" name="password" type="password" required autocomplete="current-password" placeholder="••••••••" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                <x-input-error :messages="$errors->get('password')" class="mt-2" />
            </div>

            <label class="flex items-center gap-2 text-sm text-slate-600 dark:text-slate-300">
                <input id="remember_me" name="remember" type="checkbox" class="rounded border-slate-300 text-primary-600 shadow-sm focus:ring-primary-500" />
                Remember me for 30 days
            </label>

            <button type="submit" class="inline-flex h-11 w-full items-center justify-center rounded-xl bg-primary-600 text-sm font-semibold text-white shadow-sm">Sign in</button>
        </form>

        <div class="rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-xs text-slate-500 dark:border-slate-800 dark:bg-slate-950">
            Admin access is protected by `auth` + `admin` middleware. Use an authorized admin email.
        </div>
    </div>
</x-guest-layout>
