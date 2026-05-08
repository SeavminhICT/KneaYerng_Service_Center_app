<section class="space-y-6">
    <header class="space-y-2">
        <h2 class="text-xl font-semibold text-slate-900 dark:text-slate-100">
            {{ __('Update Password') }}
        </h2>

        <p class="text-sm text-slate-600 dark:text-slate-400">
            {{ __('Ensure your account is using a long, random password to stay secure.') }}
        </p>
    </header>

    <form method="post" action="{{ route('password.update') }}" class="space-y-5">
        @csrf
        @method('put')

        <div>
            <x-input-label for="update_password_current_password" :value="__('Current Password')" class="text-xs font-semibold uppercase tracking-wide text-slate-600 dark:text-slate-300" />
            <x-text-input
                id="update_password_current_password"
                name="current_password"
                type="password"
                class="mt-2 block w-full rounded-xl border-slate-300/90 px-4 py-3 text-sm text-slate-900 focus:border-sky-500 focus:ring-sky-500 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-100"
                autocomplete="current-password"
            />
            <x-input-error :messages="$errors->updatePassword->get('current_password')" class="mt-2" />
        </div>

        <div>
            <x-input-label for="update_password_password" :value="__('New Password')" class="text-xs font-semibold uppercase tracking-wide text-slate-600 dark:text-slate-300" />
            <x-text-input
                id="update_password_password"
                name="password"
                type="password"
                class="mt-2 block w-full rounded-xl border-slate-300/90 px-4 py-3 text-sm text-slate-900 focus:border-sky-500 focus:ring-sky-500 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-100"
                autocomplete="new-password"
            />
            <x-input-error :messages="$errors->updatePassword->get('password')" class="mt-2" />
        </div>

        <div>
            <x-input-label for="update_password_password_confirmation" :value="__('Confirm Password')" class="text-xs font-semibold uppercase tracking-wide text-slate-600 dark:text-slate-300" />
            <x-text-input
                id="update_password_password_confirmation"
                name="password_confirmation"
                type="password"
                class="mt-2 block w-full rounded-xl border-slate-300/90 px-4 py-3 text-sm text-slate-900 focus:border-sky-500 focus:ring-sky-500 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-100"
                autocomplete="new-password"
            />
            <x-input-error :messages="$errors->updatePassword->get('password_confirmation')" class="mt-2" />
        </div>

        <div class="flex items-center gap-4 pt-1">
            <x-primary-button class="rounded-xl bg-sky-600 px-5 py-2.5 text-[11px] hover:bg-sky-500 focus:bg-sky-600 active:bg-sky-700 dark:bg-sky-500 dark:text-white dark:hover:bg-sky-400 dark:focus:bg-sky-500 dark:active:bg-sky-600">
                {{ __('Update Password') }}
            </x-primary-button>

            @if (session('status') === 'password-updated')
                <p
                    x-data="{ show: true }"
                    x-show="show"
                    x-transition
                    x-init="setTimeout(() => show = false, 2000)"
                    class="text-sm font-medium text-emerald-600 dark:text-emerald-400"
                >{{ __('Saved.') }}</p>
            @endif
        </div>
    </form>
</section>
