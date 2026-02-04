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

            <div>
                <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="description">Description</label>
                <textarea id="description" name="description" rows="4" placeholder="Write a short product summary" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200"></textarea>
            </div>

            <div class="grid gap-4 lg:grid-cols-2">
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="storage_capacity">Storage Capacity</label>
                    <div class="js-attribute-select mt-2" data-select="storage_capacity" data-placeholder="Select Storage Capacity">
                        <button type="button" class="js-attribute-toggle flex min-h-[2.75rem] w-full items-center justify-between gap-3 rounded-xl border border-slate-300 bg-white px-3 py-2 text-left text-sm text-slate-700 shadow-sm dark:border-slate-700 dark:bg-slate-900 dark:text-slate-200">
                            <div class="js-attribute-selected flex flex-wrap items-center gap-2 text-xs text-slate-600"></div>
                            <svg class="js-attribute-caret h-4 w-4 text-slate-400" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M6 9l6 6 6-6" />
                            </svg>
                        </button>
                        <div class="js-attribute-dropdown mt-2 hidden rounded-xl border border-slate-200 bg-white p-2 shadow-lg dark:border-slate-700 dark:bg-slate-950">
                            <div class="js-attribute-options max-h-40 overflow-y-auto"></div>
                        </div>
                        <select id="storage_capacity" name="storage_capacity[]" multiple class="hidden"></select>
                    </div>
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="color">Color</label>
                    <div class="js-attribute-select mt-2" data-select="color" data-placeholder="Select Color">
                        <button type="button" class="js-attribute-toggle flex min-h-[2.75rem] w-full items-center justify-between gap-3 rounded-xl border border-slate-300 bg-white px-3 py-2 text-left text-sm text-slate-700 shadow-sm dark:border-slate-700 dark:bg-slate-900 dark:text-slate-200">
                            <div class="js-attribute-selected flex flex-wrap items-center gap-2 text-xs text-slate-600"></div>
                            <svg class="js-attribute-caret h-4 w-4 text-slate-400" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M6 9l6 6 6-6" />
                            </svg>
                        </button>
                        <div class="js-attribute-dropdown mt-2 hidden rounded-xl border border-slate-200 bg-white p-2 shadow-lg dark:border-slate-700 dark:bg-slate-950">
                            <div class="js-attribute-options max-h-40 overflow-y-auto"></div>
                        </div>
                        <select id="color" name="color[]" multiple class="hidden"></select>
                    </div>
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="condition">Condition</label>
                    <div class="js-attribute-select mt-2" data-select="condition" data-placeholder="Select Condition">
                        <button type="button" class="js-attribute-toggle flex min-h-[2.75rem] w-full items-center justify-between gap-3 rounded-xl border border-slate-300 bg-white px-3 py-2 text-left text-sm text-slate-700 shadow-sm dark:border-slate-700 dark:bg-slate-900 dark:text-slate-200">
                            <div class="js-attribute-selected flex flex-wrap items-center gap-2 text-xs text-slate-600"></div>
                            <svg class="js-attribute-caret h-4 w-4 text-slate-400" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M6 9l6 6 6-6" />
                            </svg>
                        </button>
                        <div class="js-attribute-dropdown mt-2 hidden rounded-xl border border-slate-200 bg-white p-2 shadow-lg dark:border-slate-700 dark:bg-slate-950">
                            <div class="js-attribute-options max-h-40 overflow-y-auto"></div>
                        </div>
                        <select id="condition" name="condition[]" multiple class="hidden"></select>
                    </div>
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="ram">RAM</label>
                    <div class="js-attribute-select mt-2" data-select="ram" data-placeholder="Select RAM">
                        <button type="button" class="js-attribute-toggle flex min-h-[2.75rem] w-full items-center justify-between gap-3 rounded-xl border border-slate-300 bg-white px-3 py-2 text-left text-sm text-slate-700 shadow-sm dark:border-slate-700 dark:bg-slate-900 dark:text-slate-200">
                            <div class="js-attribute-selected flex flex-wrap items-center gap-2 text-xs text-slate-600"></div>
                            <svg class="js-attribute-caret h-4 w-4 text-slate-400" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M6 9l6 6 6-6" />
                            </svg>
                        </button>
                        <div class="js-attribute-dropdown mt-2 hidden rounded-xl border border-slate-200 bg-white p-2 shadow-lg dark:border-slate-700 dark:bg-slate-950">
                            <div class="js-attribute-options max-h-40 overflow-y-auto"></div>
                        </div>
                        <select id="ram" name="ram[]" multiple class="hidden"></select>
                    </div>
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="ssd">SSD</label>
                    <div class="js-attribute-select mt-2" data-select="ssd" data-placeholder="Select SSD">
                        <button type="button" class="js-attribute-toggle flex min-h-[2.75rem] w-full items-center justify-between gap-3 rounded-xl border border-slate-300 bg-white px-3 py-2 text-left text-sm text-slate-700 shadow-sm dark:border-slate-700 dark:bg-slate-900 dark:text-slate-200">
                            <div class="js-attribute-selected flex flex-wrap items-center gap-2 text-xs text-slate-600"></div>
                            <svg class="js-attribute-caret h-4 w-4 text-slate-400" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M6 9l6 6 6-6" />
                            </svg>
                        </button>
                        <div class="js-attribute-dropdown mt-2 hidden rounded-xl border border-slate-200 bg-white p-2 shadow-lg dark:border-slate-700 dark:bg-slate-950">
                            <div class="js-attribute-options max-h-40 overflow-y-auto"></div>
                        </div>
                        <select id="ssd" name="ssd[]" multiple class="hidden"></select>
                    </div>
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="cpu">CPU</label>
                    <div class="js-attribute-select mt-2" data-select="cpu" data-placeholder="Select CPU">
                        <button type="button" class="js-attribute-toggle flex min-h-[2.75rem] w-full items-center justify-between gap-3 rounded-xl border border-slate-300 bg-white px-3 py-2 text-left text-sm text-slate-700 shadow-sm dark:border-slate-700 dark:bg-slate-900 dark:text-slate-200">
                            <div class="js-attribute-selected flex flex-wrap items-center gap-2 text-xs text-slate-600"></div>
                            <svg class="js-attribute-caret h-4 w-4 text-slate-400" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M6 9l6 6 6-6" />
                            </svg>
                        </button>
                        <div class="js-attribute-dropdown mt-2 hidden rounded-xl border border-slate-200 bg-white p-2 shadow-lg dark:border-slate-700 dark:bg-slate-950">
                            <div class="js-attribute-options max-h-40 overflow-y-auto"></div>
                        </div>
                        <select id="cpu" name="cpu[]" multiple class="hidden"></select>
                    </div>
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="display">Display</label>
                    <div class="js-attribute-select mt-2" data-select="display" data-placeholder="Select Display">
                        <button type="button" class="js-attribute-toggle flex min-h-[2.75rem] w-full items-center justify-between gap-3 rounded-xl border border-slate-300 bg-white px-3 py-2 text-left text-sm text-slate-700 shadow-sm dark:border-slate-700 dark:bg-slate-900 dark:text-slate-200">
                            <div class="js-attribute-selected flex flex-wrap items-center gap-2 text-xs text-slate-600"></div>
                            <svg class="js-attribute-caret h-4 w-4 text-slate-400" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M6 9l6 6 6-6" />
                            </svg>
                        </button>
                        <div class="js-attribute-dropdown mt-2 hidden rounded-xl border border-slate-200 bg-white p-2 shadow-lg dark:border-slate-700 dark:bg-slate-950">
                            <div class="js-attribute-options max-h-40 overflow-y-auto"></div>
                        </div>
                        <select id="display" name="display[]" multiple class="hidden"></select>
                    </div>
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="country">Country</label>
                    <div class="js-attribute-select mt-2" data-select="country" data-placeholder="Select Country">
                        <button type="button" class="js-attribute-toggle flex min-h-[2.75rem] w-full items-center justify-between gap-3 rounded-xl border border-slate-300 bg-white px-3 py-2 text-left text-sm text-slate-700 shadow-sm dark:border-slate-700 dark:bg-slate-900 dark:text-slate-200">
                            <div class="js-attribute-selected flex flex-wrap items-center gap-2 text-xs text-slate-600"></div>
                            <svg class="js-attribute-caret h-4 w-4 text-slate-400" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M6 9l6 6 6-6" />
                            </svg>
                        </button>
                        <div class="js-attribute-dropdown mt-2 hidden rounded-xl border border-slate-200 bg-white p-2 shadow-lg dark:border-slate-700 dark:bg-slate-950">
                            <div class="js-attribute-options max-h-40 overflow-y-auto"></div>
                        </div>
                        <select id="country" name="country[]" multiple class="hidden"></select>
                    </div>
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

        async function loadAttributeOptions(type, selectId, selectedValues) {
            await window.adminApi.ensureCsrfCookie();
            var response = await window.adminApi.request('/api/product-attributes?type=' + encodeURIComponent(type));
            if (!response.ok) {
                return;
            }
            var data = await response.json();
            var select = document.getElementById(selectId);
            if (!select) {
                return;
            }
            var selected = Array.isArray(selectedValues) ? selectedValues.map(String) : [];
            var optionsHtml = (data.data || []).map(function (item) {
                var isSelected = selected.includes(String(item.value));
                return '<option value="' + item.value + '"' + (isSelected ? ' selected' : '') + '>' + item.value + '</option>';
            }).join('');
            if (select) {
                select.innerHTML = optionsHtml;
            }
            renderAttributeSelect(selectId);
        }

        function renderAttributeSelect(selectId) {
            var select = document.getElementById(selectId);
            var wrapper = document.querySelector('.js-attribute-select[data-select=\"' + selectId + '\"]');
            if (!select || !wrapper) {
                return;
            }
            var selectedContainer = wrapper.querySelector('.js-attribute-selected');
            var optionsContainer = wrapper.querySelector('.js-attribute-options');
            var placeholder = wrapper.dataset.placeholder || 'Select';

            if (selectedContainer) {
                selectedContainer.innerHTML = '';
                var selectedOptions = Array.from(select.selectedOptions || []);
                if (!selectedOptions.length) {
                    var empty = document.createElement('span');
                    empty.className = 'text-xs text-slate-400';
                    empty.textContent = placeholder;
                    selectedContainer.appendChild(empty);
                } else {
                    selectedOptions.forEach(function (option) {
                        var chip = document.createElement('span');
                        chip.className = 'inline-flex items-center gap-2 rounded-full border border-slate-200 bg-white px-2 py-1 text-xs text-slate-700 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-200';
                        var label = document.createElement('span');
                        label.textContent = option.value;
                        var remove = document.createElement('button');
                        remove.type = 'button';
                        remove.className = 'text-slate-400 hover:text-slate-700';
                        remove.textContent = 'x';
                        remove.addEventListener('click', function (event) {
                            event.stopPropagation();
                            option.selected = false;
                            renderAttributeSelect(selectId);
                        });
                        chip.appendChild(label);
                        chip.appendChild(remove);
                        selectedContainer.appendChild(chip);
                    });
                }
            }

            if (optionsContainer) {
                optionsContainer.innerHTML = '';
                Array.from(select.options || []).forEach(function (option) {
                    var button = document.createElement('button');
                    button.type = 'button';
                    button.className = 'flex w-full items-center justify-between rounded-lg px-3 py-2 text-left text-sm hover:bg-slate-100 dark:hover:bg-slate-900';
                    if (option.selected) {
                        button.classList.add('bg-slate-100', 'dark:bg-slate-900');
                    }
                    var label = document.createElement('span');
                    label.textContent = option.value;
                    var mark = document.createElement('span');
                    mark.className = 'text-xs text-slate-400';
                    mark.textContent = option.selected ? 'Selected' : '';
                    button.appendChild(label);
                    button.appendChild(mark);
                    button.addEventListener('click', function (event) {
                        event.preventDefault();
                        option.selected = !option.selected;
                        renderAttributeSelect(selectId);
                    });
                    optionsContainer.appendChild(button);
                });
            }
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
            loadAttributeOptions('storage_capacity', 'storage_capacity', []);
            loadAttributeOptions('color', 'color', []);
            loadAttributeOptions('condition', 'condition', []);
            loadAttributeOptions('ram', 'ram', []);
            loadAttributeOptions('ssd', 'ssd', []);
            loadAttributeOptions('cpu', 'cpu', []);
            loadAttributeOptions('display', 'display', []);
            loadAttributeOptions('country', 'country', []);
        });

        document.querySelectorAll('.js-attribute-toggle').forEach(function (button) {
            button.addEventListener('click', function (event) {
                event.preventDefault();
                var wrapper = button.closest('.js-attribute-select');
                if (!wrapper) {
                    return;
                }
                var dropdown = wrapper.querySelector('.js-attribute-dropdown');
                var caret = wrapper.querySelector('.js-attribute-caret');
                if (!dropdown) {
                    return;
                }
                var isOpen = !dropdown.classList.contains('hidden');
                document.querySelectorAll('.js-attribute-dropdown').forEach(function (panel) {
                    panel.classList.add('hidden');
                });
                document.querySelectorAll('.js-attribute-caret').forEach(function (icon) {
                    icon.classList.remove('rotate-180');
                });
                if (!isOpen) {
                    dropdown.classList.remove('hidden');
                    if (caret) {
                        caret.classList.add('rotate-180');
                    }
                }
            });
        });

        document.addEventListener('click', function (event) {
            var target = event.target;
            if (target.closest('.js-attribute-select')) {
                return;
            }
            document.querySelectorAll('.js-attribute-dropdown').forEach(function (panel) {
                panel.classList.add('hidden');
            });
            document.querySelectorAll('.js-attribute-caret').forEach(function (icon) {
                icon.classList.remove('rotate-180');
            });
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
