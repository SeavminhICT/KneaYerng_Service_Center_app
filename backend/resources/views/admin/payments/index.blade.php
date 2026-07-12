@extends('layouts.admin')

@section('title', __('Payments'))
@section('page-title', __('Payments'))

@section('content')
    <div class="space-y-6">
        <div>
            <h2 class="text-lg font-semibold text-slate-900 dark:text-white">{{ __('Payments') }}</h2>
            <p class="text-sm text-slate-500">{{ __('Monitor incoming transactions and reconciliation status.') }}</p>
        </div>

        <div class="grid gap-6 lg:grid-cols-3">
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <p class="text-xs uppercase tracking-widest text-slate-400">{{ __('Today') }}</p>
                <p class="mt-3 text-2xl font-semibold text-slate-900 dark:text-white">${{ number_format($todayAmount, 2) }}</p>
                <p class="text-xs text-slate-500">{{ __('Successful payments received today') }}</p>
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <p class="text-xs uppercase tracking-widest text-slate-400">{{ __('Pending') }}</p>
                <p class="mt-3 text-2xl font-semibold text-slate-900 dark:text-white">{{ $pendingCount }}</p>
                <p class="text-xs text-slate-500">{{ __(':count KHQR transaction(s) still waiting', ['count' => $khqrPendingCount]) }}</p>
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <p class="text-xs uppercase tracking-widest text-slate-400">{{ __('Reconciliation') }}</p>
                <p class="mt-3 text-2xl font-semibold text-slate-900 dark:text-white">{{ $reconciliationCount }}</p>
                <p class="text-xs text-slate-500">{{ __('Payment records that do not match KHQR status') }}</p>
            </div>
        </div>

        <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <div class="flex flex-wrap items-center justify-between gap-3">
                <h3 class="text-sm font-semibold text-slate-900 dark:text-white">{{ __('Latest Payments') }}</h3>
                <span class="text-xs text-slate-500">{{ __(':count payment record(s)', ['count' => $payments->total()]) }}</span>
            </div>
            <div class="mt-4 overflow-x-auto">
                <table class="w-full text-left text-sm">
                    <thead class="text-xs uppercase tracking-widest text-slate-400">
                        <tr>
                            <th class="px-4 py-3">{{ __('Transaction') }}</th>
                            <th class="px-4 py-3">{{ __('Order') }}</th>
                            <th class="px-4 py-3">{{ __('Method') }}</th>
                            <th class="px-4 py-3">{{ __('Amount') }}</th>
                            <th class="px-4 py-3">{{ __('Status') }}</th>
                            <th class="px-4 py-3">{{ __('Reconciliation') }}</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-200 text-slate-600 dark:divide-slate-800 dark:text-slate-300">
                        @forelse ($payments as $payment)
                            @php
                                $khqr = $payment->khqrTransaction;
                                $paymentSuccessful = $payment->status === 'success';
                                $khqrSuccessful = $khqr?->status === 'SUCCESS';
                                $reconciliationLabel = __('Not linked');
                                $reconciliationClass = 'bg-slate-100 text-slate-600';

                                if ($khqr) {
                                    if ($paymentSuccessful === $khqrSuccessful) {
                                        $reconciliationLabel = __('Matched');
                                        $reconciliationClass = 'bg-emerald-100 text-emerald-700';
                                    } else {
                                        $reconciliationLabel = __('Mismatch');
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
                                    <div class="font-medium text-slate-900 dark:text-white">{{ $payment->transaction_id ?: __('Manual payment') }}</div>
                                    <div class="text-xs text-slate-500">
                                        {{ $payment->created_at?->format('Y-m-d H:i') }}
                                    </div>
                                </td>
                                <td class="px-4 py-3">
                                    <div class="font-medium text-slate-900 dark:text-white">{{ $payment->order?->order_number ?: __('N/A') }}</div>
                                    <div class="text-xs text-slate-500">{{ $payment->order?->customer_name ?: __('Unknown customer') }}</div>
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
                                                {{ __('KHQR') }}: {{ $khqr->status }}
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
                                <td class="px-4 py-6 text-center text-sm text-slate-500" colspan="6">{{ __('No payments found.') }}</td>
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
