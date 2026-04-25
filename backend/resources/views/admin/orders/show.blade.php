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
                <h3 class="text-sm font-semibold text-slate-900 dark:text-white">Order Workflow</h3>
                <div class="mt-4 space-y-3 text-sm text-slate-600 dark:text-slate-300">
                    <div class="flex items-center justify-between">
                        <span>Type</span>
                        <span class="font-semibold text-slate-900 dark:text-white" id="order-type">--</span>
                    </div>
                    <div class="flex items-center justify-between">
                        <span>Current</span>
                        <span class="font-semibold text-slate-900 dark:text-white" id="order-status-current">--</span>
                    </div>
                    <div class="flex items-center justify-between">
                        <span>Assigned Staff</span>
                        <span class="font-semibold text-slate-900 dark:text-white" id="assigned-staff-name">--</span>
                    </div>
                    <div class="mt-4">
                        <label class="block text-xs font-semibold uppercase tracking-widest text-slate-400">Admin actions</label>
                        <div class="mt-2 flex flex-wrap items-center gap-3">
                            <button type="button" id="order-approve" class="inline-flex h-10 items-center rounded-xl bg-success-600 px-4 text-xs font-semibold text-white shadow-sm hover:bg-success-700 disabled:cursor-not-allowed disabled:bg-slate-300 dark:disabled:bg-slate-700">Approve</button>
                            <button type="button" id="order-reject" class="inline-flex h-10 items-center rounded-xl bg-danger-600 px-4 text-xs font-semibold text-white shadow-sm hover:bg-danger-700 disabled:cursor-not-allowed disabled:bg-slate-300 dark:disabled:bg-slate-700">Reject</button>
                        </div>
                        <textarea id="order-action-note" rows="3" placeholder="Reason or admin note" class="mt-3 w-full rounded-xl border border-slate-200 bg-white px-3 py-3 text-sm text-slate-700 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-200"></textarea>
                    </div>
                    <div class="mt-4">
                        <label class="block text-xs font-semibold uppercase tracking-widest text-slate-400">Assign staff</label>
                        <div class="mt-2 flex flex-wrap items-center gap-3">
                            <select id="assigned-staff-select" class="h-10 min-w-[180px] flex-1 rounded-xl border border-slate-200 bg-white px-3 text-sm text-slate-700 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-200">
                                <option value="">Select staff</option>
                            </select>
                            <button type="button" id="assigned-staff-save" class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-xs font-semibold text-white shadow-sm hover:bg-primary-700 disabled:cursor-not-allowed disabled:bg-slate-300 dark:disabled:bg-slate-700">Assign</button>
                        </div>
                        <p id="assigned-staff-note" class="mt-2 text-xs text-slate-500"></p>
                    </div>
                    <div class="mt-4">
                        <label class="block text-xs font-semibold uppercase tracking-widest text-slate-400">Manual status update</label>
                        <div class="mt-2 flex flex-wrap items-center gap-3">
                            <select id="order-status-select" class="h-10 min-w-[180px] flex-1 rounded-xl border border-slate-200 bg-white px-3 text-sm text-slate-700 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-200">
                            </select>
                            <button type="button" id="order-status-save" class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-xs font-semibold text-white shadow-sm hover:bg-primary-700 disabled:cursor-not-allowed disabled:bg-slate-300 dark:disabled:bg-slate-700">Save</button>
                        </div>
                        <label class="mt-3 flex items-center gap-2 text-xs font-semibold uppercase tracking-widest text-slate-400">
                            <input id="order-status-override" type="checkbox" class="rounded border-slate-300 text-primary-600 focus:ring-primary-500" />
                            Admin override
                        </label>
                        <p id="order-status-note" class="mt-2 text-xs text-slate-500"></p>
                    </div>
                </div>
            </div>

            <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <h3 class="text-sm font-semibold text-slate-900 dark:text-white">Tracking History</h3>
                <div id="tracking-history" class="mt-4 space-y-3 text-sm text-slate-600 dark:text-slate-300">
                    <p class="text-sm text-slate-500">Loading tracking history...</p>
                </div>
            </div>

            <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <h3 class="text-sm font-semibold text-slate-900 dark:text-white">Delivery</h3>
                <div class="mt-4 space-y-3 text-sm text-slate-600 dark:text-slate-300">
                    <div class="flex items-center justify-between gap-3">
                        <span>Address</span>
                        <span class="max-w-[220px] text-right font-semibold text-slate-900 dark:text-white" id="delivery-address">--</span>
                    </div>
                    <div class="flex items-center justify-between gap-3">
                        <span>Phone</span>
                        <span class="font-semibold text-slate-900 dark:text-white" id="delivery-phone">--</span>
                    </div>
                    <div class="flex items-start justify-between gap-3">
                        <span class="pt-0.5">Note</span>
                        <span class="max-w-[220px] text-right font-semibold text-slate-900 dark:text-white" id="delivery-note">--</span>
                    </div>
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
            var orderStatusSelect = document.getElementById('order-status-select');
            var orderStatusSave = document.getElementById('order-status-save');
            var orderStatusNote = document.getElementById('order-status-note');
            var orderStatusOverride = document.getElementById('order-status-override');
            var orderApprove = document.getElementById('order-approve');
            var orderReject = document.getElementById('order-reject');
            var orderActionNote = document.getElementById('order-action-note');
            var assignedStaffName = document.getElementById('assigned-staff-name');
            var assignedStaffSelect = document.getElementById('assigned-staff-select');
            var assignedStaffSave = document.getElementById('assigned-staff-save');
            var assignedStaffNote = document.getElementById('assigned-staff-note');
            var trackingHistory = document.getElementById('tracking-history');
            var staffOptions = [];
            var readErrorMessage = async function (response, fallback) {
                var defaultMessage = fallback || 'Request failed.';
                if (!response) {
                    return defaultMessage;
                }

                try {
                    var payload = await response.clone().json();
                    if (payload && payload.errors) {
                        var firstField = Object.keys(payload.errors)[0];
                        if (firstField && Array.isArray(payload.errors[firstField]) && payload.errors[firstField].length) {
                            return payload.errors[firstField][0];
                        }
                    }
                    if (payload && payload.message) {
                        return payload.message;
                    }
                } catch (error) {
                    // Ignore non-JSON responses and fall back to the default message.
                }

                return defaultMessage;
            };
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
            var formatStatusLabel = function (status) {
                if (!status) {
                    return '--';
                }

                var normalized = String(status).toLowerCase();
                var labels = {
                    created: 'Created',
                    pending_approval: 'Pending Approval',
                    approved: 'Approved',
                    assigned: 'Assigned',
                    in_progress: 'In Progress',
                    on_the_way: 'On the Way',
                    arrived: 'Arrived',
                    pending: 'Pending',
                    pending_confirmation: 'Pending',
                    processing: 'Ready',
                    ready: 'Ready',
                    out_for_delivery: 'Out for Delivery',
                    delivered: 'Delivered',
                    completed: 'Completed',
                    cancelled: 'Cancelled',
                    rejected: 'Rejected'
                };

                if (labels[normalized]) {
                    return labels[normalized];
                }

                return normalized
                    .split('_')
                    .map(function (part) {
                        return part.charAt(0).toUpperCase() + part.slice(1);
                    })
                    .join(' ');
            };
            var normalizeOrderStatus = function (status, orderType) {
                if (!status) {
                    return 'pending';
                }

                var normalized = String(status).toLowerCase();
                if (orderType === 'delivery' && [
                    'created',
                    'pending_approval',
                    'approved',
                    'assigned',
                    'in_progress',
                    'on_the_way',
                    'arrived',
                    'completed',
                    'cancelled',
                    'rejected'
                ].indexOf(normalized) !== -1) {
                    return normalized;
                }
                if (normalized === 'pending_confirmation') {
                    return 'pending';
                }
                if (normalized === 'processing' || normalized === 'approved') {
                    return orderType === 'delivery' ? 'ready' : 'ready';
                }
                return normalized;
            };
            var getOrderStatusOptions = function (orderType) {
                if (orderType === 'delivery') {
                    return [
                        { value: 'pending', label: 'Pending' },
                        { value: 'ready', label: 'Ready' },
                        { value: 'out_for_delivery', label: 'Out for Delivery' },
                        { value: 'delivered', label: 'Delivered' },
                        { value: 'completed', label: 'Completed' },
                        { value: 'cancelled', label: 'Cancelled' }
                    ];
                }

                return [
                    { value: 'pending', label: 'Pending' },
                    { value: 'ready', label: 'Ready' },
                    { value: 'completed', label: 'Completed' },
                    { value: 'cancelled', label: 'Cancelled' }
                ];
            };
            var currentPaymentStatus = 'pending';
            var currentOrderStatus = 'pending';
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

            function setOrderBadge(status) {
                var badge = document.getElementById('order-status');
                if (!badge) {
                    return;
                }

                badge.textContent = formatStatusLabel(status);
                badge.className = 'rounded-full px-3 py-1 text-xs font-semibold ' + (
                    status === 'completed' || status === 'delivered'
                        ? 'bg-success-50 text-success-700 dark:bg-success-500/10 dark:text-success-100'
                        : status === 'out_for_delivery'
                            ? 'bg-primary-50 text-primary-700 dark:bg-primary-500/10 dark:text-primary-100'
                            : status === 'cancelled'
                                ? 'bg-danger-50 text-danger-700 dark:bg-danger-500/10 dark:text-danger-100'
                                : 'bg-warning-50 text-warning-700 dark:bg-warning-500/10 dark:text-warning-100'
                );
            }

            function renderOrderStatusOptions(order) {
                var orderType = (order.order_type || 'pickup').toLowerCase();
                var options = [];

                if (orderType === 'delivery' && Array.isArray(order.tracking_status_options)) {
                    options = order.tracking_status_options.map(function (option) {
                        return {
                            value: option.value,
                            label: option.label || formatStatusLabel(option.value)
                        };
                    });
                } else {
                    options = getOrderStatusOptions(orderType);
                }

                if (orderType === 'delivery' && !order.assigned_staff_id) {
                    options = options.filter(function (option) {
                        return option.value !== 'assigned';
                    });
                }

                orderStatusSelect.innerHTML = options.map(function (option) {
                    return '<option value="' + option.value + '">' + option.label + '</option>';
                }).join('');

                if (options.some(function (option) { return option.value === currentOrderStatus; })) {
                    orderStatusSelect.value = currentOrderStatus;
                } else if (options.length) {
                    orderStatusSelect.value = options[0].value;
                }
                orderStatusSave.disabled = true;
                if (orderType === 'delivery') {
                    orderStatusNote.textContent = order.assigned_staff_id
                        ? 'Follow the delivery workflow or use admin override when needed.'
                        : 'Assign staff first before moving this order to Assigned.';
                } else {
                    orderStatusNote.textContent = 'Update the pickup order progress here.';
                }
            }

            function renderStaffOptions(selectedId) {
                assignedStaffSelect.innerHTML = '<option value="">Select staff</option>' + staffOptions.map(function (staff) {
                    var selected = Number(selectedId) === Number(staff.id) ? ' selected' : '';
                    return '<option value="' + staff.id + '"' + selected + '>' + staff.name + ' (' + (staff.role || 'staff') + ')</option>';
                }).join('');
                assignedStaffSave.disabled = !currentOrder || (currentOrder.order_type || '').toLowerCase() !== 'delivery';
            }

            function renderTrackingHistory(order) {
                var history = Array.isArray(order.tracking_history) ? order.tracking_history : [];
                if (!history.length) {
                    trackingHistory.innerHTML = '<p class="text-sm text-slate-500">No tracking updates yet.</p>';
                    return;
                }

                trackingHistory.innerHTML = history.slice().reverse().map(function (entry) {
                    var meta = [];
                    if (entry.changed_by_name) {
                        meta.push(entry.changed_by_name);
                    }
                    if (entry.changed_by_role) {
                        meta.push(entry.changed_by_role);
                    }
                    if (entry.assigned_staff_name) {
                        meta.push('Staff: ' + entry.assigned_staff_name);
                    }

                    return `
                        <div class="rounded-2xl border border-slate-200 bg-slate-50 p-4 shadow-sm dark:border-slate-800 dark:bg-slate-950/40">
                            <div class="flex flex-wrap items-center justify-between gap-2">
                                <p class="font-semibold text-slate-900 dark:text-white">${formatStatusLabel(entry.to_status)}</p>
                                <span class="text-xs text-slate-500">${entry.created_at ? new Date(entry.created_at).toLocaleString() : '--'}</span>
                            </div>
                            ${meta.length ? `<p class="mt-2 text-xs text-slate-500">${meta.join(' • ')}</p>` : ''}
                            ${entry.note ? `<p class="mt-2 text-sm text-slate-600 dark:text-slate-300">${entry.note}</p>` : ''}
                            ${entry.override_used ? '<span class="mt-2 inline-flex rounded-full bg-warning-50 px-2 py-1 text-[11px] font-semibold text-warning-700 dark:bg-warning-500/10 dark:text-warning-100">Override</span>' : ''}
                        </div>
                    `;
                }).join('');
            }

            function renderOrder(order) {
                currentOrder = order;
                currentPaymentStatus = normalizePaymentStatus(order.payment_status);
                currentOrderStatus = normalizeOrderStatus(order.status, (order.order_type || 'pickup').toLowerCase());

                document.getElementById('order-number').textContent = order.order_number || 'Order';
                document.getElementById('order-customer').textContent = order.customer_name || '--';
                document.getElementById('order-meta').textContent = order.placed_at ? new Date(order.placed_at).toLocaleString() : '--';
                setOrderBadge(currentOrderStatus);
                document.getElementById('customer-name').textContent = order.customer_name || '--';
                document.getElementById('customer-email').textContent = order.customer_email || '--';
                document.getElementById('order-type').textContent = order.order_type ? order.order_type.toUpperCase() : '--';
                document.getElementById('order-status-current').textContent = formatStatusLabel(currentOrderStatus);
                assignedStaffName.textContent = order.assigned_staff_name || '--';
                document.getElementById('delivery-address').textContent = order.delivery_address || (order.order_type === 'pickup' ? 'Pickup order' : '--');
                document.getElementById('delivery-phone').textContent = order.delivery_phone || '--';
                document.getElementById('delivery-note').textContent = order.delivery_note || '--';
                document.getElementById('order-total').textContent = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(order.total_amount || 0);
                setPaymentBadge(currentPaymentStatus);
                renderOrderStatusOptions(order);
                renderStaffOptions(order.assigned_staff_id);
                renderTrackingHistory(order);
                paymentStatusSelect.value = currentPaymentStatus;
                paymentStatusSave.disabled = true;
                paymentStatusNote.textContent = '';
                assignedStaffNote.textContent = '';

                var isDelivery = (order.order_type || '').toLowerCase() === 'delivery';
                var canApprove = isDelivery && currentOrderStatus === 'pending_approval';
                var canReject = isDelivery && ['pending_approval', 'approved', 'assigned'].indexOf(currentOrderStatus) !== -1;
                orderApprove.disabled = !canApprove;
                orderReject.disabled = !canReject;
                orderActionNote.placeholder = currentOrderStatus === 'pending_approval'
                    ? 'Reason or admin note'
                    : 'Optional admin note';

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

            async function loadStaffOptions() {
                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/admin/staff-options');
                if (!response.ok) {
                    staffOptions = [];
                    renderStaffOptions(null);
                    return;
                }
                var data = await response.json();
                staffOptions = Array.isArray(data.data) ? data.data : [];
                renderStaffOptions(currentOrder ? currentOrder.assigned_staff_id : null);
            }

            await loadStaffOptions();
            await loadOrder();

            paymentStatusSelect.addEventListener('change', function (event) {
                var newStatus = event.target.value;
                paymentStatusSave.disabled = newStatus === currentPaymentStatus;
                paymentStatusNote.textContent = newStatus === currentPaymentStatus ? '' : 'Unsaved changes';
            });

            orderStatusSelect.addEventListener('change', function (event) {
                var newStatus = event.target.value;
                orderStatusSave.disabled = newStatus === currentOrderStatus;
                orderStatusNote.textContent = newStatus === currentOrderStatus ? '' : 'Unsaved changes';
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

            orderStatusSave.addEventListener('click', async function () {
                var newStatus = orderStatusSelect.value;
                var previousStatus = currentOrderStatus;
                if (newStatus === previousStatus) {
                    return;
                }

                var isDelivery = currentOrder && (currentOrder.order_type || '').toLowerCase() === 'delivery';
                if (isDelivery && newStatus === 'assigned' && !currentOrder.assigned_staff_id) {
                    orderStatusSave.disabled = false;
                    orderStatusNote.textContent = 'Select a staff member and use Assign before setting Assigned.';
                    return;
                }

                try {
                    orderStatusSave.disabled = true;
                    orderStatusNote.textContent = 'Saving...';
                    await window.adminApi.ensureCsrfCookie();
                    var updateResponse = await window.adminApi.request(isDelivery ? '/api/admin/orders/' + orderId + '/tracking-status' : '/api/orders/' + orderId, {
                        method: isDelivery ? 'POST' : 'PATCH',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify(isDelivery ? {
                            status: newStatus,
                            note: orderActionNote.value || null,
                            override: !!orderStatusOverride.checked
                        } : { status: newStatus })
                    });

                    if (!updateResponse.ok) {
                        orderStatusSelect.value = previousStatus;
                        orderStatusSave.disabled = false;
                        orderStatusNote.textContent = await readErrorMessage(updateResponse, 'Save failed.');
                        return;
                    }

                    await loadOrder();
                    orderStatusNote.textContent = 'Saved.';
                } catch (error) {
                    orderStatusSelect.value = previousStatus;
                    orderStatusSave.disabled = false;
                    orderStatusNote.textContent = 'Save failed.';
                    console.error(error);
                }
            });

            assignedStaffSave.addEventListener('click', async function () {
                var staffId = assignedStaffSelect.value;
                if (!staffId) {
                    assignedStaffNote.textContent = 'Select a staff member first.';
                    return;
                }

                try {
                    assignedStaffSave.disabled = true;
                    assignedStaffNote.textContent = 'Assigning...';
                    await window.adminApi.ensureCsrfCookie();
                    var response = await window.adminApi.request('/api/admin/orders/' + orderId + '/assign', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({
                            staff_user_id: Number(staffId),
                            note: orderActionNote.value || null,
                            override: !!orderStatusOverride.checked
                        })
                    });

                    if (!response.ok) {
                        assignedStaffSave.disabled = false;
                        assignedStaffNote.textContent = await readErrorMessage(response, 'Assignment failed.');
                        return;
                    }

                    await loadOrder();
                    assignedStaffNote.textContent = 'Assigned.';
                } catch (error) {
                    assignedStaffSave.disabled = false;
                    assignedStaffNote.textContent = 'Assignment failed.';
                    console.error(error);
                }
            });

            orderApprove.addEventListener('click', async function () {
                try {
                    orderApprove.disabled = true;
                    orderStatusNote.textContent = 'Approving...';
                    await window.adminApi.ensureCsrfCookie();
                    var response = await window.adminApi.request('/api/admin/orders/' + orderId + '/approve', {
                        method: 'POST'
                    });
                    if (!response.ok) {
                        orderApprove.disabled = false;
                        orderStatusNote.textContent = await readErrorMessage(response, 'Approve failed.');
                        return;
                    }
                    await loadOrder();
                    orderStatusNote.textContent = 'Approved.';
                } catch (error) {
                    orderApprove.disabled = false;
                    orderStatusNote.textContent = 'Approve failed.';
                    console.error(error);
                }
            });

            orderReject.addEventListener('click', async function () {
                if (!orderActionNote.value.trim()) {
                    orderStatusNote.textContent = 'Add a reason before rejecting.';
                    return;
                }

                try {
                    orderReject.disabled = true;
                    orderStatusNote.textContent = 'Rejecting...';
                    await window.adminApi.ensureCsrfCookie();
                    var response = await window.adminApi.request('/api/admin/orders/' + orderId + '/reject', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ reason: orderActionNote.value.trim() })
                    });
                    if (!response.ok) {
                        orderReject.disabled = false;
                        orderStatusNote.textContent = await readErrorMessage(response, 'Reject failed.');
                        return;
                    }
                    await loadOrder();
                    orderStatusNote.textContent = 'Rejected.';
                } catch (error) {
                    orderReject.disabled = false;
                    orderStatusNote.textContent = 'Reject failed.';
                    console.error(error);
                }
            });
        });
    </script>
@endsection
