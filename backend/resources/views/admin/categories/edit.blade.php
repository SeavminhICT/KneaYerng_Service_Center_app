@extends('layouts.admin')

@section('title', 'Edit Category')
@section('page-title', 'Edit Category')

@section('content')
    <div class="grid gap-6 lg:grid-cols-[2fr_1fr]">
        <form id="category-edit-form" enctype="multipart/form-data" class="space-y-6 rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900" data-category-id="{{ $categoryId ?? '' }}">
            <div>
                <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Update Category</h2>
                <p class="text-sm text-slate-500">Edit category details and sync to the API catalog.</p>
            </div>

            <div>
                <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="name">Category Name</label>
                <input id="name" name="name" type="text" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                <p id="category-name-error" class="mt-2 text-xs text-danger-600"></p>
            </div>

            <div>
                <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="slug">Slug</label>
                <input id="slug" name="slug" type="text" disabled class="mt-2 w-full cursor-not-allowed rounded-xl border border-slate-200 bg-slate-100 px-3 py-2 text-sm text-slate-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-400" />
            </div>

            <div>
                <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="status">Status</label>
                <select id="status" name="status" class="mt-2 w-full appearance-none rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                    <option value="active">Active</option>
                    <option value="inactive">Inactive</option>
                </select>
            </div>

            <div class="flex items-center gap-3">
                <button class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white shadow-sm">Save Changes</button>
                <a href="{{ route('admin.categories.index') }}" class="text-sm font-semibold text-slate-500">Cancel</a>
            </div>
            <p id="category-form-error" class="text-sm text-danger-600"></p>
        </form>

        <div class="space-y-6">
            <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900" x-data="{ preview: null }">
                <h3 class="text-sm font-semibold text-slate-900 dark:text-white">Category Image</h3>
                <p class="mt-1 text-xs text-slate-500">Replace the current thumbnail if needed.</p>
                <div class="mt-4 flex h-40 items-center justify-center rounded-xl border border-dashed border-slate-300 bg-slate-50 text-xs text-slate-500 dark:border-slate-700 dark:bg-slate-900/60" id="category-image-preview">
                    <template x-if="preview">
                        <img :src="preview" alt="Preview" class="h-32 w-32 rounded-xl object-cover" />
                    </template>
                    <template x-if="!preview">
                        <div class="text-center">
                            <p class="font-semibold">No image uploaded</p>
                        </div>
                    </template>
                </div>
                <input type="file" name="image" form="category-edit-form" class="mt-4 w-full text-sm text-slate-500" @change="const file = $event.target.files[0]; if (file) { const reader = new FileReader(); reader.onload = e => preview = e.target.result; reader.readAsDataURL(file); }" />
            </div>

            <div class="rounded-2xl border border-danger-100 bg-danger-50 p-5 text-xs text-danger-700 dark:border-danger-500/30 dark:bg-danger-500/10 dark:text-danger-100">
                <p class="font-semibold">Danger zone</p>
                <p class="mt-2">Deleting a category will remove it from the API catalog.</p>
            </div>
        </div>
    </div>

    <script>
        var categoryImageInput = document.querySelector('input[name="image"][form="category-edit-form"]');
        if (categoryImageInput) {
            categoryImageInput.addEventListener('change', function (event) {
                var file = event.target.files[0];
                if (file) {
                    document.getElementById('category-form-error').textContent = '';
                }
                if (window.adminValidateFileSize && file && !window.adminValidateFileSize(file, 'Image')) {
                    event.stopImmediatePropagation();
                    event.preventDefault();
                    event.target.value = '';
                    document.getElementById('category-form-error').textContent = 'Image must be 5MB or smaller.';
                }
            }, true);
        }

        document.addEventListener('DOMContentLoaded', async function () {
            var form = document.getElementById('category-edit-form');
            var categoryId = form.dataset.categoryId;
            if (!categoryId) {
                return;
            }

            await window.adminApi.ensureCsrfCookie();
            var response = await window.adminApi.request('/api/categories/' + categoryId);
            if (response.ok) {
                var data = await response.json();
                document.getElementById('name').value = data.data.name || '';
                document.getElementById('slug').value = data.data.slug || '';
                document.getElementById('status').value = data.data.status || 'active';
                if (data.data.image) {
                    document.getElementById('category-image-preview').innerHTML = '<img src="' + data.data.image + '" alt="' + data.data.name + '" class="h-32 w-32 rounded-xl object-cover" />';
                }
            }
        });

        document.getElementById('category-edit-form').addEventListener('submit', async function (event) {
            event.preventDefault();
            document.getElementById('category-name-error').textContent = '';
            document.getElementById('category-form-error').textContent = '';
            var form = event.target;
            var categoryId = form.dataset.categoryId;
            var formData = new FormData(form);
            formData.append('_method', 'PUT');

            var slug = formData.get('slug');
            if (!slug || !String(slug).trim()) {
                formData.delete('slug');
            }

            var imageInput = form.querySelector('input[name="image"]');
            if (imageInput && imageInput.files.length === 0) {
                formData.delete('image');
            }

            try {
                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/categories/' + categoryId, {
                    method: 'POST',
                    body: formData,
                });

                if (response.ok) {
                    if (window.adminSwalStore) {
                        window.adminSwalStore({
                            icon: 'success',
                            title: 'Category updated',
                            text: 'Category updated successfully.',
                            confirmButtonColor: '#2563eb',
                        });
                    } else if (window.adminToastStore) {
                        window.adminToastStore({ type: 'success', message: 'Category updated successfully.' });
                    }
                    window.location.href = '/admin/categories';
                    return;
                }

                var errorData = await response.json();
                if (errorData.errors?.name) {
                    document.getElementById('category-name-error').textContent = errorData.errors.name[0];
                } else {
                    document.getElementById('category-form-error').textContent = errorData.message || 'Unable to update category.';
                }
                if (window.adminSwalError) {
                    window.adminSwalError('Update failed', errorData.message || 'Unable to update category.');
                } else if (window.adminToast) {
                    window.adminToast(errorData.message || 'Unable to update category.', { type: 'error' });
                }
            } catch (error) {
                document.getElementById('category-form-error').textContent = 'Unable to update category.';
                if (window.adminSwalError) {
                    window.adminSwalError('Update failed', 'Unable to update category.');
                } else if (window.adminToast) {
                    window.adminToast('Unable to update category.', { type: 'error' });
                }
            }
        });
    </script>
@endsection
