@extends('layouts.admin')

@section('title', 'Edit Product')
@section('page-title', 'Edit Product')

@section('content')
    <div class="grid gap-6 lg:grid-cols-[2fr_1fr]">
        <form id="product-edit-form" enctype="multipart/form-data" class="space-y-6 rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900" data-product-id="{{ $productId ?? '' }}">
            <div>
                <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Update Product</h2>
                <p class="text-sm text-slate-500">Edit product details to keep the catalog accurate.</p>
            </div>

            <div class="grid gap-4 sm:grid-cols-2">
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="name">Product Name</label>
                    <input id="name" name="name" type="text" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="brand">Brand</label>
                    <input id="brand" name="brand" type="text" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="sku">SKU</label>
                    <input id="sku" name="sku" type="text" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
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
                    <input id="price" name="price" type="number" step="0.01" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="discount">Discount</label>
                    <input id="discount" name="discount" type="number" step="0.01" min="0" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>
            </div>

            <div class="grid gap-4 sm:grid-cols-2">
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="stock">Stock</label>
                    <input id="stock" name="stock" type="number" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="status">Status</label>
                    <select id="status" name="status" class="mt-2 w-full appearance-none rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                        <option value="active">Active</option>
                        <option value="draft">Draft</option>
                        <option value="archived">Archived</option>
                    </select>
                </div>
            </div>

            <div>
                <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="description">Description</label>
                <textarea id="description" name="description" rows="4" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200"></textarea>
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
                <button class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white shadow-sm">Save Changes</button>
                <a href="{{ route('admin.products.index') }}" class="text-sm font-semibold text-slate-500">Cancel</a>
            </div>
        </form>

        <div class="space-y-6">
            <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900" x-data="{ preview: null }">
                <h3 class="text-sm font-semibold text-slate-900 dark:text-white">Product Images</h3>
                <p class="mt-1 text-xs text-slate-500">Replace the main cover if needed.</p>
                <div class="mt-4 flex h-40 items-center justify-center rounded-xl border border-dashed border-slate-300 bg-slate-50 text-xs text-slate-500 dark:border-slate-700 dark:bg-slate-900/60">
                    <template x-if="preview">
                        <img :src="preview" alt="Preview" class="h-32 w-32 rounded-xl object-cover" />
                    </template>
                    <template x-if="!preview">
                        <div class="text-center">
                            <p class="font-semibold">Current image</p>
                            <p id="current-thumbnail">No image</p>
                        </div>
                    </template>
                </div>
                <input type="file" name="thumbnail" form="product-edit-form" class="mt-4 w-full text-sm text-slate-500" @change="const file = $event.target.files[0]; if (file) { const reader = new FileReader(); reader.onload = e => preview = e.target.result; reader.readAsDataURL(file); }" />
                <label class="mt-4 text-xs font-semibold text-slate-600 dark:text-slate-300">Image Gallery</label>
                <div id="current-gallery" class="mt-2 grid grid-cols-3 gap-2 text-xs text-slate-500"></div>
                <div id="gallery-preview" class="mt-2 grid grid-cols-3 gap-2 text-xs text-slate-500"></div>
                <input type="file" name="image_gallery[]" form="product-edit-form" multiple class="mt-2 w-full text-sm text-slate-500" />
            </div>

            <div class="rounded-2xl border border-danger-100 bg-danger-50 p-5 text-xs text-danger-700 dark:border-danger-500/30 dark:bg-danger-500/10 dark:text-danger-100">
                <p class="font-semibold">Archive product</p>
                <p class="mt-2">Archived products stay in history but are hidden from the app.</p>
            </div>
        </div>
    </div>

    <script>
        async function loadCategories(selectedId) {
            await window.adminApi.ensureCsrfCookie();
            var response = await window.adminApi.request('/api/categories');
            if (!response.ok) {
                return;
            }
            var data = await response.json();
            var select = document.getElementById('category');
            select.innerHTML = '<option value=\"\">Select category</option>' + (data.data || []).map(function (category) {
                var selected = selectedId && String(category.id) === String(selectedId) ? ' selected' : '';
                return '<option value=\"' + category.id + '\"' + selected + '>' + category.name + '</option>';
            }).join('');
        }

        document.addEventListener('DOMContentLoaded', async function () {
            var form = document.getElementById('product-edit-form');
            var productId = form.dataset.productId;
            if (!productId) {
                return;
            }

            await window.adminApi.ensureCsrfCookie();
            var response = await window.adminApi.request('/api/products/' + productId);
            if (response.ok) {
                var data = await response.json();
                document.getElementById('name').value = data.data.name || '';
                document.getElementById('brand').value = data.data.brand || '';
                document.getElementById('sku').value = data.data.sku || '';
                document.getElementById('price').value = data.data.price ?? '';
                document.getElementById('discount').value = data.data.discount ?? '';
                document.getElementById('stock').value = data.data.stock ?? '';
                document.getElementById('status').value = data.data.status || 'active';
                document.getElementById('description').value = data.data.description || '';
                document.getElementById('storage_capacity').value = (data.data.storage_capacity || []).join(', ');
                document.getElementById('color').value = (data.data.color || []).join(', ');
                document.getElementById('condition').value = (data.data.condition || []).join(', ');
                var thumbLabel = document.getElementById('current-thumbnail');
                if (thumbLabel) {
                    thumbLabel.textContent = data.data.thumbnail ? data.data.thumbnail.split('/').pop() : 'No image';
                }
                var gallery = document.getElementById('current-gallery');
                if (gallery) {
                    gallery.innerHTML = (data.data.image_gallery || []).map(function (item) {
                        var name = String(item || '').split('/').pop();
                        return '<div class="rounded-lg border border-slate-200 bg-white px-2 py-1 dark:border-slate-800 dark:bg-slate-900">' + name + '</div>';
                    }).join('') || '<p class="col-span-3 text-xs text-slate-400">No gallery images</p>';
                }
                await loadCategories(data.data.category?.id);
            } else {
                await loadCategories();
            }
        });

        document.getElementById('product-edit-form').addEventListener('submit', async function (event) {
            event.preventDefault();
            var form = event.target;
            var productId = form.dataset.productId;
            var formData = new FormData(form);
            formData.append('_method', 'PUT');
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

            await window.adminApi.ensureCsrfCookie();
            var response = await window.adminApi.request('/api/products/' + productId, {
                method: 'POST',
                body: formData,
            });

            if (response.ok) {
                window.location.href = '/admin/products';
            }
        });

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
                renderGalleryPreview(event.target.files, 'gallery-preview');
            });
        }
    </script>
@endsection
