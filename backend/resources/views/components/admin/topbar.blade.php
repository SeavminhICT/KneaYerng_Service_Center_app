<header class="fixed top-0 left-0 right-0 z-40 h-16 border-b border-slate-200 bg-white/90 backdrop-blur dark:border-slate-800 dark:bg-slate-950/90 lg:left-72">
    <div class="flex h-full items-center justify-between gap-3 px-6 lg:px-10">

        <div class="flex items-center gap-4">
            <button type="button" class="inline-flex h-9 w-9 shrink-0 items-center justify-center rounded-xl border border-slate-200 bg-white text-slate-600 shadow-sm transition-all duration-200 ease-out hover:-translate-y-0.5 hover:text-slate-900 hover:shadow-md active:translate-y-0 active:scale-95 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary-500/70 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300 lg:hidden motion-reduce:transition-none" @click="sidebarOpen = true">
                <span class="sr-only">Open sidebar</span>
                <svg class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16" />
                </svg>
            </button>
            <div class="hidden sm:block">
                <p class="text-[10px] font-semibold uppercase tracking-widest text-slate-400">{{ __('Admin') }}</p>
                <h1 class="text-sm font-bold text-slate-900 dark:text-white">@yield('page-title', __('Dashboard'))</h1>
            </div>
        </div>

        <div class="flex items-center gap-2">
            {{-- Search --}}
            <div class="hidden w-52 shrink-0 items-center gap-2 rounded-xl border border-slate-200 bg-slate-50 px-3 py-1.5 text-sm text-slate-500 shadow-sm transition-all duration-200 ease-out hover:-translate-y-0.5 hover:shadow-md focus-within:-translate-y-0.5 focus-within:shadow-md dark:border-slate-800 dark:bg-slate-900 md:flex motion-reduce:transition-none">
                <svg class="h-4 w-4 shrink-0" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-4.35-4.35m1.6-5.15a7 7 0 11-14 0 7 7 0 0114 0z" />
                </svg>
                <input type="search" placeholder="{{ __('Search...') }}" class="w-full border-0 bg-transparent p-0 text-sm text-slate-700 placeholder:text-slate-400 focus:ring-0 dark:text-slate-200" />
            </div>

            {{-- Cambodia time --}}
            <div class="hidden shrink-0 items-center gap-1 whitespace-nowrap rounded-xl border border-slate-200 bg-slate-50 px-3 py-1.5 text-xs text-slate-500 shadow-sm dark:border-slate-800 dark:bg-slate-900 lg:flex">
                <svg class="h-4 w-4 shrink-0 text-slate-400" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <span class="font-semibold text-slate-600 dark:text-slate-300">KH</span>
                <span id="kh-current-datetime" class="font-medium text-slate-700 dark:text-slate-200">--</span>
            </div>

            {{-- Notifications --}}
            <button type="button" class="relative inline-flex h-9 w-9 shrink-0 items-center justify-center rounded-xl border border-slate-200 bg-white text-slate-600 shadow-sm transition-all duration-200 ease-out hover:-translate-y-0.5 hover:text-slate-900 hover:shadow-md hover:shadow-primary-500/15 active:translate-y-0 active:scale-95 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary-500/70 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300 motion-reduce:transition-none">
                <span class="sr-only">Notifications</span>
                <svg class="h-5 w-5 shrink-0" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M15 17h5l-1.4-1.4A2 2 0 0118 14V9a6 6 0 00-5-5.92V2a1 1 0 00-2 0v1.08A6 6 0 006 9v5a2 2 0 01-.6 1.6L4 17h5m6 0a3 3 0 11-6 0h6z" />
                </svg>
                <span class="absolute right-2 top-2 inline-flex h-2 w-2">
                    <span class="absolute inline-flex h-full w-full animate-ping rounded-full bg-danger-400 opacity-70 motion-reduce:hidden"></span>
                    <span class="relative inline-flex h-2 w-2 rounded-full bg-danger-500"></span>
                </span>
            </button>

            {{-- Language toggle --}}
            <div class="relative shrink-0" x-data="{ langOpen: false }">
                <button type="button" class="inline-flex h-9 items-center gap-1 rounded-xl border border-slate-200 bg-white px-2 text-sm font-medium text-slate-700 shadow-sm transition-all duration-200 ease-out hover:-translate-y-0.5 hover:text-slate-900 hover:shadow-md active:translate-y-0 active:scale-95 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary-500/70 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-200 motion-reduce:transition-none" @click="langOpen = !langOpen" @keydown.escape="langOpen = false">
                    <span class="mr-1 text-base leading-none">{{ app()->getLocale() === 'km' ? '🇰🇭' : '🇬🇧' }}</span>
                    <span class="text-xs font-semibold uppercase">{{ app()->getLocale() }}</span>
                    <svg class="h-4 w-4 shrink-0 text-slate-400 transition-transform duration-200 ease-out" :class="langOpen ? 'rotate-180 text-slate-500' : ''" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M6 9l6 6 6-6" />
                    </svg>
                </button>
                <div class="absolute right-0 mt-2 w-36 rounded-2xl border border-slate-200 bg-white p-2 text-sm shadow-xl dark:border-slate-800 dark:bg-slate-900" x-show="langOpen" x-transition:enter="transition ease-out duration-200" x-transition:enter-start="opacity-0 -translate-y-1 scale-95" x-transition:enter-end="opacity-100 translate-y-0 scale-100" x-transition:leave="transition ease-in duration-150" x-transition:leave-start="opacity-100 translate-y-0 scale-100" x-transition:leave-end="opacity-0 -translate-y-1 scale-95" x-cloak @click.outside="langOpen = false">
                    <a href="{{ route('locale.set', 'en') }}" class="flex items-center gap-3 rounded-xl px-3 py-2 text-slate-600 transition-all duration-200 ease-out hover:translate-x-1 hover:bg-slate-100 hover:text-slate-900 dark:text-slate-300 dark:hover:bg-slate-800 {{ app()->getLocale() === 'en' ? 'bg-slate-50 font-semibold dark:bg-slate-800/50' : '' }}">
                        <span class="text-base leading-none">🇬🇧</span> English
                    </a>
                    <a href="{{ route('locale.set', 'km') }}" class="flex items-center gap-3 rounded-xl px-3 py-2 text-slate-600 transition-all duration-200 ease-out hover:translate-x-1 hover:bg-slate-100 hover:text-slate-900 dark:text-slate-300 dark:hover:bg-slate-800 {{ app()->getLocale() === 'km' ? 'bg-slate-50 font-semibold dark:bg-slate-800/50' : '' }}">
                        <span class="text-base leading-none">🇰🇭</span> ភាសាខ្មែរ
                    </a>
                </div>
            </div>

            {{-- Theme toggle --}}
            <button type="button" class="inline-flex h-9 shrink-0 w-24 items-center justify-center gap-2 rounded-xl border border-slate-200 bg-white text-sm font-medium text-slate-600 shadow-sm transition-all duration-200 ease-out hover:-translate-y-0.5 hover:text-slate-900 hover:shadow-md active:translate-y-0 active:scale-95 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary-500/70 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300 motion-reduce:transition-none" @click="theme = theme === 'dark' ? 'light' : 'dark'; localStorage.setItem('theme', theme); document.documentElement.classList.toggle('dark', theme === 'dark')">
                {{-- Moon icon (shown in light mode) --}}
                <svg x-show="theme === 'light'" class="h-4 w-4 shrink-0 transition-transform duration-200 ease-out" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24" x-cloak>
                    <path stroke-linecap="round" stroke-linejoin="round" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" />
                </svg>
                {{-- Sun icon (shown in dark mode) --}}
                <svg x-show="theme === 'dark'" class="h-4 w-4 shrink-0 transition-transform duration-200 ease-out" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24" x-cloak>
                    <path stroke-linecap="round" stroke-linejoin="round" d="M12 3v2m0 14v2m9-9h-2M5 12H3m15.364 6.364l-1.414-1.414M7.05 7.05L5.636 5.636m12.728 0l-1.414 1.414M7.05 16.95l-1.414 1.414" />
                </svg>
                <span x-text="theme === 'dark' ? '{{ __('Dark') }}' : '{{ __('Light') }}'">{{ __('Theme') }}</span>
            </button>

            {{-- User dropdown --}}
            <div class="relative shrink-0" x-data="{ open: false }">
                <button type="button" class="inline-flex h-9 items-center gap-2 rounded-xl border border-slate-200 bg-white px-2 text-sm font-medium text-slate-700 shadow-sm transition-all duration-200 ease-out hover:-translate-y-0.5 hover:text-slate-900 hover:shadow-md active:translate-y-0 active:scale-95 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary-500/70 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-200 motion-reduce:transition-none" @click="open = !open" @keydown.escape="open = false">
                    <span class="flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-primary-600 text-xs font-bold text-white">
                        {{ strtoupper(substr(auth()->user()?->name ?? 'A', 0, 1)) }}
                    </span>
                    <span class="hidden text-left sm:block">
                        <span class="block text-xs font-semibold">{{ auth()->user()?->name ?? __('Admin') }}</span>
                    </span>
                    <svg class="h-4 w-4 shrink-0 text-slate-400 transition-transform duration-200 ease-out" :class="open ? 'rotate-180 text-slate-500' : ''" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M6 9l6 6 6-6" />
                    </svg>
                </button>
                <div class="absolute right-0 mt-2 w-48 rounded-2xl border border-slate-200 bg-white p-2 text-sm shadow-xl dark:border-slate-800 dark:bg-slate-900" x-show="open" x-transition:enter="transition ease-out duration-200" x-transition:enter-start="opacity-0 -translate-y-1 scale-95" x-transition:enter-end="opacity-100 translate-y-0 scale-100" x-transition:leave="transition ease-in duration-150" x-transition:leave-start="opacity-100 translate-y-0 scale-100" x-transition:leave-end="opacity-0 -translate-y-1 scale-95" x-cloak @click.outside="open = false">
                    <a href="{{ route('profile.edit') }}" class="block rounded-xl px-3 py-2 text-slate-600 transition-all duration-200 ease-out hover:translate-x-1 hover:bg-slate-100 hover:text-slate-900 dark:text-slate-300 dark:hover:bg-slate-800">{{ __('Profile') }}</a>
                    <a href="{{ route('admin.settings.index') }}" class="block rounded-xl px-3 py-2 text-slate-600 transition-all duration-200 ease-out hover:translate-x-1 hover:bg-slate-100 hover:text-slate-900 dark:text-slate-300 dark:hover:bg-slate-800">{{ __('Settings') }}</a>
                    <form method="POST" action="{{ route('logout') }}">
                        @csrf
                        <button type="submit" class="mt-1 w-full rounded-xl px-3 py-2 text-left text-slate-600 transition-all duration-200 ease-out hover:translate-x-1 hover:bg-slate-100 hover:text-slate-900 dark:text-slate-300 dark:hover:bg-slate-800">{{ __('Sign out') }}</button>
                    </form>
                </div>
            </div>

        </div>
    </div>
</header>

<script>
(function () {
    var target = document.getElementById('kh-current-datetime');
    if (!target) return;

    var days   = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
    var months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

    function update() {
        var kh = new Date(new Date().toLocaleString('en-US', { timeZone: 'Asia/Phnom_Penh' }));
        var h  = kh.getHours();
        var m  = kh.getMinutes();
        var s  = kh.getSeconds();
        var ap = h >= 12 ? 'PM' : 'AM';
        h = h % 12 || 12;

        target.textContent =
            days[kh.getDay()] + ' ' +
            kh.getDate()      + ' ' +
            months[kh.getMonth()] + ' ' +
            String(h).padStart(2,'0') + ':' +
            String(m).padStart(2,'0') + ':' +
            String(s).padStart(2,'0') + ' ' + ap;
    }

    // Align to the exact next second boundary, then tick every 1 s
    update();
    var msUntilNextSecond = 1000 - (Date.now() % 1000);
    setTimeout(function () {
        update();
        setInterval(update, 1000);
    }, msUntilNextSecond);
})();
</script>
