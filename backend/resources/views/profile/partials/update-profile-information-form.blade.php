<section class="space-y-6">
    <header class="space-y-2">
        <h2 class="text-xl font-semibold text-slate-900 dark:text-slate-100">
            {{ __('Profile Information') }}
        </h2>

        <p class="text-sm text-slate-600 dark:text-slate-400">
            {{ __("Update your account's profile information and email address.") }}
        </p>
    </header>

    <form id="send-verification" method="post" action="{{ route('verification.send') }}">
        @csrf
    </form>

    <form method="post" action="{{ route('profile.update') }}" class="space-y-5">
        @csrf
        @method('patch')

        <div>
            <x-input-label for="name" :value="__('Name')" class="text-xs font-semibold uppercase tracking-wide text-slate-600 dark:text-slate-300" />
            <x-text-input
                id="name"
                name="name"
                type="text"
                class="mt-2 block w-full rounded-xl border-slate-300/90 px-4 py-3 text-sm text-slate-900 focus:border-sky-500 focus:ring-sky-500 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-100"
                :value="old('name', $user->name)"
                required
                autofocus
                autocomplete="name"
            />
            <x-input-error class="mt-2" :messages="$errors->get('name')" />
        </div>

        <div>
            <x-input-label for="email" :value="__('Email')" class="text-xs font-semibold uppercase tracking-wide text-slate-600 dark:text-slate-300" />
            <x-text-input
                id="email"
                name="email"
                type="email"
                class="mt-2 block w-full rounded-xl border-slate-300/90 px-4 py-3 text-sm text-slate-900 focus:border-sky-500 focus:ring-sky-500 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-100"
                :value="old('email', $user->email)"
                required
                autocomplete="username"
            />
            <x-input-error class="mt-2" :messages="$errors->get('email')" />

            @if ($user instanceof \Illuminate\Contracts\Auth\MustVerifyEmail && ! $user->hasVerifiedEmail())
                <div>
                    <p class="mt-3 text-sm text-slate-700 dark:text-slate-300">
                        {{ __('Your email address is unverified.') }}

                        <button form="send-verification" class="font-semibold text-sky-700 underline underline-offset-2 hover:text-sky-900 focus:outline-none focus:ring-2 focus:ring-sky-500 focus:ring-offset-2 dark:text-sky-300 dark:hover:text-sky-200 dark:focus:ring-offset-slate-900">
                            {{ __('Click here to re-send the verification email.') }}
                        </button>
                    </p>

                    @if (session('status') === 'verification-link-sent')
                        <p class="mt-2 text-sm font-medium text-emerald-600 dark:text-emerald-400">
                            {{ __('A new verification link has been sent to your email address.') }}
                        </p>
                    @endif
                </div>
            @endif
        </div>

        <div class="flex items-center gap-4 pt-1">
            <x-primary-button class="rounded-xl bg-sky-600 px-5 py-2.5 text-[11px] hover:bg-sky-500 focus:bg-sky-600 active:bg-sky-700 dark:bg-sky-500 dark:text-white dark:hover:bg-sky-400 dark:focus:bg-sky-500 dark:active:bg-sky-600">
                {{ __('Save Changes') }}
            </x-primary-button>

            @if (session('status') === 'profile-updated')
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
