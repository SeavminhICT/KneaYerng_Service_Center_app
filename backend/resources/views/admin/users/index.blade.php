@extends('layouts.admin')

@section('title', 'User Management')
@section('page-title', 'User Management')

@section('content')
    <div class="space-y-6">
        <div>
            <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Users</h2>
            <p class="text-sm text-slate-500">Create staff accounts for delivery assignment and manage access roles.</p>
        </div>

        <div class="grid gap-6 xl:grid-cols-[1.5fr_1fr]">
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <div class="flex flex-wrap items-center justify-between gap-3">
                    <div class="relative">
                        <input id="user-search" type="text" placeholder="Search staff" class="h-10 w-60 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                        <svg class="absolute right-3 top-3 h-4 w-4 text-slate-400" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-4.35-4.35m1.6-5.15a7 7 0 11-14 0 7 7 0 0114 0z" />
                        </svg>
                    </div>
                    <select id="user-role-filter" class="h-10 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300">
                        <option value="">All roles</option>
                        <option value="staff">Staff</option>
                        <option value="technician">Technician</option>
                    </select>
                </div>

                <div class="mt-5 overflow-x-auto">
                    <table class="w-full text-left text-sm">
                        <thead class="text-xs uppercase tracking-widest text-slate-400">
                            <tr>
                                <th class="px-4 py-3">Name</th>
                                <th class="px-4 py-3">Email</th>
                                <th class="px-4 py-3">Role</th>
                                <th class="px-4 py-3">Phone</th>
                                <th class="px-4 py-3">Status</th>
                            </tr>
                        </thead>
                        <tbody id="user-rows" class="divide-y divide-slate-200 text-slate-600 dark:divide-slate-800 dark:text-slate-300">
                            <tr>
                                <td class="px-4 py-6 text-center text-sm text-slate-500" colspan="5">Loading users...</td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <p id="user-list-status" class="mt-4 text-xs text-slate-500"></p>
            </div>

            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <h3 class="text-sm font-semibold text-slate-900 dark:text-white">Create Staff Account</h3>
                <form id="user-form" class="mt-4 space-y-3 text-sm text-slate-600 dark:text-slate-300">
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-widest text-slate-400" for="user-first-name">First name</label>
                        <input id="user-first-name" type="text" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    </div>
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-widest text-slate-400" for="user-last-name">Last name</label>
                        <input id="user-last-name" type="text" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    </div>
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-widest text-slate-400" for="user-email">Email</label>
                        <input id="user-email" type="email" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    </div>
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-widest text-slate-400" for="user-phone">Phone</label>
                        <input id="user-phone" type="text" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    </div>
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-widest text-slate-400" for="user-role">Role</label>
                        <select id="user-role" class="mt-2 h-10 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300">
                            <option value="staff">Staff</option>
                            <option value="technician">Technician</option>
                        </select>
                    </div>
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-widest text-slate-400" for="user-password">Password</label>
                        <input id="user-password" type="password" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                        <p class="mt-2 text-xs text-slate-500">Minimum 8 characters.</p>
                    </div>
                    <button id="user-submit" class="inline-flex h-10 w-full items-center justify-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white" type="submit">Create account</button>
                    <p id="user-form-status" class="text-xs text-slate-500"></p>
                </form>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', async function () {
            var searchInput = document.getElementById('user-search');
            var roleFilter = document.getElementById('user-role-filter');
            var rows = document.getElementById('user-rows');
            var listStatus = document.getElementById('user-list-status');
            var form = document.getElementById('user-form');
            var submitButton = document.getElementById('user-submit');
            var formStatus = document.getElementById('user-form-status');

            var readErrorMessage = async function (response, fallback) {
                var defaultMessage = fallback || 'Request failed.';

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

            var formatRole = function (role) {
                if (!role) {
                    return '--';
                }

                return String(role)
                    .split('_')
                    .map(function (part) {
                        return part.charAt(0).toUpperCase() + part.slice(1);
                    })
                    .join(' ');
            };

            async function loadUsers() {
                rows.innerHTML = '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="5">Loading users...</td></tr>';
                listStatus.textContent = '';

                try {
                    await window.adminApi.ensureCsrfCookie();
                    var query = new URLSearchParams();
                    if (searchInput.value.trim()) {
                        query.set('q', searchInput.value.trim());
                    }
                    if (roleFilter.value) {
                        query.set('role', roleFilter.value);
                    }

                    var response = await window.adminApi.request('/api/admin/users?' + query.toString());
                    if (!response.ok) {
                        rows.innerHTML = '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="5">Unable to load users.</td></tr>';
                        listStatus.textContent = 'Load failed.';
                        return;
                    }

                    var payload = await response.json();
                    var items = Array.isArray(payload.data) ? payload.data : [];
                    rows.innerHTML = items.map(function (user) {
                        return `
                            <tr>
                                <td class="px-4 py-3 font-semibold text-slate-900 dark:text-white">${user.name || '--'}</td>
                                <td class="px-4 py-3">${user.email || '--'}</td>
                                <td class="px-4 py-3">${formatRole(user.role)}</td>
                                <td class="px-4 py-3">${user.phone || '--'}</td>
                                <td class="px-4 py-3">${user.status || 'active'}</td>
                            </tr>
                        `;
                    }).join('') || '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="5">No staff users found.</td></tr>';

                    if (payload.meta && typeof payload.meta.total !== 'undefined') {
                        listStatus.textContent = payload.meta.total + ' staff account(s)';
                    }
                } catch (error) {
                    rows.innerHTML = '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="5">Unable to load users.</td></tr>';
                    listStatus.textContent = 'Load failed.';
                    console.error(error);
                }
            }

            var debounceTimer = null;
            searchInput.addEventListener('input', function () {
                clearTimeout(debounceTimer);
                debounceTimer = setTimeout(loadUsers, 250);
            });
            roleFilter.addEventListener('change', loadUsers);

            form.addEventListener('submit', async function (event) {
                event.preventDefault();

                try {
                    submitButton.disabled = true;
                    formStatus.textContent = 'Creating...';
                    await window.adminApi.ensureCsrfCookie();

                    var response = await window.adminApi.request('/api/admin/users', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({
                            first_name: document.getElementById('user-first-name').value.trim(),
                            last_name: document.getElementById('user-last-name').value.trim(),
                            email: document.getElementById('user-email').value.trim(),
                            phone: document.getElementById('user-phone').value.trim(),
                            role: document.getElementById('user-role').value,
                            password: document.getElementById('user-password').value
                        })
                    });

                    if (!response.ok) {
                        submitButton.disabled = false;
                        formStatus.textContent = await readErrorMessage(response, 'Unable to create account.');
                        return;
                    }

                    form.reset();
                    submitButton.disabled = false;
                    formStatus.textContent = 'Account created.';
                    await loadUsers();
                } catch (error) {
                    submitButton.disabled = false;
                    formStatus.textContent = 'Unable to create account.';
                    console.error(error);
                }
            });

            await loadUsers();
        });
    </script>
@endsection
