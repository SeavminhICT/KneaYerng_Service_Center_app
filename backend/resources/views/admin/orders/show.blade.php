@extends('layouts.admin')

@section('title', 'Order Details')
@section('page-title', 'Order Details')

@section('content')
    <div class="grid gap-6 lg:grid-cols-[2fr_1fr]" id="order-detail" data-order-id="{{ $orderId ?? '' }}">
        <div class="space-y-6">
            <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <div class="flex flex-wrap items-center justify-between gap-3">
                    <div>
                        <p class="text-xs uppercase tracking-widest text-slate-400" id="order-number">Order</p>
                        <h2 class="text-lg font-semibold text-slate-900 dark:text-white" id="order-customer">Customer</h2>
                        <p class="text-sm text-slate-500" id="order-meta">--</p>
                    </div>
                    <span class="rounded-full bg-primary-50 px-3 py-1 text-xs font-semibold text-primary-700 dark:bg-primary-500/10 dark:text-primary-100" id="order-status">--</span>
                </div>

                <div class="mt-6 overflow-x-auto">
                    <table class="w-full text-left text-sm">
                        <thead class="text-xs uppercase tracking-widest text-slate-400">
                            <tr>
                                <th class="px-4 py-3">Item</th>
                                <th class="px-4 py-3">Qty</th>
                                <th class="px-4 py-3">Price</th>
                                <th class="px-4 py-3 text-right">Total</th>
                            </tr>
                        </thead>
                        <tbody id="order-items" class="divide-y divide-slate-200 text-slate-600 dark:divide-slate-800 dark:text-slate-300"></tbody>
                    </table>
                </div>
            </div>
        </div>

        <div class="space-y-6">
            <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <h3 class="text-sm font-semibold text-slate-900 dark:text-white">Customer</h3>
                <div class="mt-4 space-y-3 text-sm text-slate-600 dark:text-slate-300">
                    <p class="font-semibold text-slate-900 dark:text-white" id="customer-name">--</p>
                    <p id="customer-email">--</p>
                </div>
            </div>

            <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <h3 class="text-sm font-semibold text-slate-900 dark:text-white">Payment Summary</h3>
                <div class="mt-4 space-y-2 text-sm text-slate-600 dark:text-slate-300">
                    <div class="flex items-center justify-between font-semibold text-slate-900 dark:text-white">
                        <span>Total</span>
                        <span id="order-total">--</span>
                    </div>
                    <div class="mt-3">
                        <span class="rounded-full bg-success-50 px-2 py-1 text-xs font-semibold text-success-700 dark:bg-success-500/10 dark:text-success-100" id="order-payment">--</span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', async function () {
            var container = document.getElementById('order-detail');
            var orderId = container.dataset.orderId;
            if (!orderId) {
                return;
            }

            await window.adminApi.ensureCsrfCookie();
            var response = await window.adminApi.request('/api/orders/' + orderId);
            if (!response.ok) {
                return;
            }
            var data = await response.json();
            var order = data.data;

            document.getElementById('order-number').textContent = order.order_number || 'Order';
            document.getElementById('order-customer').textContent = order.customer_name || '--';
            document.getElementById('order-meta').textContent = order.placed_at ? new Date(order.placed_at).toLocaleString() : '--';
            document.getElementById('order-status').textContent = order.status || '--';
            document.getElementById('customer-name').textContent = order.customer_name || '--';
            document.getElementById('customer-email').textContent = order.customer_email || '--';
            document.getElementById('order-total').textContent = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(order.total_amount || 0);
            document.getElementById('order-payment').textContent = order.payment_status || '--';

            var items = order.items || [];
            var rows = items.map(function (item) {
                var total = (item.quantity || 0) * (item.price || 0);
                return `
                    <tr>
                        <td class="px-4 py-3 font-semibold text-slate-900 dark:text-white">${item.product_name}</td>
                        <td class="px-4 py-3">${item.quantity}</td>
                        <td class="px-4 py-3">${new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(item.price || 0)}</td>
                        <td class="px-4 py-3 text-right">${new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(total)}</td>
                    </tr>
                `;
            }).join('');

            document.getElementById('order-items').innerHTML = rows || '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="4">No items found.</td></tr>';
        });
    </script>
@endsection
