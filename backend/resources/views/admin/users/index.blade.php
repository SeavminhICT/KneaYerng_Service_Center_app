@extends('layouts.admin')

@section('title', 'User Management')
@section('page-title', 'User Management')

@section('content')
    <div class="space-y-6">
        <div>
            <h2 class="text-lg font-semibold text-slate-900 dark:text-white">{{ __('Users') }}</h2>
            <p class="text-sm text-slate-500">{{ __('Create accounts that can sign in to the web admin and control what they can do through roles and permissions.') }}</p>
        </div>

        <div class="grid gap-6 xl:grid-cols-[1.5fr_1fr]">
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <div class="flex flex-wrap items-center justify-between gap-3">
                    <div class="relative">
                        <input id="user-search" type="text" placeholder="{{ __('Search users') }}" class="h-10 w-60 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                        <svg class="absolute right-3 top-3 h-4 w-4 text-slate-400" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-4.35-4.35m1.6-5.15a7 7 0 11-14 0 7 7 0 0114 0z" />
                        </svg>
                    </div>
                    <select id="user-role-filter" class="h-10 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300">
                        <option value="">{{ __('All roles') }}</option>
                    </select>
                </div>

                <div class="mt-5 overflow-x-auto">
                    <table class="w-full text-left text-sm">
                        <thead class="text-xs uppercase tracking-widest text-slate-400">
                            <tr>
                                <th class="px-4 py-3">{{ __('Name') }}</th>
                                <th class="px-4 py-3">{{ __('Email') }}</th>
                                <th class="px-4 py-3">{{ __('Role') }}</th>
                                <th class="px-4 py-3">{{ __('Phone') }}</th>
                                <th class="px-4 py-3">{{ __('Status') }}</th>
                                <th class="px-4 py-3 text-right">{{ __('Actions') }}</th>
                            </tr>
                        </thead>
                        <tbody id="user-rows" class="divide-y divide-slate-200 text-slate-600 dark:divide-slate-800 dark:text-slate-300">
                            <tr>
                                <td class="px-4 py-6 text-center text-sm text-slate-500" colspan="6">{{ __('Loading users...') }}</td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <p id="user-list-status" class="mt-4 text-xs text-slate-500"></p>
            </div>

            @if (auth()->user()?->hasAnyPermission('create_user', 'update_user'))
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <h3 id="user-form-title" class="text-sm font-semibold text-slate-900 dark:text-white">{{ __('Create User Account') }}</h3>
                <form id="user-form" class="mt-4 space-y-3 text-sm text-slate-600 dark:text-slate-300">
                    <input type="hidden" id="user-id" value="" />
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-widest text-slate-400" for="user-first-name">{{ __('First name') }}</label>
                        <input id="user-first-name" type="text" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    </div>
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-widest text-slate-400" for="user-last-name">{{ __('Last name') }}</label>
                        <input id="user-last-name" type="text" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    </div>
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-widest text-slate-400" for="user-email">{{ __('Email') }}</label>
                        <input id="user-email" type="email" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    </div>
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-widest text-slate-400" for="user-phone">{{ __('Phone') }}</label>
                        <input id="user-phone" type="text" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    </div>
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-widest text-slate-400" for="user-role">{{ __('Role') }}</label>
                        <select id="user-role" class="mt-2 h-10 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300">
                            <option value="">{{ __('Loading roles...') }}</option>
                        </select>
                        <p class="mt-2 text-xs text-slate-500">
                            {{ __('The role decides what this user can see and do.') }}
                            @if (auth()->user()?->hasPermission('view_role'))
                                <a href="{{ route('admin.roles.index') }}" class="font-semibold text-primary-600 hover:underline">{{ __('Manage roles & permissions') }}</a>
                            @endif
                        </p>
                    </div>
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-widest text-slate-400" for="user-password">{{ __('Password') }}</label>
                        <input id="user-password" type="password" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                        <p id="user-password-hint" class="mt-2 text-xs text-slate-500">{{ __('Minimum 8 characters.') }}</p>
                    </div>
                    <div class="flex gap-2">
                        <button id="user-submit" class="inline-flex h-10 flex-1 items-center justify-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white" type="submit">{{ __('Create account') }}</button>
                        <button id="user-cancel-edit" type="button" class="hidden h-10 items-center justify-center rounded-xl border border-slate-200 px-4 text-sm font-semibold text-slate-600 dark:border-slate-800 dark:text-slate-300">{{ __('Cancel') }}</button>
                    </div>
                    <p id="user-form-status" class="text-xs text-slate-500"></p>
                </form>
            </div>
            @endif
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', async function () {
            var searchInput = document.getElementById('user-search');
            var roleFilter = document.getElementById('user-role-filter');
            var rows = document.getElementById('user-rows');
            var listStatus = document.getElementById('user-list-status');
            var form = document.getElementById('user-form');
            var formTitle = document.getElementById('user-form-title');
            var submitButton = document.getElementById('user-submit');
            var cancelButton = document.getElementById('user-cancel-edit');
            var formStatus = document.getElementById('user-form-status');
            var idField = document.getElementById('user-id');
            var firstNameField = document.getElementById('user-first-name');
            var lastNameField = document.getElementById('user-last-name');
            var emailField = document.getElementById('user-email');
            var phoneField = document.getElementById('user-phone');
            var roleField = document.getElementById('user-role');
            var passwordField = document.getElementById('user-password');
            var passwordHint = document.getElementById('user-password-hint');

            var usersById = {};

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
                } catch (error) {
                    // Ignore parse failure and fall back to default.
                }

                return defaultMessage;
            };

            var escapeHtml = function (value) {
                return String(value == null ? '' : value)
                    .replace(/&/g, '&amp;')
                    .replace(/</g, '&lt;')
                    .replace(/>/g, '&gt;')
                    .replace(/"/g, '&quot;');
            };

            function resetForm() {
                if (!form) {
                    return;
                }
                idField.value = '';
                form.reset();
                formTitle.textContent = '{{ __('Create User Account') }}';
                submitButton.textContent = '{{ __('Create account') }}';
                passwordHint.textContent = '{{ __('Minimum 8 characters.') }}';
                cancelButton.classList.add('hidden');
            }

            async function loadRoles() {
                try {
                    await window.adminApi.ensureCsrfCookie();
                    var response = await window.adminApi.request('/api/roles');
                    if (!response.ok) {
                        if (roleField) roleField.innerHTML = '<option value="">{{ __('Unable to load roles.') }}</option>';
                        return;
                    }
                    var payload = await response.json();
                    var items = Array.isArray(payload.data) ? payload.data : [];
                    var options = items.map(function (role) {
                        return '<option value="' + role.id + '">' + escapeHtml(role.name) + '</option>';
                    }).join('');

                    if (roleField) roleField.innerHTML = '<option value="">{{ __('Select a role...') }}</option>' + options;
                    roleFilter.innerHTML = '<option value="">{{ __('All roles') }}</option>' + options;
                } catch (error) {
                    if (roleField) roleField.innerHTML = '<option value="">{{ __('Unable to load roles.') }}</option>';
                    console.error(error);
                }
            }

            async function loadUsers() {
                rows.innerHTML = '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="6">{{ __('Loading users...') }}</td></tr>';
                listStatus.textContent = '';

                try {
                    await window.adminApi.ensureCsrfCookie();
                    var query = new URLSearchParams();
                    if (searchInput.value.trim()) {
                        query.set('q', searchInput.value.trim());
                    }
                    if (roleFilter.value) {
                        query.set('role_id', roleFilter.value);
                    }

                    var response = await window.adminApi.request('/api/admin/users?' + query.toString());
                    if (!response.ok) {
                        rows.innerHTML = '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="6">{{ __('Unable to load users.') }}</td></tr>';
                        listStatus.textContent = '{{ __('Load failed.') }}';
                        return;
                    }

                    var payload = await response.json();
                    var items = Array.isArray(payload.data) ? payload.data : [];
                    usersById = {};
                    items.forEach(function (user) {
                        usersById[user.id] = user;
                    });

                    rows.innerHTML = items.map(function (user) {
                        var isActive = user.status !== 'inactive';
                        var statusBadge = isActive
                            ? '<span class="rounded-full bg-emerald-100 px-2 py-1 text-xs font-semibold text-emerald-700 dark:bg-emerald-900/40 dark:text-emerald-400">{{ __('Active') }}</span>'
                            : '<span class="rounded-full bg-slate-100 px-2 py-1 text-xs font-semibold text-slate-500 dark:bg-slate-800">{{ __('Inactive') }}</span>';
                        var toggleLabel = isActive ? '{{ __('Deactivate') }}' : '{{ __('Activate') }}';
                        var actionButtons = '';
                        if (window.adminCan('update_user')) {
                            actionButtons += '<button data-edit-id="' + user.id + '" class="user-edit-btn text-primary-600 hover:underline">{{ __('Edit') }}</button>';
                            actionButtons += '<button data-toggle-id="' + user.id + '" data-next-status="' + (isActive ? 'inactive' : 'active') + '" class="user-toggle-btn ml-3 text-amber-600 hover:underline">' + toggleLabel + '</button>';
                        }
                        if (window.adminCan('delete_user')) {
                            actionButtons += '<button data-delete-id="' + user.id + '" class="user-delete-btn ml-3 text-red-600 hover:underline">{{ __('Delete') }}</button>';
                        }
                        if (!actionButtons) {
                            actionButtons = '<span class="text-xs text-slate-300 dark:text-slate-600">—</span>';
                        }

                        return `
                            <tr>
                                <td class="px-4 py-3 font-semibold text-slate-900 dark:text-white">${escapeHtml(user.name) || '--'}</td>
                                <td class="px-4 py-3">${escapeHtml(user.email) || '--'}</td>
                                <td class="px-4 py-3">${escapeHtml(user.role_name) || '--'}</td>
                                <td class="px-4 py-3">${escapeHtml(user.phone) || '--'}</td>
                                <td class="px-4 py-3">${statusBadge}</td>
                                <td class="px-4 py-3 text-right whitespace-nowrap">${actionButtons}</td>
                            </tr>
                        `;
                    }).join('') || '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="6">{{ __('No users found.') }}</td></tr>';

                    if (payload.meta && typeof payload.meta.total !== 'undefined') {
                        listStatus.textContent = payload.meta.total + ' {{ __('account(s)') }}';
                    }

                    rows.querySelectorAll('.user-edit-btn').forEach(function (btn) {
                        btn.addEventListener('click', function () {
                            var user = usersById[btn.dataset.editId];
                            if (!user) {
                                return;
                            }
                            idField.value = user.id;
                            firstNameField.value = user.first_name || '';
                            lastNameField.value = user.last_name || '';
                            emailField.value = user.email || '';
                            phoneField.value = user.phone || '';
                            roleField.value = user.role_id != null ? String(user.role_id) : '';
                            passwordField.value = '';
                            formTitle.textContent = '{{ __('Edit User Account') }}';
                            submitButton.textContent = '{{ __('Update account') }}';
                            passwordHint.textContent = '{{ __('Leave blank to keep the current password.') }}';
                            cancelButton.classList.remove('hidden');
                        });
                    });

                    rows.querySelectorAll('.user-toggle-btn').forEach(function (btn) {
                        btn.addEventListener('click', async function () {
                            await window.adminApi.ensureCsrfCookie();
                            var response = await window.adminApi.request('/api/admin/users/' + btn.dataset.toggleId + '/status', {
                                method: 'PATCH',
                                headers: { 'Content-Type': 'application/json' },
                                body: JSON.stringify({ status: btn.dataset.nextStatus })
                            });
                            if (response.ok) {
                                await loadUsers();
                            } else {
                                alert(await readErrorMessage(response, '{{ __('Unable to update status.') }}'));
                            }
                        });
                    });

                    rows.querySelectorAll('.user-delete-btn').forEach(function (btn) {
                        btn.addEventListener('click', async function () {
                            if (!confirm('{{ __('Delete this user account?') }}')) {
                                return;
                            }
                            await window.adminApi.ensureCsrfCookie();
                            var response = await window.adminApi.request('/api/admin/users/' + btn.dataset.deleteId, { method: 'DELETE' });
                            if (response.ok) {
                                await loadUsers();
                            } else {
                                alert(await readErrorMessage(response, '{{ __('Unable to delete user.') }}'));
                            }
                        });
                    });
                } catch (error) {
                    rows.innerHTML = '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="6">{{ __('Unable to load users.') }}</td></tr>';
                    listStatus.textContent = '{{ __('Load failed.') }}';
                    console.error(error);
                }
            }

            var debounceTimer = null;
            searchInput.addEventListener('input', function () {
                clearTimeout(debounceTimer);
                debounceTimer = setTimeout(loadUsers, 250);
            });
            roleFilter.addEventListener('change', loadUsers);
            if (cancelButton) cancelButton.addEventListener('click', resetForm);

            if (form) form.addEventListener('submit', async function (event) {
                event.preventDefault();

                try {
                    submitButton.disabled = true;
                    formStatus.textContent = '{{ __('Saving...') }}';
                    await window.adminApi.ensureCsrfCookie();

                    var isEdit = !!idField.value;
                    var body = {
                        first_name: firstNameField.value.trim(),
                        last_name: lastNameField.value.trim(),
                        email: emailField.value.trim(),
                        phone: phoneField.value.trim()
                    };
                    if (roleField.value || !isEdit) {
                        body.role_id = roleField.value ? parseInt(roleField.value, 10) : null;
                    }
                    if (!isEdit || passwordField.value) {
                        body.password = passwordField.value;
                    }

                    var response = await window.adminApi.request(isEdit ? '/api/admin/users/' + idField.value : '/api/admin/users', {
                        method: isEdit ? 'PUT' : 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify(body)
                    });

                    if (!response.ok) {
                        submitButton.disabled = false;
                        formStatus.textContent = await readErrorMessage(response, '{{ __('Unable to save account.') }}');
                        return;
                    }

                    resetForm();
                    submitButton.disabled = false;
                    formStatus.textContent = '{{ __('Account saved.') }}';
                    await loadUsers();
                } catch (error) {
                    submitButton.disabled = false;
                    formStatus.textContent = '{{ __('Unable to save account.') }}';
                    console.error(error);
                }
            });

            await loadRoles();
            await loadUsers();
        });
    </script>
@endsection
