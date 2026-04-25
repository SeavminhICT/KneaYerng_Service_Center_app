@extends('layouts.admin')

@section('title', 'Product Master')
@section('page-title', 'Product Master')

@section('content')
    <div class="space-y-6">
        <div class="flex flex-wrap items-center justify-between gap-4">
            <div>
                <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Product Master</h2>
                <p class="text-sm text-slate-500">Manage selectable options for products (storage, color, specs, and more).</p>
            </div>
        </div>

        <div class="grid gap-6 lg:grid-cols-[1.2fr_2fr]">
            <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <h3 class="text-sm font-semibold text-slate-900 dark:text-white">Add Option</h3>
                <p class="mt-1 text-xs text-slate-500">Create new values that appear in product create/edit.</p>

                <form id="master-create-form" class="mt-4 space-y-4">
                    <div>
                        <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="master-type">Attribute</label>
                        <select id="master-type" name="type" class="mt-2 w-full appearance-none rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                            <option value="storage_capacity">Storage Capacity</option>
                            <option value="color">Color</option>
                            <option value="condition">Condition</option>
                            <option value="ram">RAM</option>
                            <option value="ssd">SSD</option>
                            <option value="cpu">CPU</option>
                            <option value="display">Display</option>
                            <option value="country">Country</option>
                        </select>
                    </div>
                    <div>
                        <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="master-value">Value</label>
                        <input id="master-value" name="value" type="text" placeholder="e.g. 256GB" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                        <p id="master-value-error" class="mt-2 text-xs text-danger-600"></p>
                    </div>
                    <button class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white shadow-sm">Add Option</button>
                    <p id="master-form-error" class="text-xs text-danger-600"></p>
                </form>
            </div>

            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <div class="flex flex-wrap items-center justify-between gap-3">
                    <div class="flex items-center gap-3">
                        <select id="master-filter" class="h-10 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300">
                            <option value="storage_capacity">Storage Capacity</option>
                            <option value="color">Color</option>
                            <option value="condition">Condition</option>
                            <option value="ram">RAM</option>
                            <option value="ssd">SSD</option>
                            <option value="cpu">CPU</option>
                            <option value="display">Display</option>
                            <option value="country">Country</option>
                        </select>
                    </div>
                    <div class="relative">
                        <input id="master-search" type="text" placeholder="Search values" class="h-10 w-60 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                        <svg class="absolute right-3 top-3 h-4 w-4 text-slate-400" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-4.35-4.35m1.6-5.15a7 7 0 11-14 0 7 7 0 0114 0z" />
                        </svg>
                    </div>
                </div>

                <div class="mt-5 overflow-x-auto">
                    <table class="w-full text-left text-sm">
                        <thead class="text-xs uppercase tracking-widest text-slate-400">
                            <tr>
                                <th class="px-4 py-3">Value</th>
                                <th class="px-4 py-3">Type</th>
                                <th class="px-4 py-3 text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody id="master-rows" class="divide-y divide-slate-200 text-slate-600 dark:divide-slate-800 dark:text-slate-300"></tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <div id="edit-modal" class="fixed inset-0 z-50 hidden items-center justify-center bg-black/40 px-4">
        <div class="w-full max-w-md rounded-2xl bg-white p-6 shadow-xl dark:bg-slate-900">
            <div class="flex items-center justify-between">
                <h3 class="text-lg font-semibold text-slate-900 dark:text-white">Edit Option</h3>
                <button id="edit-modal-close" type="button" class="rounded-lg p-1 text-slate-400 hover:text-slate-600 dark:hover:text-slate-200">
                    <svg class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                </button>
            </div>
            <form id="edit-modal-form" class="mt-4 space-y-4">
                <input type="hidden" id="edit-id" />
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200">Type</label>
                    <input id="edit-type" type="text" disabled class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-100 px-3 py-2 text-sm text-slate-600 dark:border-slate-800 dark:bg-slate-800 dark:text-slate-300" />
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200">Value</label>
                    <input id="edit-value" type="text" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    <p id="edit-value-error" class="mt-2 text-xs text-danger-600"></p>
                </div>
                <button class="inline-flex h-10 w-full items-center justify-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white shadow-sm">Update</button>
                <p id="edit-form-error" class="text-xs text-danger-600"></p>
            </form>
        </div>
    </div>

    <div id="delete-modal" class="fixed inset-0 z-50 hidden items-center justify-center bg-black/40 px-4">
        <div class="w-full max-w-sm rounded-2xl bg-white p-6 text-center shadow-xl dark:bg-slate-900">
            <div class="mx-auto mb-3 flex h-12 w-12 items-center justify-center rounded-full bg-rose-50 text-rose-600 dark:bg-rose-500/10 dark:text-rose-300">
                <svg class="h-6 w-6" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v4m0 4h.01M19.1 7a9 9 0 11-14.2 0 9 9 0 0114.2 0z" />
                </svg>
            </div>
            <h3 class="text-lg font-semibold text-slate-900 dark:text-white">Delete option?</h3>
            <p class="mt-2 text-sm text-slate-500 dark:text-slate-300">This action cannot be undone.</p>
            <p id="delete-form-error" class="mt-3 text-xs text-danger-600"></p>
            <div class="mt-5 flex items-center justify-center gap-3">
                <button id="delete-cancel" type="button" class="h-10 rounded-xl border border-slate-200 px-4 text-sm font-semibold text-slate-600 hover:bg-slate-50 dark:border-slate-700 dark:text-slate-200">Cancel</button>
                <button id="delete-confirm" type="button" class="h-10 rounded-xl bg-rose-600 px-4 text-sm font-semibold text-white hover:bg-rose-700">Delete</button>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var filterSelect = document.getElementById('master-filter');
            var searchInput = document.getElementById('master-search');
            var rows = document.getElementById('master-rows');
            var editModal = document.getElementById('edit-modal');
            var editModalClose = document.getElementById('edit-modal-close');
            var editForm = document.getElementById('edit-modal-form');
            var editIdInput = document.getElementById('edit-id');
            var editTypeInput = document.getElementById('edit-type');
            var editValueInput = document.getElementById('edit-value');
            var editValueError = document.getElementById('edit-value-error');
            var editFormError = document.getElementById('edit-form-error');
            var deleteModal = document.getElementById('delete-modal');
            var deleteCancel = document.getElementById('delete-cancel');
            var deleteConfirm = document.getElementById('delete-confirm');
            var deleteFormError = document.getElementById('delete-form-error');
            var pendingDeleteId = null;

            function escapeHtml(value) {
                return String(value ?? '')
                    .replace(/&/g, '&amp;')
                    .replace(/</g, '&lt;')
                    .replace(/>/g, '&gt;')
                    .replace(/"/g, '&quot;')
                    .replace(/'/g, '&#039;');
            }

            async function loadOptions() {
                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/product-attributes?type=' + encodeURIComponent(filterSelect.value));
                if (!response.ok) {
                    rows.innerHTML = '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="3">Unable to load options.</td></tr>';
                    return;
                }
                var data = await response.json();
                var list = data.data || [];
                var query = (searchInput.value || '').trim().toLowerCase();
                if (query) {
                    list = list.filter(function (item) {
                        return String(item.value || '').toLowerCase().includes(query);
                    });
                }

                rows.innerHTML = list.map(function (item) {
                    var valueText = escapeHtml(item.value);
                    var typeText = escapeHtml(item.type);
                    return `
                        <tr data-id="${item.id}" data-type="${typeText}" data-value="${valueText}">
                            <td class="px-4 py-3">${valueText}</td>
                            <td class="px-4 py-3">${typeText}</td>
                            <td class="px-4 py-3 text-right">
                                <button type="button" data-action="edit" class="rounded-lg border border-slate-200 px-3 py-1 text-xs font-semibold text-slate-600 hover:bg-slate-50 dark:border-slate-700 dark:text-slate-200">Edit</button>
                                <button type="button" data-action="delete" class="ml-2 rounded-lg border border-rose-200 px-3 py-1 text-xs font-semibold text-rose-600 hover:bg-rose-50 dark:border-rose-400/40 dark:text-rose-300">Delete</button>
                            </td>
                        </tr>
                    `;
                }).join('') || '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="3">No options found.</td></tr>';
            }

            function openEditModal(data) {
                editIdInput.value = data.id || '';
                editTypeInput.value = data.type || '';
                editValueInput.value = data.value || '';
                editValueError.textContent = '';
                editFormError.textContent = '';
                editModal.classList.remove('hidden');
                editModal.classList.add('flex');
                setTimeout(function () {
                    editValueInput.focus();
                }, 0);
            }

            function closeEditModal() {
                editModal.classList.add('hidden');
                editModal.classList.remove('flex');
            }

            editModalClose.addEventListener('click', closeEditModal);
            editModal.addEventListener('click', function (event) {
                if (event.target === editModal) {
                    closeEditModal();
                }
            });
            function openDeleteModal(id) {
                pendingDeleteId = id;
                deleteFormError.textContent = '';
                deleteModal.classList.remove('hidden');
                deleteModal.classList.add('flex');
            }

            function closeDeleteModal() {
                pendingDeleteId = null;
                deleteModal.classList.add('hidden');
                deleteModal.classList.remove('flex');
            }

            deleteCancel.addEventListener('click', closeDeleteModal);
            deleteModal.addEventListener('click', function (event) {
                if (event.target === deleteModal) {
                    closeDeleteModal();
                }
            });

            document.addEventListener('keydown', function (event) {
                if (event.key === 'Escape') {
                    if (!editModal.classList.contains('hidden')) {
                        closeEditModal();
                    }
                    if (!deleteModal.classList.contains('hidden')) {
                        closeDeleteModal();
                    }
                }
            });

            rows.addEventListener('click', async function (event) {
                var button = event.target.closest('[data-action]');
                if (!button) return;
                var row = button.closest('tr');
                if (!row) return;

                var id = row.dataset.id;
                var type = row.dataset.type;
                var value = row.dataset.value;
                if (!id) return;

                if (button.dataset.action === 'edit') {
                    openEditModal({ id: id, type: type, value: value });
                    return;
                }

                if (button.dataset.action === 'delete') {
                    openDeleteModal(id);
                }
            });

            deleteConfirm.addEventListener('click', async function () {
                if (!pendingDeleteId) return;
                deleteFormError.textContent = '';
                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/product-attributes/' + encodeURIComponent(pendingDeleteId), {
                    method: 'DELETE',
                });

                if (response.ok) {
                    closeDeleteModal();
                    await loadOptions();
                    window.adminToast?.('Option deleted.');
                    return;
                }

                var errorData = await response.json();
                deleteFormError.textContent = errorData.message || 'Unable to delete option.';
                window.adminToast?.(errorData.message || 'Unable to delete option.', { type: 'error' });
            });

            editForm.addEventListener('submit', async function (event) {
                event.preventDefault();
                editValueError.textContent = '';
                editFormError.textContent = '';

                var id = editIdInput.value;
                var type = editTypeInput.value;
                var nextValue = (editValueInput.value || '').trim();

                if (!nextValue) {
                    editValueError.textContent = 'Value is required.';
                    return;
                }

                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/product-attributes/' + encodeURIComponent(id), {
                    method: 'PATCH',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ type: type, value: nextValue }),
                });

                if (response.ok) {
                    closeEditModal();
                    await loadOptions();
                    window.adminToast?.('Option updated.');
                    return;
                }

                var errorData = await response.json();
                if (errorData.errors?.value) {
                    editValueError.textContent = errorData.errors.value[0];
                }
                editFormError.textContent = errorData.message || 'Unable to update option.';
                window.adminToast?.(errorData.message || 'Unable to update option.', { type: 'error' });
            });

            filterSelect.addEventListener('change', loadOptions);
            searchInput.addEventListener('input', loadOptions);

            document.getElementById('master-create-form').addEventListener('submit', async function (event) {
                event.preventDefault();
                document.getElementById('master-form-error').textContent = '';
                document.getElementById('master-value-error').textContent = '';

                var type = document.getElementById('master-type').value;
                var valueInput = document.getElementById('master-value');
                var value = (valueInput.value || '').trim();

                if (!value) {
                    document.getElementById('master-value-error').textContent = 'Value is required.';
                    return;
                }

                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/product-attributes', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ type: type, value: value }),
                });

                if (response.ok) {
                    valueInput.value = '';
                    filterSelect.value = type;
                    await loadOptions();
                    if (window.adminToast) {
                        window.adminToast('Option added.');
                    }
                    return;
                }

                var errorData = await response.json();
                if (errorData.errors?.value) {
                    document.getElementById('master-value-error').textContent = errorData.errors.value[0];
                }
                document.getElementById('master-form-error').textContent = errorData.message || 'Unable to add option.';
                if (window.adminToast) {
                    window.adminToast(errorData.message || 'Unable to add option.', { type: 'error' });
                }
            });

            loadOptions();
        });
    </script>
@endsection
