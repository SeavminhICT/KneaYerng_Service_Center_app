@extends('layouts.admin')

@section('title', 'Create Part')
@section('page-title', 'Create Part')

@section('content')
    <div class="grid gap-6 lg:grid-cols-[2fr_1fr]">
        <form id="part-create-form" class="space-y-6 rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <div>
                <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Part Details</h2>
                <p class="text-sm text-slate-500">Add a new repair part to the inventory.</p>
            </div>

            <div class="grid gap-4 sm:grid-cols-2">
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="name">Name</label>
                    <input id="name" name="name" type="text" placeholder="Battery" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    <p id="part-name-error" class="mt-2 text-xs text-danger-600"></p>
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="type">Type</label>
                    <input id="type" name="type" type="text" placeholder="Replacement" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>
            </div>

            <div class="grid gap-4 sm:grid-cols-3">
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="brand">Brand</label>
                    <input id="brand" name="brand" type="text" placeholder="IPHONE" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="sku">SKU</label>
                    <input id="sku" name="sku" type="text" placeholder="Optional" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="stock">Parts Stock</label>
                    <input id="stock" name="stock" type="number" min="0" value="0" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    <p id="part-stock-error" class="mt-2 text-xs text-danger-600"></p>
                </div>
            </div>

            <div class="grid gap-4 sm:grid-cols-3">
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="unit_cost">Unit Cost</label>
                    <input id="unit_cost" name="unit_cost" type="number" step="0.01" min="0" value="0" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    <p id="part-cost-error" class="mt-2 text-xs text-danger-600"></p>
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="status">Status</label>
                    <select id="status" name="status" class="mt-2 w-full appearance-none rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                        <option value="active" selected>Active</option>
                        <option value="inactive">Inactive</option>
                        <option value="archived">Archived</option>
                    </select>
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="tag">Tag</label>
                    <select id="tag" name="tag" class="mt-2 w-full appearance-none rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                        <option value="">No tag</option>
                        <option value="HOT_SALE">Hot Sale</option>
                        <option value="TOP_SELLER">Top Seller</option>
                        <option value="PROMOTION">Promotion</option>
                    </select>
                </div>
            </div>

            <div class="flex items-center gap-3">
                <button class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white shadow-sm">Save Part</button>
                <a href="{{ route('admin.parts.index') }}" class="text-sm font-semibold text-slate-500">Cancel</a>
            </div>
            <p id="part-form-error" class="text-sm text-danger-600"></p>
        </form>

        <div class="space-y-6">
            <div class="rounded-2xl border border-slate-200 bg-slate-50 p-5 text-xs text-slate-500 dark:border-slate-800 dark:bg-slate-950">
                <p class="font-semibold text-slate-700 dark:text-slate-200">Inventory tips</p>
                <p class="mt-2">Keep part stock updated to avoid overbooking repairs.</p>
            </div>
        </div>
    </div>

    <script>
        function parseNumber(value) {
            if (value === null || value === undefined || value === '') {
                return null;
            }
            var num = Number(value);
            return Number.isFinite(num) ? num : null;
        }

        function parseInteger(value) {
            if (value === null || value === undefined || value === '') {
                return null;
            }
            var num = parseInt(value, 10);
            return Number.isFinite(num) ? num : null;
        }

        document.getElementById('part-create-form').addEventListener('submit', async function (event) {
            event.preventDefault();
            document.getElementById('part-form-error').textContent = '';
            document.getElementById('part-name-error').textContent = '';
            document.getElementById('part-stock-error').textContent = '';
            document.getElementById('part-cost-error').textContent = '';

            var form = event.target;
            var payload = {
                name: (form.name.value || '').trim(),
                type: (form.type.value || '').trim() || null,
                brand: (form.brand.value || '').trim() || null,
                sku: (form.sku.value || '').trim() || null,
                stock: parseInteger(form.stock.value) ?? 0,
                unit_cost: parseNumber(form.unit_cost.value) ?? 0,
                status: form.status.value,
                tag: form.tag.value || null,
            };

            try {
                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/parts', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(payload),
                });

                if (response.ok) {
                    if (window.adminSwalStore) {
                        window.adminSwalStore({
                            icon: 'success',
                            title: 'Part created',
                            text: 'Part created successfully.',
                            confirmButtonColor: '#2563eb',
                        });
                    } else if (window.adminToastStore) {
                        window.adminToastStore({ type: 'success', message: 'Part created successfully.' });
                    }
                    window.location.href = '/admin/parts';
                    return;
                }

                var errorData = await response.json();
                if (errorData.errors?.name) {
                    document.getElementById('part-name-error').textContent = errorData.errors.name[0];
                }
                if (errorData.errors?.stock) {
                    document.getElementById('part-stock-error').textContent = errorData.errors.stock[0];
                }
                if (errorData.errors?.unit_cost) {
                    document.getElementById('part-cost-error').textContent = errorData.errors.unit_cost[0];
                }
                document.getElementById('part-form-error').textContent = errorData.message || 'Unable to save part.';
                if (window.adminSwalError) {
                    window.adminSwalError('Create failed', errorData.message || 'Unable to save part.');
                } else if (window.adminToast) {
                    window.adminToast(errorData.message || 'Unable to save part.', { type: 'error' });
                }
            } catch (error) {
                document.getElementById('part-form-error').textContent = 'Unable to save part.';
                if (window.adminSwalError) {
                    window.adminSwalError('Create failed', 'Unable to save part.');
                } else if (window.adminToast) {
                    window.adminToast('Unable to save part.', { type: 'error' });
                }
            }
        });
    </script>
@endsection
