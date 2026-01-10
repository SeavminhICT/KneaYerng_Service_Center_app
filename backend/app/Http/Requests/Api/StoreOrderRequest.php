<?php

namespace App\Http\Requests\Api;

use Illuminate\Foundation\Http\FormRequest;

class StoreOrderRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'order_number' => ['nullable', 'string', 'max:100', 'unique:orders,order_number'],
            'user_id' => ['nullable', 'exists:users,id'],
            'customer_name' => ['required', 'string', 'max:255'],
            'customer_email' => ['nullable', 'email', 'max:255'],
            'order_type' => ['nullable', 'in:pickup,delivery'],
            'payment_method' => ['nullable', 'in:bank,cash'],
            'delivery_address' => ['required_if:order_type,delivery', 'nullable', 'string', 'max:255'],
            'delivery_phone' => ['required_if:order_type,delivery', 'nullable', 'string', 'max:50'],
            'payment_status' => ['nullable', 'in:pending,processing,success,failed'],
            'status' => ['nullable', 'in:pending,processing,ready,completed,cancelled'],
            'placed_at' => ['nullable', 'date'],
            'items' => ['required', 'array', 'min:1'],
            'items.*.product_id' => ['nullable', 'exists:products,id'],
            'items.*.product_name' => ['required', 'string', 'max:255'],
            'items.*.quantity' => ['required', 'integer', 'min:1'],
            'items.*.price' => ['required', 'numeric', 'min:0'],
        ];
    }
}

