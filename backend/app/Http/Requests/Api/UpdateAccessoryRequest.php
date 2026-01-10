<?php

namespace App\Http\Requests\Api;

use App\Models\Accessory;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Validator;

class UpdateAccessoryRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'brand' => ['sometimes', 'required', 'in:'.implode(',', Accessory::BRANDS)],
            'name' => ['sometimes', 'required', 'string', 'min:3'],
            'price' => ['sometimes', 'required', 'numeric', 'min:0.01'],
            'discount' => ['sometimes', 'nullable', 'numeric', 'min:0'],
            'description' => ['sometimes', 'nullable', 'string', 'max:500'],
            'warranty' => ['sometimes', 'required', 'in:'.implode(',', Accessory::WARRANTIES)],
        ];
    }

    public function withValidator(Validator $validator): void
    {
        $validator->after(function (Validator $validator) {
            $accessory = $this->route('accessory');
            $price = $this->has('price') ? $this->input('price') : $accessory?->price;
            $discount = $this->has('discount') ? $this->input('discount') : $accessory?->discount;
            if ($discount !== null && $price !== null && $discount > $price) {
                $validator->errors()->add('discount', 'The discount may not be greater than the price.');
            }
        });
    }
}
