@extends('layouts.admin')

@section('title', 'Checking Pick Up')
@section('page-title', 'Checking Pick Up')

@section('content')
    <div class="space-y-6">
        <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <div class="flex flex-wrap items-center justify-between gap-3">
                <div>
                    <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Pickup Order Verification</h2>
                    <p class="text-sm text-slate-500">Scan or enter the pickup ticket QR to verify orders.</p>
                </div>
                <span class="text-xs font-semibold uppercase tracking-widest text-slate-400">Pickup</span>
            </div>
            <div class="mt-4 grid gap-4 lg:grid-cols-2">
                <div class="rounded-2xl border border-slate-200 bg-slate-50 p-4 shadow-sm dark:border-slate-800 dark:bg-slate-950/40">
                    <label class="text-xs font-semibold uppercase tracking-widest text-slate-400">Scan QR token</label>
                    <div class="mt-2 flex flex-wrap items-center gap-3">
                        <input id="pickup-qr-input" type="text" placeholder="Paste or scan QR token" class="h-10 flex-1 rounded-xl border border-slate-200 bg-white px-3 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-200" />
                        <button id="pickup-qr-verify" class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-xs font-semibold text-white shadow-sm hover:bg-primary-700">Verify</button>
                        <button id="pickup-qr-camera" class="inline-flex h-10 items-center rounded-xl border border-slate-200 bg-white px-3 text-xs font-semibold text-slate-600 shadow-sm hover:border-primary-200 hover:text-primary-600 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300">Open Camera</button>
                        <button id="pickup-qr-photo" class="inline-flex h-10 items-center rounded-xl border border-slate-200 bg-white px-3 text-xs font-semibold text-slate-600 shadow-sm hover:border-primary-200 hover:text-primary-600 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300">Use Photo</button>
                        <input id="pickup-qr-file" type="file" accept="image/*" capture="environment" class="hidden" />
                    </div>
                    <div id="pickup-qr-camera-wrap" class="mt-3 hidden rounded-xl border border-slate-200 bg-white p-3 dark:border-slate-800 dark:bg-slate-900">
                        <div class="mb-3 flex flex-wrap items-center gap-3">
                            <label class="text-xs font-semibold uppercase tracking-widest text-slate-400">Camera</label>
                            <select id="pickup-qr-camera-select" class="h-9 flex-1 rounded-xl border border-slate-200 bg-white px-3 text-xs text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-200">
                                <option value="">Select camera</option>
                            </select>
                            <button id="pickup-qr-camera-refresh" class="inline-flex h-9 items-center rounded-xl border border-slate-200 bg-white px-3 text-xs font-semibold text-slate-600 shadow-sm hover:border-primary-200 hover:text-primary-600 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300">Refresh</button>
                            <div id="pickup-qr-camera-single" class="hidden text-xs font-semibold text-slate-700 dark:text-slate-200"></div>
                        </div>
                        <div id="pickup-qr-reader" class="mx-auto max-w-xs"></div>
                        <p class="mt-2 text-xs text-slate-500">Allow camera access to scan the ticket QR. If live camera does not open on phone, use Use Photo or open the page with HTTPS.</p>
                    </div>
                    <p id="pickup-qr-status" class="mt-2 text-xs text-slate-500">Waiting for scan.</p>
                </div>
                <div class="rounded-2xl border border-slate-200 bg-slate-50 p-4 shadow-sm dark:border-slate-800 dark:bg-slate-950/40">
                    <label class="text-xs font-semibold uppercase tracking-widest text-slate-400">Manual Order Search</label>
                    <div class="mt-2 flex flex-wrap items-center gap-3">
                        <input id="pickup-order-search-input" type="text" placeholder="Order ID or Order Number" class="h-10 flex-1 rounded-xl border border-slate-200 bg-white px-3 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-200" />
                        <button id="pickup-order-search" class="inline-flex h-10 items-center rounded-xl border border-slate-200 bg-white px-4 text-xs font-semibold text-slate-600 shadow-sm hover:border-primary-200 hover:text-primary-600 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300">Search</button>
                    </div>
                    <p class="mt-2 text-xs text-slate-500">Use this to review ticket status before verifying.</p>
                </div>
                <div class="rounded-2xl border border-slate-200 bg-slate-50 p-4 shadow-sm dark:border-slate-800 dark:bg-slate-950/40">
                    <label class="text-xs font-semibold uppercase tracking-widest text-slate-400">Verify by Ticket ID</label>
                    <div class="mt-2 flex flex-wrap items-center gap-3">
                        <input id="pickup-ticket-id-input" type="text" placeholder="Ticket ID (e.g., TCK-KYAPP00...)" class="h-10 flex-1 rounded-xl border border-slate-200 bg-white px-3 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-200" />
                        <button id="pickup-ticket-id-verify" class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-xs font-semibold text-white shadow-sm hover:bg-primary-700">Verify Ticket</button>
                    </div>
                    <p class="mt-2 text-xs text-slate-500">Enter ticket ID to verify without scanning QR.</p>
                </div>
            </div>
            <div class="mt-4 rounded-2xl border border-slate-200 bg-white p-4 shadow-sm dark:border-slate-800 dark:bg-slate-900/60">
                <div class="flex flex-wrap items-center justify-between gap-2">
                    <div>
                        <p class="text-xs uppercase tracking-widest text-slate-400">Verification Result</p>
                        <p id="pickup-order-title" class="mt-1 text-sm font-semibold text-slate-900 dark:text-white">No order selected.</p>
                    </div>
                    <span id="pickup-ticket-status" class="rounded-full bg-slate-100 px-3 py-1 text-xs font-semibold text-slate-600 dark:bg-slate-800 dark:text-slate-200">--</span>
                </div>
                <div class="mt-3 grid gap-2 text-sm text-slate-600 dark:text-slate-300 sm:grid-cols-2">
                    <div>Customer: <span id="pickup-order-customer" class="font-semibold text-slate-900 dark:text-white">--</span></div>
                    <div>Payment: <span id="pickup-order-payment" class="font-semibold text-slate-900 dark:text-white">--</span></div>
                    <div>Status: <span id="pickup-order-status" class="font-semibold text-slate-900 dark:text-white">--</span></div>
                    <div>Verified At: <span id="pickup-order-verified" class="font-semibold text-slate-900 dark:text-white">--</span></div>
                    <div>Verified By: <span id="pickup-order-verified-by" class="font-semibold text-slate-900 dark:text-white">--</span></div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://unpkg.com/html5-qrcode"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var pickupQrInput = document.getElementById('pickup-qr-input');
            var pickupQrVerify = document.getElementById('pickup-qr-verify');
            var pickupQrCameraButton = document.getElementById('pickup-qr-camera');
            var pickupQrPhotoButton = document.getElementById('pickup-qr-photo');
            var pickupQrCameraWrap = document.getElementById('pickup-qr-camera-wrap');
            var pickupQrReader = document.getElementById('pickup-qr-reader');
            var pickupQrCameraSelect = document.getElementById('pickup-qr-camera-select');
            var pickupQrCameraRefresh = document.getElementById('pickup-qr-camera-refresh');
            var pickupQrCameraSingle = document.getElementById('pickup-qr-camera-single');
            var pickupQrFileInput = document.getElementById('pickup-qr-file');
            var pickupQrStatus = document.getElementById('pickup-qr-status');
            var pickupOrderSearchInput = document.getElementById('pickup-order-search-input');
            var pickupOrderSearchButton = document.getElementById('pickup-order-search');
            var pickupTicketIdInput = document.getElementById('pickup-ticket-id-input');
            var pickupTicketIdVerify = document.getElementById('pickup-ticket-id-verify');
            var pickupOrderTitle = document.getElementById('pickup-order-title');
            var pickupTicketStatus = document.getElementById('pickup-ticket-status');
            var pickupOrderCustomer = document.getElementById('pickup-order-customer');
            var pickupOrderPayment = document.getElementById('pickup-order-payment');
            var pickupOrderStatus = document.getElementById('pickup-order-status');
            var pickupOrderVerified = document.getElementById('pickup-order-verified');
            var pickupOrderVerifiedBy = document.getElementById('pickup-order-verified-by');
            var pickupQrScanner = null;
            var pickupQrActive = false;
            var pickupQrCameras = [];
            var pickupQrAutoTimer = null;
            var pickupQrLastToken = null;
            var pickupTicketAutoTimer = null;
            var pickupTicketLastId = null;

            function canUseLiveCamera() {
                return !!(window.isSecureContext && navigator.mediaDevices && navigator.mediaDevices.getUserMedia);
            }

            function openPickupQrPhotoInput() {
                if (!pickupQrFileInput) {
                    pickupQrStatus.textContent = 'Photo scanner not available.';
                    return;
                }

                pickupQrFileInput.click();
            }

            function normalizeTicketStatus(order) {
                if (!order) { return 'invalid'; }
                return (order.pickup_ticket_status || (order.pickup_verified_at ? 'used' : 'active') || 'active').toLowerCase();
            }

            function setPickupStatusBadge(status) {
                if (!pickupTicketStatus) { return; }
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
                if (!token) { pickupQrStatus.textContent = 'Please scan or paste a QR token.'; return; }
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
                } catch (error) {
                    pickupQrStatus.textContent = 'Verification failed.';
                    renderPickupOrder(null, pickupQrStatus.textContent);
                    console.error(error);
                } finally {
                    pickupQrVerify.disabled = false;
                }
            }

            function scheduleAutoVerifyToken() {
                if (!pickupQrInput) { return; }
                var token = pickupQrInput.value.trim();
                if (!token || token === pickupQrLastToken) { return; }
                if (pickupQrAutoTimer) { clearTimeout(pickupQrAutoTimer); }
                pickupQrAutoTimer = setTimeout(function () {
                    pickupQrLastToken = token;
                    verifyPickupToken();
                }, 400);
            }

            async function verifyPickupTicketId() {
                var ticketId = pickupTicketIdInput.value.trim();
                if (!ticketId) { pickupQrStatus.textContent = 'Please enter a ticket ID.'; return; }
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
                } catch (error) {
                    pickupQrStatus.textContent = 'Verification failed.';
                    renderPickupOrder(null, pickupQrStatus.textContent);
                    console.error(error);
                } finally {
                    pickupTicketIdVerify.disabled = false;
                }
            }

            function scheduleAutoVerifyTicketId() {
                if (!pickupTicketIdInput) { return; }
                var ticketId = pickupTicketIdInput.value.trim();
                if (!ticketId || ticketId === pickupTicketLastId) { return; }
                if (pickupTicketAutoTimer) { clearTimeout(pickupTicketAutoTimer); }
                pickupTicketAutoTimer = setTimeout(function () {
                    pickupTicketLastId = ticketId;
                    verifyPickupTicketId();
                }, 400);
            }

            async function startPickupQrCamera() {
                if (!pickupQrReader) { return; }
                if (!window.Html5Qrcode) { pickupQrStatus.textContent = 'QR scanner library not available.'; return; }
                if (!canUseLiveCamera()) {
                    pickupQrStatus.textContent = 'Live camera needs HTTPS or localhost on mobile. Opening photo capture instead.';
                    openPickupQrPhotoInput();
                    return;
                }
                try {
                    pickupQrScanner = pickupQrScanner || new Html5Qrcode('pickup-qr-reader');
                    var cameras = await Html5Qrcode.getCameras();
                    pickupQrCameras = cameras || [];
                    renderCameraOptions();
                    pickupQrStatus.textContent = 'Camera ready. Scan the QR code.';
                    pickupQrCameraWrap.classList.remove('hidden');
                    pickupQrCameraButton.textContent = 'Stop Camera';
                    pickupQrActive = true;

                    var cameraId = getSelectedCameraId();
                    var cameraConfig = cameraId
                        ? { deviceId: { exact: cameraId } }
                        : { facingMode: 'environment' };

                    try {
                        await pickupQrScanner.start(
                            cameraConfig,
                            { fps: 10, qrbox: 280 },
                            function (decodedText) {
                                pickupQrInput.value = decodedText;
                                pickupQrStatus.textContent = 'QR scanned. Verifying...';
                                stopPickupQrCamera();
                                verifyPickupToken();
                            }
                        );
                    } catch (startError) {
                        if (cameraId) {
                            await pickupQrScanner.start(
                                { facingMode: 'environment' },
                                { fps: 10, qrbox: 280 },
                                function (decodedText) {
                                    pickupQrInput.value = decodedText;
                                    pickupQrStatus.textContent = 'QR scanned. Verifying...';
                                    stopPickupQrCamera();
                                    verifyPickupToken();
                                }
                            );
                        } else {
                            throw startError;
                        }
                    }
                } catch (error) {
                    pickupQrStatus.textContent = 'Unable to access live camera. Use Photo instead.';
                    console.error(error);
                }
            }

            async function scanPickupQrFile(file) {
                if (!file) {
                    return;
                }
                if (!window.Html5Qrcode) {
                    pickupQrStatus.textContent = 'QR scanner library not available.';
                    return;
                }

                try {
                    if (pickupQrActive) {
                        await stopPickupQrCamera();
                    }

                    pickupQrScanner = pickupQrScanner || new Html5Qrcode('pickup-qr-reader');
                    pickupQrCameraWrap.classList.remove('hidden');
                    pickupQrStatus.textContent = 'Reading QR from photo...';

                    var decodedText = await pickupQrScanner.scanFile(file, true);
                    pickupQrInput.value = decodedText;
                    pickupQrStatus.textContent = 'QR scanned from photo. Verifying...';
                    verifyPickupToken();
                } catch (error) {
                    pickupQrStatus.textContent = 'Unable to read QR from photo.';
                    console.error(error);
                } finally {
                    if (pickupQrFileInput) {
                        pickupQrFileInput.value = '';
                    }
                }
            }

            function getSelectedCameraId() {
                if (!pickupQrCameraSelect) { return null; }
                var value = pickupQrCameraSelect.value;
                return value ? value : null;
            }

            function findCamoCameraId() {
                if (!pickupQrCameras || !pickupQrCameras.length) { return null; }
                var camo = pickupQrCameras.find(function (camera) {
                    return (camera.label || '').toLowerCase().includes('camo');
                });
                return camo ? camo.id : null;
            }

            function renderCameraOptions() {
                if (!pickupQrCameraSelect) { return; }
                var current = pickupQrCameraSelect.value;
                pickupQrCameraSelect.innerHTML = '<option value="">Select camera</option>';
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
                        pickupQrCameraSingle.textContent = pickupQrCameras.length ? (pickupQrCameras[0].label || 'Camera ready') : 'No camera found';
                    }
                } else {
                    pickupQrCameraSelect.classList.remove('hidden');
                    pickupQrCameraRefresh.classList.remove('hidden');
                    if (pickupQrCameraSingle) { pickupQrCameraSingle.classList.add('hidden'); }
                }
                var camoId = findCamoCameraId();
                if (camoId) {
                    pickupQrCameraSelect.value = camoId;
                } else if (current && pickupQrCameras.some(function (c) { return c.id === current; })) {
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
                    return Promise.resolve();
                }
                return pickupQrScanner.stop().then(function () {
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
                if (!value) { renderPickupOrder(null, 'Enter an order id or number to search.'); return; }
                try {
                    await window.adminApi.ensureCsrfCookie();
                    var response;
                    if (/^\d+$/.test(value)) {
                        response = await window.adminApi.request('/api/orders/' + value);
                    } else {
                        response = await window.adminApi.request('/api/orders?q=' + encodeURIComponent(value));
                    }
                    if (!response.ok) { renderPickupOrder(null, 'Order not found.'); return; }
                    var payload = await response.json();
                    var order = payload.data || payload;
                    if (Array.isArray(order)) {
                        order = order.length ? order[0] : null;
                    } else if (payload.data && Array.isArray(payload.data)) {
                        order = payload.data.length ? payload.data[0] : null;
                    }
                    if (!order) { renderPickupOrder(null, 'Order not found.'); return; }
                    renderPickupOrder(order);
                } catch (error) {
                    renderPickupOrder(null, 'Unable to fetch order.');
                    console.error(error);
                }
            }

            if (pickupQrVerify) { pickupQrVerify.addEventListener('click', verifyPickupToken); }
            if (pickupQrInput) {
                pickupQrInput.addEventListener('keydown', function (event) {
                    if (event.key === 'Enter') { event.preventDefault(); verifyPickupToken(); }
                });
                pickupQrInput.addEventListener('input', function () { scheduleAutoVerifyToken(); });
            }
            if (pickupQrCameraButton) {
                pickupQrCameraButton.addEventListener('click', function () {
                    if (pickupQrActive) { stopPickupQrCamera(); } else { startPickupQrCamera(); }
                });
            }
            if (pickupQrPhotoButton) {
                pickupQrPhotoButton.addEventListener('click', function () {
                    openPickupQrPhotoInput();
                });
            }
            if (pickupQrFileInput) {
                pickupQrFileInput.addEventListener('change', function (event) {
                    var file = event.target.files && event.target.files[0] ? event.target.files[0] : null;
                    scanPickupQrFile(file);
                });
            }
            if (pickupQrCameraRefresh) {
                pickupQrCameraRefresh.addEventListener('click', async function () {
                    if (!window.Html5Qrcode) { pickupQrStatus.textContent = 'QR scanner library not available.'; return; }
                    try {
                        pickupQrCameras = await Html5Qrcode.getCameras();
                        renderCameraOptions();
                        pickupQrStatus.textContent = pickupQrCameras.length ? 'Camera list updated.' : 'No camera found.';
                    } catch (error) {
                        pickupQrStatus.textContent = 'Unable to load cameras.';
                        console.error(error);
                    }
                });
            }
            if (pickupQrCameraSelect) {
                pickupQrCameraSelect.addEventListener('change', async function () {
                    if (pickupQrActive) {
                        await stopPickupQrCamera();
                        startPickupQrCamera();
                    }
                });
            }
            if (pickupTicketIdVerify) { pickupTicketIdVerify.addEventListener('click', verifyPickupTicketId); }
            if (pickupTicketIdInput) {
                pickupTicketIdInput.addEventListener('keydown', function (event) {
                    if (event.key === 'Enter') { event.preventDefault(); verifyPickupTicketId(); }
                });
                pickupTicketIdInput.addEventListener('input', function () { scheduleAutoVerifyTicketId(); });
            }
            if (pickupOrderSearchButton) { pickupOrderSearchButton.addEventListener('click', searchPickupOrder); }
            if (pickupOrderSearchInput) {
                pickupOrderSearchInput.addEventListener('keydown', function (event) {
                    if (event.key === 'Enter') { event.preventDefault(); searchPickupOrder(); }
                });
            }
        });
    </script>
@endsection
