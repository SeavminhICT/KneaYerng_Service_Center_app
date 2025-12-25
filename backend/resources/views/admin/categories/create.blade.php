@extends('layouts.admin')

@section('title', 'Create Category')
@section('page-title', 'Create Category')

@section('content')
    <div class="grid gap-6 lg:grid-cols-[2fr_1fr]">
        <form id="category-create-form" enctype="multipart/form-data" class="space-y-6 rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <div>
                <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Category Details</h2>
                <p class="text-sm text-slate-500">Add a new product category for the web and API catalog.</p>
            </div>

            <div>
                <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="name">Category Name</label>
                <input id="name" name="name" type="text" placeholder="Fresh Beverages" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                <p id="category-name-error" class="mt-2 text-xs text-danger-600"></p>
            </div>

            <div>
                <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="slug">Slug</label>
                <input id="slug" name="slug" type="text" placeholder="fresh-beverages" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
            </div>

            <div>
                <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="status">Status</label>
                <select id="status" name="status" class="mt-2 w-full appearance-none rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                    <option value="active" selected>Active</option>
                    <option value="inactive">Inactive</option>
                </select>
            </div>

            <div class="flex items-center gap-3">
                <button class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white shadow-sm">Save Category</button>
                <a href="{{ route('admin.categories.index') }}" class="text-sm font-semibold text-slate-500">Cancel</a>
            </div>
            <p id="category-form-error" class="text-sm text-danger-600"></p>
        </form>

        <div class="space-y-6">
            <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900" x-data="{ preview: null }">
                <h3 class="text-sm font-semibold text-slate-900 dark:text-white">Category Image</h3>
                <p class="mt-1 text-xs text-slate-500">Upload a thumbnail to display in the app.</p>
                <div class="mt-4 flex h-40 items-center justify-center rounded-xl border border-dashed border-slate-300 bg-slate-50 text-xs text-slate-500 dark:border-slate-700 dark:bg-slate-900/60">
                    <template x-if="preview">
                        <img :src="preview" alt="Preview" class="h-32 w-32 rounded-xl object-cover" />
                    </template>
                    <template x-if="!preview">
                        <div class="text-center">
                            <p class="font-semibold">Drop image here</p>
                            <p>PNG, JPG up to 2MB</p>
                        </div>
                    </template>
                </div>
                <input type="file" name="image" form="category-create-form" class="mt-4 w-full text-sm text-slate-500" @change="const file = $event.target.files[0]; if (file) { const reader = new FileReader(); reader.onload = e => preview = e.target.result; reader.readAsDataURL(file); }" />
            </div>

            <div class="rounded-2xl border border-slate-200 bg-slate-50 p-5 text-xs text-slate-500 dark:border-slate-800 dark:bg-slate-950">
                <p class="font-semibold text-slate-700 dark:text-slate-200">Select2-style tip</p>
                <p class="mt-2">Use searchable dropdowns for large category lists and tag fields.</p>
            </div>
        </div>
    </div>

    <script>
        document.getElementById('category-create-form').addEventListener('submit', async function (event) {
            event.preventDefault();
            document.getElementById('category-form-error').textContent = '';
            document.getElementById('category-name-error').textContent = '';

            var formData = new FormData(event.target);

            try {
                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/categories', {
                    method: 'POST',
                    body: formData,
                });

                if (response.ok) {
                    window.location.href = '/admin/categories';
                    return;
                }

                var errorData = await response.json();
                if (errorData.errors?.name) {
                    document.getElementById('category-name-error').textContent = errorData.errors.name[0];
                } else {
                    document.getElementById('category-form-error').textContent = errorData.message || 'Unable to save category.';
                }
            } catch (error) {
                document.getElementById('category-form-error').textContent = 'Unable to save category.';
            }
        });
    </script>
@endsection
