@extends('layouts.admin')

@section('title', 'Vouchers')
@section('page-title', 'Vouchers')

@section('content')
    <div class="space-y-6">
        <div class="flex flex-wrap items-center justify-between gap-4">
            <div>
                <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Voucher List</h2>
                <p class="text-sm text-slate-500">Create and manage discount vouchers for the store.</p>
            </div>
            <div class="flex items-center gap-3">
                <a href="{{ route('admin.vouchers.create') }}" class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white shadow-sm">Add Voucher</a>
            </div>
        </div>

        <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <div class="flex flex-wrap items-center justify-between gap-3">
                <div class="flex flex-wrap items-center gap-3">
                    <select class="h-10 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300">
                        <option>Bulk actions</option>
                        <option>Activate</option>
                        <option>Deactivate</option>
                        <option>Delete</option>
                    </select>
                    <button class="h-10 rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-600 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300">Apply</button>
                </div>
                <div class="relative">
                    <input type="text" placeholder="Search vouchers" class="h-10 w-60 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    <svg class="absolute right-3 top-3 h-4 w-4 text-slate-400" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-4.35-4.35m1.6-5.15a7 7 0 11-14 0 7 7 0 0114 0z" />
                    </svg>
                </div>
            </div>

            <div class="mt-5 overflow-x-auto">
                <table class="w-full text-left text-sm">
                    <thead class="text-xs uppercase tracking-widest text-slate-400">
                        <tr>
                            <th class="px-4 py-3"><input type="checkbox" class="rounded border-slate-300 text-primary-600 focus:ring-primary-500" /></th>
                            <th class="px-4 py-3">Code</th>
                            <th class="px-4 py-3">Discount</th>
                            <th class="px-4 py-3">Min Order</th>
                            <th class="px-4 py-3">Validity</th>
                            <th class="px-4 py-3">Usage</th>
                            <th class="px-4 py-3">Status</th>
                            <th class="px-4 py-3 text-right">Action</th>
                        </tr>
                    </thead>
                    <tbody id="voucher-rows" class="divide-y divide-slate-200 text-slate-600 dark:divide-slate-800 dark:text-slate-300"></tbody>
                </table>
            </div>

            <div class="mt-4 flex items-center justify-between text-xs text-slate-500">
                <p id="voucher-pagination-info">Loading vouchers...</p>
                <div class="flex items-center gap-2">
                    <button id="voucher-prev" class="rounded-lg border border-slate-200 px-3 py-1 text-slate-600 dark:border-slate-800 dark:text-slate-300">Previous</button>
                    <button id="voucher-next" class="rounded-lg border border-slate-200 bg-slate-100 px-3 py-1 text-slate-900 dark:border-slate-800 dark:bg-slate-900">Next</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var currentPage = 1;
            var currentQuery = '';

            var searchInput = document.querySelector('input[placeholder="Search vouchers"]');
            var prevButton = document.getElementById('voucher-prev');
            var nextButton = document.getElementById('voucher-next');
            var info = document.getElementById('voucher-pagination-info');
            var rows = document.getElementById('voucher-rows');

            function statusBadge(status) {
                var map = {
                    active: 'bg-success-50 text-success-700 dark:bg-success-500/10 dark:text-success-100',
                    inactive: 'bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-300',
                };
                var klass = map[status] || map.inactive;
                return '<span class="rounded-full px-2 py-1 text-xs font-semibold ' + klass + '">' + status + '</span>';
            }

            function formatCurrency(value) {
                return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(value || 0);
            }

            function formatDiscount(voucher) {
                if (!voucher) {
                    return '--';
                }
                if (voucher.discount_type === 'percent') {
                    return (voucher.discount_value || 0) + '%';
                }
                return formatCurrency(voucher.discount_value || 0);
            }

            function formatDate(value) {
                if (!value) {
                    return '--';
                }
                var date = new Date(value);
                if (Number.isNaN(date.getTime())) {
                    return '--';
                }
                return date.toLocaleDateString();
            }

            function formatValidity(voucher) {
                var start = formatDate(voucher.starts_at);
                var end = formatDate(voucher.expires_at);
                if (start === '--' && end === '--') {
                    return 'Always';
                }
                if (start !== '--' && end !== '--') {
                    return start + ' - ' + end;
                }
                if (start !== '--') {
                    return 'From ' + start;
                }
                return 'Until ' + end;
            }

            function formatUsage(voucher) {
                var used = voucher.redemptions_count || 0;
                if (voucher.usage_limit_total) {
                    return used + ' / ' + voucher.usage_limit_total;
                }
                return used + ' / No limit';
            }

            async function loadVouchers() {
                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/vouchers?q=' + encodeURIComponent(currentQuery) + '&page=' + currentPage);
                if (!response.ok) {
                    rows.innerHTML = '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="8">Unable to load vouchers.</td></tr>';
                    return;
                }
                var data = await response.json();
                var list = data.data || [];

                rows.innerHTML = list.map(function (voucher) {
                    var statusLabel = voucher.is_active ? 'active' : 'inactive';
                    return `
                        <tr>
                            <td class="px-4 py-3"><input type="checkbox" class="rounded border-slate-300 text-primary-600 focus:ring-primary-500" /></td>
                            <td class="px-4 py-3">
                                <div>
                                    <p class="font-semibold text-slate-900 dark:text-white">${voucher.code || '--'}</p>
                                    <p class="text-xs text-slate-500">${voucher.name || 'Unnamed voucher'}</p>
                                </div>
                            </td>
                            <td class="px-4 py-3">${formatDiscount(voucher)}</td>
                            <td class="px-4 py-3">${formatCurrency(voucher.min_order_amount || 0)}</td>
                            <td class="px-4 py-3">${formatValidity(voucher)}</td>
                            <td class="px-4 py-3">${formatUsage(voucher)}</td>
                            <td class="px-4 py-3">${statusBadge(statusLabel)}</td>
                            <td class="px-4 py-3 text-right">
                                <div class="inline-flex items-center justify-end gap-3">
                                    <button data-id="${voucher.id}" class="text-xs font-semibold text-slate-500 js-view-voucher">View</button>
                                    <a href="/admin/vouchers/${voucher.id}/edit" class="text-xs font-semibold text-primary-600">Edit</a>
                                    <button data-id="${voucher.id}" data-active="${voucher.is_active ? '1' : '0'}" class="text-xs font-semibold text-slate-500 js-toggle-voucher">${voucher.is_active ? 'Deactivate' : 'Activate'}</button>
                                    <button data-id="${voucher.id}" class="text-xs font-semibold text-danger-600 js-delete-voucher">Delete</button>
                                </div>
                            </td>
                        </tr>
                    `;
                }).join('') || '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="8">No vouchers found.</td></tr>';

                info.textContent = 'Showing ' + list.length + ' of ' + (data.meta?.total ?? list.length) + ' vouchers';
                prevButton.disabled = !data.links?.prev;
                nextButton.disabled = !data.links?.next;
            }

            searchInput.addEventListener('input', function (event) {
                currentQuery = event.target.value.trim();
                currentPage = 1;
                loadVouchers();
            });

            prevButton.addEventListener('click', function () {
                if (currentPage > 1) {
                    currentPage -= 1;
                    loadVouchers();
                }
            });

            nextButton.addEventListener('click', function () {
                currentPage += 1;
                loadVouchers();
            });

            rows.addEventListener('click', async function (event) {
                var target = event.target;
                if (target.classList.contains('js-view-voucher')) {
                    await window.adminApi.ensureCsrfCookie();
                    var response = await window.adminApi.request('/api/vouchers/' + target.dataset.id);
                    if (!response.ok) {
                        if (window.adminSwalError) {
                            await window.adminSwalError('View failed', 'Unable to load voucher details.');
                        } else if (window.adminToast) {
                            window.adminToast('Unable to load voucher details.', { type: 'error' });
                        }
                        return;
                    }

                    var payload = await response.json();
                    var voucher = payload.data || payload;
                    var statusLabel = voucher.is_active ? 'active' : 'inactive';
                    var html = `
                        <div class="text-left">
                            <div class="flex items-center justify-between gap-4">
                                <div>
                                    <p class="text-xs uppercase tracking-widest text-slate-400">Voucher</p>
                                    <p class="text-lg font-semibold text-slate-900">${voucher.code || '--'}</p>
                                    <p class="text-xs text-slate-500">${voucher.name || 'Unnamed voucher'}</p>
                                </div>
                                <div>${statusBadge(statusLabel)}</div>
                            </div>
                            <div class="mt-5 grid gap-3 rounded-2xl border border-slate-200 bg-slate-50 p-4 text-sm text-slate-600">
                                <div class="flex items-center justify-between gap-4">
                                    <span class="font-semibold text-slate-500">Discount</span>
                                    <span class="text-slate-900">${formatDiscount(voucher)}</span>
                                </div>
                                <div class="flex items-center justify-between gap-4">
                                    <span class="font-semibold text-slate-500">Minimum Order</span>
                                    <span class="text-slate-900">${formatCurrency(voucher.min_order_amount || 0)}</span>
                                </div>
                                <div class="flex items-center justify-between gap-4">
                                    <span class="font-semibold text-slate-500">Starts</span>
                                    <span class="text-slate-900">${formatDate(voucher.starts_at)}</span>
                                </div>
                                <div class="flex items-center justify-between gap-4">
                                    <span class="font-semibold text-slate-500">Expires</span>
                                    <span class="text-slate-900">${formatDate(voucher.expires_at)}</span>
                                </div>
                                <div class="flex items-center justify-between gap-4">
                                    <span class="font-semibold text-slate-500">Total Usage</span>
                                    <span class="text-slate-900">${formatUsage(voucher)}</span>
                                </div>
                                <div class="flex items-center justify-between gap-4">
                                    <span class="font-semibold text-slate-500">Per User Limit</span>
                                    <span class="text-slate-900">${voucher.usage_limit_per_user ?? 'No limit'}</span>
                                </div>
                                <div class="flex items-center justify-between gap-4">
                                    <span class="font-semibold text-slate-500">Stackable</span>
                                    <span class="text-slate-900">${voucher.is_stackable ? 'Yes' : 'No'}</span>
                                </div>
                            </div>
                        </div>
                    `;

                    if (window.Swal) {
                        await window.Swal.fire({
                            title: 'Voucher Details',
                            html: html,
                            confirmButtonColor: '#2563eb',
                            width: 560,
                            padding: '1.5rem',
                        });
                    }
                }
                if (target.classList.contains('js-toggle-voucher')) {
                    var nextActive = target.dataset.active !== '1';
                    await window.adminApi.ensureCsrfCookie();
                    var response = await window.adminApi.request('/api/vouchers/' + target.dataset.id, {
                        method: 'PATCH',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ is_active: nextActive }),
                    });
                    if (window.adminSwalSuccess && response.ok) {
                        await window.adminSwalSuccess('Updated', 'Voucher status updated.');
                    } else if (window.adminSwalError && !response.ok) {
                        await window.adminSwalError('Update failed', 'Unable to update voucher status.');
                    } else if (window.adminToast) {
                        if (response.ok) {
                            window.adminToast('Voucher status updated.');
                        } else {
                            window.adminToast('Unable to update voucher status.', { type: 'error' });
                        }
                    }
                    loadVouchers();
                }

                if (target.classList.contains('js-delete-voucher')) {
                    var confirmed = true;
                    if (window.adminSwalConfirm) {
                        var result = await window.adminSwalConfirm('Delete voucher?', 'This will remove the voucher from the catalog.', 'Yes, delete it');
                        confirmed = result.isConfirmed;
                    } else {
                        confirmed = window.confirm('Delete this voucher?');
                    }
                    if (!confirmed) {
                        return;
                    }

                    await window.adminApi.ensureCsrfCookie();
                    var response = await window.adminApi.request('/api/vouchers/' + target.dataset.id, { method: 'DELETE' });
                    if (window.adminSwalSuccess && response.ok) {
                        await window.adminSwalSuccess('Deleted', 'Voucher deleted successfully.');
                    } else if (window.adminSwalError && !response.ok) {
                        await window.adminSwalError('Delete failed', 'Unable to delete voucher.');
                    } else if (window.adminToast) {
                        if (response.ok) {
                            window.adminToast('Voucher deleted.');
                        } else {
                            window.adminToast('Unable to delete voucher.', { type: 'error' });
                        }
                    }
                    loadVouchers();
                }
            });

            loadVouchers();
        });
    </script>
@endsection
