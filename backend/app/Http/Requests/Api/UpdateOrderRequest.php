<?php

namespace App\Http\Requests\Api;

use Illuminate\Foundation\Http\FormRequest;

class UpdateOrderRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'user_id' => ['sometimes', 'nullable', 'exists:users,id'],
            'customer_name' => ['sometimes', 'required', 'string', 'max:255'],
            'customer_email' => ['sometimes', 'nullable', 'email', 'max:255'],
            'order_type' => ['sometimes', 'nullable', 'in:pickup,delivery'],
            'payment_method' => ['sometimes', 'nullable', 'in:bank,cash'],
            'delivery_address' => ['sometimes', 'nullable', 'string', 'max:255'],
            'delivery_phone' => ['sometimes', 'nullable', 'string', 'max:50'],
            'payment_status' => ['sometimes', 'required', 'in:pending,processing,success,failed'],
            'status' => ['sometimes', 'required', 'in:pending,processing,ready,completed,cancelled'],
            'placed_at' => ['sometimes', 'nullable', 'date'],
            'items' => ['sometimes', 'array', 'min:1'],
            'items.*.product_id' => ['nullable', 'exists:products,id'],
            'items.*.product_name' => ['required_with:items', 'string', 'max:255'],
            'items.*.quantity' => ['required_with:items', 'integer', 'min:1'],
            'items.*.price' => ['required_with:items', 'numeric', 'min:0'],
        ];
    }
}

