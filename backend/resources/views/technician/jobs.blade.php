<x-app-layout>
    <x-slot name="header">
        <div class="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
            <div>
                <p class="text-xs font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400">
                    {{ __('Technician') }}
                </p>
                <h2 class="mt-1 text-2xl font-semibold tracking-tight text-slate-950 dark:text-white">
                    {{ __('My Repair Jobs') }}
                </h2>
            </div>
            <div class="flex items-center gap-3 text-xs text-slate-500 dark:text-slate-400">
                <span id="last-updated">{{ __('Loading...') }}</span>
                <button id="refresh-jobs" type="button" class="inline-flex h-10 items-center justify-center rounded-lg bg-slate-950 px-4 text-sm font-semibold text-white transition hover:bg-slate-800 focus:outline-none focus:ring-2 focus:ring-slate-400 dark:bg-white dark:text-slate-950 dark:hover:bg-slate-100">
                    {{ __('Refresh') }}
                </button>
            </div>
        </div>
    </x-slot>

    <div class="bg-slate-50/70 dark:bg-slate-950">
        <div class="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">
            <div class="grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
                <section class="rounded-lg border border-slate-200 bg-white p-4 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                    <p class="text-xs font-semibold uppercase tracking-wider text-slate-500">{{ __('New Assignments') }}</p>
                    <div class="mt-3 flex items-end justify-between">
                        <p id="assigned-count" class="text-3xl font-bold text-blue-600">0</p>
                        <span class="h-2 w-10 rounded-full bg-blue-500"></span>
                    </div>
                </section>
                <section class="rounded-lg border border-slate-200 bg-white p-4 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                    <p class="text-xs font-semibold uppercase tracking-wider text-slate-500">{{ __('In Service') }}</p>
                    <div class="mt-3 flex items-end justify-between">
                        <p id="active-count" class="text-3xl font-bold text-emerald-600">0</p>
                        <span class="h-2 w-10 rounded-full bg-emerald-500"></span>
                    </div>
                </section>
                <section class="rounded-lg border border-slate-200 bg-white p-4 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                    <p class="text-xs font-semibold uppercase tracking-wider text-slate-500">{{ __('Waiting') }}</p>
                    <div class="mt-3 flex items-end justify-between">
                        <p id="waiting-count" class="text-3xl font-bold text-amber-600">0</p>
                        <span class="h-2 w-10 rounded-full bg-amber-500"></span>
                    </div>
                </section>
                <section class="rounded-lg border border-slate-200 bg-white p-4 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                    <p class="text-xs font-semibold uppercase tracking-wider text-slate-500">{{ __('Done') }}</p>
                    <div class="mt-3 flex items-end justify-between">
                        <p id="completed-count" class="text-3xl font-bold text-violet-600">0</p>
                        <span class="h-2 w-10 rounded-full bg-violet-500"></span>
                    </div>
                </section>
            </div>

            <section class="mt-6 overflow-hidden rounded-lg border border-slate-200 bg-white shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <div class="border-b border-slate-200 px-5 py-4 dark:border-slate-800">
                    <div class="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
                        <div>
                            <h3 class="text-base font-semibold text-slate-950 dark:text-white">{{ __('Assigned Repairs') }}</h3>
                            <p class="mt-1 text-sm text-slate-500">{{ __('Approve new jobs, then send status updates to the customer.') }}</p>
                        </div>
                        <div class="flex flex-wrap gap-2 text-xs font-semibold">
                            <button type="button" data-filter="all" class="filter-button rounded-lg bg-slate-950 px-3 py-2 text-white dark:bg-white dark:text-slate-950">{{ __('All') }}</button>
                            <button type="button" data-filter="assigned" class="filter-button rounded-lg px-3 py-2 text-slate-600 hover:bg-slate-100 dark:text-slate-300 dark:hover:bg-slate-800">{{ __('New') }}</button>
                            <button type="button" data-filter="active" class="filter-button rounded-lg px-3 py-2 text-slate-600 hover:bg-slate-100 dark:text-slate-300 dark:hover:bg-slate-800">{{ __('Active') }}</button>
                            <button type="button" data-filter="waiting" class="filter-button rounded-lg px-3 py-2 text-slate-600 hover:bg-slate-100 dark:text-slate-300 dark:hover:bg-slate-800">{{ __('Waiting') }}</button>
                        </div>
                    </div>
                </div>

                <div id="jobs-body" class="divide-y divide-slate-200 dark:divide-slate-800">
                    <div class="p-6 text-sm text-slate-500">{{ __('Loading assigned jobs...') }}</div>
                </div>
            </section>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script>
        (function () {
            var userId = @json(auth()->id());
            var alertedStorageKey = 'technician_alerted_assignment_repairs_' + userId;
            var sound = new Audio('/sounds/mixkit-bell-notification-933.wav');
            var jobsBody = document.getElementById('jobs-body');
            var refreshButton = document.getElementById('refresh-jobs');
            var lastUpdated = document.getElementById('last-updated');
            var filterButtons = document.querySelectorAll('.filter-button');
            var pollTimer = null;
            var isLoading = false;
            var currentFilter = 'all';
            var currentJobs = [];
            function escapeHtml(value) {
                return String(value || '')
                    .replace(/&/g, '&amp;')
                    .replace(/</g, '&lt;')
                    .replace(/>/g, '&gt;')
                    .replace(/"/g, '&quot;')
                    .replace(/'/g, '&#039;');
            }

            function getCookie(name) {
                var match = document.cookie.match(new RegExp('(^| )' + name + '=([^;]+)'));
                return match ? decodeURIComponent(match[2]) : null;
            }

            async function ensureCsrfCookie() {
                try {
                    await fetch('/sanctum/csrf-cookie', { credentials: 'include' });
                } catch (error) {}
            }

            async function apiRequest(url, options) {
                var opts = options || {};
                var method = (opts.method || 'GET').toUpperCase();

                if (method !== 'GET') {
                    await ensureCsrfCookie();
                }

                var headers = Object.assign({ 'Accept': 'application/json' }, opts.headers || {});
                if (opts.body && !headers['Content-Type']) {
                    headers['Content-Type'] = 'application/json';
                }

                var xsrf = getCookie('XSRF-TOKEN');
                if (xsrf) {
                    headers['X-XSRF-TOKEN'] = xsrf;
                }

                return fetch(url, Object.assign({ credentials: 'include' }, opts, { headers: headers }));
            }

            function statusLabel(status) {
                return String(status || 'unknown')
                    .replace(/_/g, ' ')
                    .replace(/\b\w/g, function (letter) { return letter.toUpperCase(); });
            }

            function statusTone(status) {
                var tones = {
                    assigned: 'bg-blue-50 text-blue-700 border-blue-200 dark:bg-blue-500/10 dark:text-blue-200 dark:border-blue-500/20',
                    accepted: 'bg-indigo-50 text-indigo-700 border-indigo-200 dark:bg-indigo-500/10 dark:text-indigo-200 dark:border-indigo-500/20',
                    diagnosing: 'bg-cyan-50 text-cyan-700 border-cyan-200 dark:bg-cyan-500/10 dark:text-cyan-200 dark:border-cyan-500/20',
                    waiting_customer_approval: 'bg-amber-50 text-amber-800 border-amber-200 dark:bg-amber-500/10 dark:text-amber-200 dark:border-amber-500/20',
                    approved: 'bg-emerald-50 text-emerald-700 border-emerald-200 dark:bg-emerald-500/10 dark:text-emerald-200 dark:border-emerald-500/20',
                    in_progress: 'bg-emerald-50 text-emerald-700 border-emerald-200 dark:bg-emerald-500/10 dark:text-emerald-200 dark:border-emerald-500/20',
                    waiting_parts: 'bg-orange-50 text-orange-700 border-orange-200 dark:bg-orange-500/10 dark:text-orange-200 dark:border-orange-500/20',
                    testing: 'bg-violet-50 text-violet-700 border-violet-200 dark:bg-violet-500/10 dark:text-violet-200 dark:border-violet-500/20',
                    repair_completed: 'bg-slate-100 text-slate-800 border-slate-200 dark:bg-slate-800 dark:text-slate-100 dark:border-slate-700',
                    ready_for_pickup: 'bg-lime-50 text-lime-700 border-lime-200 dark:bg-lime-500/10 dark:text-lime-200 dark:border-lime-500/20',
                    cannot_repair: 'bg-rose-50 text-rose-700 border-rose-200 dark:bg-rose-500/10 dark:text-rose-200 dark:border-rose-500/20'
                };

                return tones[status] || 'bg-slate-100 text-slate-700 border-slate-200 dark:bg-slate-800 dark:text-slate-200 dark:border-slate-700';
            }

            function loadAlertedIds() {
                try {
                    return new Set(JSON.parse(localStorage.getItem(alertedStorageKey) || '[]').map(String));
                } catch (error) {
                    return new Set();
                }
            }

            function saveAlertedIds(ids) {
                try {
                    localStorage.setItem(alertedStorageKey, JSON.stringify(Array.from(ids)));
                } catch (error) {}
            }

            function playAlertSound() {
                try {
                    sound.currentTime = 0;
                    var maybePromise = sound.play();
                    if (maybePromise && typeof maybePromise.catch === 'function') {
                        maybePromise.catch(function () {});
                    }
                } catch (error) {}
            }

            function showToast(message, type) {
                if (window.Swal) {
                    window.Swal.fire({
                        toast: true,
                        position: 'top-end',
                        icon: type || 'success',
                        title: message,
                        showConfirmButton: false,
                        timer: 2400,
                        timerProgressBar: true
                    });
                    return;
                }

                alert(message);
            }

            function formatDate(value) {
                if (!value) {
                    return '-';
                }

                try {
                    return new Date(value).toLocaleString();
                } catch (error) {
                    return value;
                }
            }

            function formatMoney(value) {
                return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(Number(value || 0));
            }

            function jobBucket(job) {
                if (job.status === 'assigned') {
                    return 'assigned';
                }
                if (['waiting_parts', 'waiting_customer_approval'].indexOf(job.status) !== -1) {
                    return 'waiting';
                }
                if (['repair_completed', 'ready_for_pickup', 'delivered'].indexOf(job.status) !== -1) {
                    return 'completed';
                }
                return 'active';
            }

            function visibleJobs(jobs) {
                if (currentFilter === 'all') {
                    return jobs;
                }

                return jobs.filter(function (job) {
                    return jobBucket(job) === currentFilter;
                });
            }

            function renderSummary(jobs) {
                var assigned = jobs.filter(function (job) { return job.status === 'assigned'; }).length;
                var waiting = jobs.filter(function (job) {
                    return ['waiting_parts', 'waiting_customer_approval'].indexOf(job.status) !== -1;
                }).length;
                var completed = jobs.filter(function (job) {
                    return ['repair_completed', 'ready_for_pickup', 'delivered'].indexOf(job.status) !== -1;
                }).length;
                var active = jobs.filter(function (job) {
                    return ['assigned', 'waiting_parts', 'waiting_customer_approval', 'repair_completed', 'ready_for_pickup', 'cancelled', 'delivered'].indexOf(job.status) === -1;
                }).length;

                document.getElementById('assigned-count').textContent = assigned;
                document.getElementById('active-count').textContent = active;
                document.getElementById('waiting-count').textContent = waiting;
                document.getElementById('completed-count').textContent = completed;
            }

            function renderFilterButtons() {
                filterButtons.forEach(function (button) {
                    var active = button.dataset.filter === currentFilter;
                    button.className = active
                        ? 'filter-button rounded-lg bg-slate-950 px-3 py-2 text-white dark:bg-white dark:text-slate-950'
                        : 'filter-button rounded-lg px-3 py-2 text-slate-600 hover:bg-slate-100 dark:text-slate-300 dark:hover:bg-slate-800';
                });
            }

            function primaryStatusAction(job) {
                var allowed = Array.isArray(job.allowed_next_statuses) ? job.allowed_next_statuses : [];
                function can(status) {
                    return allowed.indexOf(status) !== -1;
                }

                if (job.status === 'accepted' && can('diagnosing')) {
                    return {
                        status: 'diagnosing',
                        label: @json(__('Process')),
                        note: @json(__('Technician started processing this repair.'))
                    };
                }

                if ((job.status === 'diagnosing' || job.status === 'approved' || job.status === 'waiting_parts') && can('in_progress')) {
                    return {
                        status: 'in_progress',
                        label: @json(__('Repair')),
                        note: @json(__('Technician started repair work.'))
                    };
                }

                if ((job.status === 'in_progress' || job.status === 'testing') && can('repair_completed')) {
                    return {
                        status: 'repair_completed',
                        label: @json(__('DONE')),
                        note: @json(__('Repair work is done.'))
                    };
                }

                return null;
            }

            function renderActionPanel(job) {
                if (job.status === 'assigned') {
                    return '<div class="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-end">' +
                        '<button type="button" data-action="reject" data-id="' + job.id + '" class="inline-flex h-10 items-center justify-center rounded-lg border border-rose-200 bg-white px-4 text-sm font-semibold text-rose-700 transition hover:bg-rose-50 dark:border-rose-500/30 dark:bg-slate-900 dark:text-rose-200 dark:hover:bg-rose-500/10">{{ __('Reject') }}</button>' +
                        '<button type="button" data-action="accept" data-id="' + job.id + '" class="inline-flex h-10 items-center justify-center rounded-lg bg-emerald-600 px-4 text-sm font-semibold text-white transition hover:bg-emerald-700">{{ __('Approve Job') }}</button>' +
                    '</div>';
                }

                var nextAction = primaryStatusAction(job);
                if (!nextAction) {
                    return '<p class="text-sm text-slate-500">{{ __('No status update is available for this repair right now.') }}</p>';
                }

                var buttonClass = nextAction.status === 'repair_completed'
                    ? 'inline-flex h-10 items-center justify-center rounded-lg bg-emerald-600 px-5 text-sm font-semibold text-white transition hover:bg-emerald-700'
                    : 'inline-flex h-10 items-center justify-center rounded-lg bg-blue-600 px-5 text-sm font-semibold text-white transition hover:bg-blue-700';

                return '<div class="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-end">' +
                    '<button type="button" data-action="status" data-id="' + job.id + '" data-status="' + escapeHtml(nextAction.status) + '" data-note="' + escapeHtml(nextAction.note) + '" class="' + buttonClass + '">' + escapeHtml(nextAction.label) + '</button>' +
                '</div>';
            }

            function renderJobs(jobs) {
                renderSummary(jobs);
                renderFilterButtons();

                var list = visibleJobs(jobs);

                if (!list.length) {
                    jobsBody.innerHTML = '<div class="p-10 text-center"><p class="text-sm font-semibold text-slate-700 dark:text-slate-200">{{ __('No repair jobs in this view.') }}</p><p class="mt-1 text-sm text-slate-500">{{ __('Use Refresh to check for new assignments.') }}</p></div>';
                    return;
                }

                jobsBody.innerHTML = list.map(function (job) {
                    var customer = job.customer || {};
                    var invoiceTotal = job.invoice && job.invoice.total ? formatMoney(job.invoice.total) : '-';
                    var quoteStatus = job.quotation && job.quotation.status ? statusLabel(job.quotation.status) : '-';
                    var actionPanel = renderActionPanel(job);
                    var badgeTone = statusTone(job.status);

                    return '<article class="relative bg-white p-5 transition hover:bg-slate-50/70 dark:bg-slate-900 dark:hover:bg-slate-900/80" data-job-id="' + job.id + '">' +
                        '<div class="absolute inset-y-5 left-0 w-1 rounded-r-full ' + (job.status === 'assigned' ? 'bg-blue-500' : job.status === 'cannot_repair' ? 'bg-rose-500' : 'bg-emerald-500') + '"></div>' +
                        '<div class="pl-3">' +
                            '<div class="flex flex-col gap-3 lg:flex-row lg:items-start lg:justify-between">' +
                                '<div class="min-w-0">' +
                                    '<div class="flex flex-wrap items-center gap-2">' +
                                        '<h4 class="text-lg font-semibold text-slate-950 dark:text-white">Repair #' + job.id + '</h4>' +
                                        '<span class="inline-flex rounded-full border px-2.5 py-1 text-xs font-semibold ' + badgeTone + '">' + escapeHtml(statusLabel(job.status)) + '</span>' +
                                    '</div>' +
                                    '<p class="mt-2 text-sm font-medium text-slate-800 dark:text-slate-100">' + escapeHtml(job.device_model || '-') + '</p>' +
                                    '<p class="mt-1 text-sm text-slate-500 dark:text-slate-400">' + escapeHtml(job.issue_type || '-') + '</p>' +
                                '</div>' +
                                '<div class="text-left text-sm text-slate-500 lg:text-right">' +
                                    '<p class="font-semibold text-slate-800 dark:text-slate-100">' + escapeHtml(formatDate(job.created_at)) + '</p>' +
                                    '<p>{{ __('Invoice') }}: ' + escapeHtml(invoiceTotal) + '</p>' +
                                '</div>' +
                            '</div>' +
                            '<dl class="mt-5 grid gap-x-6 gap-y-3 text-sm sm:grid-cols-2 lg:grid-cols-4">' +
                                '<div><dt class="text-xs font-semibold uppercase tracking-wider text-slate-400">{{ __('Customer') }}</dt><dd class="mt-1 font-medium text-slate-800 dark:text-slate-100">' + escapeHtml(customer.name || '-') + '</dd></div>' +
                                '<div><dt class="text-xs font-semibold uppercase tracking-wider text-slate-400">{{ __('Phone') }}</dt><dd class="mt-1 font-medium text-slate-800 dark:text-slate-100">' + escapeHtml(customer.phone || '-') + '</dd></div>' +
                                '<div><dt class="text-xs font-semibold uppercase tracking-wider text-slate-400">{{ __('Service') }}</dt><dd class="mt-1 font-medium text-slate-800 dark:text-slate-100">' + escapeHtml(statusLabel(job.service_type || '-')) + '</dd></div>' +
                                '<div><dt class="text-xs font-semibold uppercase tracking-wider text-slate-400">{{ __('Quote') }}</dt><dd class="mt-1 font-medium text-slate-800 dark:text-slate-100">' + escapeHtml(quoteStatus) + '</dd></div>' +
                            '</dl>' +
                            '<div class="mt-5 border-t border-slate-200 pt-4 dark:border-slate-800">' + actionPanel + '</div>' +
                        '</div>' +
                    '</article>';
                }).join('');
            }

            async function loadJobs(options) {
                if (isLoading) {
                    return;
                }

                isLoading = true;
                refreshButton.disabled = true;
                refreshButton.classList.add('opacity-70');
                var opts = options || {};

                try {
                    var response = await apiRequest('/api/technician/repairs/assigned?per_page=100');
                    if (!response.ok) {
                        jobsBody.innerHTML = '<div class="p-6 text-sm text-rose-600">{{ __('Unable to load assigned jobs.') }}</div>';
                        return;
                    }

                    var payload = await response.json();
                    currentJobs = Array.isArray(payload.data) ? payload.data : [];
                    renderJobs(currentJobs);
                    lastUpdated.textContent = '{{ __('Updated') }} ' + new Date().toLocaleTimeString();

                    if (opts.showAlerts !== false) {
                        showNewAssignmentAlerts(currentJobs);
                    }
                } catch (error) {
                    jobsBody.innerHTML = '<div class="p-6 text-sm text-rose-600">{{ __('Network error while loading jobs.') }}</div>';
                } finally {
                    isLoading = false;
                    refreshButton.disabled = false;
                    refreshButton.classList.remove('opacity-70');
                }
            }

            async function showNewAssignmentAlerts(jobs) {
                var alertedIds = loadAlertedIds();
                var newAssignments = jobs.filter(function (job) {
                    return job.status === 'assigned' && !alertedIds.has(String(job.id));
                });

                if (!newAssignments.length) {
                    return;
                }

                newAssignments.sort(function (a, b) { return a.id - b.id; });

                for (var i = 0; i < newAssignments.length; i++) {
                    var job = newAssignments[i];
                    alertedIds.add(String(job.id));
                    saveAlertedIds(alertedIds);
                    playAlertSound();
                    await showAssignmentDecision(job);
                }
            }

            async function showAssignmentDecision(job) {
                if (!window.Swal) {
                    alert('New repair assignment #' + job.id + '.');
                    await acceptJob(job.id);
                    return;
                }

                var customer = job.customer || {};
                var result = await window.Swal.fire({
                    icon: 'info',
                    title: 'New repair assignment',
                    html: '<div class="text-left text-sm">' +
                        '<p><strong>Repair #' + job.id + '</strong></p>' +
                        '<p>' + escapeHtml(job.device_model || '-') + ' - ' + escapeHtml(job.issue_type || '-') + '</p>' +
                        '<p>Customer: ' + escapeHtml(customer.name || '-') + '</p>' +
                    '</div>',
                    showDenyButton: false,
                    showCancelButton: false,
                    confirmButtonText: 'Approve',
                    confirmButtonColor: '#059669',
                    allowOutsideClick: false,
                    allowEscapeKey: false
                });

                if (result.isConfirmed) {
                    await acceptJob(job.id);
                }
            }

            async function acceptJob(id) {
                var response = await apiRequest('/api/technician/repairs/' + id + '/accept', {
                    method: 'POST'
                });

                if (!response.ok) {
                    showToast('{{ __('Unable to approve job.') }}', 'error');
                    return;
                }

                showToast('{{ __('Job approved.') }}', 'success');
                await loadJobs({ showAlerts: false });
            }

            async function rejectJob(id) {
                var reason = 'Rejected by technician.';

                if (window.Swal) {
                    var result = await window.Swal.fire({
                        icon: 'warning',
                        title: 'Reject repair job',
                        input: 'textarea',
                        inputLabel: 'Reason',
                        inputPlaceholder: 'Why can you not take this job?',
                        showCancelButton: true,
                        confirmButtonText: 'Reject',
                        confirmButtonColor: '#dc2626',
                        inputValidator: function (value) {
                            if (!value || !value.trim()) {
                                return 'Reason is required.';
                            }
                        }
                    });

                    if (!result.isConfirmed) {
                        return;
                    }

                    reason = result.value.trim();
                }

                var response = await apiRequest('/api/technician/repairs/' + id + '/reject', {
                    method: 'POST',
                    body: JSON.stringify({ reason: reason })
                });

                if (!response.ok) {
                    showToast('{{ __('Unable to reject job.') }}', 'error');
                    return;
                }

                showToast('{{ __('Job rejected and returned for reassignment.') }}', 'success');
                await loadJobs({ showAlerts: false });
            }

            async function updateStatus(id, status, note) {
                if (!status) {
                    showToast('{{ __('No status update is available for this repair right now.') }}', 'error');
                    return;
                }

                var response = await apiRequest('/api/technician/repairs/' + id + '/status', {
                    method: 'POST',
                    body: JSON.stringify({
                        status: status,
                        note: note || null
                    })
                });

                if (!response.ok) {
                    var message = '{{ __('Unable to update status.') }}';
                    try {
                        var payload = await response.json();
                        message = payload.message || message;
                    } catch (error) {}
                    showToast(message, 'error');
                    return;
                }

                showToast('{{ __('Status sent to customer.') }}', 'success');
                await loadJobs({ showAlerts: false });
            }

            jobsBody.addEventListener('click', function (event) {
                var button = event.target.closest('[data-action]');
                if (!button) {
                    return;
                }

                var id = button.getAttribute('data-id');
                var action = button.getAttribute('data-action');

                if (action === 'accept') {
                    acceptJob(id);
                } else if (action === 'reject') {
                    rejectJob(id);
                } else if (action === 'status') {
                    updateStatus(id, button.getAttribute('data-status') || '', button.getAttribute('data-note') || '');
                }
            });

            filterButtons.forEach(function (button) {
                button.addEventListener('click', function () {
                    currentFilter = button.dataset.filter || 'all';
                    renderJobs(currentJobs);
                });
            });

            refreshButton.addEventListener('click', function () {
                loadJobs({ showAlerts: true });
            });

            document.addEventListener('click', function unlockSound() {
                sound.load();
                document.removeEventListener('click', unlockSound);
            });

            loadJobs({ showAlerts: true });
            pollTimer = setInterval(function () {
                loadJobs({ showAlerts: true });
            }, 15000);

            window.addEventListener('beforeunload', function () {
                if (pollTimer) {
                    clearInterval(pollTimer);
                }
            });
        })();
    </script>
</x-app-layout>
