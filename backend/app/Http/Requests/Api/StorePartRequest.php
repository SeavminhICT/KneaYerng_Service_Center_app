<?php

namespace App\Http\Requests\Api;

use App\Models\Part;
use Illuminate\Foundation\Http\FormRequest;

class StorePartRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'min:3', 'max:255'],
            'type' => ['nullable', 'string', 'max:100'],
            'brand' => ['nullable', 'string', 'max:50'],
            'sku' => ['nullable', 'string', 'max:100', 'unique:parts,sku'],
            'stock' => ['required', 'integer', 'min:0'],
            'unit_cost' => ['required', 'numeric', 'min:0'],
            'status' => ['required', 'in:'.implode(',', Part::STATUSES)],
            'tag' => ['nullable', 'in:'.implode(',', Part::TAGS)],
        ];
    }
}
