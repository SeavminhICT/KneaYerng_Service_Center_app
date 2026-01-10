@extends('layouts.admin')

@section('title', 'Payments')
@section('page-title', 'Payments')

@section('content')
    <div class="space-y-6">
        <div>
            <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Payments</h2>
            <p class="text-sm text-slate-500">Monitor incoming transactions and reconciliation status.</p>
        </div>

        <div class="grid gap-6 lg:grid-cols-3">
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <p class="text-xs uppercase tracking-widest text-slate-400">Today</p>
                <p class="mt-3 text-2xl font-semibold text-slate-900 dark:text-white">--</p>
                <p class="text-xs text-slate-500">No data yet</p>
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <p class="text-xs uppercase tracking-widest text-slate-400">Pending</p>
                <p class="mt-3 text-2xl font-semibold text-slate-900 dark:text-white">--</p>
                <p class="text-xs text-slate-500">No data yet</p>
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <p class="text-xs uppercase tracking-widest text-slate-400">Refunds</p>
                <p class="mt-3 text-2xl font-semibold text-slate-900 dark:text-white">--</p>
                <p class="text-xs text-slate-500">No data yet</p>
            </div>
        </div>

        <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <div class="flex flex-wrap items-center justify-between gap-3">
                <h3 class="text-sm font-semibold text-slate-900 dark:text-white">Latest Payments</h3>
                <button class="rounded-xl border border-slate-200 bg-white px-4 py-2 text-sm font-semibold text-slate-600 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300">Export</button>
            </div>
            <div class="mt-4 overflow-x-auto">
                <table class="w-full text-left text-sm">
                    <thead class="text-xs uppercase tracking-widest text-slate-400">
                        <tr>
                            <th class="px-4 py-3">Transaction</th>
                            <th class="px-4 py-3">Order</th>
                            <th class="px-4 py-3">Method</th>
                            <th class="px-4 py-3">Amount</th>
                            <th class="px-4 py-3">Status</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-200 text-slate-600 dark:divide-slate-800 dark:text-slate-300">
                        <tr>
                            <td class="px-4 py-6 text-center text-sm text-slate-500" colspan="5">No payments found.</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
@endsection
