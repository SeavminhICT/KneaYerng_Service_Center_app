<?php

namespace App\Http\Requests\Api;

use App\Models\ProductAttributeOption;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreProductAttributeOptionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'type' => ['required', 'in:'.implode(',', ProductAttributeOption::TYPES)],
            'value' => [
                'required',
                'string',
                'max:150',
                Rule::unique('product_attribute_options', 'value')->where(fn ($query) =>
                    $query->where('type', $this->input('type'))
                ),
            ],
        ];
    }

    protected function prepareForValidation(): void
    {
        if ($this->has('value')) {
            $value = $this->input('value');
            if (is_string($value)) {
                $value = trim($value);
            }
            $this->merge([
                'value' => $value,
            ]);
        }
    }
}
