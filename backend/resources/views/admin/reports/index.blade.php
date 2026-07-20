@extends('layouts.admin')

@section('title', __('Business Intelligence & Reports'))
@section('page-title', __('Business Intelligence & Reports'))

@section('content')
<div class="space-y-6" id="report-root">

    {{-- ── Header Banner ────────────────────────────────────────────────── --}}
    <div class="relative overflow-hidden rounded-2xl bg-gradient-to-r from-slate-900 via-indigo-950 to-slate-900 p-6 text-white shadow-xl dark:border dark:border-slate-800">
        <div class="absolute -right-10 -top-10 h-40 w-40 rounded-full bg-primary-500/10 blur-3xl"></div>
        <div class="relative z-10 flex flex-col justify-between gap-4 md:flex-row md:items-center">
            <div>
                <div class="inline-flex items-center gap-2 rounded-full bg-primary-500/20 px-3 py-1 text-xs font-semibold text-primary-300 backdrop-blur-md">
                    <span class="h-2 w-2 rounded-full bg-primary-400 animate-pulse"></span>
                    {{ __('BI Data Visualizations & Analytics') }}
                </div>
                <h1 class="mt-2 text-2xl font-extrabold tracking-tight text-white sm:text-3xl">
                    {{ __('Analytics & Executive Reports') }}
                </h1>
                <p class="mt-1 text-sm text-slate-300">
                    {{ __('Monitor revenue trends, customer growth, inventory health, and repair operations with actionable insights.') }}
                </p>
            </div>
            <div class="flex items-center gap-3">
                <span id="live-range-badge" class="hidden rounded-xl border border-slate-700/60 bg-slate-900/80 px-3 py-1.5 text-xs font-medium text-slate-300 backdrop-blur-md">
                    <span id="range-label-text" class="font-semibold text-white"></span>
                </span>
            </div>
        </div>
    </div>

    {{-- ── BI Navigation Tabs & Filter Bar ───────────────────────────────── --}}
    <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">

        {{-- Tabbed Navigation --}}
        <div class="flex flex-wrap items-center justify-between gap-4 border-b border-slate-100 pb-5 dark:border-slate-800">
            <div class="flex flex-wrap items-center gap-2" id="report-tabs">
                <button data-tab="sales" class="tab-btn inline-flex items-center gap-2 rounded-xl px-4 py-2.5 text-sm font-semibold transition-all bg-primary-600 text-white shadow-md shadow-primary-600/20">
                    <svg class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6"/></svg>
                    {{ __('Sales Analytics') }}
                </button>
                <button data-tab="customers" class="tab-btn inline-flex items-center gap-2 rounded-xl px-4 py-2.5 text-sm font-semibold transition-all text-slate-600 hover:bg-slate-100 dark:text-slate-300 dark:hover:bg-slate-800">
                    <svg class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"/></svg>
                    {{ __('Customer Intelligence') }}
                </button>
                <button data-tab="inventory" class="tab-btn inline-flex items-center gap-2 rounded-xl px-4 py-2.5 text-sm font-semibold transition-all text-slate-600 hover:bg-slate-100 dark:text-slate-300 dark:hover:bg-slate-800">
                    <svg class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"/></svg>
                    {{ __('Inventory & Stock') }}
                </button>
                <button data-tab="repairs" class="tab-btn inline-flex items-center gap-2 rounded-xl px-4 py-2.5 text-sm font-semibold transition-all text-slate-600 hover:bg-slate-100 dark:text-slate-300 dark:hover:bg-slate-800">
                    <svg class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/></svg>
                    {{ __('Repair Operations') }}
                </button>
            </div>

            {{-- Hidden sync input --}}
            <input type="hidden" id="report-type" value="sales" />
        </div>

        {{-- Filter controls --}}
        <div class="mt-5 flex flex-wrap items-end gap-4">

            {{-- Preset --}}
            <div class="flex-1 min-w-[160px]">
                <label class="text-xs font-semibold uppercase tracking-wider text-slate-400 dark:text-slate-400">{{ __('Date Range') }}</label>
                <select id="report-preset" class="mt-2 h-10 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-200">
                    <option value="last_7_days">{{ __('Last 7 days') }}</option>
                    <option value="last_30_days" selected>{{ __('Last 30 days') }}</option>
                    <option value="last_90_days">{{ __('Last 90 days') }}</option>
                    <option value="this_month">{{ __('This month') }}</option>
                    <option value="last_month">{{ __('Last month') }}</option>
                    <option value="year_to_date">{{ __('Year to date') }}</option>
                    <option value="custom">{{ __('Custom range') }}</option>
                </select>
            </div>

            {{-- Custom start --}}
            <div id="custom-start-wrap" class="hidden flex-1 min-w-[130px]">
                <label class="text-xs font-semibold uppercase tracking-wider text-slate-400 dark:text-slate-400">{{ __('From') }}</label>
                <input id="report-start" type="date" class="mt-2 h-10 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-200" />
            </div>

            {{-- Custom end --}}
            <div id="custom-end-wrap" class="hidden flex-1 min-w-[130px]">
                <label class="text-xs font-semibold uppercase tracking-wider text-slate-400 dark:text-slate-400">{{ __('To') }}</label>
                <input id="report-end" type="date" class="mt-2 h-10 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-200" />
            </div>

            {{-- Threshold (Inventory tab only) --}}
            <div id="threshold-wrap" class="hidden min-w-[110px]">
                <label class="text-xs font-semibold uppercase tracking-wider text-slate-400 dark:text-slate-400">{{ __('Low Threshold') }}</label>
                <input id="report-threshold" type="number" min="1" max="500" value="10" class="mt-2 h-10 w-24 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-200" />
            </div>

            {{-- Actions --}}
            <div class="flex items-center gap-3">

                {{-- Generate Button --}}
                <button id="btn-generate"
                        class="inline-flex h-10 items-center gap-2 rounded-xl bg-primary-600 px-5 text-sm font-semibold text-white shadow-md hover:bg-primary-700 active:scale-95 transition-all disabled:opacity-50">
                    <svg class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
                    </svg>
                    {{ __('Generate Report') }}
                </button>

                {{-- Export Dropdown Selector --}}
                <div class="relative inline-block text-left" id="export-dropdown-container">
                    <button id="btn-export-toggle" type="button"
                            class="inline-flex h-10 items-center gap-2 rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-700 shadow-sm hover:bg-slate-50 hover:text-slate-900 dark:border-slate-700 dark:bg-slate-800 dark:text-slate-200 dark:hover:bg-slate-700 transition-all">
                        <svg class="h-4 w-4 text-slate-500 dark:text-slate-400" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"/>
                        </svg>
                        <span>{{ __('Export Report') }}</span>
                        <svg class="h-3.5 w-3.5 text-slate-400" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"/>
                        </svg>
                    </button>

                    <div id="export-dropdown-menu" class="hidden absolute right-0 z-30 mt-2 w-56 origin-top-right rounded-2xl border border-slate-200 bg-white p-2 shadow-xl ring-1 ring-black/5 dark:border-slate-800 dark:bg-slate-900">
                        <div class="px-3 py-2 border-b border-slate-100 dark:border-slate-800">
                            <p class="text-xs font-semibold uppercase tracking-wider text-slate-400">{{ __('Select Format') }}</p>
                        </div>
                        <button id="export-excel-opt" type="button" class="flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-left text-sm font-medium text-slate-700 hover:bg-emerald-50 hover:text-emerald-700 dark:text-slate-200 dark:hover:bg-emerald-500/10 dark:hover:text-emerald-400 transition-all">
                            <span class="flex h-8 w-8 items-center justify-center rounded-lg bg-emerald-100 text-emerald-600 dark:bg-emerald-500/20 dark:text-emerald-400">
                                📊
                            </span>
                            <div>
                                <p class="font-semibold">{{ __('Export as Excel') }}</p>
                                <p class="text-xs text-slate-400">{{ __('Formatted Spreadsheet (.xlsx)') }}</p>
                            </div>
                        </button>
                        <button id="export-pdf-opt" type="button" class="mt-1 flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-left text-sm font-medium text-slate-700 hover:bg-red-50 hover:text-red-700 dark:text-slate-200 dark:hover:bg-red-500/10 dark:hover:text-red-400 transition-all">
                            <span class="flex h-8 w-8 items-center justify-center rounded-lg bg-red-100 text-red-600 dark:bg-red-500/20 dark:text-red-400">
                                📄
                            </span>
                            <div>
                                <p class="font-semibold">{{ __('Export as PDF') }}</p>
                                <p class="text-xs text-slate-400">{{ __('Executive Document (.pdf)') }}</p>
                            </div>
                        </button>
                    </div>
                </div>

            </div>
        </div>
    </div>

    {{-- ── Loading Spinner ─────────────────────────────────────────────────── --}}
    <div id="report-loading" class="hidden flex items-center justify-center py-20">
        <div class="flex items-center gap-3 rounded-2xl border border-slate-200 bg-white px-6 py-4 shadow-lg dark:border-slate-800 dark:bg-slate-900">
            <div class="h-6 w-6 animate-spin rounded-full border-3 border-primary-200 border-t-primary-600"></div>
            <span class="text-sm font-semibold text-slate-700 dark:text-slate-200">{{ __('Generating analytics & compiling report data...') }}</span>
        </div>
    </div>

    {{-- ── 1. Sales Analytics Panel ────────────────────────────────────────── --}}
    <div id="sales-panel" class="space-y-6">

        {{-- KPI Cards --}}
        <div class="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900 hover:shadow-md transition-all">
                <div class="flex items-center justify-between">
                    <p class="text-xs font-semibold uppercase tracking-wider text-slate-400">{{ __('Total Revenue') }}</p>
                    <span class="flex h-10 w-10 items-center justify-center rounded-xl bg-emerald-100 dark:bg-emerald-500/10">
                        <svg class="h-5 w-5 text-emerald-600 dark:text-emerald-400" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                    </span>
                </div>
                <p id="kpi-revenue" class="mt-3 text-2xl font-extrabold text-slate-900 dark:text-white">$0.00</p>
                <div class="mt-2 flex items-center gap-1.5 text-xs text-emerald-600 dark:text-emerald-400">
                    <span class="font-medium">Total sales revenue in period</span>
                </div>
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900 hover:shadow-md transition-all">
                <div class="flex items-center justify-between">
                    <p class="text-xs font-semibold uppercase tracking-wider text-slate-400">{{ __('Total Orders') }}</p>
                    <span class="flex h-10 w-10 items-center justify-center rounded-xl bg-indigo-100 dark:bg-indigo-500/10">
                        <svg class="h-5 w-5 text-indigo-600 dark:text-indigo-400" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"/></svg>
                    </span>
                </div>
                <p id="kpi-orders" class="mt-3 text-2xl font-extrabold text-slate-900 dark:text-white">0</p>
                <div class="mt-2 flex items-center gap-1.5 text-xs text-indigo-600 dark:text-indigo-400">
                    <span class="font-medium">Orders placed by customers</span>
                </div>
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900 hover:shadow-md transition-all">
                <div class="flex items-center justify-between">
                    <p class="text-xs font-semibold uppercase tracking-wider text-slate-400">{{ __('Avg Order Value') }}</p>
                    <span class="flex h-10 w-10 items-center justify-center rounded-xl bg-purple-100 dark:bg-purple-500/10">
                        <svg class="h-5 w-5 text-purple-600 dark:text-purple-400" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/></svg>
                    </span>
                </div>
                <p id="kpi-avg" class="mt-3 text-2xl font-extrabold text-slate-900 dark:text-white">$0.00</p>
                <div class="mt-2 flex items-center gap-1.5 text-xs text-purple-600 dark:text-purple-400">
                    <span class="font-medium">Average checkout size</span>
                </div>
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900 hover:shadow-md transition-all">
                <div class="flex items-center justify-between">
                    <p class="text-xs font-semibold uppercase tracking-wider text-slate-400">{{ __('Paid Orders') }}</p>
                    <span class="flex h-10 w-10 items-center justify-center rounded-xl bg-blue-100 dark:bg-blue-500/10">
                        <svg class="h-5 w-5 text-blue-600 dark:text-blue-400" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                    </span>
                </div>
                <p id="kpi-paid" class="mt-3 text-2xl font-extrabold text-slate-900 dark:text-white">0</p>
                <div class="mt-2 flex items-center gap-1.5 text-xs text-blue-600 dark:text-blue-400">
                    <span class="font-medium">Successful transactions</span>
                </div>
            </div>
        </div>

        {{-- BI Charts Grid --}}
        <div class="grid gap-6 xl:grid-cols-3">

            {{-- Line Chart: Daily Revenue Trend --}}
            <div class="xl:col-span-2 rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <div class="flex items-center justify-between">
                    <div>
                        <h3 class="text-base font-bold text-slate-900 dark:text-white">{{ __('Revenue Trend & Daily Performance') }}</h3>
                        <p id="chart-range" class="text-xs text-slate-400 mt-0.5">{{ __('Daily revenue breakdown over selected period') }}</p>
                    </div>
                    <span class="rounded-lg bg-primary-50 px-2.5 py-1 text-xs font-semibold text-primary-600 dark:bg-primary-500/10 dark:text-primary-400">
                        {{ __('BI Area Chart') }}
                    </span>
                </div>
                <div class="mt-5 h-72">
                    <canvas id="sales-chart"></canvas>
                </div>
            </div>

            {{-- Payment Breakdown Doughnut --}}
            <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900 flex flex-col justify-between">
                <div>
                    <h3 class="text-base font-bold text-slate-900 dark:text-white">{{ __('Payment Status Share') }}</h3>
                    <p class="text-xs text-slate-400 mt-0.5">{{ __('Transaction fulfillment ratio') }}</p>
                    <div class="mt-4 h-48 relative flex items-center justify-center">
                        <canvas id="payment-donut-chart"></canvas>
                    </div>
                </div>
                <div class="mt-4 border-t border-slate-100 pt-4 dark:border-slate-800 space-y-2.5">
                    <div class="flex items-center justify-between text-xs">
                        <span class="flex items-center gap-2 text-slate-600 dark:text-slate-300">
                            <span class="h-2.5 w-2.5 rounded-full bg-emerald-500"></span> {{ __('Paid') }}
                        </span>
                        <span id="pay-paid" class="font-bold text-slate-900 dark:text-white">0</span>
                    </div>
                    <div class="flex items-center justify-between text-xs">
                        <span class="flex items-center gap-2 text-slate-600 dark:text-slate-300">
                            <span class="h-2.5 w-2.5 rounded-full bg-amber-400"></span> {{ __('Unpaid') }}
                        </span>
                        <span id="pay-unpaid" class="font-bold text-slate-900 dark:text-white">0</span>
                    </div>
                    <div class="flex items-center justify-between text-xs">
                        <span class="flex items-center gap-2 text-slate-600 dark:text-slate-300">
                            <span class="h-2.5 w-2.5 rounded-full bg-red-400"></span> {{ __('Failed') }}
                        </span>
                        <span id="pay-failed" class="font-bold text-slate-900 dark:text-white">0</span>
                    </div>
                    <div class="mt-3">
                        <div class="flex justify-between text-xs font-semibold text-slate-600 dark:text-slate-300">
                            <span>{{ __('Fulfillment Rate') }}</span>
                            <span id="pay-rate-label">0%</span>
                        </div>
                        <div class="mt-1.5 h-2 w-full overflow-hidden rounded-full bg-slate-100 dark:bg-slate-800">
                            <div id="pay-rate-bar" class="h-full bg-emerald-500 transition-all duration-700" style="width: 0%"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        {{-- Top Revenue Products Table --}}
        <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <h3 class="text-base font-bold text-slate-900 dark:text-white mb-4">{{ __('Top Performing Products by Revenue') }}</h3>
            <div class="overflow-x-auto">
                <table class="w-full text-left text-sm">
                    <thead class="bg-slate-50 text-xs uppercase tracking-wider text-slate-400 dark:bg-slate-800/60">
                        <tr>
                            <th class="px-4 py-3 rounded-l-xl">#</th>
                            <th class="px-4 py-3">{{ __('Product') }}</th>
                            <th class="px-4 py-3">{{ __('Type') }}</th>
                            <th class="px-4 py-3">{{ __('Qty Sold') }}</th>
                            <th class="px-4 py-3 text-right rounded-r-xl">{{ __('Revenue ($)') }}</th>
                        </tr>
                    </thead>
                    <tbody id="top-products-body" class="divide-y divide-slate-100 text-slate-600 dark:divide-slate-800 dark:text-slate-300">
                        <tr><td colspan="5" class="px-4 py-8 text-center text-xs text-slate-400">{{ __('Click Generate Report to load data.') }}</td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    {{-- ── 2. Customer Intelligence Panel ──────────────────────────────────── --}}
    <div id="customers-panel" class="hidden space-y-6">

        {{-- KPI Cards --}}
        <div class="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900 hover:shadow-md transition-all">
                <p class="text-xs font-semibold uppercase tracking-wider text-slate-400">{{ __('Total Customers') }}</p>
                <p id="c-total" class="mt-3 text-2xl font-extrabold text-slate-900 dark:text-white">0</p>
                <p class="mt-1 text-xs text-slate-400">{{ __('Registered accounts') }}</p>
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900 hover:shadow-md transition-all">
                <p class="text-xs font-semibold uppercase tracking-wider text-slate-400">{{ __('New Customers') }}</p>
                <p id="c-new" class="mt-3 text-2xl font-extrabold text-emerald-600 dark:text-emerald-400">0</p>
                <p class="mt-1 text-xs text-emerald-600 dark:text-emerald-400">{{ __('Joined in this period') }}</p>
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900 hover:shadow-md transition-all">
                <p class="text-xs font-semibold uppercase tracking-wider text-slate-400">{{ __('Active Customers') }}</p>
                <p id="c-active" class="mt-3 text-2xl font-extrabold text-indigo-600 dark:text-indigo-400">0</p>
                <p class="mt-1 text-xs text-indigo-600 dark:text-indigo-400">{{ __('Made at least 1 order') }}</p>
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900 hover:shadow-md transition-all">
                <p class="text-xs font-semibold uppercase tracking-wider text-slate-400">{{ __('Repeat Customers') }}</p>
                <p id="c-repeat" class="mt-3 text-2xl font-extrabold text-purple-600 dark:text-purple-400">0</p>
                <p class="mt-1 text-xs text-purple-600 dark:text-purple-400">{{ __('2+ orders in period') }}</p>
            </div>
        </div>

        {{-- BI Customer Segmentation Chart + Leaderboard --}}
        <div class="grid gap-6 xl:grid-cols-3">
            <div class="xl:col-span-1 rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <h3 class="text-base font-bold text-slate-900 dark:text-white mb-2">{{ __('Customer Segmentation') }}</h3>
                <div class="h-64 relative flex items-center justify-center">
                    <canvas id="customer-segment-chart"></canvas>
                </div>
            </div>

            <div class="xl:col-span-2 rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <h3 class="text-base font-bold text-slate-900 dark:text-white mb-4">{{ __('Top Customers Leaderboard') }}</h3>
                <div class="overflow-x-auto">
                    <table class="w-full text-left text-sm">
                        <thead class="bg-slate-50 text-xs uppercase tracking-wider text-slate-400 dark:bg-slate-800/60">
                            <tr>
                                <th class="px-4 py-3 rounded-l-xl">#</th>
                                <th class="px-4 py-3">{{ __('Customer') }}</th>
                                <th class="px-4 py-3">{{ __('Email') }}</th>
                                <th class="px-4 py-3">{{ __('Orders') }}</th>
                                <th class="px-4 py-3 text-right rounded-r-xl">{{ __('Total Spent') }}</th>
                            </tr>
                        </thead>
                        <tbody id="top-customers-body" class="divide-y divide-slate-100 text-slate-600 dark:divide-slate-800 dark:text-slate-300">
                            <tr><td colspan="5" class="px-4 py-8 text-center text-xs text-slate-400">{{ __('Click Generate Report to load data.') }}</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    {{-- ── 3. Inventory & Stock Panel ──────────────────────────────────────── --}}
    <div id="inventory-panel" class="hidden space-y-6">

        {{-- KPI Cards --}}
        <div class="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900 hover:shadow-md transition-all">
                <p class="text-xs font-semibold uppercase tracking-wider text-slate-400">{{ __('Products') }}</p>
                <p id="inv-products" class="mt-3 text-2xl font-extrabold text-slate-900 dark:text-white">0</p>
                <p class="text-xs text-slate-400 mt-1">{{ __('Active product catalog') }}</p>
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900 hover:shadow-md transition-all">
                <p class="text-xs font-semibold uppercase tracking-wider text-slate-400">{{ __('Accessories') }}</p>
                <p id="inv-accessories" class="mt-3 text-2xl font-extrabold text-slate-900 dark:text-white">0</p>
                <p class="text-xs text-slate-400 mt-1">{{ __('Accessory items count') }}</p>
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900 hover:shadow-md transition-all">
                <p class="text-xs font-semibold uppercase tracking-wider text-slate-400">{{ __('Spare Parts') }}</p>
                <p id="inv-parts" class="mt-3 text-2xl font-extrabold text-slate-900 dark:text-white">0</p>
                <p class="text-xs text-slate-400 mt-1">{{ __('Repair parts inventory') }}</p>
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900 hover:shadow-md transition-all">
                <p class="text-xs font-semibold uppercase tracking-wider text-slate-400">{{ __('Low Stock Alert') }}</p>
                <p id="inv-low" class="mt-3 text-2xl font-extrabold text-red-500">0</p>
                <p class="text-xs text-red-500 mt-1">{{ __('Items below threshold') }}</p>
            </div>
        </div>

        {{-- Category Share BI Chart + Low Stock Table --}}
        <div class="grid gap-6 xl:grid-cols-3">
            <div class="xl:col-span-1 rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <h3 class="text-base font-bold text-slate-900 dark:text-white mb-2">{{ __('Catalog Share Distribution') }}</h3>
                <div class="h-64 relative flex items-center justify-center">
                    <canvas id="inventory-cat-chart"></canvas>
                </div>
            </div>

            <div class="xl:col-span-2 rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <h3 class="text-base font-bold text-slate-900 dark:text-white mb-4">{{ __('Low Stock Warning Items') }}</h3>
                <div class="overflow-x-auto">
                    <table class="w-full text-left text-sm">
                        <thead class="bg-slate-50 text-xs uppercase tracking-wider text-slate-400 dark:bg-slate-800/60">
                            <tr>
                                <th class="px-4 py-3 rounded-l-xl">#</th>
                                <th class="px-4 py-3">{{ __('Item Name') }}</th>
                                <th class="px-4 py-3">{{ __('Category') }}</th>
                                <th class="px-4 py-3">{{ __('SKU') }}</th>
                                <th class="px-4 py-3 text-right rounded-r-xl">{{ __('Stock Quantity') }}</th>
                            </tr>
                        </thead>
                        <tbody id="low-stock-body" class="divide-y divide-slate-100 text-slate-600 dark:divide-slate-800 dark:text-slate-300">
                            <tr><td colspan="5" class="px-4 py-8 text-center text-xs text-slate-400">{{ __('Click Generate Report to load data.') }}</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    {{-- ── 4. Repair Operations Panel ──────────────────────────────────────── --}}
    <div id="repairs-panel" class="hidden space-y-6">

        {{-- KPI Cards --}}
        <div class="grid gap-4 sm:grid-cols-3">
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900 hover:shadow-md transition-all">
                <div class="flex items-center justify-between">
                    <p class="text-xs font-semibold uppercase tracking-wider text-slate-400">{{ __('Total Requests') }}</p>
                    <span class="flex h-10 w-10 items-center justify-center rounded-xl bg-indigo-100 dark:bg-indigo-500/10">
                        <svg class="h-5 w-5 text-indigo-600 dark:text-indigo-400" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/></svg>
                    </span>
                </div>
                <p id="r-total" class="mt-3 text-2xl font-extrabold text-slate-900 dark:text-white">0</p>
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900 hover:shadow-md transition-all">
                <div class="flex items-center justify-between">
                    <p class="text-xs font-semibold uppercase tracking-wider text-slate-400">{{ __('Completed') }}</p>
                    <span class="flex h-10 w-10 items-center justify-center rounded-xl bg-emerald-100 dark:bg-emerald-500/10">
                        <svg class="h-5 w-5 text-emerald-600 dark:text-emerald-400" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                    </span>
                </div>
                <p id="r-completed" class="mt-3 text-2xl font-extrabold text-emerald-600 dark:text-emerald-400">0</p>
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900 hover:shadow-md transition-all">
                <div class="flex items-center justify-between">
                    <p class="text-xs font-semibold uppercase tracking-wider text-slate-400">{{ __('In Progress') }}</p>
                    <span class="flex h-10 w-10 items-center justify-center rounded-xl bg-amber-100 dark:bg-amber-500/10">
                        <svg class="h-5 w-5 text-amber-600 dark:text-amber-400" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                    </span>
                </div>
                <p id="r-inprogress" class="mt-3 text-2xl font-extrabold text-amber-600 dark:text-amber-400">0</p>
            </div>
        </div>

        {{-- Status + Service Type Breakdown Charts --}}
        <div class="grid gap-6 xl:grid-cols-2">

            {{-- Status Breakdown Chart --}}
            <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <h3 class="text-base font-bold text-slate-900 dark:text-white mb-2">{{ __('Requests Status Distribution') }}</h3>
                <div class="h-64 relative flex items-center justify-center">
                    <canvas id="repair-status-chart"></canvas>
                </div>
            </div>

            {{-- Service Type Chart --}}
            <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <h3 class="text-base font-bold text-slate-900 dark:text-white mb-2">{{ __('Requests by Service Type') }}</h3>
                <div class="h-64 relative flex items-center justify-center">
                    <canvas id="repair-service-chart"></canvas>
                </div>
            </div>
        </div>

        {{-- Recent Repair Requests --}}
        <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <h3 class="text-base font-bold text-slate-900 dark:text-white mb-4">{{ __('Recent Repair Work Orders') }}</h3>
            <div class="overflow-x-auto">
                <table class="w-full text-left text-sm">
                    <thead class="bg-slate-50 text-xs uppercase tracking-wider text-slate-400 dark:bg-slate-800/60">
                        <tr>
                            <th class="px-4 py-3 rounded-l-xl">#</th>
                            <th class="px-4 py-3">{{ __('Customer') }}</th>
                            <th class="px-4 py-3">{{ __('Device / Issue') }}</th>
                            <th class="px-4 py-3">{{ __('Service Type') }}</th>
                            <th class="px-4 py-3">{{ __('Technician') }}</th>
                            <th class="px-4 py-3">{{ __('Status') }}</th>
                            <th class="px-4 py-3 text-right rounded-r-xl">{{ __('Created Date') }}</th>
                        </tr>
                    </thead>
                    <tbody id="r-recent-body" class="divide-y divide-slate-100 text-slate-600 dark:divide-slate-800 dark:text-slate-300">
                        <tr><td colspan="7" class="px-4 py-8 text-center text-xs text-slate-400">{{ __('Click Generate Report to load data.') }}</td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    {{-- ── Export History Drawer ───────────────────────────────────────────── --}}
    <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
        <div class="flex items-center justify-between gap-3">
            <div>
                <h3 class="text-base font-bold text-slate-900 dark:text-white">{{ __('Recent Exported Files') }}</h3>
                <p class="text-xs text-slate-400">{{ __('Download past generated Excel and PDF report exports') }}</p>
            </div>
            <button id="exports-refresh" class="inline-flex items-center gap-1.5 rounded-xl border border-slate-200 px-3 py-1.5 text-xs font-semibold text-slate-600 hover:bg-slate-50 dark:border-slate-800 dark:text-slate-300 dark:hover:bg-slate-800 transition-all">
                <svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/></svg>
                {{ __('Refresh') }}
            </button>
        </div>
        <div id="exports-list" class="mt-4 space-y-3">
            <p class="text-xs text-slate-400">{{ __('No recent exports.') }}</p>
        </div>
    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function () {
    var $ = function (id) { return document.getElementById(id); };
    var fmt = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' });

    var preset      = $('report-preset');
    var startInp    = $('report-start');
    var endInp      = $('report-end');
    var thresholdInp= $('report-threshold');
    var typeInput   = $('report-type');
    var btnGen      = $('btn-generate');

    // Export dropdown element references
    var exportContainer = $('export-dropdown-container');
    var exportToggle    = $('btn-export-toggle');
    var exportMenu      = $('export-dropdown-menu');
    var exportExcelOpt  = $('export-excel-opt');
    var exportPdfOpt    = $('export-pdf-opt');

    // Chart instances
    var salesChart = null;
    var paymentDonutChart = null;
    var customerSegmentChart = null;
    var inventoryCatChart = null;
    var repairStatusChart = null;
    var repairServiceChart = null;

    // ── Export Dropdown Toggle ─────────────────────────────────────────────
    exportToggle.addEventListener('click', function (e) {
        e.stopPropagation();
        exportMenu.classList.toggle('hidden');
    });
    document.addEventListener('click', function (e) {
        if (!exportContainer.contains(e.target)) {
            exportMenu.classList.add('hidden');
        }
    });

    exportExcelOpt.addEventListener('click', function () {
        exportMenu.classList.add('hidden');
        triggerExport('excel');
    });
    exportPdfOpt.addEventListener('click', function () {
        exportMenu.classList.add('hidden');
        triggerExport('pdf');
    });

    // ── Tab Switching ──────────────────────────────────────────────────────
    var tabBtns = document.querySelectorAll('#report-tabs .tab-btn');
    tabBtns.forEach(function (btn) {
        btn.addEventListener('click', function () {
            var targetTab = btn.getAttribute('data-tab');
            typeInput.value = targetTab;

            tabBtns.forEach(function (b) {
                b.className = 'tab-btn inline-flex items-center gap-2 rounded-xl px-4 py-2.5 text-sm font-semibold transition-all text-slate-600 hover:bg-slate-100 dark:text-slate-300 dark:hover:bg-slate-800';
            });
            btn.className = 'tab-btn inline-flex items-center gap-2 rounded-xl px-4 py-2.5 text-sm font-semibold transition-all bg-primary-600 text-white shadow-md shadow-primary-600/20';

            showPanel(targetTab);
            generate();
        });
    });

    function showPanel(name) {
        ['sales','customers','inventory','repairs'].forEach(function (p) {
            var panel = $(p + '-panel');
            if (panel) panel.classList.toggle('hidden', p !== name);
        });

        // Show threshold input only for inventory
        $('threshold-wrap').classList.toggle('hidden', name !== 'inventory');
    }

    // ── Custom Range Toggle ────────────────────────────────────────────────
    function toggleCustom() {
        var isCustom = preset.value === 'custom';
        $('custom-start-wrap').classList.toggle('hidden', !isCustom);
        $('custom-end-wrap').classList.toggle('hidden', !isCustom);
    }
    preset.addEventListener('change', toggleCustom);
    toggleCustom();

    // ── Build Query Params ─────────────────────────────────────────────────
    function buildParams() {
        var p = new URLSearchParams({ preset: preset.value });
        if (preset.value === 'custom' && startInp.value && endInp.value) {
            p.set('start', startInp.value);
            p.set('end', endInp.value);
        }
        if (thresholdInp.value) {
            p.set('threshold', thresholdInp.value);
        }
        return p;
    }

    // ── Fetch & Generate Analytics ──────────────────────────────────────────
    btnGen.addEventListener('click', generate);

    async function generate() {
        var type = typeInput.value;
        setLoading(true);
        try {
            var res = await window.adminApi.request('/api/admin/reports/' + type + '?' + buildParams());
            setLoading(false);
            if (!res.ok) return;

            var data = await res.json();

            if (data.range) {
                $('range-label-text').textContent = data.range.label + ' (' + data.range.start + ' → ' + data.range.end + ')';
                $('live-range-badge').classList.remove('hidden');
            }

            if (type === 'sales')      renderSales(data);
            if (type === 'customers')  renderCustomers(data);
            if (type === 'inventory')  renderInventory(data);
            if (type === 'repairs')    renderRepairs(data);

        } catch (e) {
            setLoading(false);
        }
    }

    function setLoading(on) {
        $('report-loading').classList.toggle('hidden', !on);
        btnGen.disabled = on;
        exportToggle.disabled = on;
    }

    // ── 1. Sales BI Rendering ──────────────────────────────────────────────
    function renderSales(data) {
        var m = data.metrics || {};
        $('kpi-revenue').textContent = fmt.format(m.total_sales || 0);
        $('kpi-orders').textContent  = m.total_orders ?? 0;
        $('kpi-avg').textContent     = fmt.format(m.average_order_value || 0);
        $('kpi-paid').textContent    = m.paid_orders ?? 0;

        $('pay-paid').textContent   = m.paid_orders ?? 0;
        $('pay-unpaid').textContent = m.unpaid_orders ?? 0;
        $('pay-failed').textContent = m.failed_orders ?? 0;

        var total = (m.total_orders || 0);
        var rate  = total > 0 ? Math.round(((m.paid_orders || 0) / total) * 100) : 0;
        $('pay-rate-bar').style.width   = rate + '%';
        $('pay-rate-label').textContent = rate + '%';

        var isDark = document.documentElement.classList.contains('dark');
        var gridColor = isDark ? 'rgba(255,255,255,0.06)' : 'rgba(0,0,0,0.05)';
        var textColor = isDark ? '#94a3b8' : '#64748b';

        function safelyDestroyChart(canvasId) {
            if (typeof Chart !== 'undefined' && Chart.getChart) {
                var existing = Chart.getChart(canvasId);
                if (existing) {
                    existing.destroy();
                }
            }
        }

        // 1. Line Area Chart
        var daily  = data.daily || [];
        var labels = daily.map(function (d) { return d.day; });
        var values = daily.map(function (d) { return d.total; });

        $('chart-range').textContent = (data.range ? data.range.label : '') + ' · Daily Revenue ($)';

        safelyDestroyChart('sales-chart');
        var ctx = $('sales-chart').getContext('2d');

        var gradient = ctx.createLinearGradient(0, 0, 0, 300);
        gradient.addColorStop(0, 'rgba(79, 70, 229, 0.35)');
        gradient.addColorStop(1, 'rgba(79, 70, 229, 0.0)');

        salesChart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Revenue ($)',
                    data: values,
                    borderColor: '#4f46e5',
                    backgroundColor: gradient,
                    borderWidth: 3,
                    fill: true,
                    tension: 0.35,
                    pointRadius: 3,
                    pointHoverRadius: 6,
                    pointBackgroundColor: '#4f46e5',
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: {
                    x: { ticks: { color: textColor, font: { size: 10 } }, grid: { color: gridColor } },
                    y: {
                        ticks: {
                            color: textColor, font: { size: 10 },
                            callback: function (v) { return '$' + v.toLocaleString(); }
                        },
                        grid: { color: gridColor },
                        beginAtZero: true
                    }
                }
            }
        });

        // 2. Payment Donut Chart
        safelyDestroyChart('payment-donut-chart');
        var dCtx = $('payment-donut-chart').getContext('2d');
        paymentDonutChart = new Chart(dCtx, {
            type: 'doughnut',
            data: {
                labels: ['Paid', 'Unpaid', 'Failed'],
                datasets: [{
                    data: [m.paid_orders || 0, m.unpaid_orders || 0, m.failed_orders || 0],
                    backgroundColor: ['#10b981', '#f59e0b', '#ef4444'],
                    borderWidth: 0,
                    hoverOffset: 4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                cutout: '72%',
                plugins: { legend: { display: false } }
            }
        });

        // Top products table
        var items = data.top_items || [];
        if (!items.length) {
            $('top-products-body').innerHTML = '<tr><td colspan="5" class="px-4 py-8 text-center text-xs text-slate-400">No sales transactions in this period.</td></tr>';
            return;
        }
        var maxSales = Math.max.apply(null, items.map(function(it){ return it.sales || 0; })) || 1;
        $('top-products-body').innerHTML = items.map(function (item, i) {
            var pct = Math.round((item.sales / maxSales) * 100);
            return '<tr class="hover:bg-slate-50 dark:hover:bg-slate-800/40 transition-colors">'
                + '<td class="px-4 py-3.5 font-bold text-xs text-slate-400">' + (i + 1) + '</td>'
                + '<td class="px-4 py-3.5"><div class="font-bold text-slate-900 dark:text-white">' + esc(item.name || '—') + '</div>'
                + '<div class="mt-1 h-1.5 w-32 overflow-hidden rounded-full bg-slate-100 dark:bg-slate-800"><div class="h-full rounded-full bg-indigo-500" style="width:' + pct + '%"></div></div></td>'
                + '<td class="px-4 py-3.5"><span class="rounded-full bg-slate-100 px-2.5 py-1 text-xs font-medium dark:bg-slate-800 text-slate-600 dark:text-slate-300">' + esc(item.item_type || 'product') + '</span></td>'
                + '<td class="px-4 py-3.5 font-semibold text-slate-700 dark:text-slate-300">' + (item.quantity || 0) + '</td>'
                + '<td class="px-4 py-3.5 text-right font-extrabold text-emerald-600 dark:text-emerald-400">' + fmt.format(item.sales || 0) + '</td>'
                + '</tr>';
        }).join('');
    }

    // ── 2. Customer BI Rendering ───────────────────────────────────────────
    function renderCustomers(data) {
        var m = data.metrics || {};
        $('c-total').textContent  = m.total_customers ?? 0;
        $('c-new').textContent    = m.new_customers ?? 0;
        $('c-active').textContent = m.active_customers ?? 0;
        $('c-repeat').textContent = m.repeat_customers ?? 0;

        // Customer Segment Bar Chart
        safelyDestroyChart('customer-segment-chart');
        var cCtx = $('customer-segment-chart').getContext('2d');
        customerSegmentChart = new Chart(cCtx, {
            type: 'bar',
            data: {
                labels: ['Total', 'New', 'Active', 'Repeat'],
                datasets: [{
                    label: 'Customers',
                    data: [m.total_customers ?? 0, m.new_customers ?? 0, m.active_customers ?? 0, m.repeat_customers ?? 0],
                    backgroundColor: ['#6366f1', '#10b981', '#4f46e5', '#8b5cf6'],
                    borderRadius: 8,
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: {
                    x: { grid: { display: false } },
                    y: { beginAtZero: true }
                }
            }
        });

        // Top customers table
        var top = data.top_customers || [];
        if (!top.length) {
            $('top-customers-body').innerHTML = '<tr><td colspan="5" class="px-4 py-8 text-center text-xs text-slate-400">No customer purchases found in this period.</td></tr>';
            return;
        }
        $('top-customers-body').innerHTML = top.map(function (c, i) {
            return '<tr class="hover:bg-slate-50 dark:hover:bg-slate-800/40 transition-colors">'
                + '<td class="px-4 py-3.5 font-bold text-xs text-slate-400">' + (i + 1) + '</td>'
                + '<td class="px-4 py-3.5 font-bold text-slate-900 dark:text-white">' + esc(c.name || 'Customer') + '</td>'
                + '<td class="px-4 py-3.5 text-xs text-slate-500">' + esc(c.email || '—') + '</td>'
                + '<td class="px-4 py-3.5 font-semibold text-slate-700 dark:text-slate-300">' + (c.orders_count || 0) + '</td>'
                + '<td class="px-4 py-3.5 text-right font-extrabold text-emerald-600 dark:text-emerald-400">' + fmt.format(c.total_spent || 0) + '</td>'
                + '</tr>';
        }).join('');
    }

    // ── 3. Inventory BI Rendering ──────────────────────────────────────────
    function renderInventory(data) {
        var m = data.metrics || {};
        $('inv-products').textContent    = m.total_products ?? 0;
        $('inv-accessories').textContent = m.total_accessories ?? 0;
        $('inv-parts').textContent       = m.total_parts ?? 0;
        $('inv-low').textContent         = m.low_stock_count ?? 0;

        // Category Share Chart
        safelyDestroyChart('inventory-cat-chart');
        var iCtx = $('inventory-cat-chart').getContext('2d');
        inventoryCatChart = new Chart(iCtx, {
            type: 'doughnut',
            data: {
                labels: ['Products', 'Accessories', 'Parts'],
                datasets: [{
                    data: [m.total_products ?? 0, m.total_accessories ?? 0, m.total_parts ?? 0],
                    backgroundColor: ['#4f46e5', '#06b6d4', '#f59e0b'],
                    borderWidth: 0,
                    hoverOffset: 4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                cutout: '70%',
                plugins: { legend: { position: 'bottom' } }
            }
        });

        // Low stock table
        var low = data.low_stock || [];
        if (!low.length) {
            $('low-stock-body').innerHTML = '<tr><td colspan="5" class="px-4 py-8 text-center text-xs text-slate-400">All inventory stock levels are healthy!</td></tr>';
            return;
        }
        $('low-stock-body').innerHTML = low.map(function (item, i) {
            var isOut = item.stock === 0;
            var badgeClass = isOut ? 'bg-red-100 text-red-700 dark:bg-red-500/10 dark:text-red-400' : 'bg-amber-100 text-amber-700 dark:bg-amber-500/10 dark:text-amber-400';
            var statusLabel = isOut ? 'Out of Stock' : 'Low Stock';

            return '<tr class="hover:bg-slate-50 dark:hover:bg-slate-800/40 transition-colors">'
                + '<td class="px-4 py-3.5 font-bold text-xs text-slate-400">' + (i + 1) + '</td>'
                + '<td class="px-4 py-3.5 font-bold text-slate-900 dark:text-white">' + esc(item.name || '—') + '</td>'
                + '<td class="px-4 py-3.5"><span class="rounded-full bg-slate-100 px-2.5 py-0.5 text-xs font-semibold dark:bg-slate-800 text-slate-600 dark:text-slate-300">' + esc(item.type || 'item') + '</span></td>'
                + '<td class="px-4 py-3.5 text-xs text-slate-500 font-mono">' + esc(item.sku || '—') + '</td>'
                + '<td class="px-4 py-3.5 text-right"><span class="inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-bold ' + badgeClass + '">' + (item.stock ?? 0) + ' units (' + statusLabel + ')</span></td>'
                + '</tr>';
        }).join('');
    }

    // ── 4. Repairs BI Rendering ────────────────────────────────────────────
    function renderRepairs(data) {
        var m = data.metrics || {};
        $('r-total').textContent      = m.total_requests ?? 0;
        $('r-completed').textContent  = m.completed ?? 0;
        $('r-inprogress').textContent = m.in_progress ?? 0;

        var byStatus  = data.by_status || [];
        var byService = data.by_service_type || [];

        // Status Doughnut Chart
        safelyDestroyChart('repair-status-chart');
        var rCtx = $('repair-status-chart').getContext('2d');
        repairStatusChart = new Chart(rCtx, {
            type: 'doughnut',
            data: {
                labels: byStatus.map(function(s){ return (s.status || '').replace(/_/g,' '); }),
                datasets: [{
                    data: byStatus.map(function(s){ return s.count; }),
                    backgroundColor: ['#3b82f6','#8b5cf6','#f59e0b','#f97316','#8b5cf6','#10b981','#059669'],
                    borderWidth: 0
                }]
            },
            options: { responsive: true, maintainAspectRatio: false, cutout: '68%', plugins: { legend: { position: 'bottom' } } }
        });

        // Service Type Bar Chart
        safelyDestroyChart('repair-service-chart');
        var sCtx = $('repair-service-chart').getContext('2d');
        repairServiceChart = new Chart(sCtx, {
            type: 'bar',
            data: {
                labels: byService.map(function(s){ return (s.service_type || '').replace(/_/g,' '); }),
                datasets: [{
                    label: 'Service Count',
                    data: byService.map(function(s){ return s.count; }),
                    backgroundColor: '#6366f1',
                    borderRadius: 8
                }]
            },
            options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } }, scales: { y: { beginAtZero: true } } }
        });

        // Recent table
        var recent = data.recent || [];
        if (!recent.length) {
            $('r-recent-body').innerHTML = '<tr><td colspan="7" class="px-4 py-8 text-center text-xs text-slate-400">No repair work orders found for this period.</td></tr>';
            return;
        }
        $('r-recent-body').innerHTML = recent.map(function (r, i) {
            var statusLabel = (r.status || '').replace(/_/g, ' ').toUpperCase();
            var date        = r.created_at ? r.created_at.slice(0, 10) : '—';
            return '<tr class="hover:bg-slate-50 dark:hover:bg-slate-800/40 transition-colors">'
                + '<td class="px-4 py-3.5 font-bold text-xs text-slate-400">' + (i + 1) + '</td>'
                + '<td class="px-4 py-3.5 font-bold text-slate-900 dark:text-white">' + esc(r.customer_name || 'Guest') + '</td>'
                + '<td class="px-4 py-3.5 text-xs text-slate-600 dark:text-slate-300">' + esc((r.device_model || '—') + ' (' + (r.issue_type || '—') + ')') + '</td>'
                + '<td class="px-4 py-3.5"><span class="rounded-full bg-slate-100 px-2.5 py-0.5 text-xs font-medium dark:bg-slate-800">' + esc(r.service_type || 'drop_off') + '</span></td>'
                + '<td class="px-4 py-3.5 text-xs text-slate-500">' + esc(r.technician_name || 'Unassigned') + '</td>'
                + '<td class="px-4 py-3.5"><span class="rounded-full bg-indigo-100 px-2.5 py-1 text-xs font-bold text-indigo-700 dark:bg-indigo-500/10 dark:text-indigo-400">' + esc(statusLabel) + '</span></td>'
                + '<td class="px-4 py-3.5 text-right text-xs text-slate-400">' + esc(date) + '</td>'
                + '</tr>';
        }).join('');
    }

    // ── Export Trigger ─────────────────────────────────────────────────────
    async function triggerExport(selectedFormat) {
        var type = typeInput.value;
        var payload = { type: type, format: selectedFormat, preset: preset.value, threshold: thresholdInp.value || 10 };
        if (preset.value === 'custom') { payload.start = startInp.value; payload.end = endInp.value; }

        await window.adminApi.ensureCsrfCookie();
        setLoading(true);

        try {
            var res = await window.adminApi.request('/api/admin/reports/export', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(payload)
            });
            setLoading(false);
            if (res.ok) {
                var d = await res.json();
                if (d.download_url) window.open(d.download_url, '_blank');
                loadExports();
            } else {
                alert('Export failed. Please check filters.');
            }
        } catch (e) {
            setLoading(false);
        }
    }

    // ── Exports History ────────────────────────────────────────────────────
    $('exports-refresh').addEventListener('click', loadExports);

    async function loadExports() {
        try {
            var res = await window.adminApi.request('/api/admin/reports/exports');
            if (!res.ok) return;
            var data = await res.json();
            var list = data.exports || [];
            if (!list.length) {
                $('exports-list').innerHTML = '<p class="text-xs text-slate-400">No recent exports.</p>';
                return;
            }
            $('exports-list').innerHTML = list.map(function (item) {
                var isPdf = item.format === 'pdf';
                var icon  = isPdf ? '📄' : '📊';
                var badge = isPdf ? 'bg-red-100 text-red-700 dark:bg-red-500/10 dark:text-red-400' : 'bg-emerald-100 text-emerald-700 dark:bg-emerald-500/10 dark:text-emerald-400';
                var label = cap(item.type) + ' Analytics Report · ' + item.format.toUpperCase();
                var range = item.range ? item.range.start + ' → ' + item.range.end : '';
                var date  = item.generated_at ? new Date(item.generated_at).toLocaleString() : '';
                var kb    = item.size ? (item.size / 1024).toFixed(1) + ' KB' : '';

                return '<div class="flex items-center justify-between gap-4 rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 dark:border-slate-800 dark:bg-slate-950/40">'
                    + '<div class="flex items-center gap-3"><span class="text-lg">' + icon + '</span>'
                    + '<div><div class="flex items-center gap-2"><p class="text-sm font-bold text-slate-900 dark:text-white">' + esc(label) + '</p><span class="rounded-full px-2 py-0.5 text-[10px] font-extrabold uppercase ' + badge + '">' + esc(item.format) + '</span></div>'
                    + '<p class="text-xs text-slate-400 mt-0.5">' + [date, range, kb].filter(Boolean).join(' · ') + '</p></div></div>'
                    + '<a href="' + esc(item.download_url) + '" target="_blank" class="inline-flex items-center gap-1.5 rounded-xl bg-primary-600 px-3.5 py-1.5 text-xs font-semibold text-white shadow-sm hover:bg-primary-700 transition-all">'
                    + '<svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"/></svg>'
                    + 'Download</a></div>';
            }).join('');
        } catch (e) {}
    }

    function esc(s) {
        return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
    }
    function cap(s) { return s ? s.charAt(0).toUpperCase() + s.slice(1) : ''; }

    // Initial load
    generate();
    loadExports();
});
</script>
@endsection
