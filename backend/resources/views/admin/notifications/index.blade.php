@extends('layouts.admin')

@section('title', 'Notifications')
@section('page-title', 'Notifications')

@section('content')
    <section class="space-y-6">
        <div class="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <div class="flex flex-col gap-4 lg:flex-row lg:items-end lg:justify-between">
                <div>
                    <span class="inline-flex rounded-full bg-primary-50 px-3 py-1 text-xs font-semibold uppercase tracking-[0.22em] text-primary-700 dark:bg-primary-500/10 dark:text-primary-100">Push Center</span>
                    <h1 class="mt-3 text-2xl font-semibold text-slate-900 dark:text-white">Send Notifications With Delivery Context</h1>
                    <p class="mt-2 max-w-3xl text-sm text-slate-500">Design and preview the notification payload, choose the audience, and follow the full system flow from admin action to mobile deep linking.</p>
                </div>
                <div class="grid gap-3 sm:grid-cols-3">
                    <div class="rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 dark:border-slate-800 dark:bg-slate-950">
                        <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Primary color</p>
                        <p class="mt-2 text-sm font-semibold text-slate-900 dark:text-white">#4A88F7</p>
                    </div>
                    <div class="rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 dark:border-slate-800 dark:bg-slate-950">
                        <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Mobile state</p>
                        <p class="mt-2 text-sm font-semibold text-slate-900 dark:text-white">Unread -&gt; Read</p>
                    </div>
                    <div class="rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 dark:border-slate-800 dark:bg-slate-950">
                        <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Delivery path</p>
                        <p class="mt-2 text-sm font-semibold text-slate-900 dark:text-white">Admin -&gt; Backend -&gt; FCM -&gt; App</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="grid gap-6 xl:grid-cols-[1.6fr_1fr]">
            <div class="space-y-6">
                <div class="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                    <div class="flex items-center justify-between gap-4">
                        <div>
                            <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Compose Notification</h2>
                            <p class="mt-1 text-sm text-slate-500">Create a reusable payload for announcements, alerts, documents, and order updates.</p>
                        </div>
                        <span class="rounded-full bg-primary-50 px-3 py-1 text-xs font-semibold text-primary-700 dark:bg-primary-500/10 dark:text-primary-100">Draft mode</span>
                    </div>

                    <form id="notification-form" class="mt-6 space-y-5" data-send-url="{{ route('admin.notifications.store', [], false) }}">
                        <div class="grid gap-5 md:grid-cols-2">
                            <div>
                                <label for="notification-title" class="text-sm font-semibold text-slate-700 dark:text-slate-200">Title</label>
                                <input id="notification-title" name="title" type="text" placeholder="Enter notification title" class="mt-2 h-12 w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-100" />
                            </div>
                            <div>
                                <label for="notification-type" class="text-sm font-semibold text-slate-700 dark:text-slate-200">Notification Type</label>
                                <select id="notification-type" name="type" class="mt-2 h-12 w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-100">
                                    <option value="Announcement">Announcement</option>
                                    <option value="Alert">Alert</option>
                                    <option value="Document">Document</option>
                                    <option value="Order">Order</option>
                                </select>
                            </div>
                        </div>

                        <div>
                            <label for="notification-message" class="text-sm font-semibold text-slate-700 dark:text-slate-200">Message</label>
                            <textarea id="notification-message" name="message" rows="5" placeholder="Write the message users should see on the device and inside the app." class="mt-2 w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-100"></textarea>
                        </div>

                        <div class="grid gap-5 md:grid-cols-2">
                            <div>
                                <label class="text-sm font-semibold text-slate-700 dark:text-slate-200">Target Users</label>
                                <div class="mt-2 grid gap-3 sm:grid-cols-2">
                                    <label class="flex items-center gap-3 rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm font-medium text-slate-700 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-200">
                                        <input type="radio" name="target_mode" value="all" checked class="h-4 w-4 border-slate-300 text-primary-600 focus:ring-primary-500" />
                                        All Users
                                    </label>
                                    <label class="flex items-center gap-3 rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm font-medium text-slate-700 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-200">
                                        <input type="radio" name="target_mode" value="specific" class="h-4 w-4 border-slate-300 text-primary-600 focus:ring-primary-500" />
                                        Specific User
                                    </label>
                                </div>
                            </div>
                            <div id="specific-user-panel" class="hidden">
                                <label for="target-user-id" class="text-sm font-semibold text-slate-700 dark:text-slate-200">Choose User</label>
                                <select id="target-user-id" name="target_user_id" class="mt-2 h-12 w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-100" disabled>
                                    <option value="">Select a user</option>
                                    @foreach ($users as $user)
                                        <option value="{{ $user->id }}">
                                            {{ trim(($user->name ?: 'User').' - '.($user->email ?: $user->phone ?: 'No contact')) }}
                                        </option>
                                    @endforeach
                                </select>
                                <p class="mt-2 text-xs text-slate-500">Only users who already opened the mobile app and registered a device token can receive push delivery.</p>
                            </div>
                        </div>

                        <div class="grid gap-5 md:grid-cols-2">
                            <div>
                                <label for="notification-image" class="text-sm font-semibold text-slate-700 dark:text-slate-200">Upload Image</label>
                                <input id="notification-image" name="image" type="file" accept="image/*" class="mt-2 block w-full rounded-2xl border border-dashed border-slate-300 bg-slate-50 px-4 py-3 text-sm text-slate-500 file:mr-4 file:rounded-xl file:border-0 file:bg-primary-50 file:px-3 file:py-2 file:text-sm file:font-semibold file:text-primary-700 hover:file:bg-primary-100 dark:border-slate-700 dark:bg-slate-950 dark:text-slate-400 dark:file:bg-primary-500/10 dark:file:text-primary-100" />
                            </div>
                            <div>
                                <label for="notification-link" class="text-sm font-semibold text-slate-700 dark:text-slate-200">Deep Link</label>
                                <input id="notification-link" name="deep_link" type="text" placeholder="/document/6 or https://..." class="mt-2 h-12 w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-100" />
                            </div>
                        </div>

                        <div class="flex flex-wrap gap-3 pt-2">
                            <button id="send-notification" type="submit" class="inline-flex items-center justify-center rounded-2xl bg-[#4A88F7] px-5 py-3 text-sm font-semibold text-white shadow-lg shadow-primary-500/20 transition hover:bg-[#3977E6]">Send Notification</button>
                            <button id="save-draft" type="button" class="inline-flex items-center justify-center rounded-2xl border border-slate-200 bg-white px-5 py-3 text-sm font-semibold text-slate-700 shadow-sm transition hover:bg-slate-50 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-200">Save Draft</button>
                        </div>
                        <p class="text-xs text-slate-500">Dashboard send flow: save notification in backend, send through Firebase, then the phone receives it if that user has a valid mobile token.</p>
                    </form>
                </div>

                <div class="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                    <div class="flex items-center justify-between gap-3">
                        <div>
                            <h2 class="text-lg font-semibold text-slate-900 dark:text-white">End-to-End System Flow</h2>
                            <p class="mt-1 text-sm text-slate-500">The notification lifecycle from admin action to user click and read state.</p>
                        </div>
                    </div>
                    <div class="mt-6 grid gap-4 md:grid-cols-5">
                        @foreach ([
                            ['Admin Dashboard', 'Create notification payload and audience'],
                            ['Backend + Database', 'Store payload and metadata'],
                            ['Firebase Push', 'Dispatch title, body, and deep link'],
                            ['Mobile App', 'Show system or in-app alert'],
                            ['Open + Mark Read', 'Navigate and update status'],
                        ] as [$title, $body])
                            <div class="rounded-2xl border border-slate-200 bg-slate-50 p-4 dark:border-slate-800 dark:bg-slate-950">
                                <p class="text-sm font-semibold text-slate-900 dark:text-white">{{ $title }}</p>
                                <p class="mt-2 text-xs leading-5 text-slate-500">{{ $body }}</p>
                            </div>
                        @endforeach
                    </div>
                </div>
            </div>

            <div class="space-y-6">
                <div class="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                    <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Push Preview</h2>
                    <p class="mt-1 text-sm text-slate-500">Live preview of the content users will see on mobile.</p>
                    <div class="mt-5 rounded-[28px] border border-slate-200 bg-slate-950 p-4 text-white shadow-inner dark:border-slate-800">
                        <div class="rounded-[24px] bg-white/10 p-4 backdrop-blur">
                            <div class="flex items-start gap-3">
                                <div class="flex h-11 w-11 items-center justify-center rounded-2xl bg-white/15 text-white">
                                    <svg class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M15 17h5l-1.4-1.4a2 2 0 01-.6-1.42V11a6 6 0 10-12 0v3.18a2 2 0 01-.59 1.41L4 17h5m6 0a3 3 0 11-6 0m6 0H9" />
                                    </svg>
                                </div>
                                <div class="min-w-0 flex-1">
                                    <p id="preview-type" class="text-xs font-semibold uppercase tracking-[0.24em] text-white/60">Announcement</p>
                                    <p id="preview-title" class="mt-2 text-base font-semibold">Title preview will appear here</p>
                                    <p id="preview-message" class="mt-2 text-sm leading-6 text-white/80">Message preview will update as you type into the form on the left.</p>
                                    <div class="mt-4 flex items-center justify-between text-xs text-white/55">
                                        <span>2 min ago</span>
                                        <span id="preview-link">No deep link</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                    <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Routing Rules</h2>
                    <div class="mt-5 space-y-3 text-sm">
                        @foreach ([
                            'If type = document -> open Document Detail',
                            'If type = order -> open Order Screen',
                            'If type = alert -> open Alert Page',
                            'If type = announcement -> open Announcement Screen',
                            'Unread -> User clicks -> Mark as read',
                            'Swipe left on mobile -> Mark read or delete',
                        ] as $rule)
                            <div class="flex items-start gap-3 rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-slate-600 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-300">
                                <span class="mt-0.5 inline-flex h-5 min-w-5 items-center justify-center rounded-full bg-primary-50 px-1 text-[11px] font-bold text-primary-700 dark:bg-primary-500/10 dark:text-primary-100">OK</span>
                                <span>{{ $rule }}</span>
                            </div>
                        @endforeach
                    </div>
                </div>
            </div>
        </div>
    </section>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
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
            var saveDraftButton = document.getElementById('save-draft');
            var sendButton = document.getElementById('send-notification');
            var draftKey = 'admin.notification.draft';
            var csrfToken = document.querySelector('meta[name="csrf-token"]');

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
                if (errors.target_user_id) {
                    setFieldError(targetUserSelect, true);
                }
            }

            function summaryText(summary) {
                if (!summary) {
                    return 'Notification was processed.';
                }
                return [
                    'Target users: ' + (summary.targeted_users || 0),
                    'Saved notifications: ' + (summary.saved_notifications || 0),
                    'Registered devices: ' + (summary.device_tokens || 0),
                    'Delivered to phones: ' + (summary.delivered || 0),
                    'Failed deliveries: ' + (summary.failed || 0),
                    'Removed invalid tokens: ' + (summary.removed_invalid_tokens || 0),
                ].join('\n');
            }

            function resetFormState() {
                form.reset();
                if (targetModeInputs[0]) {
                    targetModeInputs[0].checked = true;
                }
                localStorage.removeItem(draftKey);
                updateSpecificUserState();
                syncPreview();
            }

            function setSubmitting(isSubmitting) {
                if (!sendButton) {
                    return;
                }
                sendButton.disabled = isSubmitting;
                sendButton.textContent = isSubmitting ? 'Sending...' : 'Send Notification';
            }

            targetModeInputs.forEach(function (input) {
                input.addEventListener('change', updateSpecificUserState);
            });

            [titleInput, messageInput, typeInput, deepLinkInput].forEach(function (input) {
                input.addEventListener('input', syncPreview);
                input.addEventListener('change', syncPreview);
            });

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
                            window.adminSwalSuccess(result.message || 'Notification sent', summaryText(result.summary));
                        }
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
        });
    </script>
@endsection
