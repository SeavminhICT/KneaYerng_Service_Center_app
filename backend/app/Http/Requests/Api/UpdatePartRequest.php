<?php

namespace App\Http\Requests\Api;

use App\Models\Part;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdatePartRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $partId = $this->route('part')?->id ?? $this->route('part');

        return [
            'name' => ['sometimes', 'required', 'string', 'min:3', 'max:255'],
            'type' => ['sometimes', 'nullable', 'string', 'max:100'],
            'brand' => ['sometimes', 'nullable', 'string', 'max:50'],
            'sku' => ['sometimes', 'nullable', 'string', 'max:100', Rule::unique('parts', 'sku')->ignore($partId)],
            'stock' => ['sometimes', 'required', 'integer', 'min:0'],
            'unit_cost' => ['sometimes', 'required', 'numeric', 'min:0'],
            'status' => ['sometimes', 'required', 'in:'.implode(',', Part::STATUSES)],
            'tag' => ['sometimes', 'nullable', 'in:'.implode(',', Part::TAGS)],
        ];
    }
}
