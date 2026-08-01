<?php

namespace App\Http\Requests\Api;

use App\Models\ProductType;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateProductTypeRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:80'],
            'fields' => ['required', 'array', 'min:1'],
            'fields.*' => ['required', 'string', Rule::in(ProductType::fieldKeys())],
            'required_fields' => ['nullable', 'array'],
            'required_fields.*' => ['required', 'string', Rule::in(ProductType::fieldKeys())],
            'sort_order' => ['nullable', 'integer', 'min:0'],
        ];
    }

    protected function prepareForValidation(): void
    {
        $this->merge([
            'name' => trim((string) $this->input('name')),
            'fields' => ProductType::normalizeFieldList($this->input('fields', [])),
            'required_fields' => ProductType::normalizeFieldList($this->input('required_fields', [])),
        ]);
    }

    public function withValidator($validator): void
    {
        $validator->after(function ($validator) {
            $fields = $this->input('fields', []);
            $requiredFields = $this->input('required_fields', []);

            foreach ($requiredFields as $field) {
                if (! in_array($field, $fields, true)) {
                    $validator->errors()->add('required_fields', 'Required fields must also be selected as visible fields.');
                    break;
                }
            }
        });
    }
}
