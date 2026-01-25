@extends('layouts.admin')

@section('title', 'Create Product')
@section('page-title', 'Create Product')

@section('content')
    <div class="grid gap-6 lg:grid-cols-[2fr_1fr]">
        <form id="product-create-form" enctype="multipart/form-data" class="space-y-6 rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <div>
                <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Product Details</h2>
                <p class="text-sm text-slate-500">Add a new product for the web and API catalog.</p>
            </div>

            <div class="grid gap-4 sm:grid-cols-2">
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="name">Product Name</label>
                    <input id="name" name="name" type="text" placeholder="Organic Tea" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="brand">Brand</label>
                    <input id="brand" name="brand" type="text" placeholder="Brand name" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="sku">SKU</label>
                    <input id="sku" name="sku" type="text" placeholder="Auto-generated" disabled class="mt-2 w-full cursor-not-allowed rounded-xl border border-slate-200 bg-slate-100 px-3 py-2 text-sm text-slate-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-400" />
                </div>
            </div>

            <div class="grid gap-4 sm:grid-cols-2">
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="category">Category</label>
                    <select id="category" name="category_id" class="mt-2 w-full appearance-none rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                        <option value="">Select category</option>
                    </select>
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="price">Price</label>
                    <input id="price" name="price" type="number" step="0.01" min="0" required placeholder="4.50" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
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
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="stock">Stock</label>
                    <input id="stock" name="stock" type="number" min="0" required placeholder="100" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="status">Status</label>
                    <select id="status" name="status" required class="mt-2 w-full appearance-none rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                        <option value="active" selected>Active</option>
                        <option value="draft">Draft</option>
                        <option value="archived">Archived</option>
                    </select>
                </div>
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
                <textarea id="description" name="description" rows="4" placeholder="Write a short product summary" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200"></textarea>
            </div>

            <div class="grid gap-4 sm:grid-cols-3">
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="storage_capacity">Storage Capacity</label>
                    <input id="storage_capacity" name="storage_capacity_raw" type="text" placeholder="64GB, 128GB" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    <p class="mt-1 text-xs text-slate-500">Comma separated</p>
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="color">Color</label>
                    <input id="color" name="color_raw" type="text" placeholder="Black, Silver" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    <p class="mt-1 text-xs text-slate-500">Comma separated</p>
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="condition">Condition</label>
                    <input id="condition" name="condition_raw" type="text" placeholder="New, Open box" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    <p class="mt-1 text-xs text-slate-500">Comma separated</p>
                </div>
            </div>

            <div class="flex items-center gap-3">
                <button class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white shadow-sm">Save Product</button>
                <a href="{{ route('admin.products.index') }}" class="text-sm font-semibold text-slate-500">Cancel</a>
            </div>
            <p id="product-form-error" class="text-sm text-danger-600"></p>
        </form>

        <div class="space-y-6">
            <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900" x-data="{ preview: null }">
                <h3 class="text-sm font-semibold text-slate-900 dark:text-white">Product Images</h3>
                <p class="mt-1 text-xs text-slate-500">Upload a thumbnail and gallery for storefront previews.</p>
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
                <input type="file" name="thumbnail" form="product-create-form" class="mt-4 w-full text-sm text-slate-500" @change="const file = $event.target.files[0]; if (file) { const reader = new FileReader(); reader.onload = e => preview = e.target.result; reader.readAsDataURL(file); }" />
                <label class="mt-4 text-xs font-semibold text-slate-600 dark:text-slate-300">Image Gallery</label>
                <div id="gallery-preview" class="mt-2 grid grid-cols-3 gap-2 text-xs text-slate-500"></div>
                <input type="file" name="image_gallery[]" form="product-create-form" multiple class="mt-2 w-full text-sm text-slate-500" />
            </div>

            <div class="rounded-2xl border border-slate-200 bg-slate-50 p-5 text-xs text-slate-500 dark:border-slate-800 dark:bg-slate-950">
                <p class="font-semibold text-slate-700 dark:text-slate-200">Select2-style fields</p>
                <p class="mt-2">Enable searchable selects for categories and tags when lists grow.</p>
            </div>
        </div>
    </div>

    <script src="https://cdn.ckeditor.com/4.25.1-lts/standard-all/ckeditor.js"></script>

    <script>
        async function loadCategories() {
            await window.adminApi.ensureCsrfCookie();
            var response = await window.adminApi.request('/api/categories');
            if (!response.ok) {
                return;
            }
            var data = await response.json();
            var select = document.getElementById('category');
            select.innerHTML = '<option value=\"\">Select category</option>' + (data.data || []).map(function (category) {
                return '<option value=\"' + category.id + '\">' + category.name + '</option>';
            }).join('');
        }

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
            loadCategories();
            setupDiscountTools();
            initRichTextEditor('description');
        });

        var productThumbnailInput = document.querySelector('input[name="thumbnail"][form="product-create-form"]');
        if (productThumbnailInput) {
            productThumbnailInput.addEventListener('change', function (event) {
                var file = event.target.files[0];
                if (file) {
                    document.getElementById('product-form-error').textContent = '';
                }
                if (window.adminValidateFileSize && file && !window.adminValidateFileSize(file, 'Thumbnail')) {
                    event.stopImmediatePropagation();
                    event.preventDefault();
                    event.target.value = '';
                    document.getElementById('product-form-error').textContent = 'Thumbnail must be 5MB or smaller.';
                }
            }, true);
        }

        function renderGalleryPreview(files, containerId) {
            var container = document.getElementById(containerId);
            if (!container) {
                return;
            }
            container.innerHTML = '';
            Array.from(files || []).forEach(function (file) {
                var reader = new FileReader();
                reader.onload = function (e) {
                    var wrapper = document.createElement('div');
                    wrapper.className = 'h-20 w-full overflow-hidden rounded-lg border border-slate-200 bg-white dark:border-slate-800 dark:bg-slate-900';
                    var img = document.createElement('img');
                    img.src = e.target.result;
                    img.alt = file.name;
                    img.className = 'h-full w-full object-cover';
                    wrapper.appendChild(img);
                    container.appendChild(wrapper);
                };
                reader.readAsDataURL(file);
            });
        }

        var galleryInput = document.querySelector('input[name="image_gallery[]"]');
        if (galleryInput) {
            galleryInput.addEventListener('change', function (event) {
                var files = Array.from(event.target.files || []);
                if (window.adminValidateFileSize) {
                    var hasOversized = files.some(function (file) {
                        return !window.adminValidateFileSize(file, 'Gallery image');
                    });
                    if (hasOversized) {
                        event.target.value = '';
                        renderGalleryPreview([], 'gallery-preview');
                        document.getElementById('product-form-error').textContent = 'Gallery images must be 5MB or smaller.';
                        return;
                    }
                }
                if (files.length) {
                    document.getElementById('product-form-error').textContent = '';
                }
                renderGalleryPreview(event.target.files, 'gallery-preview');
            });
        }

        document.getElementById('product-create-form').addEventListener('submit', async function (event) {
            event.preventDefault();
            document.getElementById('product-form-error').textContent = '';

            var formData = new FormData(event.target);
            ['storage_capacity', 'color', 'condition'].forEach(function (field) {
                var raw = formData.get(field + '_raw');
                formData.delete(field + '_raw');
                if (!raw) {
                    return;
                }
                String(raw).split(',').map(function (item) { return item.trim(); }).filter(Boolean).forEach(function (value) {
                    formData.append(field + '[]', value);
                });
            });
            try {
                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/products', {
                    method: 'POST',
                    body: formData,
                });

                if (response.ok) {
                    if (window.adminSwalStore) {
                        window.adminSwalStore({
                            icon: 'success',
                            title: 'Product created',
                            text: 'Product created successfully.',
                            confirmButtonColor: '#2563eb',
                        });
                    } else if (window.adminToastStore) {
                        window.adminToastStore({ type: 'success', message: 'Product created successfully.' });
                    }
                    window.location.href = '/admin/products';
                    return;
                }

                var errorData = await response.json();
                document.getElementById('product-form-error').textContent = errorData.message || 'Unable to save product.';
                if (window.adminSwalError) {
                    window.adminSwalError('Create failed', errorData.message || 'Unable to save product.');
                } else if (window.adminToast) {
                    window.adminToast(errorData.message || 'Unable to save product.', { type: 'error' });
                }
            } catch (error) {
                document.getElementById('product-form-error').textContent = 'Unable to save product.';
                if (window.adminSwalError) {
                    window.adminSwalError('Create failed', 'Unable to save product.');
                } else if (window.adminToast) {
                    window.adminToast('Unable to save product.', { type: 'error' });
                }
            }
        });
    </script>
@endsection
