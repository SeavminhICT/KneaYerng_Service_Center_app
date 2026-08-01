<?php

use App\Models\Product;
use App\Models\ProductType;
use App\Models\User;

it('creates custom product types and uses them when creating products', function () {
    $admin = User::factory()->create([
        'role' => 'admin',
        'is_admin' => true,
    ]);

    $typeResponse = $this
        ->actingAs($admin)
        ->postJson('/api/product-types', [
            'name' => 'Tablet',
            'slug' => 'tablet',
            'fields' => ['storage', 'color', 'country'],
            'required_fields' => ['storage'],
            'sort_order' => 40,
        ]);

    $typeResponse
        ->assertCreated()
        ->assertJsonPath('data.slug', 'tablet')
        ->assertJsonPath('data.fields', ['storage', 'color', 'country'])
        ->assertJsonPath('data.required_fields', ['storage']);

    $productResponse = $this
        ->actingAs($admin)
        ->postJson('/api/products', [
            'name' => 'iPad Pro 13',
            'brand' => 'Apple',
            'product_type' => 'tablet',
            'status' => 'active',
            'variants' => [
                [
                    'storage_capacity' => '256 GB',
                    'color' => 'Silver',
                    'country' => 'US',
                    'price' => 999,
                    'stock' => 4,
                ],
            ],
        ]);

    $productResponse->assertSuccessful();

    $product = Product::query()->where('name', 'iPad Pro 13')->firstOrFail();

    expect($product->product_type)->toBe('tablet')
        ->and((int) $product->stock)->toBe(4)
        ->and($product->variants()->first()?->storage_capacity)->toBe('256 GB');
});

it('requires required product type fields to be selected as visible fields', function () {
    $admin = User::factory()->create([
        'role' => 'admin',
        'is_admin' => true,
    ]);

    $response = $this
        ->actingAs($admin)
        ->postJson('/api/product-types', [
            'name' => 'Console',
            'slug' => 'console',
            'fields' => ['color'],
            'required_fields' => ['storage'],
        ]);

    $response
        ->assertUnprocessable()
        ->assertJsonValidationErrors('required_fields');

    expect(ProductType::query()->where('slug', 'console')->exists())->toBeFalse();
});
