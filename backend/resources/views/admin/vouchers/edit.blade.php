@extends('layouts.admin')

@section('title', 'Edit Voucher')
@section('page-title', 'Edit Voucher')

@section('content')
    <div class="grid gap-6 lg:grid-cols-[2fr_1fr]">
        <form id="voucher-edit-form" class="space-y-6 rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900" data-voucher-id="{{ $voucherId ?? '' }}">
            <div>
                <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Update Voucher</h2>
                <p class="text-sm text-slate-500">Edit the voucher configuration and limits.</p>
            </div>

            <div class="grid gap-4 sm:grid-cols-2">
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="code">Voucher Code</label>
                    <input id="code" name="code" type="text" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    <p id="voucher-code-error" class="mt-2 text-xs text-danger-600"></p>
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="name">Name</label>
                    <input id="name" name="name" type="text" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>
            </div>

            <div class="grid gap-4 sm:grid-cols-3">
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="discount_type">Discount Type</label>
                    <select id="discount_type" name="discount_type" class="mt-2 w-full appearance-none rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                        <option value="percent">Percent</option>
                        <option value="fixed">Fixed amount</option>
                    </select>
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="discount_value">Discount Value</label>
                    <input id="discount_value" name="discount_value" type="number" step="0.01" min="0" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    <p id="voucher-discount-error" class="mt-2 text-xs text-danger-600"></p>
                </div>
                <div>
                    <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="min_order_amount">Minimum Order</label>
                    <input id="min_order_amount" name="min_order_amount" type="number" step="0.01" min="0" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
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
                    <input id="is_active" name="is_active" type="checkbox" class="h-4 w-4 rounded border-slate-300 text-primary-600 focus:ring-primary-500" />
                    <label for="is_active" class="text-sm font-semibold text-slate-700 dark:text-slate-200">Active</label>
                </div>
                <div class="flex items-center gap-3">
                    <input id="is_stackable" name="is_stackable" type="checkbox" class="h-4 w-4 rounded border-slate-300 text-primary-600 focus:ring-primary-500" />
                    <label for="is_stackable" class="text-sm font-semibold text-slate-700 dark:text-slate-200">Stackable with other vouchers</label>
                </div>
            </div>

            <div>
                <label class="text-sm font-semibold text-slate-700 dark:text-slate-200" for="description">Description</label>
                <textarea id="description" name="description" rows="3" class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200"></textarea>
            </div>

            <div class="flex items-center gap-3">
                <button class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white shadow-sm">Save Changes</button>
                <a href="{{ route('admin.vouchers.index') }}" class="text-sm font-semibold text-slate-500">Cancel</a>
            </div>
            <p id="voucher-form-error" class="text-sm text-danger-600"></p>
        </form>

        <div class="space-y-6">
            <div class="rounded-2xl border border-danger-100 bg-danger-50 p-5 text-xs text-danger-700 dark:border-danger-500/30 dark:bg-danger-500/10 dark:text-danger-100">
                <p class="font-semibold">Delete voucher</p>
                <p class="mt-2">Deleting will permanently remove the voucher and its redemptions.</p>
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

        function formatDateTimeLocal(value) {
            if (!value) {
                return '';
            }
            var date = new Date(value);
            if (Number.isNaN(date.getTime())) {
                return '';
            }
            var offset = date.getTimezoneOffset() * 60000;
            var local = new Date(date.getTime() - offset);
            return local.toISOString().slice(0, 16);
        }

        document.addEventListener('DOMContentLoaded', async function () {
            var form = document.getElementById('voucher-edit-form');
            var voucherId = form.dataset.voucherId;
            if (!voucherId) {
                return;
            }

            await window.adminApi.ensureCsrfCookie();
            var response = await window.adminApi.request('/api/vouchers/' + voucherId);
            if (response.ok) {
                var payload = await response.json();
                var voucher = payload.data || payload;
                document.getElementById('code').value = voucher.code || '';
                document.getElementById('name').value = voucher.name || '';
                document.getElementById('discount_type').value = voucher.discount_type || 'percent';
                document.getElementById('discount_value').value = voucher.discount_value ?? 0;
                document.getElementById('min_order_amount').value = voucher.min_order_amount ?? 0;
                document.getElementById('starts_at').value = formatDateTimeLocal(voucher.starts_at);
                document.getElementById('expires_at').value = formatDateTimeLocal(voucher.expires_at);
                document.getElementById('usage_limit_total').value = voucher.usage_limit_total ?? '';
                document.getElementById('usage_limit_per_user').value = voucher.usage_limit_per_user ?? '';
                document.getElementById('is_active').checked = !!voucher.is_active;
                document.getElementById('is_stackable').checked = !!voucher.is_stackable;
                document.getElementById('description').value = voucher.description || '';
            }
        });

        document.getElementById('voucher-edit-form').addEventListener('submit', async function (event) {
            event.preventDefault();
            document.getElementById('voucher-form-error').textContent = '';
            document.getElementById('voucher-code-error').textContent = '';
            document.getElementById('voucher-discount-error').textContent = '';

            var form = event.target;
            var voucherId = form.dataset.voucherId;

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
                var response = await window.adminApi.request('/api/vouchers/' + voucherId, {
                    method: 'PATCH',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(payload),
                });

                if (response.ok) {
                    if (window.adminSwalStore) {
                        window.adminSwalStore({
                            icon: 'success',
                            title: 'Voucher updated',
                            text: 'Voucher updated successfully.',
                            confirmButtonColor: '#2563eb',
                        });
                    } else if (window.adminToastStore) {
                        window.adminToastStore({ type: 'success', message: 'Voucher updated successfully.' });
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
                document.getElementById('voucher-form-error').textContent = errorData.message || 'Unable to update voucher.';
                if (window.adminSwalError) {
                    window.adminSwalError('Update failed', errorData.message || 'Unable to update voucher.');
                } else if (window.adminToast) {
                    window.adminToast(errorData.message || 'Unable to update voucher.', { type: 'error' });
                }
            } catch (error) {
                document.getElementById('voucher-form-error').textContent = 'Unable to update voucher.';
                if (window.adminSwalError) {
                    window.adminSwalError('Update failed', 'Unable to update voucher.');
                } else if (window.adminToast) {
                    window.adminToast('Unable to update voucher.', { type: 'error' });
                }
            }
        });
    </script>
@endsection
