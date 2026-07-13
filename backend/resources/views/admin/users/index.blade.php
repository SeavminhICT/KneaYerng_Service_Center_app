@extends('layouts.admin')

@section('title', 'User Management')
@section('page-title', 'User Management')

@section('content')
    <style>
        .user-account-popup {
            border: 1px solid rgba(226, 232, 240, .9) !important;
            border-radius: 24px !important;
            box-shadow: 0 24px 70px -18px rgba(15, 23, 42, .28) !important;
        }
        .user-account-popup .swal2-html-container {
            margin: 0 !important;
            padding: 0 !important;
            overflow: visible !important;
        }
        .user-account-popup .swal2-close {
            top: 18px !important;
            right: 18px !important;
            width: 36px !important;
            height: 36px !important;
            border-radius: 10px !important;
            color: #94a3b8 !important;
            font-size: 26px !important;
            transition: background-color .2s, color .2s;
        }
        .user-account-popup .swal2-close:hover {
            background: #f1f5f9 !important;
            color: #334155 !important;
        }
        .user-account-field {
            width: 100%;
            height: 46px;
            margin: 7px 0 0 !important;
            padding: 0 14px;
            border: 1px solid #dbe3ee;
            border-radius: 12px;
            background: #f8fafc;
            color: #0f172a;
            font-size: 14px;
            outline: none;
            box-shadow: none !important;
            transition: border-color .2s, background-color .2s, box-shadow .2s;
        }
        .user-account-field:hover { border-color: #cbd5e1; }
        .user-account-field:focus {
            border-color: #3b82f6;
            background: #fff;
            box-shadow: 0 0 0 4px rgba(59, 130, 246, .12) !important;
        }
        .user-account-popup .swal2-actions {
            width: 100%;
            margin: 24px 0 0 !important;
            gap: 10px;
        }
        .user-account-popup .swal2-styled {
            min-height: 44px;
            margin: 0 !important;
            padding: 0 18px !important;
            border-radius: 12px !important;
            font-size: 14px !important;
            font-weight: 600 !important;
            box-shadow: none !important;
        }
        .user-account-popup .swal2-confirm {
            background: #2563eb !important;
            box-shadow: 0 8px 20px -8px rgba(37, 99, 235, .7) !important;
        }
        .user-account-popup .swal2-confirm:hover { background: #1d4ed8 !important; }
        .user-account-popup .swal2-cancel {
            border: 1px solid #e2e8f0 !important;
            background: #fff !important;
            color: #475569 !important;
        }
        .user-account-popup .swal2-cancel:hover { background: #f8fafc !important; }
        .user-account-popup .swal2-validation-message {
            margin: 16px 0 0 !important;
            border-radius: 12px;
            font-size: 13px;
        }
        .dark .user-account-popup {
            border-color: #253047 !important;
            background: #0f172a !important;
        }
        .dark .user-account-popup .swal2-close:hover { background: #1e293b !important; color: #e2e8f0 !important; }
        .dark .user-account-field { border-color: #334155; background: #111c30; color: #f8fafc; }
        .dark .user-account-field:focus { border-color: #60a5fa; background: #0f172a; }
        .dark .user-account-popup .swal2-cancel { border-color: #334155 !important; background: #1e293b !important; color: #e2e8f0 !important; }
        @media (max-width: 540px) {
            .user-account-popup { width: calc(100% - 24px) !important; padding: 24px 20px 20px !important; border-radius: 20px !important; }
            .user-account-grid { grid-template-columns: 1fr !important; }
            .user-account-popup .swal2-actions { flex-direction: column-reverse; }
            .user-account-popup .swal2-styled { width: 100%; }
        }
    </style>

    <div class="space-y-6">
        <div class="flex flex-wrap items-center justify-between gap-4">
            <div>
                <h2 class="text-lg font-semibold text-slate-900 dark:text-white">{{ __('User List') }}</h2>
                <p class="text-sm text-slate-500">{{ __('Create accounts that can sign in to the web admin and control what they can do through roles and permissions.') }}</p>
            </div>
            <div class="flex items-center gap-3">
                @if (auth()->user()?->hasPermission('create_user'))
                <button id="user-add-btn" type="button" class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white shadow-sm">{{ __('Add User') }}</button>
                @endif
            </div>
        </div>

        <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <div class="flex flex-wrap items-center justify-between gap-3">
                <select id="user-role-filter" class="h-10 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 sm:w-48 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300">
                    <option value="">{{ __('All roles') }}</option>
                </select>
                <div class="relative">
                    <input id="user-search" type="text" placeholder="{{ __('Search users') }}" class="h-10 w-60 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    <svg class="absolute right-3 top-3 h-4 w-4 text-slate-400" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-4.35-4.35m1.6-5.15a7 7 0 11-14 0 7 7 0 0114 0z" />
                    </svg>
                </div>
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
                            <th class="px-4 py-3 text-right">{{ __('Action') }}</th>
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
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', async function () {
            var addButton = document.getElementById('user-add-btn');
            var searchInput = document.getElementById('user-search');
            var roleFilter = document.getElementById('user-role-filter');
            var rows = document.getElementById('user-rows');
            var listStatus = document.getElementById('user-list-status');

            var usersById = {};
            var rolesCache = [];

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

            async function loadRoles() {
                try {
                    await window.adminApi.ensureCsrfCookie();
                    var response = await window.adminApi.request('/api/roles');
                    if (!response.ok) {
                        return;
                    }
                    var payload = await response.json();
                    rolesCache = Array.isArray(payload.data) ? payload.data : [];
                    var options = rolesCache.map(function (role) {
                        return '<option value="' + role.id + '">' + escapeHtml(role.name) + '</option>';
                    }).join('');

                    roleFilter.innerHTML = '<option value="">{{ __('All roles') }}</option>' + options;
                } catch (error) {
                    console.error(error);
                }
            }

            function roleOptionsHtml(selectedId) {
                return rolesCache.map(function (role) {
                    var selected = String(role.id) === String(selectedId) ? ' selected' : '';
                    return '<option value="' + role.id + '"' + selected + '>' + escapeHtml(role.name) + '</option>';
                }).join('');
            }

            function openUserModal(user) {
                if (!window.Swal) {
                    return;
                }

                var isEdit = !!user;
                var html = `
                    <div class="text-left">
                        <div class="mb-6 flex items-center gap-4 pr-10">
                            <div class="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-blue-50 text-blue-600 dark:bg-blue-500/10 dark:text-blue-400">
                                <svg class="h-6 w-6" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M18 7.5v3m0 0v3m0-3h3m-3 0h-3M11.25 6.375a3.375 3.375 0 11-6.75 0 3.375 3.375 0 016.75 0zM3 19.125v-.75a5.625 5.625 0 0111.25 0v.75c0 .621-.504 1.125-1.125 1.125h-9A1.125 1.125 0 013 19.125z" /></svg>
                            </div>
                            <div>
                                <h3 class="text-xl font-bold tracking-tight text-slate-900 dark:text-white">${isEdit ? '{{ __('Edit User Account') }}' : '{{ __('Create User Account') }}'}</h3>
                                <p class="mt-1 text-sm text-slate-500 dark:text-slate-400">${isEdit ? '{{ __('Update account details and access.') }}' : '{{ __('Add account details and assign a role.') }}'}</p>
                            </div>
                        </div>
                        <div class="user-account-grid grid grid-cols-2 gap-4">
                        <div>
                            <label class="text-xs font-semibold text-slate-600 dark:text-slate-300">{{ __('First name') }}</label>
                            <input id="swal-user-first-name" type="text" class="user-account-field" autocomplete="off" value="${escapeHtml(user && user.first_name)}" />
                        </div>
                        <div>
                            <label class="text-xs font-semibold text-slate-600 dark:text-slate-300">{{ __('Last name') }}</label>
                            <input id="swal-user-last-name" type="text" class="user-account-field" autocomplete="off" value="${escapeHtml(user && user.last_name)}" />
                        </div>
                        <div class="col-span-full">
                            <label class="text-xs font-semibold text-slate-600 dark:text-slate-300">{{ __('Email') }}</label>
                            <input id="swal-user-email" name="new-user-email" type="email" class="user-account-field" autocomplete="off" value="${escapeHtml(user && user.email)}" />
                        </div>
                        <div class="col-span-full">
                            <label class="text-xs font-semibold text-slate-600 dark:text-slate-300">{{ __('Phone') }}</label>
                            <input id="swal-user-phone" type="text" class="user-account-field" autocomplete="off" value="${escapeHtml(user && user.phone)}" />
                        </div>
                        <div>
                            <label class="text-xs font-semibold text-slate-600 dark:text-slate-300">{{ __('Role') }}</label>
                            <select id="swal-user-role" class="user-account-field">
                                <option value="">{{ __('Select a role...') }}</option>
                                ${roleOptionsHtml(user && user.role_id)}
                            </select>
                        </div>
                        <div>
                            <label class="text-xs font-semibold text-slate-600 dark:text-slate-300">{{ __('Password') }}</label>
                            <input id="swal-user-password" name="new-user-password" type="password" class="user-account-field" autocomplete="new-password" />
                            <p class="mt-1 text-xs text-slate-500">${isEdit ? '{{ __('Leave blank to keep the current password.') }}' : '{{ __('Minimum 8 characters.') }}'}</p>
                        </div>
                        </div>
                    </div>
                `;

                window.Swal.fire({
                    html: html,
                    width: 560,
                    padding: '2rem',
                    showCloseButton: true,
                    confirmButtonText: isEdit ? '{{ __('Update account') }}' : '{{ __('Create account') }}',
                    showCancelButton: true,
                    cancelButtonText: '{{ __('Cancel') }}',
                    focusConfirm: false,
                    customClass: {
                        popup: 'user-account-popup'
                    },
                    didOpen: function () {
                        if (isEdit) {
                            return;
                        }

                        window.setTimeout(function () {
                            [
                                'swal-user-first-name',
                                'swal-user-last-name',
                                'swal-user-email',
                                'swal-user-phone',
                                'swal-user-password'
                            ].forEach(function (id) {
                                document.getElementById(id).value = '';
                            });
                            document.getElementById('swal-user-role').value = '';
                        }, 50);
                    },
                    preConfirm: async function () {
                        var body = {
                            first_name: document.getElementById('swal-user-first-name').value.trim(),
                            last_name: document.getElementById('swal-user-last-name').value.trim(),
                            email: document.getElementById('swal-user-email').value.trim(),
                            phone: document.getElementById('swal-user-phone').value.trim(),
                        };
                        var roleValue = document.getElementById('swal-user-role').value;
                        var passwordValue = document.getElementById('swal-user-password').value;

                        if (roleValue || !isEdit) {
                            body.role_id = roleValue ? parseInt(roleValue, 10) : null;
                        }
                        if (!isEdit || passwordValue) {
                            body.password = passwordValue;
                        }

                        try {
                            await window.adminApi.ensureCsrfCookie();
                            var response = await window.adminApi.request(isEdit ? '/api/admin/users/' + user.id : '/api/admin/users', {
                                method: isEdit ? 'PUT' : 'POST',
                                headers: { 'Content-Type': 'application/json' },
                                body: JSON.stringify(body)
                            });

                            if (!response.ok) {
                                window.Swal.showValidationMessage(await readErrorMessage(response, '{{ __('Unable to save account.') }}'));
                                return false;
                            }

                            return true;
                        } catch (error) {
                            window.Swal.showValidationMessage('{{ __('Unable to save account.') }}');
                            return false;
                        }
                    }
                }).then(async function (result) {
                    if (result.isConfirmed) {
                        if (window.adminSwalSuccess) {
                            await window.adminSwalSuccess(isEdit ? '{{ __('Updated') }}' : '{{ __('Created') }}', isEdit ? '{{ __('User account updated.') }}' : '{{ __('User account created.') }}');
                        }
                        await loadUsers();
                    }
                });
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
                            actionButtons += '<button data-edit-id="' + user.id + '" class="user-edit-btn text-xs font-semibold text-primary-600">{{ __('Edit') }}</button>';
                            actionButtons += '<button data-toggle-id="' + user.id + '" data-next-status="' + (isActive ? 'inactive' : 'active') + '" class="user-toggle-btn ml-3 text-xs font-semibold text-slate-500">' + toggleLabel + '</button>';
                        }
                        if (window.adminCan('delete_user')) {
                            actionButtons += '<button data-delete-id="' + user.id + '" class="user-delete-btn ml-3 text-xs font-semibold text-red-600">{{ __('Delete') }}</button>';
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
                            if (user) {
                                openUserModal(user);
                            }
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
                                if (window.adminSwalSuccess) {
                                    await window.adminSwalSuccess('{{ __('Updated') }}', '{{ __('User status updated.') }}');
                                }
                                await loadUsers();
                            } else if (window.adminSwalError) {
                                await window.adminSwalError('{{ __('Update failed') }}', await readErrorMessage(response, '{{ __('Unable to update status.') }}'));
                            } else {
                                alert(await readErrorMessage(response, '{{ __('Unable to update status.') }}'));
                            }
                        });
                    });

                    rows.querySelectorAll('.user-delete-btn').forEach(function (btn) {
                        btn.addEventListener('click', async function () {
                            if (window.adminSwalConfirm) {
                                var result = await window.adminSwalConfirm('{{ __('Delete user?') }}', '{{ __('This will remove the user account permanently.') }}', '{{ __('Yes, delete it') }}');
                                if (!result.isConfirmed) {
                                    return;
                                }
                            } else if (!confirm('{{ __('Delete this user account?') }}')) {
                                return;
                            }
                            await window.adminApi.ensureCsrfCookie();
                            var response = await window.adminApi.request('/api/admin/users/' + btn.dataset.deleteId, { method: 'DELETE' });
                            if (response.ok) {
                                if (window.adminSwalSuccess) {
                                    await window.adminSwalSuccess('{{ __('Deleted') }}', '{{ __('User deleted successfully.') }}');
                                }
                                await loadUsers();
                            } else if (window.adminSwalError) {
                                await window.adminSwalError('{{ __('Delete failed') }}', await readErrorMessage(response, '{{ __('Unable to delete user.') }}'));
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
            if (addButton) addButton.addEventListener('click', function () { openUserModal(null); });

            await loadRoles();
            await loadUsers();
        });
    </script>
@endsection
