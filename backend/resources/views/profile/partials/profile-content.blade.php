@php
    $user = auth()->user();
    $displayName = trim((string) ($user?->name ?? 'User'));
    $email = (string) ($user?->email ?? 'No email on file');
    $roleName = $user?->isAdmin() ? 'Super Administrator' : ($user?->role ?? 'User');
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

<div x-data="{ activeTab: 'details' }" class="space-y-6">

    {{-- ── 1. Clean Profile Header Card ────────────────────────────────────── --}}
    <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
        <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-5">

            {{-- Avatar & Identity --}}
            <div class="flex items-center gap-4">
                <div class="relative shrink-0">
                    <div class="flex h-16 w-16 items-center justify-center rounded-2xl bg-gradient-to-br from-indigo-600 to-purple-600 text-xl font-extrabold text-white shadow-md">
                        {{ $initials }}
                    </div>
                    <span class="absolute -bottom-1 -right-1 h-4 w-4 rounded-full border-2 border-white bg-emerald-500 dark:border-slate-900" title="Active"></span>
                </div>

                <div class="space-y-1">
                    <div class="flex flex-wrap items-center gap-2">
                        <h1 class="text-xl font-bold text-slate-900 dark:text-white">{{ $displayName }}</h1>
                        <span class="inline-flex items-center gap-1 rounded-full bg-indigo-50 px-2.5 py-0.5 text-xs font-bold text-indigo-700 dark:bg-indigo-500/10 dark:text-indigo-300">
                            🛡️ {{ $roleName }}
                        </span>
                        <span @class([
                            'inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-bold',
                            'bg-emerald-50 text-emerald-700 dark:bg-emerald-500/10 dark:text-emerald-400' => $isVerified,
                            'bg-amber-50 text-amber-700 dark:bg-amber-500/10 dark:text-amber-400' => ! $isVerified,
                        ])>
                            {{ $isVerified ? __('Email Verified') : __('Unverified') }}
                        </span>
                    </div>
                    <p class="text-xs text-slate-500 dark:text-slate-400 font-medium">
                        {{ $email }}
                        @if ($joinedAt)
                            <span class="mx-1.5">•</span>
                            <span>{{ __('Joined') }} {{ $joinedAt }}</span>
                        @endif
                    </p>
                </div>
            </div>
        </div>
    </div>

    {{-- ── 2. Navigation Tabs Bar ────────────────────────────────────────── --}}
    <div class="rounded-2xl border border-slate-200 bg-white p-2 shadow-sm dark:border-slate-800 dark:bg-slate-900">
        <div class="flex flex-wrap items-center gap-2">
            <button @click="activeTab = 'details'"
                    :class="activeTab === 'details' ? 'bg-primary-600 text-white shadow-sm' : 'text-slate-600 hover:bg-slate-100 dark:text-slate-300 dark:hover:bg-slate-800'"
                    class="inline-flex items-center gap-2 rounded-xl px-4 py-2 text-xs font-bold transition-all">
                <svg class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/></svg>
                {{ __('Profile Information') }}
            </button>

            <button @click="activeTab = 'security'"
                    :class="activeTab === 'security' ? 'bg-primary-600 text-white shadow-sm' : 'text-slate-600 hover:bg-slate-100 dark:text-slate-300 dark:hover:bg-slate-800'"
                    class="inline-flex items-center gap-2 rounded-xl px-4 py-2 text-xs font-bold transition-all">
                <svg class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/></svg>
                {{ __('Password & Security') }}
            </button>

            <button @click="activeTab = 'danger'"
                    :class="activeTab === 'danger' ? 'bg-red-600 text-white shadow-sm' : 'text-slate-600 hover:bg-slate-100 dark:text-slate-300 dark:hover:bg-slate-800'"
                    class="inline-flex items-center gap-2 rounded-xl px-4 py-2 text-xs font-bold transition-all">
                <svg class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
                {{ __('Account Settings') }}
            </button>
        </div>
    </div>

    {{-- ── 3. Tab Contents Grid ───────────────────────────────────────────── --}}
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 items-start">

        {{-- Main Form Area (2 cols) --}}
        <div class="lg:col-span-2 space-y-6">

            {{-- Tab 1: Profile Details --}}
            <div x-show="activeTab === 'details'" class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                @include('profile.partials.update-profile-information-form')
            </div>

            {{-- Tab 2: Password & Security --}}
            <div x-show="activeTab === 'security'" x-cloak class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                @include('profile.partials.update-password-form')
            </div>

            {{-- Tab 3: Danger Zone --}}
            <div x-show="activeTab === 'danger'" x-cloak class="rounded-2xl border border-red-200 bg-red-50/30 p-6 shadow-sm dark:border-red-900/40 dark:bg-red-950/20">
                @include('profile.partials.delete-user-form')
            </div>
        </div>

        {{-- Sidebar Summary (1 col) --}}
        <div class="space-y-6">

            {{-- Account Summary Card --}}
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900 space-y-4">
                <h3 class="text-sm font-bold text-slate-900 dark:text-white flex items-center gap-2">
                    <svg class="h-4 w-4 text-indigo-500" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                    {{ __('Account Summary') }}
                </h3>

                <div class="space-y-2.5 text-xs">
                    <div class="flex items-center justify-between rounded-xl bg-slate-50 p-3 dark:bg-slate-800/60">
                        <span class="text-slate-500 dark:text-slate-400">{{ __('Role Permission') }}</span>
                        <span class="font-bold text-slate-900 dark:text-white">{{ $roleName }}</span>
                    </div>

                    <div class="flex items-center justify-between rounded-xl bg-slate-50 p-3 dark:bg-slate-800/60">
                        <span class="text-slate-500 dark:text-slate-400">{{ __('Verification Status') }}</span>
                        <span class="font-bold text-emerald-600 dark:text-emerald-400">{{ $isVerified ? __('Verified') : __('Unverified') }}</span>
                    </div>

                    <div class="flex items-center justify-between rounded-xl bg-slate-50 p-3 dark:bg-slate-800/60">
                        <span class="text-slate-500 dark:text-slate-400">{{ __('Security Rating') }}</span>
                        <span class="font-bold text-indigo-600 dark:text-indigo-400">🛡️ {{ __('High') }}</span>
                    </div>
                </div>
            </div>

            {{-- Security Tips Card --}}
            <div class="rounded-2xl border border-indigo-100 bg-indigo-50/50 p-5 shadow-sm dark:border-indigo-900/30 dark:bg-indigo-950/20">
                <h3 class="text-sm font-bold text-slate-900 dark:text-white flex items-center gap-2">
                    <svg class="h-4 w-4 text-indigo-600 dark:text-indigo-400" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/></svg>
                    {{ __('Best Security Practices') }}
                </h3>
                <ul class="mt-3 space-y-2.5 text-xs text-slate-600 dark:text-slate-300">
                    <li class="flex items-start gap-2">
                        <span class="mt-1 h-1.5 w-1.5 rounded-full bg-indigo-500 shrink-0"></span>
                        <span>{{ __('Use at least 8 characters with numbers and special symbols.') }}</span>
                    </li>
                    <li class="flex items-start gap-2">
                        <span class="mt-1 h-1.5 w-2 rounded-full bg-indigo-500 shrink-0"></span>
                        <span>{{ __('Keep your email verified to ensure password recovery access.') }}</span>
                    </li>
                    <li class="flex items-start gap-2">
                        <span class="mt-1 h-1.5 w-1.5 rounded-full bg-indigo-500 shrink-0"></span>
                        <span>{{ __('Do not share administrative credentials with unauthorized personnel.') }}</span>
                    </li>
                </ul>
            </div>
        </div>
    </div>
</div>
