@extends('layouts.admin')

@section('title', 'Assign Permissions')
@section('page-title', 'Assign Permissions')

@section('content')
    <div class="space-y-6">
        <div>
            <h2 class="text-lg font-semibold text-slate-900 dark:text-white">{{ __('Assign Permissions to Role') }}</h2>
            <p class="text-sm text-slate-500">{{ __('Select a role, then check the permissions it should have.') }}</p>
        </div>

        <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <div class="max-w-xs">
                <label class="text-xs font-semibold uppercase tracking-widest text-slate-400" for="assign-role-select">{{ __('Role') }}</label>
                <select id="assign-role-select" class="mt-2 h-10 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300">
                    <option value="">{{ __('Select a role...') }}</option>
                </select>
            </div>

            <div id="assign-permissions-wrapper" class="mt-6 hidden">
                <h3 class="text-sm font-semibold text-slate-900 dark:text-white">{{ __('User Management') }}</h3>
                <div id="assign-permission-checkboxes" class="mt-3 grid gap-3 sm:grid-cols-2 lg:grid-cols-3"></div>

                <button id="assign-save-btn" class="mt-6 inline-flex h-10 items-center justify-center rounded-xl bg-primary-600 px-5 text-sm font-semibold text-white">{{ __('Save Permissions') }}</button>
                <p id="assign-status" class="mt-3 text-xs text-slate-500"></p>
            </div>

            <p id="assign-empty-status" class="mt-4 text-sm text-slate-500">{{ __('Choose a role above to manage its permissions.') }}</p>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', async function () {
            var roleSelect = document.getElementById('assign-role-select');
            var wrapper = document.getElementById('assign-permissions-wrapper');
            var emptyStatus = document.getElementById('assign-empty-status');
            var checkboxContainer = document.getElementById('assign-permission-checkboxes');
            var saveButton = document.getElementById('assign-save-btn');
            var statusText = document.getElementById('assign-status');

            var permissionLabels = {
                create_user: '{{ __('Create User') }}',
                view_user: '{{ __('View User') }}',
                update_user: '{{ __('Update User') }}',
                delete_user: '{{ __('Delete User') }}',
                create_role: '{{ __('Create Role') }}',
                view_role: '{{ __('View Role') }}',
                update_role: '{{ __('Update Role') }}',
                delete_role: '{{ __('Delete Role') }}',
                create_permission: '{{ __('Create Permission') }}',
                view_permission: '{{ __('View Permission') }}',
                update_permission: '{{ __('Update Permission') }}',
                delete_permission: '{{ __('Delete Permission') }}'
            };

            var allPermissions = [];

            async function loadRoles() {
                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/roles');
                if (!response.ok) {
                    return;
                }
                var payload = await response.json();
                var items = Array.isArray(payload.data) ? payload.data : [];
                roleSelect.innerHTML = '<option value="">{{ __('Select a role...') }}</option>' + items.map(function (role) {
                    return `<option value="${role.id}">${role.name}</option>`;
                }).join('');
            }

            async function loadPermissions() {
                var response = await window.adminApi.request('/api/permissions');
                if (!response.ok) {
                    return;
                }
                var payload = await response.json();
                allPermissions = Array.isArray(payload.data) ? payload.data : [];
            }

            function renderCheckboxes(checkedIds) {
                checkboxContainer.innerHTML = allPermissions.map(function (permission) {
                    var label = permissionLabels[permission.name] || permission.name;
                    var checked = checkedIds.includes(permission.id) ? 'checked' : '';
                    return `
                        <label class="flex items-center gap-2 rounded-xl border border-slate-200 px-3 py-2 text-sm text-slate-600 dark:border-slate-800 dark:text-slate-300">
                            <input type="checkbox" class="permission-checkbox h-4 w-4 rounded border-slate-300 text-primary-600" value="${permission.id}" ${checked} />
                            ${label}
                        </label>
                    `;
                }).join('');
            }

            roleSelect.addEventListener('change', async function () {
                var roleId = roleSelect.value;
                if (!roleId) {
                    wrapper.classList.add('hidden');
                    emptyStatus.classList.remove('hidden');
                    return;
                }

                statusText.textContent = '{{ __('Loading...') }}';
                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/roles/' + roleId + '/permissions');
                if (!response.ok) {
                    statusText.textContent = '{{ __('Unable to load permissions for this role.') }}';
                    return;
                }
                var payload = await response.json();
                var checkedIds = (payload.data && Array.isArray(payload.data.permissions)) ? payload.data.permissions : [];

                renderCheckboxes(checkedIds);
                wrapper.classList.remove('hidden');
                emptyStatus.classList.add('hidden');
                statusText.textContent = '';
            });

            saveButton.addEventListener('click', async function () {
                var roleId = roleSelect.value;
                if (!roleId) {
                    return;
                }

                var permissionIds = Array.from(checkboxContainer.querySelectorAll('.permission-checkbox:checked')).map(function (el) {
                    return parseInt(el.value, 10);
                });

                saveButton.disabled = true;
                statusText.textContent = '{{ __('Saving...') }}';
                try {
                    await window.adminApi.ensureCsrfCookie();
                    var response = await window.adminApi.request('/api/roles/' + roleId + '/permissions', {
                        method: 'PUT',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ permission_ids: permissionIds })
                    });

                    if (!response.ok) {
                        statusText.textContent = '{{ __('Unable to save permissions.') }}';
                        return;
                    }
                    statusText.textContent = '{{ __('Permissions saved.') }}';
                } catch (error) {
                    statusText.textContent = '{{ __('Unable to save permissions.') }}';
                    console.error(error);
                } finally {
                    saveButton.disabled = false;
                }
            });

            await Promise.all([loadRoles(), loadPermissions()]);
        });
    </script>
@endsection
