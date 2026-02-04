@extends('layouts.admin')

@section('title', 'Create Voucher')
@section('page-title', 'Create Voucher')

@section('content')
    <div class="grid gap-6 lg:grid-cols-[2fr_1fr]">
        <form id="voucher-create-form" class="space-y-6 rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <div>
                <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Voucher Details</h2>
                <p class="text-sm text-slate-500">Create a new discount voucher for the mobile checkout flow.</p>
            </div>

            <div class="grid gap-4 sm:grid-cols-2">
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="code">Voucher Code</label>
                    <input id="code" name="code" type="text" placeholder="WELCOME10" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    <p id="voucher-code-error" class="mt-2 text-xs text-danger-600"></p>
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="name">Name</label>
                    <input id="name" name="name" type="text" placeholder="New customer offer" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>
            </div>

            <div class="grid gap-4 sm:grid-cols-3">
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="discount_type">Discount Type</label>
                    <select id="discount_type" name="discount_type" class="mt-2 w-full appearance-none rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                        <option value="percent" selected>Percent</option>
                        <option value="fixed">Fixed amount</option>
                    </select>
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="discount_value">Discount Value</label>
                    <input id="discount_value" name="discount_value" type="number" step="0.01" min="0" value="0" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    <p id="voucher-discount-error" class="mt-2 text-xs text-danger-600"></p>
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="min_order_amount">Minimum Order</label>
                    <input id="min_order_amount" name="min_order_amount" type="number" step="0.01" min="0" value="0" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>
            </div>

            <div class="grid gap-4 sm:grid-cols-2">
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="starts_at">Starts At</label>
                    <input id="starts_at" name="starts_at" type="datetime-local" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="expires_at">Expires At</label>
                    <input id="expires_at" name="expires_at" type="datetime-local" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>
            </div>

            <div class="grid gap-4 sm:grid-cols-2">
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="usage_limit_total">Usage Limit (Total)</label>
                    <input id="usage_limit_total" name="usage_limit_total" type="number" min="1" placeholder="No limit" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="usage_limit_per_user">Usage Limit (Per User)</label>
                    <input id="usage_limit_per_user" name="usage_limit_per_user" type="number" min="1" placeholder="No limit" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>
            </div>

            <div class="grid gap-4 sm:grid-cols-2">
                <div class="flex items-center gap-3">
                    <input id="is_active" name="is_active" type="checkbox" class="h-4 w-4 rounded border-slate-300 text-primary-600 focus:ring-primary-500" checked />
                    <label for="is_active" class="text-sm font-semibold text-slate-700 dark:text-slate-200">Active</label>
                </div>
                <div class="flex items-center gap-3">
                    <input id="is_stackable" name="is_stackable" type="checkbox" class="h-4 w-4 rounded border-slate-300 text-primary-600 focus:ring-primary-500" />
                    <label for="is_stackable" class="text-sm font-semibold text-slate-700 dark:text-slate-200">Stackable with other vouchers</label>
                </div>
            </div>

            <div>
                <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="description">Description</label>
                <textarea id="description" name="description" rows="3" placeholder="Add any usage notes" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200"></textarea>
            </div>

            <div class="flex items-center gap-3">
                <button class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white shadow-sm">Save Voucher</button>
                <a href="{{ route('admin.vouchers.index') }}" class="text-sm font-semibold text-slate-500">Cancel</a>
            </div>
            <p id="voucher-form-error" class="text-sm text-danger-600"></p>
        </form>

        <div class="space-y-6">
            <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <h3 class="text-sm font-semibold text-slate-900 dark:text-white">Tips</h3>
                <ul class="mt-3 space-y-2 text-xs text-slate-500">
                    <li>Use short codes customers can remember.</li>
                    <li>Set start and end dates to control campaigns.</li>
                    <li>Keep total usage limits aligned with promo budgets.</li>
                </ul>
            </div>
        </div>
    </div>

    <script>
        function parseNumber(value) {
            if (value === null || value === undefined || value === '') {
                return null;
            }
            var num = Number(value);
            return Number.isFinite(num) ? num : null;
        }

        function parseInteger(value) {
            if (value === null || value === undefined || value === '') {
                return null;
            }
            var num = parseInt(value, 10);
            return Number.isFinite(num) ? num : null;
        }

        document.getElementById('voucher-create-form').addEventListener('submit', async function (event) {
            event.preventDefault();
            document.getElementById('voucher-form-error').textContent = '';
            document.getElementById('voucher-code-error').textContent = '';
            document.getElementById('voucher-discount-error').textContent = '';

            var form = event.target;
            var payload = {
                code: (form.code.value || '').trim(),
                name: (form.name.value || '').trim() || null,
                discount_type: form.discount_type.value,
                discount_value: parseNumber(form.discount_value.value) ?? 0,
                min_order_amount: parseNumber(form.min_order_amount.value) ?? 0,
                starts_at: form.starts_at.value || null,
                expires_at: form.expires_at.value || null,
                usage_limit_total: parseInteger(form.usage_limit_total.value),
                usage_limit_per_user: parseInteger(form.usage_limit_per_user.value),
                is_active: form.is_active.checked,
                is_stackable: form.is_stackable.checked,
                description: (form.description.value || '').trim() || null,
            };

            try {
                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/vouchers', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(payload),
                });

                if (response.ok) {
                    if (window.adminSwalStore) {
                        window.adminSwalStore({
                            icon: 'success',
                            title: 'Voucher created',
                            text: 'Voucher created successfully.',
                            confirmButtonColor: '#2563eb',
                        });
                    } else if (window.adminToastStore) {
                        window.adminToastStore({ type: 'success', message: 'Voucher created successfully.' });
                    }
                    window.location.href = '/admin/vouchers';
                    return;
                }

                var errorData = await response.json();
                if (errorData.errors?.code) {
                    document.getElementById('voucher-code-error').textContent = errorData.errors.code[0];
                }
                if (errorData.errors?.discount_value) {
                    document.getElementById('voucher-discount-error').textContent = errorData.errors.discount_value[0];
                }
                document.getElementById('voucher-form-error').textContent = errorData.message || 'Unable to save voucher.';
                if (window.adminSwalError) {
                    window.adminSwalError('Create failed', errorData.message || 'Unable to save voucher.');
                } else if (window.adminToast) {
                    window.adminToast(errorData.message || 'Unable to save voucher.', { type: 'error' });
                }
            } catch (error) {
                document.getElementById('voucher-form-error').textContent = 'Unable to save voucher.';
                if (window.adminSwalError) {
                    window.adminSwalError('Create failed', 'Unable to save voucher.');
                } else if (window.adminToast) {
                    window.adminToast('Unable to save voucher.', { type: 'error' });
                }
            }
        });
    </script>
@endsection
