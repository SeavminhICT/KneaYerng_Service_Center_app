@extends('layouts.admin')

@section('title', __('New Repair Job'))
@section('page-title', __('New Repair Job'))

@section('content')
    <div class="mx-auto max-w-7xl space-y-6">

        <!-- Top Header & Quick Appointment Import Banner -->
        <div class="rounded-2xl border border-slate-200/80 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
                <div class="flex items-center gap-3">
                    <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-primary-50 text-primary-600 dark:bg-primary-950/50 dark:text-primary-400">
                        <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/></svg>
                    </div>
                    <div>
                        <h1 class="text-lg font-bold text-slate-900 dark:text-white">{{ __('Create Repair Ticket') }}</h1>
                        <p class="text-xs text-slate-500">{{ __('Register a walk-in or booked repair service job and assign a technician.') }}</p>
                    </div>
                </div>

                <div class="flex items-center gap-2">
                    <div class="relative w-full sm:w-auto sm:min-w-[300px]">
                        <select id="appointment-select" class="w-full rounded-xl border border-slate-200 bg-slate-50 pl-3 pr-8 py-2 text-xs font-medium text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-200">
                            <option value="">{{ __('Import Appointment (Optional)...') }}</option>
                        </select>
                    </div>
                    <button type="button" id="refresh-appointments" title="{{ __('Refresh Appointments') }}" class="inline-flex h-9 w-9 shrink-0 items-center justify-center rounded-xl border border-slate-200 bg-white text-slate-600 hover:bg-slate-50 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300 dark:hover:bg-slate-800">
                        <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/></svg>
                    </button>
                </div>
            </div>
        </div>

        <div class="grid gap-6 lg:grid-cols-[1fr_340px]">

            <!-- Main Form Column -->
            <form id="repair-create-form" class="space-y-6">

                <!-- STEP 1: Customer Information -->
                <div class="rounded-2xl border border-slate-200/80 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                    <div class="mb-5 flex items-center justify-between border-b border-slate-100 pb-4 dark:border-slate-800">
                        <div class="flex items-center gap-3">
                            <span class="flex h-7 w-7 items-center justify-center rounded-full bg-primary-100 text-xs font-bold text-primary-700 dark:bg-primary-900/60 dark:text-primary-300">1</span>
                            <div>
                                <h2 class="text-base font-semibold text-slate-900 dark:text-white">{{ __('Customer & Phone Lookup') }}</h2>
                                <p class="text-xs text-slate-500">{{ __('Enter customer phone number to search or instantly link/create account.') }}</p>
                            </div>
                        </div>
                    </div>

                    <div id="customer-picker" class="space-y-3">
                        <!-- Search Bar with Integrated Add Phone Button -->
                        <div class="relative flex items-center">
                            <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-4 text-slate-400">
                                <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z"/></svg>
                            </div>
                            <input id="customer-search" type="text" autocomplete="off" placeholder="{{ __('Type Phone Number (e.g. 081515245) or Customer Name...') }}" class="w-full rounded-xl border border-slate-200 bg-slate-50/70 py-3 text-sm text-slate-900 placeholder:text-slate-400 focus:border-primary-500 focus:bg-white focus:ring-2 focus:ring-primary-500/20 dark:border-slate-800 dark:bg-slate-950/70 dark:text-slate-100 dark:focus:bg-slate-900" style="padding-left: 3.25rem !important; padding-right: 7.5rem !important;" />
                            
                            <button type="button" id="btn-add-phone" class="absolute right-1.5 inline-flex items-center gap-1 rounded-lg bg-primary-600 px-3 py-1.5 text-xs font-bold text-white shadow-sm hover:bg-primary-700">
                                <svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"/></svg>
                                <span>{{ __('Add Phone') }}</span>
                            </button>
                        </div>

                        <!-- Live Search Results & Quick Action Bar -->
                        <div id="customer-results" class="space-y-2 overflow-hidden"></div>

                        <!-- Selected Customer Card Display -->
                        <div id="customer-selected" class="hidden rounded-xl border border-emerald-200 bg-emerald-50/80 p-3.5 text-sm text-emerald-900 dark:border-emerald-800/40 dark:bg-emerald-950/30 dark:text-emerald-200">
                            <div class="flex items-center justify-between">
                                <div class="flex items-center gap-3">
                                    <div class="flex h-9 w-9 items-center justify-center rounded-full bg-emerald-600 text-xs font-bold text-white shadow-sm">
                                        <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/></svg>
                                    </div>
                                    <div>
                                        <div id="customer-selected-name" class="font-bold text-emerald-950 dark:text-emerald-100"></div>
                                        <div id="customer-selected-details" class="text-xs text-emerald-700 dark:text-emerald-400"></div>
                                    </div>
                                </div>
                                <button type="button" id="customer-clear" class="inline-flex items-center gap-1 rounded-lg bg-white/80 px-2.5 py-1 text-xs font-semibold text-emerald-800 shadow-sm hover:bg-white dark:bg-emerald-900/50 dark:text-emerald-200 dark:hover:bg-emerald-900">
                                    <svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
                                    {{ __('Change') }}
                                </button>
                            </div>
                        </div>

                        <!-- New Customer Toggle Button -->
                        <div class="flex items-center justify-between pt-1">
                            <button type="button" id="customer-new-toggle" class="inline-flex items-center gap-1.5 text-xs font-semibold text-primary-600 hover:text-primary-700 dark:text-primary-400">
                                <svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"/></svg>
                                <span>{{ __('Register Customer with Name & Email (Optional)') }}</span>
                            </button>
                        </div>
                    </div>

                    <!-- Collapsible Inline New Customer Form -->
                    <div id="customer-new-form" class="mt-4 hidden space-y-4 rounded-xl border border-slate-200 bg-slate-50/80 p-4 dark:border-slate-800 dark:bg-slate-950/60">
                        <div class="flex items-center justify-between border-b border-slate-200/60 pb-2.5 dark:border-slate-800">
                            <h3 class="text-xs font-bold uppercase tracking-wider text-slate-700 dark:text-slate-300">{{ __('New Customer Details') }}</h3>
                            <span class="text-[11px] font-medium text-emerald-600 dark:text-emerald-400">{{ __('Only Phone Number Required') }}</span>
                        </div>

                        <div class="grid gap-3 sm:grid-cols-2">
                            <div>
                                <label class="block text-xs font-semibold text-slate-700 dark:text-slate-200" for="new_phone">{{ __('Phone Number') }} <span class="text-rose-500">*</span></label>
                                <input id="new_phone" type="text" placeholder="e.g. 081515245" class="mt-1.5 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-800 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-100" />
                            </div>

                            <div>
                                <label class="block text-xs font-semibold text-slate-700 dark:text-slate-200" for="new_first_name">{{ __('First Name (Optional)') }}</label>
                                <input id="new_first_name" type="text" placeholder="e.g. Sokha" class="mt-1.5 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-800 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-100" />
                            </div>

                            <div>
                                <label class="block text-xs font-semibold text-slate-700 dark:text-slate-200" for="new_last_name">{{ __('Last Name (Optional)') }}</label>
                                <input id="new_last_name" type="text" placeholder="e.g. Chan" class="mt-1.5 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-800 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-100" />
                            </div>

                            <div>
                                <label class="block text-xs font-semibold text-slate-700 dark:text-slate-200" for="new_email">{{ __('Email Address (Optional)') }}</label>
                                <input id="new_email" type="email" placeholder="e.g. customer@gmail.com" class="mt-1.5 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-800 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-100" />
                            </div>
                        </div>

                        <div class="flex items-center gap-2 pt-1">
                            <button type="button" id="customer-new-save" class="inline-flex h-9 items-center rounded-xl bg-primary-600 px-4 text-xs font-semibold text-white shadow-sm hover:bg-primary-700">
                                {{ __('Create & Link Customer') }}
                            </button>
                            <span id="customer-new-status" class="text-xs font-medium text-rose-600"></span>
                        </div>
                    </div>
                </div>

                <!-- STEP 2: Device & Issue Details -->
                <div class="rounded-2xl border border-slate-200/80 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                    <div class="mb-5 flex items-center gap-3 border-b border-slate-100 pb-4 dark:border-slate-800">
                        <span class="flex h-7 w-7 items-center justify-center rounded-full bg-primary-100 text-xs font-bold text-primary-700 dark:bg-primary-900/60 dark:text-primary-300">2</span>
                        <div>
                            <h2 class="text-base font-semibold text-slate-900 dark:text-white">{{ __('Device & Service Details') }}</h2>
                            <p class="text-xs text-slate-500">{{ __('Specify device model, select repair issue, write custom notes, service type, and date.') }}</p>
                        </div>
                    </div>

                    <div class="grid gap-5 sm:grid-cols-2">
                        <!-- Device Model Input with Quick Suggestions Chips -->
                        <div class="sm:col-span-2">
                            <label class="block text-xs font-semibold text-slate-700 dark:text-slate-200" for="device_model">
                                {{ __('Device Model') }} <span class="text-rose-500">*</span>
                            </label>
                            <input id="device_model" list="device_models_list" type="text" autocomplete="off" placeholder="{{ __('Type or select e.g. iPhone 16 Pro Max, MacBook Pro 14"') }}" class="mt-1.5 w-full rounded-xl border border-slate-200 bg-slate-50/70 px-3.5 py-2.5 text-sm text-slate-800 placeholder:text-slate-400 focus:border-primary-500 focus:bg-white focus:ring-2 focus:ring-primary-500/20 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-100" />
                            <datalist id="device_models_list">
                                <option value="iPhone 16 Pro Max">
                                <option value="iPhone 16 Pro">
                                <option value="iPhone 16">
                                <option value="iPhone 15 Pro Max">
                                <option value="iPhone 15 Pro">
                                <option value="iPhone 14 Pro Max">
                                <option value="iPad Pro 12.9">
                                <option value="MacBook Pro 14">
                                <option value="MacBook Air M3">
                                <option value="Samsung Galaxy S24 Ultra">
                            </datalist>

                            <!-- Quick Suggestion Chips -->
                            <div class="mt-2 flex flex-wrap items-center gap-1.5">
                                <span class="text-[11px] text-slate-400">{{ __('Quick select:') }}</span>
                                <button type="button" class="device-chip rounded-lg border border-slate-200 bg-slate-50 px-2 py-0.5 text-[11px] font-medium text-slate-600 hover:bg-primary-50 hover:text-primary-600 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-300">iPhone 16 Pro Max</button>
                                <button type="button" class="device-chip rounded-lg border border-slate-200 bg-slate-50 px-2 py-0.5 text-[11px] font-medium text-slate-600 hover:bg-primary-50 hover:text-primary-600 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-300">iPhone 15 Pro</button>
                                <button type="button" class="device-chip rounded-lg border border-slate-200 bg-slate-50 px-2 py-0.5 text-[11px] font-medium text-slate-600 hover:bg-primary-50 hover:text-primary-600 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-300">MacBook Air</button>
                                <button type="button" class="device-chip rounded-lg border border-slate-200 bg-slate-50 px-2 py-0.5 text-[11px] font-medium text-slate-600 hover:bg-primary-50 hover:text-primary-600 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-300">iPad Pro</button>
                            </div>
                        </div>

                        <!-- Repair Issue Selection & Custom Description -->
                        <div class="sm:col-span-2 space-y-3">
                            <div>
                                <label class="block text-xs font-semibold text-slate-700 dark:text-slate-200" for="issue_type">
                                    {{ __('Repair Category / Issue') }} <span class="text-rose-500">*</span>
                                </label>
                                <input id="issue_type" list="issue_types_list" type="text" autocomplete="off" placeholder="{{ __('Select common issue or type e.g. Screen Replacement, Battery Issue') }}" class="mt-1.5 w-full rounded-xl border border-slate-200 bg-slate-50/70 px-3.5 py-2.5 text-sm text-slate-800 placeholder:text-slate-400 focus:border-primary-500 focus:bg-white focus:ring-2 focus:ring-primary-500/20 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-100" />
                                <datalist id="issue_types_list">
                                    <option value="Screen Replacement">
                                    <option value="Battery Replacement">
                                    <option value="Water Damage Repair">
                                    <option value="Charging Port Repair">
                                    <option value="Camera Repair / Replacement">
                                    <option value="Speaker / Microphone Fix">
                                    <option value="Logic Board / IC Repair">
                                    <option value="Software / OS Restore">
                                </datalist>

                                <!-- Quick Issue Chips -->
                                <div class="mt-2 flex flex-wrap items-center gap-1.5">
                                    <span class="text-[11px] text-slate-400">{{ __('Common issues:') }}</span>
                                    <button type="button" class="issue-chip rounded-lg border border-slate-200 bg-slate-50 px-2 py-0.5 text-[11px] font-medium text-slate-600 hover:bg-primary-50 hover:text-primary-600 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-300">Screen Replacement</button>
                                    <button type="button" class="issue-chip rounded-lg border border-slate-200 bg-slate-50 px-2 py-0.5 text-[11px] font-medium text-slate-600 hover:bg-primary-50 hover:text-primary-600 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-300">Battery Replacement</button>
                                    <button type="button" class="issue-chip rounded-lg border border-slate-200 bg-slate-50 px-2 py-0.5 text-[11px] font-medium text-slate-600 hover:bg-primary-50 hover:text-primary-600 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-300">Water Damage</button>
                                    <button type="button" class="issue-chip rounded-lg border border-slate-200 bg-slate-50 px-2 py-0.5 text-[11px] font-medium text-slate-600 hover:bg-primary-50 hover:text-primary-600 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-300">Charging Port</button>
                                    <button type="button" class="issue-chip rounded-lg border border-slate-200 bg-slate-50 px-2 py-0.5 text-[11px] font-medium text-slate-600 hover:bg-primary-50 hover:text-primary-600 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-300">Motherboard IC</button>
                                </div>
                            </div>

                            <!-- Additional Notes & Symptom Details -->
                            <div>
                                <label class="block text-xs font-semibold text-slate-700 dark:text-slate-200" for="issue_notes">
                                    {{ __('Additional Notes & Specific Details (Optional)') }}
                                </label>
                                <textarea id="issue_notes" rows="2" placeholder="{{ __('Write any extra notes e.g. Passcode: 1234, top left glass cracked, customer requests data backup...') }}" class="mt-1.5 w-full rounded-xl border border-slate-200 bg-slate-50/70 px-3.5 py-2.5 text-sm text-slate-800 placeholder:text-slate-400 focus:border-primary-500 focus:bg-white focus:ring-2 focus:ring-primary-500/20 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-100"></textarea>
                            </div>
                        </div>

                        <!-- Service Type -->
                        <div>
                            <label class="block text-xs font-semibold text-slate-700 dark:text-slate-200" for="service_type">{{ __('Service Type') }}</label>
                            <select id="service_type" class="mt-1.5 w-full rounded-xl border border-slate-200 bg-slate-50/70 px-3 py-2 text-sm text-slate-800 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-100">
                                <option value="drop_off">{{ __('Drop Off (Store Walk-in)') }}</option>
                                <option value="pickup">{{ __('Pickup Service') }}</option>
                                <option value="on_site">{{ __('On Site Repair') }}</option>
                            </select>
                        </div>

                        <!-- Appointment Date & Time -->
                        <div>
                            <div class="flex items-center justify-between">
                                <label class="block text-xs font-semibold text-slate-700 dark:text-slate-200" for="appointment_datetime">{{ __('Date & Time') }}</label>
                                <button type="button" id="set-date-today" class="inline-flex items-center gap-1 text-[11px] font-semibold text-primary-600 hover:underline dark:text-primary-400">
                                    <svg class="h-3 w-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                                    {{ __('Set to Today') }}
                                </button>
                            </div>
                            <input id="appointment_datetime" type="datetime-local" class="mt-1.5 w-full rounded-xl border border-slate-200 bg-slate-50/70 px-3 py-2 text-sm text-slate-800 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-100" />
                        </div>
                    </div>
                </div>

                <!-- STEP 3: Technician Assignment -->
                <div class="rounded-2xl border border-slate-200/80 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                    <div class="mb-5 flex items-center justify-between border-b border-slate-100 pb-4 dark:border-slate-800">
                        <div class="flex items-center gap-3">
                            <span class="flex h-7 w-7 items-center justify-center rounded-full bg-primary-100 text-xs font-bold text-primary-700 dark:bg-primary-900/60 dark:text-primary-300">3</span>
                            <div>
                                <h2 class="text-base font-semibold text-slate-900 dark:text-white">{{ __('Technician Assignment') }}</h2>
                                <p class="text-xs text-slate-500">{{ __('Assign a technician now to immediately set status to "Waiting Diagnosis", or assign later.') }}</p>
                            </div>
                        </div>
                    </div>

                    <div>
                        <select id="technician_id" class="w-full rounded-xl border border-slate-200 bg-slate-50/70 px-3.5 py-2.5 text-sm text-slate-800 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-100">
                            <option value="">{{ __('-- Keep Unassigned for Now --') }}</option>
                            <option value="auto">{{ __('⚡ Auto-Assign Available Technician with Lowest Workload') }}</option>
                        </select>
                    </div>
                </div>

                <!-- Action Toolbar -->
                <div class="flex items-center justify-between pt-2">
                    <a href="{{ route('admin.repairs.index') }}" class="inline-flex h-10 items-center justify-center rounded-xl border border-slate-200 bg-white px-4 text-xs font-semibold text-slate-600 shadow-sm hover:bg-slate-50 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300 dark:hover:bg-slate-800">
                        {{ __('Cancel') }}
                    </a>

                    <div class="flex items-center gap-3">
                        <span id="repair-create-error" class="text-xs font-medium text-rose-600"></span>
                        <button id="repair-create-submit" type="button" class="inline-flex h-11 items-center justify-center gap-2 rounded-xl bg-primary-600 px-6 text-sm font-semibold text-white shadow-md hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2">
                            <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>
                            <span>{{ __('Create Repair Ticket') }}</span>
                        </button>
                    </div>
                </div>
            </form>

            <!-- Sidebar Summary & Helper Card -->
            <div class="space-y-5">

                <!-- Job Preview Card -->
                <div class="rounded-2xl border border-slate-200/80 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                    <h3 class="text-xs font-bold uppercase tracking-wider text-slate-700 dark:text-slate-300 flex items-center gap-2">
                        <svg class="h-4 w-4 text-primary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/></svg>
                        {{ __('Ticket Summary Preview') }}
                    </h3>

                    <div class="mt-4 space-y-3.5 text-xs">
                        <div class="flex justify-between border-b border-slate-100 pb-2 dark:border-slate-800">
                            <span class="text-slate-500">{{ __('Customer:') }}</span>
                            <span id="preview-customer" class="font-medium text-slate-900 dark:text-white">{{ __('Not Selected') }}</span>
                        </div>
                        <div class="flex justify-between border-b border-slate-100 pb-2 dark:border-slate-800">
                            <span class="text-slate-500">{{ __('Device:') }}</span>
                            <span id="preview-device" class="font-medium text-slate-900 dark:text-white">-</span>
                        </div>
                        <div class="flex justify-between border-b border-slate-100 pb-2 dark:border-slate-800">
                            <span class="text-slate-500">{{ __('Issue & Notes:') }}</span>
                            <span id="preview-issue" class="font-medium text-slate-900 text-right dark:text-white">-</span>
                        </div>
                        <div class="flex justify-between border-b border-slate-100 pb-2 dark:border-slate-800">
                            <span class="text-slate-500">{{ __('Technician:') }}</span>
                            <span id="preview-technician" class="font-medium text-slate-900 dark:text-white">{{ __('Unassigned') }}</span>
                        </div>
                        <div class="flex justify-between">
                            <span class="text-slate-500">{{ __('Initial Status:') }}</span>
                            <span id="preview-status" class="rounded-md bg-slate-100 px-2 py-0.5 text-[11px] font-bold text-slate-700 dark:bg-slate-800 dark:text-slate-300">Received</span>
                        </div>
                    </div>
                </div>

                <!-- Quick Tips Card -->
                <div class="rounded-2xl border border-slate-200/80 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                    <h3 class="text-xs font-bold uppercase tracking-wider text-slate-700 dark:text-slate-300 flex items-center gap-1.5">
                        <svg class="h-4 w-4 text-amber-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                        {{ __('Workflow Guidance') }}
                    </h3>
                    <ul class="mt-3 space-y-2.5 text-xs text-slate-500 leading-relaxed">
                        <li class="flex items-start gap-2">
                            <span class="mt-0.5 h-1.5 w-1.5 shrink-0 rounded-full bg-primary-500"></span>
                            <span><strong>{{ __('Repair Presets:') }}</strong> {{ __('Click common issue chips like "Screen Replacement" or "Water Damage" to set issue category.') }}</span>
                        </li>
                        <li class="flex items-start gap-2">
                            <span class="mt-0.5 h-1.5 w-1.5 shrink-0 rounded-full bg-primary-500"></span>
                            <span><strong>{{ __('Custom Notes:') }}</strong> {{ __('Use Additional Notes to write specific passcode, glass crack details, or customer requests.') }}</span>
                        </li>
                    </ul>
                </div>

            </div>
        </div>
    </div>

    <script>
        (function () {
            function safeApiRequest(url, options) {
                if (window.adminApi && typeof window.adminApi.request === 'function') {
                    return window.adminApi.request(url, options);
                }
                function getCookie(name) {
                    var match = document.cookie.match(new RegExp('(^| )' + name + '=([^;]+)'));
                    return match ? decodeURIComponent(match[2]) : null;
                }
                var opts = options || {};
                var headers = Object.assign({ 'Accept': 'application/json' }, opts.headers || {});
                var token = getCookie('XSRF-TOKEN');
                if (token) {
                    headers['X-XSRF-TOKEN'] = token;
                }
                return fetch(url, Object.assign({ credentials: 'include' }, opts, { headers: headers }));
            }

            async function safeEnsureCsrfCookie() {
                if (window.adminApi && typeof window.adminApi.ensureCsrfCookie === 'function') {
                    return window.adminApi.ensureCsrfCookie();
                }
                return fetch('/sanctum/csrf-cookie', { credentials: 'include' });
            }

            var selectedCustomer = null;
            var searchInput = document.getElementById('customer-search');
            var resultsBox = document.getElementById('customer-results');
            var selectedBox = document.getElementById('customer-selected');
            var selectedNameEl = document.getElementById('customer-selected-name');
            var selectedDetailsEl = document.getElementById('customer-selected-details');
            var appointmentSelect = document.getElementById('appointment-select');
            var technicianSelect = document.getElementById('technician_id');
            var appointmentDatetimeInput = document.getElementById('appointment_datetime');
            var deviceModelInput = document.getElementById('device_model');
            var issueTypeInput = document.getElementById('issue_type');
            var issueNotesInput = document.getElementById('issue_notes');
            var btnAddPhone = document.getElementById('btn-add-phone');
            var appointmentsList = [];

            // Preview elements
            var previewCustomer = document.getElementById('preview-customer');
            var previewDevice = document.getElementById('preview-device');
            var previewIssue = document.getElementById('preview-issue');
            var previewTech = document.getElementById('preview-technician');
            var previewStatus = document.getElementById('preview-status');

            function getFormattedNow() {
                var now = new Date();
                var year = now.getFullYear();
                var month = String(now.getMonth() + 1).padStart(2, '0');
                var day = String(now.getDate()).padStart(2, '0');
                var hours = String(now.getHours()).padStart(2, '0');
                var minutes = String(now.getMinutes()).padStart(2, '0');
                return year + '-' + month + '-' + day + 'T' + hours + ':' + minutes;
            }

            appointmentDatetimeInput.value = getFormattedNow();

            document.getElementById('set-date-today').addEventListener('click', function () {
                appointmentDatetimeInput.value = getFormattedNow();
            });

            function updatePreview() {
                previewCustomer.textContent = selectedCustomer ? selectedCustomer.name : '{{ __('Not Selected') }}';
                previewDevice.textContent = deviceModelInput.value.trim() || '-';
                
                var issueCategory = issueTypeInput.value.trim();
                var issueNotes = issueNotesInput.value.trim();
                if (issueCategory && issueNotes) {
                    previewIssue.textContent = issueCategory + ' (' + issueNotes + ')';
                } else {
                    previewIssue.textContent = issueCategory || issueNotes || '-';
                }

                var techVal = technicianSelect.value;
                if (techVal === 'auto') {
                    previewTech.textContent = '⚡ Auto-Assign';
                } else if (techVal) {
                    var selectedOpt = technicianSelect.options[technicianSelect.selectedIndex];
                    previewTech.textContent = selectedOpt ? selectedOpt.textContent.split('(')[0].trim() : 'Assigned';
                } else {
                    previewTech.textContent = 'Unassigned';
                }

                if (techVal) {
                    previewStatus.textContent = 'Waiting Diagnosis';
                    previewStatus.className = 'rounded-md bg-amber-100 px-2 py-0.5 text-[11px] font-bold text-amber-800 dark:bg-amber-950/60 dark:text-amber-300';
                } else {
                    previewStatus.textContent = 'Received';
                    previewStatus.className = 'rounded-md bg-slate-100 px-2 py-0.5 text-[11px] font-bold text-slate-700 dark:bg-slate-800 dark:text-slate-300';
                }
            }

            function selectCustomer(customer) {
                if (!customer) return;
                selectedCustomer = customer;
                selectedNameEl.textContent = customer.name;
                var details = [];
                if (customer.phone) details.push('📞 ' + customer.phone);
                if (customer.email) details.push('✉️ ' + customer.email);

                var appStatusBadge = customer.is_app_user
                    ? ' · <span class="inline-flex items-center gap-1 font-bold text-emerald-700 dark:text-emerald-300">📱 Mobile App Registered</span>'
                    : ' · <span class="inline-flex items-center gap-1 font-medium text-amber-700 dark:text-amber-300">🏬 Walk-in Customer</span>';

                var appNotice = customer.is_app_user
                    ? '<div class="mt-2 flex items-center gap-1.5 text-xs font-semibold text-emerald-800 dark:text-emerald-300"><svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>✅ Customer receives live App Push Notifications & real-time repair status tracking.</div>'
                    : '<div class="mt-2 flex items-center gap-1.5 text-xs font-medium text-amber-800 dark:text-amber-300"><svg class="w-3.5 h-3.5 shrink-0 text-amber-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 18h.01M8 21h8a2 2 0 002-2V5a2 2 0 00-2-2H8a2 2 0 00-2 2v14a2 2 0 002 2z"/></svg><span>📲 Customer can log into the Mobile App anytime with <strong>' + (customer.phone || '') + '</strong> to live track repair status & receive notifications.</span></div>';

                selectedDetailsEl.innerHTML = (details.join(' · ') || 'ID: #' + customer.id) + appStatusBadge + appNotice;

                selectedBox.classList.remove('hidden');
                searchInput.classList.add('hidden');
                btnAddPhone.classList.add('hidden');
                resultsBox.innerHTML = '';
                searchInput.value = '';
                updatePreview();
            }

            document.getElementById('customer-clear').addEventListener('click', function () {
                selectedCustomer = null;
                selectedBox.classList.add('hidden');
                searchInput.classList.remove('hidden');
                btnAddPhone.classList.remove('hidden');
                searchInput.focus();
                updatePreview();
            });

            // Quick device suggestion chips click handler
            document.querySelectorAll('.device-chip').forEach(function (chip) {
                chip.addEventListener('click', function () {
                    deviceModelInput.value = chip.textContent.trim();
                    updatePreview();
                });
            });

            // Quick issue suggestion chips click handler
            document.querySelectorAll('.issue-chip').forEach(function (chip) {
                chip.addEventListener('click', function () {
                    issueTypeInput.value = chip.textContent.trim();
                    updatePreview();
                });
            });

            deviceModelInput.addEventListener('input', updatePreview);
            issueTypeInput.addEventListener('input', updatePreview);
            issueNotesInput.addEventListener('input', updatePreview);
            technicianSelect.addEventListener('change', updatePreview);

            // Handler for Add Phone button & Enter key on search bar
            async function submitPhoneLookup() {
                var q = searchInput.value.trim();
                if (!q) return;

                var response = await safeApiRequest('/api/admin/customers/search?q=' + encodeURIComponent(q));
                if (response.ok) {
                    var data = await response.json();
                    var list = data.data || [];
                    var cleanQ = q.replace(/[\s\-]/g, '');
                    var exactMatch = list.find(function (c) {
                        return c.phone && c.phone.replace(/[\s\-]/g, '') === cleanQ;
                    }) || list[0];

                    if (exactMatch) {
                        selectCustomer(exactMatch);
                        return;
                    }
                }

                await createWalkInCustomer(q);
            }

            btnAddPhone.addEventListener('click', submitPhoneLookup);

            searchInput.addEventListener('keydown', function (e) {
                if (e.key === 'Enter') {
                    e.preventDefault();
                    submitPhoneLookup();
                }
            });

            // Search input logic
            var searchTimer = null;
            searchInput.addEventListener('input', function () {
                clearTimeout(searchTimer);
                var q = searchInput.value.trim();
                if (q.length < 2) {
                    resultsBox.innerHTML = '';
                    return;
                }
                searchTimer = setTimeout(async function () {
                    var response = await safeApiRequest('/api/admin/customers/search?q=' + encodeURIComponent(q));
                    if (!response.ok) return;
                    var data = await response.json();
                    var list = data.data || [];

                    if (list.length > 0) {
                        resultsBox.innerHTML = list.map(function (customer, index) {
                            var appBadge = customer.is_app_user
                                ? '<span class="inline-flex items-center gap-1 rounded-md bg-emerald-100 px-2 py-0.5 text-xs font-bold text-emerald-800 dark:bg-emerald-950/60 dark:text-emerald-300">📱 App User</span>'
                                : '<span class="inline-flex items-center gap-1 rounded-md bg-amber-50 px-2 py-0.5 text-xs font-medium text-amber-700 dark:bg-amber-950/40 dark:text-amber-300">🏬 Walk-in</span>';

                            var phoneText = customer.phone ? ' · 📞 ' + customer.phone : '';
                            var emailText = customer.email ? ' · ✉️ ' + customer.email : '';
                            return '<button type="button" data-index="' + index + '" class="customer-result-item flex w-full items-center justify-between rounded-xl border border-slate-200 bg-white px-3.5 py-2.5 text-left text-sm text-slate-700 hover:border-primary-300 hover:bg-primary-50/50 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-200 dark:hover:bg-slate-800">' +
                                '<div><strong class="font-bold text-slate-900 dark:text-white">' + customer.name + '</strong>' + phoneText + emailText + '</div>' +
                                appBadge +
                                '</button>';
                        }).join('');

                        resultsBox.querySelectorAll('.customer-result-item').forEach(function (button) {
                            button.addEventListener('click', function () {
                                selectCustomer(list[Number(button.dataset.index)]);
                            });
                        });
                    } else {
                        var isPhonePattern = /^[0-9+\s\-]{6,15}$/.test(q);
                        var quickBtnHtml = isPhonePattern
                            ? '<div class="mt-2 rounded-xl border border-slate-200 bg-slate-50/80 p-4 text-center dark:border-slate-800 dark:bg-slate-950/50">' +
                                '<p class="text-xs text-slate-600 dark:text-slate-400">No account registered for phone <strong class="font-bold text-slate-900 dark:text-white">' + q + '</strong></p>' +
                                '<div class="mt-2.5 flex items-center justify-center gap-2">' +
                                    '<button type="button" id="quick-create-walkin" class="inline-flex items-center gap-1.5 rounded-xl bg-primary-600 px-4 py-2 text-xs font-bold text-white shadow-sm hover:bg-primary-700">' +
                                        '<svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"/></svg>' +
                                        'Quick Add Customer with Phone (' + q + ')' +
                                    '</button>' +
                                '</div>' +
                              '</div>'
                            : '<p class="px-2 py-1 text-xs text-slate-500">{{ __('No customers found matching search query.') }}</p>';

                        resultsBox.innerHTML = quickBtnHtml;

                        var quickBtn = document.getElementById('quick-create-walkin');
                        if (quickBtn) {
                            quickBtn.addEventListener('click', async function () {
                                await createWalkInCustomer(q);
                            });
                        }
                    }
                }, 200);
            });

            async function createWalkInCustomer(phoneNum) {
                await safeEnsureCsrfCookie();
                var response = await safeApiRequest('/api/admin/customers', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ phone: phoneNum })
                });

                if (!response.ok) {
                    document.getElementById('customer-new-form').classList.remove('hidden');
                    document.getElementById('new_phone').value = phoneNum;
                    return;
                }

                var data = await response.json();
                selectCustomer(data.data);
            }

            document.getElementById('customer-new-toggle').addEventListener('click', function () {
                var form = document.getElementById('customer-new-form');
                form.classList.toggle('hidden');
                if (!form.classList.contains('hidden')) {
                    var currentSearchVal = searchInput.value.trim();
                    if (currentSearchVal) {
                        document.getElementById('new_phone').value = currentSearchVal;
                    }
                }
            });

            document.getElementById('customer-new-save').addEventListener('click', async function () {
                var phone = document.getElementById('new_phone').value.trim();
                var firstName = document.getElementById('new_first_name').value.trim();
                var statusEl = document.getElementById('customer-new-status');
                statusEl.textContent = '';

                if (!phone) {
                    statusEl.textContent = '{{ __('Phone number is required.') }}';
                    return;
                }
                var payload = {
                    phone: phone,
                    first_name: firstName || null,
                    last_name: document.getElementById('new_last_name').value.trim() || null,
                    email: document.getElementById('new_email').value.trim() || null,
                };
                await safeEnsureCsrfCookie();
                var response = await safeApiRequest('/api/admin/customers', {
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

            // Load Technicians
            async function loadTechnicians() {
                try {
                    var res = await safeApiRequest('/api/technicians?per_page=100');
                    if (!res.ok) return;
                    var body = await res.json();
                    var techs = body.data || [];
                    techs.forEach(function (tech) {
                        var opt = document.createElement('option');
                        opt.value = tech.id;
                        var statusText = tech.availability_status ? tech.availability_status.toUpperCase() : 'AVAILABLE';
                        var jobsText = (tech.active_jobs_count || 0) + ' active jobs';
                        opt.textContent = tech.name + ' (' + statusText + ' · ' + jobsText + ')';
                        technicianSelect.appendChild(opt);
                    });
                } catch (e) {
                    console.error('Failed to load technicians', e);
                }
            }

            // Load Appointments
            async function loadAppointments() {
                try {
                    var res = await safeApiRequest('/api/repairs?per_page=30');
                    if (!res.ok) return;
                    var body = await res.json();
                    appointmentsList = body.data || [];

                    appointmentSelect.innerHTML = '<option value="">{{ __('Import Appointment (Optional)...') }}</option>';
                    appointmentsList.forEach(function (rep) {
                        if (rep.customer) {
                            var opt = document.createElement('option');
                            opt.value = rep.id;
                            var dateStr = rep.appointment_datetime ? new Date(rep.appointment_datetime).toLocaleDateString() : 'No date';
                            opt.textContent = '#' + rep.id + ' · ' + rep.customer.name + ' (' + (rep.customer.phone || 'No phone') + ') · ' + rep.device_model + ' [' + dateStr + ']';
                            appointmentSelect.appendChild(opt);
                        }
                    });
                } catch (e) {
                    console.error('Failed to load appointments', e);
                }
            }

            appointmentSelect.addEventListener('change', function () {
                var repId = Number(appointmentSelect.value);
                if (!repId) return;
                var found = appointmentsList.find(function (item) { return item.id === repId; });
                if (!found) return;

                if (found.customer) {
                    selectCustomer(found.customer);
                }
                if (found.device_model) {
                    deviceModelInput.value = found.device_model;
                }
                if (found.issue_type) {
                    issueTypeInput.value = found.issue_type;
                }
                if (found.service_type) {
                    document.getElementById('service_type').value = found.service_type;
                }
                if (found.appointment_datetime) {
                    var d = new Date(found.appointment_datetime);
                    if (!isNaN(d.getTime())) {
                        var year = d.getFullYear();
                        var month = String(d.getMonth() + 1).padStart(2, '0');
                        var day = String(d.getDate()).padStart(2, '0');
                        var hours = String(d.getHours()).padStart(2, '0');
                        var minutes = String(d.getMinutes()).padStart(2, '0');
                        appointmentDatetimeInput.value = year + '-' + month + '-' + day + 'T' + hours + ':' + minutes;
                    }
                }
                updatePreview();
            });

            document.getElementById('refresh-appointments').addEventListener('click', loadAppointments);

            loadTechnicians();
            loadAppointments();

            // Submit Handler
            document.getElementById('repair-create-submit').addEventListener('click', async function (event) {
                event.preventDefault();
                var errorEl = document.getElementById('repair-create-error');
                errorEl.textContent = '';

                if (!selectedCustomer) {
                    errorEl.textContent = '{{ __('Select or create a customer first.') }}';
                    return;
                }
                var deviceModel = deviceModelInput.value.trim();
                var issueCategory = issueTypeInput.value.trim();
                var issueNotes = issueNotesInput.value.trim();

                if (!deviceModel || (!issueCategory && !issueNotes)) {
                    errorEl.textContent = '{{ __('Device model and repair issue/notes are required.') }}';
                    return;
                }

                var combinedIssue = issueCategory;
                if (issueNotes) {
                    combinedIssue = issueCategory ? (issueCategory + ' | Note: ' + issueNotes) : issueNotes;
                }

                var techVal = technicianSelect.value;
                var payload = {
                    customer_id: selectedCustomer.id,
                    device_model: deviceModel,
                    issue_type: combinedIssue,
                    service_type: document.getElementById('service_type').value,
                    appointment_datetime: appointmentDatetimeInput.value || null,
                };

                if (techVal === 'auto') {
                    payload.auto_assign = true;
                } else if (techVal) {
                    payload.technician_id = Number(techVal);
                }

                var btn = document.getElementById('repair-create-submit');
                btn.disabled = true;
                btn.classList.add('opacity-75');

                await safeEnsureCsrfCookie();
                var response = await safeApiRequest('/api/repairs', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(payload)
                });

                if (!response.ok) {
                    btn.disabled = false;
                    btn.classList.remove('opacity-75');
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
