@extends('layouts.admin')

@section('title', 'Roles & Permissions')
@section('page-title', 'Roles & Permissions')

@section('content')
    <div class="space-y-6">
        <div class="flex flex-wrap items-center justify-between gap-3">
            <div>
                <h2 class="text-lg font-semibold text-slate-900 dark:text-white">{{ __('Roles & Permissions') }}</h2>
                <p class="text-sm text-slate-500">{{ __('Create a role, tick what it can do, and save — all in one place. Assign roles to accounts in User Management.') }}</p>
            </div>
            @if (auth()->user()?->hasPermission('view_permission'))
                <a href="{{ route('admin.permissions.index') }}" class="inline-flex h-10 items-center justify-center rounded-xl border border-slate-200 px-4 text-sm font-semibold text-slate-600 dark:border-slate-800 dark:text-slate-300">{{ __('Custom Permissions') }}</a>
            @endif
        </div>

        <div class="grid gap-6 xl:grid-cols-[1fr_1.7fr]">
            <div class="self-start rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <div class="flex items-center justify-between gap-3">
                    <h3 class="text-sm font-semibold text-slate-900 dark:text-white">{{ __('Roles') }}</h3>
                    @if (auth()->user()?->hasPermission('create_role'))
                    <button id="role-new-btn" type="button" class="inline-flex h-9 items-center justify-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white">{{ __('+ New role') }}</button>
                    @endif
                </div>
                <div class="relative mt-4">
                    <input id="role-search" type="text" placeholder="{{ __('Search roles') }}" class="h-10 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>

                <ul id="role-list" class="mt-4 space-y-2">
                    <li class="rounded-xl border border-slate-200 px-4 py-6 text-center text-sm text-slate-500 dark:border-slate-800">{{ __('Loading roles...') }}</li>
                </ul>
                <p id="role-list-status" class="mt-4 text-xs text-slate-500"></p>
            </div>

            @if (auth()->user()?->hasAnyPermission('create_role', 'update_role'))
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <h3 id="role-form-title" class="text-sm font-semibold text-slate-900 dark:text-white">{{ __('Create Role') }}</h3>
                <form id="role-form" class="mt-4 space-y-4 text-sm text-slate-600 dark:text-slate-300">
                    <input type="hidden" id="role-id" value="" />
                    <div class="grid gap-4 sm:grid-cols-2">
                        <div>
                            <label class="text-xs font-semibold uppercase tracking-widest text-slate-400" for="role-name">{{ __('Role name') }}</label>
                            <input id="role-name" type="text" placeholder="{{ __('e.g. Cashier') }}" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                        </div>
                        <div>
                            <label class="text-xs font-semibold uppercase tracking-widest text-slate-400" for="role-description">{{ __('Description') }}</label>
                            <input id="role-description" type="text" placeholder="{{ __('What is this role for?') }}" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                        </div>
                    </div>

                    <div>
                        <div class="flex flex-wrap items-center justify-between gap-3">
                            <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">{{ __('Permissions') }}</p>
                            <div class="flex gap-2">
                                <button id="perm-check-all" type="button" class="h-8 rounded-lg border border-slate-200 px-3 text-xs font-semibold text-slate-600 dark:border-slate-800 dark:text-slate-300">{{ __('Select all') }}</button>
                                <button id="perm-uncheck-all" type="button" class="h-8 rounded-lg border border-slate-200 px-3 text-xs font-semibold text-slate-600 dark:border-slate-800 dark:text-slate-300">{{ __('Clear all') }}</button>
                            </div>
                        </div>

                        <div class="mt-3 overflow-x-auto rounded-xl border border-slate-200 dark:border-slate-800">
                            <table class="w-full text-left text-sm">
                                <thead class="bg-slate-50 text-xs uppercase tracking-widest text-slate-400 dark:bg-slate-900/60">
                                    <tr>
                                        <th class="px-4 py-3">{{ __('Module') }}</th>
                                        <th class="px-3 py-3 text-center">{{ __('All') }}</th>
                                        <th class="px-3 py-3 text-center">{{ __('View') }}</th>
                                        <th class="px-3 py-3 text-center">{{ __('Create') }}</th>
                                        <th class="px-3 py-3 text-center">{{ __('Update') }}</th>
                                        <th class="px-3 py-3 text-center">{{ __('Delete') }}</th>
                                    </tr>
                                </thead>
                                <tbody id="perm-module-rows" class="divide-y divide-slate-200 text-slate-600 dark:divide-slate-800 dark:text-slate-300">
                                    <tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="6">{{ __('Loading permissions...') }}</td></tr>
                                </tbody>
                            </table>
                        </div>

                        <div id="perm-other-wrapper" class="mt-4 hidden">
                            <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">{{ __('Other Permissions') }}</p>
                            <div id="perm-other-checkboxes" class="mt-3 grid gap-3 sm:grid-cols-2 lg:grid-cols-3"></div>
                        </div>
                    </div>

                    <div class="flex flex-wrap items-center gap-2">
                        <button id="role-submit" class="inline-flex h-10 items-center justify-center rounded-xl bg-primary-600 px-5 text-sm font-semibold text-white" type="submit">{{ __('Save role & permissions') }}</button>
                        <button id="role-cancel-edit" type="button" class="hidden h-10 items-center justify-center rounded-xl border border-slate-200 px-4 text-sm font-semibold text-slate-600 dark:border-slate-800 dark:text-slate-300">{{ __('Cancel') }}</button>
                        <p id="role-form-status" class="text-xs text-slate-500"></p>
                    </div>
                </form>
            </div>
            @endif
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', async function () {
            var searchInput = document.getElementById('role-search');
            var roleList = document.getElementById('role-list');
            var listStatus = document.getElementById('role-list-status');
            var form = document.getElementById('role-form');
            var formTitle = document.getElementById('role-form-title');
            var submitButton = document.getElementById('role-submit');
            var cancelButton = document.getElementById('role-cancel-edit');
            var newButton = document.getElementById('role-new-btn');
            var formStatus = document.getElementById('role-form-status');
            var idField = document.getElementById('role-id');
            var nameField = document.getElementById('role-name');
            var descriptionField = document.getElementById('role-description');
            var moduleRows = document.getElementById('perm-module-rows');
            var otherWrapper = document.getElementById('perm-other-wrapper');
            var otherContainer = document.getElementById('perm-other-checkboxes');
            var checkAllButton = document.getElementById('perm-check-all');
            var uncheckAllButton = document.getElementById('perm-uncheck-all');

            // Keep in sync with Database\Seeders\RolePermissionSeeder::MODULES.
            var moduleLabels = {
                dashboard: '{{ __('Dashboard') }}',
                notification: '{{ __('Notifications') }}',
                sales_report: '{{ __('Sales Report') }}',
                support_inbox: '{{ __('Support Inbox') }}',
                category: '{{ __('Categories') }}',
                product: '{{ __('Products') }}',
                product_master: '{{ __('Product Master') }}',
                accessory: '{{ __('Accessories') }}',
                banner: '{{ __('Banners') }}',
                order: '{{ __('Orders') }}',
                checking_pickup: '{{ __('Checking Pick Up') }}',
                tracking_order: '{{ __('Tracking Order') }}',
                voucher: '{{ __('Vouchers') }}',
                customer: '{{ __('Customers') }}',
                payment: '{{ __('Payments') }}',
                parts_inventory: '{{ __('Parts Inventory') }}',
                warranty_tracking: '{{ __('Warranty Tracking') }}',
                user: '{{ __('User Management') }}',
                role: '{{ __('Role Management') }}',
                permission: '{{ __('Permission Management') }}',
                setting: '{{ __('Setting') }}'
            };
            var actions = ['view', 'create', 'update', 'delete'];

            var allPermissions = [];
            var rolesById = {};

            var escapeHtml = function (value) {
                return String(value == null ? '' : value)
                    .replace(/&/g, '&amp;')
                    .replace(/</g, '&lt;')
                    .replace(/>/g, '&gt;')
                    .replace(/"/g, '&quot;');
            };

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

            function splitPermissionName(name) {
                var parts = String(name).split('_');
                var action = parts.shift();
                if (actions.indexOf(action) === -1 || !parts.length) {
                    return null;
                }
                return { action: action, module: parts.join('_') };
            }

            function renderMatrix(checkedIds) {
                if (!moduleRows) {
                    return;
                }
                var grouped = {};
                var other = [];

                allPermissions.forEach(function (permission) {
                    var parsed = splitPermissionName(permission.name);
                    if (parsed && moduleLabels[parsed.module]) {
                        grouped[parsed.module] = grouped[parsed.module] || {};
                        grouped[parsed.module][parsed.action] = permission;
                    } else {
                        other.push(permission);
                    }
                });

                var orderedModules = Object.keys(moduleLabels).filter(function (key) {
                    return grouped[key];
                });

                moduleRows.innerHTML = orderedModules.map(function (moduleKey) {
                    var cells = actions.map(function (action) {
                        var permission = grouped[moduleKey][action];
                        if (!permission) {
                            return '<td class="px-3 py-2.5 text-center text-slate-300">--</td>';
                        }
                        var checked = checkedIds.includes(permission.id) ? 'checked' : '';
                        return '<td class="px-3 py-2.5 text-center">' +
                            '<input type="checkbox" class="permission-checkbox h-4 w-4 rounded border-slate-300 text-primary-600" data-module="' + moduleKey + '" value="' + permission.id + '" ' + checked + ' />' +
                            '</td>';
                    }).join('');

                    return '<tr class="hover:bg-slate-50 dark:hover:bg-slate-800/40">' +
                        '<td class="px-4 py-2.5 font-medium text-slate-900 dark:text-white">' + moduleLabels[moduleKey] + '</td>' +
                        '<td class="px-3 py-2.5 text-center">' +
                            '<input type="checkbox" class="module-check-all h-4 w-4 rounded border-slate-300 text-primary-600" data-module="' + moduleKey + '" />' +
                        '</td>' +
                        cells +
                        '</tr>';
                }).join('') || '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="6">{{ __('No permissions found. Run the seeder first.') }}</td></tr>';

                if (other.length) {
                    otherWrapper.classList.remove('hidden');
                    otherContainer.innerHTML = other.map(function (permission) {
                        var checked = checkedIds.includes(permission.id) ? 'checked' : '';
                        return '<label class="flex items-center gap-2 rounded-xl border border-slate-200 px-3 py-2 text-sm text-slate-600 dark:border-slate-800 dark:text-slate-300">' +
                            '<input type="checkbox" class="permission-checkbox h-4 w-4 rounded border-slate-300 text-primary-600" value="' + permission.id + '" ' + checked + ' />' +
                            escapeHtml(permission.description || permission.name) +
                            '</label>';
                    }).join('');
                } else {
                    otherWrapper.classList.add('hidden');
                    otherContainer.innerHTML = '';
                }

                moduleRows.querySelectorAll('.module-check-all').forEach(function (masterBox) {
                    var moduleKey = masterBox.dataset.module;
                    var boxes = Array.from(moduleRows.querySelectorAll('.permission-checkbox[data-module="' + moduleKey + '"]'));

                    var syncMaster = function () {
                        masterBox.checked = boxes.length > 0 && boxes.every(function (box) { return box.checked; });
                    };
                    syncMaster();

                    masterBox.addEventListener('change', function () {
                        boxes.forEach(function (box) { box.checked = masterBox.checked; });
                    });
                    boxes.forEach(function (box) {
                        box.addEventListener('change', syncMaster);
                    });
                });
            }

            function setAll(checked) {
                form.querySelectorAll('.permission-checkbox, .module-check-all').forEach(function (box) {
                    box.checked = checked;
                });
            }

            if (checkAllButton) checkAllButton.addEventListener('click', function () { setAll(true); });
            if (uncheckAllButton) uncheckAllButton.addEventListener('click', function () { setAll(false); });

            function resetForm() {
                if (!form) {
                    return;
                }
                idField.value = '';
                nameField.value = '';
                descriptionField.value = '';
                formTitle.textContent = '{{ __('Create Role') }}';
                submitButton.textContent = '{{ __('Save role & permissions') }}';
                cancelButton.classList.add('hidden');
                formStatus.textContent = '';
                renderMatrix([]);
                highlightSelectedRole(null);
            }

            function highlightSelectedRole(roleId) {
                roleList.querySelectorAll('[data-role-card]').forEach(function (card) {
                    var isSelected = roleId != null && roleId !== '' && card.dataset.roleCard === String(roleId);
                    card.classList.toggle('border-primary-500', isSelected);
                    card.classList.toggle('ring-1', isSelected);
                    card.classList.toggle('ring-primary-500', isSelected);
                });
            }

            async function loadPermissions() {
                var response = await window.adminApi.request('/api/permissions');
                if (!response.ok) {
                    moduleRows.innerHTML = '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="6">{{ __('Unable to load permissions.') }}</td></tr>';
                    return;
                }
                var payload = await response.json();
                allPermissions = Array.isArray(payload.data) ? payload.data : [];
            }

            async function loadRoles() {
                roleList.innerHTML = '<li class="rounded-xl border border-slate-200 px-4 py-6 text-center text-sm text-slate-500 dark:border-slate-800">{{ __('Loading roles...') }}</li>';
                listStatus.textContent = '';
                try {
                    await window.adminApi.ensureCsrfCookie();
                    var query = new URLSearchParams();
                    if (searchInput.value.trim()) {
                        query.set('q', searchInput.value.trim());
                    }
                    var response = await window.adminApi.request('/api/roles?' + query.toString());
                    if (!response.ok) {
                        roleList.innerHTML = '<li class="rounded-xl border border-slate-200 px-4 py-6 text-center text-sm text-slate-500 dark:border-slate-800">{{ __('Unable to load roles.') }}</li>';
                        return;
                    }
                    var payload = await response.json();
                    var items = Array.isArray(payload.data) ? payload.data : [];
                    rolesById = {};
                    items.forEach(function (role) { rolesById[role.id] = role; });

                    roleList.innerHTML = items.map(function (role) {
                        var roleActions = '';
                        if (window.adminCan('update_role')) {
                            roleActions += '<button data-edit-id="' + role.id + '" class="role-edit-btn rounded-lg border border-slate-200 px-3 py-1 text-xs font-semibold text-primary-600 dark:border-slate-800">{{ __('Edit') }}</button>';
                        }
                        if (window.adminCan('delete_role')) {
                            roleActions += '<button data-delete-id="' + role.id + '" class="role-delete-btn rounded-lg border border-slate-200 px-3 py-1 text-xs font-semibold text-red-600 dark:border-slate-800">{{ __('Delete') }}</button>';
                        }
                        return '<li data-role-card="' + role.id + '" class="rounded-xl border border-slate-200 px-4 py-3 transition dark:border-slate-800">' +
                            '<div class="flex items-start justify-between gap-3">' +
                                '<div class="min-w-0">' +
                                    '<p class="truncate font-semibold text-slate-900 dark:text-white">' + escapeHtml(role.name) + '</p>' +
                                    '<p class="mt-0.5 truncate text-xs text-slate-500">' + (escapeHtml(role.description) || '--') + '</p>' +
                                    '<p class="mt-1 text-xs text-slate-400">' + (role.users_count ?? 0) + ' {{ __('user(s)') }} · ' + (role.permissions_count ?? 0) + ' {{ __('permission(s)') }}</p>' +
                                '</div>' +
                                '<div class="flex shrink-0 gap-2">' + roleActions + '</div>' +
                            '</div>' +
                            '</li>';
                    }).join('') || '<li class="rounded-xl border border-slate-200 px-4 py-6 text-center text-sm text-slate-500 dark:border-slate-800">{{ __('No roles yet. Create your first role on the right.') }}</li>';

                    listStatus.textContent = items.length + ' {{ __('role(s)') }}';
                    highlightSelectedRole(idField ? idField.value : null);

                    roleList.querySelectorAll('.role-edit-btn').forEach(function (btn) {
                        btn.addEventListener('click', function () { startEdit(btn.dataset.editId); });
                    });

                    roleList.querySelectorAll('.role-delete-btn').forEach(function (btn) {
                        btn.addEventListener('click', async function () {
                            var role = rolesById[btn.dataset.deleteId];
                            var label = role ? role.name : '';
                            if (!confirm('{{ __('Delete role') }} "' + label + '"? {{ __('Users with this role will lose their access.') }}')) {
                                return;
                            }
                            await window.adminApi.ensureCsrfCookie();
                            var deleteResponse = await window.adminApi.request('/api/roles/' + btn.dataset.deleteId, { method: 'DELETE' });
                            if (deleteResponse.ok) {
                                if (idField && idField.value === String(btn.dataset.deleteId)) {
                                    resetForm();
                                }
                                await loadRoles();
                            } else {
                                alert(await readErrorMessage(deleteResponse, '{{ __('Unable to delete role.') }}'));
                            }
                        });
                    });
                } catch (error) {
                    roleList.innerHTML = '<li class="rounded-xl border border-slate-200 px-4 py-6 text-center text-sm text-slate-500 dark:border-slate-800">{{ __('Unable to load roles.') }}</li>';
                    console.error(error);
                }
            }

            async function startEdit(roleId) {
                var role = rolesById[roleId];
                if (!role) {
                    return;
                }

                formStatus.textContent = '{{ __('Loading permissions...') }}';
                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/roles/' + roleId + '/permissions');
                var checkedIds = [];
                if (response.ok) {
                    var payload = await response.json();
                    checkedIds = (payload.data && Array.isArray(payload.data.permissions)) ? payload.data.permissions : [];
                }

                idField.value = role.id;
                nameField.value = role.name;
                descriptionField.value = role.description || '';
                formTitle.textContent = '{{ __('Edit Role') }}: ' + role.name;
                submitButton.textContent = '{{ __('Update role & permissions') }}';
                cancelButton.classList.remove('hidden');
                formStatus.textContent = '';
                renderMatrix(checkedIds);
                highlightSelectedRole(role.id);
                form.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }

            var debounceTimer = null;
            searchInput.addEventListener('input', function () {
                clearTimeout(debounceTimer);
                debounceTimer = setTimeout(loadRoles, 250);
            });

            if (cancelButton) cancelButton.addEventListener('click', resetForm);
            if (newButton) newButton.addEventListener('click', function () {
                resetForm();
                nameField.focus();
            });

            if (form) form.addEventListener('submit', async function (event) {
                event.preventDefault();
                try {
                    submitButton.disabled = true;
                    formStatus.textContent = '{{ __('Saving...') }}';
                    await window.adminApi.ensureCsrfCookie();

                    var isEdit = !!idField.value;
                    var response = await window.adminApi.request(isEdit ? '/api/roles/' + idField.value : '/api/roles', {
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

                    var payload = await response.json();
                    var roleId = isEdit ? idField.value : (payload.data && payload.data.id);

                    var permissionIds = Array.from(form.querySelectorAll('.permission-checkbox:checked')).map(function (el) {
                        return parseInt(el.value, 10);
                    });

                    var permResponse = await window.adminApi.request('/api/roles/' + roleId + '/permissions', {
                        method: 'PUT',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ permission_ids: permissionIds })
                    });

                    submitButton.disabled = false;
                    if (!permResponse.ok) {
                        formStatus.textContent = await readErrorMessage(permResponse, '{{ __('Role saved, but permissions could not be saved.') }}');
                        await loadRoles();
                        return;
                    }

                    resetForm();
                    formStatus.textContent = '{{ __('Role and permissions saved.') }}';
                    await loadRoles();
                } catch (error) {
                    submitButton.disabled = false;
                    formStatus.textContent = '{{ __('Unable to save role.') }}';
                    console.error(error);
                }
            });

            await Promise.all([loadPermissions(), loadRoles()]);
            renderMatrix([]);
        });
    </script>
@endsection
