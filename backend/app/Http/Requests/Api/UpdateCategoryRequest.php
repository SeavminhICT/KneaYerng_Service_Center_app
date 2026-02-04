<?php

namespace App\Http\Requests\Api;

use Illuminate\Foundation\Http\FormRequest;

class UpdateCategoryRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $categoryId = $this->route('category')?->id ?? $this->route('category');

        return [
            'name' => ['sometimes', 'required', 'string', 'max:255'],
            'slug' => ['sometimes', 'nullable', 'string', 'max:255', 'unique:categories,slug,'.$categoryId],
            'image' => ['sometimes', 'nullable', 'image', 'max:5120'],
            'sort_order' => ['sometimes', 'required', 'integer', 'min:0'],
            'status' => ['sometimes', 'required', 'in:active,inactive'],
        ];
    }

    protected function prepareForValidation(): void
    {
        if (! $this->has('slug')) {
            return;
        }

        $slug = $this->input('slug');
        if (is_string($slug)) {
            $slug = trim($slug);
        }

        $this->merge([
            'slug' => $slug === '' ? null : $slug,
        ]);
    }
}
