@extends('layouts.admin')

@section('title', 'Orders')
@section('page-title', 'Orders')

@section('content')
    <div class="space-y-6">
        <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <div class="flex flex-wrap items-center justify-between gap-3">
                <div>
                    <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Order Counts by Shift</h2>
                    <p class="text-sm text-slate-500">Track order volume and totals for the current filters.</p>
                </div>
                <span class="text-xs font-semibold uppercase tracking-widest text-slate-400">Live</span>
            </div>
            <div class="mt-4 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
                <div class="rounded-2xl border border-slate-200 bg-slate-50 p-4 shadow-sm dark:border-slate-800 dark:bg-slate-950/40">
                    <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Morning Shift</p>
                    <p id="shift-morning-count" class="mt-3 text-2xl font-semibold text-slate-900 dark:text-white">--</p>
                    <p class="mt-2 text-xs text-slate-500">Amount <span id="shift-morning-amount" class="font-semibold text-slate-700 dark:text-slate-200">--</span></p>
                    <p class="mt-1 text-xs text-slate-400">06:00-11:59</p>
                </div>
                <div class="rounded-2xl border border-slate-200 bg-slate-50 p-4 shadow-sm dark:border-slate-800 dark:bg-slate-950/40">
                    <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Afternoon Shift</p>
                    <p id="shift-afternoon-count" class="mt-3 text-2xl font-semibold text-slate-900 dark:text-white">--</p>
                    <p class="mt-2 text-xs text-slate-500">Amount <span id="shift-afternoon-amount" class="font-semibold text-slate-700 dark:text-slate-200">--</span></p>
                    <p class="mt-1 text-xs text-slate-400">12:00-17:59</p>
                </div>
                <div class="rounded-2xl border border-slate-200 bg-slate-50 p-4 shadow-sm dark:border-slate-800 dark:bg-slate-950/40">
                    <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Evening Shift</p>
                    <p id="shift-evening-count" class="mt-3 text-2xl font-semibold text-slate-900 dark:text-white">--</p>
                    <p class="mt-2 text-xs text-slate-500">Amount <span id="shift-evening-amount" class="font-semibold text-slate-700 dark:text-slate-200">--</span></p>
                    <p class="mt-1 text-xs text-slate-400">18:00-21:59</p>
                </div>
                <div class="rounded-2xl border border-slate-200 bg-slate-50 p-4 shadow-sm dark:border-slate-800 dark:bg-slate-950/40">
                    <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Night Shift</p>
                    <p id="shift-night-count" class="mt-3 text-2xl font-semibold text-slate-900 dark:text-white">--</p>
                    <p class="mt-2 text-xs text-slate-500">Amount <span id="shift-night-amount" class="font-semibold text-slate-700 dark:text-slate-200">--</span></p>
                    <p class="mt-1 text-xs text-slate-400">22:00-05:59</p>
                </div>
            </div>
        </div>


        <div class="flex flex-wrap items-center justify-between gap-4">
            <div>
                <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Order List</h2>
                <p class="text-sm text-slate-500">Monitor fulfillment, payment status, and delivery progress.</p>
            </div>
            <div class="flex items-center gap-3">
                <button id="order-export" class="inline-flex h-10 items-center rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-600 shadow-sm dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300">Export CSV</button>
            </div>
        </div>

        <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <div class="flex flex-wrap items-center justify-between gap-3">
                <div class="flex flex-wrap items-center gap-3">
                    <select id="order-status-filter" class="h-10 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300">
                        <option>All statuses</option>
                        <option>Created</option>
                        <option>Pending Approval</option>
                        <option>Approved</option>
                        <option>Assigned</option>
                        <option>In Progress</option>
                        <option>On The Way</option>
                        <option>Arrived</option>
                        <option>Processing</option>
                        <option>Completed</option>
                        <option>Cancelled</option>
                        <option>Rejected</option>
                    </select>
                    <select id="order-type-filter" class="h-10 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300">
                        <option>All types</option>
                        <option value="pickup">Pickup</option>
                        <option value="delivery">Delivery</option>
                    </select>
                    <select id="order-payment-filter" class="h-10 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300">
                        <option>Payment</option>
                        <option>Paid</option>
                        <option>Unpaid</option>
                        <option>Refunded</option>
                    </select>
                    <input id="order-from-date" type="date" class="h-10 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300" />
                    <input id="order-to-date" type="date" class="h-10 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300" />
                </div>
                <div class="relative">
                    <input id="order-search" type="text" placeholder="Search orders" class="h-10 w-60 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    <svg class="absolute right-3 top-3 h-4 w-4 text-slate-400" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-4.35-4.35m1.6-5.15a7 7 0 11-14 0 7 7 0 0114 0z" />
                    </svg>
                </div>
            </div>

            <div class="mt-5 overflow-x-auto">
                <table class="w-full text-left text-sm">
                    <thead class="text-xs uppercase tracking-widest text-slate-400">
                        <tr>
                            <th class="px-4 py-3">
                                <button class="inline-flex items-center gap-1 text-xs font-semibold uppercase tracking-widest text-slate-400">
                                    Order ID
                                    <svg class="h-3 w-3" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M8 9l4-4 4 4M16 15l-4 4-4-4" />
                                    </svg>
                                </button>
                            </th>
                            <th class="px-4 py-3">Customer</th>
                            <th class="px-4 py-3">
                                <button class="inline-flex items-center gap-1 text-xs font-semibold uppercase tracking-widest text-slate-400">
                                    Date
                                    <svg class="h-3 w-3" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M8 9l4-4 4 4M16 15l-4 4-4-4" />
                                    </svg>
                                </button>
                            </th>
                            <th class="px-4 py-3">
                                <button class="inline-flex items-center gap-1 text-xs font-semibold uppercase tracking-widest text-slate-400">
                                    Total
                                    <svg class="h-3 w-3" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M8 9l4-4 4 4M16 15l-4 4-4-4" />
                                    </svg>
                                </button>
                            </th>
                            <th class="px-4 py-3">Payment</th>
                            <th class="px-4 py-3">Status</th>
                            <th class="px-4 py-3 text-right">Action</th>
                        </tr>
                    </thead>
                    <tbody id="order-rows" class="divide-y divide-slate-200 text-slate-600 dark:divide-slate-800 dark:text-slate-300"></tbody>
                </table>
            </div>

            <div class="mt-4 flex items-center justify-between text-xs text-slate-500">
                <p id="order-pagination-info">Loading orders...</p>
                <div class="flex items-center gap-2">
                    <button id="order-prev" class="rounded-lg border border-slate-200 px-3 py-1 text-slate-600 dark:border-slate-800 dark:text-slate-300">Previous</button>
                    <button id="order-next" class="rounded-lg border border-slate-200 bg-slate-100 px-3 py-1 text-slate-900 dark:border-slate-800 dark:bg-slate-900">Next</button>
                </div>
            </div>
        </div>
    </div>


    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var currentPage = 1;
            var searchInput = document.getElementById('order-search');
            var statusFilter = document.getElementById('order-status-filter');
            var orderTypeFilter = document.getElementById('order-type-filter');
            var paymentFilter = document.getElementById('order-payment-filter');
            var orderFromDate = document.getElementById('order-from-date');
            var orderToDate = document.getElementById('order-to-date');
            var prevButton = document.getElementById('order-prev');
            var nextButton = document.getElementById('order-next');
            var info = document.getElementById('order-pagination-info');
            var rows = document.getElementById('order-rows');
            var exportButton = document.getElementById('order-export');
            var currencyFormatter = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' });
            var latestOrders = [];
            var hasServerSummary = false;
            var shiftCards = {
                morning: {
                    count: document.getElementById('shift-morning-count'),
                    amount: document.getElementById('shift-morning-amount')
                },
                afternoon: {
                    count: document.getElementById('shift-afternoon-count'),
                    amount: document.getElementById('shift-afternoon-amount')
                },
                evening: {
                    count: document.getElementById('shift-evening-count'),
                    amount: document.getElementById('shift-evening-amount')
                },
                night: {
                    count: document.getElementById('shift-night-count'),
                    amount: document.getElementById('shift-night-amount')
                }
            };


            function mapStatus(value) {
                return (value || '').toLowerCase().replace(/\s+/g, '_');
            }

            function formatStatusLabel(status) {
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
                    completed: 'Completed',
                    cancelled: 'Cancelled',
                    rejected: 'Rejected',
                    processing: 'Processing',
                    pending: 'Pending',
                    ready: 'Ready',
                    out_for_delivery: 'Out for Delivery',
                    delivered: 'Delivered'
                };

                return labels[normalized] || normalized.split('_').map(function (part) {
                    return part.charAt(0).toUpperCase() + part.slice(1);
                }).join(' ');
            }

            function buildOrderQuery() {
                var query = new URLSearchParams();
                if (searchInput.value.trim()) {
                    query.set('q', searchInput.value.trim());
                }
                if (mapStatus(statusFilter.value) && mapStatus(statusFilter.value) !== 'all statuses') {
                    query.set('status', mapStatus(statusFilter.value));
                }
                if (mapStatus(paymentFilter.value) && mapStatus(paymentFilter.value) !== 'payment') {
                    query.set('payment_status', mapStatus(paymentFilter.value));
                }
                if (orderTypeFilter && orderTypeFilter.value && orderTypeFilter.value !== 'All types') {
                    query.set('order_type', orderTypeFilter.value);
                }
                if (orderFromDate && orderFromDate.value) {
                    query.set('from_date', orderFromDate.value);
                }
                if (orderToDate && orderToDate.value) {
                    query.set('to_date', orderToDate.value);
                }
                return query;
            }

            function getShiftKeyFromDate(date) {
                if (!date || Number.isNaN(date.getTime())) {
                    return null;
                }
                var hour = date.getHours();
                if (hour >= 6 && hour < 12) {
                    return 'morning';
                }
                if (hour >= 12 && hour < 18) {
                    return 'afternoon';
                }
                if (hour >= 18 && hour < 22) {
                    return 'evening';
                }
                return 'night';
            }

            function buildShiftSummaryFromList(list) {
                var summary = {
                    morning: { count: 0, amount: 0 },
                    afternoon: { count: 0, amount: 0 },
                    evening: { count: 0, amount: 0 },
                    night: { count: 0, amount: 0 }
                };

                list.forEach(function (order) {
                    var timestamp = order.placed_at || order.created_at;
                    if (!timestamp) {
                        return;
                    }
                    var date = new Date(timestamp);
                    var shiftKey = getShiftKeyFromDate(date);
                    if (!shiftKey) {
                        return;
                    }
                    summary[shiftKey].count += 1;
                    summary[shiftKey].amount += Number(order.total_amount || 0);
                });

                return summary;
            }

            function setShiftSummaryPlaceholder(value) {
                Object.keys(shiftCards).forEach(function (key) {
                    if (!shiftCards[key]) {
                        return;
                    }
                    shiftCards[key].count.textContent = value;
                    shiftCards[key].amount.textContent = value;
                });
            }

            function normalizeTicketStatus(order) {
                if (!order) {
                    return 'invalid';
                }
                return (order.pickup_ticket_status || (order.pickup_verified_at ? 'used' : 'active') || 'active').toLowerCase();
            }

            function setPickupStatusBadge(status) {
                if (!pickupTicketStatus) {
                    return;
                }
                var label = status ? status.toUpperCase() : '--';
                pickupTicketStatus.textContent = label;
                var base = 'rounded-full px-3 py-1 text-xs font-semibold ';
                if (status === 'active') {
                    pickupTicketStatus.className = base + 'bg-primary-50 text-primary-700 dark:bg-primary-500/10 dark:text-primary-100';
                } else if (status === 'used' || status === 'completed') {
                    pickupTicketStatus.className = base + 'bg-success-50 text-success-700 dark:bg-success-500/10 dark:text-success-100';
                } else if (status === 'expired') {
                    pickupTicketStatus.className = base + 'bg-danger-50 text-danger-700 dark:bg-danger-500/10 dark:text-danger-100';
                } else {
                    pickupTicketStatus.className = base + 'bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-200';
                }
            }

            function renderPickupOrder(order, note) {
                if (!order) {
                    pickupOrderTitle.textContent = note || 'No order selected.';
                    pickupOrderCustomer.textContent = '--';
                    pickupOrderPayment.textContent = '--';
                    pickupOrderStatus.textContent = '--';
                    pickupOrderVerified.textContent = '--';
                    pickupOrderVerifiedBy.textContent = '--';
                    setPickupStatusBadge('--');
                    return;
                }

                var orderLabel = order.order_number || ('Order #' + order.id);
                pickupOrderTitle.textContent = orderLabel;
                pickupOrderCustomer.textContent = order.customer_name || '--';
                pickupOrderPayment.textContent = order.payment_status || '--';
                pickupOrderStatus.textContent = order.status || '--';
                pickupOrderVerified.textContent = order.pickup_verified_at ? new Date(order.pickup_verified_at).toLocaleString() : 'Not verified';
                pickupOrderVerifiedBy.textContent = order.pickup_verified_by_name || '--';
                setPickupStatusBadge(normalizeTicketStatus(order));
            }

            async function verifyPickupToken() {
                var token = pickupQrInput.value.trim();
                if (!token) {
                    pickupQrStatus.textContent = 'Please scan or paste a QR token.';
                    return;
                }
                pickupQrStatus.textContent = 'Verifying ticket...';
                pickupQrVerify.disabled = true;
                try {
                    await window.adminApi.ensureCsrfCookie();
                    var response = await window.adminApi.request('/api/admin/orders/verify-qr', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ token: token })
                    });
                    var payload = await response.json();
                    if (!response.ok) {
                        pickupQrStatus.textContent = payload && payload.message ? payload.message : 'Invalid ticket.';
                        renderPickupOrder(null, pickupQrStatus.textContent);
                        return;
                    }
                    var order = payload.data || payload;
                    pickupQrStatus.textContent = 'Ticket verified and marked completed.';
                    renderPickupOrder(order);
                    refreshListAndSummary();
                } catch (error) {
                    pickupQrStatus.textContent = 'Verification failed.';
                    renderPickupOrder(null, pickupQrStatus.textContent);
                    console.error(error);
                } finally {
                    pickupQrVerify.disabled = false;
                }
            }

            function scheduleAutoVerifyToken() {
                if (!pickupQrInput) {
                    return;
                }
                var token = pickupQrInput.value.trim();
                if (!token || token === pickupQrLastToken) {
                    return;
                }
                if (pickupQrAutoTimer) {
                    clearTimeout(pickupQrAutoTimer);
                }
                pickupQrAutoTimer = setTimeout(function () {
                    pickupQrLastToken = token;
                    verifyPickupToken();
                }, 400);
            }

            async function verifyPickupTicketId() {
                var ticketId = pickupTicketIdInput.value.trim();
                if (!ticketId) {
                    pickupQrStatus.textContent = 'Please enter a ticket ID.';
                    return;
                }
                pickupQrStatus.textContent = 'Verifying ticket...';
                pickupTicketIdVerify.disabled = true;
                try {
                    await window.adminApi.ensureCsrfCookie();
                    var response = await window.adminApi.request('/api/admin/orders/verify-qr', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ ticket_id: ticketId })
                    });
                    var payload = await response.json();
                    if (!response.ok) {
                        pickupQrStatus.textContent = payload && payload.message ? payload.message : 'Invalid ticket.';
                        renderPickupOrder(null, pickupQrStatus.textContent);
                        return;
                    }
                    var order = payload.data || payload;
                    pickupQrStatus.textContent = 'Ticket verified and marked completed.';
                    renderPickupOrder(order);
                    refreshListAndSummary();
                } catch (error) {
                    pickupQrStatus.textContent = 'Verification failed.';
                    renderPickupOrder(null, pickupQrStatus.textContent);
                    console.error(error);
                } finally {
                    pickupTicketIdVerify.disabled = false;
                }
            }

            function scheduleAutoVerifyTicketId() {
                if (!pickupTicketIdInput) {
                    return;
                }
                var ticketId = pickupTicketIdInput.value.trim();
                if (!ticketId || ticketId === pickupTicketLastId) {
                    return;
                }
                if (pickupTicketAutoTimer) {
                    clearTimeout(pickupTicketAutoTimer);
                }
                pickupTicketAutoTimer = setTimeout(function () {
                    pickupTicketLastId = ticketId;
                    verifyPickupTicketId();
                }, 400);
            }

            async function startPickupQrCamera() {
                if (!pickupQrReader) {
                    return;
                }
                if (!window.Html5Qrcode) {
                    pickupQrStatus.textContent = 'QR scanner library not available.';
                    return;
                }
                if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
                    pickupQrStatus.textContent = 'Camera not supported on this device.';
                    return;
                }
                try {
                    pickupQrScanner = pickupQrScanner || new Html5Qrcode('pickup-qr-reader');
                    var cameras = await Html5Qrcode.getCameras();
                    if (!cameras || cameras.length === 0) {
                        pickupQrStatus.textContent = 'No camera found.';
                        return;
                    }
                    pickupQrCameras = cameras;
                    renderCameraOptions();
                    pickupQrStatus.textContent = 'Camera ready. Scan the QR code.';
                    pickupQrCameraWrap.classList.remove('hidden');
                    pickupQrCameraButton.textContent = 'Stop Camera';
                    pickupQrActive = true;

                    var cameraId = getSelectedCameraId() || cameras[cameras.length - 1].id;
                    await pickupQrScanner.start(
                        { deviceId: { exact: cameraId } },
                        { fps: 10, qrbox: 280 },
                        function (decodedText) {
                            pickupQrInput.value = decodedText;
                            pickupQrStatus.textContent = 'QR scanned. Verifying...';
                            stopPickupQrCamera();
                            verifyPickupToken();
                        }
                    );
                } catch (error) {
                    pickupQrStatus.textContent = 'Unable to access camera.';
                    console.error(error);
                }
            }

            function getSelectedCameraId() {
                if (!pickupQrCameraSelect) {
                    return null;
                }
                var value = pickupQrCameraSelect.value;
                return value ? value : null;
            }

            function findCamoCameraId() {
                if (!pickupQrCameras || !pickupQrCameras.length) {
                    return null;
                }
                var camo = pickupQrCameras.find(function (camera) {
                    return (camera.label || '').toLowerCase().includes('camo');
                });
                return camo ? camo.id : null;
            }

            function renderCameraOptions() {
                if (!pickupQrCameraSelect) {
                    return;
                }
                var current = pickupQrCameraSelect.value;
                pickupQrCameraSelect.innerHTML = '<option value=\"\">Select camera</option>';
                pickupQrCameras.forEach(function (camera) {
                    var option = document.createElement('option');
                    option.value = camera.id;
                    option.textContent = camera.label || ('Camera ' + camera.id);
                    pickupQrCameraSelect.appendChild(option);
                });
                if (pickupQrCameras.length <= 1) {
                    pickupQrCameraSelect.classList.add('hidden');
                    pickupQrCameraRefresh.classList.add('hidden');
                    if (pickupQrCameraSingle) {
                        pickupQrCameraSingle.classList.remove('hidden');
                        pickupQrCameraSingle.textContent = pickupQrCameras.length
                            ? (pickupQrCameras[0].label || 'Camera ready')
                            : 'No camera found';
                    }
                } else {
                    pickupQrCameraSelect.classList.remove('hidden');
                    pickupQrCameraRefresh.classList.remove('hidden');
                    if (pickupQrCameraSingle) {
                        pickupQrCameraSingle.classList.add('hidden');
                    }
                }
                var camoId = findCamoCameraId();
                if (camoId) {
                    pickupQrCameraSelect.value = camoId;
                } else if (current && pickupQrCameras.some(function (camera) { return camera.id === current; })) {
                    pickupQrCameraSelect.value = current;
                } else if (pickupQrCameras.length) {
                    pickupQrCameraSelect.value = pickupQrCameras[pickupQrCameras.length - 1].id;
                }
            }

            function stopPickupQrCamera() {
                if (!pickupQrScanner) {
                    pickupQrCameraWrap.classList.add('hidden');
                    pickupQrCameraButton.textContent = 'Open Camera';
                    pickupQrActive = false;
                    return;
                }
                pickupQrScanner.stop().then(function () {
                    pickupQrScanner.clear();
                    pickupQrCameraWrap.classList.add('hidden');
                    pickupQrCameraButton.textContent = 'Open Camera';
                    pickupQrActive = false;
                }).catch(function (error) {
                    pickupQrCameraWrap.classList.add('hidden');
                    pickupQrCameraButton.textContent = 'Open Camera';
                    pickupQrActive = false;
                    console.error(error);
                });
            }

            async function searchPickupOrder() {
                var value = pickupOrderSearchInput.value.trim();
                if (!value) {
                    renderPickupOrder(null, 'Enter an order id or number to search.');
                    return;
                }
                try {
                    await window.adminApi.ensureCsrfCookie();
                    var response;
                    if (/^\\d+$/.test(value)) {
                        response = await window.adminApi.request('/api/orders/' + value);
                    } else {
                        response = await window.adminApi.request('/api/orders?q=' + encodeURIComponent(value));
                    }
                    if (!response.ok) {
                        renderPickupOrder(null, 'Order not found.');
                        return;
                    }
                    var payload = await response.json();
                    var order = payload.data || payload;
                    if (Array.isArray(order)) {
                        order = order.length ? order[0] : null;
                    } else if (payload.data && Array.isArray(payload.data)) {
                        order = payload.data.length ? payload.data[0] : null;
                    }
                    if (!order) {
                        renderPickupOrder(null, 'Order not found.');
                        return;
                    }
                    renderPickupOrder(order);
                } catch (error) {
                    renderPickupOrder(null, 'Unable to fetch order.');
                    console.error(error);
                }
            }

            async function loadOrders() {
                await window.adminApi.ensureCsrfCookie();
                var query = buildOrderQuery();
                query.set('page', currentPage);

                var response = await window.adminApi.request('/api/orders?' + query.toString());
                if (!response.ok) {
                    rows.innerHTML = '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="7">Unable to load orders.</td></tr>';
                    return;
                }
                var data = await response.json();
                var list = data.data || [];

                rows.innerHTML = list.map(function (order) {
                    return `
                        <tr>
                            <td class="px-4 py-3 font-semibold text-slate-900 dark:text-white">${order.order_number}</td>
                            <td class="px-4 py-3">${order.customer_name}</td>
                            <td class="px-4 py-3">${(order.placed_at || order.created_at) ? new Date(order.placed_at || order.created_at).toLocaleDateString() : '-'}</td>
                            <td class="px-4 py-3">${currencyFormatter.format(order.total_amount || 0)}</td>
                            <td class="px-4 py-3">${order.payment_status}</td>
                            <td class="px-4 py-3">${formatStatusLabel(order.status)}</td>
                            <td class="px-4 py-3 text-right"><a href="/admin/orders/${order.id}" class="text-xs font-semibold text-primary-600">Details</a></td>
                        </tr>
                    `;
                }).join('') || '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="7">No orders found.</td></tr>';

                info.textContent = 'Showing ' + list.length + ' of ' + (data.meta?.total ?? list.length) + ' orders';
                prevButton.disabled = !data.links?.prev;
                nextButton.disabled = !data.links?.next;
                latestOrders = list;
                if (!hasServerSummary) {
                    applyShiftSummary(buildShiftSummaryFromList(list));
                }
            }

            function applyShiftSummary(summary) {
                Object.keys(shiftCards).forEach(function (key) {
                    var entry = summary && summary[key] ? summary[key] : null;
                    if (!shiftCards[key]) {
                        return;
                    }
                    shiftCards[key].count.textContent = entry ? entry.count : 0;
                    shiftCards[key].amount.textContent = currencyFormatter.format(entry ? entry.amount : 0);
                });
            }

            async function loadShiftSummary() {
                await window.adminApi.ensureCsrfCookie();
                var query = buildOrderQuery();
                var response = await window.adminApi.request('/api/admin/orders/summary?' + query.toString());
                if (!response.ok) {
                    if (latestOrders.length) {
                        applyShiftSummary(buildShiftSummaryFromList(latestOrders));
                    } else {
                        setShiftSummaryPlaceholder('--');
                    }
                    return;
                }
                var data = await response.json();
                hasServerSummary = true;
                applyShiftSummary(data.summary);
            }

            function refreshListAndSummary() {
                currentPage = 1;
                hasServerSummary = false;
                loadOrders();
                loadShiftSummary();
            }

            searchInput.addEventListener('input', function () {
                refreshListAndSummary();
            });
            statusFilter.addEventListener('change', function () {
                refreshListAndSummary();
            });
            if (orderTypeFilter) {
                orderTypeFilter.addEventListener('change', function () {
                    refreshListAndSummary();
                });
            }
            paymentFilter.addEventListener('change', function () {
                refreshListAndSummary();
            });
            if (orderFromDate) {
                orderFromDate.addEventListener('change', function () {
                    refreshListAndSummary();
                });
            }
            if (orderToDate) {
                orderToDate.addEventListener('change', function () {
                    refreshListAndSummary();
                });
            }
            prevButton.addEventListener('click', function () {
                if (currentPage > 1) {
                    currentPage -= 1;
                    loadOrders();
                }
            });
            nextButton.addEventListener('click', function () {
                currentPage += 1;
                loadOrders();
            });
            if (exportButton) {
                exportButton.addEventListener('click', function () {
                    var query = buildOrderQuery();
                    var url = '/api/admin/orders/export';
                    if (query.toString()) {
                        url += '?' + query.toString();
                    }
                    window.location.href = url;
                });
            }



            loadOrders();
            loadShiftSummary();
        });
    </script>
@endsection
