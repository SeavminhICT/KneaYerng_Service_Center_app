@php
    $user = auth()->user();
    $displayName = trim((string) ($user?->name ?? 'User'));
    $email = (string) ($user?->email ?? 'No email on file');
    $parts = preg_split('/\s+/', $displayName) ?: [];
    $initials = '';

    foreach ($parts as $part) {
        $part = trim((string) $part);
        if ($part === '') {
            continue;
        }

        $initials .= \Illuminate\Support\Str::upper(\Illuminate\Support\Str::substr($part, 0, 1));
        if (\Illuminate\Support\Str::length($initials) >= 2) {
            break;
        }
    }

    if ($initials === '') {
        $initials = 'U';
    }

    $joinedAt = $user?->created_at?->format('M d, Y');
    $isVerified = ! ($user instanceof \Illuminate\Contracts\Auth\MustVerifyEmail) || $user->hasVerifiedEmail();
@endphp

<div class="relative overflow-hidden py-10">
    <div class="pointer-events-none absolute inset-x-0 top-0 -z-10 h-72 bg-gradient-to-br from-sky-100 via-cyan-50 to-emerald-50 dark:from-slate-900 dark:via-slate-900 dark:to-slate-950"></div>

    <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <section class="rounded-3xl border border-slate-200/70 bg-white/90 p-6 shadow-sm backdrop-blur dark:border-slate-700 dark:bg-slate-900/80 sm:p-8">
            <div class="flex flex-col gap-5 sm:flex-row sm:items-center sm:justify-between">
                <div class="flex items-center gap-4">
                    <div class="flex h-16 w-16 shrink-0 items-center justify-center rounded-2xl bg-gradient-to-br from-sky-500 to-cyan-500 text-xl font-semibold text-white shadow-lg shadow-sky-500/30">
                        {{ $initials }}
                    </div>
                    <div class="space-y-1">
                        <h3 class="text-xl font-semibold text-slate-900 dark:text-slate-100">{{ $displayName }}</h3>
                        <p class="text-sm text-slate-600 dark:text-slate-400">{{ $email }}</p>
                    </div>
                </div>

                <div class="flex flex-wrap gap-2">
                    <span @class([
                        'inline-flex items-center rounded-full px-3 py-1 text-xs font-medium',
                        'bg-emerald-100 text-emerald-700 dark:bg-emerald-500/20 dark:text-emerald-300' => $isVerified,
                        'bg-amber-100 text-amber-700 dark:bg-amber-500/20 dark:text-amber-300' => ! $isVerified,
                    ])>
                        {{ $isVerified ? __('Email verified') : __('Email not verified') }}
                    </span>
                    @if ($joinedAt)
                        <span class="inline-flex items-center rounded-full bg-slate-100 px-3 py-1 text-xs font-medium text-slate-700 dark:bg-slate-800 dark:text-slate-300">
                            {{ __('Joined') }} {{ $joinedAt }}
                        </span>
                    @endif
                </div>
            </div>
        </section>

        <div class="mt-8 grid grid-cols-1 gap-6 lg:grid-cols-[1.2fr_2fr]">
            <aside class="min-w-0 space-y-6">
                <section class="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-700 dark:bg-slate-900">
                    <h3 class="text-lg font-semibold text-slate-900 dark:text-slate-100">{{ __('Account Overview') }}</h3>
                    <dl class="mt-5 space-y-4 text-sm">
                        <div class="rounded-2xl bg-slate-50 px-4 py-3 dark:bg-slate-800/60">
                            <dt class="text-slate-500 dark:text-slate-400">{{ __('Status') }}</dt>
                            <dd class="mt-1 font-medium text-slate-900 dark:text-slate-100">
                                {{ $isVerified ? __('Verified') : __('Action needed') }}
                            </dd>
                        </div>
                        <div class="rounded-2xl bg-slate-50 px-4 py-3 dark:bg-slate-800/60">
                            <dt class="text-slate-500 dark:text-slate-400">{{ __('Display name') }}</dt>
                            <dd class="mt-1 font-medium text-slate-900 dark:text-slate-100">{{ $displayName }}</dd>
                        </div>
                        <div class="rounded-2xl bg-slate-50 px-4 py-3 dark:bg-slate-800/60">
                            <dt class="text-slate-500 dark:text-slate-400">{{ __('Email') }}</dt>
                            <dd class="mt-1 break-all font-medium text-slate-900 dark:text-slate-100">{{ $email }}</dd>
                        </div>
                    </dl>
                </section>

                <section class="rounded-3xl border border-sky-100 bg-sky-50/70 p-6 shadow-sm dark:border-sky-900/40 dark:bg-sky-950/30">
                    <h3 class="text-lg font-semibold text-slate-900 dark:text-slate-100">{{ __('Security Tips') }}</h3>
                    <ul class="mt-4 space-y-3 text-sm text-slate-700 dark:text-slate-300">
                        <li class="flex items-start gap-3">
                            <span class="mt-1.5 h-1.5 w-1.5 rounded-full bg-sky-500"></span>
                            <span>{{ __('Use a strong password with uppercase letters and numbers.') }}</span>
                        </li>
                        <li class="flex items-start gap-3">
                            <span class="mt-1.5 h-1.5 w-1.5 rounded-full bg-sky-500"></span>
                            <span>{{ __('Keep your email up to date so account recovery works.') }}</span>
                        </li>
                        <li class="flex items-start gap-3">
                            <span class="mt-1.5 h-1.5 w-1.5 rounded-full bg-sky-500"></span>
                            <span>{{ __('Only delete your account when you are sure all data is backed up.') }}</span>
                        </li>
                    </ul>
                </section>
            </aside>

            <section class="min-w-0 space-y-6">
                <div class="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-700 dark:bg-slate-900 sm:p-8">
                    @include('profile.partials.update-profile-information-form')
                </div>

                <div class="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-700 dark:bg-slate-900 sm:p-8">
                    @include('profile.partials.update-password-form')
                </div>

                <div class="rounded-3xl border border-red-200 bg-red-50/40 p-6 shadow-sm dark:border-red-900/60 dark:bg-red-950/20 sm:p-8">
                    @include('profile.partials.delete-user-form')
                </div>
            </section>
        </div>
    </div>
</div>
