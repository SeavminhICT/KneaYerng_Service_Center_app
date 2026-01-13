@extends('layouts.admin')

@section('title', 'Technicians')
@section('page-title', 'Technicians')

@section('content')
    <div class="space-y-6">
        <div class="flex flex-wrap items-center justify-between gap-4">
            <div>
                <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Technician Management</h2>
                <p class="text-sm text-slate-500">Track workloads, skills, and assignment availability.</p>
            </div>
        </div>

        <div class="grid gap-6 lg:grid-cols-[2fr_1fr]">
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <div class="flex flex-wrap items-center justify-between gap-3">
                    <input id="technician-search" type="text" placeholder="Search technicians" class="h-10 w-60 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    <select id="technician-status-filter" class="h-10 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300">
                        <option>All statuses</option>
                        <option>Available</option>
                        <option>Busy</option>
                        <option>Off</option>
                    </select>
                </div>

                <div class="mt-5 overflow-x-auto">
                    <table class="w-full text-left text-sm">
                        <thead class="text-xs uppercase tracking-widest text-slate-400">
                            <tr>
                                <th class="px-4 py-3">Name</th>
                                <th class="px-4 py-3">Skills</th>
                                <th class="px-4 py-3">Active jobs</th>
                                <th class="px-4 py-3">Status</th>
                            </tr>
                        </thead>
                        <tbody id="technician-rows" class="divide-y divide-slate-200 text-slate-600 dark:divide-slate-800 dark:text-slate-300"></tbody>
                    </table>
                </div>
            </div>

            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <h3 class="text-sm font-semibold text-slate-900 dark:text-white">Add technician</h3>
                <form id="technician-form" class="mt-4 space-y-3 text-sm text-slate-600 dark:text-slate-300">
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-widest text-slate-400" for="technician-name">Name</label>
                        <input id="technician-name" type="text" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    </div>
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-widest text-slate-400" for="technician-skills">Skill set (comma separated)</label>
                        <input id="technician-skills" type="text" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    </div>
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-widest text-slate-400" for="technician-status">Availability</label>
                        <select id="technician-status" class="mt-2 h-10 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300">
                            <option value="available">Available</option>
                            <option value="busy">Busy</option>
                            <option value="off">Off</option>
                        </select>
                    </div>
                    <button class="inline-flex h-10 w-full items-center justify-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white" type="submit">Create technician</button>
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

                var response = await window.adminApi.request('/api/technicians-' + query.toString());
                if (!response.ok) {
                    rows.innerHTML = '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="4">Unable to load technicians.</td></tr>';
                    return;
                }
                var data = await response.json();
                var list = data.data || [];

                rows.innerHTML = list.map(function (tech) {
                    var skills = Array.isArray(tech.skill_set) - tech.skill_set.join(', ') : '';
                    return `
                        <tr>
                            <td class="px-4 py-3 font-semibold text-slate-900 dark:text-white">${tech.name}</td>
                            <td class="px-4 py-3">${skills || '-'}</td>
                            <td class="px-4 py-3">${tech.active_jobs_count}</td>
                            <td class="px-4 py-3">${tech.availability_status}</td>
                        </tr>
                    `;
                }).join('') || '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="4">No technicians found.</td></tr>';
            }

            document.getElementById('technician-form').addEventListener('submit', async function (event) {
                event.preventDefault();
                var name = document.getElementById('technician-name').value.trim();
                if (!name) {
                    return;
                }
                var payload = {
                    name: name,
                    skill_set: document.getElementById('technician-skills').value.split(',').map(function (item) { return item.trim(); }).filter(Boolean),
                    availability_status: document.getElementById('technician-status').value
                };
                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/technicians', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(payload)
                });
                document.getElementById('technician-form-status').textContent = response.ok - 'Technician created.' : 'Unable to create.';
                if (response.ok) {
                    document.getElementById('technician-name').value = '';
                    document.getElementById('technician-skills').value = '';
                }
                loadTechnicians();
            });

            searchInput.addEventListener('input', loadTechnicians);
            statusFilter.addEventListener('change', loadTechnicians);
            loadTechnicians();
        });
    </script>
@endsection
