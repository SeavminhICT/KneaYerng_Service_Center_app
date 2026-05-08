<x-app-layout>
    <x-slot name="header">
        <div class="flex flex-col gap-1">
            <h2 class="text-2xl font-semibold tracking-tight text-slate-900 dark:text-slate-100">
                {{ __('Profile & Security') }}
            </h2>
            <p class="text-sm text-slate-600 dark:text-slate-400">
                {{ __('Manage your account details, password, and account lifecycle settings.') }}
            </p>
        </div>
    </x-slot>

    @include('profile.partials.profile-content')
</x-app-layout>
