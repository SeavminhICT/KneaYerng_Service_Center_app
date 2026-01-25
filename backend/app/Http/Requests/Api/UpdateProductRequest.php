<?php

namespace App\Http\Requests\Api;

use Illuminate\Foundation\Http\FormRequest;
use App\Models\Product;

class UpdateProductRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $productId = $this->route('product')?->id ?? $this->route('product');

        return [
            'name' => ['sometimes', 'required', 'string', 'max:255'],
            'description' => ['sometimes', 'nullable', 'string'],
            'sku' => ['sometimes', 'nullable', 'string', 'max:100', 'unique:products,sku,'.$productId],
            'category_id' => ['sometimes', 'nullable', 'exists:categories,id'],
            'price' => ['sometimes', 'required', 'numeric', 'min:0'],
            'discount' => ['sometimes', 'nullable', 'numeric', 'min:0'],
            'stock' => ['sometimes', 'required', 'integer', 'min:0'],
            'status' => ['sometimes', 'required', 'in:active,draft,archived'],
            'brand' => ['sometimes', 'nullable', 'string', 'max:255'],
            'warranty' => ['sometimes', 'nullable', 'in:'.implode(',', Product::WARRANTIES)],
            'thumbnail' => ['sometimes', 'nullable', 'image', 'max:5120'],
            'image_gallery' => ['sometimes', 'nullable', 'array'],
            'image_gallery.*' => ['image', 'max:5120'],
            'storage_capacity' => ['sometimes', 'nullable', 'array'],
            'storage_capacity.*' => ['string', 'max:100'],
            'color' => ['sometimes', 'nullable', 'array'],
            'color.*' => ['string', 'max:100'],
            'condition' => ['sometimes', 'nullable', 'array'],
            'condition.*' => ['string', 'max:100'],
            'image' => ['sometimes', 'nullable', 'image', 'max:5120'],
        ];
    }

    protected function prepareForValidation(): void
    {
        if ($this->has('discount')) {
            $value = $this->input('discount');
            if ($value === '' || $value === null) {
                $this->merge(['discount' => 0]);
            }
        }
    }
}
