@extends('layouts.admin')

@section('title', __('Dashboard'))
@section('page-title', __('Dashboard'))

@section('content')
    @if (auth()->user()?->hasPermission('view_dashboard'))
    <section class="space-y-6">
        <div class="flex flex-wrap items-center justify-between gap-4 rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <div>
                <h2 class="text-lg font-semibold text-slate-900 dark:text-white">{{ __('Overview') }}</h2>
                <p class="text-sm text-slate-500">{{ __('Filter sales and orders by date range.') }}</p>
            </div>
            <div class="flex flex-wrap items-end gap-3">
                <div class="min-w-[170px]">
                    <label class="text-xs font-semibold uppercase tracking-wider text-slate-400">{{ __('Date Range') }}</label>
                    <select id="dashboard-range" class="mt-2 h-10 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-200">
                        <option value="all" selected>{{ __('All time') }}</option>
                        <option value="today">{{ __('Today') }}</option>
                        <option value="yesterday">{{ __('Yesterday') }}</option>
                        <option value="7_days">{{ __('Last 7 days') }}</option>
                        <option value="1_month">{{ __('Last 1 month') }}</option>
                        <option value="2_months">{{ __('Last 2 months') }}</option>
                        <option value="3_months">{{ __('Last 3 months') }}</option>
                        <option value="6_months">{{ __('Last 6 months') }}</option>
                        <option value="1_year">{{ __('Last 1 year') }}</option>
                        <option value="custom">{{ __('Custom range') }}</option>
                    </select>
                </div>
                <div id="dashboard-range-start-wrap" class="hidden min-w-[150px]">
                    <label class="text-xs font-semibold uppercase tracking-wider text-slate-400">{{ __('From') }}</label>
                    <input id="dashboard-range-start" type="date" class="mt-2 h-10 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-200" />
                </div>
                <div id="dashboard-range-end-wrap" class="hidden min-w-[150px]">
                    <label class="text-xs font-semibold uppercase tracking-wider text-slate-400">{{ __('To') }}</label>
                    <input id="dashboard-range-end" type="date" class="mt-2 h-10 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-200" />
                </div>
                <button id="dashboard-range-apply" type="button" class="hidden h-10 inline-flex items-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white shadow-sm hover:bg-primary-700">
                    {{ __('Apply') }}
                </button>
            </div>
        </div>
        <div class="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
                <a id="metric-sales-card" href="{{ route('admin.orders.index') }}" class="block rounded-2xl border border-slate-200 bg-white p-5 shadow-sm transition hover:-translate-y-0.5 hover:border-primary-200 hover:shadow-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2 dark:border-slate-800 dark:bg-slate-900 dark:hover:border-primary-500/40 dark:focus:ring-offset-slate-950">
                    <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">{{ __('Total Sales') }}</p>
                    <div class="mt-4 flex items-end justify-between">
                        <p id="metric-sales" class="text-2xl font-semibold text-slate-900 dark:text-white">--</p>
                        <span class="rounded-full bg-success-50 px-2 py-1 text-xs font-medium text-success-700 dark:bg-success-500/10 dark:text-success-100">{{ __('Live') }}</span>
                    </div>
                    <p id="metric-sales-caption" class="mt-2 text-xs text-slate-500">{{ __('All time') }}</p>
                </a>
                <a id="metric-orders-card" href="{{ route('admin.orders.index') }}" class="block rounded-2xl border border-slate-200 bg-white p-5 shadow-sm transition hover:-translate-y-0.5 hover:border-primary-200 hover:shadow-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2 dark:border-slate-800 dark:bg-slate-900 dark:hover:border-primary-500/40 dark:focus:ring-offset-slate-950">
                    <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">{{ __('Total Orders') }}</p>
                    <div class="mt-4 flex items-end justify-between">
                        <p id="metric-orders" class="text-2xl font-semibold text-slate-900 dark:text-white">--</p>
                        <span class="rounded-full bg-primary-50 px-2 py-1 text-xs font-medium text-primary-700 dark:bg-primary-500/10 dark:text-primary-100">{{ __('Live') }}</span>
                    </div>
                    <p id="metric-orders-caption" class="mt-2 text-xs text-slate-500">{{ __('All time') }}</p>
                </a>
                <a href="{{ route('admin.products.index') }}" class="block rounded-2xl border border-slate-200 bg-white p-5 shadow-sm transition hover:-translate-y-0.5 hover:border-primary-200 hover:shadow-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2 dark:border-slate-800 dark:bg-slate-900 dark:hover:border-primary-500/40 dark:focus:ring-offset-slate-950">
                    <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">{{ __('Total Products') }}</p>
                    <div class="mt-4 flex items-end justify-between">
                        <p id="metric-products" class="text-2xl font-semibold text-slate-900 dark:text-white">--</p>
                        <span class="rounded-full bg-warning-50 px-2 py-1 text-xs font-medium text-warning-700 dark:bg-warning-500/10 dark:text-warning-100">{{ __('Live') }}</span>
                    </div>
                    <p class="mt-2 text-xs text-slate-500">{{ __('All time') }}</p>
                </a>
                <a href="{{ route('admin.customers.index') }}" class="block rounded-2xl border border-slate-200 bg-white p-5 shadow-sm transition hover:-translate-y-0.5 hover:border-primary-200 hover:shadow-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2 dark:border-slate-800 dark:bg-slate-900 dark:hover:border-primary-500/40 dark:focus:ring-offset-slate-950">
                    <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">{{ __('Total Customers') }}</p>
                    <div class="mt-4 flex items-end justify-between">
                        <p id="metric-customers" class="text-2xl font-semibold text-slate-900 dark:text-white">--</p>
                        <span class="rounded-full bg-success-50 px-2 py-1 text-xs font-medium text-success-700 dark:bg-success-500/10 dark:text-success-100">{{ __('Live') }}</span>
                    </div>
                    <p class="mt-2 text-xs text-slate-500">{{ __('All time') }}</p>
                </a>
            </div>

            <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <div class="flex flex-wrap items-center justify-between gap-3">
                    <div>
                        <h2 class="text-lg font-semibold text-slate-900 dark:text-white">{{ __('Recent Orders') }}</h2>
                        <p class="text-sm text-slate-500">{{ __('Track latest transactions and order status.') }}</p>
                    </div>
                    <div class="flex flex-wrap items-center gap-3">
                        <div class="relative">
                            <input type="text" placeholder="{{ __('Search orders') }}" class="h-10 w-52 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                            <svg class="absolute right-3 top-3 h-4 w-4 text-slate-400" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-4.35-4.35m1.6-5.15a7 7 0 11-14 0 7 7 0 0114 0z" />
                            </svg>
                        </div>
                        <div class="relative" id="recent-orders-export-wrap">
                            <button id="recent-orders-export-btn" type="button" class="inline-flex h-10 items-center gap-2 rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-600 shadow-sm hover:text-slate-900 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300">
                                <svg class="h-4 w-4 opacity-70" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
                                </svg>
                                {{ __('Export') }}
                                <svg class="h-3 w-3 opacity-50" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7" />
                                </svg>
                            </button>
                            <div id="recent-orders-export-menu" class="hidden absolute right-0 z-30 mt-2 w-52 overflow-hidden rounded-xl border border-slate-200 bg-white shadow-lg dark:border-slate-800 dark:bg-slate-900">
                                <button id="recent-orders-export-excel" type="button" class="flex w-full items-center gap-3 px-3 py-2.5 text-left text-sm text-slate-600 transition hover:bg-slate-50 dark:text-slate-300 dark:hover:bg-slate-800">
                                    <svg class="h-6 w-6 flex-shrink-0" viewBox="0 0 28 28" fill="none" xmlns="http://www.w3.org/2000/svg">
                                        <rect width="28" height="28" rx="5" fill="#1D6F42"/>
                                        <rect x="5" y="11.75" width="18" height="4.5" rx="2.25" transform="rotate(45 14 14)" fill="white"/>
                                        <rect x="5" y="11.75" width="18" height="4.5" rx="2.25" transform="rotate(-45 14 14)" fill="white"/>
                                    </svg>
                                    <span class="font-medium">{{ __('Excel Workbook') }}</span>
                                </button>
                                <button id="recent-orders-export-pdf" type="button" class="flex w-full items-center gap-3 px-3 py-2.5 text-left text-sm text-slate-600 transition hover:bg-slate-50 dark:text-slate-300 dark:hover:bg-slate-800">
                                    <svg class="h-6 w-6 flex-shrink-0" viewBox="0 0 28 28" fill="none" xmlns="http://www.w3.org/2000/svg">
                                        <path d="M4 4C4 2.9 4.9 2 6 2H14L22 10V24C22 25.1 21.1 26 20 26H6C4.9 26 4 25.1 4 24V4Z" fill="#DC2626"/>
                                        <path d="M14 2L22 10H16C14.9 10 14 9.1 14 8V2Z" fill="#991B1B"/>
                                        <rect x="4" y="12" width="18" height="7" fill="#B91C1C"/>
                                        <text x="13" y="17.5" font-family="Arial, sans-serif" font-size="5.8" font-weight="bold" fill="white" text-anchor="middle">PDF</text>
                                        <rect x="7" y="21.5" width="11" height="1.5" rx="0.75" fill="white" opacity="0.65"/>
                                    </svg>
                                    <span class="font-medium">{{ __('PDF Report') }}</span>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
    
                <div class="mt-5 overflow-x-auto">
                    <table class="w-full text-left text-sm">
                        <thead class="text-xs uppercase tracking-widest text-slate-400">
                            <tr>
                                <th class="px-4 py-3">{{ __('Order ID') }}</th>
                                <th class="px-4 py-3">{{ __('Customer') }}</th>
                                <th class="px-4 py-3">{{ __('Date') }}</th>
                                <th class="px-4 py-3">{{ __('Total') }}</th>
                                <th class="px-4 py-3">{{ __('Payment Status') }}</th>
                                <th class="px-4 py-3 text-right">{{ __('Action') }}</th>
                            </tr>
                        </thead>
                        <tbody id="recent-orders-body" class="divide-y divide-slate-200 text-slate-600 dark:divide-slate-800 dark:text-slate-300"></tbody>
                    </table>
                </div>
                <div class="mt-4 flex items-center justify-between text-xs text-slate-500">
                    <p>{{ __('Showing 1-3 of 128 orders') }}</p>
                    <div class="flex items-center gap-2">
                        <button class="rounded-lg border border-slate-200 px-3 py-1 text-slate-600 dark:border-slate-800 dark:text-slate-300">{{ __('Previous') }}</button>
                        <button class="rounded-lg border border-slate-200 bg-slate-100 px-3 py-1 text-slate-900 dark:border-slate-800 dark:bg-slate-900">{{ __('Next') }}</button>
                    </div>
                </div>
            </div>
        <div class="grid gap-6 lg:grid-cols-[2fr_1fr]">
            <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <div class="flex flex-wrap items-center justify-between gap-3">
                    <div>
                        <h2 class="text-lg font-semibold text-slate-900 dark:text-white">{{ __('Sales Overview') }}</h2>
                        <p id="sales-overview-subtitle" class="text-sm text-slate-500">{{ __('Revenue performance for the selected period.') }}</p>
                    </div>
                    <div class="flex items-center gap-2 text-xs text-slate-500">
                        <span class="inline-flex h-2 w-2 rounded-full bg-primary-500"></span>
                        {{ __('Weekly sales') }}
                    </div>
                </div>
                <div id="sales-overview-container" class="mt-6 rounded-xl bg-slate-50 p-4 dark:bg-slate-950">
                    <div id="sales-overview-empty" class="flex h-40 items-center justify-center text-sm text-slate-500">
                        {{ __('No sales data available yet.') }}
                    </div>
                    <div id="sales-overview-chart" class="hidden">
                        <div id="sales-overview-bars" class="grid h-40 items-end gap-2"></div>
                        <div id="sales-overview-labels" class="mt-3 grid gap-2 text-[10px] uppercase tracking-widest text-slate-400"></div>
                    </div>
                </div>
            </div>

            <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <div class="flex items-center justify-between">
                    <h2 class="text-lg font-semibold text-slate-900 dark:text-white">{{ __('Low Stock Alerts') }}</h2>
                    <a href="{{ route('admin.products.index', ['low_stock' => 1, 'threshold' => 10]) }}" class="text-xs font-semibold text-primary-600">{{ __('View all') }}</a>
                </div>
                <div id="low-stock-list" class="mt-5 space-y-4 text-sm text-slate-500">
                    {{ __('Loading low stock items...') }}
                </div>
            </div>
        </div>

    </section>

    <script>
        const i18n = {
            week: @json(__('Week')),
            orders: @json(__('orders')),
            sku: @json(__('SKU')),
            noSku: @json(__('No SKU')),
            left: @json(__('left')),
            noLowStock: @json(__('No low stock items right now.')),
            unableLowStock: @json(__('Unable to load low stock items.')),
            noRecentOrders: @json(__('No recent orders.')),
            view: @json(__('View')),
            overviewSubtitlePrefix: @json(__('Revenue performance for')),
            paymentStatusLabels: {
                unpaid: @json(__('unpaid')),
                paid: @json(__('paid')),
                failed: @json(__('failed')),
                refunded: @json(__('refunded')),
            },
        };

        document.addEventListener('DOMContentLoaded', async function () {
            var recentOrdersExportBtn = document.getElementById('recent-orders-export-btn');
            var recentOrdersExportMenu = document.getElementById('recent-orders-export-menu');
            if (recentOrdersExportBtn && recentOrdersExportMenu) {
                recentOrdersExportBtn.addEventListener('click', function (e) {
                    e.stopPropagation();
                    recentOrdersExportMenu.classList.toggle('hidden');
                });
                document.addEventListener('click', function () {
                    recentOrdersExportMenu.classList.add('hidden');
                });
                var recentOrdersExportExcel = document.getElementById('recent-orders-export-excel');
                if (recentOrdersExportExcel) {
                    recentOrdersExportExcel.addEventListener('click', function () {
                        window.location.href = '/api/admin/orders/export-excel';
                        recentOrdersExportMenu.classList.add('hidden');
                    });
                }
                var recentOrdersExportPdf = document.getElementById('recent-orders-export-pdf');
                if (recentOrdersExportPdf) {
                    recentOrdersExportPdf.addEventListener('click', function () {
                        window.location.href = '/api/admin/orders/export-pdf';
                        recentOrdersExportMenu.classList.add('hidden');
                    });
                }
            }

            function formatCurrency(value) {
                return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(value || 0);
            }

            function renderSalesOverview(series) {
                const chart = document.getElementById('sales-overview-chart');
                const emptyState = document.getElementById('sales-overview-empty');
                const bars = document.getElementById('sales-overview-bars');
                const labels = document.getElementById('sales-overview-labels');

                if (!chart || !emptyState || !bars || !labels) {
                    return;
                }

                if (!Array.isArray(series) || series.length === 0) {
                    chart.classList.add('hidden');
                    emptyState.classList.remove('hidden');
                    return;
                }

                const maxValue = series.reduce(function (carry, entry) {
                    const total = Number(entry.total || 0);
                    return total > carry ? total : carry;
                }, 0);

                if (maxValue <= 0) {
                    chart.classList.add('hidden');
                    emptyState.classList.remove('hidden');
                    return;
                }

                const columns = 'repeat(' + series.length + ', minmax(0, 1fr))';
                bars.style.gridTemplateColumns = columns;
                labels.style.gridTemplateColumns = columns;

                // Avoid overcrowding the axis when a range produces many buckets (e.g. hourly/daily views).
                const labelStep = Math.max(1, Math.ceil(series.length / 12));

                bars.innerHTML = '';
                labels.innerHTML = '';
                series.forEach(function (entry, index) {
                    const total = Number(entry.total || 0);
                    const count = Number(entry.order_count || 0);
                    const height = total > 0 ? Math.max(6, Math.round((total / maxValue) * 100)) : 0;

                    const bar = document.createElement('div');
                    bar.className = 'self-end rounded-lg bg-primary-500/80 shadow-sm';
                    bar.style.height = height + '%';
                    bar.setAttribute('title', (entry.label || i18n.week) + ' · ' + formatCurrency(total) + ' · ' + count + ' ' + i18n.orders);
                    bars.appendChild(bar);

                    const label = document.createElement('div');
                    label.className = 'truncate text-center';
                    label.textContent = (index % labelStep === 0) ? (entry.label || '') : '';
                    labels.appendChild(label);
                });

                emptyState.classList.add('hidden');
                chart.classList.remove('hidden');
            }

            const rangeSelect = document.getElementById('dashboard-range');
            const rangeStartInput = document.getElementById('dashboard-range-start');
            const rangeEndInput = document.getElementById('dashboard-range-end');
            const rangeStartWrap = document.getElementById('dashboard-range-start-wrap');
            const rangeEndWrap = document.getElementById('dashboard-range-end-wrap');
            const rangeApplyBtn = document.getElementById('dashboard-range-apply');
            const salesCaption = document.getElementById('metric-sales-caption');
            const ordersCaption = document.getElementById('metric-orders-caption');
            const overviewSubtitle = document.getElementById('sales-overview-subtitle');
            const salesCard = document.getElementById('metric-sales-card');
            const ordersCard = document.getElementById('metric-orders-card');
            const ordersIndexUrl = @json(route('admin.orders.index'));
            let latestMetricsRange = null;

            function toggleCustomRangeInputs() {
                const isCustom = rangeSelect.value === 'custom';
                rangeStartWrap.classList.toggle('hidden', !isCustom);
                rangeEndWrap.classList.toggle('hidden', !isCustom);
                rangeApplyBtn.classList.toggle('hidden', !isCustom);
            }

            function currentRangeCaption() {
                if (rangeSelect.value === 'custom' && rangeStartInput.value && rangeEndInput.value) {
                    return rangeStartInput.value + ' → ' + rangeEndInput.value;
                }
                const selectedOption = rangeSelect.options[rangeSelect.selectedIndex];
                return selectedOption ? selectedOption.textContent : '';
            }

            function updateMetricCardLinks() {
                const params = new URLSearchParams();
                if (latestMetricsRange && latestMetricsRange.start) {
                    params.set('from_date', latestMetricsRange.start);
                    if (latestMetricsRange.end) {
                        params.set('to_date', latestMetricsRange.end);
                    }
                }

                const query = params.toString();
                const ordersUrl = ordersIndexUrl + (query ? '?' + query : '');
                if (salesCard) salesCard.href = ordersUrl;
                if (ordersCard) ordersCard.href = ordersUrl;
            }

            async function loadMetrics() {
                try {
                    await window.adminApi.ensureCsrfCookie();
                    const params = new URLSearchParams({ range: rangeSelect.value });
                    if (rangeSelect.value === 'custom') {
                        if (!rangeStartInput.value || !rangeEndInput.value) {
                            return;
                        }
                        params.set('start_date', rangeStartInput.value);
                        params.set('end_date', rangeEndInput.value);
                    }

                    const response = await window.adminApi.request('/api/admin/metrics?' + params.toString());
                    if (!response.ok) {
                        return;
                    }
                    const data = await response.json();
                    latestMetricsRange = data.range || null;
                    document.getElementById('metric-sales').textContent = formatCurrency(data.total_sales || 0);
                    document.getElementById('metric-orders').textContent = data.total_orders ?? '--';
                    document.getElementById('metric-products').textContent = data.total_products ?? '--';
                    document.getElementById('metric-customers').textContent = data.total_customers ?? '--';

                    const caption = currentRangeCaption();
                    if (salesCaption) salesCaption.textContent = caption;
                    if (ordersCaption) ordersCaption.textContent = caption;
                    if (overviewSubtitle) {
                        overviewSubtitle.textContent = i18n.overviewSubtitlePrefix + ' ' + caption;
                    }

                    updateMetricCardLinks();
                    renderSalesOverview(data.sales_series || []);
                } catch (error) {
                    console.error(error);
                }
            }

            if (rangeSelect) {
                toggleCustomRangeInputs();
                rangeSelect.addEventListener('change', function () {
                    toggleCustomRangeInputs();
                    if (rangeSelect.value !== 'custom') {
                        loadMetrics();
                    }
                });
                rangeApplyBtn.addEventListener('click', loadMetrics);
            }

            await loadMetrics();

            try {
                const lowStockResponse = await window.adminApi.request('/api/products?low_stock=1&threshold=10');
                const lowStockList = document.getElementById('low-stock-list');
                if (lowStockResponse.ok) {
                    const lowStockData = await lowStockResponse.json();
                    if (!lowStockData.data.length) {
                        lowStockList.textContent = i18n.noLowStock;
                    } else {
                        lowStockList.innerHTML = lowStockData.data.map(function (item) {
                            return `
                                <div class="flex items-center justify-between rounded-xl border border-warning-100 bg-warning-50 px-3 py-3 text-sm dark:border-warning-500/20 dark:bg-warning-500/10">
                                    <div>
                                        <p class="font-semibold text-slate-900 dark:text-white">${item.name}</p>
                                        <p class="text-xs text-slate-500">${item.sku ? i18n.sku + ': ' + item.sku : i18n.noSku}</p>
                                    </div>
                                    <span class="text-xs font-semibold text-warning-700">${item.stock} ${i18n.left}</span>
                                </div>
                            `;
                        }).join('');
                    }
                } else {
                    lowStockList.textContent = i18n.unableLowStock;
                }
            } catch (error) {
                console.error(error);
            }

            try {
                const ordersResponse = await window.adminApi.request('/api/orders?per_page=5');
                if (ordersResponse.ok) {
                    const ordersData = await ordersResponse.json();
                    const normalizePaymentStatus = function (status) {
                        if (!status) {
                            return 'unpaid';
                        }
                        const normalized = String(status).toLowerCase();
                        if (normalized === 'success') {
                            return 'paid';
                        }
                        if (normalized === 'failed') {
                            return 'failed';
                        }
                        if (normalized === 'processing' || normalized === 'pending') {
                            return 'unpaid';
                        }
                        return normalized;
                    };
                    const paymentOptions = ['unpaid', 'paid', 'failed', 'refunded'];
                    const rows = ordersData.data.map(function (order) {
                        const normalizedPaymentStatus = normalizePaymentStatus(order.payment_status);
                        const paymentClass = normalizedPaymentStatus === 'paid'
                            ? 'bg-success-50 text-success-700 dark:bg-success-500/10 dark:text-success-100'
                            : normalizedPaymentStatus === 'failed'
                                ? 'bg-danger-50 text-danger-700 dark:bg-danger-500/10 dark:text-danger-100'
                                : normalizedPaymentStatus === 'refunded'
                                    ? 'bg-slate-100 text-slate-700 dark:bg-slate-800 dark:text-slate-200'
                                    : 'bg-warning-50 text-warning-700 dark:bg-warning-500/10 dark:text-warning-100';

                        const paymentSelectOptions = paymentOptions.map(function (status) {
                            const selected = status === normalizedPaymentStatus ? 'selected' : '';
                            return `<option value="${status}" ${selected}>${i18n.paymentStatusLabels[status] || status}</option>`;
                        }).join('');

                        return `
                            <tr class="cursor-pointer hover:bg-slate-50 dark:hover:bg-slate-800/60" onclick="window.location.href='/admin/orders/${order.id}'">
                                <td class="px-4 py-3 font-semibold text-slate-900 dark:text-white">${order.order_number}</td>
                                <td class="px-4 py-3">${order.customer_name}</td>
                                <td class="px-4 py-3">${order.placed_at ? new Date(order.placed_at).toLocaleDateString() : '-'}</td>
                                <td class="px-4 py-3">${new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(order.total_amount || 0)}</td>
                                <td class="px-4 py-3">
                                    <span class="payment-badge rounded-full px-2 py-1 text-xs font-semibold ${paymentClass}" data-order-id="${order.id}">${i18n.paymentStatusLabels[normalizedPaymentStatus] || normalizedPaymentStatus}</span>
                                </td>
                                <td class="px-4 py-3 text-right" onclick="event.stopPropagation()">
                                    <div class="flex items-center justify-end gap-2">
                                        <select class="payment-status-select h-9 rounded-lg border border-slate-200 bg-white px-2 text-xs text-slate-700 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-200" data-order-id="${order.id}" data-current="${normalizedPaymentStatus}">
                                            ${paymentSelectOptions}
                                        </select>
                                        <a href="/admin/orders/${order.id}" class="text-xs font-semibold text-primary-600">${i18n.view}</a>
                                    </div>
                                </td>
                            </tr>
                        `;
                    }).join('');
                    document.getElementById('recent-orders-body').innerHTML = rows || ('<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="6">' + i18n.noRecentOrders + '</td></tr>');

                    document.querySelectorAll('.payment-status-select').forEach(function (select) {
                        select.addEventListener('change', async function (event) {
                            const target = event.target;
                            const orderId = target.dataset.orderId;
                            const newStatus = target.value;
                            const previousStatus = target.dataset.current;

                            try {
                                await window.adminApi.ensureCsrfCookie();
                                const updateResponse = await window.adminApi.request('/api/orders/' + orderId, {
                                    method: 'PATCH',
                                    headers: { 'Content-Type': 'application/json' },
                                    body: JSON.stringify({ payment_status: newStatus })
                                });

                                if (!updateResponse.ok) {
                                    target.value = previousStatus;
                                    return;
                                }

                                target.dataset.current = newStatus;
                                const badge = document.querySelector('.payment-badge[data-order-id="' + orderId + '"]');
                                if (badge) {
                                    badge.textContent = i18n.paymentStatusLabels[newStatus] || newStatus;
                                    badge.className = 'payment-badge rounded-full px-2 py-1 text-xs font-semibold ' + (
                                        newStatus === 'paid'
                                            ? 'bg-success-50 text-success-700 dark:bg-success-500/10 dark:text-success-100'
                                            : newStatus === 'failed'
                                                ? 'bg-danger-50 text-danger-700 dark:bg-danger-500/10 dark:text-danger-100'
                                                : newStatus === 'refunded'
                                                    ? 'bg-slate-100 text-slate-700 dark:bg-slate-800 dark:text-slate-200'
                                                    : 'bg-warning-50 text-warning-700 dark:bg-warning-500/10 dark:text-warning-100'
                                    );
                                }
                            } catch (error) {
                                target.value = previousStatus;
                                console.error(error);
                            }
                        });
                    });
                }
            } catch (error) {
                console.error(error);
            }
        });
    </script>
    @else
    <section class="space-y-6">
        <div class="rounded-2xl border border-slate-200 bg-white p-10 text-center shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <p class="text-lg font-semibold text-slate-900 dark:text-white">{{ __('Welcome') }}, {{ auth()->user()?->name }}</p>
            <p class="mt-2 text-sm text-slate-500">{{ __('Use the menu on the left to open the pages you have access to.') }}</p>
        </div>
    </section>
    @endif
@endsection
