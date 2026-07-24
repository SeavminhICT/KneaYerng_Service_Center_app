<?php

use App\Models\Product;
use App\Models\User;

it('generates product and variant skus when creating a product without skus', function () {
    $admin = User::factory()->create([
        'role' => 'admin',
        'is_admin' => true,
    ]);

    Product::factory()->create([
        'name' => 'iPhone 16 Pro Max',
        'brand' => 'Apple',
        'sku' => 'IPAPPLE001',
    ]);

    $response = $this
        ->actingAs($admin)
        ->postJson('/api/products', [
            'name' => 'iPhone 17 Pro Max',
            'brand' => 'Apple',
            'product_type' => 'mobile',
            'status' => 'active',
            'variants' => [
                [
                    'storage_capacity' => '256 GB',
                    'color' => 'Black',
                    'condition' => 'New',
                    'price' => 1299,
                    'stock' => 5,
                ],
                [
                    'storage_capacity' => '512 GB',
                    'color' => 'Silver',
                    'condition' => 'New',
                    'price' => 1499,
                    'stock' => 3,
                ],
            ],
        ]);

    $response->assertSuccessful();

    $product = Product::query()
        ->where('name', 'iPhone 17 Pro Max')
        ->firstOrFail();

    expect($product->sku)->toBe('IPAPPLE002')
        ->and((int) $product->stock)->toBe(8);

    expect($product->variants()->pluck('sku')->all())->toBe([
        'IPAPPLE002-256GB-BLACK-NEW',
        'IPAPPLE002-512GB-SILVER-NEW',
    ]);
});
