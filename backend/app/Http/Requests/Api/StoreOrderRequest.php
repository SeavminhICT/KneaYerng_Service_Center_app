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
            'payment_method' => ['nullable', 'in:cod,aba,card,wallet,bank,cash'],
            'delivery_address' => ['required_if:order_type,delivery', 'nullable', 'string', 'max:255'],
            'delivery_phone' => ['required_if:order_type,delivery', 'nullable', 'string', 'max:50'],
            'delivery_note' => ['nullable', 'string', 'max:1000'],
            'delivery_fee' => ['nullable', 'numeric', 'min:0'],
            'payment_status' => ['nullable', 'in:unpaid,paid,failed,refunded,pending,processing,success'],
            'status' => ['nullable', 'in:pending,processing,ready,completed,cancelled,rejected'],
            'placed_at' => ['nullable', 'date'],
            'voucher_code' => ['nullable', 'string', 'max:50'],
            'items' => ['required', 'array', 'min:1'],
            'items.*.product_id' => ['nullable', 'integer'],
            'items.*.item_type' => ['nullable', 'in:product,accessory,part,repair_part'],
            'items.*.item_id' => ['nullable', 'integer'],
            'items.*.product_name' => ['nullable', 'string', 'max:255'],
            'items.*.quantity' => ['required', 'integer', 'min:1'],
            'items.*.price' => ['nullable', 'numeric', 'min:0'],
        ];
    }
}
