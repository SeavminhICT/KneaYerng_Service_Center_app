@extends('layouts.admin')

@section('title', 'Repairs')
@section('page-title', 'Repairs')

@section('content')
    <div class="space-y-6">
        <div class="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Today repairs</p>
                <div class="mt-4 flex items-end justify-between">
                    <p id="today-repairs" class="text-2xl font-semibold text-slate-900 dark:text-white">--</p>
                    <span class="rounded-full bg-primary-50 px-2 py-1 text-xs font-medium text-primary-700 dark:bg-primary-500/10 dark:text-primary-100">Live</span>
                </div>
                <p class="mt-2 text-xs text-slate-500">New requests logged today.</p>
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Pending approvals</p>
                <div class="mt-4 flex items-end justify-between">
                    <p id="pending-approvals" class="text-2xl font-semibold text-slate-900 dark:text-white">--</p>
                    <span class="rounded-full bg-warning-50 px-2 py-1 text-xs font-medium text-warning-700 dark:bg-warning-500/10 dark:text-warning-100">Needs action</span>
                </div>
                <p class="mt-2 text-xs text-slate-500">Quotes waiting on customer response.</p>
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Payments summary</p>
                <div class="mt-4 flex items-end justify-between">
                    <p id="payment-summary" class="text-2xl font-semibold text-slate-900 dark:text-white">--</p>
                    <span class="rounded-full bg-success-50 px-2 py-1 text-xs font-medium text-success-700 dark:bg-success-500/10 dark:text-success-100">Updated</span>
                </div>
                <p class="mt-2 text-xs text-slate-500">Recent invoice payment activity.</p>
            </div>
        </div>

        <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <div class="flex flex-wrap items-center justify-between gap-3">
                <div class="flex flex-wrap items-center gap-3">
                    <select id="repair-status-filter" class="h-10 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300">
                        <option>All statuses</option>
                        <option>Received</option>
                        <option>Diagnosing</option>
                        <option>Waiting Approval</option>
                        <option>In Repair</option>
                        <option>QC</option>
                        <option>Ready</option>
                        <option>Completed</option>
                    </select>
                    <select id="repair-service-filter" class="h-10 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300">
                        <option>All services</option>
                        <option>Drop Off</option>
                        <option>Pickup</option>
                        <option>On Site</option>
                    </select>
                </div>
                <div class="relative">
                    <input id="repair-search" type="text" placeholder="Search repairs" class="h-10 w-60 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    <svg class="absolute right-3 top-3 h-4 w-4 text-slate-400" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-4.35-4.35m1.6-5.15a7 7 0 11-14 0 7 7 0 0114 0z" />
                    </svg>
                </div>
            </div>

            <div class="mt-5 overflow-x-auto">
                <table class="w-full text-left text-sm">
                    <thead class="text-xs uppercase tracking-widest text-slate-400">
                        <tr>
                            <th class="px-4 py-3">Repair ID</th>
                            <th class="px-4 py-3">Customer</th>
                            <th class="px-4 py-3">Device</th>
                            <th class="px-4 py-3">Appointment</th>
                            <th class="px-4 py-3">Status</th>
                            <th class="px-4 py-3">Technician</th>
                            <th class="px-4 py-3 text-right">Action</th>
                        </tr>
                    </thead>
                    <tbody id="repair-rows" class="divide-y divide-slate-200 text-slate-600 dark:divide-slate-800 dark:text-slate-300"></tbody>
                </table>
            </div>

            <div class="mt-4 flex items-center justify-between text-xs text-slate-500">
                <p id="repair-pagination-info">Loading repairs...</p>
                <div class="flex items-center gap-2">
                    <button id="repair-prev" class="rounded-lg border border-slate-200 px-3 py-1 text-slate-600 dark:border-slate-800 dark:text-slate-300">Previous</button>
                    <button id="repair-next" class="rounded-lg border border-slate-200 bg-slate-100 px-3 py-1 text-slate-900 dark:border-slate-800 dark:bg-slate-900">Next</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var currentPage = 1;
            var searchInput = document.getElementById('repair-search');
            var statusFilter = document.getElementById('repair-status-filter');
            var serviceFilter = document.getElementById('repair-service-filter');
            var prevButton = document.getElementById('repair-prev');
            var nextButton = document.getElementById('repair-next');
            var info = document.getElementById('repair-pagination-info');
            var rows = document.getElementById('repair-rows');

            function normalize(value) {
                return (value || '').toLowerCase().trim().replace(/\s+/g, '_');
            }

            function toTitle(value) {
                return (value || '').replace(/_/g, ' ').replace(/\b\w/g, function (char) { return char.toUpperCase(); });
            }

            async function loadRepairs() {
                await window.adminApi.ensureCsrfCookie();
                var query = new URLSearchParams();
                if (searchInput.value.trim()) {
                    query.set('q', searchInput.value.trim());
                }
                if (normalize(statusFilter.value) && normalize(statusFilter.value) !== 'all_statuses') {
                    query.set('status', normalize(statusFilter.value));
                }
                if (normalize(serviceFilter.value) && normalize(serviceFilter.value) !== 'all_services') {
                    query.set('service_type', normalize(serviceFilter.value));
                }
                query.set('page', currentPage);

                var response = await window.adminApi.request('/api/repairs-' + query.toString());
                if (!response.ok) {
                    rows.innerHTML = '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="7">Unable to load repairs.</td></tr>';
                    return;
                }
                var data = await response.json();
                var list = data.data || [];

                rows.innerHTML = list.map(function (repair) {
                    var appointment = repair.appointment_datetime - new Date(repair.appointment_datetime).toLocaleString() : '-';
                    return `
                        <tr>
                            <td class="px-4 py-3 font-semibold text-slate-900 dark:text-white">#${repair.id}</td>
                            <td class="px-4 py-3">${repair.customer - (repair.customer.name || repair.customer.email || '-') : '-'}</td>
                            <td class="px-4 py-3">${repair.device_model}</td>
                            <td class="px-4 py-3">${appointment}</td>
                            <td class="px-4 py-3">${toTitle(repair.status)}</td>
                            <td class="px-4 py-3">${repair.technician - repair.technician.name : '-'}</td>
                            <td class="px-4 py-3 text-right"><a href="/admin/repairs/${repair.id}" class="text-xs font-semibold text-primary-600">Details</a></td>
                        </tr>
                    `;
                }).join('') || '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="7">No repairs found.</td></tr>';

                info.textContent = 'Showing ' + list.length + ' of ' + (data.meta-.total -- list.length) + ' repairs';
                prevButton.disabled = !data.links-.prev;
                nextButton.disabled = !data.links-.next;

                var todayLabel = new Date().toDateString();
                var todayCount = list.filter(function (repair) {
                    return repair.created_at && new Date(repair.created_at).toDateString() === todayLabel;
                }).length;
                var pendingCount = list.filter(function (repair) {
                    return repair.status === 'waiting_approval';
                }).length;
                document.getElementById('today-repairs').textContent = todayCount;
                document.getElementById('pending-approvals').textContent = pendingCount;
            }

            async function loadInvoiceSummary() {
                var response = await window.adminApi.request('/api/invoices-per_page=20');
                if (!response.ok) {
                    return;
                }
                var data = await response.json();
                var list = data.data || [];
                var paid = list.filter(function (invoice) { return invoice.payment_status === 'paid'; }).length;
                var pending = list.filter(function (invoice) { return invoice.payment_status === 'pending'; }).length;
                document.getElementById('payment-summary').textContent = paid + ' paid / ' + pending + ' pending';
            }

            searchInput.addEventListener('input', function () {
                currentPage = 1;
                loadRepairs();
            });
            statusFilter.addEventListener('change', function () {
                currentPage = 1;
                loadRepairs();
            });
            serviceFilter.addEventListener('change', function () {
                currentPage = 1;
                loadRepairs();
            });
            prevButton.addEventListener('click', function () {
                if (currentPage > 1) {
                    currentPage -= 1;
                    loadRepairs();
                }
            });
            nextButton.addEventListener('click', function () {
                currentPage += 1;
                loadRepairs();
            });

            loadRepairs();
            loadInvoiceSummary();
        });
    </script>
@endsection
