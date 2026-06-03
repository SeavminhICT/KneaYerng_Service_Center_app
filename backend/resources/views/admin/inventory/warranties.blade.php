@extends('layouts.admin')

@section('title', 'Warranty Tracking')
@section('page-title', 'Warranty Tracking')

@section('content')
<div class="space-y-6">

    {{-- ── Header ── --}}
    <div class="flex flex-wrap items-center justify-between gap-3">
        <div>
            <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Product Warranties</h2>
            <p class="text-sm text-slate-500">Warranties issued to customers for purchased products from the mobile app.</p>
        </div>
        <div class="flex items-center gap-3">
            <span id="stat-active"   class="inline-flex items-center gap-1.5 rounded-full bg-green-50 px-3 py-1 text-xs font-semibold text-green-700 dark:bg-green-500/10 dark:text-green-300">
                <span class="h-1.5 w-1.5 rounded-full bg-green-500"></span> Active: <span id="count-active">--</span>
            </span>
            <span id="stat-expired"  class="inline-flex items-center gap-1.5 rounded-full bg-red-50 px-3 py-1 text-xs font-semibold text-red-700 dark:bg-red-500/10 dark:text-red-300">
                <span class="h-1.5 w-1.5 rounded-full bg-red-500"></span> Expired: <span id="count-expired">--</span>
            </span>
        </div>
    </div>

    {{-- ── Filters ── --}}
    <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
        <div class="flex flex-wrap items-center gap-3">
            <div class="relative flex-1 min-w-[200px]">
                <input id="search-input" type="text" placeholder="Search product or customer email..."
                    class="h-10 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 pr-9 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                <svg class="absolute right-3 top-3 h-4 w-4 text-slate-400" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-4.35-4.35m1.6-5.15a7 7 0 11-14 0 7 7 0 0114 0z"/>
                </svg>
            </div>
            <select id="status-filter"
                class="h-10 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 sm:w-36 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300">
                <option value="">All Statuses</option>
                <option value="active">Active</option>
                <option value="expired">Expired</option>
                <option value="void">Void</option>
            </select>
            <button id="btn-refresh"
                class="inline-flex h-10 w-full items-center justify-center gap-2 rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-600 hover:bg-slate-50 sm:w-auto dark:border-slate-700 dark:bg-slate-800 dark:text-slate-300">
                <svg class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
                </svg>
                Refresh
            </button>
        </div>

        {{-- ── Table ── --}}
        <div class="mt-5 overflow-x-auto">
            <table class="w-full text-left text-sm">
                <thead class="text-xs uppercase tracking-widest text-slate-400">
                    <tr>
                        <th class="px-4 py-3">Product</th>
                        <th class="px-4 py-3">Customer</th>
                        <th class="px-4 py-3">Order</th>
                        <th class="px-4 py-3">Period</th>
                        <th class="px-4 py-3">Start</th>
                        <th class="px-4 py-3">Expires</th>
                        <th class="px-4 py-3">Remaining</th>
                        <th class="px-4 py-3">Status</th>
                        <th class="px-4 py-3 text-right">Action</th>
                    </tr>
                </thead>
                <tbody id="warranty-rows" class="divide-y divide-slate-100 text-slate-600 dark:divide-slate-800 dark:text-slate-300">
                    <tr><td colspan="9" class="px-4 py-8 text-center text-sm text-slate-400">Loading...</td></tr>
                </tbody>
            </table>
        </div>

        {{-- Pagination --}}
        <div id="pagination" class="mt-4 flex items-center justify-between gap-3 text-sm text-slate-500"></div>
    </div>

    {{-- ── Void modal ── --}}
    <div id="void-modal" class="fixed inset-0 z-50 hidden items-center justify-center bg-black/40 backdrop-blur-sm">
        <div class="w-full max-w-md rounded-2xl border border-slate-200 bg-white p-6 shadow-2xl dark:border-slate-800 dark:bg-slate-900">
            <h3 class="text-base font-semibold text-slate-900 dark:text-white">Void Warranty</h3>
            <p class="mt-1 text-sm text-slate-500">This will mark the warranty as void. The customer will no longer see it as active.</p>
            <textarea id="void-notes" rows="3" placeholder="Reason (optional)..."
                class="mt-4 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200"></textarea>
            <div class="mt-4 flex justify-end gap-3">
                <button id="void-cancel" class="rounded-xl border border-slate-200 px-4 py-2 text-sm font-semibold text-slate-600 hover:bg-slate-50 dark:border-slate-700 dark:text-slate-300">Cancel</button>
                <button id="void-confirm" class="rounded-xl bg-red-600 px-4 py-2 text-sm font-semibold text-white hover:bg-red-700">Void Warranty</button>
            </div>
        </div>
    </div>

</div>

<script>
document.addEventListener('DOMContentLoaded', function () {
    var currentPage = 1;
    var voidId = null;

    var searchInput  = document.getElementById('search-input');
    var statusFilter = document.getElementById('status-filter');
    var btnRefresh   = document.getElementById('btn-refresh');
    var rowsEl       = document.getElementById('warranty-rows');
    var pagination   = document.getElementById('pagination');
    var voidModal    = document.getElementById('void-modal');
    var voidNotes    = document.getElementById('void-notes');
    var voidCancel   = document.getElementById('void-cancel');
    var voidConfirm  = document.getElementById('void-confirm');

    function statusBadge(status) {
        var map = {
            active:  'bg-green-50 text-green-700 dark:bg-green-500/10 dark:text-green-300',
            expired: 'bg-red-50 text-red-700 dark:bg-red-500/10 dark:text-red-300',
            void:    'bg-slate-100 text-slate-500 dark:bg-slate-800 dark:text-slate-400',
        };
        return '<span class="inline-flex items-center rounded-full px-2 py-0.5 text-xs font-semibold ' + (map[status] || '') + '">'
            + status.charAt(0).toUpperCase() + status.slice(1) + '</span>';
    }

    function daysBar(pct, days, status) {
        if (status === 'expired' || status === 'void') {
            return '<span class="text-xs text-slate-400">' + (status === 'expired' ? 'Expired' : 'Voided') + '</span>';
        }
        var color = days > 30 ? 'bg-green-500' : days > 7 ? 'bg-yellow-400' : 'bg-red-500';
        return '<div class="flex items-center gap-2">'
            + '<div class="h-1.5 w-20 overflow-hidden rounded-full bg-slate-200 dark:bg-slate-700">'
            + '<div class="h-full rounded-full ' + color + '" style="width:' + Math.min(100, 100 - pct) + '%"></div>'
            + '</div>'
            + '<span class="text-xs font-semibold ' + (days <= 7 ? 'text-red-500' : 'text-slate-700 dark:text-slate-200') + '">' + days + 'd</span>'
            + '</div>';
    }

    async function load() {
        var params = new URLSearchParams({ page: currentPage, per_page: 20 });
        if (statusFilter.value) params.set('status', statusFilter.value);
        if (searchInput.value.trim()) params.set('search', searchInput.value.trim());

        rowsEl.innerHTML = '<tr><td colspan="9" class="px-4 py-8 text-center text-sm text-slate-400">Loading...</td></tr>';

        var res = await window.adminApi.request('/api/admin/product-warranties?' + params);
        if (!res.ok) {
            rowsEl.innerHTML = '<tr><td colspan="9" class="px-4 py-8 text-center text-sm text-red-500">Failed to load warranties.</td></tr>';
            return;
        }
        var json = await res.json();
        var list = json.data || [];
        var meta = json.meta || {};

        if (!list.length) {
            rowsEl.innerHTML = '<tr><td colspan="9" class="px-4 py-8 text-center text-sm text-slate-400">No warranties found.</td></tr>';
            pagination.innerHTML = '';
            return;
        }

        rowsEl.innerHTML = list.map(function (w) {
            var canVoid = w.status === 'active';
            var orderLink = w.order_id
                ? '<a href="/admin/orders/' + w.order_id + '" class="text-xs font-mono text-primary-600 hover:underline dark:text-primary-400">' + (w.order_number || '#' + w.order_id) + '</a>'
                : '—';
            return '<tr class="hover:bg-slate-50 dark:hover:bg-slate-800/40">'
                + '<td class="px-4 py-3"><div class="font-medium text-slate-900 dark:text-white max-w-[160px] truncate" title="' + esc(w.product_name) + '">' + esc(w.product_name) + '</div>'
                + (w.variant_label ? '<div class="text-xs text-slate-400">' + esc(w.variant_label) + '</div>' : '') + '</td>'
                + '<td class="px-4 py-3"><div class="text-xs font-semibold text-slate-800 dark:text-white">' + esc(w.customer_name || '—') + '</div><div class="text-xs text-slate-400">' + esc(w.customer_email || '') + '</div></td>'
                + '<td class="px-4 py-3">' + orderLink + '</td>'
                + '<td class="px-4 py-3 text-xs font-semibold text-slate-700 dark:text-slate-200">' + esc(w.period_label) + '</td>'
                + '<td class="px-4 py-3 text-xs text-slate-500">' + (w.start_date || '—') + '</td>'
                + '<td class="px-4 py-3 text-xs text-slate-500">' + (w.end_date || '—') + '</td>'
                + '<td class="px-4 py-3">' + daysBar(w.progress_percent, w.days_remaining, w.status) + '</td>'
                + '<td class="px-4 py-3">' + statusBadge(w.status) + '</td>'
                + '<td class="px-4 py-3 text-right">'
                + (canVoid ? '<button onclick="openVoid(' + w.id + ')" class="rounded-lg border border-red-200 px-3 py-1 text-xs font-semibold text-red-600 hover:bg-red-50 dark:border-red-900/50 dark:text-red-400">Void</button>' : '<span class="text-xs text-slate-300 dark:text-slate-600">—</span>')
                + '</td>'
                + '</tr>';
        }).join('');

        // Pagination
        if (meta.last_page > 1) {
            pagination.innerHTML = '<span class="text-xs text-slate-500">Page ' + meta.current_page + ' of ' + meta.last_page + ' · ' + meta.total + ' total</span>'
                + '<div class="flex gap-2">'
                + (meta.current_page > 1 ? '<button onclick="goPage(' + (meta.current_page - 1) + ')" class="rounded-lg border border-slate-200 px-3 py-1 text-xs font-semibold text-slate-600 hover:bg-slate-50 dark:border-slate-700">Prev</button>' : '')
                + (meta.current_page < meta.last_page ? '<button onclick="goPage(' + (meta.current_page + 1) + ')" class="rounded-lg border border-slate-200 px-3 py-1 text-xs font-semibold text-slate-600 hover:bg-slate-50 dark:border-slate-700">Next</button>' : '')
                + '</div>';
        } else {
            pagination.innerHTML = '';
        }
    }

    window.goPage = function (page) { currentPage = page; load(); };

    window.openVoid = function (id) {
        voidId = id;
        voidNotes.value = '';
        voidModal.classList.remove('hidden');
        voidModal.classList.add('flex');
    };

    voidCancel.addEventListener('click', function () {
        voidModal.classList.add('hidden');
        voidModal.classList.remove('flex');
    });

    voidConfirm.addEventListener('click', async function () {
        if (!voidId) return;
        await window.adminApi.ensureCsrfCookie();
        var res = await window.adminApi.request('/api/admin/product-warranties/' + voidId + '/void', {
            method: 'PATCH',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ notes: voidNotes.value.trim() || null }),
        });
        voidModal.classList.add('hidden');
        voidModal.classList.remove('flex');
        voidId = null;
        if (res.ok) { load(); loadStats(); }
    });

    async function loadStats() {
        var aRes = await window.adminApi.request('/api/admin/product-warranties?status=active&per_page=1');
        var eRes = await window.adminApi.request('/api/admin/product-warranties?status=expired&per_page=1');
        if (aRes.ok) {
            var d = await aRes.json();
            document.getElementById('count-active').textContent = (d.meta && d.meta.total != null) ? d.meta.total : '—';
        }
        if (eRes.ok) {
            var d = await eRes.json();
            document.getElementById('count-expired').textContent = (d.meta && d.meta.total != null) ? d.meta.total : '—';
        }
    }

    var debounceTimer;
    searchInput.addEventListener('input', function () {
        clearTimeout(debounceTimer);
        debounceTimer = setTimeout(function () { currentPage = 1; load(); }, 400);
    });
    statusFilter.addEventListener('change', function () { currentPage = 1; load(); });
    btnRefresh.addEventListener('click', function () { load(); });

    function esc(s) {
        return String(s || '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
    }

    load();
    loadStats();
});
</script>
@endsection
