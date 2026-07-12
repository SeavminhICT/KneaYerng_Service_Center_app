@extends('layouts.admin')

@section('title', __('Customers'))
@section('page-title', __('Customers'))

@section('content')
    <div class="space-y-6">
        @if (session('success'))
            <div class="flex items-center gap-3 rounded-xl border border-green-200 bg-green-50 px-4 py-3 text-sm font-medium text-green-700 dark:border-green-800/40 dark:bg-green-900/20 dark:text-green-300">
                <svg class="h-4 w-4 shrink-0" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/></svg>
                {{ session('success') }}
            </div>
        @endif

        <div class="flex flex-wrap items-center justify-between gap-3">
            <div>
                <h2 class="text-lg font-semibold text-slate-900 dark:text-white">{{ __('Customer List') }}</h2>
                <p class="text-sm text-slate-500">{{ __('Track active users and customer segments.') }}</p>
            </div>
            <span class="inline-flex items-center rounded-full bg-primary-50 px-3 py-1 text-xs font-semibold text-primary-700 dark:bg-primary-500/10 dark:text-primary-100">
                {{ __('Total') }}: {{ $customersCount ?? 0 }}
            </span>
        </div>

        <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <form method="GET" action="{{ route('admin.customers.index') }}" id="customer-filter-form">
            <div class="flex flex-wrap items-center justify-between gap-3">
                <div class="relative">
                    <input type="text" name="search" value="{{ request('search') }}"
                           placeholder="{{ __('Search customers') }}"
                           class="h-10 w-60 rounded-xl border border-slate-200 bg-slate-50 px-3 pr-9 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200"
                           oninput="clearTimeout(this._t); this._t = setTimeout(() => document.getElementById('customer-filter-form').submit(), 400)" />
                    <svg class="absolute right-3 top-3 h-4 w-4 text-slate-400" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-4.35-4.35m1.6-5.15a7 7 0 11-14 0 7 7 0 0114 0z" />
                    </svg>
                </div>
                <div class="flex items-center gap-3">
                    <select name="segment" id="segment-filter"
                            onchange="document.getElementById('customer-filter-form').submit()"
                            class="h-10 w-36 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300">
                        <option value="">{{ __('Segment') }}</option>
                        <option value="vip"    {{ request('segment') === 'vip'      ? 'selected' : '' }}>{{ __('VIP') }}</option>
                        <option value="new"    {{ request('segment') === 'new'      ? 'selected' : '' }}>{{ __('New') }}</option>
                        <option value="inactive" {{ request('segment') === 'inactive' ? 'selected' : '' }}>{{ __('Inactive') }}</option>
                    </select>
                    @if(request('search') || request('segment'))
                        <a href="{{ route('admin.customers.index') }}"
                           class="inline-flex items-center gap-1 rounded-xl border border-slate-200 bg-slate-50 px-3 h-10 text-xs font-semibold text-slate-500 hover:bg-slate-100 dark:border-slate-700 dark:bg-slate-800 dark:text-slate-400 dark:hover:bg-slate-700">
                            <svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"/>
                            </svg>
                            {{ __('Clear') }}
                        </a>
                    @endif
                </div>
            </div>
            </form>

            <div class="mt-5 overflow-x-auto">
                <table class="w-full text-left text-sm">
                    <thead class="text-xs uppercase tracking-widest text-slate-400">
                        <tr>
                            <th class="px-4 py-3">{{ __('Name') }}</th>
                            <th class="px-4 py-3">{{ __('Email') }}</th>
                            <th class="px-4 py-3">{{ __('Orders') }}</th>
                            <th class="px-4 py-3">{{ __('Spent') }}</th>
                            <th class="px-4 py-3">{{ __('Status') }}</th>
                            <th class="px-4 py-3 text-right">{{ __('Action') }}</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-200 text-slate-600 dark:divide-slate-800 dark:text-slate-300">
                        @forelse ($customers ?? [] as $customer)
                            @php
                                $isVerified = (bool) ($customer->otp_verified_at ?? $customer->email_verified_at);
                                $spentTotal = (float) ($customer->orders_sum_total_amount ?? 0);
                            @endphp
                            <tr class="hover:bg-slate-50 dark:hover:bg-slate-800/40">
                                <td class="px-4 py-3">
                                    <div class="flex items-center gap-3">
                                        <div class="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-primary-100 text-xs font-bold text-primary-700 dark:bg-primary-500/20 dark:text-primary-300">
                                            {{ strtoupper(substr($customer->first_name ?: '?', 0, 1)) }}
                                        </div>
                                        <span class="font-medium text-slate-900 dark:text-white">{{ $customer->name ?: __('Unnamed') }}</span>
                                    </div>
                                </td>
                                <td class="px-4 py-3">{{ $customer->email ?? '—' }}</td>
                                <td class="px-4 py-3">{{ $customer->orders_count ?? 0 }}</td>
                                <td class="px-4 py-3">${{ number_format($spentTotal, 2) }}</td>
                                <td class="px-4 py-3">
                                    <span class="inline-flex items-center rounded-full px-2 py-1 text-xs font-semibold {{ $isVerified ? 'bg-success-50 text-success-700 dark:bg-success-500/10 dark:text-success-100' : 'bg-warning-50 text-warning-700 dark:bg-warning-500/10 dark:text-warning-100' }}">
                                        {{ $isVerified ? __('Verified') : __('Pending') }}
                                    </span>
                                </td>
                                <td class="px-4 py-3 text-right">
                                    <div class="flex items-center justify-end gap-2">
                                        {{-- View --}}
                                        <a href="{{ route('admin.customers.show', $customer->id) }}"
                                           class="inline-flex items-center gap-1 rounded-lg border border-slate-200 bg-white px-3 py-1.5 text-xs font-semibold text-slate-600 shadow-sm hover:bg-slate-50 dark:border-slate-700 dark:bg-slate-800 dark:text-slate-300 dark:hover:bg-slate-700">
                                            <svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 010-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.964-7.178z"/>
                                                <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                                            </svg>
                                            {{ __('View') }}
                                        </a>
                                        {{-- Delete --}}
                                        @if (auth()->user()?->hasPermission('delete_customer'))
                                        <form method="POST"
                                              action="{{ route('admin.customers.destroy', $customer->id) }}"
                                              class="delete-customer-form">
                                            @csrf
                                            @method('DELETE')
                                            <button type="button"
                                                    data-customer-name="{{ addslashes($customer->name ?: __('Unnamed')) }}"
                                                    onclick="confirmDeleteCustomer(this)"
                                                    class="inline-flex items-center gap-1 rounded-lg border border-red-200 bg-white px-3 py-1.5 text-xs font-semibold text-red-600 shadow-sm hover:bg-red-50 dark:border-red-900/50 dark:bg-slate-800 dark:text-red-400 dark:hover:bg-red-900/20">
                                                <svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
                                                </svg>
                                                {{ __('Delete') }}
                                            </button>
                                        </form>
                                        @endif
                                    </div>
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td class="px-4 py-6 text-center text-sm text-slate-500" colspan="6">{{ __('No customer data yet.') }}</td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>
    </div>
@endsection

@push('scripts')
<script>
    function confirmDeleteCustomer(btn) {
        var customerName = btn.getAttribute('data-customer-name') || '{{ __('this customer') }}';
        var form = btn.closest('form');

        Swal.fire({
            icon: 'warning',
            title: '{{ __('Delete Customer?') }}',
            html: '{{ __('You are about to delete') }} <strong>' + customerName + '</strong>.<br>{{ __('This action cannot be undone.') }}',
            showCancelButton: true,
            confirmButtonColor: '#dc2626',
            cancelButtonColor: '#64748b',
            confirmButtonText: '<svg xmlns="http://www.w3.org/2000/svg" class="inline-block h-4 w-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg> {{ __('Yes, Delete') }}',
            cancelButtonText: '{{ __('Cancel') }}',
            focusCancel: true,
            customClass: {
                confirmButton: 'swal-confirm-btn',
                cancelButton: 'swal-cancel-btn',
            },
        }).then(function (result) {
            if (result.isConfirmed) {
                form.submit();
            }
        });
    }
</script>
@endpush
