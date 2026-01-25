<?php

namespace App\Http\Requests\Api;

use Illuminate\Foundation\Http\FormRequest;
use App\Models\Product;

class StoreProductRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'sku' => ['nullable', 'string', 'max:100', 'unique:products,sku'],
            'category_id' => ['nullable', 'exists:categories,id'],
            'price' => ['required', 'numeric', 'min:0'],
            'discount' => ['nullable', 'numeric', 'min:0'],
            'stock' => ['required', 'integer', 'min:0'],
            'status' => ['required', 'in:active,draft,archived'],
            'brand' => ['nullable', 'string', 'max:255'],
            'warranty' => ['nullable', 'in:'.implode(',', Product::WARRANTIES)],
            'thumbnail' => ['nullable', 'image', 'max:5120'],
            'image_gallery' => ['nullable', 'array'],
            'image_gallery.*' => ['image', 'max:5120'],
            'storage_capacity' => ['nullable', 'array'],
            'storage_capacity.*' => ['string', 'max:100'],
            'color' => ['nullable', 'array'],
            'color.*' => ['string', 'max:100'],
            'condition' => ['nullable', 'array'],
            'condition.*' => ['string', 'max:100'],
            'image' => ['nullable', 'image', 'max:5120'],
        ];
    }

    protected function prepareForValidation(): void
    {
        if ($this->has('discount')) {
            $value = $this->input('discount');
            if ($value === '' || $value === null) {
                $this->merge(['discount' => 0]);
            }
        } else {
            $this->merge(['discount' => 0]);
        }
    }
}
