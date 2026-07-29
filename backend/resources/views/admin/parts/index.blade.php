@extends('layouts.admin')

@section('title', 'Parts')
@section('page-title', 'Parts')

@section('content')
    <div class="space-y-6">
        <div class="flex flex-wrap items-center justify-between gap-4">
            <div>
                <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Parts Inventory</h2>
                <p class="text-sm text-slate-500">Track repair parts stock and cost.</p>
            </div>
            <div class="flex items-center gap-3">
                <div class="relative" id="parts-export-dropdown-wrap">
                    <button id="parts-export-dropdown-btn" type="button" class="inline-flex h-10 items-center gap-2 rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-600 shadow-sm transition hover:bg-slate-50 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300 dark:hover:bg-slate-800">
                        <svg class="h-4 w-4 opacity-70" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
                        </svg>
                        Export
                        <svg class="h-3 w-3 opacity-50" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7" />
                        </svg>
                    </button>
                    <div id="parts-export-dropdown-menu" class="absolute right-0 top-12 z-50 hidden w-52 overflow-hidden rounded-xl border border-slate-200 bg-white shadow-lg dark:border-slate-800 dark:bg-slate-900">
                        <div class="px-3 py-2 text-xs font-semibold uppercase tracking-widest text-slate-400">Export as</div>
                        <div class="border-t border-slate-100 dark:border-slate-800">
                            <button id="parts-export-excel" type="button" class="flex w-full items-center gap-3 px-3 py-2.5 text-left text-sm text-slate-600 transition hover:bg-slate-50 dark:text-slate-300 dark:hover:bg-slate-800">
                                <span class="flex h-7 w-7 flex-shrink-0 items-center justify-center rounded-lg bg-success-600 text-xs font-bold text-white">XLS</span>
                                <span>
                                    <span class="block font-medium">Excel Workbook</span>
                                    <span class="block text-xs text-slate-400">Filtered rows, up to 5 000</span>
                                </span>
                            </button>
                            <button id="parts-export-pdf" type="button" class="flex w-full items-center gap-3 px-3 py-2.5 text-left text-sm text-slate-600 transition hover:bg-slate-50 dark:text-slate-300 dark:hover:bg-slate-800">
                                <span class="flex h-7 w-7 flex-shrink-0 items-center justify-center rounded-lg bg-danger-600 text-xs font-bold text-white">PDF</span>
                                <span>
                                    <span class="block font-medium">PDF Report</span>
                                    <span class="block text-xs text-slate-400">Print-ready, up to 1 000</span>
                                </span>
                            </button>
                        </div>
                    </div>
                </div>
                @if (auth()->user()?->hasPermission('create_parts_inventory'))
                <a href="{{ route('admin.parts.create') }}" class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white shadow-sm">Add Part</a>
                @endif
            </div>
        </div>

        <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <div class="flex flex-wrap items-center justify-between gap-3">
                <div class="flex w-60 flex-wrap items-center gap-3 sm:w-auto">
                    <select class="h-10 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 sm:w-40 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300">
                        <option>Bulk actions</option>
                        <option>Delete</option>
                    </select>
                    <button class="h-10 w-full rounded-xl border border-slate-200 bg-white px-6 text-sm font-semibold text-slate-600 sm:w-auto dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300">Apply</button>
                </div>
                <div class="relative">
                    <input id="part-search" type="text" placeholder="Search parts" class="h-10 w-60 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    <svg class="absolute right-3 top-3 h-4 w-4 text-slate-400" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-4.35-4.35m1.6-5.15a7 7 0 11-14 0 7 7 0 0114 0z" />
                    </svg>
                </div>
            </div>

            <div class="mt-4 grid gap-3 sm:grid-cols-2 xl:grid-cols-6">
                <select id="part-status-filter" class="h-10 rounded-xl border border-slate-200 bg-slate-50 pl-3 pr-8 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300">
                    <option value="">All statuses</option>
                    @foreach (\App\Models\Part::STATUSES as $status)
                        <option value="{{ $status }}">{{ ucwords(str_replace('_', ' ', $status)) }}</option>
                    @endforeach
                </select>
                <select id="part-tag-filter" class="h-10 rounded-xl border border-slate-200 bg-slate-50 pl-3 pr-8 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300">
                    <option value="">All tags</option>
                    <option value="HOT_SALE">Hot Sale</option>
                    <option value="TOP_SELLER">Top Seller</option>
                    <option value="PROMOTION">Promotion</option>
                </select>
                <select id="part-stock-filter" class="h-10 rounded-xl border border-slate-200 bg-slate-50 pl-3 pr-8 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300">
                    <option value="">All stock</option>
                    <option value="in_stock">In stock</option>
                    <option value="low_stock">Low stock (1-5)</option>
                    <option value="out_of_stock">Out of stock</option>
                </select>
                <input id="part-type-filter" type="text" placeholder="Filter type" class="h-10 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                <input id="part-brand-filter" type="text" placeholder="Filter brand" class="h-10 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                <button id="part-reset-filters" type="button" class="h-10 rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-600 shadow-sm transition hover:bg-slate-50 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300 dark:hover:bg-slate-800">Reset</button>
            </div>

            <div class="mt-5 overflow-x-auto">
                <table class="w-full text-left text-sm">
                    <thead class="text-xs uppercase tracking-widest text-slate-400">
                        <tr>
                            <th class="px-4 py-3"><input type="checkbox" class="rounded border-slate-300 text-primary-600 focus:ring-primary-500" /></th>
                            <th class="px-4 py-3">Name</th>
                            <th class="px-4 py-3">Type</th>
                            <th class="px-4 py-3">Brand</th>
                            <th class="px-4 py-3">SKU</th>
                            <th class="px-4 py-3">Stock</th>
                            <th class="px-4 py-3">Unit Cost</th>
                            <th class="px-4 py-3">Status</th>
                            <th class="px-4 py-3">Tag</th>
                            <th class="px-4 py-3 text-right">Action</th>
                        </tr>
                    </thead>
                    <tbody id="part-rows" class="divide-y divide-slate-200 text-slate-600 dark:divide-slate-800 dark:text-slate-300"></tbody>
                </table>
            </div>

            <div class="mt-4 flex items-center justify-between text-xs text-slate-500">
                <p id="part-pagination-info">Loading parts...</p>
                <div class="flex items-center gap-2">
                    <button id="part-prev" class="rounded-lg border border-slate-200 px-3 py-1 text-slate-600 dark:border-slate-800 dark:text-slate-300">Previous</button>
                    <button id="part-next" class="rounded-lg border border-slate-200 bg-slate-100 px-3 py-1 text-slate-900 dark:border-slate-800 dark:bg-slate-900">Next</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var currentPage = 1;

            var searchInput = document.getElementById('part-search');
            var statusFilter = document.getElementById('part-status-filter');
            var tagFilter = document.getElementById('part-tag-filter');
            var stockFilter = document.getElementById('part-stock-filter');
            var typeFilter = document.getElementById('part-type-filter');
            var brandFilter = document.getElementById('part-brand-filter');
            var resetFiltersButton = document.getElementById('part-reset-filters');
            var prevButton = document.getElementById('part-prev');
            var nextButton = document.getElementById('part-next');
            var info = document.getElementById('part-pagination-info');
            var rows = document.getElementById('part-rows');
            var exportDropdownBtn = document.getElementById('parts-export-dropdown-btn');
            var exportDropdownMenu = document.getElementById('parts-export-dropdown-menu');
            var filterTimer = null;

            function formatCurrency(value) {
                return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(value || 0);
            }

            function escapeHtml(value) {
                return String(value ?? '').replace(/[&<>"']/g, function (character) {
                    return {
                        '&': '&amp;',
                        '<': '&lt;',
                        '>': '&gt;',
                        '"': '&quot;',
                        "'": '&#039;'
                    }[character];
                });
            }

            function buildPartQuery() {
                var query = new URLSearchParams();

                if (searchInput.value.trim()) {
                    query.set('q', searchInput.value.trim());
                }
                if (statusFilter.value) {
                    query.set('status', statusFilter.value);
                }
                if (tagFilter.value) {
                    query.set('tag', tagFilter.value);
                }
                if (stockFilter.value) {
                    query.set('stock_filter', stockFilter.value);
                }
                if (typeFilter.value.trim()) {
                    query.set('type', typeFilter.value.trim());
                }
                if (brandFilter.value.trim()) {
                    query.set('brand', brandFilter.value.trim());
                }

                return query;
            }

            function scheduleRefresh() {
                if (filterTimer) {
                    clearTimeout(filterTimer);
                }

                filterTimer = setTimeout(function () {
                    currentPage = 1;
                    loadParts();
                }, 250);
            }

            function statusBadge(status) {
                var map = {
                    active: 'bg-success-50 text-success-700 dark:bg-success-500/10 dark:text-success-100',
                    inactive: 'bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-300',
                    archived: 'bg-warning-50 text-warning-700 dark:bg-warning-500/10 dark:text-warning-100',
                };
                var key = status || 'inactive';
                var klass = map[key] || map.inactive;
                return '<span class="rounded-full px-2 py-1 text-xs font-semibold ' + klass + '">' + escapeHtml(key) + '</span>';
            }

            function tagBadge(tag) {
                if (!tag) {
                    return '<span class="text-xs text-slate-400">--</span>';
                }
                var map = {
                    HOT_SALE: 'bg-danger-50 text-danger-700 dark:bg-danger-500/10 dark:text-danger-100',
                    TOP_SELLER: 'bg-primary-50 text-primary-700 dark:bg-primary-500/10 dark:text-primary-100',
                    PROMOTION: 'bg-warning-50 text-warning-700 dark:bg-warning-500/10 dark:text-warning-100',
                };
                var labelMap = {
                    HOT_SALE: 'Hot Sale',
                    TOP_SELLER: 'Top Seller',
                    PROMOTION: 'Promotion',
                };
                var klass = map[tag] || 'bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-300';
                var label = labelMap[tag] || tag.toString().replace(/_/g, ' ').toLowerCase().replace(/\b\w/g, function (m) { return m.toUpperCase(); });
                return '<span class="rounded-full px-2 py-1 text-xs font-semibold ' + klass + '">' + escapeHtml(label) + '</span>';
            }

            async function loadParts() {
                await window.adminApi.ensureCsrfCookie();
                var query = buildPartQuery();
                query.set('page', currentPage);
                var response = await window.adminApi.request('/api/parts?' + query.toString());
                if (!response.ok) {
                    rows.innerHTML = '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="10">Unable to load parts.</td></tr>';
                    return;
                }
                var data = await response.json();
                var list = data.data || [];

                rows.innerHTML = list.map(function (item) {
                    return `
                        <tr>
                            <td class="px-4 py-3"><input type="checkbox" class="rounded border-slate-300 text-primary-600 focus:ring-primary-500" /></td>
                            <td class="px-4 py-3">
                                <div>
                                    <p class="font-semibold text-slate-900 dark:text-white">${escapeHtml(item.name || '--')}</p>
                                </div>
                            </td>
                            <td class="px-4 py-3">${escapeHtml(item.type || '--')}</td>
                            <td class="px-4 py-3">${escapeHtml(item.brand || '--')}</td>
                            <td class="px-4 py-3">${escapeHtml(item.sku || '--')}</td>
                            <td class="px-4 py-3">${item.stock ?? 0}</td>
                            <td class="px-4 py-3">${formatCurrency(item.unit_cost)}</td>
                            <td class="px-4 py-3">${statusBadge(item.status)}</td>
                            <td class="px-4 py-3">${tagBadge(item.tag)}</td>
                            <td class="px-4 py-3 text-right">
                                <button data-id="${item.id}" class="text-xs font-semibold text-slate-500 js-view-part">View</button>
                                ${window.adminCan('update_parts_inventory') ? `<a href="/admin/parts/${item.id}/edit" class="ml-3 text-xs font-semibold text-primary-600">Edit</a>` : ''}
                                ${window.adminCan('delete_parts_inventory') ? `<button data-id="${item.id}" class="ml-3 text-xs font-semibold text-danger-600 js-delete-part">Delete</button>` : ''}
                            </td>
                        </tr>
                    `;
                }).join('') || '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="10">No parts found.</td></tr>';

                info.textContent = 'Showing ' + list.length + ' of ' + (data.meta?.total ?? list.length) + ' parts';
                prevButton.disabled = !data.links?.prev;
                nextButton.disabled = !data.links?.next;
            }

            searchInput.addEventListener('input', scheduleRefresh);
            typeFilter.addEventListener('input', scheduleRefresh);
            brandFilter.addEventListener('input', scheduleRefresh);
            statusFilter.addEventListener('change', function () {
                currentPage = 1;
                loadParts();
            });
            tagFilter.addEventListener('change', function () {
                currentPage = 1;
                loadParts();
            });
            stockFilter.addEventListener('change', function () {
                currentPage = 1;
                loadParts();
            });
            resetFiltersButton.addEventListener('click', function () {
                searchInput.value = '';
                statusFilter.value = '';
                tagFilter.value = '';
                stockFilter.value = '';
                typeFilter.value = '';
                brandFilter.value = '';
                currentPage = 1;
                loadParts();
            });

            prevButton.addEventListener('click', function () {
                if (currentPage > 1) {
                    currentPage -= 1;
                    loadParts();
                }
            });

            nextButton.addEventListener('click', function () {
                currentPage += 1;
                loadParts();
            });

            function buildExportUrl(endpoint) {
                var query = buildPartQuery();
                var url = '/api/admin/parts/' + endpoint;
                if (query.toString()) {
                    url += '?' + query.toString();
                }
                return url;
            }

            function closeExportDropdown() {
                if (exportDropdownMenu) {
                    exportDropdownMenu.classList.add('hidden');
                }
            }

            if (exportDropdownBtn && exportDropdownMenu) {
                exportDropdownBtn.addEventListener('click', function (event) {
                    event.stopPropagation();
                    exportDropdownMenu.classList.toggle('hidden');
                });
                exportDropdownMenu.addEventListener('click', function (event) {
                    event.stopPropagation();
                });
                document.addEventListener('click', closeExportDropdown);
            }

            var excelButton = document.getElementById('parts-export-excel');
            if (excelButton) {
                excelButton.addEventListener('click', function () {
                    window.location.href = buildExportUrl('export-excel');
                    closeExportDropdown();
                });
            }

            var pdfButton = document.getElementById('parts-export-pdf');
            if (pdfButton) {
                pdfButton.addEventListener('click', function () {
                    window.location.href = buildExportUrl('export-pdf');
                    closeExportDropdown();
                });
            }

            rows.addEventListener('click', async function (event) {
                var target = event.target;
                if (target.classList.contains('js-view-part')) {
                    await window.adminApi.ensureCsrfCookie();
                    var response = await window.adminApi.request('/api/parts/' + target.dataset.id);
                    if (!response.ok) {
                        if (window.adminSwalError) {
                            await window.adminSwalError('View failed', 'Unable to load part details.');
                        } else if (window.adminToast) {
                            window.adminToast('Unable to load part details.', { type: 'error' });
                        }
                        return;
                    }

                    var payload = await response.json();
                    var item = payload.data || payload;
                    var html = `
                        <div class="text-left">
                            <div>
                                <p class="text-xs uppercase tracking-widest text-slate-400">Part</p>
                                <p class="text-lg font-semibold text-slate-900">${escapeHtml(item.name || '--')}</p>
                                <div class="mt-2">${statusBadge(item.status)}</div>
                            </div>
                            <div class="mt-5 grid gap-3 rounded-2xl border border-slate-200 bg-slate-50 p-4 text-sm text-slate-600">
                                <div class="flex items-center justify-between gap-4">
                                    <span class="font-semibold text-slate-500">Type</span>
                                    <span class="text-slate-900">${escapeHtml(item.type || '--')}</span>
                                </div>
                                <div class="flex items-center justify-between gap-4">
                                    <span class="font-semibold text-slate-500">Brand</span>
                                    <span class="text-slate-900">${escapeHtml(item.brand || '--')}</span>
                                </div>
                                <div class="flex items-center justify-between gap-4">
                                    <span class="font-semibold text-slate-500">SKU</span>
                                    <span class="text-slate-900">${escapeHtml(item.sku || '--')}</span>
                                </div>
                                <div class="flex items-center justify-between gap-4">
                                    <span class="font-semibold text-slate-500">Stock</span>
                                    <span class="text-slate-900">${item.stock ?? 0}</span>
                                </div>
                                <div class="flex items-center justify-between gap-4">
                                    <span class="font-semibold text-slate-500">Unit Cost</span>
                                    <span class="text-slate-900">${formatCurrency(item.unit_cost)}</span>
                                </div>
                                <div class="flex items-center justify-between gap-4">
                                    <span class="font-semibold text-slate-500">Tag</span>
                                    <span class="text-slate-900">${escapeHtml(item.tag || '--')}</span>
                                </div>
                            </div>
                        </div>
                    `;

                    if (window.Swal) {
                        await window.Swal.fire({
                            title: 'Part Details',
                            html: html,
                            confirmButtonColor: '#2563eb',
                            width: 600,
                            padding: '1.5rem',
                        });
                    }
                }
                if (target.classList.contains('js-delete-part')) {
                    var confirmed = true;
                    if (window.adminSwalConfirm) {
                        var result = await window.adminSwalConfirm('Delete part?', 'This will remove the part from inventory.', 'Yes, delete it');
                        confirmed = result.isConfirmed;
                    } else {
                        confirmed = window.confirm('Delete this part?');
                    }
                    if (!confirmed) {
                        return;
                    }
                    await window.adminApi.ensureCsrfCookie();
                    var response = await window.adminApi.request('/api/parts/' + target.dataset.id, { method: 'DELETE' });
                    if (window.adminSwalSuccess && response.ok) {
                        await window.adminSwalSuccess('Deleted', 'Part deleted successfully.');
                    } else if (window.adminSwalError && !response.ok) {
                        await window.adminSwalError('Delete failed', 'Unable to delete part.');
                    } else if (window.adminToast) {
                        if (response.ok) {
                            window.adminToast('Part deleted.');
                        } else {
                            window.adminToast('Unable to delete part.', { type: 'error' });
                        }
                    }
                    loadParts();
                }
            });

            loadParts();
        });
    </script>
@endsection
