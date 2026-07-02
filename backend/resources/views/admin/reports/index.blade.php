@extends('layouts.admin')

@section('title', __('Sales Report'))
@section('page-title', __('Sales Report'))

@section('content')
<div class="space-y-6" id="report-root">

    {{-- ── Filter bar ──────────────────────────────────────────────────────── --}}
    <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
        <div class="flex flex-wrap items-end gap-4">

            {{-- Preset --}}
            <div class="flex-1 min-w-[160px]">
                <label class="text-xs font-semibold uppercase tracking-widest text-slate-400">{{ __('Date Range') }}</label>
                <select id="report-preset" class="mt-2 h-10 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
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
                <label class="text-xs font-semibold uppercase tracking-widest text-slate-400">{{ __('From') }}</label>
                <input id="report-start" type="date" class="mt-2 h-10 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
            </div>

            {{-- Custom end --}}
            <div id="custom-end-wrap" class="hidden flex-1 min-w-[130px]">
                <label class="text-xs font-semibold uppercase tracking-widest text-slate-400">{{ __('To') }}</label>
                <input id="report-end" type="date" class="mt-2 h-10 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
            </div>

            {{-- Report type --}}
            <div class="flex-1 min-w-[150px]">
                <label class="text-xs font-semibold uppercase tracking-widest text-slate-400">{{ __('Report Type') }}</label>
                <select id="report-type" class="mt-2 h-10 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                    <option value="sales">{{ __('Sales') }}</option>
                    <option value="customers">{{ __('Customers') }}</option>
                    <option value="inventory">{{ __('Inventory') }}</option>
                    <option value="repairs">{{ __('Repair Requests') }}</option>
                </select>
            </div>

            {{-- Export format --}}
            <div>
                <label class="text-xs font-semibold uppercase tracking-widest text-slate-400">{{ __('Export As') }}</label>
                <div class="mt-2 flex items-center gap-3 h-10 text-sm text-slate-600 dark:text-slate-300">
                    <label class="inline-flex items-center gap-1.5 cursor-pointer">
                        <input id="format-csv" type="checkbox" class="rounded border-slate-300 text-primary-600 focus:ring-primary-500" checked />
                        CSV
                    </label>
                    <label class="inline-flex items-center gap-1.5 cursor-pointer">
                        <input id="format-pdf" type="checkbox" class="rounded border-slate-300 text-primary-600 focus:ring-primary-500" checked />
                        PDF
                    </label>
                </div>
            </div>

            {{-- Buttons --}}
            <div class="flex items-center gap-2">
                <button id="btn-generate"
                        class="inline-flex h-10 items-center gap-2 rounded-xl bg-primary-600 px-5 text-sm font-semibold text-white shadow-sm hover:bg-primary-700 disabled:opacity-50">
                    <svg class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M9 17v-2m3 2v-4m3 4v-6m2 10H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414A1 1 0 0119 9.414V19a2 2 0 01-2 2z"/>
                    </svg>
                    {{ __('Generate') }}
                </button>
                <button id="btn-export"
                        class="inline-flex h-10 items-center gap-2 rounded-xl border border-slate-200 bg-white px-5 text-sm font-semibold text-slate-600 shadow-sm hover:bg-slate-50 dark:border-slate-700 dark:bg-slate-800 dark:text-slate-300 disabled:opacity-50">
                    <svg class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"/>
                    </svg>
                    {{ __('Export') }}
                </button>
            </div>
        </div>

        {{-- Range label --}}
        <p id="range-label" class="mt-3 text-xs text-slate-500 hidden">
            {{ __('Showing data for:') }} <span id="range-label-text" class="font-semibold text-slate-700 dark:text-slate-200"></span>
        </p>
    </div>

    {{-- ── Loading spinner ─────────────────────────────────────────────────── --}}
    <div id="report-loading" class="hidden flex items-center justify-center py-16">
        <div class="h-8 w-8 animate-spin rounded-full border-4 border-primary-200 border-t-primary-600"></div>
        <span class="ml-3 text-sm font-medium text-slate-500">{{ __('Generating report...') }}</span>
    </div>

    {{-- ── Sales panel ─────────────────────────────────────────────────────── --}}
    <div id="sales-panel" class="hidden space-y-6">

        {{-- KPI cards --}}
        <div class="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <div class="flex items-center justify-between">
                    <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">{{ __('Total Revenue') }}</p>
                    <span class="flex h-8 w-8 items-center justify-center rounded-xl bg-green-100 dark:bg-green-500/10">
                        <svg class="h-4 w-4 text-green-600 dark:text-green-400" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                    </span>
                </div>
                <p id="kpi-revenue" class="mt-3 text-2xl font-bold text-slate-900 dark:text-white">--</p>
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <div class="flex items-center justify-between">
                    <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">{{ __('Total Orders') }}</p>
                    <span class="flex h-8 w-8 items-center justify-center rounded-xl bg-blue-100 dark:bg-blue-500/10">
                        <svg class="h-4 w-4 text-blue-600 dark:text-blue-400" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"/></svg>
                    </span>
                </div>
                <p id="kpi-orders" class="mt-3 text-2xl font-bold text-slate-900 dark:text-white">--</p>
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <div class="flex items-center justify-between">
                    <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">{{ __('Avg Order Value') }}</p>
                    <span class="flex h-8 w-8 items-center justify-center rounded-xl bg-purple-100 dark:bg-purple-500/10">
                        <svg class="h-4 w-4 text-purple-600 dark:text-purple-400" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/></svg>
                    </span>
                </div>
                <p id="kpi-avg" class="mt-3 text-2xl font-bold text-slate-900 dark:text-white">--</p>
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <div class="flex items-center justify-between">
                    <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">{{ __('Paid Orders') }}</p>
                    <span class="flex h-8 w-8 items-center justify-center rounded-xl bg-emerald-100 dark:bg-emerald-500/10">
                        <svg class="h-4 w-4 text-emerald-600 dark:text-emerald-400" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                    </span>
                </div>
                <p id="kpi-paid" class="mt-3 text-2xl font-bold text-slate-900 dark:text-white">--</p>
            </div>
        </div>

        {{-- Chart + Payment breakdown --}}
        <div class="grid gap-6 xl:grid-cols-3">

            {{-- Daily revenue chart --}}
            <div class="xl:col-span-2 rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <h3 class="text-sm font-semibold text-slate-800 dark:text-white">{{ __('Daily Revenue') }}</h3>
                <p id="chart-range" class="mt-0.5 text-xs text-slate-400">--</p>
                <div class="mt-4 h-64">
                    <canvas id="sales-chart"></canvas>
                </div>
            </div>

            {{-- Payment breakdown --}}
            <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <h3 class="text-sm font-semibold text-slate-800 dark:text-white">{{ __('Payment Breakdown') }}</h3>
                <div class="mt-4 space-y-3">
                    <div class="flex items-center justify-between rounded-xl bg-green-50 px-4 py-3 dark:bg-green-500/10">
                        <div class="flex items-center gap-2">
                            <span class="h-2.5 w-2.5 rounded-full bg-green-500"></span>
                            <span class="text-sm font-medium text-slate-700 dark:text-slate-300">{{ __('Paid') }}</span>
                        </div>
                        <span id="pay-paid" class="text-sm font-bold text-slate-900 dark:text-white">--</span>
                    </div>
                    <div class="flex items-center justify-between rounded-xl bg-yellow-50 px-4 py-3 dark:bg-yellow-500/10">
                        <div class="flex items-center gap-2">
                            <span class="h-2.5 w-2.5 rounded-full bg-yellow-400"></span>
                            <span class="text-sm font-medium text-slate-700 dark:text-slate-300">{{ __('Unpaid') }}</span>
                        </div>
                        <span id="pay-unpaid" class="text-sm font-bold text-slate-900 dark:text-white">--</span>
                    </div>
                    <div class="flex items-center justify-between rounded-xl bg-red-50 px-4 py-3 dark:bg-red-500/10">
                        <div class="flex items-center gap-2">
                            <span class="h-2.5 w-2.5 rounded-full bg-red-400"></span>
                            <span class="text-sm font-medium text-slate-700 dark:text-slate-300">{{ __('Failed') }}</span>
                        </div>
                        <span id="pay-failed" class="text-sm font-bold text-slate-900 dark:text-white">--</span>
                    </div>
                </div>
                <div class="mt-5">
                    <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">{{ __('Payment Rate') }}</p>
                    <div class="mt-2 h-2.5 w-full overflow-hidden rounded-full bg-slate-100 dark:bg-slate-800">
                        <div id="pay-rate-bar" class="h-full rounded-full bg-green-500 transition-all duration-700" style="width:0%"></div>
                    </div>
                    <p id="pay-rate-label" class="mt-1.5 text-xs font-semibold text-slate-600 dark:text-slate-300">0%</p>
                </div>
            </div>
        </div>

        {{-- Top products table --}}
        <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <h3 class="mb-4 text-sm font-semibold text-slate-800 dark:text-white">{{ __('Top Products by Revenue') }}</h3>
            <div class="overflow-x-auto">
                <table class="w-full text-left text-sm">
                    <thead class="text-xs uppercase tracking-widest text-slate-400">
                        <tr>
                            <th class="px-4 py-3">#</th>
                            <th class="px-4 py-3">{{ __('Product') }}</th>
                            <th class="px-4 py-3">{{ __('Type') }}</th>
                            <th class="px-4 py-3">{{ __('Qty Sold') }}</th>
                            <th class="px-4 py-3 text-right">{{ __('Revenue') }}</th>
                        </tr>
                    </thead>
                    <tbody id="top-products-body" class="divide-y divide-slate-100 text-slate-600 dark:divide-slate-800 dark:text-slate-300">
                        <tr><td colspan="5" class="px-4 py-6 text-center text-xs text-slate-400">{{ __('Click Generate to load data.') }}</td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    {{-- ── Customer panel ──────────────────────────────────────────────────── --}}
    <div id="customers-panel" class="hidden space-y-6">
        <div class="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">{{ __('Total Customers') }}</p>
                <p id="c-total" class="mt-3 text-2xl font-bold text-slate-900 dark:text-white">--</p>
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">{{ __('New Customers') }}</p>
                <p id="c-new" class="mt-3 text-2xl font-bold text-slate-900 dark:text-white">--</p>
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">{{ __('Active Customers') }}</p>
                <p id="c-active" class="mt-3 text-2xl font-bold text-slate-900 dark:text-white">--</p>
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">{{ __('Repeat Customers') }}</p>
                <p id="c-repeat" class="mt-3 text-2xl font-bold text-slate-900 dark:text-white">--</p>
            </div>
        </div>
        <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <h3 class="mb-4 text-sm font-semibold text-slate-800 dark:text-white">{{ __('Top Customers') }}</h3>
            <div class="overflow-x-auto">
                <table class="w-full text-left text-sm">
                    <thead class="text-xs uppercase tracking-widest text-slate-400">
                        <tr><th class="px-4 py-3">#</th><th class="px-4 py-3">{{ __('Name') }}</th><th class="px-4 py-3">{{ __('Email') }}</th><th class="px-4 py-3">{{ __('Orders') }}</th><th class="px-4 py-3 text-right">{{ __('Total Spent') }}</th></tr>
                    </thead>
                    <tbody id="top-customers-body" class="divide-y divide-slate-100 text-slate-600 dark:divide-slate-800 dark:text-slate-300">
                        <tr><td colspan="5" class="px-4 py-6 text-center text-xs text-slate-400">{{ __('Click Generate to load data.') }}</td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    {{-- ── Inventory panel ─────────────────────────────────────────────────── --}}
    <div id="inventory-panel" class="hidden space-y-6">
        <div class="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">{{ __('Products') }}</p>
                <p id="inv-products" class="mt-3 text-2xl font-bold text-slate-900 dark:text-white">--</p>
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">{{ __('Accessories') }}</p>
                <p id="inv-accessories" class="mt-3 text-2xl font-bold text-slate-900 dark:text-white">--</p>
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">{{ __('Parts') }}</p>
                <p id="inv-parts" class="mt-3 text-2xl font-bold text-slate-900 dark:text-white">--</p>
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">{{ __('Low Stock') }}</p>
                <p id="inv-low" class="mt-3 text-2xl font-bold text-red-500">--</p>
            </div>
        </div>
        <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <h3 class="mb-4 text-sm font-semibold text-slate-800 dark:text-white">{{ __('Low Stock Items') }}</h3>
            <div class="overflow-x-auto">
                <table class="w-full text-left text-sm">
                    <thead class="text-xs uppercase tracking-widest text-slate-400">
                        <tr><th class="px-4 py-3">#</th><th class="px-4 py-3">{{ __('Name') }}</th><th class="px-4 py-3">{{ __('Type') }}</th><th class="px-4 py-3">{{ __('SKU') }}</th><th class="px-4 py-3 text-right">{{ __('Stock') }}</th></tr>
                    </thead>
                    <tbody id="low-stock-body" class="divide-y divide-slate-100 text-slate-600 dark:divide-slate-800 dark:text-slate-300">
                        <tr><td colspan="5" class="px-4 py-6 text-center text-xs text-slate-400">{{ __('Click Generate to load data.') }}</td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    {{-- ── Repairs panel ──────────────────────────────────────────────────── --}}
    <div id="repairs-panel" class="hidden space-y-6">

        {{-- KPI cards --}}
        <div class="grid gap-4 sm:grid-cols-3">
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <div class="flex items-center justify-between">
                    <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Total Requests</p>
                    <span class="flex h-8 w-8 items-center justify-center rounded-xl bg-indigo-100 dark:bg-indigo-500/10">
                        <svg class="h-4 w-4 text-indigo-600 dark:text-indigo-400" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/></svg>
                    </span>
                </div>
                <p id="r-total" class="mt-3 text-2xl font-bold text-slate-900 dark:text-white">--</p>
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <div class="flex items-center justify-between">
                    <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Completed</p>
                    <span class="flex h-8 w-8 items-center justify-center rounded-xl bg-green-100 dark:bg-green-500/10">
                        <svg class="h-4 w-4 text-green-600 dark:text-green-400" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                    </span>
                </div>
                <p id="r-completed" class="mt-3 text-2xl font-bold text-green-600 dark:text-green-400">--</p>
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <div class="flex items-center justify-between">
                    <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">In Progress</p>
                    <span class="flex h-8 w-8 items-center justify-center rounded-xl bg-amber-100 dark:bg-amber-500/10">
                        <svg class="h-4 w-4 text-amber-600 dark:text-amber-400" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                    </span>
                </div>
                <p id="r-inprogress" class="mt-3 text-2xl font-bold text-amber-600 dark:text-amber-400">--</p>
            </div>
        </div>

        {{-- Status + Service Type breakdown --}}
        <div class="grid gap-6 xl:grid-cols-2">

            {{-- By Status --}}
            <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <h3 class="mb-4 text-sm font-semibold text-slate-800 dark:text-white">Requests by Status</h3>
                <div id="r-status-list" class="space-y-2">
                    <p class="text-xs text-slate-400">Click Generate to load data.</p>
                </div>
            </div>

            {{-- By Service Type --}}
            <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <h3 class="mb-4 text-sm font-semibold text-slate-800 dark:text-white">Requests by Service Type</h3>
                <div id="r-service-list" class="space-y-2">
                    <p class="text-xs text-slate-400">Click Generate to load data.</p>
                </div>
            </div>
        </div>

        {{-- Recent requests table --}}
        <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <h3 class="mb-4 text-sm font-semibold text-slate-800 dark:text-white">Recent Repair Requests</h3>
            <div class="overflow-x-auto">
                <table class="w-full text-left text-sm">
                    <thead class="text-xs uppercase tracking-widest text-slate-400">
                        <tr>
                            <th class="px-4 py-3">#</th>
                            <th class="px-4 py-3">Customer</th>
                            <th class="px-4 py-3">Device / Issue</th>
                            <th class="px-4 py-3">Service</th>
                            <th class="px-4 py-3">Technician</th>
                            <th class="px-4 py-3">Status</th>
                            <th class="px-4 py-3 text-right">Date</th>
                        </tr>
                    </thead>
                    <tbody id="r-recent-body" class="divide-y divide-slate-100 text-slate-600 dark:divide-slate-800 dark:text-slate-300">
                        <tr><td colspan="7" class="px-4 py-6 text-center text-xs text-slate-400">Click Generate to load data.</td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    {{-- ── Recent exports ─────────────────────────────────────────────────── --}}
    <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
        <div class="flex items-center justify-between gap-3">
            <h3 class="text-sm font-semibold text-slate-800 dark:text-white">Recent Exports</h3>
            <button id="exports-refresh" class="rounded-xl border border-slate-200 px-3 py-1 text-xs font-semibold text-slate-600 hover:bg-slate-50 dark:border-slate-800 dark:text-slate-300">Refresh</button>
        </div>
        <div id="exports-list" class="mt-4 space-y-3">
            <p class="text-xs text-slate-500">No exports yet.</p>
        </div>
    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function () {
    var $ = function (id) { return document.getElementById(id); };
    var fmt = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' });

    var preset    = $('report-preset');
    var startInp  = $('report-start');
    var endInp    = $('report-end');
    var typeSelect= $('report-type');
    var btnGen    = $('btn-generate');
    var btnExp    = $('btn-export');
    var csvCb     = $('format-csv');
    var pdfCb     = $('format-pdf');

    var salesChart = null;

    // ── Panels ───────────────────────────────────────────────────────────────
    function showPanel(name) {
        ['sales','customers','inventory','repairs'].forEach(function (p) {
            $(p + '-panel').classList.toggle('hidden', p !== name);
        });
    }
    typeSelect.addEventListener('change', function () { showPanel(typeSelect.value); });

    // ── Custom range toggle ───────────────────────────────────────────────────
    function toggleCustom() {
        var custom = preset.value === 'custom';
        $('custom-start-wrap').classList.toggle('hidden', !custom);
        $('custom-end-wrap').classList.toggle('hidden', !custom);
    }
    preset.addEventListener('change', toggleCustom);
    toggleCustom();

    // ── Build query params ────────────────────────────────────────────────────
    function buildParams() {
        var p = new URLSearchParams({ preset: preset.value });
        if (preset.value === 'custom' && startInp.value && endInp.value) {
            p.set('start', startInp.value);
            p.set('end', endInp.value);
        }
        p.set('threshold', 10);
        return p;
    }

    // ── Generate ─────────────────────────────────────────────────────────────
    btnGen.addEventListener('click', generate);
    async function generate() {
        var type = typeSelect.value;
        setLoading(true);
        try {
            var res = await window.adminApi.request('/api/admin/reports/' + type + '?' + buildParams());
            if (!res.ok) { setLoading(false); return; }
            var data = await res.json();
            setLoading(false);

            var rangeText = data.range ? (data.range.label + ' · ' + data.range.start + ' → ' + data.range.end) : '';
            $('range-label-text').textContent = rangeText;
            $('range-label').classList.remove('hidden');

            if (type === 'sales')      renderSales(data);
            if (type === 'customers')  renderCustomers(data);
            if (type === 'inventory')  renderInventory(data);
            if (type === 'repairs')    renderRepairs(data);

            showPanel(type);
        } catch (e) {
            setLoading(false);
        }
    }

    function setLoading(on) {
        $('report-loading').classList.toggle('hidden', !on);
        btnGen.disabled = on;
        btnExp.disabled = on;
    }

    // ── Sales ─────────────────────────────────────────────────────────────────
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
        $('pay-rate-bar').style.width  = rate + '%';
        $('pay-rate-label').textContent = rate + '% paid';

        // Chart
        var daily  = data.daily || [];
        var labels = daily.map(function (d) { return d.day; });
        var values = daily.map(function (d) { return d.total; });
        var isDark = document.documentElement.classList.contains('dark');
        var gridColor = isDark ? 'rgba(255,255,255,0.07)' : 'rgba(0,0,0,0.06)';
        var textColor = isDark ? '#94a3b8' : '#64748b';

        $('chart-range').textContent = data.range ? data.range.label : '';

        if (salesChart) { salesChart.destroy(); }
        var ctx = $('sales-chart').getContext('2d');
        salesChart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Revenue ($)',
                    data: values,
                    backgroundColor: 'rgba(99,102,241,0.75)',
                    borderColor: 'rgba(99,102,241,1)',
                    borderWidth: 1,
                    borderRadius: 6,
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: {
                    x: {
                        ticks: { color: textColor, maxTicksLimit: 10, font: { size: 10 } },
                        grid: { color: gridColor }
                    },
                    y: {
                        ticks: {
                            color: textColor,
                            font: { size: 10 },
                            callback: function (v) { return '$' + v.toLocaleString(); }
                        },
                        grid: { color: gridColor },
                        beginAtZero: true
                    }
                }
            }
        });

        // Top products
        var items = data.top_items || [];
        if (items.length === 0) {
            $('top-products-body').innerHTML = '<tr><td colspan="5" class="px-4 py-6 text-center text-xs text-slate-400">No sales data for this period.</td></tr>';
            return;
        }
        $('top-products-body').innerHTML = items.map(function (item, i) {
            return '<tr class="hover:bg-slate-50 dark:hover:bg-slate-800/40">'
                + '<td class="px-4 py-3 text-xs font-semibold text-slate-400">' + (i + 1) + '</td>'
                + '<td class="px-4 py-3 font-medium text-slate-900 dark:text-white">' + esc(item.name || '—') + '</td>'
                + '<td class="px-4 py-3"><span class="rounded-full bg-slate-100 px-2 py-0.5 text-xs dark:bg-slate-800">' + esc(item.item_type || '—') + '</span></td>'
                + '<td class="px-4 py-3">' + (item.quantity || 0) + '</td>'
                + '<td class="px-4 py-3 text-right font-semibold text-green-700 dark:text-green-400">' + fmt.format(item.sales || 0) + '</td>'
                + '</tr>';
        }).join('');
    }

    // ── Customers ─────────────────────────────────────────────────────────────
    function renderCustomers(data) {
        var m = data.metrics || {};
        $('c-total').textContent  = m.total_customers ?? 0;
        $('c-new').textContent    = m.new_customers ?? 0;
        $('c-active').textContent = m.active_customers ?? 0;
        $('c-repeat').textContent = m.repeat_customers ?? 0;

        var top = data.top_customers || [];
        if (!top.length) {
            $('top-customers-body').innerHTML = '<tr><td colspan="5" class="px-4 py-6 text-center text-xs text-slate-400">No customer activity.</td></tr>';
            return;
        }
        $('top-customers-body').innerHTML = top.map(function (c, i) {
            return '<tr class="hover:bg-slate-50 dark:hover:bg-slate-800/40">'
                + '<td class="px-4 py-3 text-xs font-semibold text-slate-400">' + (i + 1) + '</td>'
                + '<td class="px-4 py-3 font-medium text-slate-900 dark:text-white">' + esc(c.name || '—') + '</td>'
                + '<td class="px-4 py-3 text-xs text-slate-500">' + esc(c.email || '—') + '</td>'
                + '<td class="px-4 py-3">' + (c.orders_count || 0) + '</td>'
                + '<td class="px-4 py-3 text-right font-semibold text-green-700 dark:text-green-400">' + fmt.format(c.total_spent || 0) + '</td>'
                + '</tr>';
        }).join('');
    }

    // ── Inventory ─────────────────────────────────────────────────────────────
    function renderInventory(data) {
        var m = data.metrics || {};
        $('inv-products').textContent    = m.total_products ?? 0;
        $('inv-accessories').textContent = m.total_accessories ?? 0;
        $('inv-parts').textContent       = m.total_parts ?? 0;
        $('inv-low').textContent         = m.low_stock_count ?? 0;

        var low = data.low_stock || [];
        if (!low.length) {
            $('low-stock-body').innerHTML = '<tr><td colspan="5" class="px-4 py-6 text-center text-xs text-slate-400">No low stock items.</td></tr>';
            return;
        }
        $('low-stock-body').innerHTML = low.map(function (item, i) {
            var stockColor = item.stock === 0 ? 'text-red-600 dark:text-red-400' : 'text-yellow-600 dark:text-yellow-400';
            return '<tr class="hover:bg-slate-50 dark:hover:bg-slate-800/40">'
                + '<td class="px-4 py-3 text-xs font-semibold text-slate-400">' + (i + 1) + '</td>'
                + '<td class="px-4 py-3 font-medium text-slate-900 dark:text-white">' + esc(item.name || '—') + '</td>'
                + '<td class="px-4 py-3"><span class="rounded-full bg-slate-100 px-2 py-0.5 text-xs dark:bg-slate-800">' + esc(item.type || '—') + '</span></td>'
                + '<td class="px-4 py-3 text-xs text-slate-500">' + esc(item.sku || '—') + '</td>'
                + '<td class="px-4 py-3 text-right font-bold ' + stockColor + '">' + (item.stock ?? 0) + '</td>'
                + '</tr>';
        }).join('');
    }

    // ── Repairs ───────────────────────────────────────────────────────────────
    function renderRepairs(data) {
        var m = data.metrics || {};
        $('r-total').textContent      = m.total_requests ?? 0;
        $('r-completed').textContent  = m.completed ?? 0;
        $('r-inprogress').textContent = m.in_progress ?? 0;

        var total = m.total_requests || 0;

        var statusColors = {
            received: 'bg-blue-100 text-blue-700 dark:bg-blue-500/10 dark:text-blue-300',
            diagnosing: 'bg-purple-100 text-purple-700 dark:bg-purple-500/10 dark:text-purple-300',
            waiting_approval: 'bg-amber-100 text-amber-700 dark:bg-amber-500/10 dark:text-amber-300',
            in_repair: 'bg-orange-100 text-orange-700 dark:bg-orange-500/10 dark:text-orange-300',
            qc: 'bg-violet-100 text-violet-700 dark:bg-violet-500/10 dark:text-violet-300',
            ready: 'bg-green-100 text-green-700 dark:bg-green-500/10 dark:text-green-300',
            completed: 'bg-emerald-100 text-emerald-700 dark:bg-emerald-500/10 dark:text-emerald-300',
        };
        var serviceLabels = { drop_off: 'Drop-off', pickup: 'Pickup', on_site: 'On-site' };

        // By status
        var byStatus = data.by_status || [];
        if (!byStatus.length) {
            $('r-status-list').innerHTML = '<p class="text-xs text-slate-400">No data.</p>';
        } else {
            $('r-status-list').innerHTML = byStatus.map(function (row) {
                var pct = total > 0 ? Math.round(row.count / total * 100) : 0;
                var colorClass = statusColors[row.status] || 'bg-slate-100 text-slate-700';
                var label = row.status.replace(/_/g, ' ').replace(/\b\w/g, function(c){ return c.toUpperCase(); });
                return '<div class="flex items-center justify-between gap-3">'
                    + '<span class="inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold ' + colorClass + '">' + esc(label) + '</span>'
                    + '<div class="flex flex-1 items-center gap-2">'
                    + '<div class="h-2 flex-1 overflow-hidden rounded-full bg-slate-100 dark:bg-slate-800">'
                    + '<div class="h-full rounded-full bg-indigo-500 transition-all duration-700" style="width:' + pct + '%"></div>'
                    + '</div>'
                    + '<span class="w-8 text-right text-xs font-semibold text-slate-700 dark:text-slate-300">' + row.count + '</span>'
                    + '</div></div>';
            }).join('');
        }

        // By service type
        var byService = data.by_service_type || [];
        if (!byService.length) {
            $('r-service-list').innerHTML = '<p class="text-xs text-slate-400">No data.</p>';
        } else {
            $('r-service-list').innerHTML = byService.map(function (row) {
                var pct = total > 0 ? Math.round(row.count / total * 100) : 0;
                var label = serviceLabels[row.service_type] || row.service_type;
                return '<div class="flex items-center justify-between gap-3">'
                    + '<span class="inline-flex items-center rounded-full bg-slate-100 px-2.5 py-0.5 text-xs font-semibold text-slate-700 dark:bg-slate-800 dark:text-slate-300">' + esc(label) + '</span>'
                    + '<div class="flex flex-1 items-center gap-2">'
                    + '<div class="h-2 flex-1 overflow-hidden rounded-full bg-slate-100 dark:bg-slate-800">'
                    + '<div class="h-full rounded-full bg-violet-500 transition-all duration-700" style="width:' + pct + '%"></div>'
                    + '</div>'
                    + '<span class="w-8 text-right text-xs font-semibold text-slate-700 dark:text-slate-300">' + row.count + '</span>'
                    + '</div></div>';
            }).join('');
        }

        // Recent table
        var recent = data.recent || [];
        if (!recent.length) {
            $('r-recent-body').innerHTML = '<tr><td colspan="7" class="px-4 py-6 text-center text-xs text-slate-400">No repair requests for this period.</td></tr>';
            return;
        }
        $('r-recent-body').innerHTML = recent.map(function (r, i) {
            var statusLabel = (r.status || '').replace(/_/g, ' ').replace(/\b\w/g, function(c){ return c.toUpperCase(); });
            var svcLabel    = serviceLabels[r.service_type] || r.service_type;
            var colorClass  = statusColors[r.status] || 'bg-slate-100 text-slate-700';
            var date        = r.created_at ? r.created_at.slice(0, 10) : '—';
            return '<tr class="hover:bg-slate-50 dark:hover:bg-slate-800/40">'
                + '<td class="px-4 py-3 text-xs font-semibold text-slate-400">' + (i + 1) + '</td>'
                + '<td class="px-4 py-3 font-medium text-slate-900 dark:text-white">' + esc(r.customer_name || '—') + '</td>'
                + '<td class="px-4 py-3 text-xs text-slate-500">' + esc((r.device_model || '—') + ' / ' + (r.issue_type || '—')) + '</td>'
                + '<td class="px-4 py-3"><span class="rounded-full bg-slate-100 px-2 py-0.5 text-xs dark:bg-slate-800">' + esc(svcLabel) + '</span></td>'
                + '<td class="px-4 py-3 text-xs text-slate-500">' + esc(r.technician_name || '—') + '</td>'
                + '<td class="px-4 py-3"><span class="rounded-full px-2 py-0.5 text-xs font-semibold ' + colorClass + '">' + esc(statusLabel) + '</span></td>'
                + '<td class="px-4 py-3 text-right text-xs text-slate-500">' + esc(date) + '</td>'
                + '</tr>';
        }).join('');
    }

    // ── Export ────────────────────────────────────────────────────────────────
    btnExp.addEventListener('click', async function () {
        var formats = [];
        if (csvCb.checked) formats.push('csv');
        if (pdfCb.checked) formats.push('pdf');
        if (!formats.length) { alert('Select at least one export format.'); return; }

        var type = typeSelect.value;
        var payload = { type: type, preset: preset.value, threshold: 10 };
        if (preset.value === 'custom') { payload.start = startInp.value; payload.end = endInp.value; }

        await window.adminApi.ensureCsrfCookie();
        setLoading(true);

        for (var i = 0; i < formats.length; i++) {
            var res = await window.adminApi.request('/api/admin/reports/export', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(Object.assign({}, payload, { format: formats[i] }))
            });
            if (res.ok) {
                var d = await res.json();
                if (d.download_url) window.open(d.download_url, '_blank');
            }
        }
        setLoading(false);
        loadExports();
    });

    // ── Exports list ──────────────────────────────────────────────────────────
    $('exports-refresh').addEventListener('click', loadExports);

    async function loadExports() {
        var res = await window.adminApi.request('/api/admin/reports/exports');
        if (!res.ok) return;
        var data = await res.json();
        var list = data.exports || [];
        if (!list.length) {
            $('exports-list').innerHTML = '<p class="text-xs text-slate-500">No exports yet.</p>';
            return;
        }
        $('exports-list').innerHTML = list.map(function (item) {
            var label = cap(item.type) + ' Report · ' + item.format.toUpperCase();
            var range = item.range ? item.range.start + ' → ' + item.range.end : '';
            var date  = item.generated_at ? new Date(item.generated_at).toLocaleString() : '';
            var kb    = item.size ? (item.size / 1024).toFixed(1) + ' KB' : '';
            return '<div class="flex items-center justify-between gap-4 rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 dark:border-slate-800 dark:bg-slate-950/40">'
                + '<div><p class="text-sm font-semibold text-slate-900 dark:text-white">' + esc(label) + '</p>'
                + '<p class="text-xs text-slate-500">' + [date, range, kb].filter(Boolean).join(' · ') + '</p></div>'
                + '<a href="' + esc(item.download_url) + '" class="inline-flex items-center gap-1 rounded-lg bg-primary-600 px-3 py-1.5 text-xs font-semibold text-white hover:bg-primary-700">'
                + '<svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"/></svg>'
                + 'Download</a></div>';
        }).join('');
    }

    function esc(s) {
        return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
    }
    function cap(s) { return s ? s.charAt(0).toUpperCase() + s.slice(1) : ''; }

    // ── Auto-load sales on open ───────────────────────────────────────────────
    generate();
    loadExports();
});
</script>
@endsection
