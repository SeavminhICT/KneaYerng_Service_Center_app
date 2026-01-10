@extends('layouts.admin')

@section('title', 'Edit Accessory')
@section('page-title', 'Edit Accessory')

@section('content')
    <div class="grid gap-6 lg:grid-cols-[2fr_1fr]">
        <form id="accessory-edit-form" class="space-y-6 rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900" data-accessory-id="{{ $accessoryId ?? '' }}">
            <div>
                <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Update Accessory</h2>
                <p class="text-sm text-slate-500">Update accessory and repair part details.</p>
            </div>

            <div class="grid gap-4 sm:grid-cols-2">
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="name">Name</label>
                    <input id="name" name="name" type="text" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="brand">Brand</label>
                    <select id="brand" name="brand" class="mt-2 w-full appearance-none rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                        <option value="IPHONE">IPHONE</option>
                        <option value="SAMSUNG">SAMSUNG</option>
                    </select>
                </div>
            </div>

            <div class="grid gap-4 sm:grid-cols-2">
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="price">Price</label>
                    <input id="price" name="price" type="number" step="0.01" min="0" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="discount">Discount</label>
                    <input id="discount" name="discount" type="number" step="0.01" min="0" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>
            </div>

            <div class="grid gap-4 sm:grid-cols-2">
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="warranty">Warranty</label>
                    <select id="warranty" name="warranty" class="mt-2 w-full appearance-none rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                        <option value="NO_WARRANTY">NO_WARRANTY</option>
                        <option value="7_DAYS">7_DAYS</option>
                        <option value="14_DAYS">14_DAYS</option>
                        <option value="1_MONTH">1_MONTH</option>
                        <option value="3_MONTHS">3_MONTHS</option>
                        <option value="6_MONTHS">6_MONTHS</option>
                        <option value="1_YEAR">1_YEAR</option>
                    </select>
                </div>
            </div>

            <div>
                <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="description">Description</label>
                <textarea id="description" name="description" rows="4" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200"></textarea>
            </div>

            <div class="flex items-center gap-3">
                <button class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white shadow-sm">Save Changes</button>
                <a href="{{ route('admin.accessories.index') }}" class="text-sm font-semibold text-slate-500">Cancel</a>
            </div>
            <p id="accessory-form-error" class="text-sm text-danger-600"></p>
        </form>

        <div class="space-y-6">
            <div class="rounded-2xl border border-danger-100 bg-danger-50 p-5 text-xs text-danger-700 dark:border-danger-500/30 dark:bg-danger-500/10 dark:text-danger-100">
                <p class="font-semibold">Delete accessory</p>
                <p class="mt-2">Deleting will remove the item from the catalog and mobile app.</p>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', async function () {
            var form = document.getElementById('accessory-edit-form');
            var accessoryId = form.dataset.accessoryId;
            if (!accessoryId) {
                return;
            }

            await window.adminApi.ensureCsrfCookie();
            var response = await window.adminApi.request('/api/accessories/' + accessoryId);
            if (response.ok) {
                var data = await response.json();
                document.getElementById('name').value = data.data.name || '';
                document.getElementById('brand').value = data.data.brand || 'IPHONE';
                document.getElementById('price').value = data.data.price ?? '';
                document.getElementById('discount').value = data.data.discount ?? '';
                document.getElementById('warranty').value = data.data.warranty || 'NO_WARRANTY';
                document.getElementById('description').value = data.data.description || '';
            }
        });

        document.getElementById('accessory-edit-form').addEventListener('submit', async function (event) {
            event.preventDefault();
            document.getElementById('accessory-form-error').textContent = '';

            var form = event.target;
            var accessoryId = form.dataset.accessoryId;
            var formData = new FormData(form);
            formData.append('_method', 'PUT');

            try {
                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/accessories/' + accessoryId, {
                    method: 'POST',
                    body: formData,
                });

                if (response.ok) {
                    window.location.href = '/admin/accessories';
                    return;
                }

                var errorData = await response.json();
                document.getElementById('accessory-form-error').textContent = errorData.message || 'Unable to update accessory.';
            } catch (error) {
                document.getElementById('accessory-form-error').textContent = 'Unable to update accessory.';
            }
        });
    </script>
@endsection
