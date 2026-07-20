<section class="space-y-6">
    <header class="space-y-1">
        <h2 class="text-xl font-extrabold text-red-600 dark:text-red-400 flex items-center gap-2">
            <svg class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
            {{ __('Delete Account') }}
        </h2>

        <p class="text-xs text-slate-500 dark:text-slate-400">
            {{ __('Once your account is deleted, all associated resources and data will be permanently purged.') }}
        </p>
    </header>

    <div class="rounded-2xl border border-red-200 bg-red-50/80 p-4 dark:border-red-900/50 dark:bg-red-950/40">
        <p class="text-xs font-semibold text-red-800 dark:text-red-300">
            {{ __('Warning: Account deletion is permanent and cannot be undone.') }}
        </p>
    </div>

    <button
        x-data=""
        x-on:click.prevent="$dispatch('open-modal', 'confirm-user-deletion')"
        class="inline-flex h-11 items-center gap-2 rounded-xl bg-red-600 px-6 text-sm font-bold text-white shadow-md hover:bg-red-700 active:scale-95 transition-all"
    >
        <svg class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
        {{ __('Delete Account') }}
    </button>

    <x-modal name="confirm-user-deletion" :show="$errors->userDeletion->isNotEmpty()" focusable>
        <form method="post" action="{{ route('profile.destroy') }}" class="space-y-5 p-6 sm:p-8">
            @csrf
            @method('delete')

            <h2 class="text-xl font-extrabold text-slate-900 dark:text-white">
                {{ __('Confirm Account Deletion') }}
            </h2>

            <p class="text-xs text-slate-500 dark:text-slate-400">
                {{ __('Once your account is deleted, all resources will be permanently removed. Please enter your password to confirm deletion.') }}
            </p>

            <div>
                <label for="password" class="text-xs font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400 block mb-1.5">{{ __('Password') }}</label>
                <input
                    id="password"
                    name="password"
                    type="password"
                    class="h-11 block w-full rounded-xl border border-slate-200 bg-slate-50/80 px-4 text-sm font-medium text-slate-900 focus:border-red-500 focus:ring-red-500 dark:border-slate-800 dark:bg-slate-950 dark:text-white transition-all"
                    placeholder="{{ __('Enter your current password') }}"
                />
                <x-input-error :messages="$errors->userDeletion->get('password')" class="mt-2" />
            </div>

            <div class="flex items-center justify-end gap-3 pt-2">
                <button type="button" x-on:click="$dispatch('close')" class="h-10 rounded-xl border border-slate-200 px-5 text-xs font-bold text-slate-600 hover:bg-slate-50 dark:border-slate-800 dark:text-slate-300 dark:hover:bg-slate-800 transition-all">
                    {{ __('Cancel') }}
                </button>

                <button type="submit" class="h-10 rounded-xl bg-red-600 px-5 text-xs font-bold text-white hover:bg-red-700 active:scale-95 transition-all">
                    {{ __('Permanently Delete Account') }}
                </button>
            </div>
        </form>
    </x-modal>
</section>
