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
            'payment_method' => ['sometimes', 'nullable', 'in:cod,aba,card,wallet,bank,cash'],
            'delivery_address' => ['sometimes', 'nullable', 'string', 'max:255'],
            'delivery_phone' => ['sometimes', 'nullable', 'string', 'max:50'],
            'delivery_note' => ['sometimes', 'nullable', 'string', 'max:1000'],
            'delivery_fee' => ['sometimes', 'nullable', 'numeric', 'min:0'],
            'payment_status' => ['sometimes', 'required', 'in:unpaid,paid,failed,refunded,pending,processing,success'],
            'status' => ['sometimes', 'required', 'in:pending,processing,ready,completed,cancelled,rejected'],
            'placed_at' => ['sometimes', 'nullable', 'date'],
            'items' => ['sometimes', 'array', 'min:1'],
            'items.*.product_id' => ['nullable', 'integer'],
            'items.*.item_type' => ['nullable', 'in:product,accessory,part,repair_part'],
            'items.*.item_id' => ['nullable', 'integer'],
            'items.*.product_name' => ['nullable', 'string', 'max:255'],
            'items.*.quantity' => ['required_with:items', 'integer', 'min:1'],
            'items.*.price' => ['nullable', 'numeric', 'min:0'],
        ];
    }
}
