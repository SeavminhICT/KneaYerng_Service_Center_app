<?php

namespace App\Http\Requests\Api;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateVoucherRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $voucherId = $this->route('voucher')?->id ?? $this->route('voucher');

        return [
            'code' => ['sometimes', 'required', 'string', 'max:50', Rule::unique('vouchers', 'code')->ignore($voucherId)],
            'name' => ['sometimes', 'nullable', 'string', 'max:255'],
            'discount_type' => ['sometimes', 'required', 'in:percent,fixed'],
            'discount_value' => ['sometimes', 'required', 'numeric', 'min:0'],
            'min_order_amount' => ['sometimes', 'required', 'numeric', 'min:0'],
            'starts_at' => ['sometimes', 'nullable', 'date'],
            'expires_at' => ['sometimes', 'nullable', 'date', 'after_or_equal:starts_at'],
            'usage_limit_total' => ['sometimes', 'nullable', 'integer', 'min:1'],
            'usage_limit_per_user' => ['sometimes', 'nullable', 'integer', 'min:1'],
            'is_active' => ['sometimes', 'boolean'],
            'is_stackable' => ['sometimes', 'boolean'],
            'description' => ['sometimes', 'nullable', 'string'],
        ];
    }

    protected function prepareForValidation(): void
    {
        $this->merge($this->normalizeFields([
            'code',
            'name',
            'discount_type',
            'discount_value',
            'min_order_amount',
            'starts_at',
            'expires_at',
            'usage_limit_total',
            'usage_limit_per_user',
            'description',
        ]));

        if ($this->has('min_order_amount') && $this->input('min_order_amount') === null) {
            $this->merge(['min_order_amount' => 0]);
        }
    }

    private function normalizeFields(array $fields): array
    {
        $normalized = [];

        foreach ($fields as $field) {
            if (! $this->has($field)) {
                continue;
            }
            $value = $this->input($field);
            if (is_string($value)) {
                $value = trim($value);
            }
            if ($value === '') {
                $value = null;
            }
            $normalized[$field] = $value;
        }

        return $normalized;
    }
}
