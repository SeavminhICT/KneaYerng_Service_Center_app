<section class="space-y-5">
    <header class="space-y-1">
        <h2 class="text-base font-bold text-slate-900 dark:text-white flex items-center gap-2">
            <svg class="h-4 w-4 text-primary-600 dark:text-primary-400" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/></svg>
            {{ __('Profile Information') }}
        </h2>
        <p class="text-xs text-slate-500 dark:text-slate-400">
            {{ __("Update your account's display name, email address, and general settings.") }}
        </p>
    </header>

    <form id="send-verification" method="post" action="{{ route('verification.send') }}">
        @csrf
    </form>

    <form method="post" action="{{ route('profile.update') }}" class="space-y-4 max-w-2xl">
        @csrf
        @method('patch')

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
                <label for="name" class="text-xs font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400 block mb-1">{{ __('Full Name') }}</label>
                <input
                    id="name"
                    name="name"
                    type="text"
                    class="h-10 block w-full rounded-xl border border-slate-200 bg-white px-3.5 text-sm font-medium text-slate-900 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900 dark:text-white transition-all"
                    value="{{ old('name', $user->name) }}"
                    required
                    autofocus
                    autocomplete="name"
                />
                <x-input-error class="mt-1.5" :messages="$errors->get('name')" />
            </div>

            <div>
                <label for="email" class="text-xs font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400 block mb-1">{{ __('Email Address') }}</label>
                <input
                    id="email"
                    name="email"
                    type="email"
                    class="h-10 block w-full rounded-xl border border-slate-200 bg-white px-3.5 text-sm font-medium text-slate-900 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900 dark:text-white transition-all"
                    value="{{ old('email', $user->email) }}"
                    required
                    autocomplete="username"
                />
                <x-input-error class="mt-1.5" :messages="$errors->get('email')" />
            </div>
        </div>

        @if ($user instanceof \Illuminate\Contracts\Auth\MustVerifyEmail && ! $user->hasVerifiedEmail())
            <div class="mt-3 rounded-xl border border-amber-200 bg-amber-50/60 p-3 dark:border-amber-900/40 dark:bg-amber-950/30">
                <p class="text-xs text-amber-800 dark:text-amber-300">
                    {{ __('Your email address is currently unverified.') }}
                    <button form="send-verification" class="font-bold underline hover:text-amber-950 dark:hover:text-white ml-1">
                        {{ __('Click here to re-send verification email.') }}
                    </button>
                </p>

                @if (session('status') === 'verification-link-sent')
                    <p class="mt-2 text-xs font-bold text-emerald-600 dark:text-emerald-400">
                        {{ __('A new verification link has been sent to your email address.') }}
                    </p>
                @endif
            </div>
        @endif

        <div class="flex items-center gap-3 pt-2">
            <button type="submit" class="inline-flex h-10 items-center gap-2 rounded-xl bg-primary-600 px-5 text-xs font-bold text-white shadow-sm hover:bg-primary-700 active:scale-95 transition-all">
                <svg class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/></svg>
                {{ __('Save Changes') }}
            </button>

            @if (session('status') === 'profile-updated')
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
