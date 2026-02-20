@extends('layouts.admin')

@section('title', 'Accessories')
@section('page-title', 'Accessories')

@section('content')
    <div class="space-y-6">
        <div class="flex flex-wrap items-center justify-between gap-4">
            <div>
                <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Accessories & Repair Parts</h2>
                <p class="text-sm text-slate-500">Manage accessories and repair parts for iPhone and Samsung.</p>
            </div>
            <div class="flex items-center gap-3">
                <a href="{{ route('admin.accessories.create') }}" class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white shadow-sm">Add Accessory</a>
            </div>
        </div>

        <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <div class="flex flex-wrap items-center justify-between gap-3">
                <div class="flex flex-wrap items-center gap-3">
                    <select class="h-10 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300">
                        <option>Bulk actions</option>
                        <option>Delete</option>
                    </select>
                    <button class="h-10 rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-600 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300">Apply</button>
                </div>
                <div class="relative">
                    <input type="text" placeholder="Search accessories" class="h-10 w-60 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
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
                            <th class="px-4 py-3">Image</th>
                            <th class="px-4 py-3">Name</th>
                            <th class="px-4 py-3">Brand</th>
                            <th class="px-4 py-3">Price</th>
                            <th class="px-4 py-3">Stock</th>
                            <th class="px-4 py-3">Discount</th>
                            <th class="px-4 py-3">Final Price</th>
                            <th class="px-4 py-3">Warranty</th>
                            <th class="px-4 py-3 text-right">Action</th>
                        </tr>
                    </thead>
                    <tbody id="accessory-rows" class="divide-y divide-slate-200 text-slate-600 dark:divide-slate-800 dark:text-slate-300"></tbody>
                </table>
            </div>

            <div class="mt-4 flex items-center justify-between text-xs text-slate-500">
                <p id="accessory-pagination-info">Loading accessories...</p>
                <div class="flex items-center gap-2">
                    <button id="accessory-prev" class="rounded-lg border border-slate-200 px-3 py-1 text-slate-600 dark:border-slate-800 dark:text-slate-300">Previous</button>
                    <button id="accessory-next" class="rounded-lg border border-slate-200 bg-slate-100 px-3 py-1 text-slate-900 dark:border-slate-800 dark:bg-slate-900">Next</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var currentPage = 1;
            var currentQuery = '';

            var searchInput = document.querySelector('input[placeholder="Search accessories"]');
            var prevButton = document.getElementById('accessory-prev');
            var nextButton = document.getElementById('accessory-next');
            var info = document.getElementById('accessory-pagination-info');
            var rows = document.getElementById('accessory-rows');

            function formatCurrency(value) {
                return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(value || 0);
            }

            function warrantyBadge(warranty) {
                var map = {
                    NO_WARRANTY: { label: 'NO_WARRANTY', color: '#9CA3AF', text: 'text-white', note: 'No coverage' },
                    '7_DAYS': { label: '7_DAYS', color: '#F87171', text: 'text-white', note: 'Very short' },
                    '14_DAYS': { label: '14_DAYS', color: '#FB923C', text: 'text-white', note: 'Short' },
                    '1_MONTH': { label: '1_MONTH', color: '#FACC15', text: 'text-slate-900', note: 'Basic' },
                    '3_MONTHS': { label: '3_MONTHS', color: '#4ADE80', text: 'text-slate-900', note: 'Standard' },
                    '6_MONTHS': { label: '6_MONTHS', color: '#60A5FA', text: 'text-white', note: 'Good' },
                    '1_YEAR': { label: '1_YEAR', color: '#A78BFA', text: 'text-white', note: 'Best' },
                };
                var info = map[warranty] || { label: warranty || '--', color: '#E5E7EB', text: 'text-slate-700', note: '' };
                var title = info.note ? ' title="' + info.note + '"' : '';
                return '<span class="rounded-full px-2 py-1 text-xs font-semibold ' + info.text + '" style="background-color: ' + info.color + ';"' + title + '>' + info.label + '</span>';
            }

            async function loadAccessories() {
                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/accessories?q=' + encodeURIComponent(currentQuery) + '&page=' + currentPage);
                if (!response.ok) {
                    rows.innerHTML = '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="10">Unable to load accessories.</td></tr>';
                    return;
                }
                var data = await response.json();
                var list = data.data || [];

                rows.innerHTML = list.map(function (item) {
                    return `
                        <tr>
                            <td class="px-4 py-3"><input type="checkbox" class="rounded border-slate-300 text-primary-600 focus:ring-primary-500" /></td>
                            <td class="px-4 py-3">
                                ${item.image ? `<img src="${item.image}" alt="${item.name}" class="h-10 w-10 rounded-lg object-cover" />` : '<div class="flex h-10 w-10 items-center justify-center rounded-lg bg-slate-100 text-[10px] text-slate-400">No image</div>'}
                            </td>
                            <td class="px-4 py-3">
                                <div>
                                    <p class="font-semibold text-slate-900 dark:text-white">${item.name}</p>
                                    <p class="text-xs text-slate-500">${item.description || 'No description'}</p>
                                </div>
                            </td>
                            <td class="px-4 py-3">${item.brand}</td>
                            <td class="px-4 py-3">${formatCurrency(item.price)}</td>
                            <td class="px-4 py-3">${item.stock ?? 0}</td>
                            <td class="px-4 py-3">${formatCurrency(item.discount)}</td>
                            <td class="px-4 py-3">${formatCurrency(item.final_price)}</td>
                            <td class="px-4 py-3">${warrantyBadge(item.warranty)}</td>
                            <td class="px-4 py-3 text-right">
                                <button data-id="${item.id}" class="text-xs font-semibold text-slate-500 js-view-accessory">View</button>
                                <a href="/admin/accessories/${item.id}/edit" class="ml-3 text-xs font-semibold text-primary-600">Edit</a>
                                <button data-id="${item.id}" class="ml-3 text-xs font-semibold text-danger-600 js-delete-accessory">Delete</button>
                            </td>
                        </tr>
                    `;
                }).join('') || '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="10">No accessories found.</td></tr>';

                info.textContent = 'Showing ' + list.length + ' of ' + (data.meta?.total ?? list.length) + ' accessories';
                prevButton.disabled = !data.links?.prev;
                nextButton.disabled = !data.links?.next;
            }

            searchInput.addEventListener('input', function (event) {
                currentQuery = event.target.value.trim();
                currentPage = 1;
                loadAccessories();
            });

            prevButton.addEventListener('click', function () {
                if (currentPage > 1) {
                    currentPage -= 1;
                    loadAccessories();
                }
            });

            nextButton.addEventListener('click', function () {
                currentPage += 1;
                loadAccessories();
            });

            rows.addEventListener('click', async function (event) {
                var target = event.target;
                if (target.classList.contains('js-view-accessory')) {
                    await window.adminApi.ensureCsrfCookie();
                    var response = await window.adminApi.request('/api/accessories/' + target.dataset.id);
                    if (!response.ok) {
                        if (window.adminSwalError) {
                            await window.adminSwalError('View failed', 'Unable to load accessory details.');
                        } else if (window.adminToast) {
                            window.adminToast('Unable to load accessory details.', { type: 'error' });
                        }
                        return;
                    }

                    var payload = await response.json();
                    var item = payload.data || payload;
                    var html = `
                        <div class="text-left">
                            <div>
                                <p class="text-xs uppercase tracking-widest text-slate-400">Accessory</p>
                                <p class="text-lg font-semibold text-slate-900">${item.name || '--'}</p>
                            </div>
                            <div class="mt-5 grid gap-3 rounded-2xl border border-slate-200 bg-slate-50 p-4 text-sm text-slate-600">
                                <div class="flex items-center justify-between gap-4">
                                    <span class="font-semibold text-slate-500">Brand</span>
                                    <span class="text-slate-900">${item.brand || '--'}</span>
                                </div>
                                <div class="flex items-center justify-between gap-4">
                                    <span class="font-semibold text-slate-500">Price</span>
                                    <span class="text-slate-900">${formatCurrency(item.price)}</span>
                                </div>
                                <div class="flex items-center justify-between gap-4">
                                    <span class="font-semibold text-slate-500">Stock</span>
                                    <span class="text-slate-900">${item.stock ?? 0}</span>
                                </div>
                                <div class="flex items-center justify-between gap-4">
                                    <span class="font-semibold text-slate-500">Discount</span>
                                    <span class="text-slate-900">${formatCurrency(item.discount)}</span>
                                </div>
                                <div class="flex items-center justify-between gap-4">
                                    <span class="font-semibold text-slate-500">Final price</span>
                                    <span class="text-slate-900">${formatCurrency(item.final_price)}</span>
                                </div>
                                <div class="flex items-center justify-between gap-4">
                                    <span class="font-semibold text-slate-500">Warranty</span>
                                    <span>${warrantyBadge(item.warranty)}</span>
                                </div>
                                <div class="flex items-start justify-between gap-4">
                                    <span class="font-semibold text-slate-500">Description</span>
                                    <span class="text-slate-900 text-right">${item.description || '--'}</span>
                                </div>
                            </div>
                        </div>
                    `;

                    if (window.Swal) {
                        await window.Swal.fire({
                            title: 'Accessory Details',
                            html: html,
                            confirmButtonColor: '#2563eb',
                            width: 600,
                            padding: '1.5rem',
                        });
                    }
                }
                if (target.classList.contains('js-delete-accessory')) {
                    var confirmed = true;
                    if (window.adminSwalConfirm) {
                        var result = await window.adminSwalConfirm('Delete accessory?', 'This will remove the accessory from the catalog.', 'Yes, delete it');
                        confirmed = result.isConfirmed;
                    } else {
                        confirmed = window.confirm('Delete this accessory?');
                    }
                    if (!confirmed) {
                        return;
                    }
                    await window.adminApi.ensureCsrfCookie();
                    var response = await window.adminApi.request('/api/accessories/' + target.dataset.id, { method: 'DELETE' });
                    if (window.adminSwalSuccess && response.ok) {
                        await window.adminSwalSuccess('Deleted', 'Accessory deleted successfully.');
                    } else if (window.adminSwalError && !response.ok) {
                        await window.adminSwalError('Delete failed', 'Unable to delete accessory.');
                    } else if (window.adminToast) {
                        if (response.ok) {
                            window.adminToast('Accessory deleted.');
                        } else {
                            window.adminToast('Unable to delete accessory.', { type: 'error' });
                        }
                    }
                    loadAccessories();
                }
            });

            loadAccessories();
        });
    </script>
@endsection
