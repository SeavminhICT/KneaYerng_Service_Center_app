@extends('layouts.admin')

@section('title', __('Notifications'))
@section('page-title', __('Notifications'))

@section('content')
    @php
        $panelClass = 'rounded-lg border border-slate-200 bg-white shadow-sm dark:border-slate-800 dark:bg-slate-900';
        $inputClass = 'mt-2 h-11 w-full rounded-lg border border-slate-200 bg-white px-3 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-700 dark:bg-slate-950 dark:text-slate-100';
        $textareaClass = 'mt-2 w-full rounded-lg border border-slate-200 bg-white px-3 py-3 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-700 dark:bg-slate-950 dark:text-slate-100';
        $radioCardClass = 'flex min-h-[54px] cursor-pointer items-center gap-3 rounded-lg border border-slate-200 bg-white px-3 py-2.5 text-sm font-medium text-slate-700 transition hover:border-primary-300 hover:bg-primary-50/50 dark:border-slate-700 dark:bg-slate-950 dark:text-slate-200 dark:hover:border-primary-500/60 dark:hover:bg-primary-500/10';
        $sectionClass = 'border-t border-slate-100 pt-5 dark:border-slate-800/70';
    @endphp

    <section class="space-y-6"
        id="notification-page"
        data-can-send="{{ auth()->user()?->hasPermission('create_notification') ? '1' : '0' }}"
        data-can-cancel="{{ auth()->user()?->hasPermission('delete_notification') ? '1' : '0' }}"
        data-history-url="{{ route('admin.notifications.history', [], false) }}">
        <div class="{{ $panelClass }} p-5 sm:p-6">
            <div class="flex flex-col gap-5 lg:flex-row lg:items-center lg:justify-between">
                <div class="max-w-3xl">
                    <div class="flex flex-wrap items-center gap-2">
                        <span class="inline-flex rounded-full bg-primary-50 px-3 py-1 text-xs font-semibold uppercase tracking-wide text-primary-700 dark:bg-primary-500/10 dark:text-primary-100">{{ __('Push Center') }}</span>
                        <span class="inline-flex rounded-full bg-emerald-50 px-3 py-1 text-xs font-semibold text-emerald-700 dark:bg-emerald-500/10 dark:text-emerald-300">{{ __('Admin Notifications') }}</span>
                    </div>
                    <h1 class="mt-3 text-2xl font-semibold text-slate-900 dark:text-white">{{ __('Notifications') }}</h1>
                    <p class="mt-2 text-sm leading-6 text-slate-500 dark:text-slate-400">{{ __('Compose, schedule, preview, and review delivery results from one organized workspace.') }}</p>
                </div>

                <div class="grid w-full gap-3 sm:grid-cols-3 lg:w-auto lg:min-w-[420px]">
                    <div class="rounded-lg border border-slate-200 bg-slate-50 px-4 py-3 dark:border-slate-800 dark:bg-slate-950">
                        <p class="text-xs font-semibold uppercase tracking-wide text-slate-500 dark:text-slate-400">{{ __('Sent') }}</p>
                        <p id="stat-sent" class="mt-1 text-2xl font-semibold text-slate-900 dark:text-white">--</p>
                    </div>
                    <div class="rounded-lg border border-emerald-200 bg-emerald-50 px-4 py-3 dark:border-emerald-500/30 dark:bg-emerald-500/10">
                        <p class="text-xs font-semibold uppercase tracking-wide text-emerald-700 dark:text-emerald-300">{{ __('Delivered') }}</p>
                        <p id="stat-delivered" class="mt-1 text-2xl font-semibold text-emerald-700 dark:text-emerald-300">--</p>
                    </div>
                    <div class="rounded-lg border border-rose-200 bg-rose-50 px-4 py-3 dark:border-rose-500/30 dark:bg-rose-500/10">
                        <p class="text-xs font-semibold uppercase tracking-wide text-rose-700 dark:text-rose-300">{{ __('Failed') }}</p>
                        <p id="stat-failed" class="mt-1 text-2xl font-semibold text-rose-700 dark:text-rose-300">--</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="grid gap-6 xl:grid-cols-[minmax(0,1.45fr)_minmax(340px,0.85fr)]">
            <div class="space-y-6">
                <div class="{{ $panelClass }} p-5 sm:p-6">
                    <div class="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
                        <div>
                            <h2 class="text-lg font-semibold text-slate-900 dark:text-white">{{ __('Compose Notification') }}</h2>
                            <p class="mt-1 text-sm text-slate-500 dark:text-slate-400">{{ __('Required payload, target audience, delivery timing, and optional routing.') }}</p>
                        </div>
                        <span class="inline-flex w-fit rounded-full bg-amber-50 px-3 py-1 text-xs font-semibold text-amber-700 dark:bg-amber-500/10 dark:text-amber-300">{{ __('Draft ready') }}</span>
                    </div>

                    <form id="notification-form" class="mt-6 space-y-5" data-send-url="{{ route('admin.notifications.store', [], false) }}" data-generate-message-url="{{ route('admin.notifications.generate-message', [], false) }}">
                        <div class="flex items-center gap-3">
                            <span class="flex h-7 w-7 items-center justify-center rounded-lg bg-primary-50 text-sm font-semibold text-primary-700 dark:bg-primary-500/10 dark:text-primary-200">1</span>
                            <div>
                                <h3 class="text-sm font-semibold text-slate-900 dark:text-white">{{ __('Content') }}</h3>
                                <p class="text-xs text-slate-500 dark:text-slate-400">{{ __('Title, type, and message') }}</p>
                            </div>
                        </div>

                        <div class="grid gap-4 md:grid-cols-2">
                            <div>
                                <label for="notification-title" class="text-sm font-semibold text-slate-700 dark:text-slate-200">{{ __('Title') }}</label>
                                <input id="notification-title" name="title" type="text" placeholder="{{ __('Enter notification title') }}" class="{{ $inputClass }}" />
                            </div>
                            <div>
                                <label for="notification-type" class="text-sm font-semibold text-slate-700 dark:text-slate-200">{{ __('Type') }}</label>
                                <select id="notification-type" name="type" class="{{ $inputClass }}">
                                    <option value="Alert">{{ __('Alert') }}</option>
                                    <option value="Announcement">{{ __('Announcement') }}</option>
                                    <option value="Promotion">{{ __('Promotion') }}</option>
                                    <option value="Info">{{ __('Info') }}</option>
                                    <option value="Reminder">{{ __('Reminder') }}</option>
                                    <option value="Document">{{ __('Document') }}</option>
                                    <option value="Order">{{ __('Order') }}</option>
                                </select>
                            </div>
                        </div>

                        <div>
                            <div class="flex flex-wrap items-center justify-between gap-2">
                                <label for="notification-message" class="text-sm font-semibold text-slate-700 dark:text-slate-200">{{ __('Message') }}</label>
                                <button id="ai-generate-message-btn" type="button" class="inline-flex h-8 items-center gap-2 rounded-lg border border-primary-200 bg-primary-50 px-3 text-xs font-semibold text-primary-700 transition hover:bg-primary-100 disabled:cursor-not-allowed disabled:opacity-60 dark:border-primary-500/40 dark:bg-primary-500/10 dark:text-primary-200">
                                    <svg id="ai-generate-message-spinner" class="hidden h-3.5 w-3.5 animate-spin" fill="none" viewBox="0 0 24 24">
                                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                                        <path class="opacity-80" fill="currentColor" d="M4 12a8 8 0 018-8v8z"></path>
                                    </svg>
                                    <span>{{ __('Generate') }}</span>
                                </button>
                            </div>
                            <textarea id="notification-message" name="message" rows="5" placeholder="{{ __('Write the message users should see on the device and inside the app.') }}" class="{{ $textareaClass }}"></textarea>
                            <p id="ai-generate-message-error" class="mt-1 text-xs text-rose-600"></p>
                        </div>

                        <div class="{{ $sectionClass }}">
                            <div class="flex items-center gap-3">
                                <span class="flex h-7 w-7 items-center justify-center rounded-lg bg-emerald-50 text-sm font-semibold text-emerald-700 dark:bg-emerald-500/10 dark:text-emerald-300">2</span>
                                <div>
                                    <h3 class="text-sm font-semibold text-slate-900 dark:text-white">{{ __('Audience') }}</h3>
                                    <p class="text-xs text-slate-500 dark:text-slate-400">{{ __('Recipients and device groups') }}</p>
                                </div>
                            </div>

                            <div class="mt-4 grid gap-4 lg:grid-cols-[minmax(0,1fr)_minmax(240px,0.75fr)]">
                                <div class="grid gap-3 sm:grid-cols-2">
                                    <label class="{{ $radioCardClass }}">
                                        <input type="radio" name="target_mode" value="all" checked class="h-4 w-4 border-slate-300 text-primary-600 focus:ring-primary-500" />
                                        <span>{{ __('All devices') }}</span>
                                    </label>
                                    <label class="{{ $radioCardClass }}">
                                        <input type="radio" name="target_mode" value="registered" class="h-4 w-4 border-slate-300 text-primary-600 focus:ring-primary-500" />
                                        <span>{{ __('Registered users') }}</span>
                                    </label>
                                    <label class="{{ $radioCardClass }}">
                                        <input type="radio" name="target_mode" value="guests" class="h-4 w-4 border-slate-300 text-primary-600 focus:ring-primary-500" />
                                        <span>{{ __('Guest devices') }}</span>
                                    </label>
                                    <label class="{{ $radioCardClass }}">
                                        <input type="radio" name="target_mode" value="specific" class="h-4 w-4 border-slate-300 text-primary-600 focus:ring-primary-500" />
                                        <span>{{ __('Specific user') }}</span>
                                    </label>
                                </div>

                                <div id="specific-user-panel" class="hidden rounded-lg border border-slate-200 bg-slate-50 p-4 dark:border-slate-700 dark:bg-slate-950">
                                    <label for="target-user-id" class="text-sm font-semibold text-slate-700 dark:text-slate-200">{{ __('Choose User') }}</label>
                                    <select id="target-user-id" name="target_user_id" class="{{ $inputClass }}" disabled>
                                        <option value="">{{ __('Select a user') }}</option>
                                        @foreach ($users as $user)
                                            <option value="{{ $user->id }}">
                                                {{ trim(($user->name ?: __('User')).' - '.($user->email ?: $user->phone ?: __('No contact'))) }}
                                            </option>
                                        @endforeach
                                    </select>
                                    <p class="mt-2 text-xs leading-5 text-slate-500 dark:text-slate-400">{{ __('Only users with registered device tokens can receive push delivery.') }}</p>
                                </div>
                            </div>
                        </div>

                        <div class="{{ $sectionClass }}">
                            <div class="flex items-center gap-3">
                                <span class="flex h-7 w-7 items-center justify-center rounded-lg bg-slate-100 text-sm font-semibold text-slate-700 dark:bg-slate-800 dark:text-slate-200">3</span>
                                <div>
                                    <h3 class="text-sm font-semibold text-slate-900 dark:text-white">{{ __('Media & Link') }}</h3>
                                    <p class="text-xs text-slate-500 dark:text-slate-400">{{ __('Optional image and deep link') }}</p>
                                </div>
                            </div>

                            <div class="mt-4 grid gap-4 md:grid-cols-2">
                                <div>
                                    <label for="notification-image" class="text-sm font-semibold text-slate-700 dark:text-slate-200">{{ __('Image') }}</label>
                                    <input id="notification-image" name="image" type="file" accept="image/*" class="mt-2 block w-full rounded-lg border border-dashed border-slate-300 bg-white px-3 py-2.5 text-sm text-slate-500 file:mr-4 file:rounded-md file:border-0 file:bg-primary-50 file:px-3 file:py-2 file:text-sm file:font-semibold file:text-primary-700 hover:file:bg-primary-100 dark:border-slate-700 dark:bg-slate-950 dark:text-slate-400 dark:file:bg-primary-500/10 dark:file:text-primary-100" />
                                </div>
                                <div>
                                    <label for="notification-link" class="text-sm font-semibold text-slate-700 dark:text-slate-200">{{ __('Deep Link') }}</label>
                                    <input id="notification-link" name="deep_link" type="text" placeholder="/document/6 or https://..." class="{{ $inputClass }}" />
                                </div>
                            </div>
                        </div>

                        <input type="hidden" id="notification-action" name="action" value="send_now" />

                        <div class="{{ $sectionClass }}">
                            <div class="flex items-center gap-3">
                                <span class="flex h-7 w-7 items-center justify-center rounded-lg bg-amber-50 text-sm font-semibold text-amber-700 dark:bg-amber-500/10 dark:text-amber-300">4</span>
                                <div>
                                    <h3 class="text-sm font-semibold text-slate-900 dark:text-white">{{ __('Delivery') }}</h3>
                                    <p class="text-xs text-slate-500 dark:text-slate-400">{{ __('Immediate send or scheduled campaign') }}</p>
                                </div>
                            </div>
                            <div class="mt-4 grid gap-3 sm:grid-cols-3">
                                <label class="{{ $radioCardClass }}">
                                    <input type="radio" name="schedule_type" value="now" checked class="h-4 w-4 border-slate-300 text-primary-600 focus:ring-primary-500" />
                                    <span>{{ __('Now') }}</span>
                                </label>
                                <label class="{{ $radioCardClass }}">
                                    <input type="radio" name="schedule_type" value="date" class="h-4 w-4 border-slate-300 text-primary-600 focus:ring-primary-500" />
                                    <span>{{ __('Date & time') }}</span>
                                </label>
                                <label class="{{ $radioCardClass }}">
                                    <input type="radio" name="schedule_type" value="delay" class="h-4 w-4 border-slate-300 text-primary-600 focus:ring-primary-500" />
                                    <span>{{ __('Preset delay') }}</span>
                                </label>
                            </div>
                        </div>

                        <div id="schedule-date-panel" class="hidden rounded-lg border border-slate-200 bg-slate-50 p-4 dark:border-slate-700 dark:bg-slate-950">
                            <label for="scheduled-for-input" class="text-sm font-semibold text-slate-700 dark:text-slate-200">{{ __('Choose Date & Time') }}</label>
                            <input id="scheduled-for-input" name="scheduled_for" type="datetime-local" class="{{ $inputClass }}" />
                        </div>

                        <div id="schedule-delay-panel" class="hidden rounded-lg border border-slate-200 bg-slate-50 p-4 dark:border-slate-700 dark:bg-slate-950">
                            <label for="schedule-delay-select" class="text-sm font-semibold text-slate-700 dark:text-slate-200">{{ __('Choose Delay Duration') }}</label>
                            <select id="schedule-delay-select" name="schedule_delay" class="{{ $inputClass }}">
                                <option value="1_day">{{ __('1 Day') }}</option>
                                <option value="3_days">{{ __('3 Days') }}</option>
                                <option value="5_days">{{ __('5 Days') }}</option>
                                <option value="1_week">{{ __('1 Week') }}</option>
                            </select>
                            <div class="mt-3 border-t border-slate-200 pt-3 dark:border-slate-700">
                                <button id="add-delay-option-toggle" type="button" class="inline-flex h-8 items-center gap-2 rounded-lg border border-slate-200 bg-white px-3 text-xs font-semibold text-slate-700 transition hover:bg-slate-100 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-200">
                                    <svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
                                    </svg>
                                    <span>{{ __('Custom duration') }}</span>
                                </button>

                                <div id="add-delay-option-form" class="mt-3 hidden rounded-lg border border-dashed border-slate-300 bg-white p-3 dark:border-slate-700 dark:bg-slate-900">
                                    <div class="grid gap-2 sm:grid-cols-[96px_minmax(0,1fr)_auto_auto]">
                                        <input id="delay-option-amount" type="number" min="1" max="9999" value="1" class="h-10 rounded-lg border border-slate-200 bg-white px-3 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-700 dark:bg-slate-950 dark:text-slate-100" />
                                        <select id="delay-option-unit" class="h-10 rounded-lg border border-slate-200 bg-white px-3 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-700 dark:bg-slate-950 dark:text-slate-100">
                                            <option value="hours">{{ __('Hours') }}</option>
                                            <option value="days" selected>{{ __('Days') }}</option>
                                            <option value="weeks">{{ __('Weeks') }}</option>
                                        </select>
                                        <button id="delay-option-add" type="button" class="h-10 rounded-lg bg-[#4A88F7] px-4 text-sm font-semibold text-white transition hover:bg-[#3977E6]">{{ __('Add') }}</button>
                                        <button id="delay-option-cancel" type="button" class="h-10 rounded-lg border border-slate-200 px-4 text-sm font-semibold text-slate-600 dark:border-slate-700 dark:text-slate-300">{{ __('Cancel') }}</button>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="flex flex-col-reverse gap-3 border-t border-slate-100 pt-5 dark:border-slate-800/70 sm:flex-row sm:items-center sm:justify-between">
                            <button id="save-draft" type="button" class="inline-flex h-10 items-center justify-center rounded-lg border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-700 shadow-sm transition hover:bg-slate-50 dark:border-slate-700 dark:bg-slate-950 dark:text-slate-200">
                                {{ __('Save Draft') }}
                            </button>
                            @if (auth()->user()?->hasPermission('create_notification'))
                                <button id="send-notification" type="submit" class="inline-flex h-10 items-center justify-center gap-2 rounded-lg bg-[#4A88F7] px-5 text-sm font-semibold text-white shadow-sm transition hover:bg-[#3977E6] disabled:cursor-not-allowed disabled:opacity-60">
                                    <svg class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M6 12L3.27 3.96a.6.6 0 01.8-.74L21 12 4.07 20.78a.6.6 0 01-.8-.74L6 12zm0 0h8" />
                                    </svg>
                                    <span>{{ __('Send Notification') }}</span>
                                </button>
                            @endif
                        </div>
                    </form>
                </div>

                <div class="{{ $panelClass }} p-5 sm:p-6">
                    <div class="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
                        <div>
                            <h2 class="text-lg font-semibold text-slate-900 dark:text-white">{{ __('History') }}</h2>
                            <p class="mt-1 text-sm text-slate-500 dark:text-slate-400">{{ __('Latest campaigns and delivery outcomes') }}</p>
                        </div>
                        <button id="refresh-history" type="button" class="inline-flex h-10 w-fit items-center gap-2 rounded-lg border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-700 shadow-sm transition hover:bg-slate-50 dark:border-slate-700 dark:bg-slate-950 dark:text-slate-200">
                            <svg class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M4 4v5h5M20 20v-5h-5M5.07 15a7 7 0 0011.9 2.4M18.93 9a7 7 0 00-11.9-2.4" />
                            </svg>
                            {{ __('Refresh') }}
                        </button>
                    </div>
                    <div id="history-list" class="mt-5 space-y-3">
                        <p id="history-empty" class="rounded-lg border border-dashed border-slate-300 bg-slate-50 px-4 py-6 text-center text-sm text-slate-500 dark:border-slate-700 dark:bg-slate-950">{{ __('Loading history...') }}</p>
                    </div>
                    <div id="history-pagination" class="mt-4 hidden items-center justify-between gap-3"></div>
                </div>
            </div>

            <div class="space-y-6 xl:sticky xl:top-24 xl:self-start">
                <div class="{{ $panelClass }} p-5 sm:p-6">
                    <div class="flex items-start justify-between gap-4">
                        <div>
                            <h2 class="text-lg font-semibold text-slate-900 dark:text-white">{{ __('Mobile Preview') }}</h2>
                            <p class="mt-1 text-sm text-slate-500 dark:text-slate-400">{{ __('Payload snapshot') }}</p>
                        </div>
                    </div>
                    <div class="mt-5 rounded-[28px] border border-slate-800 bg-slate-950 p-4 text-white shadow-inner">
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
                                    <p id="preview-type" class="text-xs font-semibold uppercase tracking-wide text-white/60">{{ __('Alert') }}</p>
                                    <p id="preview-title" class="mt-2 text-base font-semibold">{{ __('Title preview will appear here') }}</p>
                                    <p id="preview-message" class="mt-2 text-sm leading-6 text-white/80">{{ __('Message preview will update as you type into the form on the left.') }}</p>
                                    <img id="preview-image" src="" alt="" class="mt-3 hidden max-h-40 w-full rounded-lg object-cover" />
                                    <div class="mt-4 flex items-center justify-between text-xs text-white/55">
                                        <span>{{ __('now') }}</span>
                                        <span id="preview-link">{{ __('No deep link') }}</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <dl class="mt-4 grid gap-3 sm:grid-cols-2 xl:grid-cols-1 2xl:grid-cols-2">
                        <div class="rounded-lg border border-slate-200 bg-slate-50 px-3 py-3 dark:border-slate-800 dark:bg-slate-950">
                            <dt class="text-xs font-semibold uppercase tracking-wide text-slate-500 dark:text-slate-400">{{ __('Audience') }}</dt>
                            <dd id="preview-audience" class="mt-1 text-sm font-semibold text-slate-900 dark:text-white">{{ __('All devices') }}</dd>
                        </div>
                        <div class="rounded-lg border border-slate-200 bg-slate-50 px-3 py-3 dark:border-slate-800 dark:bg-slate-950">
                            <dt class="text-xs font-semibold uppercase tracking-wide text-slate-500 dark:text-slate-400">{{ __('Delivery') }}</dt>
                            <dd id="preview-schedule" class="mt-1 text-sm font-semibold text-slate-900 dark:text-white">{{ __('Now') }}</dd>
                        </div>
                    </dl>
                </div>
            </div>
        </div>
    </section>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var page = document.getElementById('notification-page');
            var canSend = page && page.dataset.canSend === '1';
            var canCancel = page && page.dataset.canCancel === '1';
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
            var previewAudience = document.getElementById('preview-audience');
            var previewSchedule = document.getElementById('preview-schedule');
            var saveDraftButton = document.getElementById('save-draft');
            var sendButton = document.getElementById('send-notification');
            var aiGenerateMessageBtn = document.getElementById('ai-generate-message-btn');
            var aiGenerateMessageSpinner = document.getElementById('ai-generate-message-spinner');
            var aiGenerateMessageError = document.getElementById('ai-generate-message-error');
            var refreshHistoryButton = document.getElementById('refresh-history');
            var historyList = document.getElementById('history-list');
            var historyPagination = document.getElementById('history-pagination');
            var historyPage = 1;
            var historyPerPage = 10;
            var statSent = document.getElementById('stat-sent');
            var statDelivered = document.getElementById('stat-delivered');
            var statFailed = document.getElementById('stat-failed');
            var draftKey = 'admin.notification.draft';
            var csrfToken = document.querySelector('meta[name="csrf-token"]');

            var scheduleTypeInputs = document.querySelectorAll('input[name="schedule_type"]');
            var scheduleDatePanel = document.getElementById('schedule-date-panel');
            var scheduleDelayPanel = document.getElementById('schedule-delay-panel');
            var scheduledForInput = document.getElementById('scheduled-for-input');
            var scheduleDelaySelect = document.getElementById('schedule-delay-select');
            var actionInput = document.getElementById('notification-action');
            var addDelayToggle = document.getElementById('add-delay-option-toggle');
            var addDelayForm = document.getElementById('add-delay-option-form');
            var delayAmountInput = document.getElementById('delay-option-amount');
            var delayUnitSelect = document.getElementById('delay-option-unit');
            var delayAddButton = document.getElementById('delay-option-add');
            var delayCancelButton = document.getElementById('delay-option-cancel');
            var customDelayKey = 'admin.notification.customDelayOptions';

            if (previewClock) {
                var now = new Date();
                previewClock.textContent = String(now.getHours()).padStart(2, '0') + ':' + String(now.getMinutes()).padStart(2, '0');
            }

            function delayOptionValue(amount, unit) {
                var singularUnit = ({ hours: 'hour', days: 'day', weeks: 'week' })[unit] || 'day';
                return amount + '_' + (amount === 1 ? singularUnit : singularUnit + 's');
            }

            function delayOptionLabel(amount, unit) {
                var unitLabel = ({ hours: 'Hour', days: 'Day', weeks: 'Week' })[unit] || 'Day';
                if (amount !== 1) {
                    unitLabel += 's';
                }
                return amount + ' ' + unitLabel;
            }

            function delayLabelFromValue(value) {
                var match = /^(\d{1,4})_(hour|hours|day|days|week|weeks)$/.exec(value || '');
                if (!match) {
                    return null;
                }
                var amount = parseInt(match[1], 10);
                var unitWord = match[2].replace(/s$/, '');
                var label = unitWord.charAt(0).toUpperCase() + unitWord.slice(1);
                if (amount !== 1) {
                    label += 's';
                }
                return amount + ' ' + label;
            }

            function persistCustomDelayOption(value, label) {
                var saved = [];
                try {
                    saved = JSON.parse(localStorage.getItem(customDelayKey) || '[]');
                } catch (error) {
                    saved = [];
                }
                if (!saved.some(function (item) { return item && item.value === value; })) {
                    saved.push({ value: value, label: label });
                    localStorage.setItem(customDelayKey, JSON.stringify(saved));
                }
            }

            function addDelayOption(value, label, shouldPersist, shouldSelect) {
                if (!scheduleDelaySelect) {
                    return;
                }
                var existing = scheduleDelaySelect.querySelector('option[value="' + value + '"]');
                if (!existing) {
                    var option = document.createElement('option');
                    option.value = value;
                    option.textContent = label;
                    scheduleDelaySelect.appendChild(option);
                    if (shouldPersist !== false) {
                        persistCustomDelayOption(value, label);
                    }
                }
                if (shouldSelect !== false) {
                    scheduleDelaySelect.value = value;
                    syncPreview();
                }
            }

            function ensureDelayOptionExists(value) {
                if (!value || !scheduleDelaySelect || scheduleDelaySelect.querySelector('option[value="' + value + '"]')) {
                    return;
                }
                var label = delayLabelFromValue(value);
                if (label) {
                    addDelayOption(value, label, false, false);
                }
            }

            function restoreCustomDelayOptions() {
                if (!scheduleDelaySelect) {
                    return;
                }
                var saved = [];
                try {
                    saved = JSON.parse(localStorage.getItem(customDelayKey) || '[]');
                } catch (error) {
                    saved = [];
                }
                saved.forEach(function (item) {
                    if (item && item.value && item.label) {
                        ensureDelayOptionExists(item.value);
                    }
                });
            }

            restoreCustomDelayOptions();

            if (addDelayToggle && addDelayForm) {
                addDelayToggle.addEventListener('click', function () {
                    addDelayForm.classList.toggle('hidden');
                    if (!addDelayForm.classList.contains('hidden') && delayAmountInput) {
                        delayAmountInput.focus();
                        delayAmountInput.select();
                    }
                });
            }

            if (delayCancelButton && addDelayForm) {
                delayCancelButton.addEventListener('click', function () {
                    addDelayForm.classList.add('hidden');
                });
            }

            if (delayAddButton) {
                delayAddButton.addEventListener('click', function () {
                    var amount = parseInt(delayAmountInput ? delayAmountInput.value : '', 10);
                    if (!amount || amount < 1 || amount > 9999) {
                        if (window.adminSwalError) {
                            window.adminSwalError('Invalid duration', 'Enter a number from 1 to 9999.');
                        }
                        return;
                    }
                    var unit = delayUnitSelect ? delayUnitSelect.value : 'days';
                    addDelayOption(delayOptionValue(amount, unit), delayOptionLabel(amount, unit), true, true);
                    if (addDelayForm) {
                        addDelayForm.classList.add('hidden');
                    }
                });
            }

            function setSendButtonLabel(label) {
                if (!sendButton) {
                    return;
                }
                var labelNode = sendButton.querySelector('span');
                if (labelNode) {
                    labelNode.textContent = label;
                    return;
                }
                sendButton.textContent = label;
            }

            function sendButtonIdleLabel() {
                var scheduleType = (document.querySelector('input[name="schedule_type"]:checked') || {}).value || 'now';
                return scheduleType === 'now' ? 'Send Notification' : 'Schedule Notification';
            }

            function audienceSelectionLabel() {
                var mode = (document.querySelector('input[name="target_mode"]:checked') || {}).value || 'all';
                if (mode === 'specific') {
                    var selected = targetUserSelect && targetUserSelect.selectedOptions ? targetUserSelect.selectedOptions[0] : null;
                    return selected && targetUserSelect.value ? selected.textContent.trim() : 'Specific user';
                }
                var labels = {
                    all: 'All devices',
                    registered: 'Registered users',
                    guests: 'Guest devices',
                };
                return labels[mode] || 'All devices';
            }

            function scheduleSelectionLabel() {
                var scheduleType = (document.querySelector('input[name="schedule_type"]:checked') || {}).value || 'now';
                if (scheduleType === 'date') {
                    if (!scheduledForInput || !scheduledForInput.value) {
                        return 'Date & time';
                    }
                    var scheduledAt = new Date(scheduledForInput.value);
                    return isNaN(scheduledAt.getTime()) ? 'Date & time' : scheduledAt.toLocaleString();
                }
                if (scheduleType === 'delay') {
                    var selected = scheduleDelaySelect && scheduleDelaySelect.selectedOptions ? scheduleDelaySelect.selectedOptions[0] : null;
                    return selected ? selected.textContent.trim() : 'Preset delay';
                }
                return 'Now';
            }

            function updateSpecificUserState() {
                var mode = document.querySelector('input[name="target_mode"]:checked');
                var isSpecific = !!mode && mode.value === 'specific';
                if (specificUserPanel) {
                    specificUserPanel.classList.toggle('hidden', !isSpecific);
                }
                if (targetUserSelect) {
                    targetUserSelect.disabled = !isSpecific;
                    if (!isSpecific) {
                        targetUserSelect.value = '';
                    }
                }
                syncPreview();
            }

            function updateScheduleState() {
                var scheduleType = (document.querySelector('input[name="schedule_type"]:checked') || {}).value || 'now';
                if (scheduleDatePanel) {
                    scheduleDatePanel.classList.toggle('hidden', scheduleType !== 'date');
                }
                if (scheduleDelayPanel) {
                    scheduleDelayPanel.classList.toggle('hidden', scheduleType !== 'delay');
                }
                if (actionInput) {
                    actionInput.value = (scheduleType === 'now') ? 'send_now' : 'schedule';
                }
                if (!sendButton || !sendButton.disabled) {
                    setSendButtonLabel(sendButtonIdleLabel());
                }
                syncPreview();
            }

            function syncPreview() {
                previewTitle.textContent = titleInput.value.trim() || 'Title preview will appear here';
                previewMessage.textContent = messageInput.value.trim() || 'Message preview will update as you type into the form on the left.';
                previewType.textContent = typeInput.value || 'Alert';
                previewLink.textContent = deepLinkInput.value.trim() || 'No deep link';
                if (previewAudience) {
                    previewAudience.textContent = audienceSelectionLabel();
                }
                if (previewSchedule) {
                    previewSchedule.textContent = scheduleSelectionLabel();
                }
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

            function hasPushSetupIssue(payload) {
                var summary = (payload && payload.summary) || {};
                if (!summary.push_error && payload && payload.history_item && payload.history_item.summary) {
                    summary = payload.history_item.summary;
                }
                return !!summary.push_error || Number(summary.push_disabled || 0) > 0;
            }

            function pushSummary(payload) {
                var summary = (payload && payload.summary) || {};
                if (!summary.push_error && payload && payload.history_item && payload.history_item.summary) {
                    summary = payload.history_item.summary;
                }
                return summary || {};
            }

            function escapeHtml(value) {
                return String(value || '')
                    .replace(/&/g, '&amp;')
                    .replace(/</g, '&lt;')
                    .replace(/>/g, '&gt;')
                    .replace(/"/g, '&quot;');
            }

            function cleanPushWarningMessage(message, summary) {
                var cleaned = String(message || 'Notification saved, but push delivery is not configured.');
                if (summary && summary.push_error) {
                    cleaned = cleaned.replace(' Push setup issue: ' + summary.push_error, '');
                    cleaned = cleaned.replace('Push setup issue: ' + summary.push_error, '');
                }
                return cleaned.trim();
            }

            function showSendResult(defaultSuccessTitle, payload) {
                var summary = pushSummary(payload);
                var message = cleanPushWarningMessage((payload && payload.message) || 'Notification processed.', summary);
                if (hasPushSetupIssue(payload)) {
                    if (window.Swal) {
                        var delivered = Number(summary.delivered || 0);
                        var tokens = Number(summary.device_tokens || 0);
                        var saved = Number(summary.saved_notifications || 0);
                        var pushError = summary.push_error || 'Firebase push delivery is disabled on this server.';
                        window.Swal.fire({
                            icon: 'warning',
                            title: 'Notification saved',
                            width: 560,
                            html: ''
                                + '<div style="text-align:left">'
                                + '<p style="margin:0 0 14px;color:#475569;font-size:14px;line-height:1.55;text-align:center">' + escapeHtml(message) + '</p>'
                                + '<div style="display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:8px;margin:0 0 14px">'
                                + '<div style="border:1px solid #e2e8f0;border-radius:12px;padding:10px;background:#f8fafc;text-align:center"><div style="font-size:20px;font-weight:700;color:#0f172a">' + saved + '</div><div style="font-size:11px;font-weight:700;color:#64748b;text-transform:uppercase;letter-spacing:.06em">Inbox Saved</div></div>'
                                + '<div style="border:1px solid #fed7aa;border-radius:12px;padding:10px;background:#fff7ed;text-align:center"><div style="font-size:20px;font-weight:700;color:#c2410c">' + delivered + '/' + tokens + '</div><div style="font-size:11px;font-weight:700;color:#9a3412;text-transform:uppercase;letter-spacing:.06em">Push Delivered</div></div>'
                                + '</div>'
                                + '<div style="border:1px solid #fed7aa;border-radius:12px;background:#fff7ed;padding:12px">'
                                + '<div style="font-size:12px;font-weight:700;color:#9a3412;text-transform:uppercase;letter-spacing:.08em">Push setup issue</div>'
                                + '<code style="display:block;margin-top:7px;color:#7c2d12;font-size:12px;line-height:1.45;white-space:pre-wrap;word-break:break-word">' + escapeHtml(pushError) + '</code>'
                                + '</div>'
                                + '<p style="margin:12px 0 0;color:#64748b;font-size:12px;line-height:1.45">Add a Firebase Admin SDK service account JSON at the configured <code>FIREBASE_CREDENTIALS</code> path, then clear the Laravel config cache.</p>'
                                + '</div>',
                            confirmButtonColor: '#d97706',
                        });
                    } else if (window.adminToast) {
                        window.adminToast(message, { type: 'error', duration: 9000 });
                    }
                    return;
                }

                if (window.adminSwalSuccess) {
                    window.adminSwalSuccess(defaultSuccessTitle || 'Notification sent', message);
                } else if (window.adminToast) {
                    window.adminToast(message, { type: 'success' });
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
                [titleInput, messageInput, typeInput, deepLinkInput, imageInput, targetUserSelect, scheduledForInput, scheduleDelaySelect].forEach(function (field) {
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
                if (errors.scheduled_for) {
                    setFieldError(scheduledForInput, true);
                }
                if (errors.schedule_delay) {
                    setFieldError(scheduleDelaySelect, true);
                }
            }

            function resetFormState() {
                form.reset();
                if (targetModeInputs[0]) {
                    targetModeInputs[0].checked = true;
                }
                var defaultSchedule = document.querySelector('input[name="schedule_type"][value="now"]');
                if (defaultSchedule) {
                    defaultSchedule.checked = true;
                }
                localStorage.removeItem(draftKey);
                updateSpecificUserState();
                updateScheduleState();
                syncPreview();
                syncImagePreview();
            }

            function setSubmitting(isSubmitting) {
                if (!sendButton) {
                    return;
                }
                sendButton.disabled = isSubmitting;
                setSendButtonLabel(isSubmitting ? 'Sending...' : sendButtonIdleLabel());
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
                    all: 'Customers + guest devices',
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

            function metricPill(label, value, tone) {
                var pill = document.createElement('div');
                var tones = {
                    slate: 'border-slate-200 bg-white text-slate-900 dark:border-slate-700 dark:bg-slate-900 dark:text-white',
                    emerald: 'border-emerald-200 bg-emerald-50 text-emerald-700 dark:border-emerald-500/30 dark:bg-emerald-500/10 dark:text-emerald-300',
                    rose: 'border-rose-200 bg-rose-50 text-rose-700 dark:border-rose-500/30 dark:bg-rose-500/10 dark:text-rose-300',
                };
                pill.className = 'rounded-lg border px-3 py-2 ' + (tones[tone] || tones.slate);

                var number = document.createElement('p');
                number.className = 'text-sm font-semibold';
                number.textContent = value;

                var caption = document.createElement('p');
                caption.className = 'mt-0.5 text-[11px] font-semibold uppercase tracking-wide opacity-70';
                caption.textContent = label;

                pill.appendChild(number);
                pill.appendChild(caption);
                return pill;
            }

            function renderHistory(items) {
                historyItems = items;
                historyList.innerHTML = '';
                renderStats(items);

                if (!items.length) {
                    var empty = document.createElement('p');
                    empty.className = 'rounded-lg border border-dashed border-slate-300 bg-slate-50 px-4 py-6 text-center text-sm text-slate-500 dark:border-slate-700 dark:bg-slate-950';
                    empty.textContent = 'No notifications sent yet. Compose one above to get started.';
                    historyList.appendChild(empty);
                    return;
                }

                items.forEach(function (item) {
                    var summary = item.summary || {};
                    var row = document.createElement('article');
                    row.className = 'rounded-lg border border-slate-200 bg-slate-50 p-4 dark:border-slate-800 dark:bg-slate-950';

                    var layout = document.createElement('div');
                    layout.className = 'grid gap-4 lg:grid-cols-[minmax(0,1fr)_minmax(220px,auto)]';

                    var info = document.createElement('div');
                    info.className = 'min-w-0';

                    var badges = document.createElement('div');
                    badges.className = 'flex flex-wrap items-center gap-2';
                    badges.appendChild(statusBadge(item.status));

                    var typeBadge = document.createElement('span');
                    typeBadge.className = 'inline-flex rounded-full bg-primary-50 px-2.5 py-0.5 text-[11px] font-semibold text-primary-700 dark:bg-primary-500/10 dark:text-primary-100';
                    typeBadge.textContent = item.type || 'Alert';
                    badges.appendChild(typeBadge);
                    info.appendChild(badges);

                    var title = document.createElement('p');
                    title.className = 'mt-2 truncate text-sm font-semibold text-slate-900 dark:text-white';
                    title.textContent = item.title || '(no title)';
                    info.appendChild(title);

                    if (item.message) {
                        var message = document.createElement('p');
                        message.className = 'mt-1 max-h-12 overflow-hidden text-sm leading-6 text-slate-500 dark:text-slate-400';
                        message.textContent = item.message;
                        info.appendChild(message);
                    }

                    var meta = document.createElement('div');
                    meta.className = 'mt-3 flex flex-wrap gap-x-3 gap-y-1 text-xs text-slate-500 dark:text-slate-400';

                    [audienceLabel(item), relativeTime(item.created_at)].forEach(function (part) {
                        if (!part) {
                            return;
                        }
                        var span = document.createElement('span');
                        span.textContent = part;
                        meta.appendChild(span);
                    });

                    if (item.status === 'scheduled' && item.scheduled_for) {
                        var scheduled = document.createElement('span');
                        scheduled.textContent = 'Scheduled: ' + new Date(item.scheduled_for).toLocaleString();
                        meta.appendChild(scheduled);
                    }

                    if (item.created_by && item.created_by.name) {
                        var createdBy = document.createElement('span');
                        createdBy.textContent = 'By ' + item.created_by.name;
                        meta.appendChild(createdBy);
                    }

                    if (summary.push_error) {
                        var issue = document.createElement('span');
                        issue.className = 'font-semibold text-amber-700 dark:text-amber-300';
                        issue.textContent = 'Push setup issue';
                        meta.appendChild(issue);
                    }

                    info.appendChild(meta);
                    layout.appendChild(info);

                    var side = document.createElement('div');
                    side.className = 'space-y-3';

                    var metrics = document.createElement('div');
                    metrics.className = 'grid grid-cols-3 gap-2';
                    var saved = Number(summary.saved_notifications || summary.stored_notifications || 0);
                    var delivered = Number(summary.delivered || 0) + '/' + Number(summary.device_tokens || 0);
                    metrics.appendChild(metricPill('Saved', saved, 'slate'));
                    metrics.appendChild(metricPill('Delivered', delivered, 'emerald'));
                    metrics.appendChild(metricPill('Failed', Number(summary.failed || 0), 'rose'));
                    side.appendChild(metrics);

                    var actions = document.createElement('div');
                    actions.className = 'flex flex-wrap justify-end gap-2';

                    if (item.status === 'scheduled' && canCancel) {
                        var cancelBtn = document.createElement('button');
                        cancelBtn.type = 'button';
                        cancelBtn.className = 'inline-flex h-9 items-center justify-center rounded-lg bg-rose-50 px-3 text-xs font-semibold text-rose-600 shadow-sm transition hover:bg-rose-100 dark:bg-rose-500/10 dark:text-rose-400 dark:hover:bg-rose-500/20';
                        cancelBtn.textContent = 'Cancel';
                        cancelBtn.addEventListener('click', function () {
                            cancelCampaign(item, cancelBtn);
                        });
                        actions.appendChild(cancelBtn);
                    } else if (item.status !== 'scheduled' && item.status !== 'cancelled' && canSend) {
                        var resendBtn = document.createElement('button');
                        resendBtn.type = 'button';
                        resendBtn.className = 'inline-flex h-9 items-center justify-center gap-1.5 rounded-lg bg-[#4A88F7] px-3 text-xs font-semibold text-white shadow-sm transition hover:bg-[#3977E6] disabled:opacity-60';
                        resendBtn.innerHTML = '<svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M6 12L3.27 3.96a.6.6 0 01.8-.74L21 12 4.07 20.78a.6.6 0 01-.8-.74L6 12zm0 0h8"/></svg><span>Send Again</span>';
                        resendBtn.addEventListener('click', function () {
                            resendCampaign(item, resendBtn);
                        });
                        actions.appendChild(resendBtn);
                    }

                    var reuseBtn = document.createElement('button');
                    reuseBtn.type = 'button';
                    reuseBtn.className = 'inline-flex h-9 items-center justify-center rounded-lg border border-slate-200 bg-white px-3 text-xs font-semibold text-slate-700 shadow-sm transition hover:bg-slate-100 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-200';
                    reuseBtn.textContent = 'Load to Form';
                    reuseBtn.addEventListener('click', function () {
                        loadToForm(item);
                    });
                    actions.appendChild(reuseBtn);

                    side.appendChild(actions);
                    layout.appendChild(side);
                    row.appendChild(layout);
                    historyList.appendChild(row);
                });
            }

            function renderHistoryPagination(meta) {
                if (!historyPagination) {
                    return;
                }
                historyPagination.innerHTML = '';

                if (!meta || meta.last_page <= 1) {
                    historyPagination.classList.add('hidden');
                    historyPagination.classList.remove('flex');
                    return;
                }

                historyPagination.classList.remove('hidden');
                historyPagination.classList.add('flex');

                var info = document.createElement('p');
                info.className = 'text-xs text-slate-500 dark:text-slate-400';
                info.textContent = 'Page ' + meta.current_page + ' of ' + meta.last_page + ' (' + meta.total + ' total)';
                historyPagination.appendChild(info);

                var controls = document.createElement('div');
                controls.className = 'flex items-center gap-2';

                var prevBtn = document.createElement('button');
                prevBtn.type = 'button';
                prevBtn.className = 'inline-flex items-center justify-center rounded-lg border border-slate-200 bg-white px-3 py-1.5 text-xs font-semibold text-slate-700 shadow-sm transition hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-50 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-200';
                prevBtn.textContent = 'Previous';
                prevBtn.disabled = meta.current_page <= 1;
                prevBtn.addEventListener('click', function () {
                    if (historyPage > 1) {
                        historyPage -= 1;
                        loadHistory();
                    }
                });
                controls.appendChild(prevBtn);

                var nextBtn = document.createElement('button');
                nextBtn.type = 'button';
                nextBtn.className = 'inline-flex items-center justify-center rounded-lg border border-slate-200 bg-white px-3 py-1.5 text-xs font-semibold text-slate-700 shadow-sm transition hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-50 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-200';
                nextBtn.textContent = 'Next';
                nextBtn.disabled = meta.current_page >= meta.last_page;
                nextBtn.addEventListener('click', function () {
                    if (historyPage < meta.last_page) {
                        historyPage += 1;
                        loadHistory();
                    }
                });
                controls.appendChild(nextBtn);

                historyPagination.appendChild(controls);
            }

            async function loadHistory() {
                try {
                    var url = historyUrl + '?page=' + historyPage + '&per_page=' + historyPerPage;
                    var response = await fetch(url, {
                        headers: { 'Accept': 'application/json' },
                        credentials: 'same-origin',
                    });
                    if (!response.ok) {
                        throw new Error('history request failed');
                    }
                    var result = await response.json();
                    renderHistory(Array.isArray(result.data) ? result.data : []);
                    renderHistoryPagination(result.meta);
                } catch (error) {
                    historyList.innerHTML = '';
                    var failed = document.createElement('p');
                    failed.className = 'rounded-lg border border-dashed border-rose-300 bg-rose-50 px-4 py-6 text-center text-sm text-rose-600 dark:border-rose-800 dark:bg-rose-500/10 dark:text-rose-300';
                    failed.textContent = 'Could not load notification history. Try Refresh.';
                    historyList.appendChild(failed);
                    if (historyPagination) {
                        historyPagination.classList.add('hidden');
                        historyPagination.classList.remove('flex');
                    }
                }
            }

            function loadToForm(item) {
                titleInput.value = item.title || '';
                messageInput.value = item.message || '';
                typeInput.value = item.type || 'Alert';
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

                // Load schedule settings from item.meta or scheduled_for
                var meta = item.meta || {};
                var scheduleType = meta.schedule_type || (item.scheduled_for ? 'date' : 'now');
                var radioSchedule = document.querySelector('input[name="schedule_type"][value="' + scheduleType + '"]');
                if (radioSchedule) {
                    radioSchedule.checked = true;
                }
                if (scheduleType === 'date' && item.scheduled_for && scheduledForInput) {
                    // Convert ISO string to local datetime-local string (YYYY-MM-DDTHH:mm)
                    var date = new Date(item.scheduled_for);
                    var pad = function(num) { return String(num).padStart(2, '0'); };
                    var localString = date.getFullYear() + '-' + pad(date.getMonth() + 1) + '-' + pad(date.getDate()) + 'T' + pad(date.getHours()) + ':' + pad(date.getMinutes());
                    scheduledForInput.value = localString;
                } else if (scheduledForInput) {
                    scheduledForInput.value = '';
                }
                if (scheduleType === 'delay' && meta.schedule_delay && scheduleDelaySelect) {
                    ensureDelayOptionExists(meta.schedule_delay);
                    scheduleDelaySelect.value = scheduleDelaySelect.querySelector('option[value="' + meta.schedule_delay + '"]') ? meta.schedule_delay : '1_day';
                } else if (scheduleDelaySelect) {
                    scheduleDelaySelect.value = '1_day';
                }
                updateScheduleState();

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
                body.append('type', item.type || 'Alert');
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

                    showSendResult('Notification resent', payload);
                    historyPage = 1;
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

            async function cancelCampaign(item, button) {
                var confirmed = false;
                if (window.adminSwalConfirm) {
                    var result = await window.adminSwalConfirm(
                        'Cancel this scheduled notification?',
                        'This notification will not be sent.',
                        'Yes, cancel it'
                    );
                    confirmed = !!(result && result.isConfirmed);
                } else {
                    confirmed = confirm('Are you sure you want to cancel this scheduled notification?');
                }
                if (!confirmed) {
                    return;
                }

                var originalHtml = button ? button.innerHTML : '';
                if (button) {
                    button.disabled = true;
                    button.textContent = 'Cancelling...';
                }

                try {
                    var cancelUrl = '/admin/notifications/' + item.id + '/cancel';
                    var response = await fetch(cancelUrl, {
                        method: 'POST',
                        headers: {
                            'Accept': 'application/json',
                            'X-CSRF-TOKEN': csrfToken ? csrfToken.content : '',
                        },
                        credentials: 'same-origin',
                    });
                    var payload = {};
                    try {
                        payload = await response.json();
                    } catch (error) {
                        payload = {};
                    }

                    if (!response.ok) {
                        if (window.adminSwalError) {
                            window.adminSwalError('Cancel failed', payload.message || 'Notification could not be cancelled.');
                        } else {
                            alert(payload.message || 'Notification could not be cancelled.');
                        }
                        return;
                    }

                    if (window.adminToast) {
                        window.adminToast('Scheduled notification cancelled.', { type: 'success' });
                    }
                    historyPage = 1;
                    loadHistory();
                } catch (error) {
                    if (window.adminSwalError) {
                        window.adminSwalError('Network error', 'The dashboard could not reach the cancel endpoint.');
                    } else {
                        alert('The dashboard could not reach the cancel endpoint.');
                    }
                } finally {
                    if (button) {
                        button.disabled = false;
                        button.innerHTML = originalHtml;
                    }
                }
            }

            // ---- AI message generation ----

            async function generateMessageFromAi() {
                if (!aiGenerateMessageError) {
                    return;
                }
                aiGenerateMessageError.textContent = '';
                var title = titleInput.value.trim();
                if (!title) {
                    aiGenerateMessageError.textContent = 'Enter a notification title first.';
                    return;
                }

                aiGenerateMessageBtn.disabled = true;
                aiGenerateMessageSpinner.classList.remove('hidden');

                try {
                    var response = await fetch(form.dataset.generateMessageUrl || '/admin/notifications/generate-message', {
                        method: 'POST',
                        headers: {
                            'Accept': 'application/json',
                            'Content-Type': 'application/json',
                            'X-CSRF-TOKEN': csrfToken ? csrfToken.content : '',
                        },
                        credentials: 'same-origin',
                        body: JSON.stringify({ title: title, type: typeInput.value || '' }),
                    });
                    var payload = {};
                    try {
                        payload = await response.json();
                    } catch (error) {
                        payload = {};
                    }

                    if (!response.ok) {
                        aiGenerateMessageError.textContent = payload.message || 'Unable to generate a message.';
                        return;
                    }

                    messageInput.value = payload.generated_message || '';
                    syncPreview();
                } catch (error) {
                    aiGenerateMessageError.textContent = 'Unable to generate a message.';
                } finally {
                    aiGenerateMessageBtn.disabled = false;
                    aiGenerateMessageSpinner.classList.add('hidden');
                }
            }

            if (aiGenerateMessageBtn) {
                aiGenerateMessageBtn.addEventListener('click', generateMessageFromAi);
            }

            // ---- Wire up ----

            targetModeInputs.forEach(function (input) {
                input.addEventListener('change', updateSpecificUserState);
            });

            if (targetUserSelect) {
                targetUserSelect.addEventListener('change', syncPreview);
            }

            [titleInput, messageInput, typeInput, deepLinkInput].forEach(function (input) {
                input.addEventListener('input', syncPreview);
                input.addEventListener('change', syncPreview);
            });

            if (imageInput) {
                imageInput.addEventListener('change', syncImagePreview);
            }

            if (refreshHistoryButton) {
                refreshHistoryButton.addEventListener('click', function () {
                    historyPage = 1;
                    loadHistory();
                });
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
                        schedule_type: (document.querySelector('input[name="schedule_type"]:checked') || {}).value || 'now',
                        scheduled_for: scheduledForInput ? scheduledForInput.value : '',
                        schedule_delay: scheduleDelaySelect ? scheduleDelaySelect.value : '1_day',
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
                        showSendResult('Notification sent', result);
                        historyPage = 1;
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
                    typeInput.value = draft.type || 'Alert';
                    deepLinkInput.value = draft.deep_link || '';
                    if (targetUserSelect) {
                        targetUserSelect.value = draft.target_user_id || '';
                    }
                    var draftTarget = document.querySelector('input[name="target_mode"][value="' + (draft.target_mode || 'all') + '"]');
                    if (draftTarget) {
                        draftTarget.checked = true;
                    }
                    var draftSchedule = document.querySelector('input[name="schedule_type"][value="' + (draft.schedule_type || 'now') + '"]');
                    if (draftSchedule) {
                        draftSchedule.checked = true;
                    }
                    if (scheduledForInput) {
                        scheduledForInput.value = draft.scheduled_for || '';
                    }
                    if (scheduleDelaySelect) {
                        var draftDelay = draft.schedule_delay || '1_day';
                        ensureDelayOptionExists(draftDelay);
                        scheduleDelaySelect.value = scheduleDelaySelect.querySelector('option[value="' + draftDelay + '"]') ? draftDelay : '1_day';
                    }
                }
            } catch (error) {
                localStorage.removeItem(draftKey);
            }

            scheduleTypeInputs.forEach(function (input) {
                input.addEventListener('change', updateScheduleState);
            });

            [scheduledForInput, scheduleDelaySelect].forEach(function (input) {
                if (!input) {
                    return;
                }
                input.addEventListener('input', syncPreview);
                input.addEventListener('change', syncPreview);
            });

            updateSpecificUserState();
            updateScheduleState();
            syncPreview();
            loadHistory();
        });
    </script>
@endsection
