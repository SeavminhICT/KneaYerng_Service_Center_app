@extends('layouts.admin')

@section('title', 'Edit Category')
@section('page-title', 'Edit Category')

@section('content')
    <div class="grid gap-6 lg:grid-cols-[2fr_1fr]">
        <form id="category-edit-form" enctype="multipart/form-data"
              class="space-y-5 rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900"
              data-category-id="{{ $categoryId ?? '' }}">

            <div class="border-b border-slate-100 pb-4 dark:border-slate-800">
                <h2 class="text-base font-semibold text-slate-800 dark:text-slate-100">Update Category</h2>
                <p class="mt-0.5 text-xs text-slate-400">Edit category details and sync to the API catalog.</p>
            </div>

            <div>
                <label class="text-xs font-medium text-slate-600 dark:text-slate-400" for="name">Category Name</label>
                <input id="name" name="name" type="text"
                       class="mt-1.5 w-full rounded-lg border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-800 outline-none transition focus:border-slate-400 focus:bg-white dark:border-slate-700 dark:bg-slate-800 dark:text-slate-200 dark:focus:border-slate-500 dark:focus:bg-slate-800" />
                <p id="category-name-error" class="mt-1.5 text-xs text-slate-500"></p>
            </div>

            <div>
                <label class="text-xs font-medium text-slate-600 dark:text-slate-400" for="slug">Slug</label>
                <input id="slug" name="slug" type="text" disabled
                       class="mt-1.5 w-full cursor-not-allowed rounded-lg border border-slate-200 bg-slate-100 px-3 py-2 text-sm text-slate-400 dark:border-slate-700 dark:bg-slate-800/50 dark:text-slate-500" />
            </div>

            <div>
                <label class="text-xs font-medium text-slate-600 dark:text-slate-400" for="status">Status</label>
                <select id="status" name="status"
                        class="mt-1.5 w-full appearance-none rounded-lg border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-800 outline-none transition focus:border-slate-400 focus:bg-white dark:border-slate-700 dark:bg-slate-800 dark:text-slate-200 dark:focus:border-slate-500">
                    <option value="active">Active</option>
                    <option value="inactive">Inactive</option>
                </select>
            </div>

            <div class="flex items-center gap-3 pt-1">
                <button type="submit"
                        class="inline-flex h-9 items-center rounded-lg bg-slate-800 px-5 text-sm font-medium text-white transition hover:bg-slate-700 dark:bg-slate-700 dark:hover:bg-slate-600">
                    Save Changes
                </button>
                <a href="{{ route('admin.categories.index') }}"
                   class="text-sm font-medium text-slate-400 hover:text-slate-600 dark:hover:text-slate-200">
                    Cancel
                </a>
            </div>
            <p id="category-form-error" class="text-xs text-slate-500"></p>
        </form>

        <div class="space-y-5">
            {{-- Image upload --}}
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <h3 class="text-xs font-semibold uppercase tracking-widest text-slate-400">Category Image</h3>
                <p class="mt-1 text-xs text-slate-400">Replace the current thumbnail if needed.</p>
                <div class="mt-4 flex h-36 items-center justify-center rounded-xl border border-dashed border-slate-200 bg-slate-50 dark:border-slate-700 dark:bg-slate-800/40"
                     id="category-image-preview">
                    <div id="preview-placeholder" class="text-center text-xs text-slate-400">
                        <p>No image uploaded</p>
                    </div>
                    <img id="preview-image" src="" alt="Preview"
                         class="hidden h-28 w-28 rounded-lg object-cover" />
                </div>
                <input type="file" name="image" form="category-edit-form"
                       class="mt-3 w-full text-xs text-slate-500 file:mr-3 file:rounded-lg file:border-0 file:bg-slate-100 file:px-3 file:py-1.5 file:text-xs file:font-medium file:text-slate-600 hover:file:bg-slate-200 dark:file:bg-slate-700 dark:file:text-slate-300" />
            </div>

            {{-- Danger zone — plain, no heavy red --}}
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <h3 class="text-xs font-semibold uppercase tracking-widest text-slate-400">Danger Zone</h3>
                <p class="mt-2 text-xs text-slate-500 dark:text-slate-400">
                    Deleting a category will remove it from the API catalog and cannot be undone.
                </p>
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
                    
                    var reader = new FileReader();
                    reader.onload = function (e) {
                        var img = document.getElementById('preview-image');
                        var placeholder = document.getElementById('preview-placeholder');
                        if (img) {
                            img.src = e.target.result;
                            img.classList.remove('hidden');
                        }
                        if (placeholder) {
                            placeholder.classList.add('hidden');
                        }
                    };
                    reader.readAsDataURL(file);
                }
                if (window.adminValidateFileSize && file && !window.adminValidateFileSize(file, 'Image')) {
                    event.stopImmediatePropagation();
                    event.preventDefault();
                    event.target.value = '';
                    document.getElementById('category-form-error').textContent = 'Image must be 5MB or smaller.';
                    
                    var img = document.getElementById('preview-image');
                    var placeholder = document.getElementById('preview-placeholder');
                    if (img) {
                        img.src = '';
                        img.classList.add('hidden');
                    }
                    if (placeholder) {
                        placeholder.classList.remove('hidden');
                    }
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
                    var img = document.getElementById('preview-image');
                    var placeholder = document.getElementById('preview-placeholder');
                    if (img) {
                        img.src = data.data.image;
                        img.classList.remove('hidden');
                    }
                    if (placeholder) {
                        placeholder.classList.add('hidden');
                    }
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
