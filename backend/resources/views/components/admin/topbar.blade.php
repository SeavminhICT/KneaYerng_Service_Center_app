<header class="fixed top-0 left-0 right-0 z-40 h-16 border-b border-slate-200 bg-white/90 backdrop-blur dark:border-slate-800 dark:bg-slate-950/90 lg:left-72">
    <div class="flex h-full items-center justify-between gap-3 px-6 lg:px-10">

        <div class="flex min-w-0 items-center gap-4">
            <button type="button" class="inline-flex h-9 w-9 shrink-0 items-center justify-center rounded-xl border border-slate-200 bg-white text-slate-600 shadow-sm transition-all duration-200 ease-out hover:-translate-y-0.5 hover:text-slate-900 hover:shadow-md active:translate-y-0 active:scale-95 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary-500/70 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300 lg:hidden motion-reduce:transition-none" @click="sidebarOpen = true">
                <span class="sr-only">{{ __('Open sidebar') }}</span>
                <svg class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16" />
                </svg>
            </button>
            <div class="hidden min-w-0 sm:block">
                <p class="text-[10px] font-semibold uppercase tracking-widest text-slate-400">{{ __('Admin') }}</p>
                <h1 class="truncate text-sm font-bold text-slate-900 dark:text-white">@yield('page-title', __('Dashboard'))</h1>
            </div>
        </div>

        <div class="flex shrink-0 items-center gap-2">
            {{-- Search --}}
            <div class="hidden w-52 shrink-0 items-center gap-2 rounded-xl border border-slate-200 bg-slate-50 px-3 py-1.5 text-sm text-slate-500 shadow-sm transition-all duration-200 ease-out hover:-translate-y-0.5 hover:shadow-md focus-within:-translate-y-0.5 focus-within:shadow-md dark:border-slate-800 dark:bg-slate-900 2xl:flex motion-reduce:transition-none">
                <svg class="h-4 w-4 shrink-0" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-4.35-4.35m1.6-5.15a7 7 0 11-14 0 7 7 0 0114 0z" />
                </svg>
                <input type="search" placeholder="{{ __('Search...') }}" class="w-full border-0 bg-transparent p-0 text-sm text-slate-700 placeholder:text-slate-400 focus:ring-0 dark:text-slate-200" />
            </div>

            {{-- Cambodia time --}}
            <div class="hidden shrink-0 items-center gap-1 whitespace-nowrap rounded-xl border border-slate-200 bg-slate-50 px-3 py-1.5 text-xs text-slate-500 shadow-sm dark:border-slate-800 dark:bg-slate-900 2xl:flex">
                <svg class="h-4 w-4 shrink-0 text-slate-400" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <span class="font-semibold text-slate-600 dark:text-slate-300">KH</span>
                <span id="kh-current-datetime" class="font-medium text-slate-700 dark:text-slate-200">--</span>
            </div>

            {{-- Notifications --}}
            <div class="relative shrink-0" x-data="adminNotifPanel()" x-init="init()" @keydown.escape.window="close()">

                {{-- Bell trigger --}}
                <button type="button"
                    @click="toggle()"
                    class="relative inline-flex h-9 w-9 shrink-0 items-center justify-center rounded-xl border border-slate-200 bg-white text-slate-600 shadow-sm transition-all duration-200 ease-out hover:-translate-y-0.5 hover:text-slate-900 hover:shadow-md hover:shadow-primary-500/15 active:translate-y-0 active:scale-95 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary-500/70 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300 motion-reduce:transition-none">
                    <span class="sr-only">{{ __('Notifications') }}</span>
                    <svg class="h-5 w-5 shrink-0" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M15 17h5l-1.4-1.4A2 2 0 0118 14V9a6 6 0 00-5-5.92V2a1 1 0 00-2 0v1.08A6 6 0 006 9v5a2 2 0 01-.6 1.6L4 17h5m6 0a3 3 0 11-6 0h6z" />
                    </svg>
                    {{-- Unread dot --}}
                    <span x-show="unreadCount > 0" class="absolute right-1.5 top-1.5 inline-flex h-2 w-2">
                        <span class="absolute inline-flex h-full w-full animate-ping rounded-full bg-red-400 opacity-70 motion-reduce:hidden"></span>
                        <span class="relative inline-flex h-2 w-2 rounded-full bg-red-500"
                              :class="newFeedbackAlert ? 'animate-bounce' : ''"></span>
                    </span>
                </button>

                {{-- Panel --}}
                <div x-show="open"
                    x-transition:enter="transition ease-out duration-200"
                    x-transition:enter-start="opacity-0 -translate-y-2 scale-95"
                    x-transition:enter-end="opacity-100 translate-y-0 scale-100"
                    x-transition:leave="transition ease-in duration-150"
                    x-transition:leave-start="opacity-100 translate-y-0 scale-100"
                    x-transition:leave-end="opacity-0 -translate-y-2 scale-95"
                    @click.outside="close()"
                    x-cloak
                    class="absolute right-0 top-11 z-50 w-96 rounded-2xl border border-slate-200 bg-white shadow-2xl dark:border-slate-800 dark:bg-slate-900">

                    {{-- Header --}}
                    <div class="flex items-center justify-between border-b border-slate-100 px-4 py-3 dark:border-slate-800">
                        <div class="flex items-center gap-2">
                            <svg class="h-4 w-4 text-amber-500" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z"/>
                            </svg>
                            <span class="text-sm font-semibold text-slate-800 dark:text-white">{{ __('Support Chat') }}</span>
                            <span x-show="unreadCount > 0"
                                x-text="unreadCount > 99 ? '99+' : unreadCount"
                                class="inline-flex items-center justify-center rounded-full bg-amber-500 px-1.5 py-0.5 text-[10px] font-bold leading-none text-white"></span>
                        </div>
                        <button @click="close()" class="rounded-lg p-1 text-slate-400 hover:text-slate-600 dark:hover:text-slate-200">
                            <svg class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"/>
                            </svg>
                        </button>
                    </div>

                    {{-- Body --}}
                    <div class="max-h-[420px] overflow-y-auto overscroll-contain" style="scrollbar-width:thin">

                        {{-- Loading --}}
                        <div x-show="loading" class="flex items-center justify-center py-10">
                            <div class="h-5 w-5 animate-spin rounded-full border-2 border-amber-200 border-t-amber-500"></div>
                        </div>

                        {{-- ── FEEDBACK LIST ───────────────────────────────────────── --}}
                        <div x-show="!loading">
                            <template x-if="conversations.length === 0">
                                <div class="flex flex-col items-center py-10 text-center">
                                    <svg class="h-8 w-8 text-slate-300 dark:text-slate-700" fill="none" stroke="currentColor" stroke-width="1.4" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z"/>
                                    </svg>
                                    <p class="mt-2 text-xs font-medium text-slate-400">{{ __('No support chats yet') }}</p>
                                </div>
                            </template>
                            <template x-for="conv in conversations" :key="conv.id">
                                <a :href="'/admin/support?conversation=' + conv.id"
                                    class="flex items-start gap-3 px-4 py-3 transition-colors hover:bg-slate-50 dark:hover:bg-slate-800/50"
                                    :class="(conv.unread_for_support || conv.admin_unread_count) > 0 ? 'bg-amber-50/60 dark:bg-amber-500/5' : ''">
                                    {{-- Avatar --}}
                                    <span class="relative mt-0.5 flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-slate-200 text-xs font-bold uppercase text-slate-600 dark:bg-slate-700 dark:text-slate-300"
                                        x-text="(conv.customer && conv.customer.name ? conv.customer.name.charAt(0) : '?')">
                                        {{-- Unread dot on avatar --}}
                                        <span x-show="(conv.unread_for_support || conv.admin_unread_count) > 0"
                                            class="absolute -right-0.5 -top-0.5 h-2.5 w-2.5 rounded-full border-2 border-white bg-amber-500 dark:border-slate-900"></span>
                                    </span>
                                    {{-- Info --}}
                                    <div class="min-w-0 flex-1">
                                        <div class="flex items-center gap-2">
                                            <p class="truncate text-xs font-semibold text-slate-800 dark:text-white"
                                                x-text="conv.customer ? conv.customer.name : '{{ __('Unknown user') }}'"></p>
                                            <span x-show="(conv.unread_for_support || conv.admin_unread_count) > 0"
                                                x-text="conv.unread_for_support || conv.admin_unread_count"
                                                class="inline-flex items-center justify-center rounded-full bg-amber-500 px-1.5 text-[10px] font-bold leading-4 text-white"></span>
                                        </div>
                                        <p class="mt-0.5 truncate text-[11px] text-slate-500"
                                            x-text="(conv.latest_message ? conv.latest_message.body : null) || conv.last_message || conv.subject || '{{ __('Support conversation') }}'"></p>
                                        <span class="mt-1 inline-block rounded-full px-1.5 py-0.5 text-[10px] font-semibold"
                                            :class="{
                                                'bg-green-100 text-green-700 dark:bg-green-500/20 dark:text-green-300': conv.status === 'resolved',
                                                'bg-amber-100 text-amber-700 dark:bg-amber-500/20 dark:text-amber-300': conv.status === 'open' || conv.status === 'waiting_for_support',
                                                'bg-blue-100 text-blue-700 dark:bg-blue-500/20 dark:text-blue-300': conv.status === 'new',
                                                'bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-400': !['resolved','open','waiting_for_support','new'].includes(conv.status)
                                            }"
                                            x-text="conv.status"></span>
                                    </div>
                                    {{-- Time --}}
                                    <span class="shrink-0 text-[10px] text-slate-400"
                                        x-text="timeAgo(conv.last_message_at || conv.updated_at)"></span>
                                </a>
                            </template>

                            {{-- View all --}}
                            <a href="/admin/support"
                                class="flex items-center justify-center gap-1 border-t border-slate-100 py-3 text-xs font-semibold text-amber-600 hover:text-amber-700 dark:border-slate-800 dark:text-amber-400">
                                {{ __('View all support chats') }}
                                <svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7"/>
                                </svg>
                            </a>
                        </div>
                    </div>
                </div>
            </div>

            {{-- Language toggle --}}
            <div class="relative shrink-0" x-data="{ langOpen: false }">
                <button type="button" class="inline-flex h-9 items-center gap-2 rounded-xl border border-slate-200 bg-white px-2.5 text-sm font-medium text-slate-700 shadow-sm transition-all duration-200 ease-out hover:-translate-y-0.5 hover:text-slate-900 hover:shadow-md active:translate-y-0 active:scale-95 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary-500/70 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-200 motion-reduce:transition-none" @click="langOpen = !langOpen" @keydown.escape="langOpen = false">
                    @if (app()->getLocale() === 'km')
                        <svg class="h-3.5 w-5 shrink-0 rounded-[2px] shadow-sm" viewBox="0 0 60 40">
                            <rect width="60" height="40" rx="3" fill="#032EA6"/>
                            <rect y="10" width="60" height="20" fill="#E00025"/>
                            <path fill="#FFFFFF" d="M18 27h24v-2h-3v-3h-2v3h-3v-6h-2v-3h-4v3h-2v6h-3v-3h-2v3h-3z M29 13h2v3h-2z M22 18h2v3h-2z M36 18h2v3h-2z"/>
                        </svg>
                    @else
                        <svg class="h-3.5 w-5 shrink-0 rounded-[2px] shadow-sm" viewBox="0 0 60 40">
                            <clipPath id="uk-flag-btn"><rect width="60" height="40" rx="3"/></clipPath>
                            <g clip-path="url(#uk-flag-btn)">
                                <rect width="60" height="40" fill="#012169"/>
                                <path d="M0,0 L60,40 M60,0 L0,40" stroke="#FFFFFF" stroke-width="8"/>
                                <path d="M0,0 L60,40 M60,0 L0,40" stroke="#C8102E" stroke-width="3"/>
                                <path d="M30,0 V40 M0,20 H60" stroke="#FFFFFF" stroke-width="12"/>
                                <path d="M30,0 V40 M0,20 H60" stroke="#C8102E" stroke-width="7"/>
                            </g>
                        </svg>
                    @endif
                    <span class="hidden text-xs font-semibold uppercase xl:inline">{{ app()->getLocale() }}</span>
                    <svg class="h-4 w-4 shrink-0 text-slate-400 transition-transform duration-200 ease-out" :class="langOpen ? 'rotate-180 text-slate-500' : ''" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M6 9l6 6 6-6" />
                    </svg>
                </button>
                <div class="absolute right-0 mt-2 w-36 rounded-2xl border border-slate-200 bg-white p-2 text-sm shadow-xl dark:border-slate-800 dark:bg-slate-900" x-show="langOpen" x-transition:enter="transition ease-out duration-200" x-transition:enter-start="opacity-0 -translate-y-1 scale-95" x-transition:enter-end="opacity-100 translate-y-0 scale-100" x-transition:leave="transition ease-in duration-150" x-transition:leave-start="opacity-100 translate-y-0 scale-100" x-transition:leave-end="opacity-0 -translate-y-1 scale-95" x-cloak @click.outside="langOpen = false">
                    <a href="{{ route('locale.set', 'en') }}" class="flex items-center gap-2.5 rounded-xl px-3 py-2 text-slate-600 transition-all duration-200 ease-out hover:translate-x-1 hover:bg-slate-100 hover:text-slate-900 dark:text-slate-300 dark:hover:bg-slate-800 {{ app()->getLocale() === 'en' ? 'bg-slate-50 font-semibold dark:bg-slate-800/50' : '' }}">
                        <svg class="h-3.5 w-5 shrink-0 rounded-[2px] shadow-sm" viewBox="0 0 60 40">
                            <clipPath id="uk-flag-opt"><rect width="60" height="40" rx="3"/></clipPath>
                            <g clip-path="url(#uk-flag-opt)">
                                <rect width="60" height="40" fill="#012169"/>
                                <path d="M0,0 L60,40 M60,0 L0,40" stroke="#FFFFFF" stroke-width="8"/>
                                <path d="M0,0 L60,40 M60,0 L0,40" stroke="#C8102E" stroke-width="3"/>
                                <path d="M30,0 V40 M0,20 H60" stroke="#FFFFFF" stroke-width="12"/>
                                <path d="M30,0 V40 M0,20 H60" stroke="#C8102E" stroke-width="7"/>
                            </g>
                        </svg>
                        {{ __('English') }}
                    </a>
                    <a href="{{ route('locale.set', 'km') }}" class="flex items-center gap-2.5 rounded-xl px-3 py-2 text-slate-600 transition-all duration-200 ease-out hover:translate-x-1 hover:bg-slate-100 hover:text-slate-900 dark:text-slate-300 dark:hover:bg-slate-800 {{ app()->getLocale() === 'km' ? 'bg-slate-50 font-semibold dark:bg-slate-800/50' : '' }}">
                        <svg class="h-3.5 w-5 shrink-0 rounded-[2px] shadow-sm" viewBox="0 0 60 40">
                            <rect width="60" height="40" rx="3" fill="#032EA6"/>
                            <rect y="10" width="60" height="20" fill="#E00025"/>
                            <path fill="#FFFFFF" d="M18 27h24v-2h-3v-3h-2v3h-3v-6h-2v-3h-4v3h-2v6h-3v-3h-2v3h-3z M29 13h2v3h-2z M22 18h2v3h-2z M36 18h2v3h-2z"/>
                        </svg>
                        {{ __('Khmer') }}
                    </a>
                </div>
            </div>

            {{-- Theme toggle --}}
            <button type="button" class="inline-flex h-9 shrink-0 items-center justify-center gap-2 rounded-xl border border-slate-200 bg-white px-2 text-sm font-medium text-slate-600 shadow-sm transition-all duration-200 ease-out hover:-translate-y-0.5 hover:text-slate-900 hover:shadow-md active:translate-y-0 active:scale-95 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary-500/70 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300 motion-reduce:transition-none xl:w-24 xl:px-3" @click="theme = theme === 'dark' ? 'light' : 'dark'; localStorage.setItem('theme', theme); document.documentElement.classList.toggle('dark', theme === 'dark')">
                {{-- Moon icon (shown in light mode) --}}
                <svg x-show="theme === 'light'" class="h-4 w-4 shrink-0 transition-transform duration-200 ease-out" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24" x-cloak>
                    <path stroke-linecap="round" stroke-linejoin="round" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" />
                </svg>
                {{-- Sun icon (shown in dark mode) --}}
                <svg x-show="theme === 'dark'" class="h-4 w-4 shrink-0 transition-transform duration-200 ease-out" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24" x-cloak>
                    <path stroke-linecap="round" stroke-linejoin="round" d="M12 3v2m0 14v2m9-9h-2M5 12H3m15.364 6.364l-1.414-1.414M7.05 7.05L5.636 5.636m12.728 0l-1.414 1.414M7.05 16.95l-1.414 1.414" />
                </svg>
                <span class="hidden xl:inline" x-text="theme === 'dark' ? '{{ __('Dark') }}' : '{{ __('Light') }}'">{{ __('Theme') }}</span>
            </button>

            {{-- User dropdown --}}
            <div class="relative shrink-0" x-data="{ open: false }">
                <button type="button" class="inline-flex h-9 items-center gap-2 rounded-xl border border-slate-200 bg-white px-2 text-sm font-medium text-slate-700 shadow-sm transition-all duration-200 ease-out hover:-translate-y-0.5 hover:text-slate-900 hover:shadow-md active:translate-y-0 active:scale-95 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary-500/70 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-200 motion-reduce:transition-none" @click="open = !open" @keydown.escape="open = false">
                    <span class="flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-primary-600 text-xs font-bold text-white">
                        {{ strtoupper(substr(auth()->user()?->name ?? 'A', 0, 1)) }}
                    </span>
                    <span class="hidden max-w-[10rem] truncate text-left xl:block">
                        <span class="block truncate text-xs font-semibold">{{ auth()->user()?->name ?? __('Admin') }}</span>
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
// ── Feedback Alert Toast ──────────────────────────────────────────────────────
window._adminFeedbackToast = (function () {
    var container = null;

    function ensureContainer() {
        if (container) return container;
        container = document.createElement('div');
        container.id = 'admin-feedback-toast-container';
        container.style.cssText = [
            'position:fixed',
            'top:72px',
            'right:16px',
            'z-index:9999',
            'display:flex',
            'flex-direction:column',
            'gap:8px',
            'pointer-events:none',
        ].join(';');
        document.body.appendChild(container);
        return container;
    }

    return {
        show: function (title, body, href) {
            var wrap = ensureContainer();
            var el   = document.createElement('a');
            el.href  = href || '/admin/support';
            el.style.cssText = [
                'display:flex',
                'align-items:flex-start',
                'gap:10px',
                'background:linear-gradient(135deg,#1e293b,#0f172a)',
                'color:#f1f5f9',
                'border:1px solid rgba(99,102,241,.35)',
                'border-radius:14px',
                'padding:12px 16px',
                'width:320px',
                'box-shadow:0 8px 32px rgba(0,0,0,.45)',
                'text-decoration:none',
                'pointer-events:all',
                'cursor:pointer',
                'opacity:0',
                'transform:translateX(40px)',
                'transition:opacity .3s ease,transform .3s ease',
            ].join(';');

            var icon = document.createElement('div');
            icon.style.cssText = [
                'flex-shrink:0',
                'width:36px',
                'height:36px',
                'border-radius:50%',
                'background:linear-gradient(135deg,#6366f1,#8b5cf6)',
                'display:flex',
                'align-items:center',
                'justify-content:center',
            ].join(';');
            icon.innerHTML = '<svg width="16" height="16" fill="none" stroke="#fff" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z"/></svg>';

            var text = document.createElement('div');
            text.style.cssText = 'min-width:0;flex:1';
            text.innerHTML = '<p style="font-size:12px;font-weight:700;color:#e2e8f0;margin:0 0 2px;">' + (title || '{{ __('New Support Message') }}') + '</p>'
                           + '<p style="font-size:11px;color:#94a3b8;margin:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">' + (body || '') + '</p>';

            el.appendChild(icon);
            el.appendChild(text);
            wrap.appendChild(el);

            requestAnimationFrame(function () {
                requestAnimationFrame(function () {
                    el.style.opacity  = '1';
                    el.style.transform = 'translateX(0)';
                });
            });

            setTimeout(function () {
                el.style.opacity  = '0';
                el.style.transform = 'translateX(40px)';
                setTimeout(function () { el.remove(); }, 350);
            }, 5000);
        },
    };
})();

// ── Feedback Alert Sound ──────────────────────────────────────────────────────
window._adminFeedbackSound = (function () {
    var ctx = null;
    function getCtx() {
        if (!ctx) {
            try { ctx = new (window.AudioContext || window.webkitAudioContext)(); } catch (e) {}
        }
        return ctx;
    }
    return {
        play: function () {
            try {
                var ac = getCtx();
                if (!ac) return;
                // Two-tone gentle ping
                [880, 1100].forEach(function (freq, i) {
                    var osc  = ac.createOscillator();
                    var gain = ac.createGain();
                    osc.connect(gain);
                    gain.connect(ac.destination);
                    osc.frequency.value = freq;
                    osc.type = 'sine';
                    var t = ac.currentTime + i * 0.18;
                    gain.gain.setValueAtTime(0, t);
                    gain.gain.linearRampToValueAtTime(0.18, t + 0.04);
                    gain.gain.exponentialRampToValueAtTime(0.0001, t + 0.5);
                    osc.start(t);
                    osc.stop(t + 0.5);
                });
            } catch (e) {}
        },
    };
})();

// ── Admin Notification Panel ──────────────────────────────────────────────────
function adminNotifPanel() {
    return {
        open: false,
        loading: false,
        conversations: [],
        unreadFeedbackCount: 0,
        _prevFeedbackCount: -1,   // -1 = first load, no alert yet
        newFeedbackAlert: false,  // drives bounce animation on red dot

        get unreadCount() {
            return this.unreadFeedbackCount;
        },

        init() {
            this._requestBrowserNotifPermission();
            this.fetchCounts();
            // Poll every 15 seconds for near-real-time feel
            setInterval(() => this.fetchCounts(), 15000);
        },

        _requestBrowserNotifPermission() {
            if ('Notification' in window && Notification.permission === 'default') {
                Notification.requestPermission();
            }
        },

        _fireBrowserNotification(title, body) {
            if ('Notification' in window && Notification.permission === 'granted') {
                try {
                    new Notification(title, {
                        body: body,
                        icon: '/favicon.ico',
                        tag: 'admin-feedback-' + Date.now(),
                    });
                } catch (e) {}
            }
        },

        async fetchCounts() {
            var firstRun = (this._prevFeedbackCount === -1);

            // ── Feedback / Support ───────────────────────────────────
            try {
                var res2 = await window.adminApi.request('/api/admin/support/conversations?per_page=20');
                if (res2.ok) {
                    var data2 = await res2.json();
                    var list  = data2.data || [];
                    var newCount = list.reduce(function(sum, c) {
                        return sum + (c.unread_for_support || c.admin_unread_count || 0);
                    }, 0);

                    var increased = (!firstRun) && (newCount > this._prevFeedbackCount);

                    if (increased) {
                        // Find which conversations are newly unread
                        var delta = newCount - this._prevFeedbackCount;
                        var newest = list.find(function(c) {
                            return (c.unread_for_support || c.admin_unread_count || 0) > 0;
                        });
                        var customerName = (newest && newest.customer) ? newest.customer.name : '{{ __('A customer') }}';
                        var lastMsg = (newest && newest.latest_message) ? (newest.latest_message.body || '') : '';
                        var toastTitle = customerName + ' {{ __('sent a message') }}';
                        var toastBody  = lastMsg ? lastMsg.substring(0, 80) : '{{ __('New customer message received') }}';
                        var convHref   = newest ? ('/admin/support?conversation=' + newest.id) : '/admin/support';

                        // Toast popup
                        window._adminFeedbackToast.show(toastTitle, toastBody, convHref);

                        // Browser notification
                        this._fireBrowserNotification(toastTitle, toastBody);

                        // Sound alert
                        window._adminFeedbackSound.play();

                        // Bounce the red dot
                        this.newFeedbackAlert = true;
                        var self = this;
                        setTimeout(function() { self.newFeedbackAlert = false; }, 3000);
                    }

                    this.unreadFeedbackCount = newCount;
                    this._prevFeedbackCount  = newCount;
                }
            } catch (e) {}
        },

        async toggle() {
            if (this.open) {
                this.close();
                return;
            }
            this.open = true;
            this.newFeedbackAlert = false;
            await this.load();
        },

        close() {
            this.open = false;
        },

        async load() {
            this.loading = true;
            await this.loadFeedback();
            this.loading = false;
        },

        async loadFeedback() {
            try {
                var res = await window.adminApi.request('/api/admin/support/conversations?per_page=8');
                if (res.ok) {
                    var data = await res.json();
                    this.conversations = data.data || [];
                    this.unreadFeedbackCount = this.conversations.reduce(function(sum, c) {
                        return sum + (c.unread_for_support || c.admin_unread_count || 0);
                    }, 0);
                    // Sync the tracked count on manual open
                    this._prevFeedbackCount = this.unreadFeedbackCount;
                }
            } catch (e) {
                this.conversations = [];
            }
        },

        timeAgo(iso) {
            if (!iso) return '';
            var diff = Math.floor((Date.now() - new Date(iso).getTime()) / 1000);
            if (diff < 60) return '{{ __('just now') }}';
            if (diff < 3600) return Math.floor(diff / 60) + '{{ __('m ago') }}';
            if (diff < 86400) return Math.floor(diff / 3600) + '{{ __('h ago') }}';
            return Math.floor(diff / 86400) + '{{ __('d ago') }}';
        },
    };
}
</script>

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
