@extends('layouts.admin')

@section('title', __('Products Management'))
@section('page-title', __('Products Management'))

@section('content')
    <div class="space-y-6">
        {{-- Header Section --}}
        <div class="flex flex-wrap items-center justify-between gap-4">
            <div>
                <h2 class="text-xl font-extrabold text-slate-900 dark:text-white">{{ __('Products Catalog') }}</h2>
                <p class="text-sm text-slate-500">{{ __('Manage catalog items, filter by attributes, and execute bulk operations.') }}</p>
            </div>
            <div class="flex items-center gap-3">
                @if (auth()->user()?->hasPermission('create_product'))
                <a href="{{ route('admin.products.create') }}" class="inline-flex h-10 items-center gap-2 rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white shadow-md hover:bg-primary-700 transition-all">
                    <svg class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4"/></svg>
                    {{ __('Add Product') }}
                </a>
                @endif
            </div>
        </div>

        {{-- Filters & Controls Card --}}
        <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900 space-y-4">

            {{-- Top Controls: Bulk Actions & Search --}}
            <div class="flex flex-wrap items-center justify-between gap-4">

                {{-- Quick Action Block --}}
                <div class="flex flex-wrap items-center gap-3">
                    <select id="bulk-action-select" class="h-10 min-w-[150px] rounded-xl border border-slate-200 bg-slate-50 pl-3.5 pr-9 text-sm font-medium text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-200 cursor-pointer">
                        <option value="">{{ __('Quick action') }}</option>
                        <option value="activate">{{ __('Activate') }}</option>
                        <option value="deactivate">{{ __('Deactivate') }}</option>
                        <option value="archive">{{ __('Archive') }}</option>
                        <option value="delete">{{ __('Delete') }}</option>
                    </select>
                    <button id="btn-apply-bulk" class="inline-flex h-10 items-center gap-1.5 rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-700 shadow-sm hover:bg-slate-50 dark:border-slate-700 dark:bg-slate-800 dark:text-slate-200 dark:hover:bg-slate-700 transition-all">
                        {{ __('Apply') }}
                    </button>
                    <span id="selected-count-badge" class="hidden rounded-full bg-primary-100 px-3 py-1 text-xs font-bold text-primary-700 dark:bg-primary-500/20 dark:text-primary-300">
                        0 selected
                    </span>
                </div>

                {{-- Search Bar --}}
                <div class="relative min-w-[240px] flex-1 sm:flex-none">
                    <input id="search-products" type="text" placeholder="{{ __('Search product name or SKU...') }}" class="h-10 w-full rounded-xl border border-slate-200 bg-slate-50 pl-3 pr-9 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-200" />
                    <svg class="absolute right-3 top-3 h-4 w-4 text-slate-400" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-4.35-4.35m1.6-5.15a7 7 0 11-14 0 7 7 0 0114 0z" />
                    </svg>
                </div>
            </div>

            {{-- Filter Row: Category, Brand, Warranty, Status & Per-Page --}}
            <div class="flex flex-wrap items-end justify-between gap-3 border-t border-slate-100 pt-4 dark:border-slate-800/80">
                <div class="flex flex-wrap items-end gap-3">

                    {{-- Category Filter --}}
                    <div>
                        <label class="text-[11px] font-bold uppercase tracking-wider text-slate-400 block mb-1">{{ __('Category') }}</label>
                        <select id="filter-category" class="h-9 min-w-[155px] rounded-xl border border-slate-200 bg-slate-50 pl-3.5 pr-9 text-xs font-medium text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-200 cursor-pointer">
                            <option value="">{{ __('All Categories') }}</option>
                        </select>
                    </div>

                    {{-- Brand Filter --}}
                    <div>
                        <label class="text-[11px] font-bold uppercase tracking-wider text-slate-400 block mb-1">{{ __('Brand') }}</label>
                        <select id="filter-brand" class="h-9 min-w-[140px] rounded-xl border border-slate-200 bg-slate-50 pl-3.5 pr-9 text-xs font-medium text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-200 cursor-pointer">
                            <option value="">{{ __('All Brands') }}</option>
                            <option value="Apple">Apple</option>
                            <option value="Samsung">Samsung</option>
                            <option value="Anker">Anker</option>
                            <option value="Baseus">Baseus</option>
                            <option value="Xiaomi">Xiaomi</option>
                            <option value="Google">Google</option>
                            <option value="Sony">Sony</option>
                            <option value="Asus">Asus</option>
                            <option value="Huawei">Huawei</option>
                            <option value="Oppo">Oppo</option>
                            <option value="Vivo">Vivo</option>
                            <option value="RealMe">RealMe</option>
                        </select>
                    </div>

                    {{-- Warranty Filter --}}
                    <div>
                        <label class="text-[11px] font-bold uppercase tracking-wider text-slate-400 block mb-1">{{ __('Warranty') }}</label>
                        <select id="filter-warranty" class="h-9 min-w-[155px] rounded-xl border border-slate-200 bg-slate-50 pl-3.5 pr-9 text-xs font-medium text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-200 cursor-pointer">
                            <option value="">{{ __('All Warranties') }}</option>
                            <option value="NO_WARRANTY">NO WARRANTY</option>
                            <option value="7_DAYS">7 DAYS</option>
                            <option value="14_DAYS">14 DAYS</option>
                            <option value="1_MONTH">1 MONTH</option>
                            <option value="3_MONTHS">3 MONTHS</option>
                            <option value="6_MONTHS">6 MONTHS</option>
                            <option value="1_YEAR">1 YEAR</option>
                        </select>
                    </div>

                    {{-- Status Filter --}}
                    <div>
                        <label class="text-[11px] font-bold uppercase tracking-wider text-slate-400 block mb-1">{{ __('Status') }}</label>
                        <select id="filter-status" class="h-9 min-w-[140px] rounded-xl border border-slate-200 bg-slate-50 pl-3.5 pr-9 text-xs font-medium text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-200 cursor-pointer">
                            <option value="">{{ __('All Statuses') }}</option>
                            <option value="active">{{ __('Active') }}</option>
                            <option value="draft">{{ __('Draft') }}</option>
                            <option value="archived">{{ __('Archived') }}</option>
                        </select>
                    </div>

                    {{-- Reset Filters --}}
                    <div>
                        <button id="btn-reset-filters" class="h-9 px-3 text-xs font-semibold text-slate-500 hover:text-slate-800 dark:hover:text-slate-200 transition-all">
                            {{ __('Reset Filters') }}
                        </button>
                    </div>
                </div>

                {{-- Per Page Dropdown --}}
                <div class="flex items-center gap-2">
                    <label class="text-xs font-semibold text-slate-400">{{ __('Show:') }}</label>
                    <select id="filter-per-page" class="h-9 min-w-[85px] rounded-xl border border-slate-200 bg-slate-50 pl-3 pr-8 text-xs font-semibold text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-200 cursor-pointer">
                        <option value="25" selected>25</option>
                        <option value="50">50</option>
                        <option value="100">100</option>
                        <option value="1000">1000</option>
                        <option value="all">All</option>
                    </select>
                </div>
            </div>

            {{-- Products Table --}}
            <div class="mt-4 overflow-x-auto rounded-xl border border-slate-100 dark:border-slate-800/80">
                <table class="w-full text-left text-sm">
                    <thead class="bg-slate-50/80 text-[11px] font-extrabold uppercase tracking-wider text-slate-400 dark:bg-slate-800/50">
                        <tr>
                            <th class="px-5 py-3.5 w-10"><input id="select-all-products" type="checkbox" class="rounded border-slate-300 text-primary-600 focus:ring-primary-500 cursor-pointer" /></th>
                            <th class="px-5 py-3.5 whitespace-nowrap min-w-[220px]">{{ __('Product') }}</th>
                            <th class="px-5 py-3.5 whitespace-nowrap">{{ __('Category') }}</th>
                            <th class="px-5 py-3.5 whitespace-nowrap">{{ __('Brand') }}</th>
                            <th class="px-5 py-3.5 whitespace-nowrap">{{ __('Warranty') }}</th>
                            <th class="px-5 py-3.5 whitespace-nowrap">{{ __('Price') }}</th>
                            <th class="px-5 py-3.5 whitespace-nowrap">{{ __('Discount') }}</th>
                            <th class="px-5 py-3.5 whitespace-nowrap">{{ __('Added By') }}</th>
                            <th class="px-5 py-3.5 whitespace-nowrap text-center">{{ __('Variants') }}</th>
                            <th class="px-5 py-3.5 whitespace-nowrap text-center">{{ __('Stock') }}</th>
                            <th class="px-5 py-3.5 whitespace-nowrap">{{ __('Status') }}</th>
                            <th class="px-5 py-3.5 text-right whitespace-nowrap">{{ __('Action') }}</th>
                        </tr>
                    </thead>
                    <tbody id="product-rows" class="divide-y divide-slate-100 text-slate-600 dark:divide-slate-800 dark:text-slate-300">
                        <tr><td colspan="12" class="px-5 py-10 text-center text-xs text-slate-400">{{ __('Loading products...') }}</td></tr>
                    </tbody>
                </table>
            </div>

            {{-- Pagination Footer --}}
            <div class="mt-4 flex items-center justify-between text-xs text-slate-500 pt-2 border-t border-slate-100 dark:border-slate-800">
                <p id="product-pagination-info">{{ __('Loading products...') }}</p>
                <div class="flex items-center gap-2">
                    <button id="product-prev" class="rounded-xl border border-slate-200 px-3.5 py-1.5 font-semibold text-slate-600 hover:bg-slate-50 dark:border-slate-800 dark:text-slate-300 dark:hover:bg-slate-800 disabled:opacity-40 transition-all">{{ __('Previous') }}</button>
                    <button id="product-next" class="rounded-xl border border-slate-200 bg-slate-100 px-3.5 py-1.5 font-semibold text-slate-900 hover:bg-slate-200 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-100 disabled:opacity-40 transition-all">{{ __('Next') }}</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var currentPage   = 1;
            var currentQuery   = '';
            var currentCat     = '';
            var currentBrand   = '';
            var currentWarranty= '';
            var currentStatus  = '';
            var currentPerPage = '25';

            var searchInput   = document.getElementById('search-products');
            var filterCat     = document.getElementById('filter-category');
            var filterBrand   = document.getElementById('filter-brand');
            var filterWarranty= document.getElementById('filter-warranty');
            var filterStatus  = document.getElementById('filter-status');
            var filterPerPage = document.getElementById('filter-per-page');
            var btnReset      = document.getElementById('btn-reset-filters');

            var bulkSelect    = document.getElementById('bulk-action-select');
            var btnApplyBulk  = document.getElementById('btn-apply-bulk');
            var selectAllCb   = document.getElementById('select-all-products');
            var selectedBadge = document.getElementById('selected-count-badge');

            var prevButton    = document.getElementById('product-prev');
            var nextButton    = document.getElementById('product-next');
            var info          = document.getElementById('product-pagination-info');
            var rows          = document.getElementById('product-rows');

            // Load Categories into filter dropdown
            async function loadCategoryOptions() {
                try {
                    var res = await window.adminApi.request('/api/categories');
                    if (!res.ok) return;
                    var data = await res.json();
                    var list = data.data || data;
                    if (Array.isArray(list)) {
                        filterCat.innerHTML = '<option value="">All Categories</option>' + list.map(function(c) {
                            return '<option value="' + c.id + '">' + esc(c.name) + '</option>';
                        }).join('');
                    }
                } catch(e) {}
            }
            loadCategoryOptions();

            function resolveImage(path) {
                if (!path) return '';
                if (path.startsWith('http')) return path;
                if (path.startsWith('/')) return path;
                return '/' + path;
            }

            function statusBadge(status) {
                var map = {
                    active: 'bg-emerald-100 text-emerald-700 dark:bg-emerald-500/10 dark:text-emerald-400',
                    draft: 'bg-amber-100 text-amber-700 dark:bg-amber-500/10 dark:text-amber-400',
                    archived: 'bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-300',
                };
                var klass = map[status] || map.archived;
                return '<span class="inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-bold uppercase whitespace-nowrap ' + klass + '">' + esc(status) + '</span>';
            }

            function warrantyBadge(warranty) {
                var map = {
                    NO_WARRANTY: { label: 'NO WARRANTY', color: '#9CA3AF', text: 'text-white' },
                    '7_DAYS': { label: '7 DAYS', color: '#F87171', text: 'text-white' },
                    '14_DAYS': { label: '14 DAYS', color: '#FB923C', text: 'text-white' },
                    '1_MONTH': { label: '1 MONTH', color: '#FACC15', text: 'text-slate-900' },
                    '3_MONTHS': { label: '3 MONTHS', color: '#4ADE80', text: 'text-slate-900' },
                    '6_MONTHS': { label: '6 MONTHS', color: '#60A5FA', text: 'text-white' },
                    '1_YEAR': { label: '1 YEAR', color: '#A78BFA', text: 'text-white' },
                };
                var info = map[warranty] || { label: warranty || '--', color: '#E5E7EB', text: 'text-slate-700' };
                return '<span class="inline-flex items-center rounded-full px-2.5 py-0.5 text-[11px] font-extrabold whitespace-nowrap ' + info.text + '" style="background-color: ' + info.color + ';">' + esc(info.label) + '</span>';
            }

            function stockBadge(stock) {
                var val = stock ?? 0;
                if (val <= 0) {
                    return '<span class="inline-flex items-center rounded-full bg-red-100 px-2.5 py-0.5 text-xs font-extrabold text-red-700 dark:bg-red-500/10 dark:text-red-400">0 (Out)</span>';
                }
                if (val <= 5) {
                    return '<span class="inline-flex items-center rounded-full bg-amber-100 px-2.5 py-0.5 text-xs font-extrabold text-amber-700 dark:bg-amber-500/10 dark:text-amber-400">' + val + ' (Low)</span>';
                }
                return '<span class="inline-flex items-center rounded-full bg-slate-100 px-2.5 py-0.5 text-xs font-bold text-slate-800 dark:bg-slate-800 dark:text-slate-200">' + val + '</span>';
            }

            function formatCurrency(value) {
                return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(value || 0);
            }

            function esc(s) {
                return String(s || '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
            }

            async function loadProducts() {
                await window.adminApi.ensureCsrfCookie();
                var params = new URLSearchParams({
                    page: currentPage,
                    per_page: currentPerPage
                });
                if (currentQuery) params.set('q', currentQuery);
                if (currentCat) params.set('category_id', currentCat);
                if (currentBrand) params.set('brand', currentBrand);
                if (currentWarranty) params.set('warranty', currentWarranty);
                if (currentStatus) params.set('status', currentStatus);

                var response = await window.adminApi.request('/api/products?' + params.toString());
                if (!response.ok) {
                    rows.innerHTML = '<tr><td class="px-5 py-10 text-center text-sm text-slate-500" colspan="12">Unable to load products.</td></tr>';
                    return;
                }
                var data = await response.json();
                var list = data.data || [];

                rows.innerHTML = list.map(function (product) {
                    var imageUrl = resolveImage(product.thumbnail);
                    return `
                        <tr class="hover:bg-slate-50/80 dark:hover:bg-slate-800/40 transition-colors">
                            <td class="px-5 py-4"><input type="checkbox" value="${product.id}" class="row-checkbox rounded border-slate-300 text-primary-600 focus:ring-primary-500 cursor-pointer" /></td>
                            <td class="px-5 py-4 min-w-[220px]">
                                <div class="flex items-center gap-3.5 min-w-0">
                                    <div class="h-10 w-10 shrink-0 overflow-hidden rounded-xl bg-slate-100 border border-slate-200/60 dark:bg-slate-800 dark:border-slate-700">
                                        ${imageUrl ? `<img src="${imageUrl}" alt="${esc(product.name)}" class="h-full w-full object-cover" />` : '<div class="flex h-full w-full items-center justify-center text-[10px] text-slate-400">No img</div>'}
                                    </div>
                                    <div class="min-w-0">
                                        <p class="font-bold text-slate-900 dark:text-white truncate" title="${esc(product.name)}">${esc(product.name)}</p>
                                        <p class="text-[11px] text-slate-400 font-mono tracking-tight">${esc(product.sku || 'No SKU')}</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-5 py-4 font-medium text-slate-700 dark:text-slate-300 whitespace-nowrap">${esc(product.category?.name ?? '--')}</td>
                            <td class="px-5 py-4 font-semibold text-slate-800 dark:text-slate-200 whitespace-nowrap">${esc(product.brand || '--')}</td>
                            <td class="px-5 py-4">${warrantyBadge(product.warranty)}</td>
                            <td class="px-5 py-4 font-extrabold text-slate-900 dark:text-white whitespace-nowrap">${formatCurrency(product.price)}</td>
                            <td class="px-5 py-4 font-semibold text-emerald-600 dark:text-emerald-400 whitespace-nowrap">${formatCurrency(product.discount)}</td>
                            <td class="px-5 py-4 text-xs text-slate-500 whitespace-nowrap">${esc(product.added_by?.name ?? '--')}</td>
                            <td class="px-5 py-4 font-semibold text-slate-700 dark:text-slate-300 whitespace-nowrap text-center">${(product.variants || []).length}</td>
                            <td class="px-5 py-4 whitespace-nowrap text-center">${stockBadge(product.stock)}</td>
                            <td class="px-5 py-4">${statusBadge(product.status)}</td>
                            <td class="px-5 py-4 text-right whitespace-nowrap">
                                <div class="inline-flex items-center gap-3">
                                    <button data-id="${product.id}" class="text-xs font-bold text-slate-500 hover:text-slate-900 dark:hover:text-slate-100 transition-colors js-view-product">View</button>
                                    ${window.adminCan('update_product') ? `<a href="/admin/products/${product.id}/edit" class="text-xs font-bold text-primary-600 hover:text-primary-700 transition-colors">Edit</a>
                                    <button data-id="${product.id}" class="text-xs font-bold text-amber-600 hover:text-amber-700 transition-colors js-toggle-status">Toggle</button>` : ''}
                                    ${window.adminCan('delete_product') ? `<button data-id="${product.id}" class="text-xs font-bold text-red-600 hover:text-red-700 transition-colors js-delete-product">Delete</button>` : ''}
                                </div>
                            </td>
                        </tr>
                    `;
                }).join('') || '<tr><td class="px-5 py-10 text-center text-xs text-slate-400" colspan="12">No products match the selected criteria.</td></tr>';

                var totalCount = data.meta?.total ?? list.length;
                info.textContent = 'Showing ' + list.length + ' of ' + totalCount + ' products';
                prevButton.disabled = !data.links?.prev;
                nextButton.disabled = !data.links?.next;

                // Reset Select All check
                selectAllCb.checked = false;
                updateSelectedCount();
            }

            // ── Checkbox & Selection Handlers ─────────────────────────────────────
            selectAllCb.addEventListener('change', function () {
                var cbs = rows.querySelectorAll('.row-checkbox');
                cbs.forEach(function (cb) { cb.checked = selectAllCb.checked; });
                updateSelectedCount();
            });

            rows.addEventListener('change', function (e) {
                if (e.target.classList.contains('row-checkbox')) {
                    updateSelectedCount();
                }
            });

            function getSelectedIds() {
                var cbs = rows.querySelectorAll('.row-checkbox:checked');
                var ids = [];
                cbs.forEach(function (cb) { ids.push(parseInt(cb.value, 10)); });
                return ids;
            }

            function updateSelectedCount() {
                var ids = getSelectedIds();
                if (ids.length > 0) {
                    selectedBadge.textContent = ids.length + ' selected';
                    selectedBadge.classList.remove('hidden');
                } else {
                    selectedBadge.classList.add('hidden');
                }
            }

            // ── Quick Actions Handler with SweetAlert ────────────────────────────
            btnApplyBulk.addEventListener('click', async function () {
                var action = bulkSelect.value;
                if (!action) {
                    if (window.adminSwalError) {
                        await window.adminSwalError('Quick Action Required', 'Please select a quick action to apply.');
                    } else if (window.Swal) {
                        await window.Swal.fire('Quick Action Required', 'Please select a quick action to apply.', 'info');
                    } else {
                        alert('Please select a quick action.');
                    }
                    return;
                }
                var ids = getSelectedIds();
                if (!ids.length) {
                    if (window.adminSwalError) {
                        await window.adminSwalError('No Products Selected', 'Please select at least one product using row checkboxes.');
                    } else if (window.Swal) {
                        await window.Swal.fire('No Products Selected', 'Please select at least one product using row checkboxes.', 'warning');
                    } else {
                        alert('Please select at least one product using checkboxes.');
                    }
                    return;
                }

                var actionMap = {
                    activate: 'activate',
                    deactivate: 'deactivate (set to draft)',
                    archive: 'archive',
                    delete: 'permanently delete'
                };
                var actionLabel = actionMap[action] || action;
                var confirmTitle = 'Confirm Quick Action';
                var confirmMessage = 'Are you sure you want to ' + actionLabel + ' ' + ids.length + ' selected product(s)?';

                var confirmed = false;
                if (window.adminSwalConfirm) {
                    var confirmResult = await window.adminSwalConfirm(confirmTitle, confirmMessage, 'Yes, apply action');
                    confirmed = confirmResult.isConfirmed;
                } else if (window.Swal) {
                    var result = await window.Swal.fire({
                        title: confirmTitle,
                        text: confirmMessage,
                        icon: action === 'delete' ? 'warning' : 'question',
                        showCancelButton: true,
                        confirmButtonColor: action === 'delete' ? '#ef4444' : '#4f46e5',
                        cancelButtonColor: '#64748b',
                        confirmButtonText: 'Yes, apply action'
                    });
                    confirmed = result.isConfirmed;
                } else {
                    confirmed = confirm(confirmMessage);
                }

                if (!confirmed) return;

                await window.adminApi.ensureCsrfCookie();
                var res = await window.adminApi.request('/api/products/bulk-action', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ action: action, ids: ids })
                });

                if (res.ok) {
                    var payload = await res.json();
                    var successMsg = payload.message || (ids.length + ' product(s) updated successfully.');
                    if (window.adminSwalSuccess) {
                        await window.adminSwalSuccess('Quick Action Completed', successMsg);
                    } else if (window.Swal) {
                        await window.Swal.fire('Success', successMsg, 'success');
                    } else if (window.adminToast) {
                        window.adminToast(successMsg);
                    }
                    bulkSelect.value = '';
                    loadProducts();
                } else {
                    var errData = await res.json().catch(function(){ return {}; });
                    var errMsg = errData.message || 'Unable to execute quick action (HTTP ' + res.status + ').';
                    if (window.adminSwalError) {
                        await window.adminSwalError('Quick Action Failed', errMsg);
                    } else if (window.Swal) {
                        await window.Swal.fire('Action Failed', errMsg, 'error');
                    } else {
                        alert(errMsg);
                    }
                }
            });

            // ── Filter Change Event Listeners ─────────────────────────────────────
            searchInput.addEventListener('input', function (event) {
                currentQuery = event.target.value.trim();
                currentPage = 1;
                loadProducts();
            });

            filterCat.addEventListener('change', function () {
                currentCat = filterCat.value;
                currentPage = 1;
                loadProducts();
            });

            filterBrand.addEventListener('change', function () {
                currentBrand = filterBrand.value;
                currentPage = 1;
                loadProducts();
            });

            filterWarranty.addEventListener('change', function () {
                currentWarranty = filterWarranty.value;
                currentPage = 1;
                loadProducts();
            });

            filterStatus.addEventListener('change', function () {
                currentStatus = filterStatus.value;
                currentPage = 1;
                loadProducts();
            });

            filterPerPage.addEventListener('change', function () {
                currentPerPage = filterPerPage.value;
                currentPage = 1;
                loadProducts();
            });

            btnReset.addEventListener('click', function () {
                searchInput.value = '';
                filterCat.value = '';
                filterBrand.value = '';
                filterWarranty.value = '';
                filterStatus.value = '';
                filterPerPage.value = '25';

                currentQuery = '';
                currentCat = '';
                currentBrand = '';
                currentWarranty = '';
                currentStatus = '';
                currentPerPage = '25';
                currentPage = 1;

                loadProducts();
            });

            prevButton.addEventListener('click', function () {
                if (currentPage > 1) {
                    currentPage -= 1;
                    loadProducts();
                }
            });

            nextButton.addEventListener('click', function () {
                currentPage += 1;
                loadProducts();
            });

            // ── Row Click Actions ──────────────────────────────────────────────────
            rows.addEventListener('click', async function (event) {
                var target = event.target;
                if (target.classList.contains('js-view-product')) {
                    await window.adminApi.ensureCsrfCookie();
                    var response = await window.adminApi.request('/api/products/' + target.dataset.id);
                    if (!response.ok) {
                        alert('Unable to load product details.');
                        return;
                    }

                    var payload = await response.json();
                    var product = payload.data || payload;
                    var imageUrl = resolveImage(product.thumbnail || product.image);
                    var badge = statusBadge(product.status || 'archived');
                    var variants = Array.isArray(product.variants) ? product.variants : [];
                    var variantRows = variants.slice(0, 8).map(function (variant) {
                        var label = [variant.storage_capacity, variant.color, variant.condition].filter(Boolean).join(' / ');
                        return '<tr>' +
                            '<td class="px-2 py-1 text-slate-500">' + esc(label) + '</td>' +
                            '<td class="px-2 py-1 text-right text-slate-900">' + formatCurrency(variant.price || 0) + '</td>' +
                            '<td class="px-2 py-1 text-right text-slate-900">' + (variant.stock ?? 0) + '</td>' +
                            '</tr>';
                    }).join('');

                    var html = `
                        <div class="text-left">
                            <div class="flex items-center gap-4">
                                <div class="h-20 w-20 overflow-hidden rounded-2xl border border-slate-200 bg-slate-50 shrink-0">
                                    ${imageUrl ? `<img src="${imageUrl}" alt="${esc(product.name)}" class="h-full w-full object-cover" />` : '<div class="flex h-full w-full items-center justify-center text-xs text-slate-400">No image</div>'}
                                </div>
                                <div>
                                    <p class="text-xs uppercase tracking-widest text-slate-400 font-bold">Product</p>
                                    <p class="text-lg font-bold text-slate-900">${esc(product.name || '--')}</p>
                                    <div class="mt-2">${badge}</div>
                                </div>
                            </div>
                            <div class="mt-5 grid gap-3 rounded-2xl border border-slate-200 bg-slate-50 p-4 text-sm text-slate-600">
                                <div class="flex items-center justify-between gap-4"><span class="font-semibold text-slate-500">SKU</span><span class="text-slate-900 font-mono">${esc(product.sku || '--')}</span></div>
                                <div class="flex items-center justify-between gap-4"><span class="font-semibold text-slate-500">Brand</span><span class="text-slate-900">${esc(product.brand || '--')}</span></div>
                                <div class="flex items-center justify-between gap-4"><span class="font-semibold text-slate-500">Category</span><span class="text-slate-900">${esc(product.category?.name ?? '--')}</span></div>
                                <div class="flex items-center justify-between gap-4"><span class="font-semibold text-slate-500">Warranty</span><span>${warrantyBadge(product.warranty)}</span></div>
                                <div class="flex items-center justify-between gap-4"><span class="font-semibold text-slate-500">Price</span><span class="text-slate-900 font-bold">${formatCurrency(product.price)}</span></div>
                                <div class="flex items-center justify-between gap-4"><span class="font-semibold text-slate-500">Discount</span><span class="text-slate-900">${formatCurrency(product.discount)}</span></div>
                                <div class="flex items-center justify-between gap-4"><span class="font-semibold text-slate-500">Stock</span><span class="text-slate-900 font-bold">${product.stock ?? 0}</span></div>
                            </div>
                        </div>
                    `;

                    if (window.Swal) {
                        await window.Swal.fire({
                            title: 'Product Details',
                            html: html,
                            confirmButtonColor: '#4f46e5',
                            width: 550,
                            padding: '1.5rem',
                        });
                    }
                }

                if (target.classList.contains('js-toggle-status')) {
                    await window.adminApi.ensureCsrfCookie();
                    var response = await window.adminApi.request('/api/products/' + target.dataset.id + '/status', { method: 'PATCH' });
                    if (response.ok && window.adminToast) {
                        window.adminToast('Product status updated.');
                    }
                    loadProducts();
                }

                if (target.classList.contains('js-delete-product')) {
                    if (!confirm('Delete this product from catalog?')) return;
                    await window.adminApi.ensureCsrfCookie();
                    var response = await window.adminApi.request('/api/products/' + target.dataset.id, { method: 'DELETE' });
                    if (response.ok && window.adminToast) {
                        window.adminToast('Product deleted.');
                    }
                    loadProducts();
                }
            });

            loadProducts();
        });
    </script>
@endsection
