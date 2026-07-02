@extends('layouts.admin')

@section('title', 'Permission Management')
@section('page-title', 'Permission Management')

@section('content')
    <div class="space-y-6">
        <div>
            <h2 class="text-lg font-semibold text-slate-900 dark:text-white">{{ __('Permissions') }}</h2>
            <p class="text-sm text-slate-500">{{ __('Define the permissions that can be assigned to roles.') }}</p>
        </div>

        <div class="grid gap-6 xl:grid-cols-[1.5fr_1fr]">
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <input id="permission-search" type="text" placeholder="{{ __('Search permissions') }}" class="h-10 w-60 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />

                <div class="mt-5 overflow-x-auto">
                    <table class="w-full text-left text-sm">
                        <thead class="text-xs uppercase tracking-widest text-slate-400">
                            <tr>
                                <th class="px-4 py-3">{{ __('Name') }}</th>
                                <th class="px-4 py-3">{{ __('Description') }}</th>
                                <th class="px-4 py-3 text-right">{{ __('Actions') }}</th>
                            </tr>
                        </thead>
                        <tbody id="permission-rows" class="divide-y divide-slate-200 text-slate-600 dark:divide-slate-800 dark:text-slate-300">
                            <tr>
                                <td class="px-4 py-6 text-center text-sm text-slate-500" colspan="3">{{ __('Loading permissions...') }}</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <p id="permission-list-status" class="mt-4 text-xs text-slate-500"></p>
            </div>

            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <h3 id="permission-form-title" class="text-sm font-semibold text-slate-900 dark:text-white">{{ __('Create Permission') }}</h3>
                <form id="permission-form" class="mt-4 space-y-3 text-sm text-slate-600 dark:text-slate-300">
                    <input type="hidden" id="permission-id" value="" />
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-widest text-slate-400" for="permission-name">{{ __('Permission name') }}</label>
                        <input id="permission-name" type="text" placeholder="e.g. create_user" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    </div>
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-widest text-slate-400" for="permission-description">{{ __('Description') }}</label>
                        <textarea id="permission-description" rows="3" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200"></textarea>
                    </div>
                    <div class="flex gap-2">
                        <button id="permission-submit" class="inline-flex h-10 flex-1 items-center justify-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white" type="submit">{{ __('Save permission') }}</button>
                        <button id="permission-cancel-edit" type="button" class="hidden h-10 items-center justify-center rounded-xl border border-slate-200 px-4 text-sm font-semibold text-slate-600 dark:border-slate-800 dark:text-slate-300">{{ __('Cancel') }}</button>
                    </div>
                    <p id="permission-form-status" class="text-xs text-slate-500"></p>
                </form>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', async function () {
            var searchInput = document.getElementById('permission-search');
            var rows = document.getElementById('permission-rows');
            var listStatus = document.getElementById('permission-list-status');
            var form = document.getElementById('permission-form');
            var submitButton = document.getElementById('permission-submit');
            var cancelButton = document.getElementById('permission-cancel-edit');
            var formStatus = document.getElementById('permission-form-status');
            var formTitle = document.getElementById('permission-form-title');
            var idField = document.getElementById('permission-id');
            var nameField = document.getElementById('permission-name');
            var descriptionField = document.getElementById('permission-description');

            var readErrorMessage = async function (response, fallback) {
                var defaultMessage = fallback || '{{ __('Request failed.') }}';
                try {
                    var payload = await response.clone().json();
                    if (payload && payload.errors) {
                        var firstField = Object.keys(payload.errors)[0];
                        if (firstField && Array.isArray(payload.errors[firstField]) && payload.errors[firstField].length) {
                            return payload.errors[firstField][0];
                        }
                    }
                    if (payload && payload.message) {
                        return payload.message;
                    }
                } catch (error) {}
                return defaultMessage;
            };

            function resetForm() {
                idField.value = '';
                nameField.value = '';
                descriptionField.value = '';
                formTitle.textContent = '{{ __('Create Permission') }}';
                submitButton.textContent = '{{ __('Save permission') }}';
                cancelButton.classList.add('hidden');
            }

            async function loadPermissions() {
                rows.innerHTML = '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="3">{{ __('Loading permissions...') }}</td></tr>';
                listStatus.textContent = '';
                try {
                    await window.adminApi.ensureCsrfCookie();
                    var query = new URLSearchParams();
                    if (searchInput.value.trim()) {
                        query.set('q', searchInput.value.trim());
                    }
                    var response = await window.adminApi.request('/api/permissions?' + query.toString());
                    if (!response.ok) {
                        rows.innerHTML = '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="3">{{ __('Unable to load permissions.') }}</td></tr>';
                        listStatus.textContent = '{{ __('Load failed.') }}';
                        return;
                    }
                    var payload = await response.json();
                    var items = Array.isArray(payload.data) ? payload.data : [];
                    rows.innerHTML = items.map(function (permission) {
                        return `
                            <tr>
                                <td class="px-4 py-3 font-semibold text-slate-900 dark:text-white">${permission.name}</td>
                                <td class="px-4 py-3">${permission.description || '--'}</td>
                                <td class="px-4 py-3 text-right">
                                    <button data-edit-id="${permission.id}" data-edit-name="${permission.name}" data-edit-description="${permission.description || ''}" class="permission-edit-btn text-primary-600 hover:underline">{{ __('Edit') }}</button>
                                    <button data-delete-id="${permission.id}" class="permission-delete-btn ml-3 text-red-600 hover:underline">{{ __('Delete') }}</button>
                                </td>
                            </tr>
                        `;
                    }).join('') || '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="3">{{ __('No permissions found.') }}</td></tr>';

                    listStatus.textContent = items.length + ' {{ __('permission(s)') }}';

                    rows.querySelectorAll('.permission-edit-btn').forEach(function (btn) {
                        btn.addEventListener('click', function () {
                            idField.value = btn.dataset.editId;
                            nameField.value = btn.dataset.editName;
                            descriptionField.value = btn.dataset.editDescription;
                            formTitle.textContent = '{{ __('Edit Permission') }}';
                            submitButton.textContent = '{{ __('Update permission') }}';
                            cancelButton.classList.remove('hidden');
                        });
                    });

                    rows.querySelectorAll('.permission-delete-btn').forEach(function (btn) {
                        btn.addEventListener('click', async function () {
                            if (!confirm('{{ __('Delete this permission?') }}')) {
                                return;
                            }
                            await window.adminApi.ensureCsrfCookie();
                            var deleteResponse = await window.adminApi.request('/api/permissions/' + btn.dataset.deleteId, { method: 'DELETE' });
                            if (deleteResponse.ok) {
                                await loadPermissions();
                            } else {
                                alert(await readErrorMessage(deleteResponse, '{{ __('Unable to delete permission.') }}'));
                            }
                        });
                    });
                } catch (error) {
                    rows.innerHTML = '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="3">{{ __('Unable to load permissions.') }}</td></tr>';
                    listStatus.textContent = '{{ __('Load failed.') }}';
                    console.error(error);
                }
            }

            var debounceTimer = null;
            searchInput.addEventListener('input', function () {
                clearTimeout(debounceTimer);
                debounceTimer = setTimeout(loadPermissions, 250);
            });

            cancelButton.addEventListener('click', resetForm);

            form.addEventListener('submit', async function (event) {
                event.preventDefault();
                try {
                    submitButton.disabled = true;
                    formStatus.textContent = '{{ __('Saving...') }}';
                    await window.adminApi.ensureCsrfCookie();

                    var isEdit = !!idField.value;
                    var url = isEdit ? '/api/permissions/' + idField.value : '/api/permissions';
                    var response = await window.adminApi.request(url, {
                        method: isEdit ? 'PUT' : 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({
                            name: nameField.value.trim(),
                            description: descriptionField.value.trim()
                        })
                    });

                    if (!response.ok) {
                        submitButton.disabled = false;
                        formStatus.textContent = await readErrorMessage(response, '{{ __('Unable to save permission.') }}');
                        return;
                    }

                    resetForm();
                    submitButton.disabled = false;
                    formStatus.textContent = '{{ __('Permission saved.') }}';
                    await loadPermissions();
                } catch (error) {
                    submitButton.disabled = false;
                    formStatus.textContent = '{{ __('Unable to save permission.') }}';
                    console.error(error);
                }
            });

            await loadPermissions();
        });
    </script>
@endsection
