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
                <p class="mt-3 text-2xl font-semibold text-slate-900 dark:text-white">${{ number_format($todayAmount, 2) }}</p>
                <p class="text-xs text-slate-500">Successful payments received today</p>
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <p class="text-xs uppercase tracking-widest text-slate-400">Pending</p>
                <p class="mt-3 text-2xl font-semibold text-slate-900 dark:text-white">{{ $pendingCount }}</p>
                <p class="text-xs text-slate-500">{{ $khqrPendingCount }} KHQR transaction(s) still waiting</p>
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <p class="text-xs uppercase tracking-widest text-slate-400">Reconciliation</p>
                <p class="mt-3 text-2xl font-semibold text-slate-900 dark:text-white">{{ $reconciliationCount }}</p>
                <p class="text-xs text-slate-500">Payment records that do not match KHQR status</p>
            </div>
        </div>

        <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <div class="flex flex-wrap items-center justify-between gap-3">
                <h3 class="text-sm font-semibold text-slate-900 dark:text-white">Latest Payments</h3>
                <span class="text-xs text-slate-500">{{ $payments->total() }} payment record(s)</span>
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
                            <th class="px-4 py-3">Reconciliation</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-200 text-slate-600 dark:divide-slate-800 dark:text-slate-300">
                        @forelse ($payments as $payment)
                            @php
                                $khqr = $payment->khqrTransaction;
                                $paymentSuccessful = $payment->status === 'success';
                                $khqrSuccessful = $khqr?->status === 'SUCCESS';
                                $reconciliationLabel = 'Not linked';
                                $reconciliationClass = 'bg-slate-100 text-slate-600';

                                if ($khqr) {
                                    if ($paymentSuccessful === $khqrSuccessful) {
                                        $reconciliationLabel = 'Matched';
                                        $reconciliationClass = 'bg-emerald-100 text-emerald-700';
                                    } else {
                                        $reconciliationLabel = 'Mismatch';
                                        $reconciliationClass = 'bg-rose-100 text-rose-700';
                                    }
                                }

                                $statusClass = match ($payment->status) {
                                    'success' => 'bg-emerald-100 text-emerald-700',
                                    'failed' => 'bg-rose-100 text-rose-700',
                                    'processing' => 'bg-amber-100 text-amber-700',
                                    default => 'bg-slate-100 text-slate-600',
                                };
                            @endphp
                            <tr>
                                <td class="px-4 py-3">
                                    <div class="font-medium text-slate-900 dark:text-white">{{ $payment->transaction_id ?: 'Manual payment' }}</div>
                                    <div class="text-xs text-slate-500">
                                        {{ $payment->created_at?->format('Y-m-d H:i') }}
                                    </div>
                                </td>
                                <td class="px-4 py-3">
                                    <div class="font-medium text-slate-900 dark:text-white">{{ $payment->order?->order_number ?: 'N/A' }}</div>
                                    <div class="text-xs text-slate-500">{{ $payment->order?->customer_name ?: 'Unknown customer' }}</div>
                                </td>
                                <td class="px-4 py-3 uppercase">{{ $payment->method }}</td>
                                <td class="px-4 py-3">${{ number_format((float) $payment->amount, 2) }}</td>
                                <td class="px-4 py-3">
                                    <span class="inline-flex rounded-full px-2.5 py-1 text-xs font-semibold {{ $statusClass }}">
                                        {{ strtoupper($payment->status) }}
                                    </span>
                                </td>
                                <td class="px-4 py-3">
                                    <div class="flex flex-col gap-1">
                                        <span class="inline-flex w-fit rounded-full px-2.5 py-1 text-xs font-semibold {{ $reconciliationClass }}">
                                            {{ $reconciliationLabel }}
                                        </span>
                                        @if ($khqr)
                                            <span class="text-xs text-slate-500">
                                                KHQR: {{ $khqr->status }}
                                                @if ($khqr->checked_at)
                                                    • {{ $khqr->checked_at->format('Y-m-d H:i') }}
                                                @endif
                                            </span>
                                        @endif
                                    </div>
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td class="px-4 py-6 text-center text-sm text-slate-500" colspan="6">No payments found.</td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
            @if ($payments->hasPages())
                <div class="mt-4">
                    {{ $payments->links() }}
                </div>
            @endif
        </div>
    </div>
@endsection
