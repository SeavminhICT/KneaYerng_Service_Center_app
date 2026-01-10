@extends('layouts.admin')

@section('title', 'Create Accessory')
@section('page-title', 'Create Accessory')

@section('content')
    <div class="grid gap-6 lg:grid-cols-[2fr_1fr]">
        <form id="accessory-create-form" class="space-y-6 rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <div>
                <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Accessory Details</h2>
                <p class="text-sm text-slate-500">Add a new accessory or repair part for the catalog.</p>
            </div>

            <div class="grid gap-4 sm:grid-cols-2">
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="name">Name</label>
                    <input id="name" name="name" type="text" placeholder="Charging Port" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="brand">Brand</label>
                    <select id="brand" name="brand" class="mt-2 w-full appearance-none rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                        <option value="">Select brand</option>
                        <option value="IPHONE">IPHONE</option>
                        <option value="SAMSUNG">SAMSUNG</option>
                    </select>
                </div>
            </div>

            <div class="grid gap-4 sm:grid-cols-2">
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="price">Price</label>
                    <input id="price" name="price" type="number" step="0.01" min="0" placeholder="25.00" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="discount">Discount</label>
                    <input id="discount" name="discount" type="number" step="0.01" min="0" placeholder="0.00" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>
            </div>

            <div class="grid gap-4 sm:grid-cols-2">
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="warranty">Warranty</label>
                    <select id="warranty" name="warranty" class="mt-2 w-full appearance-none rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                        <option value="">Select warranty</option>
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
                <textarea id="description" name="description" rows="4" placeholder="Short details about this accessory" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200"></textarea>
            </div>

            <div class="flex items-center gap-3">
                <button class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white shadow-sm">Save Accessory</button>
                <a href="{{ route('admin.accessories.index') }}" class="text-sm font-semibold text-slate-500">Cancel</a>
            </div>
            <p id="accessory-form-error" class="text-sm text-danger-600"></p>
        </form>

        <div class="space-y-6">
            <div class="rounded-2xl border border-slate-200 bg-slate-50 p-5 text-xs text-slate-500 dark:border-slate-800 dark:bg-slate-950">
                <p class="font-semibold text-slate-700 dark:text-slate-200">Validation rules</p>
                <p class="mt-2">Only IPHONE and SAMSUNG brands are allowed. Warranty must match dropdown values.</p>
            </div>
        </div>
    </div>

    <script>
        document.getElementById('accessory-create-form').addEventListener('submit', async function (event) {
            event.preventDefault();
            document.getElementById('accessory-form-error').textContent = '';

            var formData = new FormData(event.target);

            try {
                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/accessories', {
                    method: 'POST',
                    body: formData,
                });

                if (response.ok) {
                    window.location.href = '/admin/accessories';
                    return;
                }

                var errorData = await response.json();
                document.getElementById('accessory-form-error').textContent = errorData.message || 'Unable to save accessory.';
            } catch (error) {
                document.getElementById('accessory-form-error').textContent = 'Unable to save accessory.';
            }
        });
    </script>
@endsection
