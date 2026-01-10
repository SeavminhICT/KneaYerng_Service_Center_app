@extends('layouts.admin')

@section('title', 'Reports')
@section('page-title', 'Reports')

@section('content')
    <div class="space-y-6">
        <div>
            <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Reports</h2>
            <p class="text-sm text-slate-500">Generate insights for sales, inventory, and customer activity.</p>
        </div>

        <div class="grid gap-6 lg:grid-cols-3">
            <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <h3 class="text-sm font-semibold text-slate-900 dark:text-white">Sales Report</h3>
                <p class="mt-2 text-xs text-slate-500">Weekly, monthly, quarterly summaries.</p>
                <button class="mt-4 w-full rounded-xl bg-primary-600 px-4 py-2 text-sm font-semibold text-white">Generate</button>
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <h3 class="text-sm font-semibold text-slate-900 dark:text-white">Inventory Report</h3>
                <p class="mt-2 text-xs text-slate-500">Stock movement and low stock alerts.</p>
                <button class="mt-4 w-full rounded-xl border border-slate-200 bg-white px-4 py-2 text-sm font-semibold text-slate-600 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300">Generate</button>
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <h3 class="text-sm font-semibold text-slate-900 dark:text-white">Customer Report</h3>
                <p class="mt-2 text-xs text-slate-500">Retention, lifetime value, churn.</p>
                <button class="mt-4 w-full rounded-xl border border-slate-200 bg-white px-4 py-2 text-sm font-semibold text-slate-600 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300">Generate</button>
            </div>
        </div>

        <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <h3 class="text-sm font-semibold text-slate-900 dark:text-white">Recent Exports</h3>
            <div class="mt-4 space-y-3 text-sm text-slate-600 dark:text-slate-300">
                <p class="text-xs text-slate-500">No exports generated yet.</p>
            </div>
        </div>
    </div>
@endsection
