@extends('layouts.admin')

@section('title', 'Create Product')
@section('page-title', 'Create Product')

@section('content')
    <div class="grid gap-6 lg:grid-cols-[2fr_1fr]">
        <form
            id="product-create-form"
            enctype="multipart/form-data"
            class="space-y-4 rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900"
        >
            <div>
                <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Create Product</h2>
                <p class="text-sm text-slate-500">Create one base product, then add variants one by one.</p>
            </div>

            <!-- Basic Information Section -->
            <div x-data="{ open: true }" class="rounded-2xl border border-slate-200 dark:border-slate-800">
                <button type="button" @click="open = !open" class="flex w-full items-center justify-between p-4 hover:bg-slate-50 dark:hover:bg-slate-800/50">
                    <h3 class="text-sm font-semibold text-slate-900 dark:text-white">Basic Information</h3>
                    <svg :class="{ 'rotate-180': open }" class="h-5 w-5 transition-transform text-slate-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 14l-7 7m0 0l-7-7m7 7V3" />
                    </svg>
                </button>
                <div x-show="open" class="space-y-4 border-t border-slate-200 bg-slate-50 p-4 dark:border-slate-800 dark:bg-slate-900/50">
                    <div class="grid gap-4 sm:grid-cols-2">
                        <div>
                            <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="name">Product Name</label>
                            <input id="name" name="name" type="text" placeholder="Enter Name of Product" class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                        </div>
                        <div>
                            <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="brand">Brand</label>
                            <input id="brand" name="brand" type="text" placeholder="Apple" class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                        </div>
                        <div>
                            <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="category">Category</label>
                            <select id="category" name="category_id" class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                                <option value="">Select category</option>
                                @foreach (($categories ?? collect()) as $category)
                                    <option value="{{ $category->id }}">{{ $category->name }}</option>
                                @endforeach
                            </select>
                        </div>
                        <div>
                            <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="status">Status</label>
                            <select id="status" name="status" class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                                <option value="active" selected>Active</option>
                                <option value="draft">Draft</option>
                                <option value="archived">Archived</option>
                            </select>
                        </div>
                    </div>
                    <div>
                        <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="description">Description</label>
                        <textarea id="description" name="description" rows="4" class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200"></textarea>
                    </div>
                </div>
            </div>

            <!-- Specifications Section -->
            <div x-data="{ open: true }" class="rounded-2xl border border-slate-200 dark:border-slate-800">
                <button type="button" @click="open = !open" class="flex w-full items-center justify-between p-4 hover:bg-slate-50 dark:hover:bg-slate-800/50">
                    <h3 class="text-sm font-semibold text-slate-900 dark:text-white">Specifications</h3>
                    <svg :class="{ 'rotate-180': open }" class="h-5 w-5 transition-transform text-slate-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 14l-7 7m0 0l-7-7m7 7V3" />
                    </svg>
                </button>
                <div x-show="open" class="space-y-4 border-t border-slate-200 bg-slate-50 p-4 dark:border-slate-800 dark:bg-slate-900/50">
                    <div class="grid gap-4 sm:grid-cols-2">
                        <div>
                            <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="cpu">CPU</label>
                            <input id="cpu" name="cpu" type="text" placeholder="A19 Pro" class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                        </div>
                        <div>
                            <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="display">Display</label>
                            <input id="display" name="display" type="text" placeholder="6.9\" OLED" class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                        </div>
                        <div>
                            <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="country">Country / Region</label>
                            <input id="country" name="country" type="text" placeholder="United States" class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                        </div>
                        <div>
                            <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="warranty">
                                Warranty
                                <span class="ml-1 text-xs font-normal text-slate-400">— auto-tracks when order completes</span>
                            </label>
                            <select id="warranty" name="warranty" class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                                <option value="NO_WARRANTY">No Warranty</option>
                                <option value="1_DAYS">1 Days</option>
                                <option value="7_DAYS">7 Days</option>
                                <option value="14_DAYS">14 Days</option>
                                <option value="1_MONTH">1 Month</option>
                                <option value="3_MONTHS">3 Months</option>
                                <option value="6_MONTHS">6 Months</option>
                                <option value="1_YEAR">1 Year</option>
                            </select>
                        </div>
                        <div class="sm:col-span-2">
                            <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="tag">Tag</label>
                            <select id="tag" name="tag" class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                                <option value="">No tag</option>
                                @foreach (\App\Models\Product::TAGS as $tag)
                                    <option value="{{ $tag }}">{{ \Illuminate\Support\Str::title(str_replace('_', ' ', strtolower($tag))) }}</option>
                                @endforeach
                            </select>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Pricing & Discount Section -->
            <div x-data="{ open: true }" class="rounded-2xl border border-slate-200 dark:border-slate-800">
                <button type="button" @click="open = !open" class="flex w-full items-center justify-between p-4 hover:bg-slate-50 dark:hover:bg-slate-800/50">
                    <h3 class="text-sm font-semibold text-slate-900 dark:text-white">Pricing & Discount</h3>
                    <svg :class="{ 'rotate-180': open }" class="h-5 w-5 transition-transform text-slate-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 14l-7 7m0 0l-7-7m7 7V3" />
                    </svg>
                </button>
                <div x-show="open" class="space-y-4 border-t border-slate-200 bg-slate-50 p-4 dark:border-slate-800 dark:bg-slate-900/50">
                    <div class="grid gap-4 sm:grid-cols-2">
                        <div>
                            <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="price">Price (From Variants)</label>
                            <input id="price" name="price" type="number" step="0.01" min="0" value="0" readonly class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-100 px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                        </div>
                        <div>
                            <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="stock">Total Stock</label>
                            <input id="stock" name="stock" type="number" min="0" value="0" readonly class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-100 px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                        </div>
                        <div>
                            <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="discount">Discount (%)</label>
                            <input id="discount" name="discount" type="number" step="0.01" min="0" value="0" class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                        </div>
                    </div>
                </div>
            </div>

            <!-- Product Variants Section -->
            <div class="rounded-2xl border border-slate-200 dark:border-slate-800">
                <div class="p-4">
                    <h3 class="text-sm font-semibold text-slate-900 dark:text-white">Product Variants</h3>
                    <p class="text-xs text-slate-500 mt-1">Add one or more variants with storage, color, condition, and pricing.</p>
                </div>

                <!-- Variant Input Form -->
                <div class="border-t border-slate-200 bg-slate-50 p-4 dark:border-slate-800 dark:bg-slate-900/50">
                    <div class="grid gap-3 sm:grid-cols-2">
                        <div>
                            <label class="text-xs font-semibold text-slate-600 dark:text-slate-300" for="variant-storage">Storage *</label>
                            <select id="variant-storage" class="mt-1 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                                <option value="">Loading…</option>
                            </select>
                        </div>
                        <div>
                            <label class="text-xs font-semibold text-slate-600 dark:text-slate-300" for="variant-color">Color *</label>
                            <select id="variant-color" class="mt-1 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                                <option value="">Loading…</option>
                            </select>
                        </div>
                        <div>
                            <label class="text-xs font-semibold text-slate-600 dark:text-slate-300" for="variant-condition">Condition *</label>
                            <select id="variant-condition" class="mt-1 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                                <option value="">Loading…</option>
                            </select>
                        </div>
                        <div>
                            <label class="text-xs font-semibold text-slate-600 dark:text-slate-300" for="variant-price">Price *</label>
                            <input id="variant-price" type="number" step="0.01" min="0" placeholder="1230" class="mt-1 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                        </div>
                        <div>
                            <label class="text-xs font-semibold text-slate-600 dark:text-slate-300" for="variant-stock">Stock *</label>
                            <input id="variant-stock" type="number" min="0" placeholder="10" class="mt-1 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                        </div>
                        <div>
                            <label class="text-xs font-semibold text-slate-600 dark:text-slate-300" for="variant-sku">SKU</label>
                            <input id="variant-sku" type="text" placeholder="IP17PM-256-BLK" class="mt-1 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                        </div>
                        <div>
                            <label class="text-xs font-semibold text-slate-600 dark:text-slate-300" for="variant-ram">RAM</label>
                            <select id="variant-ram" class="mt-1 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                                <option value="">Loading…</option>
                            </select>
                        </div>
                        <div>
                            <label class="text-xs font-semibold text-slate-600 dark:text-slate-300" for="variant-ssd">SSD</label>
                            <select id="variant-ssd" class="mt-1 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                                <option value="">Loading…</option>
                            </select>
                        </div>
                        <div>
                            <label class="text-xs font-semibold text-slate-600 dark:text-slate-300" for="variant-image">Variant Image</label>
                            <input id="variant-image" type="file" accept="image/*" class="mt-1 w-full text-xs text-slate-500" />
                        </div>
                    </div>

                    <div class="mt-4 flex items-center gap-2">
                        <button id="variant-add-btn" type="button" class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white hover:bg-primary-700">Add Variant</button>
                        <button id="variant-clear-btn" type="button" class="inline-flex h-10 items-center rounded-xl border border-slate-200 px-4 text-sm font-semibold text-slate-600 hover:bg-slate-100 dark:border-slate-700 dark:text-slate-300">Clear</button>
                        <p id="variant-form-error" class="ml-auto text-xs text-danger-600"></p>
                    </div>
                </div>

                <!-- Variants Table -->
                <div class="border-t border-slate-200 overflow-x-auto dark:border-slate-800">
                    <table class="w-full text-left text-sm">
                        <thead class="bg-slate-100 text-xs uppercase tracking-wider text-slate-600 dark:bg-slate-800 dark:text-slate-300">
                            <tr>
                                <th class="px-3 py-2">Storage</th>
                                <th class="px-3 py-2">Color</th>
                                <th class="px-3 py-2">Condition</th>
                                <th class="px-3 py-2">Price</th>
                                <th class="px-3 py-2">Stock</th>
                                <th class="px-3 py-2">RAM</th>
                                <th class="px-3 py-2">SSD</th>
                                <th class="px-3 py-2">SKU</th>
                                <th class="px-3 py-2">Image</th>
                                <th class="px-3 py-2 text-right">Action</th>
                            </tr>
                        </thead>
                        <tbody id="variant-table-body" class="divide-y divide-slate-200 dark:divide-slate-800"></tbody>
                    </table>
                </div>
            </div>

            <div class="flex items-center gap-3 border-t border-slate-200 pt-4 dark:border-slate-800">
                <button class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-6 text-sm font-semibold text-white shadow-sm hover:bg-primary-700">Save Product</button>
                <a href="{{ route('admin.products.index') }}" class="text-sm font-semibold text-slate-500 hover:text-slate-700">Cancel</a>
            </div>
            <p id="product-form-error" class="text-sm text-danger-600"></p>
        </form>

        <div class="space-y-6">
            <!-- Image Upload Card -->
            <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900" x-data="{ preview: null }">
                <h3 class="text-sm font-semibold text-slate-900 dark:text-white">Product Images</h3>
                <p class="mt-1 text-xs text-slate-500">Upload thumbnail and gallery images.</p>
                <div class="mt-4 flex h-40 items-center justify-center rounded-xl border border-dashed border-slate-300 bg-slate-50 text-xs text-slate-500 dark:border-slate-700 dark:bg-slate-900/60">
                    <template x-if="preview">
                        <img :src="preview" alt="Preview" class="h-32 w-32 rounded-xl object-cover" />
                    </template>
                    <template x-if="!preview">
                        <div class="text-center">
                            <p class="font-semibold">Drop image here</p>
                            <p class="text-xs">PNG, JPG up to 5MB</p>
                        </div>
                    </template>
                </div>
                <input type="file" name="thumbnail" form="product-create-form" class="mt-4 w-full text-sm text-slate-500" @change="const file = $event.target.files[0]; if (file) { const reader = new FileReader(); reader.onload = e => preview = e.target.result; reader.readAsDataURL(file); }" />
                <label class="mt-4 block text-xs font-semibold text-slate-600 dark:text-slate-300">Gallery Images</label>
                <div id="gallery-preview" class="mt-2 grid grid-cols-3 gap-2 text-xs text-slate-500"></div>
                <input type="file" name="image_gallery[]" form="product-create-form" multiple class="mt-2 w-full text-sm text-slate-500" />
            </div>

            <!-- Variant Summary Card -->
            <div class="rounded-2xl border border-primary-200 bg-primary-50 p-4 dark:border-primary-500/40 dark:bg-primary-500/10">
                <div class="flex items-start justify-between gap-3">
                    <div>
                        <h3 class="text-sm font-semibold text-primary-900 dark:text-primary-100">Variants Added</h3>
                        <p class="mt-1 text-xs text-primary-700 dark:text-primary-200">Total count of variants for this product.</p>
                    </div>
                    <span id="variant-count-badge" class="inline-flex rounded-full border border-primary-300 bg-primary-100 px-3 py-1 text-xs font-semibold text-primary-700 dark:border-primary-500/40 dark:bg-primary-500/20 dark:text-primary-200">0 variants</span>
                </div>
            </div>
        </div>
    </div>

    <script>
        (function () {
            const variants = [];
            let editIndex = null;

            const variantStorage = document.getElementById('variant-storage');
            const variantColor = document.getElementById('variant-color');
            const variantCondition = document.getElementById('variant-condition');
            const variantRam = document.getElementById('variant-ram');
            const variantSsd = document.getElementById('variant-ssd');
            const variantSku = document.getElementById('variant-sku');
            const variantPrice = document.getElementById('variant-price');
            const variantStock = document.getElementById('variant-stock');
            const variantImage = document.getElementById('variant-image');
            const variantAddBtn = document.getElementById('variant-add-btn');
            const variantClearBtn = document.getElementById('variant-clear-btn');
            const variantRows = document.getElementById('variant-table-body');
            const variantFormError = document.getElementById('variant-form-error');
            const variantCountBadge = document.getElementById('variant-count-badge');
            const productPriceInput = document.getElementById('price');
            const productStockInput = document.getElementById('stock');

            function cleanText(value) {
                return String(value || '').trim();
            }

            function toNumber(value, fallback) {
                const parsed = Number(value);
                return Number.isFinite(parsed) ? parsed : fallback;
            }

            function formatMoney(value) {
                return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(value || 0);
            }

            function variantKey(item) {
                return [item.storage_capacity, item.color, item.condition]
                    .map((value) => cleanText(value).toLowerCase())
                    .join('|');
            }

            function resetVariantForm() {
                editIndex = null;
                variantStorage.value = '';
                variantColor.value = '';
                variantCondition.value = '';
                variantRam.value = '';
                variantSsd.value = '';
                variantSku.value = '';
                variantPrice.value = '';
                variantStock.value = '';
                variantImage.value = '';
                variantFormError.textContent = '';
                variantAddBtn.textContent = 'Add Variant';
            }

            function updateVariantSummary() {
                variantCountBadge.textContent = variants.length + (variants.length === 1 ? ' variant' : ' variants');
                if (!variants.length) {
                    productPriceInput.value = '0';
                    productStockInput.value = '0';
                    return;
                }
                const minPrice = Math.min.apply(null, variants.map((item) => toNumber(item.price, 0)));
                const totalStock = variants.reduce((sum, item) => sum + toNumber(item.stock, 0), 0);
                productPriceInput.value = minPrice.toFixed(2);
                productStockInput.value = String(totalStock);
            }

            function renderVariantRows() {
                if (!variants.length) {
                    variantRows.innerHTML = '<tr><td colspan="10" class="px-3 py-4 text-center text-xs text-slate-500">No variants added yet.</td></tr>';
                    updateVariantSummary();
                    return;
                }

                variantRows.innerHTML = variants.map((item, index) => {
                    const hasNewFile = item.file instanceof File;
                    const imageText = hasNewFile ? item.file.name : (cleanText(item.image) ? 'Existing image' : 'None');
                    return `
                        <tr>
                            <td class="px-3 py-2">${item.storage_capacity}</td>
                            <td class="px-3 py-2">${item.color}</td>
                            <td class="px-3 py-2">${item.condition}</td>
                            <td class="px-3 py-2">${formatMoney(toNumber(item.price, 0))}</td>
                            <td class="px-3 py-2">${toNumber(item.stock, 0)}</td>
                            <td class="px-3 py-2">${cleanText(item.ram) || '--'}</td>
                            <td class="px-3 py-2">${cleanText(item.ssd) || '--'}</td>
                            <td class="px-3 py-2">${cleanText(item.sku) || '--'}</td>
                            <td class="px-3 py-2 text-xs text-slate-500">${imageText}</td>
                            <td class="px-3 py-2 text-right">
                                <button type="button" data-action="edit" data-index="${index}" class="text-xs font-semibold text-primary-600">Edit</button>
                                <button type="button" data-action="delete" data-index="${index}" class="ml-3 text-xs font-semibold text-danger-600">Delete</button>
                            </td>
                        </tr>
                    `;
                }).join('');

                updateVariantSummary();
            }

            function readVariantInput() {
                const payload = {
                    storage_capacity: cleanText(variantStorage.value),
                    color: cleanText(variantColor.value),
                    condition: cleanText(variantCondition.value),
                    ram: cleanText(variantRam.value),
                    ssd: cleanText(variantSsd.value),
                    price: toNumber(variantPrice.value, NaN),
                    stock: toNumber(variantStock.value, NaN),
                    sku: cleanText(variantSku.value),
                    image: null,
                    file: null,
                };

                if (!payload.storage_capacity || !payload.color || !payload.condition) {
                    return { error: 'Storage, color, and condition are required.' };
                }
                if (!Number.isFinite(payload.price) || payload.price < 0) {
                    return { error: 'Price must be 0 or higher.' };
                }
                if (!Number.isInteger(payload.stock) || payload.stock < 0) {
                    return { error: 'Stock must be 0 or higher.' };
                }

                const selectedFile = variantImage.files && variantImage.files[0] ? variantImage.files[0] : null;
                if (selectedFile) {
                    payload.file = selectedFile;
                }

                return { value: payload };
            }

            function fillVariantForm(index) {
                const item = variants[index];
                if (!item) {
                    return;
                }
                editIndex = index;
                variantStorage.value = cleanText(item.storage_capacity);
                variantColor.value = cleanText(item.color);
                variantCondition.value = cleanText(item.condition);
                variantRam.value = cleanText(item.ram);
                variantSsd.value = cleanText(item.ssd);
                variantSku.value = cleanText(item.sku);
                variantPrice.value = String(item.price ?? '');
                variantStock.value = String(item.stock ?? '');
                variantImage.value = '';
                variantFormError.textContent = '';
                variantAddBtn.textContent = 'Update Variant';
            }

            function addOrUpdateVariant() {
                const result = readVariantInput();
                if (result.error) {
                    variantFormError.textContent = result.error;
                    return;
                }

                const payload = result.value;
                const duplicate = variants.some((item, index) => {
                    if (editIndex !== null && editIndex === index) {
                        return false;
                    }
                    return variantKey(item) === variantKey(payload);
                });

                if (duplicate) {
                    variantFormError.textContent = 'This storage/color/condition combination already exists.';
                    return;
                }

                if (editIndex !== null) {
                    const previous = variants[editIndex];
                    const merged = Object.assign({}, previous, payload);
                    if (!(payload.file instanceof File)) {
                        merged.file = previous.file || null;
                    }
                    if (!payload.file && !payload.image) {
                        merged.image = previous.image || null;
                    }
                    variants[editIndex] = merged;
                } else {
                    variants.push(payload);
                }

                resetVariantForm();
                renderVariantRows();
            }

            function deleteVariant(index) {
                variants.splice(index, 1);
                if (editIndex === index) {
                    resetVariantForm();
                } else if (editIndex !== null && editIndex > index) {
                    editIndex -= 1;
                }
                renderVariantRows();
            }

            variantAddBtn.addEventListener('click', addOrUpdateVariant);
            variantClearBtn.addEventListener('click', resetVariantForm);

            variantRows.addEventListener('click', function (event) {
                const button = event.target.closest('button[data-action]');
                if (!button) {
                    return;
                }
                const action = button.getAttribute('data-action');
                const index = Number(button.getAttribute('data-index'));
                if (!Number.isInteger(index)) {
                    return;
                }
                if (action === 'edit') {
                    fillVariantForm(index);
                }
                if (action === 'delete') {
                    deleteVariant(index);
                }
            });

            function renderGalleryPreview(files, containerId) {
                const container = document.getElementById(containerId);
                if (!container) {
                    return;
                }
                container.innerHTML = '';
                Array.from(files || []).forEach(function (file) {
                    const reader = new FileReader();
                    reader.onload = function (e) {
                        const wrapper = document.createElement('div');
                        wrapper.className = 'h-20 w-full overflow-hidden rounded-lg border border-slate-200 bg-white dark:border-slate-800 dark:bg-slate-900';
                        const img = document.createElement('img');
                        img.src = e.target.result;
                        img.alt = file.name;
                        img.className = 'h-full w-full object-cover';
                        wrapper.appendChild(img);
                        container.appendChild(wrapper);
                    };
                    reader.readAsDataURL(file);
                });
            }

            async function loadCategories() {
                const select = document.getElementById('category');
                const selectedId = cleanText(select.value);

                await window.adminApi.ensureCsrfCookie();

                const categories = [];
                let page = 1;

                while (true) {
                    const response = await window.adminApi.request('/api/categories?per_page=100&page=' + page);
                    if (!response.ok) {
                        return;
                    }

                    const data = await response.json();
                    const list = Array.isArray(data.data) ? data.data : [];
                    categories.push.apply(categories, list);

                    if (!data.links || !data.links.next || !list.length) {
                        break;
                    }

                    page += 1;
                }

                select.innerHTML = '<option value="">Select category</option>' + categories.map(function (category) {
                    return '<option value="' + category.id + '">' + category.name + '</option>';
                }).join('');
                if (selectedId) {
                    select.value = selectedId;
                }
            }

            const galleryInput = document.querySelector('input[name="image_gallery[]"]');
            if (galleryInput) {
                galleryInput.addEventListener('change', function (event) {
                    const files = Array.from(event.target.files || []);
                    if (window.adminValidateFileSize) {
                        const hasOversized = files.some((file) => !window.adminValidateFileSize(file, 'Gallery image'));
                        if (hasOversized) {
                            event.target.value = '';
                            renderGalleryPreview([], 'gallery-preview');
                            document.getElementById('product-form-error').textContent = 'Gallery images must be 5MB or smaller.';
                            return;
                        }
                    }
                    document.getElementById('product-form-error').textContent = '';
                    renderGalleryPreview(event.target.files, 'gallery-preview');
                });
            }

            document.getElementById('product-create-form').addEventListener('submit', async function (event) {
                event.preventDefault();
                const errorBox = document.getElementById('product-form-error');
                errorBox.textContent = '';

                if (!variants.length) {
                    errorBox.textContent = 'Please add at least one variant.';
                    return;
                }

                const formData = new FormData(event.target);
                formData.set('variants', JSON.stringify(variants.map((item) => ({
                    storage_capacity: item.storage_capacity,
                    color: item.color,
                    condition: item.condition,
                    ram: cleanText(item.ram) || null,
                    ssd: cleanText(item.ssd) || null,
                    price: toNumber(item.price, 0),
                    stock: toNumber(item.stock, 0),
                    sku: cleanText(item.sku) || null,
                    image: cleanText(item.image) || null,
                }))));

                variants.forEach(function (item, index) {
                    if (item.file instanceof File) {
                        formData.append('variant_images[' + index + ']', item.file);
                    }
                });

                try {
                    await window.adminApi.ensureCsrfCookie();
                    const response = await window.adminApi.request('/api/products', {
                        method: 'POST',
                        body: formData,
                    });

                    if (response.ok) {
                        if (window.adminSwalStore) {
                            window.adminSwalStore({
                                icon: 'success',
                                title: 'Product created',
                                text: 'Product and variants created successfully.',
                                confirmButtonColor: '#2563eb',
                            });
                        }
                        window.location.href = '/admin/products';
                        return;
                    }

                    const errorData = await response.json();
                    errorBox.textContent = errorData.message || 'Unable to create product.';
                    if (window.adminSwalError) {
                        window.adminSwalError('Create failed', errorData.message || 'Unable to create product.');
                    }
                } catch (error) {
                    errorBox.textContent = 'Unable to create product.';
                    if (window.adminSwalError) {
                        window.adminSwalError('Create failed', 'Unable to create product.');
                    }
                }
            });

            function escapeAttrOption(value) {
                return String(value || '')
                    .replace(/&/g, '&amp;')
                    .replace(/</g, '&lt;')
                    .replace(/>/g, '&gt;')
                    .replace(/"/g, '&quot;');
            }

            async function loadAttributeOptions() {
                var selectMap = {
                    storage_capacity: { id: 'variant-storage',   placeholder: 'Select storage' },
                    color:            { id: 'variant-color',     placeholder: 'Select color' },
                    condition:        { id: 'variant-condition', placeholder: 'Select condition' },
                    ram:              { id: 'variant-ram',       placeholder: 'None' },
                    ssd:              { id: 'variant-ssd',       placeholder: 'None' },
                };

                // Set placeholders immediately — selects never stay on "Loading…"
                Object.keys(selectMap).forEach(function (type) {
                    var sel = document.getElementById(selectMap[type].id);
                    if (sel) sel.innerHTML = '<option value="">' + selectMap[type].placeholder + '</option>';
                });

                try {
                    await window.adminApi.ensureCsrfCookie();
                    var response = await window.adminApi.request('/api/product-attributes');
                    if (!response.ok) return;
                    var payload = await response.json();
                    var list = Array.isArray(payload.data) ? payload.data : [];

                    // Group values by type
                    var grouped = {};
                    list.forEach(function (item) {
                        if (!grouped[item.type]) grouped[item.type] = [];
                        grouped[item.type].push(item.value);
                    });

                    // Populate each select
                    Object.keys(selectMap).forEach(function (type) {
                        var cfg = selectMap[type];
                        var sel = document.getElementById(cfg.id);
                        if (!sel) return;
                        var values = grouped[type] || [];
                        if (values.length > 0) {
                            sel.innerHTML = '<option value="">' + cfg.placeholder + '</option>' +
                                values.map(function (v) {
                                    var e = escapeAttrOption(v);
                                    return '<option value="' + e + '">' + e + '</option>';
                                }).join('');
                        }
                    });
                } catch (e) {
                    // placeholders already set above
                }
            }

            loadCategories();
            renderVariantRows();

            // loadAttributeOptions must run after window.adminApi is defined by the layout
            document.addEventListener('DOMContentLoaded', function () {
                loadAttributeOptions();
            });
        })();
    </script>
@endsection
