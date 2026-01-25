@extends('layouts.admin')

@section('title', 'Customers')
@section('page-title', 'Customers')

@section('content')
    <div class="space-y-6">
        <div class="flex flex-wrap items-center justify-between gap-3">
            <div>
                <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Customer List</h2>
                <p class="text-sm text-slate-500">Track active users and customer segments.</p>
            </div>
            <span class="inline-flex items-center rounded-full bg-primary-50 px-3 py-1 text-xs font-semibold text-primary-700 dark:bg-primary-500/10 dark:text-primary-100">
                Total: {{ $customersCount ?? 0 }}
            </span>
        </div>

        <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <div class="flex flex-wrap items-center justify-between gap-3">
                <div class="relative">
                    <input type="text" placeholder="Search customers" class="h-10 w-60 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    <svg class="absolute right-3 top-3 h-4 w-4 text-slate-400" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-4.35-4.35m1.6-5.15a7 7 0 11-14 0 7 7 0 0114 0z" />
                    </svg>
                </div>
                <div class="flex items-center gap-3">
                    <select class="h-10 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300">
                        <option>Segment</option>
                        <option>VIP</option>
                        <option>New</option>
                        <option>Inactive</option>
                    </select>
                </div>
            </div>

            <div class="mt-5 overflow-x-auto">
                <table class="w-full text-left text-sm">
                    <thead class="text-xs uppercase tracking-widest text-slate-400">
                        <tr>
                            <th class="px-4 py-3">Name</th>
                            <th class="px-4 py-3">Email</th>
                            <th class="px-4 py-3">Orders</th>
                            <th class="px-4 py-3">Spent</th>
                            <th class="px-4 py-3">Status</th>
                            <th class="px-4 py-3 text-right">Action</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-200 text-slate-600 dark:divide-slate-800 dark:text-slate-300">
                        @forelse ($customers ?? [] as $customer)
                            @php
                                $isVerified = (bool) ($customer->otp_verified_at ?? $customer->email_verified_at);
                                $spentTotal = (float) ($customer->orders_sum_total_amount ?? 0);
                            @endphp
                            <tr>
                                <td class="px-4 py-3 font-medium text-slate-900 dark:text-white">{{ $customer->name ?: 'Unnamed' }}</td>
                                <td class="px-4 py-3">{{ $customer->email }}</td>
                                <td class="px-4 py-3">{{ $customer->orders_count ?? 0 }}</td>
                                <td class="px-4 py-3">${{ number_format($spentTotal, 2) }}</td>
                                <td class="px-4 py-3">
                                    <span class="inline-flex items-center rounded-full px-2 py-1 text-xs font-semibold {{ $isVerified ? 'bg-success-50 text-success-700 dark:bg-success-500/10 dark:text-success-100' : 'bg-warning-50 text-warning-700 dark:bg-warning-500/10 dark:text-warning-100' }}">
                                        {{ $isVerified ? 'Verified' : 'Pending' }}
                                    </span>
                                </td>
                                <td class="px-4 py-3 text-right">-</td>
                            </tr>
                        @empty
                            <tr>
                                <td class="px-4 py-6 text-center text-sm text-slate-500" colspan="6">No customer data yet.</td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>
    </div>
@endsection
