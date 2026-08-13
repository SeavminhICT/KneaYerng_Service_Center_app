@extends('layouts.admin')

@section('title', 'Technicians')
@section('page-title', 'Technicians')

@section('content')
    <div class="space-y-6">
        <div class="flex flex-wrap items-center justify-between gap-4">
            <div>
                <h2 class="text-lg font-semibold text-slate-900 dark:text-white">{{ __('Technician Management') }}</h2>
                <p class="text-sm text-slate-500">{{ __('Track workloads, skills, and assignment availability. Every technician gets a linked login account to sign into the mobile app and receive jobs assigned by admin or sales.') }}</p>
            </div>
        </div>

        <div class="grid gap-6 lg:grid-cols-[2fr_1fr]">
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <div class="flex flex-wrap items-center justify-between gap-3">
                    <input id="technician-search" type="text" placeholder="{{ __('Search technicians') }}" class="h-10 w-60 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    <select id="technician-status-filter" class="h-10 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300">
                        <option>{{ __('All statuses') }}</option>
                        <option>{{ __('Available') }}</option>
                        <option>{{ __('Busy') }}</option>
                        <option>{{ __('Off') }}</option>
                    </select>
                </div>

                <div class="mt-5 overflow-x-auto">
                    <table class="w-full text-left text-sm">
                        <thead class="text-xs uppercase tracking-widest text-slate-400">
                            <tr>
                                <th class="px-4 py-3">{{ __('Name') }}</th>
                                <th class="px-4 py-3">{{ __('Login') }}</th>
                                <th class="px-4 py-3">{{ __('Skills') }}</th>
                                <th class="px-4 py-3">{{ __('Active jobs') }}</th>
                                <th class="px-4 py-3">{{ __('Status') }}</th>
                            </tr>
                        </thead>
                        <tbody id="technician-rows" class="divide-y divide-slate-200 text-slate-600 dark:divide-slate-800 dark:text-slate-300"></tbody>
                    </table>
                </div>
            </div>

            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <h3 class="text-sm font-semibold text-slate-900 dark:text-white">{{ __('Add technician') }}</h3>
                <form id="technician-form" class="mt-4 space-y-3 text-sm text-slate-600 dark:text-slate-300">
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-widest text-slate-400" for="technician-name">{{ __('Name') }}</label>
                        <input id="technician-name" type="text" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    </div>
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-widest text-slate-400" for="technician-skills">{{ __('Skill set (comma separated)') }}</label>
                        <input id="technician-skills" type="text" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    </div>
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-widest text-slate-400" for="technician-email">{{ __('Email (login username)') }}</label>
                        <input id="technician-email" type="email" placeholder="{{ __('e.g. tech@example.com') }}" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    </div>
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-widest text-slate-400" for="technician-password">{{ __('Password') }}</label>
                        <input id="technician-password" type="password" placeholder="{{ __('Min. 8 characters') }}" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                        <p class="mt-1 text-[11px] text-slate-400">{{ __('The technician signs into the mobile app with this email/phone and password to receive jobs assigned by admin or sales.') }}</p>
                    </div>
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-widest text-slate-400" for="technician-phone">{{ __('Phone (optional)') }}</label>
                        <input id="technician-phone" type="text" placeholder="{{ __('e.g. 012345678') }}" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    </div>
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-widest text-slate-400" for="technician-status">{{ __('Availability') }}</label>
                        <select id="technician-status" class="mt-2 h-10 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300">
                            <option value="available">{{ __('Available') }}</option>
                            <option value="busy">{{ __('Busy') }}</option>
                            <option value="off">{{ __('Off') }}</option>
                        </select>
                    </div>
                    <button class="inline-flex h-10 w-full items-center justify-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white" type="submit">{{ __('Create technician') }}</button>
                    <p id="technician-form-status" class="text-xs text-slate-500"></p>
                </form>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var searchInput = document.getElementById('technician-search');
            var statusFilter = document.getElementById('technician-status-filter');
            var rows = document.getElementById('technician-rows');

            function normalize(value) {
                return (value || '').toLowerCase().trim();
            }

            async function loadTechnicians() {
                await window.adminApi.ensureCsrfCookie();
                var query = new URLSearchParams();
                if (searchInput.value.trim()) {
                    query.set('q', searchInput.value.trim());
                }
                if (normalize(statusFilter.value) && normalize(statusFilter.value) !== 'all statuses') {
                    query.set('availability_status', normalize(statusFilter.value));
                }

                var response = await window.adminApi.request('/api/technicians?' + query.toString());
                if (!response.ok) {
                    rows.innerHTML = '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="5">{{ __('Unable to load technicians.') }}</td></tr>';
                    return;
                }
                var data = await response.json();
                var list = data.data || [];

                rows.innerHTML = list.map(function (tech) {
                    var skills = Array.isArray(tech.skill_set) ? tech.skill_set.join(', ') : '';
                    var login = tech.has_login
                        ? (tech.email || tech.phone || '{{ __('Linked') }}')
                        : '<span class="text-amber-500">{{ __('No login') }}</span>';
                    return `
                        <tr>
                            <td class="px-4 py-3 font-semibold text-slate-900 dark:text-white">${tech.name}</td>
                            <td class="px-4 py-3">${login}</td>
                            <td class="px-4 py-3">${skills || '-'}</td>
                            <td class="px-4 py-3">${tech.active_jobs_count}</td>
                            <td class="px-4 py-3">${tech.availability_status}</td>
                        </tr>
                    `;
                }).join('') || '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="5">{{ __('No technicians found.') }}</td></tr>';
            }

            document.getElementById('technician-form').addEventListener('submit', async function (event) {
                event.preventDefault();
                var statusEl = document.getElementById('technician-form-status');
                var name = document.getElementById('technician-name').value.trim();
                var email = document.getElementById('technician-email').value.trim();
                var password = document.getElementById('technician-password').value;
                if (!name || !email || !password) {
                    statusEl.textContent = '{{ __('Name, email, and password are required.') }}';
                    return;
                }
                var payload = {
                    name: name,
                    skill_set: document.getElementById('technician-skills').value.split(',').map(function (item) { return item.trim(); }).filter(Boolean),
                    availability_status: document.getElementById('technician-status').value,
                    email: email,
                    password: password,
                    phone: document.getElementById('technician-phone').value.trim() || null
                };
                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/technicians', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(payload)
                });
                if (response.ok) {
                    statusEl.textContent = '{{ __('Technician created.') }}';
                    document.getElementById('technician-name').value = '';
                    document.getElementById('technician-skills').value = '';
                    document.getElementById('technician-email').value = '';
                    document.getElementById('technician-password').value = '';
                    document.getElementById('technician-phone').value = '';
                } else {
                    var errorMessage = '{{ __('Unable to create.') }}';
                    try {
                        var errorData = await response.json();
                        var firstError = errorData.errors && Object.values(errorData.errors)[0];
                        if (firstError && firstError[0]) {
                            errorMessage = firstError[0];
                        } else if (errorData.message) {
                            errorMessage = errorData.message;
                        }
                    } catch (e) {}
                    statusEl.textContent = errorMessage;
                }
                loadTechnicians();
            });

            searchInput.addEventListener('input', loadTechnicians);
            statusFilter.addEventListener('change', loadTechnicians);
            loadTechnicians();
        });
    </script>
@endsection
