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
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="name">Product Name</label>
                    <input id="name" name="name" type="text" value="{{ old('name', $product->name ?? '') }}" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="brand">Brand</label>
                    <input id="brand" name="brand" type="text" value="{{ old('brand', $product->brand ?? '') }}" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
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
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="cpu">CPU</label>
                    <input id="cpu" name="cpu" type="text" value="{{ old('cpu', is_array($product->cpu ?? null) ? implode(', ', $product->cpu) : ($product->cpu ?? '')) }}" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="display">Display</label>
                    <input id="display" name="display" type="text" value="{{ old('display', is_array($product->display ?? null) ? implode(', ', $product->display) : ($product->display ?? '')) }}" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="country">Country / Region</label>
                    <input id="country" name="country" type="text" value="{{ old('country', is_array($product->country ?? null) ? implode(', ', $product->country) : ($product->country ?? '')) }}" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="warranty">Warranty</label>
                    <select id="warranty" name="warranty" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                        <option value="">Select warranty</option>
                        @foreach (\App\Models\Product::WARRANTIES as $w)
                            <option value="{{ $w }}" {{ old('warranty', $product->warranty ?? '') === $w ? 'selected' : '' }}>{{ $w }}</option>
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
                        <p class="text-xs text-slate-500">Add, edit, or delete product variants.</p>
                    </div>
                    <button id="variant-clear-btn" type="button" class="rounded-lg border border-slate-200 px-3 py-1 text-xs font-semibold text-slate-600 dark:border-slate-700 dark:text-slate-300">Clear</button>
                </div>

                <div class="mt-4 grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
                    <div>
                        <label class="text-xs font-semibold text-slate-600 dark:text-slate-300" for="variant-storage">Storage</label>
                        <select id="variant-storage" class="mt-1 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                            <option value="">Select</option>
                            <option value="128GB">128GB</option>
                            <option value="256GB">256GB</option>
                            <option value="512GB">512GB</option>
                            <option value="1TB">1TB</option>
                        </select>
                    </div>
                    <div>
                        <label class="text-xs font-semibold text-slate-600 dark:text-slate-300" for="variant-color">Color</label>
                        <select id="variant-color" class="mt-1 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                            <option value="">Select</option>
                            <option value="Black">Black</option>
                            <option value="White">White</option>
                            <option value="Blue">Blue</option>
                            <option value="Gold">Gold</option>
                            <option value="Natural Titanium">Natural Titanium</option>
                        </select>
                    </div>
                    <div>
                        <label class="text-xs font-semibold text-slate-600 dark:text-slate-300" for="variant-condition">Condition</label>
                        <select id="variant-condition" class="mt-1 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                            <option value="">Select</option>
                            <option value="New">New</option>
                            <option value="Used">Used</option>
                            <option value="Like New">Like New</option>
                            <option value="Refurbished">Refurbished</option>
                        </select>
                    </div>
                    <div>
                        <label class="text-xs font-semibold text-slate-600 dark:text-slate-300" for="variant-ram">RAM</label>
                        <input id="variant-ram" type="text" class="mt-1 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    </div>
                    <div>
                        <label class="text-xs font-semibold text-slate-600 dark:text-slate-300" for="variant-ssd">SSD</label>
                        <input id="variant-ssd" type="text" class="mt-1 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
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

            <div class="flex items-center gap-3">
                <button class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white shadow-sm">Save Changes</button>
                <a href="{{ route('admin.products.index') }}" class="text-sm font-semibold text-slate-500">Cancel</a>
            </div>
            <p id="product-form-error" class="text-sm text-danger-600"></p>
        </form>

        <div class="space-y-6">
            <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <h3 class="text-sm font-semibold text-slate-900 dark:text-white">Current Thumbnail</h3>
                @php $thumbUrl = $product->thumbnail ?? $product->image ?? null; @endphp
                <div id="current-thumbnail-wrapper" class="mt-3 {{ $thumbUrl ? '' : 'hidden' }} h-40 overflow-hidden rounded-xl border border-slate-200 bg-slate-50 dark:border-slate-800 dark:bg-slate-900/50">
                    <img id="current-thumbnail-image" src="{{ $thumbUrl ? (str_starts_with($thumbUrl, 'http') ? $thumbUrl : '/'.$thumbUrl) : '' }}" alt="Current thumbnail" class="h-full w-full object-cover" />
                </div>
                <p id="current-thumbnail" class="mt-2 text-xs text-slate-500">{{ $thumbUrl ? basename($thumbUrl) : 'No image' }}</p>
                <input type="file" name="thumbnail" form="product-edit-form" class="mt-3 w-full text-sm text-slate-500" />

                <label class="mt-4 block text-xs font-semibold text-slate-600 dark:text-slate-300">Current Gallery</label>
                <div id="current-gallery" class="mt-2 grid grid-cols-3 gap-2">
                    @php $gallery = is_array($product->image_gallery ?? null) ? $product->image_gallery : []; @endphp
                    @forelse ($gallery as $img)
                        @php $imgUrl = $img ? (str_starts_with($img, 'http') ? $img : '/'.$img) : ''; @endphp
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

            function toArrayText(value) {
                if (Array.isArray(value)) {
                    return value.map((item) => cleanText(item)).filter(Boolean).join(', ');
                }
                return cleanText(value);
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
                    variantRows.innerHTML = '<tr><td colspan="10" class="px-3 py-4 text-center text-xs text-slate-500">No variants configured.</td></tr>';
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

            async function loadCategories(selectedId) {
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

                const select = document.getElementById('category');
                select.innerHTML = '<option value="">Select category</option>' + categories.map(function (category) {
                    const selected = selectedId && String(category.id) === String(selectedId) ? ' selected' : '';
                    return '<option value="' + category.id + '"' + selected + '>' + category.name + '</option>';
                }).join('');
            }

            function renderCurrentGallery(items) {
                const container = document.getElementById('current-gallery');
                if (!container) {
                    return;
                }
                const images = Array.isArray(items) ? items : [];
                if (!images.length) {
                    container.innerHTML = '<p class="col-span-3 text-xs text-slate-400">No gallery images</p>';
                    return;
                }

                container.innerHTML = images.map(function (url) {
                    const safeUrl = String(url || '').trim();
                    if (!safeUrl) {
                        return '';
                    }
                    return '<div class="h-20 overflow-hidden rounded-lg border border-slate-200 bg-white dark:border-slate-800 dark:bg-slate-900"><img src="' + safeUrl + '" alt="gallery" class="h-full w-full object-cover" /></div>';
                }).join('');
            }

            async function loadProduct() {
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

                document.getElementById('name').value = cleanText(product.name);
                document.getElementById('brand').value = cleanText(product.brand);
                document.getElementById('sku').value = cleanText(product.sku);
                document.getElementById('status').value = cleanText(product.status) || 'active';
                document.getElementById('discount').value = product.discount ?? 0;
                document.getElementById('cpu').value = toArrayText(product.cpu);
                document.getElementById('display').value = toArrayText(product.display);
                document.getElementById('country').value = toArrayText(product.country);
                document.getElementById('warranty').value = cleanText(product.warranty);
                document.getElementById('tag').value = cleanText(product.tag);
                document.getElementById('description').value = cleanText(product.description);

                await loadCategories(product.category && product.category.id ? product.category.id : null);

                const thumbUrl = cleanText(product.thumbnail || product.image);
                const thumbLabel = document.getElementById('current-thumbnail');
                const thumbWrap = document.getElementById('current-thumbnail-wrapper');
                const thumbImg = document.getElementById('current-thumbnail-image');
                if (thumbUrl) {
                    thumbLabel.textContent = thumbUrl.split('/').pop();
                    thumbImg.src = thumbUrl;
                    thumbWrap.classList.remove('hidden');
                } else {
                    thumbLabel.textContent = 'No image';
                    thumbImg.removeAttribute('src');
                    thumbWrap.classList.add('hidden');
                }

                renderCurrentGallery(product.image_gallery || []);

                variants.splice(0, variants.length);
                (product.variants || []).forEach(function (item) {
                    variants.push({
                        storage_capacity: cleanText(item.storage_capacity),
                        color: cleanText(item.color),
                        condition: cleanText(item.condition),
                        ram: cleanText(item.ram),
                        ssd: cleanText(item.ssd),
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

            if (productId) {
                loadProduct();
            } else {
                loadCategories();
            }
            renderVariantRows();
        })();
    </script>
@endsection
