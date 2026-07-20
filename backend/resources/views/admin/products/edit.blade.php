@extends('layouts.admin')

@section('title', 'Edit Product')
@section('page-title', 'Edit Product')

@section('content')
    <div class="grid gap-6 lg:grid-cols-[2fr_1fr]">
        <form
            id="product-edit-form"
            enctype="multipart/form-data"
            data-product-id="{{ $productId ?? '' }}"
            class="space-y-6 rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900"
        >
            <div>
                <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Edit Product</h2>
                <p class="text-sm text-slate-500">Update main info and maintain variants.</p>
            </div>

            <div class="grid gap-4 sm:grid-cols-2">
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="product-type">Product Type</label>
                    @php
                        $currentProductType = old('product_type', $product->product_type ?? 'mobile');
                    @endphp
                    <select id="product-type" name="product_type" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                        <option value="mobile" {{ $currentProductType === 'mobile' ? 'selected' : '' }}>Mobile</option>
                        <option value="mac" {{ $currentProductType === 'mac' ? 'selected' : '' }}>Mac</option>
                        <option value="accessory" {{ $currentProductType === 'accessory' ? 'selected' : '' }}>Accessory</option>
                    </select>
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="name">Product Name</label>
                    <input id="name" name="name" type="text" value="{{ old('name', $product->name ?? '') }}" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="brand">Brand</label>
                    <input id="brand" name="brand" type="text" value="{{ old('brand', $product->brand ?? '') }}" list="brand-presets" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    <datalist id="brand-presets">
                        <option value="Apple"></option>
                        <option value="Samsung"></option>
                    </datalist>
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="sku">SKU</label>
                    <input id="sku" name="sku" type="text" value="{{ old('sku', $product->sku ?? '') }}" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="category">Category</label>
                    <select id="category" name="category_id" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                        <option value="">Select category</option>
                        @foreach (($categories ?? collect()) as $cat)
                            <option value="{{ $cat->id }}" {{ old('category_id', $product->category_id ?? '') == $cat->id ? 'selected' : '' }}>{{ $cat->name }}</option>
                        @endforeach
                    </select>
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="status">Status</label>
                    <select id="status" name="status" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                        <option value="active" {{ old('status', $product->status ?? '') === 'active' ? 'selected' : '' }}>Active</option>
                        <option value="draft" {{ old('status', $product->status ?? '') === 'draft' ? 'selected' : '' }}>Draft</option>
                        <option value="archived" {{ old('status', $product->status ?? '') === 'archived' ? 'selected' : '' }}>Archived</option>
                    </select>
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="discount">Discount</label>
                    <input id="discount" name="discount" type="number" step="0.01" min="0" value="{{ old('discount', $product->discount ?? 0) }}" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="warranty">
                        Warranty
                        <span class="ml-1 text-xs font-normal text-slate-400">— auto-tracks when order completes</span>
                    </label>
                    @php
                        $warrantyLabels = [
                            'NO_WARRANTY' => 'No Warranty',
                            '1_DAYS'      => '1 Day',
                            '7_DAYS'      => '7 Days',
                            '14_DAYS'     => '14 Days',
                            '1_MONTH'     => '1 Month',
                            '3_MONTHS'    => '3 Months',
                            '6_MONTHS'    => '6 Months',
                            '1_YEAR'      => '1 Year',
                        ];
                    @endphp
                    <select id="warranty" name="warranty" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                        @foreach (\App\Models\Product::WARRANTIES as $w)
                            <option value="{{ $w }}" {{ old('warranty', $product->warranty ?? 'NO_WARRANTY') === $w ? 'selected' : '' }}>
                                {{ $warrantyLabels[$w] ?? $w }}
                            </option>
                        @endforeach
                    </select>
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="tag">Tag</label>
                    <select id="tag" name="tag" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                        <option value="">No tag</option>
                        @foreach (\App\Models\Product::TAGS as $t)
                            <option value="{{ $t }}" {{ old('tag', $product->tag ?? '') === $t ? 'selected' : '' }}>{{ \Illuminate\Support\Str::title(str_replace('_', ' ', strtolower($t))) }}</option>
                        @endforeach
                    </select>
                </div>
            </div>

            <div>
                <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="description">Description</label>
                <textarea id="description" name="description" rows="4" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">{{ old('description', $product->description ?? '') }}</textarea>
            </div>

            <div class="rounded-2xl border border-slate-200 p-4 dark:border-slate-800">
                <div class="flex flex-wrap items-center justify-between gap-3">
                    <div>
                        <h3 class="text-sm font-semibold text-slate-900 dark:text-white">Variant Summary</h3>
                        <p class="text-xs text-slate-500">Price and stock are calculated from variants.</p>
                    </div>
                    <span id="variant-count-badge" class="inline-flex rounded-full border border-primary-200 bg-primary-50 px-3 py-1 text-xs font-semibold text-primary-700 dark:border-primary-500/40 dark:bg-primary-500/10 dark:text-primary-200">0 variants</span>
                </div>
                <div class="mt-4 grid gap-4 sm:grid-cols-2">
                    <div>
                        <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="price">Price (From)</label>
                        <input id="price" name="price" type="number" step="0.01" min="0" readonly class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-100 px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    </div>
                    <div>
                        <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="stock">Total Stock</label>
                        <input id="stock" name="stock" type="number" min="0" readonly class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-100 px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    </div>
                </div>
            </div>

            <div class="rounded-2xl border border-slate-200 p-4 dark:border-slate-800">
                <div class="flex items-center justify-between gap-3">
                    <div>
                        <h3 class="text-sm font-semibold text-slate-900 dark:text-white">Variant Builder</h3>
                        <p id="variant-section-hint" class="text-xs text-slate-500">Add, edit, or delete product variants.</p>
                    </div>
                    <button id="variant-clear-btn" type="button" class="rounded-lg border border-slate-200 px-3 py-1 text-xs font-semibold text-slate-600 dark:border-slate-700 dark:text-slate-300">Clear</button>
                </div>

                <div class="mt-4 grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
                    <div data-variant-field="display">
                        <label class="text-xs font-semibold text-slate-600 dark:text-slate-300" for="variant-display" id="variant-label-display">Display</label>
                        <select id="variant-display" class="mt-1 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200"></select>
                    </div>
                    <div data-variant-field="cpu">
                        <label class="text-xs font-semibold text-slate-600 dark:text-slate-300" for="variant-cpu" id="variant-label-cpu">CPU</label>
                        <select id="variant-cpu" class="mt-1 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200"></select>
                    </div>
                    <div data-variant-field="storage">
                        <label class="text-xs font-semibold text-slate-600 dark:text-slate-300" for="variant-storage" id="variant-label-storage">Storage</label>
                        <select id="variant-storage" class="mt-1 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200"></select>
                    </div>
                    <div data-variant-field="ram">
                        <label class="text-xs font-semibold text-slate-600 dark:text-slate-300" for="variant-ram" id="variant-label-ram">RAM</label>
                        <select id="variant-ram" class="mt-1 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200"></select>
                    </div>
                    <div data-variant-field="ssd">
                        <label class="text-xs font-semibold text-slate-600 dark:text-slate-300" for="variant-ssd" id="variant-label-ssd">SSD</label>
                        <select id="variant-ssd" class="mt-1 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200"></select>
                    </div>
                    <div data-variant-field="color">
                        <label class="text-xs font-semibold text-slate-600 dark:text-slate-300" for="variant-color" id="variant-label-color">Color</label>
                        <select id="variant-color" class="mt-1 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200"></select>
                    </div>
                    <div data-variant-field="condition">
                        <label class="text-xs font-semibold text-slate-600 dark:text-slate-300" for="variant-condition" id="variant-label-condition">Condition</label>
                        <select id="variant-condition" class="mt-1 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200"></select>
                    </div>
                    <div data-variant-field="country">
                        <label class="text-xs font-semibold text-slate-600 dark:text-slate-300" for="variant-country" id="variant-label-country">Country</label>
                        <select id="variant-country" class="mt-1 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200"></select>
                    </div>
                    <div>
                        <label class="text-xs font-semibold text-slate-600 dark:text-slate-300" for="variant-sku">SKU</label>
                        <input id="variant-sku" type="text" class="mt-1 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    </div>
                    <div>
                        <label class="text-xs font-semibold text-slate-600 dark:text-slate-300" for="variant-price">Price</label>
                        <input id="variant-price" type="number" step="0.01" min="0" class="mt-1 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    </div>
                    <div>
                        <label class="text-xs font-semibold text-slate-600 dark:text-slate-300" for="variant-stock">Stock</label>
                        <input id="variant-stock" type="number" min="0" class="mt-1 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    </div>
                    <div>
                        <label class="text-xs font-semibold text-slate-600 dark:text-slate-300" for="variant-image">Variant Image</label>
                        <input id="variant-image" type="file" accept="image/*" class="mt-1 w-full text-xs text-slate-500" />
                    </div>
                </div>

                <div class="mt-4 flex items-center gap-2">
                    <button id="variant-add-btn" type="button" class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white">Add Variant</button>
                    <p id="variant-form-error" class="text-xs text-danger-600"></p>
                </div>

                <div class="mt-4 overflow-x-auto rounded-xl border border-slate-200 dark:border-slate-800">
                    <table class="w-full text-left text-sm">
                        <thead class="bg-slate-50 text-xs uppercase tracking-wider text-slate-500 dark:bg-slate-950 dark:text-slate-400">
                            <tr id="variant-table-head"></tr>
                        </thead>
                        <tbody id="variant-table-body" class="divide-y divide-slate-200 dark:divide-slate-800"></tbody>
                    </table>
                </div>
            </div>

            <div class="flex items-center gap-3">
                <button class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white shadow-sm">Save Changes</button>
                <a href="{{ route('admin.products.index') }}" class="text-sm font-semibold text-slate-500">Cancel</a>
            </div>
            <p id="product-form-error" class="text-sm text-danger-600"></p>
        </form>

        <div class="space-y-6">
            <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <h3 class="text-sm font-semibold text-slate-900 dark:text-white">Current Thumbnail</h3>
                @php
                    // Resolve the stored path to a displayable URL for both local and S3/R2 storage.
                    $thumbRaw = $product->thumbnail ?? $product->image ?? null;
                    if ($thumbRaw) {
                        if (str_starts_with($thumbRaw, 'http://') || str_starts_with($thumbRaw, 'https://')) {
                            $thumbUrl = $thumbRaw;
                        } else {
                            // Strip 'storage/' prefix so Storage::url() gets the disk-relative path.
                            $thumbKey = preg_replace('#^storage/#', '', ltrim($thumbRaw, '/'));
                            $thumbUrl = \Illuminate\Support\Facades\Storage::disk('public')->url($thumbKey);
                        }
                    } else {
                        $thumbUrl = null;
                    }
                @endphp
                <div id="current-thumbnail-wrapper" class="mt-3 {{ $thumbUrl ? '' : 'hidden' }} h-40 overflow-hidden rounded-xl border border-slate-200 bg-slate-50 dark:border-slate-800 dark:bg-slate-900/50">
                    <img id="current-thumbnail-image" src="{{ $thumbUrl ?? '' }}" alt="Current thumbnail" class="h-full w-full object-cover" />
                </div>
                <p id="current-thumbnail" class="mt-2 text-xs text-slate-500">{{ $thumbRaw ? basename($thumbRaw) : 'No image' }}</p>
                <input type="file" name="thumbnail" form="product-edit-form" class="mt-3 w-full text-sm text-slate-500" />

                <label class="mt-4 block text-xs font-semibold text-slate-600 dark:text-slate-300">Current Gallery</label>
                <div id="current-gallery" class="mt-2 grid grid-cols-3 gap-2">
                    @php
                        $gallery = is_array($product->image_gallery ?? null) ? $product->image_gallery : [];
                    @endphp
                    @forelse ($gallery as $img)
                        @php
                            if ($img) {
                                if (str_starts_with($img, 'http://') || str_starts_with($img, 'https://')) {
                                    $imgUrl = $img;
                                } else {
                                    $imgKey = preg_replace('#^storage/#', '', ltrim($img, '/'));
                                    $imgUrl = \Illuminate\Support\Facades\Storage::disk('public')->url($imgKey);
                                }
                            } else {
                                $imgUrl = null;
                            }
                        @endphp
                        @if ($imgUrl)
                            <div class="h-20 overflow-hidden rounded-lg border border-slate-200 bg-white dark:border-slate-800 dark:bg-slate-900">
                                <img src="{{ $imgUrl }}" alt="gallery" class="h-full w-full object-cover" />
                            </div>
                        @endif
                    @empty
                        <p class="col-span-3 text-xs text-slate-400">No gallery images</p>
                    @endforelse
                </div>

                <label class="mt-4 block text-xs font-semibold text-slate-600 dark:text-slate-300">Replace Gallery</label>
                <div id="gallery-preview" class="mt-2 grid grid-cols-3 gap-2"></div>
                <input type="file" name="image_gallery[]" form="product-edit-form" multiple class="mt-2 w-full text-sm text-slate-500" />
            </div>
        </div>
    </div>

    <script>
        (function () {
            const form = document.getElementById('product-edit-form');
            const productId = form.dataset.productId;
            const variants = [];
            let editIndex = null;
            let masterOptions = {};

            // Variant attribute fields shown per product type (same config as the create page).
            const VARIANT_FIELDS = {
                display: { payloadKey: 'display',          masterType: 'display',          label: 'Display',   placeholder: 'Select display' },
                cpu:     { payloadKey: 'cpu',              masterType: 'cpu',              label: 'CPU',       placeholder: 'Select CPU' },
                storage: { payloadKey: 'storage_capacity', masterType: 'storage_capacity', label: 'Storage',   placeholder: 'Select storage' },
                ram:     { payloadKey: 'ram',              masterType: 'ram',              label: 'RAM',       placeholder: 'Select RAM' },
                ssd:     { payloadKey: 'ssd',              masterType: 'ssd',              label: 'SSD',       placeholder: 'Select SSD' },
                color:   { payloadKey: 'color',            masterType: 'color',            label: 'Color',     placeholder: 'Select color' },
                condition: { payloadKey: 'condition',      masterType: 'condition',        label: 'Condition', placeholder: 'Select condition' },
                country: { payloadKey: 'country',          masterType: 'country',          label: 'Country',   placeholder: 'Select country' },
            };

            const TYPE_CONFIG = {
                mobile: {
                    fields: ['storage', 'color', 'condition', 'country'],
                    required: ['storage', 'color', 'condition'],
                    labels: {},
                    hint: 'Mobile variants: storage, color, condition, country, price, SKU and stock.',
                },
                mac: {
                    fields: ['display', 'cpu', 'storage', 'ram', 'ssd', 'color', 'condition', 'country'],
                    required: ['storage', 'color', 'condition'],
                    labels: { storage: 'Capacity', ssd: 'Storage (SSD)' },
                    hint: 'Mac variants: display, CPU, capacity, RAM, storage, color, condition and country — options come from Product Master.',
                },
                accessory: {
                    fields: ['color'],
                    required: [],
                    labels: {},
                    hint: 'Accessory variants: color (optional), price, SKU and stock.',
                },
            };

            const productTypeSelect = document.getElementById('product-type');
            const variantSku = document.getElementById('variant-sku');
            const variantPrice = document.getElementById('variant-price');
            const variantStock = document.getElementById('variant-stock');
            const variantImage = document.getElementById('variant-image');
            const variantAddBtn = document.getElementById('variant-add-btn');
            const variantClearBtn = document.getElementById('variant-clear-btn');
            const variantHead = document.getElementById('variant-table-head');
            const variantRows = document.getElementById('variant-table-body');
            const variantFormError = document.getElementById('variant-form-error');
            const variantCountBadge = document.getElementById('variant-count-badge');
            const variantSectionHint = document.getElementById('variant-section-hint');
            const productPriceInput = document.getElementById('price');
            const productStockInput = document.getElementById('stock');

            function currentConfig() {
                return TYPE_CONFIG[productTypeSelect.value] || TYPE_CONFIG.mobile;
            }

            function fieldSelect(key) {
                return document.getElementById('variant-' + key);
            }

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

            function escapeHtml(value) {
                return String(value || '')
                    .replace(/&/g, '&amp;')
                    .replace(/</g, '&lt;')
                    .replace(/>/g, '&gt;')
                    .replace(/"/g, '&quot;');
            }

            function variantKey(item) {
                return currentConfig().fields
                    .map((key) => cleanText(item[VARIANT_FIELDS[key].payloadKey]).toLowerCase())
                    .join('|');
            }

            function applyVariantFields() {
                const config = currentConfig();

                document.querySelectorAll('[data-variant-field]').forEach(function (wrapper) {
                    const key = wrapper.getAttribute('data-variant-field');
                    wrapper.classList.toggle('hidden', config.fields.indexOf(key) === -1);
                });

                config.fields.forEach(function (key) {
                    const label = document.getElementById('variant-label-' + key);
                    if (label) {
                        const text = config.labels[key] || VARIANT_FIELDS[key].label;
                        label.textContent = text + (config.required.indexOf(key) !== -1 ? ' *' : '');
                    }
                });

                variantSectionHint.textContent = config.hint;
                renderVariantHead();
            }

            function renderVariantHead() {
                const config = currentConfig();
                const cells = config.fields.map(function (key) {
                    return '<th class="px-3 py-2">' + escapeHtml(config.labels[key] || VARIANT_FIELDS[key].label) + '</th>';
                });
                cells.push('<th class="px-3 py-2">Price</th>');
                cells.push('<th class="px-3 py-2">Stock</th>');
                cells.push('<th class="px-3 py-2">SKU</th>');
                cells.push('<th class="px-3 py-2">Image</th>');
                cells.push('<th class="px-3 py-2 text-right">Action</th>');
                variantHead.innerHTML = cells.join('');
            }

            function resetVariantForm() {
                editIndex = null;
                Object.keys(VARIANT_FIELDS).forEach(function (key) {
                    const select = fieldSelect(key);
                    if (select) select.value = '';
                });
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
                const config = currentConfig();
                const columnCount = config.fields.length + 5;

                if (!variants.length) {
                    variantRows.innerHTML = '<tr><td colspan="' + columnCount + '" class="px-3 py-4 text-center text-xs text-slate-500">No variants configured.</td></tr>';
                    updateVariantSummary();
                    return;
                }

                variantRows.innerHTML = variants.map(function (item, index) {
                    const hasNewFile = item.file instanceof File;
                    const imageText = hasNewFile ? item.file.name : (cleanText(item.image) ? 'Existing image' : 'None');
                    const cells = config.fields.map(function (key) {
                        return '<td class="px-3 py-2">' + (escapeHtml(cleanText(item[VARIANT_FIELDS[key].payloadKey])) || '--') + '</td>';
                    });
                    cells.push('<td class="px-3 py-2">' + formatMoney(toNumber(item.price, 0)) + '</td>');
                    cells.push('<td class="px-3 py-2">' + toNumber(item.stock, 0) + '</td>');
                    cells.push('<td class="px-3 py-2">' + (escapeHtml(cleanText(item.sku)) || '--') + '</td>');
                    cells.push('<td class="px-3 py-2 text-xs text-slate-500">' + escapeHtml(imageText) + '</td>');
                    cells.push(
                        '<td class="px-3 py-2 text-right">'
                        + '<button type="button" data-action="edit" data-index="' + index + '" class="text-xs font-semibold text-primary-600">Edit</button>'
                        + '<button type="button" data-action="delete" data-index="' + index + '" class="ml-3 text-xs font-semibold text-danger-600">Delete</button>'
                        + '</td>'
                    );
                    return '<tr>' + cells.join('') + '</tr>';
                }).join('');

                updateVariantSummary();
            }

            function readVariantInput() {
                const config = currentConfig();
                const payload = {
                    storage_capacity: '',
                    color: '',
                    condition: '',
                    ram: '',
                    ssd: '',
                    cpu: '',
                    display: '',
                    country: '',
                    price: toNumber(variantPrice.value, NaN),
                    stock: toNumber(variantStock.value, NaN),
                    sku: cleanText(variantSku.value),
                    image: null,
                    file: null,
                };

                config.fields.forEach(function (key) {
                    payload[VARIANT_FIELDS[key].payloadKey] = cleanText(fieldSelect(key).value);
                });

                const missing = config.required.filter(function (key) {
                    return !payload[VARIANT_FIELDS[key].payloadKey];
                });
                if (missing.length) {
                    const names = missing.map(function (key) {
                        return config.labels[key] || VARIANT_FIELDS[key].label;
                    });
                    return { error: names.join(', ') + (missing.length === 1 ? ' is required.' : ' are required.') };
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
                Object.keys(VARIANT_FIELDS).forEach(function (key) {
                    const select = fieldSelect(key);
                    if (select) select.value = cleanText(item[VARIANT_FIELDS[key].payloadKey]);
                });
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
                    variantFormError.textContent = 'This variant combination already exists.';
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

            productTypeSelect.addEventListener('change', function () {
                resetVariantForm();
                applyVariantFields();
                renderVariantRows();
            });

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

            // Blade already renders all basic fields server-side.
            // JS only needs to load variants (not server-side rendered).
            async function loadVariants() {
                if (!productId) {
                    return;
                }

                await window.adminApi.ensureCsrfCookie();
                const response = await window.adminApi.request('/api/products/' + productId);
                if (!response.ok) {
                    return;
                }

                const payload = await response.json();
                const product = payload.data || payload;

                variants.splice(0, variants.length);
                (product.variants || []).forEach(function (item) {
                    variants.push({
                        storage_capacity: cleanText(item.storage_capacity),
                        color: cleanText(item.color),
                        condition: cleanText(item.condition),
                        ram: cleanText(item.ram),
                        ssd: cleanText(item.ssd),
                        cpu: cleanText(item.cpu),
                        display: cleanText(item.display),
                        country: cleanText(item.country),
                        price: toNumber(item.price, 0),
                        stock: toNumber(item.stock, 0),
                        sku: cleanText(item.sku),
                        image: cleanText(item.image),
                        file: null,
                    });
                });

                renderVariantRows();
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

            form.addEventListener('submit', async function (event) {
                event.preventDefault();
                const errorBox = document.getElementById('product-form-error');
                errorBox.textContent = '';

                if (!variants.length) {
                    errorBox.textContent = 'Please keep at least one variant.';
                    return;
                }

                const formData = new FormData(form);
                formData.append('_method', 'PUT');
                formData.set('variants', JSON.stringify(variants.map((item) => ({
                    storage_capacity: cleanText(item.storage_capacity) || null,
                    color: cleanText(item.color) || null,
                    condition: cleanText(item.condition) || null,
                    ram: cleanText(item.ram) || null,
                    ssd: cleanText(item.ssd) || null,
                    cpu: cleanText(item.cpu) || null,
                    display: cleanText(item.display) || null,
                    country: cleanText(item.country) || null,
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
                    const response = await window.adminApi.request('/api/products/' + productId, {
                        method: 'POST',
                        body: formData,
                    });

                    if (response.ok) {
                        if (window.adminSwalStore) {
                            window.adminSwalStore({
                                icon: 'success',
                                title: 'Product updated',
                                text: 'Product and variants updated successfully.',
                                confirmButtonColor: '#2563eb',
                            });
                        }
                        window.location.href = '/admin/products';
                        return;
                    }

                    const errorData = await response.json();
                    errorBox.textContent = errorData.message || 'Unable to update product.';
                    if (window.adminSwalError) {
                        window.adminSwalError('Update failed', errorData.message || 'Unable to update product.');
                    }
                } catch (error) {
                    errorBox.textContent = 'Unable to update product.';
                    if (window.adminSwalError) {
                        window.adminSwalError('Update failed', 'Unable to update product.');
                    }
                }
            });

            function populateAttributeSelects() {
                Object.keys(VARIANT_FIELDS).forEach(function (key) {
                    const cfg = VARIANT_FIELDS[key];
                    const select = fieldSelect(key);
                    if (!select) {
                        return;
                    }
                    const current = select.value;
                    const values = masterOptions[cfg.masterType] || [];
                    select.innerHTML = '<option value="">' + escapeHtml(cfg.placeholder) + '</option>'
                        + values.map(function (value) {
                            const escaped = escapeHtml(value);
                            return '<option value="' + escaped + '">' + escaped + '</option>';
                        }).join('');
                    if (current) {
                        select.value = current;
                    }
                });
            }

            // Options come from the Product Master (product attribute options).
            async function loadAttributeOptions() {
                populateAttributeSelects();

                try {
                    await window.adminApi.ensureCsrfCookie();
                    const response = await window.adminApi.request('/api/product-attributes');
                    if (!response.ok) return;
                    const payload = await response.json();
                    const list = Array.isArray(payload.data) ? payload.data : [];

                    masterOptions = {};
                    list.forEach(function (item) {
                        if (!masterOptions[item.type]) masterOptions[item.type] = [];
                        masterOptions[item.type].push(item.value);
                    });

                    populateAttributeSelects();
                } catch (e) {
                    // placeholders already set above
                }
            }

            // Both calls need window.adminApi (defined by layout after @yield('content')).
            // DOMContentLoaded fires after all scripts are parsed, so adminApi is ready.
            document.addEventListener('DOMContentLoaded', function () {
                loadAttributeOptions();
                if (productId) {
                    loadVariants();
                }
            });
            applyVariantFields();
            renderVariantRows(); // Shows empty-state immediately while variants load
        })();
    </script>
@endsection
