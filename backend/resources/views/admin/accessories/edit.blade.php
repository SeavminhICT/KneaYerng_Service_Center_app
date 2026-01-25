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
                    <div class="mt-2 grid grid-cols-2 gap-2">
                        <select id="discount_type" class="h-10 w-full appearance-none rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                            <option value="amount" selected>Amount</option>
                            <option value="percent">Percent</option>
                        </select>
                        <input id="discount_percent" type="number" step="0.01" min="0" max="100" placeholder="10%" class="hidden h-10 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    </div>
                    <input id="discount" name="discount" type="number" step="0.01" min="0" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    <p id="final-price" class="mt-1 text-xs text-slate-500"></p>
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

    <script src="https://cdn.ckeditor.com/4.25.1-lts/standard-all/ckeditor.js"></script>

    <script>
        function initRichTextEditor(elementId) {
            if (!window.CKEDITOR) {
                return;
            }
            if (window.CKEDITOR.instances[elementId]) {
                return;
            }
            window.CKEDITOR.replace(elementId, {
                toolbar: [
                    { name: 'styles', items: ['Format'] },
                    { name: 'basicstyles', items: ['Bold', 'Italic'] },
                    { name: 'links', items: ['Link', 'Unlink'] },
                    { name: 'paragraph', items: ['NumberedList', 'BulletedList'] },
                    { name: 'colors', items: ['TextColor', 'BGColor'] },
                    { name: 'insert', items: ['Table'] },
                    { name: 'clipboard', items: ['Undo', 'Redo'] }
                ]
            });
        }

        function setupDiscountTools() {
            var priceInput = document.getElementById('price');
            var discountInput = document.getElementById('discount');
            var discountType = document.getElementById('discount_type');
            var discountPercent = document.getElementById('discount_percent');
            var finalPrice = document.getElementById('final-price');

            if (!priceInput || !discountInput || !discountType || !discountPercent || !finalPrice) {
                return;
            }

            function parseNumber(value) {
                var number = parseFloat(value);
                return Number.isFinite(number) ? number : 0;
            }

            function formatMoney(value) {
                return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(value || 0);
            }

            function updateFinalPrice() {
                var price = parseNumber(priceInput.value);
                var discount = parseNumber(discountInput.value);
                var finalValue = Math.max(price - discount, 0);
                finalPrice.textContent = 'Final price: ' + formatMoney(finalValue);
            }

            function updateDiscountFromPercent() {
                var price = parseNumber(priceInput.value);
                var percent = parseNumber(discountPercent.value);
                if (percent < 0) {
                    percent = 0;
                }
                if (percent > 100) {
                    percent = 100;
                }
                var discountValue = price * (percent / 100);
                discountInput.value = discountValue ? discountValue.toFixed(2) : '';
                updateFinalPrice();
            }

            function applyDiscountType() {
                var isPercent = discountType.value === 'percent';
                discountPercent.classList.toggle('hidden', !isPercent);
                discountInput.readOnly = isPercent;
                discountInput.classList.toggle('bg-slate-100', isPercent);
                discountInput.classList.toggle('cursor-not-allowed', isPercent);
                if (isPercent) {
                    updateDiscountFromPercent();
                } else {
                    updateFinalPrice();
                }
            }

            priceInput.addEventListener('input', function () {
                if (discountType.value === 'percent') {
                    updateDiscountFromPercent();
                } else {
                    updateFinalPrice();
                }
            });

            discountInput.addEventListener('input', updateFinalPrice);
            discountPercent.addEventListener('input', updateDiscountFromPercent);
            discountType.addEventListener('change', applyDiscountType);

            applyDiscountType();
        }

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

            setupDiscountTools();
            initRichTextEditor('description');
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
                    if (window.adminSwalStore) {
                        window.adminSwalStore({
                            icon: 'success',
                            title: 'Accessory updated',
                            text: 'Accessory updated successfully.',
                            confirmButtonColor: '#2563eb',
                        });
                    } else if (window.adminToastStore) {
                        window.adminToastStore({ type: 'success', message: 'Accessory updated successfully.' });
                    }
                    window.location.href = '/admin/accessories';
                    return;
                }

                var errorData = await response.json();
                document.getElementById('accessory-form-error').textContent = errorData.message || 'Unable to update accessory.';
                if (window.adminSwalError) {
                    window.adminSwalError('Update failed', errorData.message || 'Unable to update accessory.');
                } else if (window.adminToast) {
                    window.adminToast(errorData.message || 'Unable to update accessory.', { type: 'error' });
                }
            } catch (error) {
                document.getElementById('accessory-form-error').textContent = 'Unable to update accessory.';
                if (window.adminSwalError) {
                    window.adminSwalError('Update failed', 'Unable to update accessory.');
                } else if (window.adminToast) {
                    window.adminToast('Unable to update accessory.', { type: 'error' });
                }
            }
        });
    </script>
@endsection
