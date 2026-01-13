@extends('layouts.admin')

@section('title', 'Payments')
@section('page-title', 'Payments')

@section('content')
    <div class="space-y-6">
        <div>
            <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Repair Payments</h2>
            <p class="text-sm text-slate-500">Track deposits and final payments per invoice.</p>
        </div>

        <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <div class="flex flex-wrap items-center justify-between gap-3">
                <select id="payment-status-filter" class="h-10 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300">
                    <option>All statuses</option>
                    <option>Pending</option>
                    <option>Paid</option>
                    <option>Failed</option>
                </select>
            </div>

            <div class="mt-5 overflow-x-auto">
                <table class="w-full text-left text-sm">
                    <thead class="text-xs uppercase tracking-widest text-slate-400">
                        <tr>
                            <th class="px-4 py-3">Invoice</th>
                            <th class="px-4 py-3">Type</th>
                            <th class="px-4 py-3">Method</th>
                            <th class="px-4 py-3">Amount</th>
                            <th class="px-4 py-3">Status</th>
                            <th class="px-4 py-3">Date</th>
                        </tr>
                    </thead>
                    <tbody id="payment-rows" class="divide-y divide-slate-200 text-slate-600 dark:divide-slate-800 dark:text-slate-300"></tbody>
                </table>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var statusFilter = document.getElementById('payment-status-filter');
            var rows = document.getElementById('payment-rows');

            function normalize(value) {
                return (value || '').toLowerCase().trim();
            }

            async function loadPayments() {
                await window.adminApi.ensureCsrfCookie();
                var query = new URLSearchParams();
                if (normalize(statusFilter.value) && normalize(statusFilter.value) !== 'all statuses') {
                    query.set('status', normalize(statusFilter.value));
                }
                var response = await window.adminApi.request('/api/repair-payments-' + query.toString());
                if (!response.ok) {
                    rows.innerHTML = '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="6">Unable to load payments.</td></tr>';
                    return;
                }
                var data = await response.json();
                var list = data.data || [];
                rows.innerHTML = list.map(function (payment) {
                    return `
                        <tr>
                            <td class="px-4 py-3 font-semibold text-slate-900 dark:text-white">#${payment.invoice_id}</td>
                            <td class="px-4 py-3">${payment.type}</td>
                            <td class="px-4 py-3">${payment.method}</td>
                            <td class="px-4 py-3">${new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(payment.amount || 0)}</td>
                            <td class="px-4 py-3">${payment.status}</td>
                            <td class="px-4 py-3">${payment.created_at - new Date(payment.created_at).toLocaleDateString() : '-'}</td>
                        </tr>
                    `;
                }).join('') || '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="6">No payments found.</td></tr>';
            }

            statusFilter.addEventListener('change', loadPayments);
            loadPayments();
        });
    </script>
@endsection
