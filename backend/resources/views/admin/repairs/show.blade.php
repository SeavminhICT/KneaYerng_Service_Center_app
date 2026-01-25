@extends('layouts.admin')

@section('title', 'Repair Details')
@section('page-title', 'Repair Details')

@section('content')
    <div class="space-y-6">
        <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <div class="flex flex-wrap items-start justify-between gap-4">
                <div>
                    <h2 id="repair-title" class="text-xl font-semibold text-slate-900 dark:text-white">Repair #{{ $repairId }}</h2>
                    <p id="repair-subtitle" class="mt-1 text-sm text-slate-500">Loading repair details...</p>
                </div>
                <div class="flex flex-wrap items-center gap-2">
                    <select id="technician-select" class="h-10 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300"></select>
                    <button id="assign-technician" class="inline-flex h-10 items-center rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-600 shadow-sm hover:text-slate-900 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300">Assign</button>
                    <button id="auto-assign" class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white shadow-sm">Auto assign</button>
                </div>
            </div>
            <div class="mt-5 grid gap-4 lg:grid-cols-3">
                <div class="rounded-2xl border border-slate-200 bg-slate-50 p-4 text-sm text-slate-600 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-300">
                    <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Customer</p>
                    <p id="repair-customer" class="mt-2 font-semibold text-slate-900 dark:text-white">--</p>
                    <p id="repair-contact" class="text-xs text-slate-500">--</p>
                </div>
                <div class="rounded-2xl border border-slate-200 bg-slate-50 p-4 text-sm text-slate-600 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-300">
                    <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Device</p>
                    <p id="repair-device" class="mt-2 font-semibold text-slate-900 dark:text-white">--</p>
                    <p id="repair-issue" class="text-xs text-slate-500">--</p>
                </div>
                <div class="rounded-2xl border border-slate-200 bg-slate-50 p-4 text-sm text-slate-600 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-300">
                    <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Status</p>
                    <div class="mt-2 flex items-center gap-2">
                        <select id="status-select" class="h-9 flex-1 rounded-xl border border-slate-200 bg-white px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300">
                            <option value="received">Received</option>
                            <option value="diagnosing">Diagnosing</option>
                            <option value="waiting_approval">Waiting Approval</option>
                            <option value="in_repair">In Repair</option>
                            <option value="qc">QC</option>
                            <option value="ready">Ready</option>
                            <option value="completed">Completed</option>
                        </select>
                        <button id="status-update" class="inline-flex h-9 items-center rounded-xl bg-primary-600 px-3 text-xs font-semibold text-white">Update</button>
                    </div>
                    <p id="status-help" class="mt-2 text-xs text-slate-500">Keep customers updated as work progresses.</p>
                </div>
            </div>
        </div>

        <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <div class="flex flex-wrap gap-2 border-b border-slate-200 pb-4 text-sm font-semibold text-slate-500 dark:border-slate-800">
                <button class="repair-tab rounded-full bg-primary-50 px-4 py-2 text-primary-700 dark:bg-primary-500/10 dark:text-primary-100" data-tab="intake">Intake</button>
                <button class="repair-tab rounded-full px-4 py-2" data-tab="diagnostic">Diagnostic</button>
                <button class="repair-tab rounded-full px-4 py-2" data-tab="quotation">Quotation</button>
                <button class="repair-tab rounded-full px-4 py-2" data-tab="status">Status</button>
                <button class="repair-tab rounded-full px-4 py-2" data-tab="chat">Chat</button>
            </div>

            <div class="mt-6 space-y-6">
                <div class="repair-panel" data-panel="intake">
                    <form id="intake-form" class="grid gap-4 lg:grid-cols-2">
                        <div>
                            <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="imei_serial">IMEI / Serial</label>
                            <input id="imei_serial" type="text" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                        </div>
                        <div>
                            <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="intake_photos">Intake photos (comma separated)</label>
                            <input id="intake_photos" type="text" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                        </div>
                        <div class="lg:col-span-2">
                            <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="condition_checklist">Condition checklist (comma separated)</label>
                            <textarea id="condition_checklist" rows="3" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200"></textarea>
                        </div>
                        <div class="lg:col-span-2">
                            <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="intake_notes">Notes</label>
                            <textarea id="intake_notes" rows="3" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200"></textarea>
                        </div>
                        <div>
                            <button class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white" type="submit">Save intake</button>
                            <span id="intake-status" class="ml-2 text-xs text-slate-500"></span>
                        </div>
                    </form>
                </div>

                <div class="repair-panel hidden" data-panel="diagnostic">
                    <form id="diagnostic-form" class="grid gap-4 lg:grid-cols-2">
                        <div class="lg:col-span-2">
                            <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="problem_description">Problem description</label>
                            <textarea id="problem_description" rows="3" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200"></textarea>
                        </div>
                        <div>
                            <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="parts_required">Parts required (comma separated)</label>
                            <input id="parts_required" type="text" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                        </div>
                        <div>
                            <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="labor_cost">Labor cost</label>
                            <input id="labor_cost" type="number" step="0.01" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                        </div>
                        <div class="lg:col-span-2">
                            <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="diagnostic_notes">Diagnostic notes</label>
                            <textarea id="diagnostic_notes" rows="3" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200"></textarea>
                        </div>
                        <div>
                            <button class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white" type="submit">Save diagnostic</button>
                            <span id="diagnostic-status" class="ml-2 text-xs text-slate-500"></span>
                        </div>
                    </form>
                </div>

                <div class="repair-panel hidden" data-panel="quotation">
                    <div class="grid gap-6 lg:grid-cols-2">
                        <form id="quotation-form" class="grid gap-4">
                            <div>
                                <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="quotation_parts">Parts cost</label>
                                <input id="quotation_parts" type="number" step="0.01" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                            </div>
                            <div>
                                <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="quotation_labor">Labor cost</label>
                                <input id="quotation_labor" type="number" step="0.01" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                            </div>
                            <div>
                                <button class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white" type="submit">Save quotation</button>
                                <span id="quotation-status" class="ml-2 text-xs text-slate-500"></span>
                            </div>
                            <div class="rounded-2xl border border-slate-200 bg-slate-50 p-4 text-xs text-slate-500 dark:border-slate-800 dark:bg-slate-950">
                                <p class="font-semibold text-slate-700 dark:text-slate-200">Current quote status</p>
                                <p id="quotation-current" class="mt-2">--</p>
                            </div>
                        </form>
                        <div class="rounded-2xl border border-slate-200 bg-slate-50 p-5 text-sm text-slate-600 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-300">
                            <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Invoice</p>
                            <p id="invoice-number" class="mt-3 text-lg font-semibold text-slate-900 dark:text-white">--</p>
                            <p id="invoice-total" class="text-sm text-slate-500">Total: --</p>
                            <div class="mt-4 flex flex-wrap items-center gap-2">
                                <input id="invoice-tax" type="number" step="0.01" placeholder="Tax" class="h-9 w-28 rounded-xl border border-slate-200 bg-white px-3 text-xs text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300" />
                                <button id="generate-invoice" class="inline-flex h-9 items-center rounded-xl bg-primary-600 px-4 text-xs font-semibold text-white">Generate</button>
                                <span id="invoice-status" class="text-xs text-slate-500"></span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="repair-panel hidden" data-panel="status">
                    <div class="grid gap-6 lg:grid-cols-[2fr_1fr]">
                        <div class="space-y-3" id="status-timeline"></div>
                        <div class="rounded-2xl border border-slate-200 bg-slate-50 p-4 text-sm text-slate-600 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-300">
                            <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Status update</p>
                            <div class="mt-3 flex items-center gap-2">
                                <select id="status-select-secondary" class="h-9 flex-1 rounded-xl border border-slate-200 bg-white px-3 text-xs text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300">
                                    <option value="received">Received</option>
                                    <option value="diagnosing">Diagnosing</option>
                                    <option value="waiting_approval">Waiting Approval</option>
                                    <option value="in_repair">In Repair</option>
                                    <option value="qc">QC</option>
                                    <option value="ready">Ready</option>
                                    <option value="completed">Completed</option>
                                </select>
                                <button id="status-update-secondary" class="inline-flex h-9 items-center rounded-xl bg-primary-600 px-3 text-xs font-semibold text-white">Update</button>
                            </div>
                            <p id="status-status" class="mt-2 text-xs text-slate-500"></p>
                        </div>
                    </div>
                </div>

                <div class="repair-panel hidden" data-panel="chat">
                    <div class="grid gap-6 lg:grid-cols-[2fr_1fr]">
                        <div id="chat-messages" class="space-y-4"></div>
                        <form id="chat-form" class="rounded-2xl border border-slate-200 bg-slate-50 p-4 text-sm text-slate-600 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-300">
                            <label class="text-xs font-semibold uppercase tracking-widest text-slate-400">New message</label>
                            <textarea id="chat-message" rows="4" class="mt-3 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-200"></textarea>
                            <button class="mt-3 inline-flex h-9 w-full items-center justify-center rounded-xl bg-primary-600 px-4 text-xs font-semibold text-white" type="submit">Send</button>
                            <p id="chat-status" class="mt-2 text-xs text-slate-500"></p>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var repairId = {{ $repairId }};
            var repairData = null;
            var tabs = document.querySelectorAll('.repair-tab');
            var panels = document.querySelectorAll('.repair-panel');

            function toTitle(value) {
                return (value || '').replace(/_/g, ' ').replace(/\b\w/g, function (char) { return char.toUpperCase(); });
            }

            function parseList(value) {
                return (value || '').split(',').map(function (item) { return item.trim(); }).filter(Boolean);
            }

            function switchTab(target) {
                tabs.forEach(function (tab) {
                    if (tab.dataset.tab === target) {
                        tab.classList.add('bg-primary-50', 'text-primary-700', 'dark:bg-primary-500/10', 'dark:text-primary-100');
                    } else {
                        tab.classList.remove('bg-primary-50', 'text-primary-700', 'dark:bg-primary-500/10', 'dark:text-primary-100');
                    }
                });
                panels.forEach(function (panel) {
                    panel.classList.toggle('hidden', panel.dataset.panel !== target);
                });
            }

            tabs.forEach(function (tab) {
                tab.addEventListener('click', function () {
                    switchTab(tab.dataset.tab);
                });
            });

            async function loadRepair() {
                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/repairs/' + repairId);
                if (!response.ok) {
                    document.getElementById('repair-subtitle').textContent = toTitle(repair.status) + ' - ' + toTitle(repair.service_type || '-');
                    return;
                }
                repairData = await response.json();
                var repair = repairData.data || repairData;

                document.getElementById('repair-title').textContent = 'Repair #' + repair.id;
                document.getElementById('repair-subtitle').textContent = toTitle(repair.status) + ' - ' + toTitle(repair.service_type || '-');
                document.getElementById('repair-customer').textContent = repair.customer ? (repair.customer.name || repair.customer.email || '-') : '-';
                document.getElementById('repair-contact').textContent = repair.customer ? (repair.customer.email || repair.customer.phone || '-') : '-';
                document.getElementById('repair-device').textContent = repair.device_model || '-';
                document.getElementById('repair-issue').textContent = repair.issue_type || '-';
                document.getElementById('status-select').value = repair.status || 'received';
                document.getElementById('status-select-secondary').value = repair.status || 'received';

                if (repair.intake) {
                    document.getElementById('imei_serial').value = repair.intake.imei_serial || '';
                    document.getElementById('condition_checklist').value = (repair.intake.device_condition_checklist || []).join(', ');
                    document.getElementById('intake_photos').value = (repair.intake.intake_photos || []).join(', ');
                    document.getElementById('intake_notes').value = repair.intake.notes || '';
                }

                if (repair.diagnostic) {
                    document.getElementById('problem_description').value = repair.diagnostic.problem_description || '';
                    document.getElementById('parts_required').value = (repair.diagnostic.parts_required || []).join(', ');
                    document.getElementById('labor_cost').value = repair.diagnostic.labor_cost || '';
                    document.getElementById('diagnostic_notes').value = repair.diagnostic.diagnostic_notes || '';
                }

                if (repair.quotation) {
                    document.getElementById('quotation_parts').value = repair.quotation.parts_cost || '';
                    document.getElementById('quotation_labor').value = repair.quotation.labor_cost || '';
                    document.getElementById('quotation-current').textContent = toTitle(repair.quotation.status || 'pending');
                }

                if (repair.invoice) {
                    document.getElementById('invoice-number').textContent = repair.invoice.invoice_number || '--';
                    document.getElementById('invoice-total').textContent = 'Total: ' + new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(repair.invoice.total || 0);
                }
            }

            async function loadTechnicians() {
                var response = await window.adminApi.request('/api/technicians-per_page=100');
                if (!response.ok) {
                    return;
                }
                var data = await response.json();
                var list = data.data || [];
                var select = document.getElementById('technician-select');
                select.innerHTML = '<option value="">Assign technician</option>' + list.map(function (tech) {
                    return '<option value="' + tech.id + '">' + tech.name + '</option>';
                }).join('');
                if (repairData && repairData.data && repairData.data.technician_id) {
                    select.value = repairData.data.technician_id;
                }
            }

            async function loadStatusTimeline() {
                var response = await window.adminApi.request('/api/repairs/' + repairId + '/status-timeline');
                if (!response.ok) {
                    return;
                }
                var data = await response.json();
                var list = data.data || [];
                var container = document.getElementById('status-timeline');
                container.innerHTML = list.map(function (log) {
                    var timestamp = log.logged_at - new Date(log.logged_at).toLocaleString() : '-';
                    return '<div class="rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm text-slate-600 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300">' +
                        '<p class="font-semibold text-slate-900 dark:text-white">' + toTitle(log.status) + '</p>' +
                        '<p class="text-xs text-slate-500">' + timestamp + '</p>' +
                        '</div>';
                }).join('') || '<p class="text-sm text-slate-500">No status updates yet.</p>';
            }

            async function loadChat() {
                var response = await window.adminApi.request('/api/repairs/' + repairId + '/chat');
                if (!response.ok) {
                    return;
                }
                var data = await response.json();
                var list = data.data || [];
                var container = document.getElementById('chat-messages');
                container.innerHTML = list.map(function (message) {
                    var isAdmin = message.sender_type === 'admin';
                    return '<div class="rounded-2xl border border-slate-200 bg-white px-4 py-3 text-sm text-slate-600 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300">' +
                        '<p class="text-xs font-semibold uppercase tracking-widest text-slate-400">' + (isAdmin - 'Admin' : 'Customer') + '</p>' +
                        '<p class="mt-2 text-slate-700 dark:text-slate-200">' + message.message + '</p>' +
                        '<p class="mt-2 text-xs text-slate-500">' + (message.created_at - new Date(message.created_at).toLocaleString() : '') + '</p>' +
                        '</div>';
                }).join('') || '<p class="text-sm text-slate-500">No messages yet.</p>';
            }

            document.getElementById('assign-technician').addEventListener('click', async function () {
                var technicianId = document.getElementById('technician-select').value;
                if (!technicianId) {
                    return;
                }
                await window.adminApi.ensureCsrfCookie();
                await window.adminApi.request('/api/repairs/' + repairId + '/assign-technician', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ technician_id: technicianId })
                });
                loadRepair();
            });

            document.getElementById('auto-assign').addEventListener('click', async function () {
                await window.adminApi.ensureCsrfCookie();
                await window.adminApi.request('/api/repairs/' + repairId + '/auto-assign', { method: 'POST' });
                loadRepair();
            });

            document.getElementById('status-update').addEventListener('click', function () {
                updateStatus(document.getElementById('status-select').value);
            });
            document.getElementById('status-update-secondary').addEventListener('click', function () {
                updateStatus(document.getElementById('status-select-secondary').value);
            });

            async function updateStatus(status) {
                if (!status) {
                    return;
                }
                await window.adminApi.ensureCsrfCookie();
                await window.adminApi.request('/api/repairs/' + repairId + '/status', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ status: status })
                });
                document.getElementById('status-status').textContent = 'Status updated.';
                loadRepair();
                loadStatusTimeline();
            }

            document.getElementById('intake-form').addEventListener('submit', async function (event) {
                event.preventDefault();
                var payload = {
                    imei_serial: document.getElementById('imei_serial').value.trim(),
                    device_condition_checklist: parseList(document.getElementById('condition_checklist').value),
                    intake_photos: parseList(document.getElementById('intake_photos').value),
                    notes: document.getElementById('intake_notes').value.trim()
                };
                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/repairs/' + repairId + '/intake', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(payload)
                });
                document.getElementById('intake-status').textContent = response.ok - 'Saved.' : 'Unable to save.';
                loadRepair();
            });

            document.getElementById('diagnostic-form').addEventListener('submit', async function (event) {
                event.preventDefault();
                var payload = {
                    problem_description: document.getElementById('problem_description').value.trim(),
                    parts_required: parseList(document.getElementById('parts_required').value),
                    labor_cost: document.getElementById('labor_cost').value,
                    diagnostic_notes: document.getElementById('diagnostic_notes').value.trim()
                };
                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/repairs/' + repairId + '/diagnostic', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(payload)
                });
                document.getElementById('diagnostic-status').textContent = response.ok - 'Saved.' : 'Unable to save.';
                loadRepair();
                loadStatusTimeline();
            });

            document.getElementById('quotation-form').addEventListener('submit', async function (event) {
                event.preventDefault();
                var payload = {
                    parts_cost: document.getElementById('quotation_parts').value,
                    labor_cost: document.getElementById('quotation_labor').value
                };
                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/repairs/' + repairId + '/quotation', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(payload)
                });
                document.getElementById('quotation-status').textContent = response.ok - 'Saved.' : 'Unable to save.';
                loadRepair();
                loadStatusTimeline();
            });

            document.getElementById('generate-invoice').addEventListener('click', async function () {
                var taxValue = document.getElementById('invoice-tax').value;
                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/repairs/' + repairId + '/invoice', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ tax: taxValue || 0 })
                });
                document.getElementById('invoice-status').textContent = response.ok - 'Invoice generated.' : 'Unable to generate.';
                loadRepair();
            });

            document.getElementById('chat-form').addEventListener('submit', async function (event) {
                event.preventDefault();
                var payload = { message: document.getElementById('chat-message').value.trim() };
                if (!payload.message) {
                    return;
                }
                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/repairs/' + repairId + '/chat', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(payload)
                });
                document.getElementById('chat-status').textContent = response.ok - 'Sent.' : 'Unable to send.';
                document.getElementById('chat-message').value = '';
                loadChat();
            });

            switchTab('intake');
            loadRepair();
            loadTechnicians();
            loadStatusTimeline();
            loadChat();
        });
    </script>
@endsection
