@extends('layouts.admin')

@section('title', 'Products')
@section('page-title', 'Products')

@section('content')
    <div class="space-y-6">
        <div class="flex flex-wrap items-center justify-between gap-4">
            <div>
                <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Product List</h2>
                <p class="text-sm text-slate-500">Manage inventory and availability for the mobile app.</p>
            </div>
            <div class="flex items-center gap-3">
                <a href="{{ route('admin.products.create') }}" class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white shadow-sm">Add Product</a>
            </div>
        </div>

        <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <div class="flex flex-wrap items-center justify-between gap-3">
                <div class="flex flex-wrap items-center gap-3">
                    <select class="h-10 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300">
                        <option>Bulk actions</option>
                        <option>Activate</option>
                        <option>Deactivate</option>
                        <option>Archive</option>
                    </select>
                    <button class="h-10 rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-600 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300">Apply</button>
                </div>
                <div class="relative">
                    <input type="text" placeholder="Search products" class="h-10 w-60 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
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
                            <th class="px-4 py-3">
                                <button class="inline-flex items-center gap-1 text-xs font-semibold uppercase tracking-widest text-slate-400">
                                    Product
                                    <svg class="h-3 w-3" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M8 9l4-4 4 4M16 15l-4 4-4-4" />
                                    </svg>
                                </button>
                            </th>
                            <th class="px-4 py-3">Category</th>
                            <th class="px-4 py-3">Brand</th>
                            <th class="px-4 py-3">
                                <button class="inline-flex items-center gap-1 text-xs font-semibold uppercase tracking-widest text-slate-400">
                                    Price
                                    <svg class="h-3 w-3" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M8 9l4-4 4 4M16 15l-4 4-4-4" />
                                    </svg>
                                </button>
                            </th>
                            <th class="px-4 py-3">Discount</th>
                            <th class="px-4 py-3">
                                <button class="inline-flex items-center gap-1 text-xs font-semibold uppercase tracking-widest text-slate-400">
                                    Stock
                                    <svg class="h-3 w-3" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M8 9l4-4 4 4M16 15l-4 4-4-4" />
                                    </svg>
                                </button>
                            </th>
                            <th class="px-4 py-3">Status</th>
                            <th class="px-4 py-3 text-right">Action</th>
                        </tr>
                    </thead>
                    <tbody id="product-rows" class="divide-y divide-slate-200 text-slate-600 dark:divide-slate-800 dark:text-slate-300"></tbody>
                </table>
            </div>

            <div class="mt-4 flex items-center justify-between text-xs text-slate-500">
                <p id="product-pagination-info">Loading products...</p>
                <div class="flex items-center gap-2">
                    <button id="product-prev" class="rounded-lg border border-slate-200 px-3 py-1 text-slate-600 dark:border-slate-800 dark:text-slate-300">Previous</button>
                    <button id="product-next" class="rounded-lg border border-slate-200 bg-slate-100 px-3 py-1 text-slate-900 dark:border-slate-800 dark:bg-slate-900">Next</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var currentPage = 1;
            var currentQuery = '';

            var searchInput = document.querySelector('input[placeholder="Search products"]');
            var prevButton = document.getElementById('product-prev');
            var nextButton = document.getElementById('product-next');
            var info = document.getElementById('product-pagination-info');
            var rows = document.getElementById('product-rows');

            function resolveImage(path) {
                if (!path) {
                    return '';
                }
                if (path.startsWith('http')) {
                    return path;
                }
                if (path.startsWith('/')) {
                    return path;
                }
                return '/' + path;
            }

            function statusBadge(status) {
                var map = {
                    active: 'bg-success-50 text-success-700 dark:bg-success-500/10 dark:text-success-100',
                    draft: 'bg-warning-50 text-warning-700 dark:bg-warning-500/10 dark:text-warning-100',
                    archived: 'bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-300',
                };
                var klass = map[status] || map.archived;
                return '<span class="rounded-full px-2 py-1 text-xs font-semibold ' + klass + '">' + status + '</span>';
            }

            async function loadProducts() {
                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/products?q=' + encodeURIComponent(currentQuery) + '&page=' + currentPage);
                if (!response.ok) {
                    rows.innerHTML = '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="9">Unable to load products.</td></tr>';
                    return;
                }
                var data = await response.json();
                var list = data.data || [];

                rows.innerHTML = list.map(function (product) {
                    var imageUrl = resolveImage(product.thumbnail);
                    return `
                        <tr>
                            <td class="px-4 py-3"><input type="checkbox" class="rounded border-slate-300 text-primary-600 focus:ring-primary-500" /></td>
                            <td class="px-4 py-3">
                                <div class="flex items-center gap-3">
                                    <div class="h-9 w-9 overflow-hidden rounded-xl bg-slate-100">
                                        ${imageUrl ? `<img src="${imageUrl}" alt="${product.name}" class="h-full w-full object-cover" />` : ''}
                                    </div>
                                    <div>
                                        <p class="font-semibold text-slate-900 dark:text-white">${product.name}</p>
                                        <p class="text-xs text-slate-500">${product.sku || 'No SKU'}</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-4 py-3">${product.category?.name ?? '--'}</td>
                            <td class="px-4 py-3">${product.brand || '--'}</td>
                            <td class="px-4 py-3">${new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(product.price || 0)}</td>
                            <td class="px-4 py-3">${new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(product.discount || 0)}</td>
                            <td class="px-4 py-3">${product.stock}</td>
                            <td class="px-4 py-3">${statusBadge(product.status)}</td>
                            <td class="px-4 py-3 text-right">
                                <a href="/admin/products/${product.id}/edit" class="text-xs font-semibold text-primary-600">Edit</a>
                                <button data-id="${product.id}" class="ml-3 text-xs font-semibold text-slate-500 js-toggle-status">Toggle</button>
                                <button data-id="${product.id}" class="ml-3 text-xs font-semibold text-danger-600 js-delete-product">Delete</button>
                            </td>
                        </tr>
                    `;
                }).join('') || '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="9">No products found.</td></tr>';

                info.textContent = 'Showing ' + list.length + ' of ' + (data.meta?.total ?? list.length) + ' products';
                prevButton.disabled = !data.links?.prev;
                nextButton.disabled = !data.links?.next;
            }

            searchInput.addEventListener('input', function (event) {
                currentQuery = event.target.value.trim();
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

            rows.addEventListener('click', async function (event) {
                var target = event.target;
                if (target.classList.contains('js-toggle-status')) {
                    await window.adminApi.ensureCsrfCookie();
                    await window.adminApi.request('/api/products/' + target.dataset.id + '/status', { method: 'PATCH' });
                    loadProducts();
                }
                if (target.classList.contains('js-delete-product')) {
                    await window.adminApi.ensureCsrfCookie();
                    await window.adminApi.request('/api/products/' + target.dataset.id, { method: 'DELETE' });
                    loadProducts();
                }
            });

            loadProducts();
        });
    </script>
@endsection
