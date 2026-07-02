@extends('layouts.admin')

@section('title', 'Role Management')
@section('page-title', 'Role Management')

@section('content')
    <div class="space-y-6">
        <div class="flex flex-wrap items-center justify-between gap-3">
            <div>
                <h2 class="text-lg font-semibold text-slate-900 dark:text-white">{{ __('Roles') }}</h2>
                <p class="text-sm text-slate-500">{{ __('Create roles and assign permissions to control access.') }}</p>
            </div>
            <a href="{{ route('admin.roles.assign-permissions') }}" class="inline-flex h-10 items-center justify-center rounded-xl border border-slate-200 px-4 text-sm font-semibold text-slate-600 dark:border-slate-800 dark:text-slate-300">{{ __('Assign Permissions') }}</a>
        </div>

        <div class="grid gap-6 xl:grid-cols-[1.5fr_1fr]">
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <div class="relative">
                    <input id="role-search" type="text" placeholder="{{ __('Search roles') }}" class="h-10 w-60 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>

                <div class="mt-5 overflow-x-auto">
                    <table class="w-full text-left text-sm">
                        <thead class="text-xs uppercase tracking-widest text-slate-400">
                            <tr>
                                <th class="px-4 py-3">{{ __('Name') }}</th>
                                <th class="px-4 py-3">{{ __('Description') }}</th>
                                <th class="px-4 py-3">{{ __('Users') }}</th>
                                <th class="px-4 py-3 text-right">{{ __('Actions') }}</th>
                            </tr>
                        </thead>
                        <tbody id="role-rows" class="divide-y divide-slate-200 text-slate-600 dark:divide-slate-800 dark:text-slate-300">
                            <tr>
                                <td class="px-4 py-6 text-center text-sm text-slate-500" colspan="4">{{ __('Loading roles...') }}</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <p id="role-list-status" class="mt-4 text-xs text-slate-500"></p>
            </div>

            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <h3 id="role-form-title" class="text-sm font-semibold text-slate-900 dark:text-white">{{ __('Create Role') }}</h3>
                <form id="role-form" class="mt-4 space-y-3 text-sm text-slate-600 dark:text-slate-300">
                    <input type="hidden" id="role-id" value="" />
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-widest text-slate-400" for="role-name">{{ __('Role name') }}</label>
                        <input id="role-name" type="text" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    </div>
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-widest text-slate-400" for="role-description">{{ __('Description') }}</label>
                        <textarea id="role-description" rows="3" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200"></textarea>
                    </div>
                    <div class="flex gap-2">
                        <button id="role-submit" class="inline-flex h-10 flex-1 items-center justify-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white" type="submit">{{ __('Save role') }}</button>
                        <button id="role-cancel-edit" type="button" class="hidden h-10 items-center justify-center rounded-xl border border-slate-200 px-4 text-sm font-semibold text-slate-600 dark:border-slate-800 dark:text-slate-300">{{ __('Cancel') }}</button>
                    </div>
                    <p id="role-form-status" class="text-xs text-slate-500"></p>
                </form>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', async function () {
            var searchInput = document.getElementById('role-search');
            var rows = document.getElementById('role-rows');
            var listStatus = document.getElementById('role-list-status');
            var form = document.getElementById('role-form');
            var submitButton = document.getElementById('role-submit');
            var cancelButton = document.getElementById('role-cancel-edit');
            var formStatus = document.getElementById('role-form-status');
            var formTitle = document.getElementById('role-form-title');
            var idField = document.getElementById('role-id');
            var nameField = document.getElementById('role-name');
            var descriptionField = document.getElementById('role-description');

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
                formTitle.textContent = '{{ __('Create Role') }}';
                submitButton.textContent = '{{ __('Save role') }}';
                cancelButton.classList.add('hidden');
            }

            async function loadRoles() {
                rows.innerHTML = '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="4">{{ __('Loading roles...') }}</td></tr>';
                listStatus.textContent = '';
                try {
                    await window.adminApi.ensureCsrfCookie();
                    var query = new URLSearchParams();
                    if (searchInput.value.trim()) {
                        query.set('q', searchInput.value.trim());
                    }
                    var response = await window.adminApi.request('/api/roles?' + query.toString());
                    if (!response.ok) {
                        rows.innerHTML = '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="4">{{ __('Unable to load roles.') }}</td></tr>';
                        listStatus.textContent = '{{ __('Load failed.') }}';
                        return;
                    }
                    var payload = await response.json();
                    var items = Array.isArray(payload.data) ? payload.data : [];
                    rows.innerHTML = items.map(function (role) {
                        return `
                            <tr>
                                <td class="px-4 py-3 font-semibold text-slate-900 dark:text-white">${role.name}</td>
                                <td class="px-4 py-3">${role.description || '--'}</td>
                                <td class="px-4 py-3">${role.users_count ?? 0}</td>
                                <td class="px-4 py-3 text-right">
                                    <button data-edit-id="${role.id}" data-edit-name="${role.name}" data-edit-description="${role.description || ''}" class="role-edit-btn text-primary-600 hover:underline">{{ __('Edit') }}</button>
                                    <button data-delete-id="${role.id}" class="role-delete-btn ml-3 text-red-600 hover:underline">{{ __('Delete') }}</button>
                                </td>
                            </tr>
                        `;
                    }).join('') || '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="4">{{ __('No roles found.') }}</td></tr>';

                    listStatus.textContent = items.length + ' {{ __('role(s)') }}';

                    rows.querySelectorAll('.role-edit-btn').forEach(function (btn) {
                        btn.addEventListener('click', function () {
                            idField.value = btn.dataset.editId;
                            nameField.value = btn.dataset.editName;
                            descriptionField.value = btn.dataset.editDescription;
                            formTitle.textContent = '{{ __('Edit Role') }}';
                            submitButton.textContent = '{{ __('Update role') }}';
                            cancelButton.classList.remove('hidden');
                        });
                    });

                    rows.querySelectorAll('.role-delete-btn').forEach(function (btn) {
                        btn.addEventListener('click', async function () {
                            if (!confirm('{{ __('Delete this role?') }}')) {
                                return;
                            }
                            await window.adminApi.ensureCsrfCookie();
                            var deleteResponse = await window.adminApi.request('/api/roles/' + btn.dataset.deleteId, { method: 'DELETE' });
                            if (deleteResponse.ok) {
                                await loadRoles();
                            } else {
                                alert(await readErrorMessage(deleteResponse, '{{ __('Unable to delete role.') }}'));
                            }
                        });
                    });
                } catch (error) {
                    rows.innerHTML = '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="4">{{ __('Unable to load roles.') }}</td></tr>';
                    listStatus.textContent = '{{ __('Load failed.') }}';
                    console.error(error);
                }
            }

            var debounceTimer = null;
            searchInput.addEventListener('input', function () {
                clearTimeout(debounceTimer);
                debounceTimer = setTimeout(loadRoles, 250);
            });

            cancelButton.addEventListener('click', resetForm);

            form.addEventListener('submit', async function (event) {
                event.preventDefault();
                try {
                    submitButton.disabled = true;
                    formStatus.textContent = '{{ __('Saving...') }}';
                    await window.adminApi.ensureCsrfCookie();

                    var isEdit = !!idField.value;
                    var url = isEdit ? '/api/roles/' + idField.value : '/api/roles';
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
                        formStatus.textContent = await readErrorMessage(response, '{{ __('Unable to save role.') }}');
                        return;
                    }

                    resetForm();
                    submitButton.disabled = false;
                    formStatus.textContent = '{{ __('Role saved.') }}';
                    await loadRoles();
                } catch (error) {
                    submitButton.disabled = false;
                    formStatus.textContent = '{{ __('Unable to save role.') }}';
                    console.error(error);
                }
            });

            await loadRoles();
        });
    </script>
@endsection
