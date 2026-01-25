<header class="fixed top-0 left-0 right-0 z-40 border-b border-slate-200 bg-white/90 backdrop-blur dark:border-slate-800 dark:bg-slate-950/90 lg:left-72">
    <div class="flex flex-wrap items-center justify-between gap-4 px-6 py-4 lg:px-10">
        <div class="flex items-center gap-4">
            <button type="button" class="inline-flex h-10 w-10 items-center justify-center rounded-xl border border-slate-200 bg-white text-slate-600 shadow-sm hover:text-slate-900 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300 lg:hidden" @click="sidebarOpen = true">
                <span class="sr-only">Open sidebar</span>
                <svg class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16" />
                </svg>
            </button>
            <div>
                <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Admin</p>
                <h1 class="text-xl font-semibold text-slate-900 dark:text-white">@yield('page-title', 'Dashboard')</h1>
            </div>
        </div>

        <div class="flex flex-1 flex-col items-end gap-2">
            <div class="flex w-full flex-wrap items-center justify-end gap-3 sm:gap-4">
                <div class="hidden w-full max-w-md items-center gap-2 rounded-2xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-500 shadow-sm dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300 md:flex">
                    <svg class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-4.35-4.35m1.6-5.15a7 7 0 11-14 0 7 7 0 0114 0z" />
                    </svg>
                    <input type="search" placeholder="Search orders, products, customers..." class="w-full border-0 bg-transparent p-0 text-sm text-slate-700 placeholder:text-slate-400 focus:ring-0 dark:text-slate-200" />
                </div>

                <button type="button" class="relative inline-flex h-10 w-10 items-center justify-center rounded-xl border border-slate-200 bg-white text-slate-600 shadow-sm hover:text-slate-900 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300">
                    <span class="sr-only">Notifications</span>
                    <svg class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M15 17h5l-1.4-1.4A2 2 0 0118 14V9a6 6 0 00-5-5.92V2a1 1 0 00-2 0v1.08A6 6 0 006 9v5a2 2 0 01-.6 1.6L4 17h5m6 0a3 3 0 11-6 0h6z" />
                    </svg>
                    <span class="absolute right-2 top-2 h-2 w-2 rounded-full bg-danger-500"></span>
                </button>

                <button type="button" class="inline-flex h-10 items-center gap-2 rounded-xl border border-slate-200 bg-white px-3 text-sm font-medium text-slate-600 shadow-sm hover:text-slate-900 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300" @click="theme = theme === 'dark' ? 'light' : 'dark'; localStorage.setItem('theme', theme); document.documentElement.classList.toggle('dark', theme === 'dark')">
                    <svg class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M12 3v2m0 14v2m9-9h-2M5 12H3m15.364 6.364l-1.414-1.414M7.05 7.05L5.636 5.636m12.728 0l-1.414 1.414M7.05 16.95l-1.414 1.414" />
                    </svg>
                    <span class="hidden sm:inline">Theme</span>
                </button>

                <div class="relative" x-data="{ open: false }">
                    <button type="button" class="inline-flex items-center gap-3 rounded-2xl border border-slate-200 bg-white px-3 py-2 text-sm font-medium text-slate-700 shadow-sm hover:text-slate-900 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-200" @click="open = !open" @keydown.escape="open = false">
                        <span class="flex h-9 w-9 items-center justify-center rounded-full bg-primary-600 text-white">
                            {{ strtoupper(substr(auth()->user()?->name ?? 'A', 0, 1)) }}
                        </span>
                        <span class="hidden text-left sm:block">
                            <span class="block text-xs text-slate-500 dark:text-slate-400">Signed in as</span>
                            <span class="block font-semibold">{{ auth()->user()?->name ?? 'Admin' }}</span>
                        </span>
                        <svg class="h-4 w-4 text-slate-400" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M6 9l6 6 6-6" />
                        </svg>
                    </button>
                    <div class="absolute right-0 mt-3 w-48 rounded-2xl border border-slate-200 bg-white p-2 text-sm shadow-xl dark:border-slate-800 dark:bg-slate-900" x-show="open" x-transition.origin.top.right x-cloak @click.outside="open = false">
                        <a href="{{ route('profile.edit') }}" class="block rounded-xl px-3 py-2 text-slate-600 hover:bg-slate-100 hover:text-slate-900 dark:text-slate-300 dark:hover:bg-slate-800">Profile</a>
                        <a href="{{ route('admin.settings.index') }}" class="block rounded-xl px-3 py-2 text-slate-600 hover:bg-slate-100 hover:text-slate-900 dark:text-slate-300 dark:hover:bg-slate-800">Settings</a>
                        <form method="POST" action="{{ route('logout') }}">
                            @csrf
                            <button type="submit" class="mt-1 w-full rounded-xl px-3 py-2 text-left text-slate-600 hover:bg-slate-100 hover:text-slate-900 dark:text-slate-300 dark:hover:bg-slate-800">Sign out</button>
                        </form>
                    </div>
                </div>
            </div>

            <div class="flex items-center gap-2 text-xs text-slate-500 dark:text-slate-400 ">
                <svg class="h-4 w-4 text-slate-400" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M8 7V3m8 4V3m-9 8h10m-11 8h12a2 2 0 002-2V7a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                </svg>
                <span class="font-semibold text-slate-600 dark:text-slate-300">Cambodia:</span>
                <span id="kh-current-datetime" class="font-medium text-slate-700 dark:text-slate-200">--</span>
            </div>
        </div>
    </div>
</header>

<script>
    (function () {
        var target = document.getElementById('kh-current-datetime');
        if (!target || !window.Intl || !Intl.DateTimeFormat) {
            return;
        }

        var formatter = new Intl.DateTimeFormat('en-US', {
            timeZone: 'Asia/Phnom_Penh',
            weekday: 'long',
            month: 'long',
            day: 'numeric',
            year: 'numeric',
            hour: 'numeric',
            minute: '2-digit',
            second: '2-digit',
            hour12: true
        });

        function update() {
            var parts = formatter.formatToParts(new Date());
            var values = {};
            parts.forEach(function (part) {
                if (part.type !== 'literal') {
                    values[part.type] = part.value;
                }
            });

            target.textContent = (values.weekday || '') + ' ' + (values.day || '') + ' ' + (values.month || '') + ' ' +
                (values.year || '') + ' Time ' + (values.hour || '') + ' : ' + (values.minute || '') + ' : ' +
                (values.second || '');
        }

        update();
        setInterval(update, 1000);
        document.addEventListener('visibilitychange', function () {
            if (!document.hidden) {
                update();
            }
        });
    })();
</script>
