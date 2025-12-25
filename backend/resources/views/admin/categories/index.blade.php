@extends('layouts.admin')

@section('title', 'Categories')
@section('page-title', 'Categories')

@section('content')
    <div class="space-y-6">
        <div class="flex flex-wrap items-center justify-between gap-4">
            <div>
                <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Category List</h2>
                <p class="text-sm text-slate-500">Organize product collections for the app catalog.</p>
            </div>
            <div class="flex items-center gap-3">
                <a href="{{ route('admin.categories.create') }}" class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white shadow-sm">Add Category</a>
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
                    <input type="text" placeholder="Search categories" class="h-10 w-60 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
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
                            <th class="px-4 py-3"><input type="checkbox" class="rounded border-slate-300 text-primary-600 focus:ring-primary-500" /></th>
                            <th class="px-4 py-3">Image</th>
                            <th class="px-4 py-3">
                                <button class="inline-flex items-center gap-1 text-xs font-semibold uppercase tracking-widest text-slate-400">
                                    Category
                                    <svg class="h-3 w-3" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M8 9l4-4 4 4M16 15l-4 4-4-4" />
                                    </svg>
                                </button>
                            </th>
                            <th class="px-4 py-3">Slug</th>
                            <th class="px-4 py-3">
                                <button class="inline-flex items-center gap-1 text-xs font-semibold uppercase tracking-widest text-slate-400">
                                    Products
                                    <svg class="h-3 w-3" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M8 9l4-4 4 4M16 15l-4 4-4-4" />
                                    </svg>
                                </button>
                            </th>
                            <th class="px-4 py-3">Status</th>
                            <th class="px-4 py-3 text-right">Action</th>
                        </tr>
                    </thead>
                    <tbody id="category-rows" class="divide-y divide-slate-200 text-slate-600 dark:divide-slate-800 dark:text-slate-300"></tbody>
                </table>
            </div>

            <div class="mt-4 flex items-center justify-between text-xs text-slate-500">
                <p id="category-pagination-info">Loading categories...</p>
                <div class="flex items-center gap-2">
                    <button id="category-prev" class="rounded-lg border border-slate-200 px-3 py-1 text-slate-600 dark:border-slate-800 dark:text-slate-300">Previous</button>
                    <button id="category-next" class="rounded-lg border border-slate-200 bg-slate-100 px-3 py-1 text-slate-900 dark:border-slate-800 dark:bg-slate-900">Next</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var currentPage = 1;
            var currentQuery = '';

            var searchInput = document.querySelector('input[placeholder="Search categories"]');
            var prevButton = document.getElementById('category-prev');
            var nextButton = document.getElementById('category-next');
            var info = document.getElementById('category-pagination-info');
            var rows = document.getElementById('category-rows');

            async function loadCategories() {
                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/categories?q=' + encodeURIComponent(currentQuery) + '&page=' + currentPage);
                if (!response.ok) {
                    rows.innerHTML = '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="7">Unable to load categories.</td></tr>';
                    return;
                }
                var data = await response.json();
                var list = data.data || [];

                function statusBadge(status) {
                    var map = {
                        active: 'bg-success-50 text-success-700 dark:bg-success-500/10 dark:text-success-100',
                        inactive: 'bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-300',
                    };
                    var klass = map[status] || map.inactive;
                    return '<span class="rounded-full px-2 py-1 text-xs font-semibold ' + klass + '">' + status + '</span>';
                }

                function resolveImage(path) {
                    if (!path) {
                        return '/images/category-placeholder.svg';
                    }
                    if (path.startsWith('http')) {
                        return path;
                    }
                    if (path.startsWith('/')) {
                        return path;
                    }
                    return '/' + path;
                }

                rows.innerHTML = list.map(function (category) {
                    var imageUrl = resolveImage(category.image);
                    return `
                        <tr>
                            <td class="px-4 py-3"><input type="checkbox" class="rounded border-slate-300 text-primary-600 focus:ring-primary-500" /></td>
                            <td class="px-4 py-3">
                                <div class="h-10 w-10 overflow-hidden rounded-xl bg-slate-100">
                                    ${imageUrl ? `<img src="${imageUrl}" alt="${category.name}" class="h-full w-full object-cover" />` : ''}
                                </div>
                            </td>
                            <td class="px-4 py-3">
                                <div class="flex items-center gap-3">
                                    <div>
                                        <p class="font-semibold text-slate-900 dark:text-white">${category.name}</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-4 py-3">${category.slug}</td>
                            <td class="px-4 py-3">${category.products_count ?? 0}</td>
                            <td class="px-4 py-3">${statusBadge(category.status || 'inactive')}</td>
                            <td class="px-4 py-3 text-right">
                                <a href="/admin/categories/${category.id}/edit" class="text-xs font-semibold text-primary-600">Edit</a>
                            </td>
                        </tr>
                    `;
                }).join('') || '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="7">No categories found.</td></tr>';

                info.textContent = 'Showing ' + list.length + ' of ' + (data.meta?.total ?? list.length) + ' categories';
                prevButton.disabled = !data.links?.prev;
                nextButton.disabled = !data.links?.next;
            }

            searchInput.addEventListener('input', function (event) {
                currentQuery = event.target.value.trim();
                currentPage = 1;
                loadCategories();
            });

            prevButton.addEventListener('click', function () {
                if (currentPage > 1) {
                    currentPage -= 1;
                    loadCategories();
                }
            });

            nextButton.addEventListener('click', function () {
                currentPage += 1;
                loadCategories();
            });

            loadCategories();
        });
    </script>
@endsection
