@php
    $activeClass = 'bg-primary-600 text-white shadow-sm';
    $inactiveClass = 'text-slate-600 hover:bg-slate-100 hover:text-slate-900 dark:text-slate-300 dark:hover:bg-slate-900 dark:hover:text-white';
@endphp

<aside class="fixed inset-y-0 left-0 z-40 flex w-72 flex-col border-r border-slate-200 bg-white/90 backdrop-blur dark:border-slate-800 dark:bg-slate-900/90 lg:translate-x-0" :class="sidebarOpen ? 'translate-x-0' : '-translate-x-full'" x-transition.duration.300ms>
    <div class="flex items-center justify-between px-6 py-6">
        <a href="{{ route('admin.dashboard') }}" class="flex items-center gap-3 text-lg font-semibold text-slate-900 dark:text-white">
            <span class="inline-flex h-10 w-10 items-center justify-center rounded-2xl bg-primary-600 text-white">
                <x-application-logo class="h-6 w-6 fill-current text-white" />
            </span>
            <span>Admin Panel</span>
        </a>
        <button type="button" class="rounded-lg border border-slate-200 bg-white p-2 text-slate-500 shadow-sm hover:text-slate-900 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300 lg:hidden" @click="sidebarOpen = false">
            <span class="sr-only">Close sidebar</span>
            <svg class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
            </svg>
        </button>
    </div>

    <div class="flex-1 overflow-y-auto px-4 pb-6">
        <p class="px-3 text-xs font-semibold uppercase tracking-widest text-slate-400">Overview</p>
        <nav class="mt-4 space-y-2">
            <a href="{{ route('admin.dashboard') }}" class="flex items-center gap-3 rounded-xl px-3 py-2 text-sm font-medium {{ request()->routeIs('admin.dashboard') ? $activeClass : $inactiveClass }}">
                <svg class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M3 12l9-9 9 9M4 10v10a1 1 0 001 1h5m4 0h5a1 1 0 001-1V10" />
                </svg>
                Dashboard
            </a>
            <a href="{{ route('admin.reports.index') }}" class="flex items-center gap-3 rounded-xl px-3 py-2 text-sm font-medium {{ request()->routeIs('admin.reports.*') ? $activeClass : $inactiveClass }}">
                <svg class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M9 17v-6m4 6V7m4 10v-3M4 21h16" />
                </svg>
                Reports
            </a>
        </nav>

        <div class="mt-6">
            <p class="px-3 text-xs font-semibold uppercase tracking-widest text-slate-400">Catalog</p>
            <nav class="mt-3 space-y-2">
                <a href="{{ route('admin.categories.index') }}" class="flex items-center gap-3 rounded-xl px-3 py-2 text-sm font-medium {{ request()->routeIs('admin.categories.*') ? $activeClass : $inactiveClass }}">
                    <svg class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16" />
                    </svg>
                    Categories
                </a>
                <a href="{{ route('admin.products.index') }}" class="flex items-center gap-3 rounded-xl px-3 py-2 text-sm font-medium {{ request()->routeIs('admin.products.*') ? $activeClass : $inactiveClass }}">
                    <svg class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M12 3l8 4-8 4-8-4 8-4zm0 8l8 4-8 4-8-4 8-4z" />
                    </svg>
                    Products
                </a>
                <a href="{{ route('admin.accessories.index') }}" class="flex items-center gap-3 rounded-xl px-3 py-2 text-sm font-medium {{ request()->routeIs('admin.accessories.*') ? $activeClass : $inactiveClass }}">
                    <svg class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M12 6v12m6-6H6" />
                    </svg>
                    Accessories
                </a>
                <a href="{{ route('admin.banners.index') }}" class="flex items-center gap-3 rounded-xl px-3 py-2 text-sm font-medium {{ request()->routeIs('admin.banners.*') ? $activeClass : $inactiveClass }}">
                    <svg class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 18H8m8 0h4M4 10h16M4 14h16" />
                    </svg>
                    Banners
                </a>
            </nav>
        </div>

        <div class="mt-6">
            <p class="px-3 text-xs font-semibold uppercase tracking-widest text-slate-400">Sales</p>
            <nav class="mt-3 space-y-2">
                <a href="{{ route('admin.orders.index') }}" class="flex items-center gap-3 rounded-xl px-3 py-2 text-sm font-medium {{ request()->routeIs('admin.orders.*') ? $activeClass : $inactiveClass }}">
                    <svg class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M3 3h18v4H3zM5 7v13h14V7" />
                    </svg>
                    Orders
                </a>
                <a href="{{ route('admin.customers.index') }}" class="flex items-center gap-3 rounded-xl px-3 py-2 text-sm font-medium {{ request()->routeIs('admin.customers.*') ? $activeClass : $inactiveClass }}">
                    <svg class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M17 20h5v-2a4 4 0 00-4-4h-1M9 20H4v-2a4 4 0 014-4h1m7-7a4 4 0 11-8 0 4 4 0 018 0zm8 0a3 3 0 11-6 0 3 3 0 016 0z" />
                    </svg>
                    Customers
                </a>
                <a href="{{ route('admin.payments.index') }}" class="flex items-center gap-3 rounded-xl px-3 py-2 text-sm font-medium {{ request()->routeIs('admin.payments.*') ? $activeClass : $inactiveClass }}">
                    <svg class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M3 8h18M3 12h18M5 16h14" />
                    </svg>
                    Payments
                </a>
            </nav>
        </div>

        <div class="mt-6">
            <p class="px-3 text-xs font-semibold uppercase tracking-widest text-slate-400">Access</p>
            <nav class="mt-3 space-y-2">
                <a href="{{ route('admin.users.index') }}" class="flex items-center gap-3 rounded-xl px-3 py-2 text-sm font-medium {{ request()->routeIs('admin.users.*') ? $activeClass : $inactiveClass }}">
                    <svg class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M12 12a4 4 0 100-8 4 4 0 000 8zm6 8H6a6 6 0 0112 0z" />
                    </svg>
                    User Management
                </a>
                <a href="{{ route('admin.settings.index') }}" class="flex items-center gap-3 rounded-xl px-3 py-2 text-sm font-medium {{ request()->routeIs('admin.settings.*') ? $activeClass : $inactiveClass }}">
                    <svg class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.356.873 2.416 2.416a1.724 1.724 0 001.065 2.573c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.873 3.356-2.416 2.416a1.724 1.724 0 00-2.573 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.356-.873-2.416-2.416a1.724 1.724 0 00-1.065-2.573c-1.756-.426-1.756-2.924 0-3.35.492-.12.88-.51 1.065-1.066.94-1.543-.873-3.356-2.416-2.416a1.724 1.724 0 00-2.573-1.065z" />
                        <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                    </svg>
                    Settings
                </a>
            </nav>
        </div>
    </div>

    <div class="px-6 pb-6">
        <div class="rounded-2xl bg-primary-600 px-4 py-4 text-sm text-white">
            <p class="font-semibold">Web + API ready</p>
            <p class="mt-1 text-xs text-white/80">Use the admin panel to manage data synced to your mobile app API.</p>
        </div>
    </div>
</aside>
