@extends('layouts.admin')

@section('title', 'Dashboard')
@section('page-title', 'Dashboard')

@section('content')
    <section class="space-y-6">
        <div class="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
                <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                    <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Total Sales</p>
                    <div class="mt-4 flex items-end justify-between">
                        <p id="metric-sales" class="text-2xl font-semibold text-slate-900 dark:text-white">--</p>
                        <span class="rounded-full bg-success-50 px-2 py-1 text-xs font-medium text-success-700 dark:bg-success-500/10 dark:text-success-100">Live</span>
                    </div>
                    <p class="mt-2 text-xs text-slate-500">All time</p>
                </div>
                <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                    <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Total Orders</p>
                    <div class="mt-4 flex items-end justify-between">
                        <p id="metric-orders" class="text-2xl font-semibold text-slate-900 dark:text-white">--</p>
                        <span class="rounded-full bg-primary-50 px-2 py-1 text-xs font-medium text-primary-700 dark:bg-primary-500/10 dark:text-primary-100">Live</span>
                    </div>
                    <p class="mt-2 text-xs text-slate-500">All time</p>
                </div>
                <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                    <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Total Products</p>
                    <div class="mt-4 flex items-end justify-between">
                        <p id="metric-products" class="text-2xl font-semibold text-slate-900 dark:text-white">--</p>
                        <span class="rounded-full bg-warning-50 px-2 py-1 text-xs font-medium text-warning-700 dark:bg-warning-500/10 dark:text-warning-100">Live</span>
                    </div>
                    <p class="mt-2 text-xs text-slate-500">All time</p>
                </div>
                <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                    <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Total Customers</p>
                    <div class="mt-4 flex items-end justify-between">
                        <p id="metric-customers" class="text-2xl font-semibold text-slate-900 dark:text-white">--</p>
                        <span class="rounded-full bg-success-50 px-2 py-1 text-xs font-medium text-success-700 dark:bg-success-500/10 dark:text-success-100">Live</span>
                    </div>
                    <p class="mt-2 text-xs text-slate-500">All time</p>
                </div>
            </div>

            <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <div class="flex flex-wrap items-center justify-between gap-3">
                    <div>
                        <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Recent Orders</h2>
                        <p class="text-sm text-slate-500">Track latest transactions and order status.</p>
                    </div>
                    <div class="flex flex-wrap items-center gap-3">
                        <div class="relative">
                            <input type="text" placeholder="Search orders" class="h-10 w-52 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                            <svg class="absolute right-3 top-3 h-4 w-4 text-slate-400" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-4.35-4.35m1.6-5.15a7 7 0 11-14 0 7 7 0 0114 0z" />
                            </svg>
                        </div>
                        <button class="inline-flex h-10 items-center gap-2 rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-600 shadow-sm hover:text-slate-900 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300">Export</button>
                    </div>
                </div>
    
                <div class="mt-5 overflow-x-auto">
                    <table class="w-full text-left text-sm">
                        <thead class="text-xs uppercase tracking-widest text-slate-400">
                            <tr>
                                <th class="px-4 py-3">Order ID</th>
                                <th class="px-4 py-3">Customer</th>
                                <th class="px-4 py-3">Date</th>
                                <th class="px-4 py-3">Total</th>
                                <th class="px-4 py-3">Payment Status</th>
                                <th class="px-4 py-3 text-right">Action</th>
                            </tr>
                        </thead>
                        <tbody id="recent-orders-body" class="divide-y divide-slate-200 text-slate-600 dark:divide-slate-800 dark:text-slate-300"></tbody>
                    </table>
                </div>
                <div class="mt-4 flex items-center justify-between text-xs text-slate-500">
                    <p>Showing 1-3 of 128 orders</p>
                    <div class="flex items-center gap-2">
                        <button class="rounded-lg border border-slate-200 px-3 py-1 text-slate-600 dark:border-slate-800 dark:text-slate-300">Previous</button>
                        <button class="rounded-lg border border-slate-200 bg-slate-100 px-3 py-1 text-slate-900 dark:border-slate-800 dark:bg-slate-900">Next</button>
                    </div>
                </div>
            </div>
        <div class="grid gap-6 lg:grid-cols-[2fr_1fr]">
            <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <div class="flex flex-wrap items-center justify-between gap-3">
                    <div>
                        <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Sales Overview</h2>
                        <p class="text-sm text-slate-500">Revenue performance for the last 12 weeks.</p>
                    </div>
                    <div class="flex items-center gap-2 text-xs text-slate-500">
                        <span class="inline-flex h-2 w-2 rounded-full bg-primary-500"></span>
                        Weekly sales
                    </div>
                </div>
                <div id="sales-overview-container" class="mt-6 rounded-xl bg-slate-50 p-4 dark:bg-slate-950">
                    <div id="sales-overview-empty" class="flex h-40 items-center justify-center text-sm text-slate-500">
                        No sales data available yet.
                    </div>
                    <div id="sales-overview-chart" class="hidden">
                        <div id="sales-overview-bars" class="grid h-40 grid-cols-12 items-end gap-2"></div>
                        <div id="sales-overview-labels" class="mt-3 grid grid-cols-12 gap-2 text-[10px] uppercase tracking-widest text-slate-400"></div>
                    </div>
                </div>
            </div>

            <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <div class="flex items-center justify-between">
                    <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Low Stock Alerts</h2>
                    <a href="{{ route('admin.products.index') }}" class="text-xs font-semibold text-primary-600">View all</a>
                </div>
                <div id="low-stock-list" class="mt-5 space-y-4 text-sm text-slate-500">
                    Loading low stock items...
                </div>
            </div>
        </div>

    </section>

    <script>
        document.addEventListener('DOMContentLoaded', async function () {
            function formatCurrency(value) {
                return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(value || 0);
            }

            function renderSalesOverview(weeklySales) {
                const chart = document.getElementById('sales-overview-chart');
                const emptyState = document.getElementById('sales-overview-empty');
                const bars = document.getElementById('sales-overview-bars');
                const labels = document.getElementById('sales-overview-labels');

                if (!chart || !emptyState || !bars || !labels) {
                    return;
                }

                if (!Array.isArray(weeklySales) || weeklySales.length === 0) {
                    chart.classList.add('hidden');
                    emptyState.classList.remove('hidden');
                    return;
                }

                const maxValue = weeklySales.reduce(function (carry, entry) {
                    const total = Number(entry.total || 0);
                    return total > carry ? total : carry;
                }, 0);

                if (maxValue <= 0) {
                    chart.classList.add('hidden');
                    emptyState.classList.remove('hidden');
                    return;
                }

                bars.innerHTML = '';
                labels.innerHTML = '';
                weeklySales.forEach(function (entry) {
                    const total = Number(entry.total || 0);
                    const count = Number(entry.order_count || 0);
                    const height = total > 0 ? Math.max(6, Math.round((total / maxValue) * 100)) : 0;

                    const bar = document.createElement('div');
                    bar.className = 'self-end rounded-lg bg-primary-500/80 shadow-sm';
                    bar.style.height = height + '%';
                    bar.setAttribute('title', (entry.label || 'Week') + ' · ' + formatCurrency(total) + ' · ' + count + ' orders');
                    bars.appendChild(bar);

                    const label = document.createElement('div');
                    label.className = 'truncate text-center';
                    label.textContent = entry.label || '';
                    labels.appendChild(label);
                });

                emptyState.classList.add('hidden');
                chart.classList.remove('hidden');
            }

            try {
                await window.adminApi.ensureCsrfCookie();
                const response = await window.adminApi.request('/api/admin/metrics');
                if (!response.ok) {
                    return;
                }
                const data = await response.json();
                document.getElementById('metric-sales').textContent = formatCurrency(data.total_sales || 0);
                document.getElementById('metric-orders').textContent = data.total_orders ?? '--';
                document.getElementById('metric-products').textContent = data.total_products ?? '--';
                document.getElementById('metric-customers').textContent = data.total_customers ?? '--';
                renderSalesOverview(data.weekly_sales || []);
            } catch (error) {
                console.error(error);
            }

            try {
                const lowStockResponse = await window.adminApi.request('/api/products?low_stock=1&threshold=10');
                const lowStockList = document.getElementById('low-stock-list');
                if (lowStockResponse.ok) {
                    const lowStockData = await lowStockResponse.json();
                    if (!lowStockData.data.length) {
                        lowStockList.textContent = 'No low stock items right now.';
                    } else {
                        lowStockList.innerHTML = lowStockData.data.map(function (item) {
                            return `
                                <div class="flex items-center justify-between rounded-xl border border-warning-100 bg-warning-50 px-3 py-3 text-sm dark:border-warning-500/20 dark:bg-warning-500/10">
                                    <div>
                                        <p class="font-semibold text-slate-900 dark:text-white">${item.name}</p>
                                        <p class="text-xs text-slate-500">${item.sku ? 'SKU: ' + item.sku : 'No SKU'}</p>
                                    </div>
                                    <span class="text-xs font-semibold text-warning-700">${item.stock} left</span>
                                </div>
                            `;
                        }).join('');
                    }
                } else {
                    lowStockList.textContent = 'Unable to load low stock items.';
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
                            return `<option value="${status}" ${selected}>${status}</option>`;
                        }).join('');

                        return `
                            <tr>
                                <td class="px-4 py-3 font-semibold text-slate-900 dark:text-white">${order.order_number}</td>
                                <td class="px-4 py-3">${order.customer_name}</td>
                                <td class="px-4 py-3">${order.placed_at ? new Date(order.placed_at).toLocaleDateString() : '-'}</td>
                                <td class="px-4 py-3">${new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(order.total_amount || 0)}</td>
                                <td class="px-4 py-3">
                                    <span class="payment-badge rounded-full px-2 py-1 text-xs font-semibold ${paymentClass}" data-order-id="${order.id}">${normalizedPaymentStatus}</span>
                                </td>
                                <td class="px-4 py-3 text-right">
                                    <div class="flex items-center justify-end gap-2">
                                        <select class="payment-status-select h-9 rounded-lg border border-slate-200 bg-white px-2 text-xs text-slate-700 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-200" data-order-id="${order.id}" data-current="${normalizedPaymentStatus}">
                                            ${paymentSelectOptions}
                                        </select>
                                        <a href="/admin/orders/${order.id}" class="text-xs font-semibold text-primary-600">View</a>
                                    </div>
                                </td>
                            </tr>
                        `;
                    }).join('');
                    document.getElementById('recent-orders-body').innerHTML = rows || '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="6">No recent orders.</td></tr>';

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
                                    badge.textContent = newStatus;
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
@endsection
