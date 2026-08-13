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
                                <th class="px-4 py-3">{{ __('Service Fee') }}</th>
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
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-widest text-slate-400" for="problem-service-fee">{{ __('Service fee') }}</label>
                        <input id="problem-service-fee" type="number" step="0.01" min="0" placeholder="10.00" required class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
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
            var status = document.getElementById('problem-form-status');

            function formatCurrency(value) {
                return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(Number(value || 0));
            }

            function escapeHtml(value) {
                return String(value ?? '').replace(/[&<>"']/g, function (char) {
                    return {
                        '&': '&amp;',
                        '<': '&lt;',
                        '>': '&gt;',
                        '"': '&quot;',
                        "'": '&#039;'
                    }[char];
                });
            }

            async function loadProblems() {
                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/repair-problems?per_page=200&status=');
                if (!response.ok) {
                    rows.innerHTML = '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="4">{{ __('Unable to load repair problems.') }}</td></tr>';
                    return;
                }
                var data = await response.json();
                var list = data.data || [];
                rows.innerHTML = list.map(function (problem) {
                    var fee = Number(problem.service_fee || 0);
                    return '<tr>' +
                        '<td class="px-4 py-3 font-semibold text-slate-900 dark:text-white">' + escapeHtml(problem.name) + '</td>' +
                        '<td class="px-4 py-3">' +
                            '<div class="flex items-center gap-2">' +
                                '<input data-id="' + problem.id + '" type="number" step="0.01" min="0" value="' + fee.toFixed(2) + '" class="problem-fee h-9 w-28 rounded-lg border border-slate-200 bg-slate-50 px-2 text-xs text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />' +
                                '<span class="text-xs text-slate-400">' + formatCurrency(fee) + '</span>' +
                            '</div>' +
                        '</td>' +
                        '<td class="px-4 py-3">' + escapeHtml(problem.status) + '</td>' +
                        '<td class="px-4 py-3 text-right">' +
                            '<button data-id="' + problem.id + '" class="problem-save mr-3 text-xs font-semibold text-primary-600">{{ __('Save Fee') }}</button>' +
                            '<button data-id="' + problem.id + '" class="problem-delete text-xs font-semibold text-rose-600">{{ __('Delete') }}</button>' +
                        '</td>' +
                        '</tr>';
                }).join('') || '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="4">{{ __('No repair problems yet.') }}</td></tr>';

                rows.querySelectorAll('.problem-save').forEach(function (button) {
                    button.addEventListener('click', async function () {
                        var input = rows.querySelector('.problem-fee[data-id="' + button.dataset.id + '"]');
                        var fee = Number(input ? input.value : NaN);
                        if (!Number.isFinite(fee) || fee < 0) {
                            status.textContent = '{{ __('Enter a valid service fee.') }}';
                            return;
                        }
                        await window.adminApi.ensureCsrfCookie();
                        var response = await window.adminApi.request('/api/repair-problems/' + button.dataset.id, {
                            method: 'PATCH',
                            headers: { 'Content-Type': 'application/json' },
                            body: JSON.stringify({ service_fee: fee })
                        });
                        status.textContent = response.ok ? '{{ __('Service fee saved.') }}' : '{{ __('Unable to save fee.') }}';
                        loadProblems();
                    });
                });

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
                var feeInput = document.getElementById('problem-service-fee');
                var fee = Number(feeInput.value);
                if (!name) {
                    status.textContent = '{{ __('Problem name is required.') }}';
                    return;
                }
                if (feeInput.value === '' || !Number.isFinite(fee) || fee < 0) {
                    status.textContent = '{{ __('Service fee is required.') }}';
                    return;
                }

                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/repair-problems', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ name: name, service_fee: fee })
                });
                status.textContent = response.ok ? '{{ __('Problem added.') }}' : '{{ __('Unable to add.') }}';
                if (response.ok) {
                    document.getElementById('problem-name').value = '';
                    feeInput.value = '';
                }
                loadProblems();
            });

            loadProblems();
        });
    </script>
@endsection
