<?php

namespace App\Http\Requests\Api;

use App\Models\ProductType;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class StoreProductTypeRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:80'],
            'slug' => [
                'nullable',
                'string',
                'max:20',
                'regex:/^[a-z0-9]+(?:-[a-z0-9]+)*$/',
                Rule::unique('product_types', 'slug'),
            ],
            'fields' => ['required', 'array', 'min:1'],
            'fields.*' => ['required', 'string', Rule::in(ProductType::fieldKeys())],
            'required_fields' => ['nullable', 'array'],
            'required_fields.*' => ['required', 'string', Rule::in(ProductType::fieldKeys())],
            'sort_order' => ['nullable', 'integer', 'min:0'],
        ];
    }

    protected function prepareForValidation(): void
    {
        $name = trim((string) $this->input('name'));
        $slug = trim((string) $this->input('slug'));

        $this->merge([
            'name' => $name,
            'slug' => $slug !== '' ? Str::slug($slug) : Str::slug($name),
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
