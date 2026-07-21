<section class="space-y-5">
    <header class="space-y-1">
        <h2 class="text-base font-bold text-slate-900 dark:text-white flex items-center gap-2">
            <svg class="h-4 w-4 text-primary-600 dark:text-primary-400" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/></svg>
            {{ __('Update Password') }}
        </h2>
        <p class="text-xs text-slate-500 dark:text-slate-400">
            {{ __('Ensure your account uses a long, complex password to stay secure.') }}
        </p>
    </header>

    <form method="post" action="{{ route('password.update') }}" class="space-y-4 max-w-xl">
        @csrf
        @method('put')

        <div>
            <label for="update_password_current_password" class="text-xs font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400 block mb-1">{{ __('Current Password') }}</label>
            <input
                id="update_password_current_password"
                name="current_password"
                type="password"
                class="h-10 block w-full rounded-xl border border-slate-200 bg-white px-3.5 text-sm font-medium text-slate-900 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900 dark:text-white transition-all"
                autocomplete="current-password"
            />
            <x-input-error :messages="$errors->updatePassword->get('current_password')" class="mt-1.5" />
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
                <label for="update_password_password" class="text-xs font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400 block mb-1">{{ __('New Password') }}</label>
                <input
                    id="update_password_password"
                    name="password"
                    type="password"
                    class="h-10 block w-full rounded-xl border border-slate-200 bg-white px-3.5 text-sm font-medium text-slate-900 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900 dark:text-white transition-all"
                    autocomplete="new-password"
                />
                <x-input-error :messages="$errors->updatePassword->get('password')" class="mt-1.5" />
            </div>

            <div>
                <label for="update_password_password_confirmation" class="text-xs font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400 block mb-1">{{ __('Confirm Password') }}</label>
                <input
                    id="update_password_password_confirmation"
                    name="password_confirmation"
                    type="password"
                    class="h-10 block w-full rounded-xl border border-slate-200 bg-white px-3.5 text-sm font-medium text-slate-900 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900 dark:text-white transition-all"
                    autocomplete="new-password"
                />
                <x-input-error :messages="$errors->updatePassword->get('password_confirmation')" class="mt-1.5" />
            </div>
        </div>

        <div class="flex items-center gap-3 pt-2">
            <button type="submit" class="inline-flex h-10 items-center gap-2 rounded-xl bg-primary-600 px-5 text-xs font-bold text-white shadow-sm hover:bg-primary-700 active:scale-95 transition-all">
                <svg class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/></svg>
                {{ __('Update Password') }}
            </button>

            @if (session('status') === 'password-updated')
                <span
                    x-data="{ show: true }"
                    x-show="show"
                    x-transition
                    x-init="setTimeout(() => show = false, 2500)"
                    class="inline-flex items-center gap-1 text-xs font-bold text-emerald-600 dark:text-emerald-400"
                >
                    ✓ {{ __('Saved.') }}
                </span>
            @endif
        </div>
    </form>
</section>
