<?php

use App\Models\Product;
use App\Models\User;
use App\Models\Voucher;

it('lets an admin account place a customer order with a voucher on the customer route', function () {
    $admin = User::factory()->create([
        'role' => 'admin',
        'is_admin' => true,
    ]);
    $product = Product::factory()->create([
        'price' => 100,
        'stock' => 5,
        'storage_capacity' => null,
        'color' => null,
        'condition' => null,
    ]);
    $voucher = Voucher::query()->create([
        'code' => 'SAVE10',
        'name' => 'Save 10',
        'discount_type' => 'fixed',
        'discount_value' => 10,
        'min_order_amount' => 0,
        'is_active' => true,
    ]);

    $response = $this
        ->actingAs($admin)
        ->postJson('/api/user/orders', [
            'customer_name' => 'Admin Customer',
            'order_type' => 'pickup',
            'payment_method' => 'cash',
            'payment_status' => 'unpaid',
            'voucher_code' => $voucher->code,
            'items' => [
                [
                    'product_id' => $product->id,
                    'item_type' => 'product',
                    'item_id' => $product->id,
                    'product_name' => $product->name,
                    'quantity' => 1,
                    'price' => 100,
                ],
            ],
        ]);

    $response
        ->assertCreated()
        ->assertJsonPath('data.voucher_code', 'SAVE10')
        ->assertJsonPath('data.discount_amount', '10.00');

    $this->assertDatabaseHas('orders', [
        'user_id' => $admin->id,
        'voucher_code' => 'SAVE10',
    ]);
    $this->assertDatabaseHas('voucher_redemptions', [
        'user_id' => $admin->id,
        'voucher_id' => $voucher->id,
    ]);
});
