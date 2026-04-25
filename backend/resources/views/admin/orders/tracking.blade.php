@extends('layouts.admin')

@section('title', 'Tracking Order')
@section('page-title', 'Tracking Order')

@section('content')
<div class="space-y-6">

    {{-- Header & Stats --}}
    <div class="grid grid-cols-2 gap-4 md:grid-cols-3 xl:grid-cols-5">
        <div class="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Total Delivery</p>
            <p id="stat-total" class="mt-2 text-2xl font-bold text-slate-900 dark:text-white">--</p>
        </div>
        <div class="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Pending</p>
            <p id="stat-pending" class="mt-2 text-2xl font-bold text-warning-600 dark:text-warning-400">--</p>
        </div>
        <div class="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Out for Delivery</p>
            <p id="stat-out" class="mt-2 text-2xl font-bold text-primary-600 dark:text-primary-400">--</p>
        </div>
        <div class="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Delivered</p>
            <p id="stat-delivered" class="mt-2 text-2xl font-bold text-success-600 dark:text-success-400">--</p>
        </div>
        <div class="col-span-2 rounded-2xl border border-slate-200 bg-white p-4 shadow-sm dark:border-slate-800 dark:bg-slate-900 md:col-span-1">
            <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Cancelled</p>
            <p id="stat-cancelled" class="mt-2 text-2xl font-bold text-danger-600 dark:text-danger-400">--</p>
        </div>
    </div>

    {{-- Filters --}}
    <div class="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm dark:border-slate-800 dark:bg-slate-900">
        <div class="flex flex-wrap items-center gap-3">
            <select id="track-status-filter" class="h-10 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300">
                <option value="">All Workflow Stages</option>
                <option value="pending_approval">Pending Approval</option>
                <option value="approved">Approved</option>
                <option value="assigned">Assigned</option>
                <option value="in_progress">In Progress</option>
                <option value="out_for_delivery">Out for Delivery</option>
                <option value="delivered">Delivered</option>
                <option value="completed">Completed</option>
                <option value="cancelled">Cancelled</option>
                <option value="rejected">Rejected</option>
            </select>
            <input id="track-from-date" type="date" class="h-10 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300" />
            <input id="track-to-date" type="date" class="h-10 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300" />
            <div class="relative flex-1">
                <input id="track-search" type="text" placeholder="Search order, customer…" class="h-10 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 pr-9 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                <svg class="absolute right-3 top-3 h-4 w-4 text-slate-400" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-4.35-4.35m1.6-5.15a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>
            </div>
            <button id="track-refresh" class="inline-flex h-10 items-center gap-2 rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-600 shadow-sm hover:border-primary-300 hover:text-primary-600 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-300">
                <svg class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M4 4v5h5M20 20v-5h-5M4.05 9A9 9 0 0119.95 15M19.95 15A9 9 0 014.05 9"/></svg>
                Refresh
            </button>
        </div>
    </div>

    {{-- Order workflow list --}}
    <div id="track-list" class="space-y-4">
        <div class="flex items-center justify-center py-16">
            <svg class="h-8 w-8 animate-spin text-primary-500" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8z"/></svg>
        </div>
    </div>

    {{-- Pagination --}}
    <div class="flex items-center justify-between text-xs text-slate-500">
        <p id="track-pagination-info">Loading…</p>
        <div class="flex gap-2">
            <button id="track-prev" class="rounded-lg border border-slate-200 px-3 py-1 text-slate-600 disabled:opacity-40 dark:border-slate-800 dark:text-slate-300">Previous</button>
            <button id="track-next" class="rounded-lg border border-slate-200 bg-slate-100 px-3 py-1 text-slate-900 disabled:opacity-40 dark:border-slate-800 dark:bg-slate-900">Next</button>
        </div>
    </div>
</div>

{{-- Order Detail Drawer --}}
<div id="track-drawer" class="fixed inset-y-0 right-0 z-50 hidden w-full max-w-lg flex-col border-l border-slate-200 bg-white shadow-2xl dark:border-slate-800 dark:bg-slate-900">
    <div class="flex items-center justify-between border-b border-slate-200 px-6 py-4 dark:border-slate-800">
        <div>
            <p id="drawer-order-number" class="text-xs uppercase tracking-widest text-slate-400">Order</p>
            <h3 id="drawer-customer" class="text-lg font-semibold text-slate-900 dark:text-white">--</h3>
        </div>
        <div class="flex items-center gap-3">
            <span id="drawer-status-badge" class="rounded-full bg-slate-100 px-3 py-1 text-xs font-semibold text-slate-700 dark:bg-slate-800 dark:text-slate-200">--</span>
            <button id="drawer-close" class="rounded-lg border border-slate-200 p-2 text-slate-400 hover:text-slate-900 dark:border-slate-700 dark:hover:text-white">
                <svg class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"/></svg>
            </button>
        </div>
    </div>
    <div class="flex-1 overflow-y-auto p-6 space-y-5">

        {{-- Workflow progress --}}
        <div>
            <p class="text-xs font-semibold uppercase tracking-widest text-slate-400 mb-3">Delivery Workflow</p>
            <div id="drawer-workflow-steps" class="relative pl-6 space-y-3 before:absolute before:left-2 before:top-2 before:bottom-2 before:w-0.5 before:bg-slate-200 dark:before:bg-slate-700"></div>
        </div>

        {{-- Order info --}}
        <div class="rounded-2xl border border-slate-200 bg-slate-50 p-4 dark:border-slate-800 dark:bg-slate-950/40 space-y-2 text-sm text-slate-600 dark:text-slate-300">
            <p class="text-xs font-semibold uppercase tracking-widest text-slate-400 mb-2">Order Info</p>
            <div class="flex justify-between"><span>Placed At</span><span id="drawer-placed" class="font-semibold text-slate-900 dark:text-white">--</span></div>
            <div class="flex justify-between"><span>Total</span><span id="drawer-total" class="font-semibold text-slate-900 dark:text-white">--</span></div>
            <div class="flex justify-between"><span>Payment</span><span id="drawer-payment" class="font-semibold text-slate-900 dark:text-white">--</span></div>
            <div class="flex justify-between"><span>Assigned Staff</span><span id="drawer-staff" class="font-semibold text-slate-900 dark:text-white">--</span></div>
        </div>

        {{-- Delivery info --}}
        <div class="rounded-2xl border border-slate-200 bg-slate-50 p-4 dark:border-slate-800 dark:bg-slate-950/40 space-y-2 text-sm text-slate-600 dark:text-slate-300">
            <p class="text-xs font-semibold uppercase tracking-widest text-slate-400 mb-2">Delivery Info</p>
            <div class="flex justify-between gap-3"><span class="shrink-0">Address</span><span id="drawer-address" class="text-right font-semibold text-slate-900 dark:text-white">--</span></div>
            <div class="flex justify-between"><span>Phone</span><span id="drawer-phone" class="font-semibold text-slate-900 dark:text-white">--</span></div>
            <div class="flex justify-between gap-3"><span class="shrink-0">Note</span><span id="drawer-note" class="text-right font-semibold text-slate-900 dark:text-white">--</span></div>
        </div>

        {{-- Items --}}
        <div>
            <p class="text-xs font-semibold uppercase tracking-widest text-slate-400 mb-3">Items</p>
            <div class="overflow-hidden rounded-2xl border border-slate-200 dark:border-slate-800">
                <table class="w-full text-left text-sm">
                    <thead class="bg-slate-50 text-xs uppercase tracking-widest text-slate-400 dark:bg-slate-950/40">
                        <tr>
                            <th class="px-4 py-2">Item</th>
                            <th class="px-4 py-2">Qty</th>
                            <th class="px-4 py-2 text-right">Total</th>
                        </tr>
                    </thead>
                    <tbody id="drawer-items" class="divide-y divide-slate-200 text-slate-600 dark:divide-slate-800 dark:text-slate-300"></tbody>
                </table>
            </div>
        </div>

        {{-- Status update --}}
        <div class="rounded-2xl border border-primary-200 bg-primary-50 p-4 dark:border-primary-500/20 dark:bg-primary-500/5">
            <p class="text-xs font-semibold uppercase tracking-widest text-primary-600 dark:text-primary-300 mb-3">Update Status</p>
            <div class="flex gap-2">
                <select id="drawer-status-select" class="h-10 flex-1 rounded-xl border border-slate-200 bg-white px-3 text-sm text-slate-700 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-200"></select>
                <button id="drawer-status-save" class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-xs font-semibold text-white shadow-sm hover:bg-primary-700 disabled:cursor-not-allowed disabled:opacity-50">Save</button>
            </div>
            <textarea id="drawer-status-note-input" rows="2" placeholder="Optional note…" class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-200"></textarea>
            <p id="drawer-status-msg" class="mt-2 text-xs text-slate-500"></p>
        </div>

        {{-- Full detail link --}}
        <div class="text-center">
            <a id="drawer-full-link" href="#" class="text-sm font-semibold text-primary-600 hover:underline dark:text-primary-400">View Full Order Details →</a>
        </div>
    </div>
</div>
<div id="track-backdrop" class="fixed inset-0 z-40 hidden bg-black/30 backdrop-blur-sm"></div>

<style>
    #track-drawer.open { display: flex; }
    .workflow-step-done .step-dot  { background: #16a34a; border-color: #16a34a; }
    .workflow-step-done .step-label { color: #15803d; font-weight: 600; }
    .workflow-step-active .step-dot { background: #2563eb; border-color: #2563eb; box-shadow: 0 0 0 3px rgba(37,99,235,.2); }
    .workflow-step-active .step-label { color: #1d4ed8; font-weight: 700; }
    .workflow-step-pending .step-dot { background: #fff; border-color: #cbd5e1; }
    .dark .workflow-step-pending .step-dot { background: #1e293b; border-color: #475569; }
    .workflow-step-cancelled .step-dot { background: #dc2626; border-color: #dc2626; }
    .workflow-step-cancelled .step-label { color: #dc2626; font-weight: 600; }
</style>

<script>
document.addEventListener('DOMContentLoaded', function () {
    var currency = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' });
    var currentPage = 1;
    var currentDrawerOrderId = null;
    var currentDrawerStatus = null;

    var statusFilter = document.getElementById('track-status-filter');
    var fromDate     = document.getElementById('track-from-date');
    var toDate       = document.getElementById('track-to-date');
    var searchInput  = document.getElementById('track-search');
    var refreshBtn   = document.getElementById('track-refresh');
    var list         = document.getElementById('track-list');
    var paginInfo    = document.getElementById('track-pagination-info');
    var prevBtn      = document.getElementById('track-prev');
    var nextBtn      = document.getElementById('track-next');

    var drawer           = document.getElementById('track-drawer');
    var backdrop         = document.getElementById('track-backdrop');
    var drawerClose      = document.getElementById('drawer-close');
    var drawerStatusSel  = document.getElementById('drawer-status-select');
    var drawerStatusSave = document.getElementById('drawer-status-save');
    var drawerStatusMsg  = document.getElementById('drawer-status-msg');
    var drawerStatusNote = document.getElementById('drawer-status-note-input');
    var drawerFullLink   = document.getElementById('drawer-full-link');

    var WORKFLOW_STEPS = [
        { value: 'pending_approval', label: 'Pending Approval' },
        { value: 'approved',         label: 'Approved' },
        { value: 'assigned',         label: 'Assigned' },
        { value: 'in_progress',      label: 'In Progress' },
        { value: 'out_for_delivery', label: 'Out for Delivery' },
        { value: 'delivered',        label: 'Delivered' },
        { value: 'completed',        label: 'Completed' }
    ];

    function statusLabel(s) {
        var map = {
            pending_approval: 'Pending Approval', approved: 'Approved', assigned: 'Assigned',
            in_progress: 'In Progress', on_the_way: 'On the Way', out_for_delivery: 'Out for Delivery',
            delivered: 'Delivered', completed: 'Completed', cancelled: 'Cancelled', rejected: 'Rejected',
            created: 'Created', pending: 'Pending', ready: 'Ready'
        };
        return map[s] || (s || '--').replace(/_/g, ' ').replace(/\b\w/g, function(c){return c.toUpperCase();});
    }

    function statusBadgeClass(s) {
        if (s === 'delivered' || s === 'completed') return 'bg-success-50 text-success-700 dark:bg-success-500/10 dark:text-success-200';
        if (s === 'out_for_delivery') return 'bg-primary-50 text-primary-700 dark:bg-primary-500/10 dark:text-primary-200';
        if (s === 'cancelled' || s === 'rejected') return 'bg-danger-50 text-danger-700 dark:bg-danger-500/10 dark:text-danger-200';
        if (s === 'assigned' || s === 'in_progress') return 'bg-indigo-50 text-indigo-700 dark:bg-indigo-500/10 dark:text-indigo-200';
        return 'bg-warning-50 text-warning-700 dark:bg-warning-500/10 dark:text-warning-200';
    }

    function buildQuery() {
        var q = new URLSearchParams({ order_type: 'delivery' });
        if (statusFilter.value) q.set('status', statusFilter.value);
        if (fromDate.value) q.set('from_date', fromDate.value);
        if (toDate.value) q.set('to_date', toDate.value);
        if (searchInput.value.trim()) q.set('q', searchInput.value.trim());
        return q;
    }

    async function loadOrders() {
        list.innerHTML = '<div class="flex justify-center py-16"><svg class="h-8 w-8 animate-spin text-primary-500" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8z"/></svg></div>';
        try {
            await window.adminApi.ensureCsrfCookie();
            // Load full stats from all pages (no pagination limit)
            var statsQ = new URLSearchParams({ order_type: 'delivery', per_page: 999 });
            var statsRes = await window.adminApi.request('/api/orders?' + statsQ.toString());
            if (statsRes.ok) {
                var statsData = await statsRes.json();
                updateStats(statsData.data || []);
            }
            // Load paginated list
            var q = buildQuery();
            q.set('page', currentPage);
            var res = await window.adminApi.request('/api/orders?' + q.toString());
            if (!res.ok) { list.innerHTML = '<p class="py-10 text-center text-sm text-slate-500">Unable to load orders.</p>'; return; }
            var data = await res.json();
            var orders = data.data || [];
            renderList(orders);
            var total = data.meta && data.meta.total != null ? data.meta.total : orders.length;
            paginInfo.textContent = 'Showing ' + orders.length + ' of ' + total + ' delivery orders';
            prevBtn.disabled = currentPage <= 1 || !data.links || !data.links.prev;
            nextBtn.disabled = !data.links || !data.links.next;
        } catch (e) {
            list.innerHTML = '<p class="py-10 text-center text-sm text-slate-500">Error loading orders.</p>';
            console.error(e);
        }
    }

    function updateStats(orders) {
        var stats = { total: orders.length, pending: 0, out: 0, delivered: 0, cancelled: 0 };
        orders.forEach(function(o) {
            var s = (o.status || '').toLowerCase();
            if (s === 'pending_approval' || s === 'pending' || s === 'approved' || s === 'assigned' || s === 'in_progress') stats.pending++;
            else if (s === 'out_for_delivery') stats.out++;
            else if (s === 'delivered' || s === 'completed') stats.delivered++;
            else if (s === 'cancelled' || s === 'rejected') stats.cancelled++;
        });
        document.getElementById('stat-total').textContent = stats.total;
        document.getElementById('stat-pending').textContent = stats.pending;
        document.getElementById('stat-out').textContent = stats.out;
        document.getElementById('stat-delivered').textContent = stats.delivered;
        document.getElementById('stat-cancelled').textContent = stats.cancelled;
    }

    function renderList(orders) {
        if (!orders.length) {
            list.innerHTML = '<div class="rounded-2xl border border-dashed border-slate-300 dark:border-slate-700 py-16 text-center"><p class="text-sm text-slate-400">No delivery orders found.</p></div>';
            return;
        }
        list.innerHTML = orders.map(function(o) {
            var s = (o.status || '').toLowerCase();
            var badgeCls = statusBadgeClass(s);
            var date = (o.placed_at || o.created_at) ? new Date(o.placed_at || o.created_at).toLocaleDateString() : '--';
            return [
                '<div class="rounded-2xl border border-slate-200 bg-white shadow-sm dark:border-slate-800 dark:bg-slate-900 overflow-hidden">',
                '  <div class="flex flex-wrap items-center justify-between gap-3 p-5">',
                '    <div class="flex items-center gap-4">',
                '      <div class="flex h-10 w-10 items-center justify-center rounded-xl bg-primary-50 text-primary-600 dark:bg-primary-500/10 dark:text-primary-300">',
                '        <svg class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M13 16h-1v-4h-1m1-4h.01M12 2a10 10 0 100 20A10 10 0 0012 2z"/></svg>',
                '      </div>',
                '      <div>',
                '        <p class="text-sm font-semibold text-slate-900 dark:text-white">' + (o.order_number || 'Order #' + o.id) + '</p>',
                '        <p class="text-xs text-slate-500">' + (o.customer_name || '--') + ' &bull; ' + date + '</p>',
                '      </div>',
                '    </div>',
                '    <div class="flex items-center gap-3">',
                '      <span class="rounded-full px-3 py-1 text-xs font-semibold ' + badgeCls + '">' + statusLabel(s) + '</span>',
                '      <span class="text-sm font-semibold text-slate-900 dark:text-white">' + currency.format(o.total_amount || 0) + '</span>',
                '      <button data-order-id="' + o.id + '" class="track-detail-btn inline-flex h-9 items-center rounded-xl bg-primary-600 px-4 text-xs font-semibold text-white hover:bg-primary-700">Detail</button>',
                '    </div>',
                '  </div>',
                '  <div class="border-t border-slate-100 dark:border-slate-800 px-5 py-3">',
                '    ' + renderMiniWorkflow(s),
                '  </div>',
                '</div>'
            ].join('');
        }).join('');

        list.querySelectorAll('.track-detail-btn').forEach(function(btn) {
            btn.addEventListener('click', function() { openDrawer(btn.dataset.orderId); });
        });
    }

    function renderMiniWorkflow(currentStatus) {
        var cancelled = currentStatus === 'cancelled' || currentStatus === 'rejected';
        var currentIdx = WORKFLOW_STEPS.findIndex(function(s) { return s.value === currentStatus; });
        var html = '<div class="flex w-full items-start overflow-x-auto">';
        WORKFLOW_STEPS.forEach(function(step, i) {
            var isCurrent = step.value === currentStatus;
            var isDone = currentIdx > i && !cancelled;
            var dotClass = (cancelled && isCurrent) ? 'bg-danger-500 border-danger-500' :
                           isCurrent ? 'bg-primary-600 border-primary-600 shadow-[0_0_0_3px_rgba(37,99,235,0.2)]' :
                           isDone    ? 'bg-success-500 border-success-500' :
                                       'bg-white border-slate-300 dark:bg-slate-800 dark:border-slate-600';
            var labelCls = (cancelled && isCurrent) ? 'text-danger-600 dark:text-danger-400 font-semibold' :
                           isCurrent ? 'text-primary-700 dark:text-primary-300 font-bold' :
                           isDone    ? 'text-success-600 dark:text-success-400 font-medium' : 'text-slate-400';
            var lineColor = (isDone || isCurrent) ? 'bg-primary-400 dark:bg-primary-500' : 'bg-slate-200 dark:bg-slate-700';
            html += '<div class="flex flex-1 flex-col items-center min-w-0">';
            html += '  <div class="flex w-full items-center">';
            html += '    ' + (i > 0 ? '<div class="h-px flex-1 ' + lineColor + '"></div>' : '<div class="flex-1"></div>');
            html += '    <div class="h-3 w-3 shrink-0 rounded-full border-2 ' + dotClass + '"></div>';
            html += '    ' + (i < WORKFLOW_STEPS.length - 1 ? '<div class="h-px flex-1 ' + lineColor + '"></div>' : '<div class="flex-1"></div>');
            html += '  </div>';
            html += '  <p class="mt-1 w-full truncate text-center text-[9px] leading-tight ' + labelCls + '" title="' + step.label + '">' + step.label + '</p>';
            html += '</div>';
        });
        html += '</div>';
        return html;
    }

    async function openDrawer(orderId) {
        currentDrawerOrderId = orderId;
        drawerStatusMsg.textContent = '';
        drawerStatusNote.value = '';
        drawer.classList.add('open');
        backdrop.classList.remove('hidden');
        document.getElementById('drawer-workflow-steps').innerHTML = '<p class="text-xs text-slate-400">Loading…</p>';
        document.getElementById('drawer-items').innerHTML = '';

        try {
            await window.adminApi.ensureCsrfCookie();
            var res = await window.adminApi.request('/api/orders/' + orderId);
            if (!res.ok) { document.getElementById('drawer-workflow-steps').innerHTML = '<p class="text-xs text-slate-400">Unable to load order.</p>'; return; }
            var data = await res.json();
            renderDrawer(data.data);
        } catch (e) { console.error(e); }
    }

    function renderDrawer(order) {
        currentDrawerStatus = (order.status || '').toLowerCase();
        drawerFullLink.href = '/admin/orders/' + order.id;

        document.getElementById('drawer-order-number').textContent = order.order_number || 'Order';
        document.getElementById('drawer-customer').textContent = order.customer_name || '--';
        document.getElementById('drawer-placed').textContent = order.placed_at ? new Date(order.placed_at).toLocaleString() : '--';
        document.getElementById('drawer-total').textContent = currency.format(order.total_amount || 0);
        document.getElementById('drawer-payment').textContent = order.payment_status || '--';
        document.getElementById('drawer-staff').textContent = order.assigned_staff_name || 'Not assigned';
        document.getElementById('drawer-address').textContent = order.delivery_address || '--';
        document.getElementById('drawer-phone').textContent = order.delivery_phone || '--';
        document.getElementById('drawer-note').textContent = order.delivery_note || '--';

        var badge = document.getElementById('drawer-status-badge');
        badge.textContent = statusLabel(currentDrawerStatus);
        badge.className = 'rounded-full px-3 py-1 text-xs font-semibold ' + statusBadgeClass(currentDrawerStatus);

        // Workflow steps
        var steps = document.getElementById('drawer-workflow-steps');
        var cancelled = currentDrawerStatus === 'cancelled' || currentDrawerStatus === 'rejected';
        var currentIdx = WORKFLOW_STEPS.findIndex(function(s) { return s.value === currentDrawerStatus; });
        steps.innerHTML = WORKFLOW_STEPS.map(function(step, i) {
            var isCurrent = step.value === currentDrawerStatus;
            var isDone = currentIdx > i && !cancelled;
            var cls = cancelled && isCurrent ? 'workflow-step-cancelled' : isCurrent ? 'workflow-step-active' : isDone ? 'workflow-step-done' : 'workflow-step-pending';
            var history = Array.isArray(order.tracking_history) ? order.tracking_history : [];
            var entry = history.find(function(h) { return (h.to_status || '').toLowerCase() === step.value; });
            var timeStr = entry && entry.created_at ? new Date(entry.created_at).toLocaleString() : '';
            return '<div class="' + cls + ' flex items-start gap-3">' +
                '<div class="step-dot mt-0.5 h-4 w-4 shrink-0 rounded-full border-2 transition-all"></div>' +
                '<div>' +
                '<p class="step-label text-sm">' + step.label + '</p>' +
                (timeStr ? '<p class="text-xs text-slate-400 dark:text-slate-500">' + timeStr + '</p>' : '') +
                (entry && entry.changed_by_name ? '<p class="text-xs text-slate-500">by ' + entry.changed_by_name + (entry.note ? ' — ' + entry.note : '') + '</p>' : '') +
                '</div></div>';
        }).join('');

        if (cancelled) {
            steps.innerHTML += '<div class="workflow-step-cancelled flex items-start gap-3"><div class="step-dot mt-0.5 h-4 w-4 shrink-0 rounded-full border-2 transition-all"></div><div><p class="step-label text-sm">' + statusLabel(currentDrawerStatus) + '</p></div></div>';
        }

        // Items
        var items = order.items || [];
        document.getElementById('drawer-items').innerHTML = items.length
            ? items.map(function(item) {
                return '<tr class="text-sm"><td class="px-4 py-2">' + (item.product_name || '--') + '</td><td class="px-4 py-2">' + (item.quantity || 1) + '</td><td class="px-4 py-2 text-right font-semibold">' + currency.format((item.price || 0) * (item.quantity || 1)) + '</td></tr>';
            }).join('')
            : '<tr><td class="px-4 py-6 text-center text-sm text-slate-400" colspan="3">No items.</td></tr>';

        // Status update dropdown
        var statusOptions = [
            { value: 'pending_approval', label: 'Pending Approval' },
            { value: 'approved',         label: 'Approved' },
            { value: 'assigned',         label: 'Assigned' },
            { value: 'in_progress',      label: 'In Progress' },
            { value: 'out_for_delivery', label: 'Out for Delivery' },
            { value: 'delivered',        label: 'Delivered' },
            { value: 'completed',        label: 'Completed' },
            { value: 'cancelled',        label: 'Cancelled' }
        ];
        drawerStatusSel.innerHTML = statusOptions.map(function(opt) {
            return '<option value="' + opt.value + '"' + (opt.value === currentDrawerStatus ? ' selected' : '') + '>' + opt.label + '</option>';
        }).join('');
        drawerStatusSave.disabled = true;
    }

    drawerStatusSel.addEventListener('change', function() {
        drawerStatusSave.disabled = drawerStatusSel.value === currentDrawerStatus;
        drawerStatusMsg.textContent = drawerStatusSel.value !== currentDrawerStatus ? 'Unsaved changes' : '';
    });

    drawerStatusSave.addEventListener('click', async function() {
        var newStatus = drawerStatusSel.value;
        if (!currentDrawerOrderId || newStatus === currentDrawerStatus) return;
        try {
            drawerStatusSave.disabled = true;
            drawerStatusMsg.textContent = 'Saving…';
            await window.adminApi.ensureCsrfCookie();
            var res = await window.adminApi.request('/api/admin/orders/' + currentDrawerOrderId + '/tracking-status', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ status: newStatus, note: drawerStatusNote.value || null, override: true })
            });
            var payload = await res.json();
            if (!res.ok) { drawerStatusMsg.textContent = (payload && payload.message) ? payload.message : 'Save failed.'; drawerStatusSave.disabled = false; return; }
            drawerStatusMsg.textContent = 'Status updated!';
            await openDrawer(currentDrawerOrderId);
            loadOrders();
        } catch(e) { drawerStatusMsg.textContent = 'Save failed.'; drawerStatusSave.disabled = false; console.error(e); }
    });

    function closeDrawer() {
        drawer.classList.remove('open');
        backdrop.classList.add('hidden');
        currentDrawerOrderId = null;
    }

    drawerClose.addEventListener('click', closeDrawer);
    backdrop.addEventListener('click', closeDrawer);

    // Filters & controls
    var searchTimer;
    searchInput.addEventListener('input', function() { clearTimeout(searchTimer); searchTimer = setTimeout(function(){ currentPage = 1; loadOrders(); }, 400); });
    statusFilter.addEventListener('change', function() { currentPage = 1; loadOrders(); });
    fromDate.addEventListener('change', function() { currentPage = 1; loadOrders(); });
    toDate.addEventListener('change', function() { currentPage = 1; loadOrders(); });
    refreshBtn.addEventListener('click', function() { loadOrders(); });
    prevBtn.addEventListener('click', function() { if (currentPage > 1) { currentPage--; loadOrders(); } });
    nextBtn.addEventListener('click', function() { currentPage++; loadOrders(); });

    loadOrders();
});
</script>
@endsection
