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
            'product_type' => ['nullable', 'in:'.implode(',', Product::PRODUCT_TYPES)],
            'price' => ['nullable', 'numeric', 'min:0', 'required_without:variants'],
            'discount' => ['nullable', 'numeric', 'min:0'],
            'stock' => ['nullable', 'integer', 'min:0', 'required_without:variants'],
            'status' => ['required', 'in:active,draft,archived'],
            'tag' => ['nullable', 'in:'.implode(',', Product::TAGS)],
            'brand' => ['nullable', 'string', 'max:255'],
            'warranty' => ['nullable', 'in:'.implode(',', Product::WARRANTIES)],
            'thumbnail' => ['nullable', 'image', 'max:2048'],
            'image_gallery' => ['nullable', 'array'],
            'image_gallery.*' => ['image', 'max:2048'],
            'storage_capacity' => ['nullable', 'array'],
            'storage_capacity.*' => ['string', 'max:100'],
            'color' => ['nullable', 'array'],
            'color.*' => ['string', 'max:100'],
            'condition' => ['nullable', 'array'],
            'condition.*' => ['string', 'max:100'],
            'ram' => ['nullable', 'array'],
            'ram.*' => ['string', 'max:100'],
            'ssd' => ['nullable', 'array'],
            'ssd.*' => ['string', 'max:100'],
            'cpu' => ['nullable', 'array'],
            'cpu.*' => ['string', 'max:150'],
            'display' => ['nullable', 'array'],
            'display.*' => ['string', 'max:150'],
            'country' => ['nullable', 'array'],
            'country.*' => ['string', 'max:100'],
            'image' => ['nullable', 'image', 'max:2048'],
            'variants' => ['nullable', 'array'],
            'variants.*.storage_capacity' => ['nullable', 'string', 'max:100'],
            'variants.*.color' => ['nullable', 'string', 'max:100'],
            'variants.*.condition' => ['nullable', 'string', 'max:100'],
            'variants.*.ram' => ['nullable', 'string', 'max:100'],
            'variants.*.ssd' => ['nullable', 'string', 'max:100'],
            'variants.*.cpu' => ['nullable', 'string', 'max:150'],
            'variants.*.display' => ['nullable', 'string', 'max:150'],
            'variants.*.country' => ['nullable', 'string', 'max:100'],
            'variants.*.price' => ['required_with:variants', 'numeric', 'min:0'],
            'variants.*.stock' => ['required_with:variants', 'integer', 'min:0'],
            'variants.*.sku' => ['nullable', 'string', 'max:120', 'distinct'],
            'variants.*.image' => ['nullable', 'string', 'max:500'],
            'variant_images' => ['nullable', 'array'],
            'variant_images.*' => ['nullable', 'image', 'max:2048'],
        ];
    }

    protected function prepareForValidation(): void
    {
        if (is_string($this->input('variants'))) {
            $decoded = json_decode($this->input('variants'), true);
            if (is_array($decoded)) {
                $this->merge(['variants' => $decoded]);
            }
        }

        $arrayFields = [
            'storage_capacity',
            'color',
            'condition',
            'ram',
            'ssd',
            'cpu',
            'display',
            'country',
        ];

        foreach ($arrayFields as $field) {
            $value = $this->input($field);

            if (is_string($value)) {
                $this->merge([$field => $this->splitMultiValue($value)]);
                continue;
            }

            if (is_array($value)) {
                $normalized = array_values(array_filter(array_map(
                    fn ($item) => trim((string) $item),
                    $value
                ), fn ($item) => $item !== ''));
                $this->merge([$field => $normalized]);
            }
        }

        if ($this->has('discount')) {
            $value = $this->input('discount');
            if ($value === '' || $value === null) {
                $this->merge(['discount' => 0]);
            }
        } else {
            $this->merge(['discount' => 0]);
        }
    }

    /**
     * @return array<int, string>
     */
    private function splitMultiValue(string $value): array
    {
        $trimmed = trim($value);
        if ($trimmed === '') {
            return [];
        }

        if (str_starts_with($trimmed, '[') && str_ends_with($trimmed, ']')) {
            $decoded = json_decode($trimmed, true);
            if (is_array($decoded)) {
                return array_values(array_filter(array_map(
                    fn ($item) => trim((string) $item),
                    $decoded
                ), fn ($item) => $item !== ''));
            }
        }

        return array_values(array_filter(array_map(
            fn ($item) => trim($item),
            preg_split('/[|,]/', $trimmed) ?: []
        ), fn ($item) => $item !== ''));
    }
}
