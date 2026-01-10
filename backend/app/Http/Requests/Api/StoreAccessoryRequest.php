<?php

namespace App\Http\Requests\Api;

use App\Models\Accessory;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Validator;

class StoreAccessoryRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'brand' => ['required', 'in:'.implode(',', Accessory::BRANDS)],
            'name' => ['required', 'string', 'min:3'],
            'price' => ['required', 'numeric', 'min:0.01'],
            'discount' => ['nullable', 'numeric', 'min:0'],
            'description' => ['nullable', 'string', 'max:500'],
            'warranty' => ['required', 'in:'.implode(',', Accessory::WARRANTIES)],
        ];
    }

    public function withValidator(Validator $validator): void
    {
        $validator->after(function (Validator $validator) {
            $price = $this->input('price');
            $discount = $this->input('discount');
            if ($discount !== null && $price !== null && $discount > $price) {
                $validator->errors()->add('discount', 'The discount may not be greater than the price.');
            }
        });
    }
}
