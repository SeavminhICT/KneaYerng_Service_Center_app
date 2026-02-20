@extends('layouts.admin')

@section('title', 'Create Accessory')
@section('page-title', 'Create Accessory')

@section('content')
    <div class="grid gap-6 lg:grid-cols-[2fr_1fr]">
        <form id="accessory-create-form" enctype="multipart/form-data" class="space-y-6 rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
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
                        <option value="IPHONE">APPLE</option>
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
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="stock">Parts Stock</label>
                    <input id="stock" name="stock" type="number" min="0" required placeholder="0" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
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
                    <input id="discount" name="discount" type="number" step="0.01" min="0" placeholder="0.00" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    <p id="final-price" class="mt-1 text-xs text-slate-500"></p>
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
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="tag">Tag</label>
                    <select id="tag" name="tag" class="mt-2 w-full appearance-none rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                        <option value="">No tag</option>
                        @foreach (\App\Models\Accessory::TAGS as $tag)
                            <option value="{{ $tag }}">
                                {{ \Illuminate\Support\Str::title(str_replace('_', ' ', strtolower($tag))) }}
                            </option>
                        @endforeach
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
            <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900" x-data="{ preview: null }">
                <h3 class="text-sm font-semibold text-slate-900 dark:text-white">Accessory Image</h3>
                <p class="mt-1 text-xs text-slate-500">Upload a photo to show in the app.</p>
                <div class="mt-4 flex h-40 items-center justify-center rounded-xl border border-dashed border-slate-300 bg-slate-50 text-xs text-slate-500 dark:border-slate-700 dark:bg-slate-900/60">
                    <template x-if="preview">
                        <img :src="preview" alt="Preview" class="h-32 w-32 rounded-xl object-cover" />
                    </template>
                    <template x-if="!preview">
                        <div class="text-center">
                            <p class="font-semibold">Drop image here</p>
                            <p>PNG, JPG up to 5MB</p>
                        </div>
                    </template>
                </div>
                <input type="file" name="image" form="accessory-create-form" accept="image/*" class="mt-4 w-full text-sm text-slate-500" @change="const file = $event.target.files[0]; if (file) { const reader = new FileReader(); reader.onload = e => preview = e.target.result; reader.readAsDataURL(file); }" />
            </div>

            <div class="rounded-2xl border border-slate-200 bg-slate-50 p-5 text-xs text-slate-500 dark:border-slate-800 dark:bg-slate-950">
                <p class="font-semibold text-slate-700 dark:text-slate-200">Validation rules</p>
                <p class="mt-2">Only IPHONE and SAMSUNG brands are allowed. Warranty must match dropdown values.</p>
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

        document.addEventListener('DOMContentLoaded', function () {
            setupDiscountTools();
            initRichTextEditor('description');
        });

        var accessoryImageInput = document.querySelector('input[name="image"][form="accessory-create-form"]');
        if (accessoryImageInput) {
            accessoryImageInput.addEventListener('change', function (event) {
                var file = event.target.files[0];
                if (file) {
                    document.getElementById('accessory-form-error').textContent = '';
                }
                if (window.adminValidateFileSize && file && !window.adminValidateFileSize(file, 'Image')) {
                    event.stopImmediatePropagation();
                    event.preventDefault();
                    event.target.value = '';
                    document.getElementById('accessory-form-error').textContent = 'Image must be 5MB or smaller.';
                }
            }, true);
        }

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
                    if (window.adminSwalStore) {
                        window.adminSwalStore({
                            icon: 'success',
                            title: 'Accessory created',
                            text: 'Accessory created successfully.',
                            confirmButtonColor: '#2563eb',
                        });
                    } else if (window.adminToastStore) {
                        window.adminToastStore({ type: 'success', message: 'Accessory created successfully.' });
                    }
                    window.location.href = '/admin/accessories';
                    return;
                }

                var errorData = await response.json();
                document.getElementById('accessory-form-error').textContent = errorData.message || 'Unable to save accessory.';
                if (window.adminSwalError) {
                    window.adminSwalError('Create failed', errorData.message || 'Unable to save accessory.');
                } else if (window.adminToast) {
                    window.adminToast(errorData.message || 'Unable to save accessory.', { type: 'error' });
                }
            } catch (error) {
                document.getElementById('accessory-form-error').textContent = 'Unable to save accessory.';
                if (window.adminSwalError) {
                    window.adminSwalError('Create failed', 'Unable to save accessory.');
                } else if (window.adminToast) {
                    window.adminToast('Unable to save accessory.', { type: 'error' });
                }
            }
        });
    </script>
@endsection
