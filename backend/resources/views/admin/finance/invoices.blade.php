@extends('layouts.admin')

@section('title', __('Invoices'))
@section('page-title', __('Invoices'))

@section('content')
    <div class="space-y-6">
        <div>
            <h2 class="text-lg font-semibold text-slate-900 dark:text-white">{{ __('Invoices') }}</h2>
            <p class="text-sm text-slate-500">{{ __('Review repair invoices and payment status.') }}</p>
        </div>

        <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <div class="flex flex-wrap items-center justify-between gap-3">
                <select id="invoice-status-filter" class="h-10 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300">
                    <option>{{ __('All statuses') }}</option>
                    <option>{{ __('Pending') }}</option>
                    <option>{{ __('Paid') }}</option>
                    <option>{{ __('Failed') }}</option>
                </select>
            </div>

            <div class="mt-5 overflow-x-auto">
                <table class="w-full text-left text-sm">
                    <thead class="text-xs uppercase tracking-widest text-slate-400">
                        <tr>
                            <th class="px-4 py-3">{{ __('Invoice') }}</th>
                            <th class="px-4 py-3">{{ __('Repair') }}</th>
                            <th class="px-4 py-3">{{ __('Total') }}</th>
                            <th class="px-4 py-3">{{ __('Status') }}</th>
                            <th class="px-4 py-3">{{ __('Created') }}</th>
                        </tr>
                    </thead>
                    <tbody id="invoice-rows" class="divide-y divide-slate-200 text-slate-600 dark:divide-slate-800 dark:text-slate-300"></tbody>
                </table>
            </div>
        </div>
    </div>

    <script>
        const i18n = {
            unableToLoadInvoices: @json(__('Unable to load invoices.')),
            noInvoicesFound: @json(__('No invoices found.')),
        };

        document.addEventListener('DOMContentLoaded', function () {
            var statusFilter = document.getElementById('invoice-status-filter');
            var rows = document.getElementById('invoice-rows');

            function normalize(value) {
                return (value || '').toLowerCase().trim();
            }

            async function loadInvoices() {
                await window.adminApi.ensureCsrfCookie();
                var query = new URLSearchParams();
                if (normalize(statusFilter.value) && normalize(statusFilter.value) !== 'all statuses') {
                    query.set('payment_status', normalize(statusFilter.value));
                }
                var response = await window.adminApi.request('/api/invoices-' + query.toString());
                if (!response.ok) {
                    rows.innerHTML = '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="5">' + i18n.unableToLoadInvoices + '</td></tr>';
                    return;
                }
                var data = await response.json();
                var list = data.data || [];
                rows.innerHTML = list.map(function (invoice) {
                    return `
                        <tr>
                            <td class="px-4 py-3 font-semibold text-slate-900 dark:text-white">${invoice.invoice_number}</td>
                            <td class="px-4 py-3">#${invoice.repair_id}</td>
                            <td class="px-4 py-3">${new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(invoice.total || 0)}</td>
                            <td class="px-4 py-3">${invoice.payment_status}</td>
                            <td class="px-4 py-3">${invoice.created_at - new Date(invoice.created_at).toLocaleDateString() : '-'}</td>
                        </tr>
                    `;
                }).join('') || ('<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="5">' + i18n.noInvoicesFound + '</td></tr>');
            }

            statusFilter.addEventListener('change', loadInvoices);
            loadInvoices();
        });
    </script>
@endsection
