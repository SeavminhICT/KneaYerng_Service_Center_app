@extends('layouts.admin')

@section('title', __('New Repair Job'))
@section('page-title', __('New Repair Job'))

@section('content')
    <div class="grid gap-6 lg:grid-cols-[2fr_1fr]">
        <form id="repair-create-form" class="space-y-6 rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <div>
                <h2 class="text-lg font-semibold text-slate-900 dark:text-white">{{ __('Customer') }}</h2>
                <p class="text-sm text-slate-500">{{ __('Search for an existing customer, or create a new one for a walk-in.') }}</p>
            </div>

            <div id="customer-picker">
                <input id="customer-search" type="text" placeholder="{{ __('Search by name, email, or phone') }}" class="w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                <div id="customer-results" class="mt-2 max-h-48 space-y-1 overflow-y-auto"></div>
                <div id="customer-selected" class="mt-3 hidden rounded-xl border border-primary-200 bg-primary-50 px-3 py-2 text-sm text-primary-800 dark:border-primary-500/30 dark:bg-primary-500/10 dark:text-primary-100">
                    <span id="customer-selected-label"></span>
                    <button type="button" id="customer-clear" class="ml-2 text-xs font-semibold underline">{{ __('Change') }}</button>
                </div>
                <button type="button" id="customer-new-toggle" class="mt-2 text-xs font-semibold text-primary-600">{{ __('+ New customer') }}</button>
            </div>

            <div id="customer-new-form" class="hidden grid gap-4 rounded-xl border border-slate-200 bg-slate-50 p-4 sm:grid-cols-2 dark:border-slate-800 dark:bg-slate-950">
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="new_first_name">{{ __('First name') }}</label>
                    <input id="new_first_name" type="text" class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-200" />
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="new_last_name">{{ __('Last name') }}</label>
                    <input id="new_last_name" type="text" class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-200" />
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="new_phone">{{ __('Phone') }}</label>
                    <input id="new_phone" type="text" class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-200" />
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="new_email">{{ __('Email (optional)') }}</label>
                    <input id="new_email" type="email" class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-200" />
                </div>
                <div class="sm:col-span-2">
                    <button type="button" id="customer-new-save" class="inline-flex h-9 items-center rounded-xl bg-primary-600 px-4 text-xs font-semibold text-white">{{ __('Create customer') }}</button>
                    <span id="customer-new-status" class="ml-2 text-xs text-slate-500"></span>
                    <p class="mt-2 text-xs text-slate-500">{{ __('The customer can set a password later using "Forgot password" with their phone or email.') }}</p>
                </div>
            </div>

            <div class="border-t border-slate-200 pt-6 dark:border-slate-800">
                <h2 class="text-lg font-semibold text-slate-900 dark:text-white">{{ __('Device & Issue') }}</h2>
            </div>

            <div class="grid gap-4 sm:grid-cols-2">
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="device_model">{{ __('Device model') }}</label>
                    <input id="device_model" type="text" placeholder="{{ __('iPhone 14 Pro Max') }}" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="issue_type">{{ __('Issue') }}</label>
                    <input id="issue_type" type="text" placeholder="{{ __('Face ID not working') }}" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="service_type">{{ __('Service type') }}</label>
                    <select id="service_type" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                        <option value="drop_off">{{ __('Drop Off') }}</option>
                        <option value="pickup">{{ __('Pickup') }}</option>
                        <option value="on_site">{{ __('On Site') }}</option>
                    </select>
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="appointment_datetime">{{ __('Appointment (optional)') }}</label>
                    <input id="appointment_datetime" type="datetime-local" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>
            </div>

            <div class="flex items-center gap-3">
                <button id="repair-create-submit" class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white shadow-sm">{{ __('Create Repair Job') }}</button>
                <a href="{{ route('admin.repairs.index') }}" class="text-sm font-semibold text-slate-500">{{ __('Cancel') }}</a>
            </div>
            <p id="repair-create-error" class="text-sm text-danger-600"></p>
        </form>

        <div class="space-y-6">
            <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <h3 class="text-sm font-semibold text-slate-900 dark:text-white">{{ __('Tips') }}</h3>
                <ul class="mt-3 space-y-2 text-xs text-slate-500">
                    <li>{{ __('Search first — most walk-ins already have an account from a prior order.') }}</li>
                    <li>{{ __('You can assign a technician and log intake details from the repair detail page after creating the job.') }}</li>
                </ul>
            </div>
        </div>
    </div>

    <script>
        (function () {
            var selectedCustomerId = null;
            var searchInput = document.getElementById('customer-search');
            var resultsBox = document.getElementById('customer-results');
            var selectedBox = document.getElementById('customer-selected');
            var selectedLabel = document.getElementById('customer-selected-label');

            function selectCustomer(customer) {
                selectedCustomerId = customer.id;
                selectedLabel.textContent = customer.name + (customer.phone ? ' · ' + customer.phone : '') + (customer.email ? ' · ' + customer.email : '');
                selectedBox.classList.remove('hidden');
                document.getElementById('customer-picker').querySelector('#customer-search').classList.add('hidden');
                resultsBox.innerHTML = '';
                searchInput.value = '';
            }

            document.getElementById('customer-clear').addEventListener('click', function () {
                selectedCustomerId = null;
                selectedBox.classList.add('hidden');
                searchInput.classList.remove('hidden');
            });

            var searchTimer = null;
            searchInput.addEventListener('input', function () {
                clearTimeout(searchTimer);
                var q = searchInput.value.trim();
                if (q.length < 2) {
                    resultsBox.innerHTML = '';
                    return;
                }
                searchTimer = setTimeout(async function () {
                    var response = await window.adminApi.request('/api/admin/customers/search?q=' + encodeURIComponent(q));
                    if (!response.ok) {
                        return;
                    }
                    var data = await response.json();
                    var list = data.data || [];
                    resultsBox.innerHTML = list.map(function (customer, index) {
                        return '<button type="button" data-index="' + index + '" class="customer-result-item block w-full rounded-lg border border-slate-200 bg-white px-3 py-2 text-left text-sm text-slate-700 hover:bg-slate-50 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-200">' +
                            customer.name + (customer.phone ? ' · ' + customer.phone : '') + (customer.email ? ' · ' + customer.email : '') +
                            '</button>';
                    }).join('') || '<p class="px-1 text-xs text-slate-500">{{ __('No customers found.') }}</p>';

                    resultsBox.querySelectorAll('.customer-result-item').forEach(function (button) {
                        button.addEventListener('click', function () {
                            selectCustomer(list[Number(button.dataset.index)]);
                        });
                    });
                }, 300);
            });

            document.getElementById('customer-new-toggle').addEventListener('click', function () {
                document.getElementById('customer-new-form').classList.toggle('hidden');
            });

            document.getElementById('customer-new-save').addEventListener('click', async function () {
                var firstName = document.getElementById('new_first_name').value.trim();
                var statusEl = document.getElementById('customer-new-status');
                if (!firstName) {
                    statusEl.textContent = '{{ __('First name is required.') }}';
                    return;
                }
                var payload = {
                    first_name: firstName,
                    last_name: document.getElementById('new_last_name').value.trim(),
                    phone: document.getElementById('new_phone').value.trim() || null,
                    email: document.getElementById('new_email').value.trim() || null,
                };
                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/admin/customers', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(payload)
                });
                if (!response.ok) {
                    var errorData = await response.json().catch(function () { return {}; });
                    statusEl.textContent = errorData.message || '{{ __('Unable to create customer.') }}';
                    return;
                }
                var data = await response.json();
                selectCustomer(data.data);
                document.getElementById('customer-new-form').classList.add('hidden');
                statusEl.textContent = '';
            });

            document.getElementById('repair-create-submit').addEventListener('click', async function (event) {
                event.preventDefault();
                var errorEl = document.getElementById('repair-create-error');
                errorEl.textContent = '';

                if (!selectedCustomerId) {
                    errorEl.textContent = '{{ __('Select or create a customer first.') }}';
                    return;
                }
                var deviceModel = document.getElementById('device_model').value.trim();
                var issueType = document.getElementById('issue_type').value.trim();
                if (!deviceModel || !issueType) {
                    errorEl.textContent = '{{ __('Device model and issue are required.') }}';
                    return;
                }

                var payload = {
                    customer_id: selectedCustomerId,
                    device_model: deviceModel,
                    issue_type: issueType,
                    service_type: document.getElementById('service_type').value,
                    appointment_datetime: document.getElementById('appointment_datetime').value || null,
                };

                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/repairs', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(payload)
                });

                if (!response.ok) {
                    var errorData = await response.json().catch(function () { return {}; });
                    errorEl.textContent = errorData.message || '{{ __('Unable to create repair job.') }}';
                    return;
                }

                var data = await response.json();
                var repair = data.data || data;
                window.location.href = '/admin/repairs/' + repair.id;
            });
        })();
    </script>
@endsection
