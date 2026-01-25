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
                    <div class="mt-4">
                        <label class="block text-xs font-semibold uppercase tracking-widest text-slate-400">Manage payment status</label>
                        <div class="mt-2 flex flex-wrap items-center gap-3">
                            <select id="payment-status-select" class="h-10 min-w-[160px] flex-1 rounded-xl border border-slate-200 bg-white px-3 text-sm text-slate-700 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-200">
                                <option value="unpaid">unpaid</option>
                                <option value="paid">paid</option>
                                <option value="failed">failed</option>
                                <option value="refunded">refunded</option>
                            </select>
                            <button type="button" id="payment-status-save" class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-xs font-semibold text-white shadow-sm hover:bg-primary-700 disabled:cursor-not-allowed disabled:bg-slate-300 dark:disabled:bg-slate-700">Save</button>
                        </div>
                        <p id="payment-status-note" class="mt-2 text-xs text-slate-500"></p>
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

            var paymentStatusSelect = document.getElementById('payment-status-select');
            var paymentStatusSave = document.getElementById('payment-status-save');
            var paymentStatusNote = document.getElementById('payment-status-note');
            var normalizePaymentStatus = function (status) {
                if (!status) {
                    return 'unpaid';
                }
                var normalized = String(status).toLowerCase();
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
            var currentPaymentStatus = 'pending';
            var currentOrder = null;

            function setPaymentBadge(status) {
                var badge = document.getElementById('order-payment');
                if (!badge) {
                    return;
                }
                badge.textContent = status;
                badge.className = 'rounded-full px-2 py-1 text-xs font-semibold ' + (
                    status === 'paid'
                        ? 'bg-success-50 text-success-700 dark:bg-success-500/10 dark:text-success-100'
                        : status === 'failed'
                            ? 'bg-danger-50 text-danger-700 dark:bg-danger-500/10 dark:text-danger-100'
                            : status === 'refunded'
                                ? 'bg-slate-100 text-slate-700 dark:bg-slate-800 dark:text-slate-200'
                                : 'bg-warning-50 text-warning-700 dark:bg-warning-500/10 dark:text-warning-100'
                );
            }

            function renderOrder(order) {
                currentOrder = order;
                currentPaymentStatus = normalizePaymentStatus(order.payment_status);

                document.getElementById('order-number').textContent = order.order_number || 'Order';
                document.getElementById('order-customer').textContent = order.customer_name || '--';
                document.getElementById('order-meta').textContent = order.placed_at ? new Date(order.placed_at).toLocaleString() : '--';
                document.getElementById('order-status').textContent = order.status || '--';
                document.getElementById('customer-name').textContent = order.customer_name || '--';
                document.getElementById('customer-email').textContent = order.customer_email || '--';
                document.getElementById('order-total').textContent = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(order.total_amount || 0);
                setPaymentBadge(currentPaymentStatus);
                paymentStatusSelect.value = currentPaymentStatus;
                paymentStatusSave.disabled = true;
                paymentStatusNote.textContent = '';

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
            }

            async function loadOrder() {
                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/orders/' + orderId);
                if (!response.ok) {
                    return;
                }
                var data = await response.json();
                renderOrder(data.data);
            }

            await loadOrder();

            paymentStatusSelect.addEventListener('change', function (event) {
                var newStatus = event.target.value;
                paymentStatusSave.disabled = newStatus === currentPaymentStatus;
                paymentStatusNote.textContent = newStatus === currentPaymentStatus ? '' : 'Unsaved changes';
            });

            paymentStatusSave.addEventListener('click', async function () {
                var newStatus = paymentStatusSelect.value;
                var previousStatus = currentPaymentStatus;
                if (newStatus === previousStatus) {
                    return;
                }

                try {
                    paymentStatusSave.disabled = true;
                    paymentStatusNote.textContent = 'Saving...';
                    await window.adminApi.ensureCsrfCookie();
                    var updateResponse = await window.adminApi.request('/api/orders/' + orderId, {
                        method: 'PATCH',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ payment_status: newStatus })
                    });

                    if (!updateResponse.ok) {
                        paymentStatusSelect.value = previousStatus;
                        paymentStatusSave.disabled = false;
                        paymentStatusNote.textContent = 'Save failed.';
                        return;
                    }

                    await loadOrder();
                    paymentStatusNote.textContent = 'Saved.';
                } catch (error) {
                    paymentStatusSelect.value = previousStatus;
                    paymentStatusSave.disabled = false;
                    paymentStatusNote.textContent = 'Save failed.';
                    console.error(error);
                }
            });
        });
    </script>
@endsection
