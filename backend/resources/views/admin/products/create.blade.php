@extends('layouts.admin')

@section('title', __('Create Product'))
@section('page-title', __('Create Product'))

@section('content')
    @php
        $productTypes = $productTypes ?? collect();
        $productTypeFieldDefinitions = \App\Models\ProductType::fieldDefinitions();
        $productTypeFieldLabels = collect($productTypeFieldDefinitions)
            ->mapWithKeys(fn ($field, $key) => [$key => $field['label']])
            ->all();
        $selectedProductType = old('product_type', $productTypes->first()?->slug ?? 'mobile');
        $productTypePayload = $productTypes
            ->map(fn ($type) => [
                'id' => $type->id,
                'name' => $type->name,
                'slug' => $type->slug,
                'fields' => $type->fields,
                'required_fields' => $type->required_fields,
                'sort_order' => $type->sort_order,
            ])
            ->values();
    @endphp

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
                <div class="flex items-center justify-between gap-3">
                    <h3 class="text-sm font-semibold text-slate-900 dark:text-white">{{ __('Product Type') }} *</h3>
                    @if (auth()->user()?->hasPermission('create_product_master'))
                        <button id="product-type-add-btn" type="button"
                                class="inline-flex h-8 items-center gap-1 rounded-lg border border-primary-200 bg-primary-50 px-3 text-xs font-semibold text-primary-700 transition-colors hover:bg-primary-100 dark:border-primary-500/30 dark:bg-primary-500/10 dark:text-primary-300 dark:hover:bg-primary-500/20">
                            + {{ __('Add Type') }}
                        </button>
                    @endif
                </div>
                <div id="product-type-group" class="mt-3 grid auto-rows-fr gap-3 sm:grid-cols-3">
                    @forelse ($productTypes as $productType)
                        @php
                            $fieldsText = collect($productType->fields ?? [])
                                ->map(fn ($field) => __($productTypeFieldLabels[$field] ?? $field))
                                ->join(', ');
                        @endphp
                        <label class="product-type-card flex h-full min-h-[66px] cursor-pointer items-center gap-3 rounded-xl border border-slate-200 bg-white p-3 transition-colors hover:border-primary-400 dark:border-slate-700 dark:bg-slate-900/60">
                            <input type="radio" name="product_type" value="{{ $productType->slug }}" {{ $selectedProductType === $productType->slug ? 'checked' : '' }} class="h-4 w-4 text-primary-600 focus:ring-primary-500" />
                            <span>
                                <span class="block text-sm font-semibold text-slate-900 dark:text-white">{{ $productType->name }}</span>
                                <span class="block text-xs text-slate-500">{{ $fieldsText !== '' ? $fieldsText : __('No variant fields') }}</span>
                            </span>
                        </label>
                    @empty
                        <label class="product-type-card flex h-full min-h-[66px] cursor-pointer items-center gap-3 rounded-xl border border-slate-200 bg-white p-3 transition-colors hover:border-primary-400 dark:border-slate-700 dark:bg-slate-900/60">
                            <input type="radio" name="product_type" value="mobile" checked class="h-4 w-4 text-primary-600 focus:ring-primary-500" />
                            <span>
                                <span class="block text-sm font-semibold text-slate-900 dark:text-white">{{ __('Mobile') }}</span>
                                <span class="block text-xs text-slate-500">{{ __('Storage, Color, Condition') }}</span>
                            </span>
                        </label>
                    @endforelse
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
                        <div class="relative">
                            <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="name">{{ __('Product Name') }} *</label>
                            <input id="name" name="name" type="text" autocomplete="off" placeholder="{{ __('Type or select a model') }}" class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                            <div id="name-suggestions" class="absolute inset-x-0 top-full z-20 mt-1 hidden max-h-56 overflow-y-auto rounded-xl border border-slate-200 bg-white py-1 shadow-lg dark:border-slate-700 dark:bg-slate-900"></div>
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
                            <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="sku-preview">{{ __('SKU') }}</label>
                            <input id="sku-preview" type="text" value="" placeholder="{{ __('Auto-generated on save') }}" readonly class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-100 px-3 py-2 font-mono text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
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
                        <div class="flex items-center justify-between gap-2">
                            <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="description">{{ __('Description') }}</label>
                            <button id="ai-generate-description-btn" type="button" class="inline-flex items-center gap-1.5 rounded-lg border border-primary-200 bg-primary-50 px-2.5 py-1 text-xs font-semibold text-primary-700 hover:bg-primary-100 disabled:cursor-not-allowed disabled:opacity-60 dark:border-primary-500/40 dark:bg-primary-500/10 dark:text-primary-200">
                                <svg id="ai-generate-spinner" class="hidden h-3.5 w-3.5 animate-spin" fill="none" viewBox="0 0 24 24">
                                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                                    <path class="opacity-80" fill="currentColor" d="M4 12a8 8 0 018-8v8z"></path>
                                </svg>
                                <span>{{ __('✨ Generate from AI') }}</span>
                            </button>
                        </div>
                        <textarea id="description" name="description" rows="4" class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200"></textarea>
                        <p id="ai-generate-error" class="mt-1 text-xs text-danger-600"></p>
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
                        <div data-variant-field="color" class="relative">
                            <label class="text-xs font-semibold text-slate-600 dark:text-slate-300" id="variant-label-color">{{ __('Color') }}</label>
                            <button type="button" id="variant-color-trigger" class="mt-1 flex w-full items-center justify-between gap-2 rounded-xl border border-slate-200 bg-white px-3 py-2 text-left text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                                <span id="variant-color-summary" class="truncate text-slate-400">{{ __('Select one or more colors') }}</span>
                                <svg class="h-4 w-4 flex-shrink-0 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                                </svg>
                            </button>
                            <div id="variant-color-dropdown" class="absolute inset-x-0 top-full z-20 mt-1 hidden max-h-56 overflow-y-auto rounded-xl border border-slate-200 bg-white p-2 shadow-lg dark:border-slate-700 dark:bg-slate-900"></div>
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
                            <input id="variant-sku" type="text" placeholder="{{ __('Auto-generated') }}" class="mt-1 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 font-mono text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
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
                <button id="product-save-btn" type="submit" class="inline-flex h-10 items-center gap-2 rounded-xl bg-primary-600 px-6 text-sm font-semibold text-white shadow-sm hover:bg-primary-700 disabled:cursor-not-allowed disabled:opacity-70">
                    <svg id="product-save-spinner" class="hidden h-4 w-4 animate-spin" fill="none" viewBox="0 0 24 24">
                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                        <path class="opacity-80" fill="currentColor" d="M4 12a8 8 0 018-8v8z"></path>
                    </svg>
                    <span id="product-save-label">{{ __('Save Product') }}</span>
                </button>
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

    {{-- Full-screen saving overlay --}}
    <div id="product-save-overlay" class="fixed inset-0 z-50 hidden items-center justify-center bg-white/60 backdrop-blur-sm dark:bg-slate-950/60">
        <div class="flex flex-col items-center gap-3">
            <svg class="h-10 w-10 animate-spin text-primary-600" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-80" fill="currentColor" d="M4 12a8 8 0 018-8v8z"></path>
            </svg>
            <p class="text-sm font-semibold text-slate-700 dark:text-slate-200">{{ __('Saving product…') }}</p>
        </div>
    </div>

    {{-- Add Product Type modal --}}
    <div id="product-type-modal" class="fixed inset-0 z-50 hidden items-center justify-center bg-black/40 px-4">
        <div class="w-full max-w-2xl rounded-2xl bg-white p-6 shadow-xl dark:bg-slate-900">
            <div class="flex items-center justify-between">
                <h3 class="text-lg font-semibold text-slate-900 dark:text-white">{{ __('Add Product Type') }}</h3>
                <button id="product-type-modal-close" type="button" class="rounded-lg p-1 text-slate-400 hover:text-slate-600 dark:hover:text-slate-200">
                    <svg class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                </button>
            </div>
            <form id="product-type-form" class="mt-4 space-y-4">
                <div class="grid gap-4 sm:grid-cols-[1fr_180px]">
                    <div>
                        <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="product-type-name">{{ __('Name') }}</label>
                        <input id="product-type-name" type="text" placeholder="{{ __('e.g. Tablet') }}"
                               class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    </div>
                    <div>
                        <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="product-type-sort-order">{{ __('Sort') }}</label>
                        <input id="product-type-sort-order" type="number" min="0" value="0"
                               class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    </div>
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="product-type-slug">{{ __('Slug') }}</label>
                    <input id="product-type-slug" type="text" placeholder="{{ __('tablet') }}"
                           class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 font-mono text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    <p class="mt-1 text-xs text-slate-500">{{ __('Used internally for saved products. It cannot be changed after creation.') }}</p>
                </div>
                <div>
                    <div class="grid gap-3 rounded-xl border border-slate-200 bg-slate-50 p-3 dark:border-slate-800 dark:bg-slate-950/40">
                        <div class="grid grid-cols-[1fr_88px_88px] gap-3 px-2 text-xs font-semibold uppercase tracking-wider text-slate-400">
                            <span>{{ __('Field') }}</span>
                            <span class="text-center">{{ __('Show') }}</span>
                            <span class="text-center">{{ __('Required') }}</span>
                        </div>
                        @foreach ($productTypeFieldDefinitions as $fieldKey => $field)
                            @php $isDefault = in_array($fieldKey, ['storage', 'color', 'condition'], true); @endphp
                            <div class="grid grid-cols-[1fr_88px_88px] items-center gap-3 rounded-lg bg-white px-3 py-2 dark:bg-slate-900">
                                <div>
                                    <p class="text-sm font-semibold text-slate-800 dark:text-slate-100">{{ __($field['label']) }}</p>
                                    <p class="text-xs text-slate-500">{{ $field['payload_key'] }}</p>
                                </div>
                                <label class="flex justify-center">
                                    <input type="checkbox" data-product-type-field value="{{ $fieldKey }}" class="h-4 w-4 rounded border-slate-300 text-primary-600 focus:ring-primary-500" {{ $isDefault ? 'checked' : '' }} />
                                </label>
                                <label class="flex justify-center">
                                    <input type="checkbox" data-product-type-required value="{{ $fieldKey }}" class="h-4 w-4 rounded border-slate-300 text-primary-600 focus:ring-primary-500 disabled:opacity-40" {{ $isDefault ? 'checked' : 'disabled' }} />
                                </label>
                            </div>
                        @endforeach
                    </div>
                    <p id="product-type-fields-error" class="mt-2 text-xs text-danger-600"></p>
                </div>
                <p id="product-type-form-error" class="text-xs text-danger-600"></p>
                <div class="flex items-center justify-end gap-3 pt-1">
                    <button id="product-type-cancel" type="button" class="h-10 rounded-xl border border-slate-200 px-4 text-sm font-semibold text-slate-600 hover:bg-slate-50 dark:border-slate-700 dark:text-slate-200 dark:hover:bg-slate-800">{{ __('Cancel') }}</button>
                    <button id="product-type-submit" type="submit" class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white shadow-sm hover:bg-primary-700 transition-colors">{{ __('Save') }}</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        (function () {
            const variants = [];
            let editIndex = null;
            const INITIAL_PRODUCT_TYPES = {!! \Illuminate\Support\Js::from($productTypePayload) !!};

            // Suggested model names per product type, shown as datalist options for the name input.
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

            const FALLBACK_PRODUCT_TYPES = [
                {
                    name: @json(__('Mobile')),
                    slug: 'mobile',
                    fields: ['storage', 'color', 'condition', 'country'],
                    required_fields: ['storage', 'color', 'condition'],
                    sort_order: 10,
                },
                {
                    name: @json(__('Mac')),
                    slug: 'mac',
                    fields: ['display', 'cpu', 'storage', 'ram', 'ssd', 'color', 'condition', 'country'],
                    required_fields: ['storage', 'color', 'condition'],
                    sort_order: 20,
                },
                {
                    name: @json(__('Accessory')),
                    slug: 'accessory',
                    fields: ['color'],
                    required_fields: [],
                    sort_order: 30,
                },
            ];

            const FALLBACK_TYPE_CONFIG = {
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
            let productTypeList = [];
            let TYPE_CONFIG = Object.assign({}, FALLBACK_TYPE_CONFIG);

            const nameSuggestions = document.getElementById('name-suggestions');
            const nameInput = document.getElementById('name');
            const brandSelect = document.getElementById('brand-select');
            const brandInput = document.getElementById('brand');
            const skuPreviewInput = document.getElementById('sku-preview');
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
            const descriptionField = document.getElementById('description');
            const aiGenerateBtn = document.getElementById('ai-generate-description-btn');
            const aiGenerateSpinner = document.getElementById('ai-generate-spinner');
            const aiGenerateError = document.getElementById('ai-generate-error');
            const categorySelect = document.getElementById('category');
            const tagSelect = document.getElementById('tag');
            const productTypeGroup = document.getElementById('product-type-group');
            const variantColorTrigger = document.getElementById('variant-color-trigger');
            const variantColorDropdown = document.getElementById('variant-color-dropdown');
            const variantColorSummary = document.getElementById('variant-color-summary');

            let masterOptions = {};
            let selectedColors = [];
            let skuPreviewTimer = null;
            let skuPreviewRequestId = 0;

            function currentType() {
                const checked = document.querySelector('input[name="product_type"]:checked');
                return checked ? checked.value : 'mobile';
            }

            function currentConfig() {
                return TYPE_CONFIG[currentType()] || TYPE_CONFIG.mobile || Object.values(TYPE_CONFIG)[0];
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

            function normalizeTypeFields(fields) {
                const allowed = Object.keys(VARIANT_FIELDS);
                const list = Array.isArray(fields) ? fields : [];
                return list.filter(function (field, index) {
                    return allowed.indexOf(field) !== -1 && list.indexOf(field) === index;
                });
            }

            function variantFieldLabel(key, config) {
                return (config && config.labels && config.labels[key]) || VARIANT_FIELDS[key]?.label || key;
            }

            function configFromProductType(type) {
                const fields = normalizeTypeFields(type.fields);
                const required = normalizeTypeFields(type.required_fields).filter(function (field) {
                    return fields.indexOf(field) !== -1;
                });
                const fallback = FALLBACK_TYPE_CONFIG[type.slug] || {};
                const labels = Object.assign({}, fallback.labels || {});
                const labelText = fields.map(function (field) {
                    return labels[field] || VARIANT_FIELDS[field].label;
                }).join(', ');

                return {
                    fields: fields.length ? fields : ['color'],
                    required: required,
                    labels: labels,
                    brandPreset: type.slug === 'mobile' || type.slug === 'mac',
                    hint: fallback.hint || (type.name + ' variants: ' + (labelText || 'selected fields') + ', price, SKU and stock.'),
                };
            }

            function renderProductTypeOptions(selectedSlug) {
                const selected = productTypeList.some((type) => type.slug === selectedSlug)
                    ? selectedSlug
                    : (productTypeList[0]?.slug || 'mobile');

                productTypeGroup.innerHTML = productTypeList.map(function (type) {
                    const checked = type.slug === selected ? 'checked' : '';
                    const fields = normalizeTypeFields(type.fields)
                        .map(function (field) { return VARIANT_FIELDS[field].label; })
                        .join(', ') || @json(__('No variant fields'));

                    return `
                        <label class="product-type-card flex h-full min-h-[66px] cursor-pointer items-center gap-3 rounded-xl border border-slate-200 bg-white p-3 transition-colors hover:border-primary-400 dark:border-slate-700 dark:bg-slate-900/60">
                            <input type="radio" name="product_type" value="${escapeHtml(type.slug)}" ${checked} class="h-4 w-4 text-primary-600 focus:ring-primary-500" />
                            <span>
                                <span class="block text-sm font-semibold text-slate-900 dark:text-white">${escapeHtml(type.name)}</span>
                                <span class="block text-xs text-slate-500">${escapeHtml(fields)}</span>
                            </span>
                        </label>
                    `;
                }).join('');
            }

            function applyProductTypes(list, selectedSlug) {
                const source = Array.isArray(list) && list.length ? list : FALLBACK_PRODUCT_TYPES;
                productTypeList = source.map(function (type) {
                    return {
                        name: cleanText(type.name) || cleanText(type.slug) || 'Product Type',
                        slug: cleanText(type.slug) || 'mobile',
                        fields: normalizeTypeFields(type.fields),
                        required_fields: normalizeTypeFields(type.required_fields),
                    };
                });

                TYPE_CONFIG = {};
                productTypeList.forEach(function (type) {
                    TYPE_CONFIG[type.slug] = configFromProductType(type);
                });

                renderProductTypeOptions(selectedSlug || currentType());
                applyNameControl();
                applyBrandControl();
                applyVariantFields();
                renderVariantRows();
            }

            function skuSegment(value, maxLength = 8) {
                return cleanText(value).replace(/[^A-Za-z0-9]/g, '').toUpperCase().slice(0, maxLength);
            }

            function localProductSkuPreview() {
                const cleanName = skuSegment(nameInput.value, 255);
                if (!cleanName) {
                    return '';
                }

                let namePart = cleanName.slice(0, 2);
                while (namePart.length < 2) {
                    namePart += 'X';
                }

                const brandPart = skuSegment(brandInput.value, 255) || 'NA';

                return namePart + brandPart + '001';
            }

            function variantSkuPreview(item, index) {
                const base = skuSegment(skuPreviewInput.value || localProductSkuPreview(), 24);
                if (!base) {
                    return '';
                }

                const segments = ['display', 'cpu', 'storage_capacity', 'ram', 'ssd', 'color', 'condition', 'country']
                    .map((key) => skuSegment(item[key]))
                    .filter((value) => value !== '');

                if (!segments.length) {
                    segments.push(String(index + 1).padStart(2, '0'));
                }

                return (base + '-' + segments.join('-')).slice(0, 120).replace(/-+$/, '');
            }

            function currentVariantDraft() {
                const draft = {
                    storage_capacity: '',
                    color: '',
                    condition: '',
                    ram: '',
                    ssd: '',
                    cpu: '',
                    display: '',
                    country: '',
                };

                Object.keys(VARIANT_FIELDS).forEach(function (key) {
                    const select = fieldSelect(key);
                    if (select) {
                        draft[VARIANT_FIELDS[key].payloadKey] = cleanText(select.value);
                    }
                });
                draft.color = selectedColors[0] || '';

                return draft;
            }

            function updateVariantSkuPlaceholder() {
                variantSku.placeholder = variantSkuPreview(currentVariantDraft(), editIndex ?? variants.length) || @json(__('Auto-generated'));
            }

            async function refreshSkuPreview() {
                const name = cleanText(nameInput.value);
                const fallback = localProductSkuPreview();

                if (!name) {
                    skuPreviewInput.value = '';
                    updateVariantSkuPlaceholder();
                    renderVariantRows();
                    return;
                }

                skuPreviewInput.value = fallback;
                updateVariantSkuPlaceholder();
                renderVariantRows();

                if (!window.adminApi) {
                    return;
                }

                const requestId = ++skuPreviewRequestId;
                const params = new URLSearchParams({
                    name: name,
                    brand: cleanText(brandInput.value),
                });

                try {
                    await window.adminApi.ensureCsrfCookie();
                    const response = await window.adminApi.request('/api/products/next-sku?' + params.toString());
                    if (requestId !== skuPreviewRequestId || !response.ok) {
                        return;
                    }

                    const payload = await response.json();
                    skuPreviewInput.value = cleanText(payload.sku) || fallback;
                    updateVariantSkuPlaceholder();
                    renderVariantRows();
                } catch (e) {
                    skuPreviewInput.value = fallback;
                }
            }

            function scheduleSkuPreviewRefresh() {
                clearTimeout(skuPreviewTimer);
                skuPreviewTimer = setTimeout(refreshSkuPreview, 250);
            }

            // ── Color multi-select (checkbox dropdown) ──────────────────
            function updateColorSummary() {
                if (!variantColorSummary) return;
                if (!selectedColors.length) {
                    variantColorSummary.textContent = @json(__('Select one or more colors'));
                    variantColorSummary.classList.add('text-slate-400');
                } else {
                    variantColorSummary.textContent = selectedColors.join(', ');
                    variantColorSummary.classList.remove('text-slate-400');
                }
            }

            function renderColorOptions() {
                if (!variantColorDropdown) return;
                const options = masterOptions.color || [];
                if (!options.length) {
                    variantColorDropdown.innerHTML = '<p class="px-2 py-1.5 text-xs text-slate-400">' + @json(__('No colors available yet.')) + '</p>';
                    return;
                }
                variantColorDropdown.innerHTML = options.map(function (value) {
                    const checked = selectedColors.indexOf(value) !== -1 ? 'checked' : '';
                    const escaped = escapeHtml(value);
                    return '<label class="flex items-center gap-2 rounded-lg px-2 py-1.5 text-sm text-slate-700 hover:bg-slate-50 dark:text-slate-200 dark:hover:bg-slate-800">'
                        + '<input type="checkbox" data-color-option value="' + escaped + '" ' + checked + ' class="h-4 w-4 rounded border-slate-300 text-primary-600 focus:ring-primary-500" />'
                        + '<span>' + escaped + '</span>'
                        + '</label>';
                }).join('');
            }

            function closeColorDropdown() {
                if (variantColorDropdown) variantColorDropdown.classList.add('hidden');
            }

            if (variantColorTrigger) {
                variantColorTrigger.addEventListener('click', function (event) {
                    event.stopPropagation();
                    variantColorDropdown.classList.toggle('hidden');
                });
            }

            if (variantColorDropdown) {
                variantColorDropdown.addEventListener('change', function (event) {
                    const checkbox = event.target.closest('[data-color-option]');
                    if (!checkbox) return;
                    if (checkbox.checked) {
                        if (selectedColors.indexOf(checkbox.value) === -1) selectedColors.push(checkbox.value);
                    } else {
                        selectedColors = selectedColors.filter((value) => value !== checkbox.value);
                    }
                    updateColorSummary();
                    updateVariantSkuPlaceholder();
                });
            }

            document.addEventListener('click', function (event) {
                if (!variantColorDropdown || variantColorDropdown.classList.contains('hidden')) return;
                if (event.target.closest('#variant-color-trigger') || event.target.closest('#variant-color-dropdown')) return;
                closeColorDropdown();
            });

            function variantKey(item) {
                return currentConfig().fields
                    .map((key) => cleanText(item[VARIANT_FIELDS[key].payloadKey]).toLowerCase())
                    .join('|');
            }

            // ── Product name control ─────────────────────────────────────
            // A single text input with a styled JS dropdown: the user can type any
            // custom name freely, or click a suggestion filtered from the presets.
            let activeNamePresets = [];

            function hideNameSuggestions() {
                nameSuggestions.classList.add('hidden');
            }

            function renderNameSuggestions() {
                const query = cleanText(nameInput.value).toLowerCase();
                const matches = activeNamePresets.filter((model) => !query || model.toLowerCase().includes(query));

                if (!matches.length) {
                    nameSuggestions.innerHTML = '';
                    hideNameSuggestions();
                    return;
                }

                nameSuggestions.innerHTML = matches.map((model) =>
                    '<button type="button" data-name-option class="block w-full px-3 py-2 text-left text-sm text-slate-700 hover:bg-primary-50 dark:text-slate-200 dark:hover:bg-slate-800">' + escapeHtml(model) + '</button>'
                ).join('');
                nameSuggestions.classList.remove('hidden');
            }

            function applyNameControl() {
                const type = currentType();
                activeNamePresets = NAME_PRESETS[type] || [];
                hideNameSuggestions();
            }

            nameInput.addEventListener('input', function () {
                renderNameSuggestions();
                scheduleSkuPreviewRefresh();
            });

            nameInput.addEventListener('focus', renderNameSuggestions);

            nameInput.addEventListener('blur', function () {
                // Delay so a click on a suggestion (mousedown below) registers first.
                setTimeout(hideNameSuggestions, 100);
            });

            nameInput.addEventListener('keydown', function (event) {
                if (event.key === 'Escape') {
                    hideNameSuggestions();
                }
            });

            nameSuggestions.addEventListener('mousedown', function (event) {
                const button = event.target.closest('[data-name-option]');
                if (!button) {
                    return;
                }
                event.preventDefault();
                nameInput.value = button.textContent;
                hideNameSuggestions();
                scheduleSkuPreviewRefresh();
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
                scheduleSkuPreviewRefresh();
            });

            brandInput.addEventListener('input', scheduleSkuPreviewRefresh);

            // ── AI description generation ────────────────────────────────
            async function generateDescriptionFromAi() {
                aiGenerateError.textContent = '';
                const name = cleanText(nameInput.value);
                if (!name) {
                    aiGenerateError.textContent = @json(__('Enter a product name first.'));
                    return;
                }

                aiGenerateBtn.disabled = true;
                aiGenerateSpinner.classList.remove('hidden');

                try {
                    await window.adminApi.ensureCsrfCookie();
                    const response = await window.adminApi.request('/api/products/generate-description', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({
                            name: name,
                            brand: cleanText(brandInput.value),
                            category: categorySelect && categorySelect.selectedIndex > -1
                                ? categorySelect.options[categorySelect.selectedIndex].text
                                : '',
                            tag: tagSelect ? cleanText(tagSelect.value) : '',
                        }),
                    });

                    const payload = await response.json();

                    if (!response.ok) {
                        aiGenerateError.textContent = payload.message || @json(__('Unable to generate a description.'));
                        return;
                    }

                    descriptionField.value = payload.description || '';
                } catch (error) {
                    aiGenerateError.textContent = @json(__('Unable to generate a description.'));
                } finally {
                    aiGenerateBtn.disabled = false;
                    aiGenerateSpinner.classList.add('hidden');
                }
            }

            aiGenerateBtn.addEventListener('click', generateDescriptionFromAi);

            Object.keys(VARIANT_FIELDS).forEach(function (key) {
                const select = fieldSelect(key);
                if (select) {
                    select.addEventListener('change', updateVariantSkuPlaceholder);
                }
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
                updateVariantSkuPlaceholder();
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
                selectedColors = [];
                renderColorOptions();
                updateColorSummary();
                closeColorDropdown();
                variantSku.value = '';
                variantPrice.value = '';
                variantStock.value = '';
                variantImage.value = '';
                variantFormError.textContent = '';
                variantAddBtn.textContent = @json(__('Add Variant'));
                updateVariantSkuPlaceholder();
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
                    const shownSku = cleanText(item.sku) || variantSkuPreview(item, index);
                    const cells = config.fields.map(function (key) {
                        return '<td class="px-3 py-2">' + (escapeHtml(cleanText(item[VARIANT_FIELDS[key].payloadKey])) || '--') + '</td>';
                    });
                    cells.push('<td class="px-3 py-2">' + formatMoney(toNumber(item.price, 0)) + '</td>');
                    cells.push('<td class="px-3 py-2">' + toNumber(item.stock, 0) + '</td>');
                    cells.push('<td class="px-3 py-2 font-mono">' + (escapeHtml(shownSku) || '--') + '</td>');
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

            function readVariantInput(colorValue) {
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
                    if (key === 'color') {
                        payload.color = cleanText(colorValue);
                        return;
                    }
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
                selectedColors = cleanText(item.color) ? [cleanText(item.color)] : [];
                renderColorOptions();
                updateColorSummary();
                variantSku.value = cleanText(item.sku);
                variantPrice.value = String(item.price ?? '');
                variantStock.value = String(item.stock ?? '');
                variantImage.value = '';
                variantFormError.textContent = '';
                variantAddBtn.textContent = @json(__('Update Variant'));
            }

            function addOrUpdateVariant() {
                const config = currentConfig();
                const hasColorField = config.fields.indexOf('color') !== -1;
                const colorRequired = hasColorField && config.required.indexOf('color') !== -1;

                if (editIndex !== null) {
                    if (hasColorField && selectedColors.length > 1) {
                        variantFormError.textContent = @json(__('Select only one color when updating a variant.'));
                        return;
                    }
                    if (colorRequired && selectedColors.length === 0) {
                        variantFormError.textContent = @json(__('Color is required.'));
                        return;
                    }

                    const result = readVariantInput(selectedColors[0] || '');
                    if (result.error) {
                        variantFormError.textContent = result.error;
                        return;
                    }

                    const payload = result.value;
                    const duplicate = variants.some(function (item, index) {
                        if (index === editIndex) {
                            return false;
                        }
                        return variantKey(item) === variantKey(payload);
                    });

                    if (duplicate) {
                        variantFormError.textContent = @json(__('This variant combination already exists.'));
                        return;
                    }

                    const previous = variants[editIndex];
                    const merged = Object.assign({}, previous, payload);
                    if (!(payload.file instanceof File)) {
                        merged.file = previous.file || null;
                    }
                    if (!payload.file && !payload.image) {
                        merged.image = previous.image || null;
                    }
                    variants[editIndex] = merged;

                    resetVariantForm();
                    renderVariantRows();
                    return;
                }

                // Add mode — one variant is created per selected color, so picking
                // several colors at once lists them all below for later per-row editing.
                if (colorRequired && selectedColors.length === 0) {
                    variantFormError.textContent = @json(__('Select at least one color.'));
                    return;
                }

                const colorsToAdd = hasColorField && selectedColors.length ? selectedColors.slice() : [''];
                const bulkAdd = colorsToAdd.length > 1;
                const newPayloads = [];
                const skipped = [];
                let firstError = '';

                colorsToAdd.forEach(function (color) {
                    if (firstError) return;

                    const result = readVariantInput(color);
                    if (result.error) {
                        firstError = result.error;
                        return;
                    }

                    const payload = result.value;
                    if (bulkAdd) {
                        // A manually typed SKU can't be reused across multiple new
                        // variants, so let the backend auto-generate one per color.
                        payload.sku = '';
                    }

                    const isDuplicate = variants.some((item) => variantKey(item) === variantKey(payload))
                        || newPayloads.some((item) => variantKey(item) === variantKey(payload));

                    if (isDuplicate) {
                        skipped.push(color || @json(__('default')));
                        return;
                    }

                    newPayloads.push(payload);
                });

                if (firstError) {
                    variantFormError.textContent = firstError;
                    return;
                }

                if (!newPayloads.length) {
                    variantFormError.textContent = skipped.length
                        ? @json(__('These variant combinations already exist.'))
                        : @json(__('Unable to add variant.'));
                    return;
                }

                variants.push.apply(variants, newPayloads);

                if (skipped.length) {
                    variantFormError.textContent = @json(__('Added')) + ' ' + newPayloads.length + ' '
                        + (newPayloads.length === 1 ? @json(__('variant')) : @json(__('variants'))) + '. '
                        + @json(__('Skipped existing:')) + ' ' + skipped.join(', ');
                } else {
                    variantFormError.textContent = '';
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
                scheduleSkuPreviewRefresh();
            });

            // ── Add Product Type modal ───────────────────────────────────
            (function () {
                const addBtn = document.getElementById('product-type-add-btn');
                if (!addBtn) return;

                const modal = document.getElementById('product-type-modal');
                const modalClose = document.getElementById('product-type-modal-close');
                const cancelBtn = document.getElementById('product-type-cancel');
                const typeForm = document.getElementById('product-type-form');
                const typeNameInput = document.getElementById('product-type-name');
                const typeSlugInput = document.getElementById('product-type-slug');
                const typeSortInput = document.getElementById('product-type-sort-order');
                const typeFieldsError = document.getElementById('product-type-fields-error');
                const typeFormError = document.getElementById('product-type-form-error');
                const typeSubmitBtn = document.getElementById('product-type-submit');
                let slugTouched = false;

                function slugify(value) {
                    return String(value || '')
                        .toLowerCase()
                        .replace(/[^a-z0-9]+/g, '-')
                        .replace(/^-+|-+$/g, '')
                        .slice(0, 20);
                }

                function selectedValues(selector) {
                    return Array.from(document.querySelectorAll(selector))
                        .filter(function (input) { return input.checked && !input.disabled; })
                        .map(function (input) { return input.value; });
                }

                function syncRequiredControls() {
                    document.querySelectorAll('[data-product-type-required]').forEach(function (input) {
                        const fieldInput = document.querySelector('[data-product-type-field][value="' + input.value + '"]');
                        const enabled = Boolean(fieldInput && fieldInput.checked);
                        input.disabled = !enabled;
                        if (!enabled) input.checked = false;
                    });
                }

                document.querySelectorAll('[data-product-type-field]').forEach(function (input) {
                    input.addEventListener('change', syncRequiredControls);
                });

                function openModal() {
                    typeForm.reset();
                    typeFieldsError.textContent = '';
                    typeFormError.textContent = '';
                    slugTouched = false;
                    syncRequiredControls();
                    modal.classList.remove('hidden');
                    modal.classList.add('flex');
                    setTimeout(function () { typeNameInput.focus(); }, 0);
                }

                function closeModal() {
                    modal.classList.add('hidden');
                    modal.classList.remove('flex');
                }

                addBtn.addEventListener('click', openModal);
                modalClose.addEventListener('click', closeModal);
                cancelBtn.addEventListener('click', closeModal);
                modal.addEventListener('click', function (event) {
                    if (event.target === modal) closeModal();
                });
                document.addEventListener('keydown', function (event) {
                    if (event.key === 'Escape' && !modal.classList.contains('hidden')) closeModal();
                });

                typeNameInput.addEventListener('input', function () {
                    if (!slugTouched) typeSlugInput.value = slugify(typeNameInput.value);
                });
                typeSlugInput.addEventListener('input', function () {
                    slugTouched = true;
                    typeSlugInput.value = slugify(typeSlugInput.value);
                });

                typeForm.addEventListener('submit', async function (event) {
                    event.preventDefault();
                    typeFieldsError.textContent = '';
                    typeFormError.textContent = '';

                    const fields = selectedValues('[data-product-type-field]');
                    const requiredFields = selectedValues('[data-product-type-required]');
                    const name = (typeNameInput.value || '').trim();
                    const slug = slugify(typeSlugInput.value || name);

                    if (!name) {
                        typeFormError.textContent = @json(__('Name is required.'));
                        return;
                    }
                    if (!fields.length) {
                        typeFieldsError.textContent = @json(__('Select at least one field to show.'));
                        return;
                    }

                    typeSubmitBtn.disabled = true;
                    try {
                        await window.adminApi.ensureCsrfCookie();
                        const response = await window.adminApi.request('/api/product-types', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/json' },
                            body: JSON.stringify({
                                name: name,
                                slug: slug,
                                fields: fields,
                                required_fields: requiredFields,
                                sort_order: Number(typeSortInput.value || 0),
                            }),
                        });

                        if (!response.ok) {
                            const errorData = await response.json().catch(function () { return {}; });
                            typeFormError.textContent = errorData.message || @json(__('Unable to save product type.'));
                            window.adminToast?.(errorData.message || @json(__('Unable to save product type.')), { type: 'error' });
                            return;
                        }

                        const payload = await response.json();
                        const created = payload.data || payload;
                        const updatedList = productTypeList.concat([{
                            name: created.name,
                            slug: created.slug,
                            fields: created.fields,
                            required_fields: created.required_fields,
                        }]);
                        applyProductTypes(updatedList, created.slug);
                        closeModal();
                        window.adminToast?.(@json(__('Product type added.')));
                    } finally {
                        typeSubmitBtn.disabled = false;
                    }
                });
            })();

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

            const saveBtn = document.getElementById('product-save-btn');
            const saveSpinner = document.getElementById('product-save-spinner');
            const saveLabel = document.getElementById('product-save-label');
            const saveOverlay = document.getElementById('product-save-overlay');

            function setSaving(isSaving) {
                saveBtn.disabled = isSaving;
                saveSpinner.classList.toggle('hidden', !isSaving);
                saveLabel.textContent = isSaving ? @json(__('Saving…')) : @json(__('Save Product'));
                saveOverlay.classList.toggle('hidden', !isSaving);
                saveOverlay.classList.toggle('flex', isSaving);
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

                setSaving(true);

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
                    setSaving(false);
                } catch (error) {
                    errorBox.textContent = 'Unable to create product.';
                    if (window.adminSwalError) {
                        window.adminSwalError('Create failed', 'Unable to create product.');
                    }
                    setSaving(false);
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

                selectedColors = selectedColors.filter((value) => (masterOptions.color || []).indexOf(value) !== -1);
                renderColorOptions();
                updateColorSummary();
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

            async function loadProductTypes() {
                applyProductTypes(INITIAL_PRODUCT_TYPES, currentType());

                try {
                    await window.adminApi.ensureCsrfCookie();
                    const response = await window.adminApi.request('/api/product-types');
                    if (!response.ok) return;
                    const payload = await response.json();
                    applyProductTypes(Array.isArray(payload.data) ? payload.data : [], currentType());
                    scheduleSkuPreviewRefresh();
                } catch (e) {
                    // server-rendered product types are already active
                }
            }

            // window.adminApi is defined by the layout after @yield('content'),
            // so wait for DOMContentLoaded before making API calls.
            document.addEventListener('DOMContentLoaded', function () {
                loadCategories();
                loadAttributeOptions();
                loadProductTypes();
                scheduleSkuPreviewRefresh();
            });

            applyProductTypes(INITIAL_PRODUCT_TYPES, currentType());
        })();
    </script>
@endsection
