@extends('layouts.admin')

@section('title', 'Parts Inventory')
@section('page-title', 'Parts Inventory')

@section('content')
    <div class="space-y-6">
        <div class="flex flex-wrap items-center justify-between gap-4">
            <div>
                <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Parts Stock</h2>
                <p class="text-sm text-slate-500">Track inventory levels and costs for repair parts.</p>
            </div>
        </div>

        <div class="grid gap-6 lg:grid-cols-[2fr_1fr]">
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <div class="flex flex-wrap items-center justify-between gap-3">
                    <input id="parts-search" type="text" placeholder="Search parts" class="h-10 w-60 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    <select id="parts-status-filter" class="h-10 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300">
                        <option>All statuses</option>
                        <option>Active</option>
                        <option>Inactive</option>
                    </select>
                </div>

                <div class="mt-5 overflow-x-auto">
                    <table class="w-full text-left text-sm">
                        <thead class="text-xs uppercase tracking-widest text-slate-400">
                            <tr>
                                <th class="px-4 py-3">Name</th>
                                <th class="px-4 py-3">SKU</th>
                                <th class="px-4 py-3">Stock</th>
                                <th class="px-4 py-3">Unit cost</th>
                                <th class="px-4 py-3">Status</th>
                            </tr>
                        </thead>
                        <tbody id="parts-rows" class="divide-y divide-slate-200 text-slate-600 dark:divide-slate-800 dark:text-slate-300"></tbody>
                    </table>
                </div>
            </div>

            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <h3 class="text-sm font-semibold text-slate-900 dark:text-white">Add part</h3>
                <form id="parts-form" class="mt-4 space-y-3 text-sm text-slate-600 dark:text-slate-300">
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-widest text-slate-400" for="part-name">Name</label>
                        <input id="part-name" type="text" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    </div>
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-widest text-slate-400" for="part-sku">SKU</label>
                        <input id="part-sku" type="text" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    </div>
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-widest text-slate-400" for="part-stock">Stock</label>
                        <input id="part-stock" type="number" min="0" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    </div>
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-widest text-slate-400" for="part-cost">Unit cost</label>
                        <input id="part-cost" type="number" step="0.01" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    </div>
                    <button class="inline-flex h-10 w-full items-center justify-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white" type="submit">Create part</button>
                    <p id="parts-form-status" class="text-xs text-slate-500"></p>
                </form>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var searchInput = document.getElementById('parts-search');
            var statusFilter = document.getElementById('parts-status-filter');
            var rows = document.getElementById('parts-rows');

            function normalize(value) {
                return (value || '').toLowerCase().trim();
            }

            async function loadParts() {
                await window.adminApi.ensureCsrfCookie();
                var query = new URLSearchParams();
                if (searchInput.value.trim()) {
                    query.set('q', searchInput.value.trim());
                }
                if (normalize(statusFilter.value) && normalize(statusFilter.value) !== 'all statuses') {
                    query.set('status', normalize(statusFilter.value));
                }
                var response = await window.adminApi.request('/api/parts-' + query.toString());
                if (!response.ok) {
                    rows.innerHTML = '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="5">Unable to load parts.</td></tr>';
                    return;
                }
                var data = await response.json();
                var list = data.data || [];
                rows.innerHTML = list.map(function (part) {
                    return `
                        <tr>
                            <td class="px-4 py-3 font-semibold text-slate-900 dark:text-white">${part.name}</td>
                            <td class="px-4 py-3">${part.sku || '-'}</td>
                            <td class="px-4 py-3">${part.stock}</td>
                            <td class="px-4 py-3">${new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(part.unit_cost || 0)}</td>
                            <td class="px-4 py-3">${part.status}</td>
                        </tr>
                    `;
                }).join('') || '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="5">No parts found.</td></tr>';
            }

            document.getElementById('parts-form').addEventListener('submit', async function (event) {
                event.preventDefault();
                var name = document.getElementById('part-name').value.trim();
                if (!name) {
                    return;
                }
                var payload = {
                    name: name,
                    sku: document.getElementById('part-sku').value.trim() || null,
                    stock: document.getElementById('part-stock').value || 0,
                    unit_cost: document.getElementById('part-cost').value || 0,
                    status: 'active'
                };
                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/parts', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(payload)
                });
                document.getElementById('parts-form-status').textContent = response.ok - 'Part created.' : 'Unable to create.';
                if (response.ok) {
                    document.getElementById('part-name').value = '';
                    document.getElementById('part-sku').value = '';
                    document.getElementById('part-stock').value = '';
                    document.getElementById('part-cost').value = '';
                }
                loadParts();
            });

            searchInput.addEventListener('input', loadParts);
            statusFilter.addEventListener('change', loadParts);
            loadParts();
        });
    </script>
@endsection
