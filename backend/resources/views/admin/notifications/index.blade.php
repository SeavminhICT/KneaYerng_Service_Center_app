@extends('layouts.admin')

@section('title', __('Notifications'))
@section('page-title', __('Notifications'))

@section('content')
    <section class="space-y-6"
        id="notification-page"
        data-can-send="{{ auth()->user()?->hasPermission('create_notification') ? '1' : '0' }}"
        data-history-url="{{ route('admin.notifications.history', [], false) }}">
        <div class="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <div class="flex flex-col gap-4 lg:flex-row lg:items-end lg:justify-between">
                <div>
                    <span class="inline-flex rounded-full bg-primary-50 px-3 py-1 text-xs font-semibold uppercase tracking-[0.22em] text-primary-700 dark:bg-primary-500/10 dark:text-primary-100">{{ __('Push Center') }}</span>
                    <h1 class="mt-3 text-2xl font-semibold text-slate-900 dark:text-white">{{ __('Send Notifications With Delivery Context') }}</h1>
                    <p class="mt-2 max-w-3xl text-sm text-slate-500">{{ __('Design and preview the notification payload, choose the audience, and resend past notifications in one click.') }}</p>
                </div>
                <div class="flex flex-wrap gap-3">
                    <div class="rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-center dark:border-slate-800 dark:bg-slate-950">
                        <p id="stat-sent" class="text-xl font-bold text-slate-900 dark:text-white">--</p>
                        <p class="text-xs font-semibold uppercase tracking-wide text-slate-500">{{ __('Sent') }}</p>
                    </div>
                    <div class="rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-center dark:border-slate-800 dark:bg-slate-950">
                        <p id="stat-delivered" class="text-xl font-bold text-emerald-600 dark:text-emerald-400">--</p>
                        <p class="text-xs font-semibold uppercase tracking-wide text-slate-500">{{ __('Delivered') }}</p>
                    </div>
                    <div class="rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-center dark:border-slate-800 dark:bg-slate-950">
                        <p id="stat-failed" class="text-xl font-bold text-rose-600 dark:text-rose-400">--</p>
                        <p class="text-xs font-semibold uppercase tracking-wide text-slate-500">{{ __('Failed') }}</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="grid gap-6 xl:grid-cols-[1.6fr_1fr]">
            <div class="space-y-6">
                <div class="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                    <div class="flex items-center justify-between gap-4">
                        <div>
                            <h2 class="text-lg font-semibold text-slate-900 dark:text-white">{{ __('Compose Notification') }}</h2>
                            <p class="mt-1 text-sm text-slate-500">{{ __('Create a reusable payload for announcements, alerts, documents, and order updates.') }}</p>
                        </div>
                        <span class="rounded-full bg-primary-50 px-3 py-1 text-xs font-semibold text-primary-700 dark:bg-primary-500/10 dark:text-primary-100">{{ __('Draft mode') }}</span>
                    </div>

                    <form id="notification-form" class="mt-6 space-y-5" data-send-url="{{ route('admin.notifications.store', [], false) }}">
                        <div class="grid gap-5 md:grid-cols-2">
                            <div>
                                <label for="notification-title" class="text-sm font-semibold text-slate-700 dark:text-slate-200">{{ __('Title') }}</label>
                                <input id="notification-title" name="title" type="text" placeholder="{{ __('Enter notification title') }}" class="mt-2 h-12 w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-100" />
                            </div>
                            <div>
                                <label for="notification-type" class="text-sm font-semibold text-slate-700 dark:text-slate-200">{{ __('Notification Type') }}</label>
                                <select id="notification-type" name="type" class="mt-2 h-12 w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-100">
                                    <option value="Announcement">{{ __('Announcement') }}</option>
                                    <option value="Promotion">{{ __('Promotion') }}</option>
                                    <option value="Alert">{{ __('Alert') }}</option>
                                    <option value="Info">{{ __('Info') }}</option>
                                    <option value="Reminder">{{ __('Reminder') }}</option>
                                    <option value="Document">{{ __('Document') }}</option>
                                    <option value="Order">{{ __('Order') }}</option>
                                </select>
                            </div>
                        </div>

                        <div>
                            <label for="notification-message" class="text-sm font-semibold text-slate-700 dark:text-slate-200">{{ __('Message') }}</label>
                            <textarea id="notification-message" name="message" rows="5" placeholder="{{ __('Write the message users should see on the device and inside the app.') }}" class="mt-2 w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-100"></textarea>
                        </div>

                        <div class="grid gap-5 md:grid-cols-2">
                            <div>
                                <label class="text-sm font-semibold text-slate-700 dark:text-slate-200">{{ __('Target Users') }}</label>
                                <div class="mt-2 grid gap-3 sm:grid-cols-2">
                                    <label class="flex items-center gap-3 rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm font-medium text-slate-700 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-200">
                                        <input type="radio" name="target_mode" value="all" checked class="h-4 w-4 border-slate-300 text-primary-600 focus:ring-primary-500" />
                                        {{ __('Everyone (incl. guests)') }}
                                    </label>
                                    <label class="flex items-center gap-3 rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm font-medium text-slate-700 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-200">
                                        <input type="radio" name="target_mode" value="registered" class="h-4 w-4 border-slate-300 text-primary-600 focus:ring-primary-500" />
                                        {{ __('Registered Users') }}
                                    </label>
                                    <label class="flex items-center gap-3 rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm font-medium text-slate-700 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-200">
                                        <input type="radio" name="target_mode" value="guests" class="h-4 w-4 border-slate-300 text-primary-600 focus:ring-primary-500" />
                                        {{ __('Guest Devices') }}
                                    </label>
                                    <label class="flex items-center gap-3 rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm font-medium text-slate-700 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-200">
                                        <input type="radio" name="target_mode" value="specific" class="h-4 w-4 border-slate-300 text-primary-600 focus:ring-primary-500" />
                                        {{ __('Specific User') }}
                                    </label>
                                </div>
                            </div>
                            <div id="specific-user-panel" class="hidden">
                                <label for="target-user-id" class="text-sm font-semibold text-slate-700 dark:text-slate-200">{{ __('Choose User') }}</label>
                                <select id="target-user-id" name="target_user_id" class="mt-2 h-12 w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-100" disabled>
                                    <option value="">{{ __('Select a user') }}</option>
                                    @foreach ($users as $user)
                                        <option value="{{ $user->id }}">
                                            {{ trim(($user->name ?: __('User')).' - '.($user->email ?: $user->phone ?: __('No contact'))) }}
                                        </option>
                                    @endforeach
                                </select>
                                <p class="mt-2 text-xs text-slate-500">{{ __('Only users who already opened the mobile app and registered a device token can receive push delivery.') }}</p>
                            </div>
                        </div>

                        <div class="grid gap-5 md:grid-cols-2">
                            <div>
                                <label for="notification-image" class="text-sm font-semibold text-slate-700 dark:text-slate-200">{{ __('Upload Image') }}</label>
                                <input id="notification-image" name="image" type="file" accept="image/*" class="mt-2 block w-full rounded-2xl border border-dashed border-slate-300 bg-slate-50 px-4 py-3 text-sm text-slate-500 file:mr-4 file:rounded-xl file:border-0 file:bg-primary-50 file:px-3 file:py-2 file:text-sm file:font-semibold file:text-primary-700 hover:file:bg-primary-100 dark:border-slate-700 dark:bg-slate-950 dark:text-slate-400 dark:file:bg-primary-500/10 dark:file:text-primary-100" />
                            </div>
                            <div>
                                <label for="notification-link" class="text-sm font-semibold text-slate-700 dark:text-slate-200">{{ __('Deep Link') }}</label>
                                <input id="notification-link" name="deep_link" type="text" placeholder="/document/6 or https://..." class="mt-2 h-12 w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-100" />
                            </div>
                        </div>

                        <div class="flex flex-wrap gap-3 pt-2">
                            @if (auth()->user()?->hasPermission('create_notification'))
                            <button id="send-notification" type="submit" class="inline-flex items-center justify-center rounded-2xl bg-[#4A88F7] px-5 py-3 text-sm font-semibold text-white shadow-lg shadow-primary-500/20 transition hover:bg-[#3977E6]">{{ __('Send Notification') }}</button>
                            @endif
                            <button id="save-draft" type="button" class="inline-flex items-center justify-center rounded-2xl border border-slate-200 bg-white px-5 py-3 text-sm font-semibold text-slate-700 shadow-sm transition hover:bg-slate-50 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-200">{{ __('Save Draft') }}</button>
                        </div>
                        <p class="text-xs text-slate-500">{{ __('Dashboard send flow: save notification in backend, send through Firebase, then the phone receives it if that user has a valid mobile token.') }}</p>
                    </form>
                </div>

                <div class="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                    <div class="flex flex-wrap items-center justify-between gap-4">
                        <div>
                            <h2 class="text-lg font-semibold text-slate-900 dark:text-white">{{ __('Sent History') }}</h2>
                            <p class="mt-1 text-sm text-slate-500">{{ __('Recent notifications sent from this dashboard. Resend or reuse any of them.') }}</p>
                        </div>
                        <button id="refresh-history" type="button" class="inline-flex items-center gap-2 rounded-2xl border border-slate-200 bg-white px-4 py-2 text-sm font-semibold text-slate-700 shadow-sm transition hover:bg-slate-50 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-200">
                            <svg class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M4 4v5h5M20 20v-5h-5M5.07 15a7 7 0 0011.9 2.4M18.93 9a7 7 0 00-11.9-2.4" />
                            </svg>
                            {{ __('Refresh') }}
                        </button>
                    </div>
                    <div id="history-list" class="mt-5 space-y-3">
                        <p id="history-empty" class="rounded-2xl border border-dashed border-slate-300 bg-slate-50 px-4 py-6 text-center text-sm text-slate-500 dark:border-slate-700 dark:bg-slate-950">{{ __('Loading history...') }}</p>
                    </div>
                </div>
            </div>

            <div class="space-y-6">
                <div class="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                    <h2 class="text-lg font-semibold text-slate-900 dark:text-white">{{ __('Push Preview') }}</h2>
                    <p class="mt-1 text-sm text-slate-500">{{ __('Live preview of the content users will see on mobile.') }}</p>
                    <div class="mt-5 rounded-[28px] border border-slate-200 bg-slate-950 p-4 text-white shadow-inner dark:border-slate-800">
                        <div class="mb-3 flex items-center justify-between px-2 text-[11px] font-semibold text-white/50">
                            <span id="preview-clock">9:41</span>
                            <span class="flex items-center gap-1">
                                <svg class="h-3 w-3" fill="currentColor" viewBox="0 0 24 24"><path d="M2 17h4v4H2zM8 13h4v8H8zM14 9h4v12h-4zM20 5h2v16h-2z"/></svg>
                                <svg class="h-3 w-3" fill="currentColor" viewBox="0 0 24 24"><path d="M12 21l-9-9a12.7 12.7 0 0118 0l-9 9z"/></svg>
                            </span>
                        </div>
                        <div class="rounded-[24px] bg-white/10 p-4 backdrop-blur">
                            <div class="flex items-start gap-3">
                                <div class="flex h-11 w-11 items-center justify-center rounded-2xl bg-white/15 text-white">
                                    <svg class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M15 17h5l-1.4-1.4a2 2 0 01-.6-1.42V11a6 6 0 10-12 0v3.18a2 2 0 01-.59 1.41L4 17h5m6 0a3 3 0 11-6 0m6 0H9" />
                                    </svg>
                                </div>
                                <div class="min-w-0 flex-1">
                                    <p id="preview-type" class="text-xs font-semibold uppercase tracking-[0.24em] text-white/60">{{ __('Announcement') }}</p>
                                    <p id="preview-title" class="mt-2 text-base font-semibold">{{ __('Title preview will appear here') }}</p>
                                    <p id="preview-message" class="mt-2 text-sm leading-6 text-white/80">{{ __('Message preview will update as you type into the form on the left.') }}</p>
                                    <img id="preview-image" src="" alt="" class="mt-3 hidden max-h-40 w-full rounded-2xl object-cover" />
                                    <div class="mt-4 flex items-center justify-between text-xs text-white/55">
                                        <span>{{ __('now') }}</span>
                                        <span id="preview-link">{{ __('No deep link') }}</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var page = document.getElementById('notification-page');
            var canSend = page && page.dataset.canSend === '1';
            var historyUrl = page ? page.dataset.historyUrl : '/admin/notifications/history';
            var form = document.getElementById('notification-form');
            var titleInput = document.getElementById('notification-title');
            var messageInput = document.getElementById('notification-message');
            var typeInput = document.getElementById('notification-type');
            var deepLinkInput = document.getElementById('notification-link');
            var imageInput = document.getElementById('notification-image');
            var specificUserPanel = document.getElementById('specific-user-panel');
            var targetUserSelect = document.getElementById('target-user-id');
            var targetModeInputs = document.querySelectorAll('input[name="target_mode"]');
            var previewTitle = document.getElementById('preview-title');
            var previewMessage = document.getElementById('preview-message');
            var previewType = document.getElementById('preview-type');
            var previewLink = document.getElementById('preview-link');
            var previewImage = document.getElementById('preview-image');
            var previewClock = document.getElementById('preview-clock');
            var saveDraftButton = document.getElementById('save-draft');
            var sendButton = document.getElementById('send-notification');
            var refreshHistoryButton = document.getElementById('refresh-history');
            var historyList = document.getElementById('history-list');
            var statSent = document.getElementById('stat-sent');
            var statDelivered = document.getElementById('stat-delivered');
            var statFailed = document.getElementById('stat-failed');
            var draftKey = 'admin.notification.draft';
            var csrfToken = document.querySelector('meta[name="csrf-token"]');

            if (previewClock) {
                var now = new Date();
                previewClock.textContent = String(now.getHours()).padStart(2, '0') + ':' + String(now.getMinutes()).padStart(2, '0');
            }

            function updateSpecificUserState() {
                var mode = document.querySelector('input[name="target_mode"]:checked');
                var isSpecific = !!mode && mode.value === 'specific';
                specificUserPanel.classList.toggle('hidden', !isSpecific);
                if (targetUserSelect) {
                    targetUserSelect.disabled = !isSpecific;
                    if (!isSpecific) {
                        targetUserSelect.value = '';
                    }
                }
            }

            function syncPreview() {
                previewTitle.textContent = titleInput.value.trim() || 'Title preview will appear here';
                previewMessage.textContent = messageInput.value.trim() || 'Message preview will update as you type into the form on the left.';
                previewType.textContent = typeInput.value || 'Announcement';
                previewLink.textContent = deepLinkInput.value.trim() || 'No deep link';
            }

            function syncImagePreview() {
                if (!previewImage) {
                    return;
                }
                var file = imageInput && imageInput.files ? imageInput.files[0] : null;
                if (!file) {
                    previewImage.src = '';
                    previewImage.classList.add('hidden');
                    return;
                }
                var reader = new FileReader();
                reader.onload = function (event) {
                    previewImage.src = event.target.result;
                    previewImage.classList.remove('hidden');
                };
                reader.readAsDataURL(file);
            }

            function saveDraftToast() {
                if (window.adminToast) {
                    window.adminToast('Notification draft saved locally.', { type: 'success' });
                }
            }

            function setFieldError(field, hasError) {
                if (!field) {
                    return;
                }
                field.classList.toggle('border-red-500', !!hasError);
                field.classList.toggle('focus:border-red-500', !!hasError);
                field.classList.toggle('focus:ring-red-500', !!hasError);
            }

            function resetFieldErrors() {
                [titleInput, messageInput, typeInput, deepLinkInput, imageInput, targetUserSelect].forEach(function (field) {
                    setFieldError(field, false);
                });
            }

            function applyErrors(errors) {
                resetFieldErrors();
                if (!errors) {
                    return;
                }
                if (errors.title) {
                    setFieldError(titleInput, true);
                }
                if (errors.message) {
                    setFieldError(messageInput, true);
                }
                if (errors.type) {
                    setFieldError(typeInput, true);
                }
                if (errors.deep_link) {
                    setFieldError(deepLinkInput, true);
                }
                if (errors.image) {
                    setFieldError(imageInput, true);
                }
                if (errors.target_user_id || errors.custom_user_ids) {
                    setFieldError(targetUserSelect, true);
                }
            }

            function resetFormState() {
                form.reset();
                if (targetModeInputs[0]) {
                    targetModeInputs[0].checked = true;
                }
                localStorage.removeItem(draftKey);
                updateSpecificUserState();
                syncPreview();
                syncImagePreview();
            }

            function setSubmitting(isSubmitting) {
                if (!sendButton) {
                    return;
                }
                sendButton.disabled = isSubmitting;
                sendButton.textContent = isSubmitting ? 'Sending...' : 'Send Notification';
            }

            // ---- History + resend ----

            var historyItems = [];

            function relativeTime(iso) {
                if (!iso) {
                    return '';
                }
                var then = new Date(iso).getTime();
                if (isNaN(then)) {
                    return '';
                }
                var diff = Math.max(0, Date.now() - then);
                var minutes = Math.floor(diff / 60000);
                if (minutes < 1) return 'just now';
                if (minutes < 60) return minutes + ' min ago';
                var hours = Math.floor(minutes / 60);
                if (hours < 24) return hours + ' hr ago';
                var days = Math.floor(hours / 24);
                if (days < 7) return days + ' day' + (days === 1 ? '' : 's') + ' ago';
                return new Date(iso).toLocaleDateString();
            }

            function audienceLabel(item) {
                var audience = (item.audience || 'all').toLowerCase();
                if (audience === 'custom') {
                    var count = Array.isArray(item.custom_user_ids) ? item.custom_user_ids.length : 0;
                    return count === 1 ? '1 specific user' : count + ' specific users';
                }
                var labels = {
                    all: 'Everyone (incl. guests)',
                    registered: 'Registered users',
                    guests: 'Guest devices',
                    active: 'Active users',
                    new: 'New users',
                    inactive: 'Inactive users',
                    premium: 'Premium users',
                };
                return labels[audience] || audience;
            }

            function statusBadge(status) {
                var span = document.createElement('span');
                var classes = {
                    sent: 'bg-emerald-50 text-emerald-700 dark:bg-emerald-500/10 dark:text-emerald-300',
                    scheduled: 'bg-sky-50 text-sky-700 dark:bg-sky-500/10 dark:text-sky-300',
                    draft: 'bg-amber-50 text-amber-700 dark:bg-amber-500/10 dark:text-amber-300',
                    queued: 'bg-indigo-50 text-indigo-700 dark:bg-indigo-500/10 dark:text-indigo-300',
                    sending: 'bg-indigo-50 text-indigo-700 dark:bg-indigo-500/10 dark:text-indigo-300',
                    failed: 'bg-rose-50 text-rose-700 dark:bg-rose-500/10 dark:text-rose-300',
                };
                span.className = 'inline-flex rounded-full px-2.5 py-0.5 text-[11px] font-semibold uppercase tracking-wide ' + (classes[status] || 'bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-300');
                span.textContent = status || 'unknown';
                return span;
            }

            function renderStats(items) {
                if (!statSent) {
                    return;
                }
                var sent = 0;
                var delivered = 0;
                var failed = 0;
                items.forEach(function (item) {
                    if (item.status === 'sent') {
                        sent++;
                    }
                    var summary = item.summary || {};
                    delivered += Number(summary.delivered || 0);
                    failed += Number(summary.failed || 0);
                });
                statSent.textContent = String(sent);
                statDelivered.textContent = String(delivered);
                statFailed.textContent = String(failed);
            }

            function renderHistory(items) {
                historyItems = items;
                historyList.innerHTML = '';
                renderStats(items);

                if (!items.length) {
                    var empty = document.createElement('p');
                    empty.className = 'rounded-2xl border border-dashed border-slate-300 bg-slate-50 px-4 py-6 text-center text-sm text-slate-500 dark:border-slate-700 dark:bg-slate-950';
                    empty.textContent = 'No notifications sent yet. Compose one above to get started.';
                    historyList.appendChild(empty);
                    return;
                }

                items.forEach(function (item) {
                    var card = document.createElement('div');
                    card.className = 'rounded-2xl border border-slate-200 bg-slate-50 p-4 dark:border-slate-800 dark:bg-slate-950';

                    var top = document.createElement('div');
                    top.className = 'flex flex-wrap items-start justify-between gap-3';

                    var info = document.createElement('div');
                    info.className = 'min-w-0 flex-1';

                    var badges = document.createElement('div');
                    badges.className = 'flex flex-wrap items-center gap-2';
                    badges.appendChild(statusBadge(item.status));
                    var typeBadge = document.createElement('span');
                    typeBadge.className = 'inline-flex rounded-full bg-primary-50 px-2.5 py-0.5 text-[11px] font-semibold text-primary-700 dark:bg-primary-500/10 dark:text-primary-100';
                    typeBadge.textContent = item.type || 'Announcement';
                    badges.appendChild(typeBadge);
                    info.appendChild(badges);

                    var title = document.createElement('p');
                    title.className = 'mt-2 truncate text-sm font-semibold text-slate-900 dark:text-white';
                    title.textContent = item.title || '(no title)';
                    info.appendChild(title);

                    if (item.message) {
                        var message = document.createElement('p');
                        message.className = 'mt-1 line-clamp-2 text-sm text-slate-500';
                        message.textContent = item.message;
                        info.appendChild(message);
                    }

                    var meta = document.createElement('p');
                    meta.className = 'mt-2 text-xs text-slate-400 dark:text-slate-500';
                    var summary = item.summary || {};
                    var parts = [audienceLabel(item)];
                    if (item.status === 'sent') {
                        parts.push('delivered ' + Number(summary.delivered || 0) + '/' + Number(summary.device_tokens || 0) + ' device(s)');
                        if (Number(summary.failed || 0) > 0) {
                            parts.push(summary.failed + ' failed');
                        }
                    }
                    var when = relativeTime(item.created_at);
                    if (when) {
                        parts.push(when);
                    }
                    if (item.created_by && item.created_by.name) {
                        parts.push('by ' + item.created_by.name);
                    }
                    meta.textContent = parts.join(' | ');
                    info.appendChild(meta);

                    top.appendChild(info);

                    var actions = document.createElement('div');
                    actions.className = 'flex shrink-0 flex-col gap-2 sm:flex-row';

                    if (canSend) {
                        var resendBtn = document.createElement('button');
                        resendBtn.type = 'button';
                        resendBtn.className = 'inline-flex items-center justify-center gap-1.5 rounded-xl bg-[#4A88F7] px-3.5 py-2 text-xs font-semibold text-white shadow-sm transition hover:bg-[#3977E6] disabled:opacity-60';
                        resendBtn.innerHTML = '<svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M6 12L3.27 3.96a.6.6 0 01.8-.74L21 12 4.07 20.78a.6.6 0 01-.8-.74L6 12zm0 0h8"/></svg>' + 'Send Again';
                        resendBtn.addEventListener('click', function () {
                            resendCampaign(item, resendBtn);
                        });
                        actions.appendChild(resendBtn);
                    }

                    var reuseBtn = document.createElement('button');
                    reuseBtn.type = 'button';
                    reuseBtn.className = 'inline-flex items-center justify-center rounded-xl border border-slate-200 bg-white px-3.5 py-2 text-xs font-semibold text-slate-700 shadow-sm transition hover:bg-slate-100 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-200';
                    reuseBtn.textContent = 'Load to Form';
                    reuseBtn.addEventListener('click', function () {
                        loadToForm(item);
                    });
                    actions.appendChild(reuseBtn);

                    top.appendChild(actions);
                    card.appendChild(top);
                    historyList.appendChild(card);
                });
            }

            async function loadHistory() {
                try {
                    var response = await fetch(historyUrl, {
                        headers: { 'Accept': 'application/json' },
                        credentials: 'same-origin',
                    });
                    if (!response.ok) {
                        throw new Error('history request failed');
                    }
                    var result = await response.json();
                    renderHistory(Array.isArray(result.data) ? result.data : []);
                } catch (error) {
                    historyList.innerHTML = '';
                    var failed = document.createElement('p');
                    failed.className = 'rounded-2xl border border-dashed border-rose-300 bg-rose-50 px-4 py-6 text-center text-sm text-rose-600 dark:border-rose-800 dark:bg-rose-500/10 dark:text-rose-300';
                    failed.textContent = 'Could not load notification history. Try Refresh.';
                    historyList.appendChild(failed);
                }
            }

            function loadToForm(item) {
                titleInput.value = item.title || '';
                messageInput.value = item.message || '';
                typeInput.value = item.type || 'Announcement';
                deepLinkInput.value = item.deep_link || '';
                var audience = (item.audience || 'all').toLowerCase();
                var isCustom = audience === 'custom';
                var wanted = isCustom
                    ? 'specific'
                    : (audience === 'guests' || audience === 'registered' ? audience : 'all');
                var radio = document.querySelector('input[name="target_mode"][value="' + wanted + '"]');
                if (radio) {
                    radio.checked = true;
                }
                updateSpecificUserState();
                if (isCustom && targetUserSelect && Array.isArray(item.custom_user_ids) && item.custom_user_ids.length) {
                    targetUserSelect.value = String(item.custom_user_ids[0]);
                }
                syncPreview();
                form.scrollIntoView({ behavior: 'smooth', block: 'start' });
                if (window.adminToast) {
                    window.adminToast('Notification loaded into the form. Review and press Send.', { type: 'success' });
                }
            }

            async function resendCampaign(item, button) {
                var confirmed = true;
                if (window.adminSwalConfirm) {
                    var result = await window.adminSwalConfirm(
                        'Send this notification again?',
                        '"' + (item.title || '') + '" will be sent again to ' + audienceLabel(item).toLowerCase() + '.',
                        'Yes, send again'
                    );
                    confirmed = !!(result && result.isConfirmed);
                }
                if (!confirmed) {
                    return;
                }

                var body = new FormData();
                body.append('title', item.title || '');
                body.append('message', item.message || '');
                body.append('type', item.type || 'Announcement');
                body.append('audience', item.audience || 'all');
                body.append('deep_link', item.deep_link || '');
                body.append('action', 'send_now');
                if ((item.audience || '') === 'custom' && Array.isArray(item.custom_user_ids)) {
                    item.custom_user_ids.forEach(function (id) {
                        body.append('custom_user_ids[]', id);
                    });
                }

                var originalHtml = button ? button.innerHTML : '';
                if (button) {
                    button.disabled = true;
                    button.textContent = 'Sending...';
                }

                try {
                    var response = await fetch(form.dataset.sendUrl || '/admin/notifications/send', {
                        method: 'POST',
                        headers: {
                            'Accept': 'application/json',
                            'X-CSRF-TOKEN': csrfToken ? csrfToken.content : '',
                        },
                        credentials: 'same-origin',
                        body: body,
                    });
                    var payload = {};
                    try {
                        payload = await response.json();
                    } catch (error) {
                        payload = {};
                    }

                    if (!response.ok) {
                        if (window.adminSwalError) {
                            window.adminSwalError('Resend failed', payload.message || 'Notification could not be resent.');
                        }
                        return;
                    }

                    if (window.adminSwalSuccess) {
                        window.adminSwalSuccess('Notification resent', payload.message || 'Message sent successfully.');
                    }
                    loadHistory();
                } catch (error) {
                    if (window.adminSwalError) {
                        window.adminSwalError('Network error', 'The dashboard could not reach the send endpoint.');
                    }
                } finally {
                    if (button) {
                        button.disabled = false;
                        button.innerHTML = originalHtml;
                    }
                }
            }

            // ---- Wire up ----

            targetModeInputs.forEach(function (input) {
                input.addEventListener('change', updateSpecificUserState);
            });

            [titleInput, messageInput, typeInput, deepLinkInput].forEach(function (input) {
                input.addEventListener('input', syncPreview);
                input.addEventListener('change', syncPreview);
            });

            if (imageInput) {
                imageInput.addEventListener('change', syncImagePreview);
            }

            if (refreshHistoryButton) {
                refreshHistoryButton.addEventListener('click', loadHistory);
            }

            if (saveDraftButton) {
                saveDraftButton.addEventListener('click', function () {
                    var payload = {
                        title: titleInput.value,
                        message: messageInput.value,
                        type: typeInput.value,
                        deep_link: deepLinkInput.value,
                        target_mode: (document.querySelector('input[name="target_mode"]:checked') || {}).value || 'all',
                        target_user_id: targetUserSelect ? targetUserSelect.value : '',
                    };
                    localStorage.setItem(draftKey, JSON.stringify(payload));
                    saveDraftToast();
                });
            }

            if (form) {
                form.addEventListener('submit', async function (event) {
                    event.preventDefault();
                    resetFieldErrors();

                    if (imageInput && imageInput.files && imageInput.files[0] && !window.adminValidateFileSize(imageInput.files[0], 'Notification image')) {
                        return;
                    }

                    if (targetUserSelect && !targetUserSelect.disabled && !targetUserSelect.value) {
                        setFieldError(targetUserSelect, true);
                        if (window.adminSwalError) {
                            window.adminSwalError('User required', 'Choose a specific user before sending this notification.');
                        }
                        return;
                    }

                    setSubmitting(true);

                    try {
                        var sendUrl = form.dataset.sendUrl || '/admin/notifications/send';
                        var response = await fetch(sendUrl, {
                            method: 'POST',
                            headers: {
                                'Accept': 'application/json',
                                'X-CSRF-TOKEN': csrfToken ? csrfToken.content : '',
                            },
                            credentials: 'same-origin',
                            body: new FormData(form),
                        });
                        var result = {};
                        try {
                            result = await response.json();
                        } catch (error) {
                            result = {};
                        }

                        if (!response.ok) {
                            applyErrors(result.errors || {});
                            if (window.adminSwalError) {
                                window.adminSwalError('Send failed', result.message || 'Notification could not be sent.');
                            }
                            return;
                        }

                        resetFormState();
                        if (window.adminSwalSuccess) {
                            window.adminSwalSuccess(result.message || 'Notification sent', 'Message sent successfully.');
                        }
                        loadHistory();
                    } catch (error) {
                        if (window.adminSwalError) {
                            window.adminSwalError('Network error', 'The dashboard could not reach ' + (form.dataset.sendUrl || '/admin/notifications/send') + '. Open the page and backend on the same host and protocol.');
                        }
                    } finally {
                        setSubmitting(false);
                    }
                });
            }

            try {
                var rawDraft = localStorage.getItem(draftKey);
                if (rawDraft) {
                    var draft = JSON.parse(rawDraft);
                    titleInput.value = draft.title || '';
                    messageInput.value = draft.message || '';
                    typeInput.value = draft.type || 'Announcement';
                    deepLinkInput.value = draft.deep_link || '';
                    if (targetUserSelect) {
                        targetUserSelect.value = draft.target_user_id || '';
                    }
                    var draftTarget = document.querySelector('input[name="target_mode"][value="' + (draft.target_mode || 'all') + '"]');
                    if (draftTarget) {
                        draftTarget.checked = true;
                    }
                }
            } catch (error) {
                localStorage.removeItem(draftKey);
            }

            updateSpecificUserState();
            syncPreview();
            loadHistory();
        });
    </script>
@endsection
