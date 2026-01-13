@extends('layouts.admin')

@section('title', 'Revenue Reports')
@section('page-title', 'Revenue Reports')

@section('content')
    <div class="space-y-6">
        <div>
            <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Revenue Reports</h2>
            <p class="text-sm text-slate-500">Summary of repair revenue and payment performance.</p>
        </div>

        <div class="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Total invoiced</p>
                <p id="report-invoiced" class="mt-3 text-2xl font-semibold text-slate-900 dark:text-white">--</p>
                <p class="mt-2 text-xs text-slate-500">Last 30 days</p>
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Payments received</p>
                <p id="report-paid" class="mt-3 text-2xl font-semibold text-slate-900 dark:text-white">--</p>
                <p class="mt-2 text-xs text-slate-500">Last 30 days</p>
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Outstanding balance</p>
                <p id="report-outstanding" class="mt-3 text-2xl font-semibold text-slate-900 dark:text-white">--</p>
                <p class="mt-2 text-xs text-slate-500">Last 30 days</p>
            </div>
        </div>

        <div class="rounded-2xl border border-slate-200 bg-white p-6 text-sm text-slate-500 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            Revenue charts will appear here once invoice data accumulates.
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', async function () {
            await window.adminApi.ensureCsrfCookie();
            var response = await window.adminApi.request('/api/invoices-per_page=50');
            if (!response.ok) {
                return;
            }
            var data = await response.json();
            var list = data.data || [];
            var totalInvoiced = list.reduce(function (sum, invoice) { return sum + (invoice.total || 0); }, 0);
            var totalPaid = list.filter(function (invoice) { return invoice.payment_status === 'paid'; })
                .reduce(function (sum, invoice) { return sum + (invoice.total || 0); }, 0);
            var outstanding = totalInvoiced - totalPaid;

            document.getElementById('report-invoiced').textContent = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(totalInvoiced);
            document.getElementById('report-paid').textContent = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(totalPaid);
            document.getElementById('report-outstanding').textContent = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(outstanding);
        });
    </script>
@endsection
