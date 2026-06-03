@extends('layouts.admin')

@section('title', 'Customer – ' . ($customer->name ?: 'Unnamed'))
@section('page-title', 'Customer Detail')

@section('content')
    @php
        $isVerified  = (bool) ($customer->otp_verified_at ?? $customer->email_verified_at);
        $memberSince = $customer->created_at ? $customer->created_at->format('d M Y') : '—';
        $initials    = strtoupper(substr($customer->first_name ?: '?', 0, 1) . substr($customer->last_name ?: '', 0, 1));
    @endphp

    <div class="space-y-6">

        {{-- ── Header ─────────────────────────────────────────────────────── --}}
        <div class="flex flex-wrap items-center justify-between gap-3">
            <a href="{{ route('admin.customers.index') }}"
               class="inline-flex items-center gap-1.5 text-sm font-medium text-slate-500 hover:text-slate-800 dark:hover:text-white">
                <svg class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M15 19l-7-7 7-7"/>
                </svg>
                Back to Customers
            </a>

            <form method="POST"
                  action="{{ route('admin.customers.destroy', $customer->id) }}"
                  onsubmit="return confirm('Delete customer &quot;{{ addslashes($customer->name ?: 'Unnamed') }}&quot;?\nThis action cannot be undone.')">
                @csrf
                @method('DELETE')
                <button type="submit"
                        class="inline-flex items-center gap-2 rounded-xl border border-red-200 bg-white px-4 py-2 text-sm font-semibold text-red-600 shadow-sm hover:bg-red-50 dark:border-red-900/50 dark:bg-slate-900 dark:text-red-400">
                    <svg class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
                    </svg>
                    Delete Customer
                </button>
            </form>
        </div>

        {{-- ── Profile card ─────────────────────────────────────────────── --}}
        <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <div class="flex flex-wrap items-center gap-5">
                {{-- Avatar --}}
                @if ($customer->avatar)
                    <img src="{{ $customer->avatar }}" alt="avatar"
                         class="h-16 w-16 rounded-full object-cover ring-2 ring-slate-200 dark:ring-slate-700">
                @else
                    <div class="flex h-16 w-16 items-center justify-center rounded-full bg-primary-100 text-xl font-bold text-primary-700 dark:bg-primary-500/20 dark:text-primary-300">
                        {{ $initials }}
                    </div>
                @endif

                <div class="flex-1 min-w-0">
                    <h2 class="text-xl font-semibold text-slate-900 dark:text-white">
                        {{ $customer->name ?: 'Unnamed' }}
                    </h2>
                    <p class="mt-0.5 text-sm text-slate-500">Member since {{ $memberSince }}</p>
                </div>

                <span class="inline-flex items-center rounded-full px-3 py-1 text-xs font-semibold
                    {{ $isVerified
                        ? 'bg-green-50 text-green-700 dark:bg-green-500/10 dark:text-green-300'
                        : 'bg-yellow-50 text-yellow-700 dark:bg-yellow-500/10 dark:text-yellow-300' }}">
                    {{ $isVerified ? '✓ Verified' : '⏳ Pending Verification' }}
                </span>
            </div>

            <div class="mt-6 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
                <div>
                    <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Email</p>
                    <p class="mt-1 text-sm text-slate-800 dark:text-slate-200">{{ $customer->email ?? '—' }}</p>
                </div>
                <div>
                    <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Phone</p>
                    <p class="mt-1 text-sm text-slate-800 dark:text-slate-200">{{ $customer->phone ? '+' . ltrim($customer->phone, '+') : '—' }}</p>
                </div>
                <div>
                    <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Customer ID</p>
                    <p class="mt-1 text-sm text-slate-800 dark:text-slate-200">#{{ $customer->id }}</p>
                </div>
            </div>
        </div>

        {{-- ── Stats ────────────────────────────────────────────────────── --}}
        <div class="grid gap-4 sm:grid-cols-3">
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Total Orders</p>
                <p class="mt-3 text-3xl font-bold text-slate-900 dark:text-white">{{ $orders->count() }}</p>
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Total Spent</p>
                <p class="mt-3 text-3xl font-bold text-slate-900 dark:text-white">${{ number_format($totalSpent, 2) }}</p>
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Repair Requests</p>
                <p class="mt-3 text-3xl font-bold text-slate-900 dark:text-white">{{ $repairs->count() }}</p>
            </div>
        </div>

        {{-- ── Orders table ──────────────────────────────────────────────── --}}
        <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <h3 class="mb-4 text-sm font-semibold text-slate-700 dark:text-slate-200">Recent Orders</h3>
            <div class="overflow-x-auto">
                <table class="w-full text-left text-sm">
                    <thead class="text-xs uppercase tracking-widest text-slate-400">
                        <tr>
                            <th class="px-4 py-3">Order #</th>
                            <th class="px-4 py-3">Amount</th>
                            <th class="px-4 py-3">Status</th>
                            <th class="px-4 py-3">Payment</th>
                            <th class="px-4 py-3">Date</th>
                            <th class="px-4 py-3 text-right">Action</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100 text-slate-600 dark:divide-slate-800 dark:text-slate-300">
                        @forelse ($orders as $order)
                            <tr class="hover:bg-slate-50 dark:hover:bg-slate-800/40">
                                <td class="px-4 py-3 font-mono text-xs text-slate-700 dark:text-slate-200">
                                    {{ $order->order_number ?? '#' . $order->id }}
                                </td>
                                <td class="px-4 py-3">${{ number_format((float) $order->total_amount, 2) }}</td>
                                <td class="px-4 py-3">
                                    <span class="inline-flex items-center rounded-full px-2 py-1 text-xs font-semibold bg-slate-100 text-slate-700 dark:bg-slate-800 dark:text-slate-300">
                                        {{ ucfirst(str_replace('_', ' ', $order->status ?? 'unknown')) }}
                                    </span>
                                </td>
                                <td class="px-4 py-3">
                                    @php $paid = ($order->payment_status ?? '') === 'paid'; @endphp
                                    <span class="inline-flex items-center rounded-full px-2 py-1 text-xs font-semibold
                                        {{ $paid ? 'bg-green-50 text-green-700 dark:bg-green-500/10 dark:text-green-300' : 'bg-yellow-50 text-yellow-700 dark:bg-yellow-500/10 dark:text-yellow-300' }}">
                                        {{ $paid ? 'Paid' : ucfirst($order->payment_status ?? 'Unpaid') }}
                                    </span>
                                </td>
                                <td class="px-4 py-3 text-xs text-slate-500">{{ $order->created_at?->format('d M Y') }}</td>
                                <td class="px-4 py-3 text-right">
                                    <a href="{{ route('admin.orders.show', $order->id) }}"
                                       class="text-xs font-semibold text-primary-600 hover:underline dark:text-primary-400">
                                        View
                                    </a>
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="6" class="px-4 py-6 text-center text-sm text-slate-400">No orders yet.</td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>

        {{-- ── Repairs table ─────────────────────────────────────────────── --}}
        <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <h3 class="mb-4 text-sm font-semibold text-slate-700 dark:text-slate-200">Repair Requests</h3>
            <div class="overflow-x-auto">
                <table class="w-full text-left text-sm">
                    <thead class="text-xs uppercase tracking-widest text-slate-400">
                        <tr>
                            <th class="px-4 py-3">Ticket #</th>
                            <th class="px-4 py-3">Device</th>
                            <th class="px-4 py-3">Status</th>
                            <th class="px-4 py-3">Date</th>
                            <th class="px-4 py-3 text-right">Action</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100 text-slate-600 dark:divide-slate-800 dark:text-slate-300">
                        @forelse ($repairs as $repair)
                            <tr class="hover:bg-slate-50 dark:hover:bg-slate-800/40">
                                <td class="px-4 py-3 font-mono text-xs text-slate-700 dark:text-slate-200">#{{ $repair->id }}</td>
                                <td class="px-4 py-3">{{ $repair->device_name ?? $repair->device_model ?? '—' }}</td>
                                <td class="px-4 py-3">
                                    <span class="inline-flex items-center rounded-full px-2 py-1 text-xs font-semibold bg-slate-100 text-slate-700 dark:bg-slate-800 dark:text-slate-300">
                                        {{ ucfirst(str_replace('_', ' ', $repair->status ?? 'unknown')) }}
                                    </span>
                                </td>
                                <td class="px-4 py-3 text-xs text-slate-500">{{ $repair->created_at?->format('d M Y') }}</td>
                                <td class="px-4 py-3 text-right">
                                    <a href="{{ route('admin.repairs.show', $repair->id) }}"
                                       class="text-xs font-semibold text-primary-600 hover:underline dark:text-primary-400">
                                        View
                                    </a>
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="5" class="px-4 py-6 text-center text-sm text-slate-400">No repair requests yet.</td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>

    </div>
@endsection
