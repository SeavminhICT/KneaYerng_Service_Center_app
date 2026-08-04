@extends('layouts.admin')

@section('title', __('Repair Problems'))
@section('page-title', __('Repair Problems'))

@section('content')
    <div class="space-y-6">
        <div>
            <h2 class="text-lg font-semibold text-slate-900 dark:text-white">{{ __('Repair Problem Catalog') }}</h2>
            <p class="text-sm text-slate-500">{{ __('Manage the tick-box problem list Sale Staff use when creating a repair job.') }}</p>
        </div>

        <div class="grid gap-6 lg:grid-cols-[2fr_1fr]">
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <div class="overflow-x-auto">
                    <table class="w-full text-left text-sm">
                        <thead class="text-xs uppercase tracking-widest text-slate-400">
                            <tr>
                                <th class="px-4 py-3">{{ __('Problem') }}</th>
                                <th class="px-4 py-3">{{ __('Status') }}</th>
                                <th class="px-4 py-3 text-right">{{ __('Actions') }}</th>
                            </tr>
                        </thead>
                        <tbody id="problem-rows" class="divide-y divide-slate-200 text-slate-600 dark:divide-slate-800 dark:text-slate-300"></tbody>
                    </table>
                </div>
            </div>

            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <h3 class="text-sm font-semibold text-slate-900 dark:text-white">{{ __('Add problem') }}</h3>
                <form id="problem-form" class="mt-4 space-y-3 text-sm text-slate-600 dark:text-slate-300">
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-widest text-slate-400" for="problem-name">{{ __('Problem name') }}</label>
                        <input id="problem-name" type="text" placeholder="{{ __('e.g. Screen broken') }}" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    </div>
                    <button class="inline-flex h-10 w-full items-center justify-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white" type="submit">{{ __('Add problem') }}</button>
                    <p id="problem-form-status" class="text-xs text-slate-500"></p>
                </form>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var rows = document.getElementById('problem-rows');

            async function loadProblems() {
                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/repair-problems?per_page=200&status=');
                if (!response.ok) {
                    rows.innerHTML = '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="3">{{ __('Unable to load repair problems.') }}</td></tr>';
                    return;
                }
                var data = await response.json();
                var list = data.data || [];
                rows.innerHTML = list.map(function (problem) {
                    return '<tr>' +
                        '<td class="px-4 py-3 font-semibold text-slate-900 dark:text-white">' + problem.name + '</td>' +
                        '<td class="px-4 py-3">' + problem.status + '</td>' +
                        '<td class="px-4 py-3 text-right">' +
                            '<button data-id="' + problem.id + '" class="problem-delete text-xs font-semibold text-rose-600">{{ __('Delete') }}</button>' +
                        '</td>' +
                        '</tr>';
                }).join('') || '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="3">{{ __('No repair problems yet.') }}</td></tr>';

                rows.querySelectorAll('.problem-delete').forEach(function (button) {
                    button.addEventListener('click', async function () {
                        if (!confirm('{{ __('Delete this problem?') }}')) return;
                        await window.adminApi.ensureCsrfCookie();
                        await window.adminApi.request('/api/repair-problems/' + button.dataset.id, { method: 'DELETE' });
                        loadProblems();
                    });
                });
            }

            document.getElementById('problem-form').addEventListener('submit', async function (event) {
                event.preventDefault();
                var name = document.getElementById('problem-name').value.trim();
                if (!name) return;

                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/repair-problems', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ name: name })
                });
                document.getElementById('problem-form-status').textContent = response.ok ? '{{ __('Problem added.') }}' : '{{ __('Unable to add.') }}';
                if (response.ok) {
                    document.getElementById('problem-name').value = '';
                }
                loadProblems();
            });

            loadProblems();
        });
    </script>
@endsection
