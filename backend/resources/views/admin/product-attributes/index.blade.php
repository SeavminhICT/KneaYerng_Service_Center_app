@extends('layouts.admin')

@section('title', __('Product Master'))
@section('page-title', __('Product Master'))

@section('content')
    @php
        $productTypeFieldDefinitions = \App\Models\ProductType::fieldDefinitions();
    @endphp

    <div class="space-y-6">
        <div class="flex flex-wrap items-center justify-between gap-4">
            <div>
                <h2 class="text-lg font-semibold text-slate-900 dark:text-white">{{ __('Product Master') }}</h2>
                <p class="text-sm text-slate-500">{{ __('Manage selectable options for products (storage, color, specs, and more).') }}</p>
            </div>
            @if (auth()->user()?->hasPermission('create_product_master'))
            <div class="flex items-center gap-3">
                <button id="master-add-btn" type="button"
                        class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white shadow-sm hover:bg-primary-700 transition-colors">
                    + {{ __('Add Option') }}
                </button>
            </div>
            @endif
        </div>

        <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <div class="flex flex-wrap items-center justify-between gap-3">
                <div>
                    <h3 class="text-base font-semibold text-slate-900 dark:text-white">{{ __('Product Types') }}</h3>
                    <p class="text-sm text-slate-500">{{ __('Create product types and choose which variant fields appear when adding products.') }}</p>
                </div>
                @if (auth()->user()?->hasPermission('create_product_master'))
                    <button id="product-type-add-btn" type="button"
                            class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white shadow-sm hover:bg-primary-700 transition-colors">
                        + {{ __('Add Product Type') }}
                    </button>
                @endif
            </div>

            <div class="mt-5 overflow-x-auto">
                <table class="w-full text-left text-sm">
                    <thead class="text-xs uppercase tracking-widest text-slate-400">
                        <tr>
                            <th class="px-4 py-3">{{ __('Type') }}</th>
                            <th class="px-4 py-3">{{ __('Visible Fields') }}</th>
                            <th class="px-4 py-3">{{ __('Required Fields') }}</th>
                            <th class="px-4 py-3 text-right">{{ __('Actions') }}</th>
                        </tr>
                    </thead>
                    <tbody id="product-type-rows" class="divide-y divide-slate-200 text-slate-600 dark:divide-slate-800 dark:text-slate-300">
                        <tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="4">{{ __('Loading...') }}</td></tr>
                    </tbody>
                </table>
            </div>

            <div class="mt-4 flex items-center justify-between text-xs text-slate-500">
                <p id="product-type-count-info"></p>
            </div>
        </div>

        <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <div class="flex flex-wrap items-center justify-between gap-3">
                <select id="master-filter" class="h-10 w-full appearance-none rounded-xl border border-slate-200 bg-slate-50 pl-3 pr-8 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 sm:w-48 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300">
                    <option value="">{{ __('All Attributes') }}</option>
                    <option value="storage_capacity">{{ __('Storage Capacity') }}</option>
                    <option value="color">{{ __('Color') }}</option>
                    <option value="condition">{{ __('Condition') }}</option>
                    <option value="ram">{{ __('RAM') }}</option>
                    <option value="ssd">{{ __('SSD') }}</option>
                    <option value="cpu">{{ __('CPU') }}</option>
                    <option value="display">{{ __('Display') }}</option>
                    <option value="country">{{ __('Country') }}</option>
                </select>
                <div class="relative">
                    <input id="master-search" type="text" placeholder="{{ __('Search values') }}"
                           class="h-10 w-60 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    <svg class="absolute right-3 top-3 h-4 w-4 text-slate-400" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-4.35-4.35m1.6-5.15a7 7 0 11-14 0 7 7 0 0114 0z" />
                    </svg>
                </div>
            </div>

            <div class="mt-5 overflow-x-auto">
                <table class="w-full text-left text-sm">
                    <thead class="text-xs uppercase tracking-widest text-slate-400">
                        <tr>
                            <th class="px-4 py-3">{{ __('Value') }}</th>
                            <th class="px-4 py-3">{{ __('Attribute') }}</th>
                            <th class="px-4 py-3 text-right">{{ __('Actions') }}</th>
                        </tr>
                    </thead>
                    <tbody id="master-rows" class="divide-y divide-slate-200 text-slate-600 dark:divide-slate-800 dark:text-slate-300">
                        <tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="3">{{ __('Loading...') }}</td></tr>
                    </tbody>
                </table>
            </div>

            <div class="mt-4 flex items-center justify-between text-xs text-slate-500">
                <p id="master-count-info"></p>
            </div>
        </div>
    </div>

    {{-- Add / Edit product type modal --}}
    <div id="product-type-modal" class="fixed inset-0 z-50 hidden items-center justify-center bg-black/40 px-4">
        <div class="w-full max-w-2xl rounded-2xl bg-white p-6 shadow-xl dark:bg-slate-900">
            <div class="flex items-center justify-between">
                <h3 id="product-type-modal-title" class="text-lg font-semibold text-slate-900 dark:text-white">{{ __('Add Product Type') }}</h3>
                <button id="product-type-modal-close" type="button" class="rounded-lg p-1 text-slate-400 hover:text-slate-600 dark:hover:text-slate-200">
                    <svg class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                </button>
            </div>
            <form id="product-type-form" class="mt-4 space-y-4">
                <input type="hidden" id="product-type-id" />
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
                           class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 font-mono text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 disabled:bg-slate-100 disabled:text-slate-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200 dark:disabled:bg-slate-800 dark:disabled:text-slate-400" />
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
                            <div class="grid grid-cols-[1fr_88px_88px] items-center gap-3 rounded-lg bg-white px-3 py-2 dark:bg-slate-900">
                                <div>
                                    <p class="text-sm font-semibold text-slate-800 dark:text-slate-100">{{ __($field['label']) }}</p>
                                    <p class="text-xs text-slate-500">{{ $field['payload_key'] }}</p>
                                </div>
                                <label class="flex justify-center">
                                    <input type="checkbox" data-product-type-field value="{{ $fieldKey }}" class="h-4 w-4 rounded border-slate-300 text-primary-600 focus:ring-primary-500" />
                                </label>
                                <label class="flex justify-center">
                                    <input type="checkbox" data-product-type-required value="{{ $fieldKey }}" class="h-4 w-4 rounded border-slate-300 text-primary-600 focus:ring-primary-500 disabled:opacity-40" />
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

    {{-- Add / Edit option modal --}}
    <div id="option-modal" class="fixed inset-0 z-50 hidden items-center justify-center bg-black/40 px-4">
        <div class="w-full max-w-md rounded-2xl bg-white p-6 shadow-xl dark:bg-slate-900">
            <div class="flex items-center justify-between">
                <h3 id="option-modal-title" class="text-lg font-semibold text-slate-900 dark:text-white">{{ __('Add Option') }}</h3>
                <button id="option-modal-close" type="button" class="rounded-lg p-1 text-slate-400 hover:text-slate-600 dark:hover:text-slate-200">
                    <svg class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                </button>
            </div>
            <form id="option-form" class="mt-4 space-y-4">
                <input type="hidden" id="option-id" />
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="option-type">{{ __('Attribute') }}</label>
                    <select id="option-type" class="mt-2 w-full appearance-none rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 disabled:bg-slate-100 disabled:text-slate-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200 dark:disabled:bg-slate-800 dark:disabled:text-slate-400">
                        <option value="storage_capacity">{{ __('Storage Capacity') }}</option>
                        <option value="color">{{ __('Color') }}</option>
                        <option value="condition">{{ __('Condition') }}</option>
                        <option value="ram">{{ __('RAM') }}</option>
                        <option value="ssd">{{ __('SSD') }}</option>
                        <option value="cpu">{{ __('CPU') }}</option>
                        <option value="display">{{ __('Display') }}</option>
                        <option value="country">{{ __('Country') }}</option>
                    </select>
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="option-value">{{ __('Value') }}</label>
                    <input id="option-value" type="text" placeholder="{{ __('e.g. 256GB') }}"
                           class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    <p id="option-value-error" class="mt-2 text-xs text-danger-600"></p>
                </div>
                <p id="option-form-error" class="text-xs text-danger-600"></p>
                <div class="flex items-center justify-end gap-3 pt-1">
                    <button id="option-cancel" type="button" class="h-10 rounded-xl border border-slate-200 px-4 text-sm font-semibold text-slate-600 hover:bg-slate-50 dark:border-slate-700 dark:text-slate-200 dark:hover:bg-slate-800">{{ __('Cancel') }}</button>
                    <button id="option-submit" type="submit" class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white shadow-sm hover:bg-primary-700 transition-colors">{{ __('Save') }}</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var filterSelect = document.getElementById('master-filter');
            var searchInput = document.getElementById('master-search');
            var rows = document.getElementById('master-rows');
            var countInfo = document.getElementById('master-count-info');
            var addButton = document.getElementById('master-add-btn');

            var modal = document.getElementById('option-modal');
            var modalTitle = document.getElementById('option-modal-title');
            var modalClose = document.getElementById('option-modal-close');
            var modalCancel = document.getElementById('option-cancel');
            var form = document.getElementById('option-form');
            var idInput = document.getElementById('option-id');
            var typeSelect = document.getElementById('option-type');
            var valueInput = document.getElementById('option-value');
            var valueError = document.getElementById('option-value-error');
            var formError = document.getElementById('option-form-error');

            var allOptions = [];
            var allProductTypes = [];

            var typeLabels = {
                storage_capacity: @json(__('Storage Capacity')),
                color: @json(__('Color')),
                condition: @json(__('Condition')),
                ram: @json(__('RAM')),
                ssd: @json(__('SSD')),
                cpu: @json(__('CPU')),
                display: @json(__('Display')),
                country: @json(__('Country')),
            };

            var typeBadgeClasses = {
                storage_capacity: 'bg-sky-50 text-sky-700 dark:bg-sky-500/10 dark:text-sky-300',
                color: 'bg-rose-50 text-rose-700 dark:bg-rose-500/10 dark:text-rose-300',
                condition: 'bg-amber-50 text-amber-700 dark:bg-amber-500/10 dark:text-amber-300',
                ram: 'bg-violet-50 text-violet-700 dark:bg-violet-500/10 dark:text-violet-300',
                ssd: 'bg-indigo-50 text-indigo-700 dark:bg-indigo-500/10 dark:text-indigo-300',
                cpu: 'bg-emerald-50 text-emerald-700 dark:bg-emerald-500/10 dark:text-emerald-300',
                display: 'bg-cyan-50 text-cyan-700 dark:bg-cyan-500/10 dark:text-cyan-300',
                country: 'bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-300',
            };

            var productTypeRows = document.getElementById('product-type-rows');
            var productTypeCountInfo = document.getElementById('product-type-count-info');
            var productTypeAddButton = document.getElementById('product-type-add-btn');
            var productTypeModal = document.getElementById('product-type-modal');
            var productTypeModalTitle = document.getElementById('product-type-modal-title');
            var productTypeModalClose = document.getElementById('product-type-modal-close');
            var productTypeCancel = document.getElementById('product-type-cancel');
            var productTypeForm = document.getElementById('product-type-form');
            var productTypeIdInput = document.getElementById('product-type-id');
            var productTypeNameInput = document.getElementById('product-type-name');
            var productTypeSlugInput = document.getElementById('product-type-slug');
            var productTypeSortInput = document.getElementById('product-type-sort-order');
            var productTypeFieldsError = document.getElementById('product-type-fields-error');
            var productTypeFormError = document.getElementById('product-type-form-error');
            var productTypeSlugTouched = false;

            var productTypeFieldLabels = {
                display: @json(__('Display')),
                cpu: @json(__('CPU')),
                storage: @json(__('Storage')),
                ram: @json(__('RAM')),
                ssd: @json(__('SSD')),
                color: @json(__('Color')),
                condition: @json(__('Condition')),
                country: @json(__('Country')),
            };

            function escapeHtml(value) {
                return String(value ?? '')
                    .replace(/&/g, '&amp;')
                    .replace(/</g, '&lt;')
                    .replace(/>/g, '&gt;')
                    .replace(/"/g, '&quot;')
                    .replace(/'/g, '&#039;');
            }

            function typeBadge(type) {
                var label = typeLabels[type] || type;
                var classes = typeBadgeClasses[type] || 'bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-300';
                return '<span class="rounded-full px-2 py-1 text-xs font-semibold ' + classes + '">' + escapeHtml(label) + '</span>';
            }

            function slugify(value) {
                return String(value || '')
                    .toLowerCase()
                    .replace(/[^a-z0-9]+/g, '-')
                    .replace(/^-+|-+$/g, '')
                    .slice(0, 20);
            }

            function productTypeById(id) {
                return allProductTypes.find(function (item) {
                    return String(item.id) === String(id);
                });
            }

            function productTypeFieldText(fields) {
                var list = Array.isArray(fields) ? fields : [];
                return list.map(function (field) {
                    return productTypeFieldLabels[field] || field;
                }).join(', ') || 'None';
            }

            function productTypeFieldBadges(fields) {
                var list = Array.isArray(fields) ? fields : [];
                return list.map(function (field) {
                    return '<span class="rounded-full bg-slate-100 px-2 py-1 text-xs font-semibold text-slate-600 dark:bg-slate-800 dark:text-slate-300">' + escapeHtml(productTypeFieldLabels[field] || field) + '</span>';
                }).join(' ') || '<span class="text-xs text-slate-400">None</span>';
            }

            function selectedProductTypeValues(selector) {
                return Array.from(document.querySelectorAll(selector))
                    .filter(function (input) { return input.checked && !input.disabled; })
                    .map(function (input) { return input.value; });
            }

            function syncRequiredFieldControls() {
                document.querySelectorAll('[data-product-type-required]').forEach(function (input) {
                    var fieldInput = document.querySelector('[data-product-type-field][value="' + input.value + '"]');
                    var enabled = Boolean(fieldInput && fieldInput.checked);
                    input.disabled = !enabled;
                    if (!enabled) {
                        input.checked = false;
                    }
                });
            }

            function setProductTypeCheckboxes(fields, requiredFields) {
                var visible = Array.isArray(fields) ? fields : [];
                var required = Array.isArray(requiredFields) ? requiredFields : [];

                document.querySelectorAll('[data-product-type-field]').forEach(function (input) {
                    input.checked = visible.indexOf(input.value) !== -1;
                });
                document.querySelectorAll('[data-product-type-required]').forEach(function (input) {
                    input.checked = required.indexOf(input.value) !== -1;
                });
                syncRequiredFieldControls();
            }

            function renderProductTypeRows() {
                productTypeRows.innerHTML = allProductTypes.map(function (item) {
                    var name = escapeHtml(item.name);
                    var slug = escapeHtml(item.slug);
                    var count = Number(item.products_count || 0);
                    return `
                        <tr class="hover:bg-slate-50 dark:hover:bg-slate-800/40 transition-colors" data-id="${item.id}">
                            <td class="px-4 py-3">
                                <p class="font-semibold text-slate-900 dark:text-white">${name}</p>
                                <p class="font-mono text-xs text-slate-400">${slug}</p>
                                <p class="text-xs text-slate-400">${count} ${count === 1 ? 'product' : 'products'}</p>
                            </td>
                            <td class="px-4 py-3">${productTypeFieldBadges(item.fields)}</td>
                            <td class="px-4 py-3">${productTypeFieldText(item.required_fields)}</td>
                            <td class="px-4 py-3 text-right">
                                <div class="inline-flex items-center justify-end gap-3">
                                    ${window.adminCan('update_product_master') ? `<button type="button" data-type-action="edit" class="text-xs font-semibold text-violet-600 hover:text-violet-800 transition-colors">{{ __('Edit') }}</button>` : ''}
                                    ${window.adminCan('delete_product_master') ? `<button type="button" data-type-action="delete" class="text-xs font-semibold text-red-500 hover:text-red-700 transition-colors">{{ __('Delete') }}</button>` : ''}
                                </div>
                            </td>
                        </tr>
                    `;
                }).join('') || '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="4">{{ __('No product types found.') }}</td></tr>';

                productTypeCountInfo.textContent = '{{ __('Showing') }} ' + allProductTypes.length + ' {{ __('product types') }}';
            }

            async function loadProductTypes() {
                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/product-types');
                if (!response.ok) {
                    allProductTypes = [];
                    productTypeRows.innerHTML = '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="4">{{ __('Unable to load product types.') }}</td></tr>';
                    productTypeCountInfo.textContent = '';
                    return;
                }
                var data = await response.json();
                allProductTypes = data.data || [];
                renderProductTypeRows();
            }

            function openProductTypeModal(data) {
                var isEdit = Boolean(data && data.id);
                productTypeIdInput.value = isEdit ? data.id : '';
                productTypeNameInput.value = (data && data.name) || '';
                productTypeSlugInput.value = (data && data.slug) || '';
                productTypeSlugInput.disabled = isEdit;
                productTypeSortInput.value = (data && data.sort_order) || 0;
                productTypeFieldsError.textContent = '';
                productTypeFormError.textContent = '';
                productTypeSlugTouched = isEdit;
                setProductTypeCheckboxes(
                    (data && data.fields) || ['storage', 'color', 'condition'],
                    (data && data.required_fields) || []
                );
                productTypeModalTitle.textContent = isEdit ? @json(__('Edit Product Type')) : @json(__('Add Product Type'));
                productTypeModal.classList.remove('hidden');
                productTypeModal.classList.add('flex');
                setTimeout(function () { productTypeNameInput.focus(); }, 0);
            }

            function closeProductTypeModal() {
                productTypeModal.classList.add('hidden');
                productTypeModal.classList.remove('flex');
            }

            if (productTypeAddButton) {
                productTypeAddButton.addEventListener('click', function () { openProductTypeModal(null); });
            }

            productTypeModalClose.addEventListener('click', closeProductTypeModal);
            productTypeCancel.addEventListener('click', closeProductTypeModal);
            productTypeModal.addEventListener('click', function (event) {
                if (event.target === productTypeModal) closeProductTypeModal();
            });

            productTypeNameInput.addEventListener('input', function () {
                if (!productTypeSlugTouched && !productTypeSlugInput.disabled) {
                    productTypeSlugInput.value = slugify(productTypeNameInput.value);
                }
            });

            productTypeSlugInput.addEventListener('input', function () {
                productTypeSlugTouched = true;
                productTypeSlugInput.value = slugify(productTypeSlugInput.value);
            });

            document.querySelectorAll('[data-product-type-field]').forEach(function (input) {
                input.addEventListener('change', syncRequiredFieldControls);
            });

            productTypeForm.addEventListener('submit', async function (event) {
                event.preventDefault();
                productTypeFieldsError.textContent = '';
                productTypeFormError.textContent = '';

                var id = productTypeIdInput.value;
                var fields = selectedProductTypeValues('[data-product-type-field]');
                var requiredFields = selectedProductTypeValues('[data-product-type-required]');
                var name = (productTypeNameInput.value || '').trim();
                var slug = slugify(productTypeSlugInput.value || name);

                if (!fields.length) {
                    productTypeFieldsError.textContent = @json(__('Select at least one field to show.'));
                    return;
                }

                await window.adminApi.ensureCsrfCookie();
                var body = {
                    name: name,
                    fields: fields,
                    required_fields: requiredFields,
                    sort_order: Number(productTypeSortInput.value || 0),
                };
                if (!id) {
                    body.slug = slug;
                }

                var response = await window.adminApi.request('/api/product-types' + (id ? '/' + encodeURIComponent(id) : ''), {
                    method: id ? 'PATCH' : 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(body),
                });

                if (response.ok) {
                    closeProductTypeModal();
                    await loadProductTypes();
                    window.adminToast?.(id ? @json(__('Product type updated.')) : @json(__('Product type added.')));
                    return;
                }

                var errorData = await response.json().catch(function () { return {}; });
                productTypeFormError.textContent = errorData.message || @json(__('Unable to save product type.'));
                window.adminToast?.(errorData.message || @json(__('Unable to save product type.')), { type: 'error' });
            });

            productTypeRows.addEventListener('click', async function (event) {
                var button = event.target.closest('[data-type-action]');
                if (!button) return;
                var row = button.closest('tr');
                if (!row || !row.dataset.id) return;

                var productType = productTypeById(row.dataset.id);
                if (!productType) return;

                if (button.dataset.typeAction === 'edit') {
                    openProductTypeModal(productType);
                    return;
                }

                if (button.dataset.typeAction === 'delete') {
                    var confirmed = true;
                    if (window.adminSwalConfirm) {
                        var result = await window.adminSwalConfirm(
                            @json(__('Delete product type?')),
                            @json(__('Products using this type will block deletion.')),
                            @json(__('Yes, delete it'))
                        );
                        confirmed = result.isConfirmed;
                    } else {
                        confirmed = window.confirm(@json(__('Delete this product type?')));
                    }
                    if (!confirmed) return;

                    await window.adminApi.ensureCsrfCookie();
                    var response = await window.adminApi.request('/api/product-types/' + encodeURIComponent(row.dataset.id), {
                        method: 'DELETE',
                    });

                    if (response.ok) {
                        await loadProductTypes();
                        window.adminToast?.(@json(__('Product type deleted.')));
                        return;
                    }

                    var errorData = await response.json().catch(function () { return {}; });
                    window.adminToast?.(errorData.message || @json(__('Unable to delete product type.')), { type: 'error' });
                }
            });

            function renderRows() {
                var query = (searchInput.value || '').trim().toLowerCase();
                var list = allOptions;
                if (query) {
                    list = list.filter(function (item) {
                        return String(item.value || '').toLowerCase().includes(query);
                    });
                }

                rows.innerHTML = list.map(function (item) {
                    var valueText = escapeHtml(item.value);
                    var typeText = escapeHtml(item.type);
                    return `
                        <tr class="hover:bg-slate-50 dark:hover:bg-slate-800/40 transition-colors" data-id="${item.id}" data-type="${typeText}" data-value="${valueText}">
                            <td class="px-4 py-3 font-semibold text-slate-900 dark:text-white">${valueText}</td>
                            <td class="px-4 py-3">${typeBadge(item.type)}</td>
                            <td class="px-4 py-3 text-right">
                                <div class="inline-flex items-center justify-end gap-3">
                                    ${window.adminCan('update_product_master') ? `<button type="button" data-action="edit" class="text-xs font-semibold text-violet-600 hover:text-violet-800 transition-colors">{{ __('Edit') }}</button>` : ''}
                                    ${window.adminCan('delete_product_master') ? `<button type="button" data-action="delete" class="text-xs font-semibold text-red-500 hover:text-red-700 transition-colors">{{ __('Delete') }}</button>` : ''}
                                </div>
                            </td>
                        </tr>
                    `;
                }).join('') || '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="3">{{ __('No options found.') }}</td></tr>';

                countInfo.textContent = '{{ __('Showing') }} ' + list.length + ' / ' + allOptions.length + ' {{ __('options') }}';
            }

            async function loadOptions() {
                await window.adminApi.ensureCsrfCookie();
                var url = '/api/product-attributes';
                if (filterSelect.value) {
                    url += '?type=' + encodeURIComponent(filterSelect.value);
                }
                var response = await window.adminApi.request(url);
                if (!response.ok) {
                    allOptions = [];
                    rows.innerHTML = '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="3">{{ __('Unable to load options.') }}</td></tr>';
                    countInfo.textContent = '';
                    return;
                }
                var data = await response.json();
                allOptions = data.data || [];
                renderRows();
            }

            function openModal(data) {
                var isEdit = Boolean(data && data.id);
                idInput.value = isEdit ? data.id : '';
                typeSelect.value = (data && data.type) || filterSelect.value || 'storage_capacity';
                typeSelect.disabled = isEdit;
                valueInput.value = (data && data.value) || '';
                valueError.textContent = '';
                formError.textContent = '';
                modalTitle.textContent = isEdit ? @json(__('Edit Option')) : @json(__('Add Option'));
                modal.classList.remove('hidden');
                modal.classList.add('flex');
                setTimeout(function () { valueInput.focus(); }, 0);
            }

            function closeModal() {
                modal.classList.add('hidden');
                modal.classList.remove('flex');
            }

            if (addButton) {
                addButton.addEventListener('click', function () { openModal(null); });
            }
            modalClose.addEventListener('click', closeModal);
            modalCancel.addEventListener('click', closeModal);
            modal.addEventListener('click', function (event) {
                if (event.target === modal) closeModal();
            });
            document.addEventListener('keydown', function (event) {
                if (event.key === 'Escape' && !modal.classList.contains('hidden')) closeModal();
                if (event.key === 'Escape' && !productTypeModal.classList.contains('hidden')) closeProductTypeModal();
            });

            form.addEventListener('submit', async function (event) {
                event.preventDefault();
                valueError.textContent = '';
                formError.textContent = '';

                var id = idInput.value;
                var value = (valueInput.value || '').trim();
                if (!value) {
                    valueError.textContent = @json(__('Value is required.'));
                    return;
                }

                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/product-attributes' + (id ? '/' + encodeURIComponent(id) : ''), {
                    method: id ? 'PATCH' : 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ type: typeSelect.value, value: value }),
                });

                if (response.ok) {
                    closeModal();
                    await loadOptions();
                    window.adminToast?.(id ? @json(__('Option updated.')) : @json(__('Option added.')));
                    return;
                }

                var errorData = await response.json().catch(function () { return {}; });
                if (errorData.errors?.value) {
                    valueError.textContent = errorData.errors.value[0];
                }
                formError.textContent = errorData.message || @json(__('Unable to save option.'));
                window.adminToast?.(errorData.message || @json(__('Unable to save option.')), { type: 'error' });
            });

            rows.addEventListener('click', async function (event) {
                var button = event.target.closest('[data-action]');
                if (!button) return;
                var row = button.closest('tr');
                if (!row || !row.dataset.id) return;

                if (button.dataset.action === 'edit') {
                    openModal({ id: row.dataset.id, type: row.dataset.type, value: row.dataset.value });
                    return;
                }

                if (button.dataset.action === 'delete') {
                    var confirmed = true;
                    if (window.adminSwalConfirm) {
                        var result = await window.adminSwalConfirm(
                            @json(__('Delete option?')),
                            @json(__('This action cannot be undone.')),
                            @json(__('Yes, delete it'))
                        );
                        confirmed = result.isConfirmed;
                    } else {
                        confirmed = window.confirm(@json(__('Delete this option?')));
                    }
                    if (!confirmed) return;

                    await window.adminApi.ensureCsrfCookie();
                    var response = await window.adminApi.request('/api/product-attributes/' + encodeURIComponent(row.dataset.id), {
                        method: 'DELETE',
                    });

                    if (response.ok) {
                        await loadOptions();
                        window.adminToast?.(@json(__('Option deleted.')));
                        return;
                    }

                    var errorData = await response.json().catch(function () { return {}; });
                    window.adminToast?.(errorData.message || @json(__('Unable to delete option.')), { type: 'error' });
                }
            });

            filterSelect.addEventListener('change', loadOptions);
            searchInput.addEventListener('input', renderRows);

            loadProductTypes();
            loadOptions();
        });
    </script>
@endsection
