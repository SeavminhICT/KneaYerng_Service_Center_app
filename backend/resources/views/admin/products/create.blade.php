@extends('layouts.admin')

@section('title', __('Create Product'))
@section('page-title', __('Create Product'))

@section('content')
    <div class="grid gap-6 lg:grid-cols-[2fr_1fr]">
        <form
            id="product-create-form"
            enctype="multipart/form-data"
            class="space-y-4 rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900"
        >
            <div>
                <h2 class="text-lg font-semibold text-slate-900 dark:text-white">{{ __('Create Product') }}</h2>
                <p class="text-sm text-slate-500">{{ __('Select a product type, then fill in the details and add variants.') }}</p>
            </div>

            <!-- Product Type Selector -->
            <div class="rounded-2xl border border-slate-200 p-4 dark:border-slate-800">
                <h3 class="text-sm font-semibold text-slate-900 dark:text-white">{{ __('Product Type') }} *</h3>
                <div id="product-type-group" class="mt-3 grid gap-3 sm:grid-cols-3">
                    <label class="product-type-card flex cursor-pointer items-center gap-3 rounded-xl border border-slate-200 bg-white p-3 transition-colors hover:border-primary-400 dark:border-slate-700 dark:bg-slate-900/60">
                        <input type="radio" name="product_type" value="mobile" checked class="h-4 w-4 text-primary-600 focus:ring-primary-500" />
                        <span>
                            <span class="block text-sm font-semibold text-slate-900 dark:text-white">{{ __('Mobile') }}</span>
                            <span class="block text-xs text-slate-500">{{ __('iPhone & smartphones') }}</span>
                        </span>
                    </label>
                    <label class="product-type-card flex cursor-pointer items-center gap-3 rounded-xl border border-slate-200 bg-white p-3 transition-colors hover:border-primary-400 dark:border-slate-700 dark:bg-slate-900/60">
                        <input type="radio" name="product_type" value="mac" class="h-4 w-4 text-primary-600 focus:ring-primary-500" />
                        <span>
                            <span class="block text-sm font-semibold text-slate-900 dark:text-white">{{ __('Mac') }}</span>
                            <span class="block text-xs text-slate-500">{{ __('MacBook & laptops') }}</span>
                        </span>
                    </label>
                    <label class="product-type-card flex cursor-pointer items-center gap-3 rounded-xl border border-slate-200 bg-white p-3 transition-colors hover:border-primary-400 dark:border-slate-700 dark:bg-slate-900/60">
                        <input type="radio" name="product_type" value="accessory" class="h-4 w-4 text-primary-600 focus:ring-primary-500" />
                        <span>
                            <span class="block text-sm font-semibold text-slate-900 dark:text-white">{{ __('Accessory') }}</span>
                            <span class="block text-xs text-slate-500">{{ __('Cases, chargers & more') }}</span>
                        </span>
                    </label>
                </div>
            </div>

            <!-- Basic Information Section -->
            <div x-data="{ open: true }" class="rounded-2xl border border-slate-200 dark:border-slate-800">
                <button type="button" @click="open = !open" class="flex w-full items-center justify-between p-4 hover:bg-slate-50 dark:hover:bg-slate-800/50">
                    <h3 class="text-sm font-semibold text-slate-900 dark:text-white">{{ __('Basic Information') }}</h3>
                    <svg :class="{ 'rotate-180': open }" class="h-5 w-5 transition-transform text-slate-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 14l-7 7m0 0l-7-7m7 7V3" />
                    </svg>
                </button>
                <div x-show="open" class="space-y-4 border-t border-slate-200 bg-slate-50 p-4 dark:border-slate-800 dark:bg-slate-900/50">
                    <div class="grid gap-4 sm:grid-cols-2">
                        <div>
                            <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="name-select">{{ __('Product Name') }} *</label>
                            <select id="name-select" class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                                <option value="">{{ __('Select model') }}</option>
                            </select>
                            <input id="name" name="name" type="text" placeholder="{{ __('Product name') }}" class="mt-2 hidden w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                        </div>
                        <div>
                            <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="brand-select">{{ __('Brand') }}</label>
                            <select id="brand-select" class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                                <option value="Apple" selected>Apple</option>
                                <option value="Samsung">Samsung</option>
                            </select>
                            <input id="brand" name="brand" type="text" value="Apple" placeholder="{{ __('Brand') }}" class="mt-2 hidden w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                        </div>
                        <div>
                            <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="category">{{ __('Category') }}</label>
                            <select id="category" name="category_id" class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                                <option value="">{{ __('Select category') }}</option>
                                @foreach (($categories ?? collect()) as $category)
                                    <option value="{{ $category->id }}">{{ $category->name }}</option>
                                @endforeach
                            </select>
                        </div>
                        <div>
                            <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="status">{{ __('Status') }}</label>
                            <select id="status" name="status" class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                                <option value="active" selected>{{ __('Active') }}</option>
                                <option value="draft">{{ __('Draft') }}</option>
                                <option value="archived">{{ __('Archived') }}</option>
                            </select>
                        </div>
                    </div>
                    <div>
                        <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="description">{{ __('Description') }}</label>
                        <textarea id="description" name="description" rows="4" class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200"></textarea>
                    </div>
                </div>
            </div>

            <!-- Specifications Section -->
            <div x-data="{ open: true }" class="rounded-2xl border border-slate-200 dark:border-slate-800">
                <button type="button" @click="open = !open" class="flex w-full items-center justify-between p-4 hover:bg-slate-50 dark:hover:bg-slate-800/50">
                    <h3 class="text-sm font-semibold text-slate-900 dark:text-white">{{ __('Specifications') }}</h3>
                    <svg :class="{ 'rotate-180': open }" class="h-5 w-5 transition-transform text-slate-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 14l-7 7m0 0l-7-7m7 7V3" />
                    </svg>
                </button>
                <div x-show="open" class="space-y-4 border-t border-slate-200 bg-slate-50 p-4 dark:border-slate-800 dark:bg-slate-900/50">
                    <div class="grid gap-4 sm:grid-cols-2">
                        <div>
                            <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="tag">{{ __('Tag') }}</label>
                            <select id="tag" name="tag" class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                                <option value="">{{ __('No tag') }}</option>
                                @foreach (\App\Models\Product::TAGS as $tag)
                                    <option value="{{ $tag }}">{{ \Illuminate\Support\Str::title(str_replace('_', ' ', strtolower($tag))) }}</option>
                                @endforeach
                            </select>
                        </div>
                        <div>
                            <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="warranty">{{ __('Warranty') }}</label>
                            <select id="warranty" name="warranty" class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                                <option value="">{{ __('Select warranty') }}</option>
                                @foreach (\App\Models\Product::WARRANTIES as $warranty)
                                    <option value="{{ $warranty }}">{{ $warranty }}</option>
                                @endforeach
                            </select>
                        </div>
                        <div>
                            <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="discount">{{ __('Discount (%)') }}</label>
                            <input id="discount" name="discount" type="number" step="0.01" min="0" value="0" class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                        </div>
                    </div>
                </div>
            </div>

            <!-- Pricing Summary Section -->
            <div x-data="{ open: true }" class="rounded-2xl border border-slate-200 dark:border-slate-800">
                <button type="button" @click="open = !open" class="flex w-full items-center justify-between p-4 hover:bg-slate-50 dark:hover:bg-slate-800/50">
                    <h3 class="text-sm font-semibold text-slate-900 dark:text-white">{{ __('Pricing Summary') }}</h3>
                    <svg :class="{ 'rotate-180': open }" class="h-5 w-5 transition-transform text-slate-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 14l-7 7m0 0l-7-7m7 7V3" />
                    </svg>
                </button>
                <div x-show="open" class="space-y-4 border-t border-slate-200 bg-slate-50 p-4 dark:border-slate-800 dark:bg-slate-900/50">
                    <div class="grid gap-4 sm:grid-cols-2">
                        <div>
                            <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="price">{{ __('Price (From Variants)') }}</label>
                            <input id="price" name="price" type="number" step="0.01" min="0" value="0" readonly class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-100 px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                        </div>
                        <div>
                            <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="stock">{{ __('Total Stock') }}</label>
                            <input id="stock" name="stock" type="number" min="0" value="0" readonly class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-100 px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                        </div>
                    </div>
                </div>
            </div>

            <!-- Product Variants Section -->
            <div class="rounded-2xl border border-slate-200 dark:border-slate-800">
                <div class="p-4">
                    <h3 class="text-sm font-semibold text-slate-900 dark:text-white">{{ __('Product Variants') }}</h3>
                    <p id="variant-section-hint" class="text-xs text-slate-500 mt-1">{{ __('Add one or more variants with pricing and stock.') }}</p>
                </div>

                <!-- Variant Input Form -->
                <div class="border-t border-slate-200 bg-slate-50 p-4 dark:border-slate-800 dark:bg-slate-900/50">
                    <div class="grid gap-3 sm:grid-cols-2">
                        <div data-variant-field="display">
                            <label class="text-xs font-semibold text-slate-600 dark:text-slate-300" for="variant-display" id="variant-label-display">{{ __('Display') }}</label>
                            <select id="variant-display" class="mt-1 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200"></select>
                        </div>
                        <div data-variant-field="cpu">
                            <label class="text-xs font-semibold text-slate-600 dark:text-slate-300" for="variant-cpu" id="variant-label-cpu">{{ __('CPU') }}</label>
                            <select id="variant-cpu" class="mt-1 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200"></select>
                        </div>
                        <div data-variant-field="storage">
                            <label class="text-xs font-semibold text-slate-600 dark:text-slate-300" for="variant-storage" id="variant-label-storage">{{ __('Storage') }}</label>
                            <select id="variant-storage" class="mt-1 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200"></select>
                        </div>
                        <div data-variant-field="ram">
                            <label class="text-xs font-semibold text-slate-600 dark:text-slate-300" for="variant-ram" id="variant-label-ram">{{ __('RAM') }}</label>
                            <select id="variant-ram" class="mt-1 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200"></select>
                        </div>
                        <div data-variant-field="ssd">
                            <label class="text-xs font-semibold text-slate-600 dark:text-slate-300" for="variant-ssd" id="variant-label-ssd">{{ __('SSD') }}</label>
                            <select id="variant-ssd" class="mt-1 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200"></select>
                        </div>
                        <div data-variant-field="color">
                            <label class="text-xs font-semibold text-slate-600 dark:text-slate-300" for="variant-color" id="variant-label-color">{{ __('Color') }}</label>
                            <select id="variant-color" class="mt-1 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200"></select>
                        </div>
                        <div data-variant-field="condition">
                            <label class="text-xs font-semibold text-slate-600 dark:text-slate-300" for="variant-condition" id="variant-label-condition">{{ __('Condition') }}</label>
                            <select id="variant-condition" class="mt-1 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200"></select>
                        </div>
                        <div data-variant-field="country">
                            <label class="text-xs font-semibold text-slate-600 dark:text-slate-300" for="variant-country" id="variant-label-country">{{ __('Country') }}</label>
                            <select id="variant-country" class="mt-1 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200"></select>
                        </div>
                        <div>
                            <label class="text-xs font-semibold text-slate-600 dark:text-slate-300" for="variant-price">{{ __('Price') }} *</label>
                            <input id="variant-price" type="number" step="0.01" min="0" placeholder="1230" class="mt-1 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                        </div>
                        <div>
                            <label class="text-xs font-semibold text-slate-600 dark:text-slate-300" for="variant-stock">{{ __('Stock') }} *</label>
                            <input id="variant-stock" type="number" min="0" placeholder="10" class="mt-1 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                        </div>
                        <div>
                            <label class="text-xs font-semibold text-slate-600 dark:text-slate-300" for="variant-sku">{{ __('SKU') }}</label>
                            <input id="variant-sku" type="text" placeholder="IP17PM-256-BLK" class="mt-1 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                        </div>
                        <div>
                            <label class="text-xs font-semibold text-slate-600 dark:text-slate-300" for="variant-image">{{ __('Variant Image') }}</label>
                            <input id="variant-image" type="file" accept="image/*" class="mt-1 w-full text-xs text-slate-500" />
                        </div>
                    </div>

                    <div class="mt-4 flex items-center gap-2">
                        <button id="variant-add-btn" type="button" class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white hover:bg-primary-700">{{ __('Add Variant') }}</button>
                        <button id="variant-clear-btn" type="button" class="inline-flex h-10 items-center rounded-xl border border-slate-200 px-4 text-sm font-semibold text-slate-600 hover:bg-slate-100 dark:border-slate-700 dark:text-slate-300">{{ __('Clear') }}</button>
                        <p id="variant-form-error" class="ml-auto text-xs text-danger-600"></p>
                    </div>
                </div>

                <!-- Variants Table -->
                <div class="border-t border-slate-200 overflow-x-auto dark:border-slate-800">
                    <table class="w-full text-left text-sm">
                        <thead class="bg-slate-100 text-xs uppercase tracking-wider text-slate-600 dark:bg-slate-800 dark:text-slate-300">
                            <tr id="variant-table-head"></tr>
                        </thead>
                        <tbody id="variant-table-body" class="divide-y divide-slate-200 dark:divide-slate-800"></tbody>
                    </table>
                </div>
            </div>

            <div class="flex items-center gap-3 border-t border-slate-200 pt-4 dark:border-slate-800">
                <button class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-6 text-sm font-semibold text-white shadow-sm hover:bg-primary-700">{{ __('Save Product') }}</button>
                <a href="{{ route('admin.products.index') }}" class="text-sm font-semibold text-slate-500 hover:text-slate-700">{{ __('Cancel') }}</a>
            </div>
            <p id="product-form-error" class="text-sm text-danger-600"></p>
        </form>

        <div class="space-y-6">
            <!-- Image Upload Card -->
            <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900" x-data="{ preview: null }">
                <h3 class="text-sm font-semibold text-slate-900 dark:text-white">{{ __('Product Images') }}</h3>
                <p class="mt-1 text-xs text-slate-500">{{ __('Upload thumbnail and gallery images.') }}</p>
                <div class="mt-4 flex h-40 items-center justify-center rounded-xl border border-dashed border-slate-300 bg-slate-50 text-xs text-slate-500 dark:border-slate-700 dark:bg-slate-900/60">
                    <template x-if="preview">
                        <img :src="preview" alt="Preview" class="h-32 w-32 rounded-xl object-cover" />
                    </template>
                    <template x-if="!preview">
                        <div class="text-center">
                            <p class="font-semibold">{{ __('Drop image here') }}</p>
                            <p class="text-xs">{{ __('PNG, JPG up to 5MB') }}</p>
                        </div>
                    </template>
                </div>
                <input type="file" name="thumbnail" form="product-create-form" class="mt-4 w-full text-sm text-slate-500" @change="const file = $event.target.files[0]; if (file) { const reader = new FileReader(); reader.onload = e => preview = e.target.result; reader.readAsDataURL(file); }" />
                <label class="mt-4 block text-xs font-semibold text-slate-600 dark:text-slate-300">{{ __('Gallery Images') }}</label>
                <div id="gallery-preview" class="mt-2 grid grid-cols-3 gap-2 text-xs text-slate-500"></div>
                <input type="file" name="image_gallery[]" form="product-create-form" multiple class="mt-2 w-full text-sm text-slate-500" />
            </div>

            <!-- Variant Summary Card -->
            <div class="rounded-2xl border border-primary-200 bg-primary-50 p-4 dark:border-primary-500/40 dark:bg-primary-500/10">
                <div class="flex items-start justify-between gap-3">
                    <div>
                        <h3 class="text-sm font-semibold text-primary-900 dark:text-primary-100">{{ __('Variants Added') }}</h3>
                        <p class="mt-1 text-xs text-primary-700 dark:text-primary-200">{{ __('Total count of variants for this product.') }}</p>
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

            // Preset model names per product type. "Custom…" reveals a free-text input.
            const NAME_PRESETS = {
                mobile: [
                    'iPhone 12', 'iPhone 12 mini', 'iPhone 12 Pro', 'iPhone 12 Pro Max',
                    'iPhone 13', 'iPhone 13 mini', 'iPhone 13 Pro', 'iPhone 13 Pro Max',
                    'iPhone 14', 'iPhone 14 Plus', 'iPhone 14 Pro', 'iPhone 14 Pro Max',
                    'iPhone 15', 'iPhone 15 Plus', 'iPhone 15 Pro', 'iPhone 15 Pro Max',
                    'iPhone 16', 'iPhone 16e', 'iPhone 16 Plus', 'iPhone 16 Pro', 'iPhone 16 Pro Max',
                    'iPhone 17', 'iPhone Air', 'iPhone 17 Pro', 'iPhone 17 Pro Max',
                ],
                mac: [
                    'MacBook Air 13" (M1)',
                    'MacBook Air 13" (M2)', 'MacBook Air 15" (M2)',
                    'MacBook Air 13" (M3)', 'MacBook Air 15" (M3)',
                    'MacBook Air 13" (M4)', 'MacBook Air 15" (M4)',
                    'MacBook Pro 13" (M1)', 'MacBook Pro 13" (M2)',
                    'MacBook Pro 14" (M1 Pro)', 'MacBook Pro 14" (M1 Max)',
                    'MacBook Pro 16" (M1 Pro)', 'MacBook Pro 16" (M1 Max)',
                    'MacBook Pro 14" (M2 Pro)', 'MacBook Pro 14" (M2 Max)',
                    'MacBook Pro 16" (M2 Pro)', 'MacBook Pro 16" (M2 Max)',
                    'MacBook Pro 14" (M3)', 'MacBook Pro 14" (M3 Pro)', 'MacBook Pro 14" (M3 Max)',
                    'MacBook Pro 16" (M3 Pro)', 'MacBook Pro 16" (M3 Max)',
                    'MacBook Pro 14" (M4)', 'MacBook Pro 14" (M4 Pro)', 'MacBook Pro 14" (M4 Max)',
                    'MacBook Pro 16" (M4 Pro)', 'MacBook Pro 16" (M4 Max)',
                    'MacBook Pro 14" (M5)', 'MacBook Pro 14" (M5 Pro)', 'MacBook Pro 14" (M5 Max)',
                    'MacBook Pro 16" (M5 Pro)', 'MacBook Pro 16" (M5 Max)',
                ],
                accessory: [],
            };

            // Variant attribute fields shown per product type.
            // key = form field id suffix, payloadKey = API field, masterType = product master attribute type.
            const VARIANT_FIELDS = {
                display: { payloadKey: 'display',          masterType: 'display',          label: @json(__('Display')),   placeholder: @json(__('Select display')) },
                cpu:     { payloadKey: 'cpu',              masterType: 'cpu',              label: @json(__('CPU')),       placeholder: @json(__('Select CPU')) },
                storage: { payloadKey: 'storage_capacity', masterType: 'storage_capacity', label: @json(__('Storage')),   placeholder: @json(__('Select storage')) },
                ram:     { payloadKey: 'ram',              masterType: 'ram',              label: @json(__('RAM')),       placeholder: @json(__('Select RAM')) },
                ssd:     { payloadKey: 'ssd',              masterType: 'ssd',              label: @json(__('SSD')),       placeholder: @json(__('Select SSD')) },
                color:   { payloadKey: 'color',            masterType: 'color',            label: @json(__('Color')),     placeholder: @json(__('Select color')) },
                condition: { payloadKey: 'condition',      masterType: 'condition',        label: @json(__('Condition')), placeholder: @json(__('Select condition')) },
                country: { payloadKey: 'country',          masterType: 'country',          label: @json(__('Country')),   placeholder: @json(__('Select country')) },
            };

            const TYPE_CONFIG = {
                mobile: {
                    fields: ['storage', 'color', 'condition', 'country'],
                    required: ['storage', 'color', 'condition'],
                    labels: {},
                    brandPreset: true,
                    hint: {!! json_encode(__('Mobile variants: storage, color, condition, country, price, SKU and stock.')) !!},
                },
                mac: {
                    fields: ['display', 'cpu', 'storage', 'ram', 'ssd', 'color', 'condition', 'country'],
                    required: ['storage', 'color', 'condition'],
                    labels: { storage: @json(__('Capacity')), ssd: @json(__('Storage (SSD)')) },
                    brandPreset: true,
                    hint: {!! json_encode(__('Mac variants: display, CPU, capacity, RAM, storage, color, condition and country — options come from Product Master.')) !!},
                },
                accessory: {
                    fields: ['color'],
                    required: [],
                    labels: {},
                    brandPreset: false,
                    hint: {!! json_encode(__('Accessory variants: color (optional), price, SKU and stock.')) !!},
                },
            };

            const nameSelect = document.getElementById('name-select');
            const nameInput = document.getElementById('name');
            const brandSelect = document.getElementById('brand-select');
            const brandInput = document.getElementById('brand');
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

            const CUSTOM_NAME = '__custom__';
            let masterOptions = {};

            function currentType() {
                const checked = document.querySelector('input[name="product_type"]:checked');
                return checked ? checked.value : 'mobile';
            }

            function currentConfig() {
                return TYPE_CONFIG[currentType()] || TYPE_CONFIG.mobile;
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

            // ── Product name control ─────────────────────────────────────
            function applyNameControl() {
                const type = currentType();
                const presets = NAME_PRESETS[type] || [];

                if (!presets.length) {
                    nameSelect.classList.add('hidden');
                    nameInput.classList.remove('hidden');
                    return;
                }

                const keepValue = cleanText(nameInput.value);
                nameSelect.innerHTML = '<option value="">' + @json(__('Select model')) + '</option>'
                    + presets.map((model) => '<option value="' + escapeHtml(model) + '">' + escapeHtml(model) + '</option>').join('')
                    + '<option value="' + CUSTOM_NAME + '">' + @json(__('Custom name…')) + '</option>';
                nameSelect.classList.remove('hidden');

                if (keepValue && presets.indexOf(keepValue) !== -1) {
                    nameSelect.value = keepValue;
                    nameInput.classList.add('hidden');
                } else if (keepValue) {
                    nameSelect.value = CUSTOM_NAME;
                    nameInput.classList.remove('hidden');
                } else {
                    nameSelect.value = '';
                    nameInput.classList.add('hidden');
                }
            }

            nameSelect.addEventListener('change', function () {
                if (nameSelect.value === CUSTOM_NAME) {
                    nameInput.value = '';
                    nameInput.classList.remove('hidden');
                    nameInput.focus();
                    return;
                }
                nameInput.value = nameSelect.value;
                nameInput.classList.add('hidden');
            });

            // ── Brand control ────────────────────────────────────────────
            function applyBrandControl() {
                if (currentConfig().brandPreset) {
                    const current = cleanText(brandInput.value);
                    brandSelect.value = current === 'Samsung' ? 'Samsung' : 'Apple';
                    brandInput.value = brandSelect.value;
                    brandSelect.classList.remove('hidden');
                    brandInput.classList.add('hidden');
                } else {
                    brandSelect.classList.add('hidden');
                    brandInput.classList.remove('hidden');
                }
            }

            brandSelect.addEventListener('change', function () {
                brandInput.value = brandSelect.value;
            });

            // ── Variant field visibility / labels / table ────────────────
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
                cells.push('<th class="px-3 py-2">' + @json(__('Price')) + '</th>');
                cells.push('<th class="px-3 py-2">' + @json(__('Stock')) + '</th>');
                cells.push('<th class="px-3 py-2">' + @json(__('SKU')) + '</th>');
                cells.push('<th class="px-3 py-2">' + @json(__('Image')) + '</th>');
                cells.push('<th class="px-3 py-2 text-right">' + @json(__('Action')) + '</th>');
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
                variantAddBtn.textContent = @json(__('Add Variant'));
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
                    variantRows.innerHTML = '<tr><td colspan="' + columnCount + '" class="px-3 py-4 text-center text-xs text-slate-500">' + @json(__('No variants added yet.')) + '</td></tr>';
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
                        + '<button type="button" data-action="edit" data-index="' + index + '" class="text-xs font-semibold text-primary-600">' + @json(__('Edit')) + '</button>'
                        + '<button type="button" data-action="delete" data-index="' + index + '" class="ml-3 text-xs font-semibold text-danger-600">' + @json(__('Delete')) + '</button>'
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
                    return { error: names.join(', ') + ' ' + (missing.length === 1 ? @json(__('is required.')) : @json(__('are required.'))) };
                }

                if (!Number.isFinite(payload.price) || payload.price < 0) {
                    return { error: @json(__('Price must be 0 or higher.')) };
                }
                if (!Number.isInteger(payload.stock) || payload.stock < 0) {
                    return { error: @json(__('Stock must be 0 or higher.')) };
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
                variantAddBtn.textContent = @json(__('Update Variant'));
            }

            function addOrUpdateVariant() {
                const result = readVariantInput();
                if (result.error) {
                    variantFormError.textContent = result.error;
                    return;
                }

                const payload = result.value;
                const duplicate = variants.some(function (item, index) {
                    if (editIndex !== null && editIndex === index) {
                        return false;
                    }
                    return variantKey(item) === variantKey(payload);
                });

                if (duplicate) {
                    variantFormError.textContent = @json(__('This variant combination already exists.'));
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

            // ── Product type switching ───────────────────────────────────
            document.getElementById('product-type-group').addEventListener('change', function (event) {
                if (event.target.name !== 'product_type') {
                    return;
                }
                if (variants.length) {
                    variants.length = 0;
                }
                resetVariantForm();
                applyNameControl();
                applyBrandControl();
                applyVariantFields();
                renderVariantRows();
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

                if (!cleanText(nameInput.value)) {
                    errorBox.textContent = @json(__('Please select or enter a product name.'));
                    return;
                }

                if (!variants.length) {
                    errorBox.textContent = @json(__('Please add at least one variant.'));
                    return;
                }

                const formData = new FormData(event.target);
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

            // window.adminApi is defined by the layout after @yield('content'),
            // so wait for DOMContentLoaded before making API calls.
            document.addEventListener('DOMContentLoaded', function () {
                loadCategories();
                loadAttributeOptions();
            });

            applyNameControl();
            applyBrandControl();
            applyVariantFields();
            renderVariantRows();
        })();
    </script>
@endsection
