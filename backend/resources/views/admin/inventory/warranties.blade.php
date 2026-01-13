@extends('layouts.admin')

@section('title', 'Warranty Records')
@section('page-title', 'Warranty Records')

@section('content')
    <div class="space-y-6">
        <div>
            <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Warranty Tracking</h2>
            <p class="text-sm text-slate-500">Monitor coverage status and expiry dates.</p>
        </div>

        <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <div class="flex flex-wrap items-center justify-between gap-3">
                <select id="warranty-status-filter" class="h-10 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300">
                    <option>All statuses</option>
                    <option>Active</option>
                    <option>Expired</option>
                </select>
            </div>

            <div class="mt-5 overflow-x-auto">
                <table class="w-full text-left text-sm">
                    <thead class="text-xs uppercase tracking-widest text-slate-400">
                        <tr>
                            <th class="px-4 py-3">Repair ID</th>
                            <th class="px-4 py-3">Duration</th>
                            <th class="px-4 py-3">Start</th>
                            <th class="px-4 py-3">End</th>
                            <th class="px-4 py-3">Status</th>
                        </tr>
                    </thead>
                    <tbody id="warranty-rows" class="divide-y divide-slate-200 text-slate-600 dark:divide-slate-800 dark:text-slate-300"></tbody>
                </table>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var statusFilter = document.getElementById('warranty-status-filter');
            var rows = document.getElementById('warranty-rows');

            function normalize(value) {
                return (value || '').toLowerCase().trim();
            }

            async function loadWarranties() {
                await window.adminApi.ensureCsrfCookie();
                var query = new URLSearchParams();
                if (normalize(statusFilter.value) && normalize(statusFilter.value) !== 'all statuses') {
                    query.set('status', normalize(statusFilter.value));
                }
                var response = await window.adminApi.request('/api/warranties-' + query.toString());
                if (!response.ok) {
                    rows.innerHTML = '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="5">Unable to load warranties.</td></tr>';
                    return;
                }
                var data = await response.json();
                var list = data.data || [];
                rows.innerHTML = list.map(function (warranty) {
                    return `
                        <tr>
                            <td class="px-4 py-3 font-semibold text-slate-900 dark:text-white">#${warranty.repair_id}</td>
                            <td class="px-4 py-3">${warranty.duration_days || '-'} days</td>
                            <td class="px-4 py-3">${warranty.start_date || '-'}</td>
                            <td class="px-4 py-3">${warranty.end_date || '-'}</td>
                            <td class="px-4 py-3">${warranty.status}</td>
                        </tr>
                    `;
                }).join('') || '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="5">No warranties found.</td></tr>';
            }

            statusFilter.addEventListener('change', loadWarranties);
            loadWarranties();
        });
    </script>
@endsection
