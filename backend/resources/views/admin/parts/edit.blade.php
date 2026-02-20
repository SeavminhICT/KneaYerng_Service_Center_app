@extends('layouts.admin')

@section('title', 'Edit Part')
@section('page-title', 'Edit Part')

@section('content')
    <div class="grid gap-6 lg:grid-cols-[2fr_1fr]">
        <form id="part-edit-form" class="space-y-6 rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900" data-part-id="{{ $partId ?? '' }}">
            <div>
                <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Update Part</h2>
                <p class="text-sm text-slate-500">Edit part details and stock.</p>
            </div>

            <div class="grid gap-4 sm:grid-cols-2">
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="name">Name</label>
                    <input id="name" name="name" type="text" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    <p id="part-name-error" class="mt-2 text-xs text-danger-600"></p>
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="type">Type</label>
                    <input id="type" name="type" type="text" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>
            </div>

            <div class="grid gap-4 sm:grid-cols-3">
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="brand">Brand</label>
                    <input id="brand" name="brand" type="text" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="sku">SKU</label>
                    <input id="sku" name="sku" type="text" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="stock">Parts Stock</label>
                    <input id="stock" name="stock" type="number" min="0" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    <p id="part-stock-error" class="mt-2 text-xs text-danger-600"></p>
                </div>
            </div>

            <div class="grid gap-4 sm:grid-cols-3">
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="unit_cost">Unit Cost</label>
                    <input id="unit_cost" name="unit_cost" type="number" step="0.01" min="0" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    <p id="part-cost-error" class="mt-2 text-xs text-danger-600"></p>
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="status">Status</label>
                    <select id="status" name="status" class="mt-2 w-full appearance-none rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                        <option value="active">Active</option>
                        <option value="inactive">Inactive</option>
                        <option value="archived">Archived</option>
                    </select>
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="tag">Tag</label>
                    <select id="tag" name="tag" class="mt-2 w-full appearance-none rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                        <option value="">No tag</option>
                        @foreach (\App\Models\Part::TAGS as $tag)
                            <option value="{{ $tag }}">
                                {{ \Illuminate\Support\Str::title(str_replace('_', ' ', strtolower($tag))) }}
                            </option>
                        @endforeach
                    </select>
                </div>
            </div>

            <div class="flex items-center gap-3">
                <button class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white shadow-sm">Save Changes</button>
                <a href="{{ route('admin.parts.index') }}" class="text-sm font-semibold text-slate-500">Cancel</a>
            </div>
            <p id="part-form-error" class="text-sm text-danger-600"></p>
        </form>

        <div class="space-y-6">
            <div class="rounded-2xl border border-danger-100 bg-danger-50 p-5 text-xs text-danger-700 dark:border-danger-500/30 dark:bg-danger-500/10 dark:text-danger-100">
                <p class="font-semibold">Delete part</p>
                <p class="mt-2">Deleting will remove the part from inventory.</p>
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

        document.addEventListener('DOMContentLoaded', async function () {
            var form = document.getElementById('part-edit-form');
            var partId = form.dataset.partId;
            if (!partId) {
                return;
            }

            await window.adminApi.ensureCsrfCookie();
            var response = await window.adminApi.request('/api/parts/' + partId);
            if (response.ok) {
                var payload = await response.json();
                var part = payload.data || payload;
                document.getElementById('name').value = part.name || '';
                document.getElementById('type').value = part.type || '';
                document.getElementById('brand').value = part.brand || '';
                document.getElementById('sku').value = part.sku || '';
                document.getElementById('stock').value = part.stock ?? 0;
                document.getElementById('unit_cost').value = part.unit_cost ?? 0;
                document.getElementById('status').value = part.status || 'active';
                document.getElementById('tag').value = part.tag || '';
            }
        });

        document.getElementById('part-edit-form').addEventListener('submit', async function (event) {
            event.preventDefault();
            document.getElementById('part-form-error').textContent = '';
            document.getElementById('part-name-error').textContent = '';
            document.getElementById('part-stock-error').textContent = '';
            document.getElementById('part-cost-error').textContent = '';

            var form = event.target;
            var partId = form.dataset.partId;

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
                var response = await window.adminApi.request('/api/parts/' + partId, {
                    method: 'PATCH',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(payload),
                });

                if (response.ok) {
                    if (window.adminSwalStore) {
                        window.adminSwalStore({
                            icon: 'success',
                            title: 'Part updated',
                            text: 'Part updated successfully.',
                            confirmButtonColor: '#2563eb',
                        });
                    } else if (window.adminToastStore) {
                        window.adminToastStore({ type: 'success', message: 'Part updated successfully.' });
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
                document.getElementById('part-form-error').textContent = errorData.message || 'Unable to update part.';
                if (window.adminSwalError) {
                    window.adminSwalError('Update failed', errorData.message || 'Unable to update part.');
                } else if (window.adminToast) {
                    window.adminToast(errorData.message || 'Unable to update part.', { type: 'error' });
                }
            } catch (error) {
                document.getElementById('part-form-error').textContent = 'Unable to update part.';
                if (window.adminSwalError) {
                    window.adminSwalError('Update failed', 'Unable to update part.');
                } else if (window.adminToast) {
                    window.adminToast('Unable to update part.', { type: 'error' });
                }
            }
        });
    </script>
@endsection
