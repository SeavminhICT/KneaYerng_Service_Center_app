@extends('layouts.admin')

@section('title', __('Device Models'))
@section('page-title', __('Device Models'))

@section('content')
    <div class="space-y-6">
        <div>
            <h2 class="text-lg font-semibold text-slate-900 dark:text-white">{{ __('Device Model Catalog') }}</h2>
            <p class="text-sm text-slate-500">{{ __('Manage the brand/model list Sale Staff pick from when creating a repair job.') }}</p>
        </div>

        <div class="grid gap-6 lg:grid-cols-[2fr_1fr]">
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <div class="overflow-x-auto">
                    <table class="w-full text-left text-sm">
                        <thead class="text-xs uppercase tracking-widest text-slate-400">
                            <tr>
                                <th class="px-4 py-3">{{ __('Brand') }}</th>
                                <th class="px-4 py-3">{{ __('Model') }}</th>
                                <th class="px-4 py-3">{{ __('Status') }}</th>
                                <th class="px-4 py-3 text-right">{{ __('Actions') }}</th>
                            </tr>
                        </thead>
                        <tbody id="model-rows" class="divide-y divide-slate-200 text-slate-600 dark:divide-slate-800 dark:text-slate-300"></tbody>
                    </table>
                </div>
            </div>

            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <h3 class="text-sm font-semibold text-slate-900 dark:text-white">{{ __('Add device model') }}</h3>
                <form id="model-form" class="mt-4 space-y-3 text-sm text-slate-600 dark:text-slate-300">
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-widest text-slate-400" for="model-brand">{{ __('Brand') }}</label>
                        <input id="model-brand" type="text" placeholder="{{ __('e.g. Apple') }}" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    </div>
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-widest text-slate-400" for="model-name">{{ __('Model') }}</label>
                        <input id="model-name" type="text" placeholder="{{ __('e.g. iPhone 16 Pro Max') }}" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    </div>
                    <button class="inline-flex h-10 w-full items-center justify-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white" type="submit">{{ __('Add model') }}</button>
                    <p id="model-form-status" class="text-xs text-slate-500"></p>
                </form>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var rows = document.getElementById('model-rows');

            async function loadModels() {
                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/device-models?per_page=200&status=');
                if (!response.ok) {
                    rows.innerHTML = '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="4">{{ __('Unable to load device models.') }}</td></tr>';
                    return;
                }
                var data = await response.json();
                var list = data.data || [];
                rows.innerHTML = list.map(function (model) {
                    return '<tr>' +
                        '<td class="px-4 py-3 font-semibold text-slate-900 dark:text-white">' + model.brand + '</td>' +
                        '<td class="px-4 py-3">' + model.model_name + '</td>' +
                        '<td class="px-4 py-3">' + model.status + '</td>' +
                        '<td class="px-4 py-3 text-right">' +
                            '<button data-id="' + model.id + '" class="model-delete text-xs font-semibold text-rose-600">{{ __('Delete') }}</button>' +
                        '</td>' +
                        '</tr>';
                }).join('') || '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="4">{{ __('No device models yet.') }}</td></tr>';

                rows.querySelectorAll('.model-delete').forEach(function (button) {
                    button.addEventListener('click', async function () {
                        if (!confirm('{{ __('Delete this device model?') }}')) return;
                        await window.adminApi.ensureCsrfCookie();
                        await window.adminApi.request('/api/device-models/' + button.dataset.id, { method: 'DELETE' });
                        loadModels();
                    });
                });
            }

            document.getElementById('model-form').addEventListener('submit', async function (event) {
                event.preventDefault();
                var brand = document.getElementById('model-brand').value.trim();
                var modelName = document.getElementById('model-name').value.trim();
                if (!brand || !modelName) return;

                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/device-models', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ brand: brand, model_name: modelName })
                });
                document.getElementById('model-form-status').textContent = response.ok ? '{{ __('Model added.') }}' : '{{ __('Unable to add.') }}';
                if (response.ok) {
                    document.getElementById('model-brand').value = '';
                    document.getElementById('model-name').value = '';
                }
                loadModels();
            });

            loadModels();
        });
    </script>
@endsection
