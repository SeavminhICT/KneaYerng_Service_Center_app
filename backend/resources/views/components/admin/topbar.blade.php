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
                        <span class="relative inline-flex h-2 w-2 rounded-full bg-red-500"></span>
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
                            <span class="text-sm font-semibold text-slate-800 dark:text-white">{{ __('Notifications') }}</span>
                            <span x-show="unreadCount > 0"
                                x-text="unreadCount > 99 ? '99+' : unreadCount"
                                class="inline-flex items-center justify-center rounded-full bg-red-500 px-1.5 py-0.5 text-[10px] font-bold leading-none text-white"></span>
                        </div>
                        <button @click="close()" class="rounded-lg p-1 text-slate-400 hover:text-slate-600 dark:hover:text-slate-200">
                            <svg class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"/>
                            </svg>
                        </button>
                    </div>

                    {{-- Tabs --}}
                    <div class="flex border-b border-slate-100 dark:border-slate-800">
                        <button @click="activeTab = 'orders'"
                            :class="activeTab === 'orders' ? 'border-b-2 border-primary-500 text-primary-600 dark:text-primary-400' : 'text-slate-500 hover:text-slate-700 dark:hover:text-slate-200'"
                            class="flex flex-1 items-center justify-center gap-1.5 px-4 py-2.5 text-xs font-semibold transition-colors">
                            <svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"/>
                            </svg>
                            {{ __('Orders') }}
                            <span x-show="newOrdersCount > 0" x-text="newOrdersCount"
                                class="inline-flex items-center justify-center rounded-full bg-primary-100 px-1.5 text-[10px] font-bold text-primary-700 dark:bg-primary-500/20 dark:text-primary-300"></span>
                        </button>
                        <button @click="activeTab = 'feedback'"
                            :class="activeTab === 'feedback' ? 'border-b-2 border-primary-500 text-primary-600 dark:text-primary-400' : 'text-slate-500 hover:text-slate-700 dark:hover:text-slate-200'"
                            class="flex flex-1 items-center justify-center gap-1.5 px-4 py-2.5 text-xs font-semibold transition-colors">
                            <svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z"/>
                            </svg>
                            {{ __('Feedback') }}
                            <span x-show="unreadFeedbackCount > 0" x-text="unreadFeedbackCount"
                                class="inline-flex items-center justify-center rounded-full bg-amber-100 px-1.5 text-[10px] font-bold text-amber-700 dark:bg-amber-500/20 dark:text-amber-300"></span>
                        </button>
                    </div>

                    {{-- Body --}}
                    <div class="max-h-[420px] overflow-y-auto overscroll-contain" style="scrollbar-width:thin">

                        {{-- Loading --}}
                        <div x-show="loading" class="flex items-center justify-center py-10">
                            <div class="h-5 w-5 animate-spin rounded-full border-2 border-primary-200 border-t-primary-600"></div>
                        </div>

                        {{-- ── ORDERS TAB ─────────────────────────────────────────── --}}
                        <div x-show="!loading && activeTab === 'orders'">
                            <template x-if="orders.length === 0">
                                <div class="flex flex-col items-center py-10 text-center">
                                    <svg class="h-8 w-8 text-slate-300 dark:text-slate-700" fill="none" stroke="currentColor" stroke-width="1.4" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"/>
                                    </svg>
                                    <p class="mt-2 text-xs font-medium text-slate-400">{{ __('No recent orders') }}</p>
                                </div>
                            </template>
                            <template x-for="order in orders" :key="order.id">
                                <a :href="'/admin/orders/' + order.id"
                                    class="flex items-start gap-3 px-4 py-3 transition-colors hover:bg-slate-50 dark:hover:bg-slate-800/50">
                                    {{-- Icon --}}
                                    <span class="mt-0.5 flex h-8 w-8 shrink-0 items-center justify-center rounded-xl"
                                        :class="{
                                            'bg-green-100 text-green-600 dark:bg-green-500/10 dark:text-green-400': order.payment_status === 'paid',
                                            'bg-amber-100 text-amber-600 dark:bg-amber-500/10 dark:text-amber-400': order.payment_status === 'unpaid',
                                            'bg-slate-100 text-slate-500 dark:bg-slate-800 dark:text-slate-400': order.payment_status !== 'paid' && order.payment_status !== 'unpaid'
                                        }">
                                        <svg class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"/>
                                        </svg>
                                    </span>
                                    {{-- Info --}}
                                    <div class="min-w-0 flex-1">
                                        <p class="truncate text-xs font-semibold text-slate-800 dark:text-white"
                                            x-text="order.customer_name || order.order_number"></p>
                                        <p class="mt-0.5 truncate text-[11px] text-slate-500"
                                            x-text="'#' + (order.order_number || order.id) + ' · ' + (order.order_type || 'order')"></p>
                                        <div class="mt-1 flex items-center gap-2">
                                            <span class="rounded-full px-1.5 py-0.5 text-[10px] font-bold"
                                                :class="{
                                                    'bg-green-100 text-green-700 dark:bg-green-500/20 dark:text-green-300': order.payment_status === 'paid',
                                                    'bg-amber-100 text-amber-700 dark:bg-amber-500/20 dark:text-amber-300': order.payment_status === 'unpaid',
                                                    'bg-red-100 text-red-700 dark:bg-red-500/20 dark:text-red-300': order.payment_status === 'failed',
                                                    'bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-300': !['paid','unpaid','failed'].includes(order.payment_status)
                                                }"
                                                x-text="order.payment_status"></span>
                                            <span class="text-[11px] font-semibold text-slate-700 dark:text-slate-300"
                                                x-text="'$' + (parseFloat(order.total_amount || 0).toFixed(2))"></span>
                                        </div>
                                    </div>
                                    {{-- Time --}}
                                    <span class="shrink-0 text-[10px] text-slate-400" x-text="timeAgo(order.placed_at || order.created_at)"></span>
                                </a>
                            </template>

                            {{-- View all --}}
                            <a href="/admin/orders"
                                class="flex items-center justify-center gap-1 border-t border-slate-100 py-3 text-xs font-semibold text-primary-600 hover:text-primary-700 dark:border-slate-800 dark:text-primary-400">
                                {{ __('View all orders') }}
                                <svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7"/>
                                </svg>
                            </a>
                        </div>

                        {{-- ── FEEDBACK TAB ───────────────────────────────────────── --}}
                        <div x-show="!loading && activeTab === 'feedback'">
                            <template x-if="conversations.length === 0">
                                <div class="flex flex-col items-center py-10 text-center">
                                    <svg class="h-8 w-8 text-slate-300 dark:text-slate-700" fill="none" stroke="currentColor" stroke-width="1.4" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z"/>
                                    </svg>
                                    <p class="mt-2 text-xs font-medium text-slate-400">{{ __('No feedback yet') }}</p>
                                </div>
                            </template>
                            <template x-for="conv in conversations" :key="conv.id">
                                <a :href="'/admin/support?conversation=' + conv.id"
                                    class="flex items-start gap-3 px-4 py-3 transition-colors hover:bg-slate-50 dark:hover:bg-slate-800/50"
                                    :class="conv.admin_unread_count > 0 ? 'bg-primary-50/60 dark:bg-primary-500/5' : ''">
                                    {{-- Avatar --}}
                                    <span class="mt-0.5 flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-slate-200 text-xs font-bold uppercase text-slate-600 dark:bg-slate-700 dark:text-slate-300"
                                        x-text="(conv.customer && conv.customer.name ? conv.customer.name.charAt(0) : '?')"></span>
                                    {{-- Info --}}
                                    <div class="min-w-0 flex-1">
                                        <div class="flex items-center gap-2">
                                            <p class="truncate text-xs font-semibold text-slate-800 dark:text-white"
                                                x-text="conv.customer ? conv.customer.name : '{{ __('Unknown user') }}'"></p>
                                            <span x-show="conv.admin_unread_count > 0"
                                                :x-text="conv.admin_unread_count"
                                                class="inline-flex items-center justify-center rounded-full bg-primary-600 px-1.5 text-[10px] font-bold leading-4 text-white"></span>
                                        </div>
                                        <p class="mt-0.5 truncate text-[11px] text-slate-500"
                                            x-text="conv.last_message || conv.subject || '{{ __('Support conversation') }}'"></p>
                                        <span class="mt-1 inline-block rounded-full px-1.5 py-0.5 text-[10px] font-semibold"
                                            :class="{
                                                'bg-green-100 text-green-700 dark:bg-green-500/20 dark:text-green-300': conv.status === 'resolved',
                                                'bg-amber-100 text-amber-700 dark:bg-amber-500/20 dark:text-amber-300': conv.status === 'open',
                                                'bg-blue-100 text-blue-700 dark:bg-blue-500/20 dark:text-blue-300': conv.status === 'new',
                                                'bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-400': !['resolved','open','new'].includes(conv.status)
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
                                class="flex items-center justify-center gap-1 border-t border-slate-100 py-3 text-xs font-semibold text-primary-600 hover:text-primary-700 dark:border-slate-800 dark:text-primary-400">
                                {{ __('View all support') }}
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
                <button type="button" class="inline-flex h-9 items-center gap-1 rounded-xl border border-slate-200 bg-white px-2 text-sm font-medium text-slate-700 shadow-sm transition-all duration-200 ease-out hover:-translate-y-0.5 hover:text-slate-900 hover:shadow-md active:translate-y-0 active:scale-95 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary-500/70 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-200 motion-reduce:transition-none" @click="langOpen = !langOpen" @keydown.escape="langOpen = false">
                    <span class="text-base leading-none xl:mr-1">{{ app()->getLocale() === 'km' ? '🇰🇭' : '🇬🇧' }}</span>
                    <span class="hidden text-xs font-semibold uppercase xl:inline">{{ app()->getLocale() }}</span>
                    <svg class="h-4 w-4 shrink-0 text-slate-400 transition-transform duration-200 ease-out" :class="langOpen ? 'rotate-180 text-slate-500' : ''" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M6 9l6 6 6-6" />
                    </svg>
                </button>
                <div class="absolute right-0 mt-2 w-36 rounded-2xl border border-slate-200 bg-white p-2 text-sm shadow-xl dark:border-slate-800 dark:bg-slate-900" x-show="langOpen" x-transition:enter="transition ease-out duration-200" x-transition:enter-start="opacity-0 -translate-y-1 scale-95" x-transition:enter-end="opacity-100 translate-y-0 scale-100" x-transition:leave="transition ease-in duration-150" x-transition:leave-start="opacity-100 translate-y-0 scale-100" x-transition:leave-end="opacity-0 -translate-y-1 scale-95" x-cloak @click.outside="langOpen = false">
                    <a href="{{ route('locale.set', 'en') }}" class="flex items-center gap-3 rounded-xl px-3 py-2 text-slate-600 transition-all duration-200 ease-out hover:translate-x-1 hover:bg-slate-100 hover:text-slate-900 dark:text-slate-300 dark:hover:bg-slate-800 {{ app()->getLocale() === 'en' ? 'bg-slate-50 font-semibold dark:bg-slate-800/50' : '' }}">
                        <span class="text-base leading-none">🇬🇧</span> {{ __('English') }}
                    </a>
                    <a href="{{ route('locale.set', 'km') }}" class="flex items-center gap-3 rounded-xl px-3 py-2 text-slate-600 transition-all duration-200 ease-out hover:translate-x-1 hover:bg-slate-100 hover:text-slate-900 dark:text-slate-300 dark:hover:bg-slate-800 {{ app()->getLocale() === 'km' ? 'bg-slate-50 font-semibold dark:bg-slate-800/50' : '' }}">
                        <span class="text-base leading-none">🇰🇭</span> {{ __('Khmer') }}
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
function adminNotifPanel() {
    return {
        open: false,
        loading: false,
        activeTab: 'orders',
        orders: [],
        conversations: [],
        newOrdersCount: 0,
        unreadFeedbackCount: 0,

        get unreadCount() {
            return this.newOrdersCount + this.unreadFeedbackCount;
        },

        init() {
            // Poll for counts every 60 seconds
            this.fetchCounts();
            setInterval(() => this.fetchCounts(), 60000);
        },

        async fetchCounts() {
            try {
                // Fetch recent orders count (new/pending)
                var res = await window.adminApi.request('/api/admin/orders/summary');
                if (res.ok) {
                    var data = await res.json();
                    this.newOrdersCount = (data.pending_count || data.pending || 0);
                }
            } catch (e) {}

            try {
                // Fetch unread feedback count
                var res2 = await window.adminApi.request('/api/admin/support/conversations?per_page=20');
                if (res2.ok) {
                    var data2 = await res2.json();
                    var list = data2.data || [];
                    this.unreadFeedbackCount = list.reduce(function(sum, c) {
                        return sum + (c.admin_unread_count || 0);
                    }, 0);
                }
            } catch (e) {}
        },

        async toggle() {
            if (this.open) {
                this.close();
                return;
            }
            this.open = true;
            await this.load();
        },

        close() {
            this.open = false;
        },

        async load() {
            this.loading = true;
            await Promise.all([this.loadOrders(), this.loadFeedback()]);
            this.loading = false;
        },

        async loadOrders() {
            try {
                var res = await window.adminApi.request('/api/orders?per_page=8&sort=newest');
                if (res.ok) {
                    var data = await res.json();
                    this.orders = data.data || [];
                    this.newOrdersCount = this.orders.filter(function(o) {
                        return o.payment_status === 'unpaid' || o.status === 'pending';
                    }).length;
                }
            } catch (e) {
                this.orders = [];
            }
        },

        async loadFeedback() {
            try {
                var res = await window.adminApi.request('/api/admin/support/conversations?per_page=8');
                if (res.ok) {
                    var data = await res.json();
                    this.conversations = data.data || [];
                    this.unreadFeedbackCount = this.conversations.reduce(function(sum, c) {
                        return sum + (c.admin_unread_count || 0);
                    }, 0);
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
