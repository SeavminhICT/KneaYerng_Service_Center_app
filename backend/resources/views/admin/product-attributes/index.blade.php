@extends('layouts.admin')

@section('title', 'Product Master')
@section('page-title', 'Product Master')

@section('content')
    <div class="space-y-6">
        <div class="flex flex-wrap items-center justify-between gap-4">
            <div>
                <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Product Master</h2>
                <p class="text-sm text-slate-500">Manage selectable options for products (storage, color, specs, and more).</p>
            </div>
        </div>

        <div class="grid gap-6 lg:grid-cols-[1.2fr_2fr]">
            <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <h3 class="text-sm font-semibold text-slate-900 dark:text-white">Add Option</h3>
                <p class="mt-1 text-xs text-slate-500">Create new values that appear in product create/edit.</p>

                <form id="master-create-form" class="mt-4 space-y-4">
                    <div>
                        <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="master-type">Attribute</label>
                        <select id="master-type" name="type" class="mt-2 w-full appearance-none rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                            <option value="storage_capacity">Storage Capacity</option>
                            <option value="color">Color</option>
                            <option value="condition">Condition</option>
                            <option value="ram">RAM</option>
                            <option value="ssd">SSD</option>
                            <option value="cpu">CPU</option>
                            <option value="display">Display</option>
                            <option value="country">Country</option>
                        </select>
                    </div>
                    <div>
                        <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="master-value">Value</label>
                        <input id="master-value" name="value" type="text" placeholder="e.g. 256GB" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                        <p id="master-value-error" class="mt-2 text-xs text-danger-600"></p>
                    </div>
                    <button class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white shadow-sm">Add Option</button>
                    <p id="master-form-error" class="text-xs text-danger-600"></p>
                </form>
            </div>

            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <div class="flex flex-wrap items-center justify-between gap-3">
                    <div class="flex items-center gap-3">
                        <select id="master-filter" class="h-10 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300">
                            <option value="storage_capacity">Storage Capacity</option>
                            <option value="color">Color</option>
                            <option value="condition">Condition</option>
                            <option value="ram">RAM</option>
                            <option value="ssd">SSD</option>
                            <option value="cpu">CPU</option>
                            <option value="display">Display</option>
                            <option value="country">Country</option>
                        </select>
                    </div>
                    <div class="relative">
                        <input id="master-search" type="text" placeholder="Search values" class="h-10 w-60 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                        <svg class="absolute right-3 top-3 h-4 w-4 text-slate-400" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-4.35-4.35m1.6-5.15a7 7 0 11-14 0 7 7 0 0114 0z" />
                        </svg>
                    </div>
                </div>

                <div class="mt-5 overflow-x-auto">
                    <table class="w-full text-left text-sm">
                        <thead class="text-xs uppercase tracking-widest text-slate-400">
                            <tr>
                                <th class="px-4 py-3">Value</th>
                                <th class="px-4 py-3">Type</th>
                            </tr>
                        </thead>
                        <tbody id="master-rows" class="divide-y divide-slate-200 text-slate-600 dark:divide-slate-800 dark:text-slate-300"></tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var filterSelect = document.getElementById('master-filter');
            var searchInput = document.getElementById('master-search');
            var rows = document.getElementById('master-rows');

            async function loadOptions() {
                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/product-attributes?type=' + encodeURIComponent(filterSelect.value));
                if (!response.ok) {
                    rows.innerHTML = '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="2">Unable to load options.</td></tr>';
                    return;
                }
                var data = await response.json();
                var list = data.data || [];
                var query = (searchInput.value || '').trim().toLowerCase();
                if (query) {
                    list = list.filter(function (item) {
                        return String(item.value || '').toLowerCase().includes(query);
                    });
                }

                rows.innerHTML = list.map(function (item) {
                    return `
                        <tr>
                            <td class="px-4 py-3">${item.value}</td>
                            <td class="px-4 py-3">${item.type}</td>
                        </tr>
                    `;
                }).join('') || '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="2">No options found.</td></tr>';
            }

            filterSelect.addEventListener('change', loadOptions);
            searchInput.addEventListener('input', loadOptions);

            document.getElementById('master-create-form').addEventListener('submit', async function (event) {
                event.preventDefault();
                document.getElementById('master-form-error').textContent = '';
                document.getElementById('master-value-error').textContent = '';

                var type = document.getElementById('master-type').value;
                var valueInput = document.getElementById('master-value');
                var value = (valueInput.value || '').trim();

                if (!value) {
                    document.getElementById('master-value-error').textContent = 'Value is required.';
                    return;
                }

                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/product-attributes', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ type: type, value: value }),
                });

                if (response.ok) {
                    valueInput.value = '';
                    filterSelect.value = type;
                    await loadOptions();
                    if (window.adminToast) {
                        window.adminToast('Option added.');
                    }
                    return;
                }

                var errorData = await response.json();
                if (errorData.errors?.value) {
                    document.getElementById('master-value-error').textContent = errorData.errors.value[0];
                }
                document.getElementById('master-form-error').textContent = errorData.message || 'Unable to add option.';
                if (window.adminToast) {
                    window.adminToast(errorData.message || 'Unable to add option.', { type: 'error' });
                }
            });

            loadOptions();
        });
    </script>
@endsection
