<section class="space-y-6">
    <header class="space-y-2">
        <h2 class="text-xl font-semibold text-slate-900 dark:text-slate-100">
            {{ __('Delete Account') }}
        </h2>

        <p class="text-sm text-slate-600 dark:text-slate-400">
            {{ __('Once your account is deleted, all of its resources and data will be permanently deleted. Before deleting your account, please download any data or information that you wish to retain.') }}
        </p>
    </header>

    <x-danger-button
        x-data=""
        x-on:click.prevent="$dispatch('open-modal', 'confirm-user-deletion')"
        class="rounded-xl px-5 py-2.5 text-[11px]"
    >{{ __('Delete Account') }}</x-danger-button>

    <x-modal name="confirm-user-deletion" :show="$errors->userDeletion->isNotEmpty()" focusable>
        <form method="post" action="{{ route('profile.destroy') }}" class="space-y-5 p-6 sm:p-8">
            @csrf
            @method('delete')

            <h2 class="text-xl font-semibold text-slate-900 dark:text-slate-100">
                {{ __('Are you sure you want to delete your account?') }}
            </h2>

            <p class="text-sm text-slate-600 dark:text-slate-400">
                {{ __('Once your account is deleted, all of its resources and data will be permanently deleted. Please enter your password to confirm you would like to permanently delete your account.') }}
            </p>

            <div>
                <x-input-label for="password" value="{{ __('Password') }}" class="sr-only" />

                <x-text-input
                    id="password"
                    name="password"
                    type="password"
                    class="mt-1 block w-full rounded-xl border-slate-300/90 px-4 py-3 text-sm text-slate-900 focus:border-red-500 focus:ring-red-500 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-100"
                    placeholder="{{ __('Password') }}"
                />

                <x-input-error :messages="$errors->userDeletion->get('password')" class="mt-2" />
            </div>

            <div class="flex items-center justify-end gap-3">
                <x-secondary-button x-on:click="$dispatch('close')" class="rounded-xl border-slate-300 px-5 py-2.5 text-[11px] dark:border-slate-600">
                    {{ __('Cancel') }}
                </x-secondary-button>

                <x-danger-button class="rounded-xl px-5 py-2.5 text-[11px]">
                    {{ __('Delete Account') }}
                </x-danger-button>
            </div>
        </form>
    </x-modal>
</section>
