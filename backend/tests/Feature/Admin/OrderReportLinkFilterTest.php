<?php

use App\Models\Category;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Product;
use App\Models\User;
use Illuminate\Support\Carbon;

it('filters the admin order list with report link query filters', function () {
    $admin = User::factory()->create([
        'role' => 'admin',
        'is_admin' => true,
    ]);

    $staff = User::factory()->create([
        'name' => 'Sophea Technician',
    ]);

    $phoneCategory = Category::factory()->create([
        'name' => 'Phones',
        'slug' => 'phones',
    ]);
    $laptopCategory = Category::factory()->create([
        'name' => 'Laptops',
        'slug' => 'laptops',
    ]);

    $matchingProduct = Product::factory()->create([
        'name' => 'iPhone 15 Pro',
        'sku' => 'IPHONE-15-PRO',
        'category_id' => $phoneCategory->id,
    ]);
    $otherProduct = Product::factory()->create([
        'name' => 'MacBook Air',
        'sku' => 'MACBOOK-AIR',
        'category_id' => $laptopCategory->id,
    ]);

    $matchingOrder = Order::query()->create([
        'added_by' => $admin->id,
        'assigned_staff_id' => $staff->id,
        'order_number' => 'ORD-FILTER-MATCH',
        'customer_name' => 'Dara Customer',
        'customer_email' => 'dara@example.com',
        'order_type' => 'pickup',
        'payment_method' => 'cash',
        'payment_status' => 'paid',
        'status' => 'completed',
        'total_amount' => 999,
        'placed_at' => Carbon::parse('2026-07-20 09:30:00'),
    ]);
    OrderItem::query()->create([
        'order_id' => $matchingOrder->id,
        'product_id' => $matchingProduct->id,
        'item_type' => 'product',
        'item_id' => $matchingProduct->id,
        'product_name' => $matchingProduct->name,
        'quantity' => 1,
        'price' => 999,
        'line_total' => 999,
    ]);

    $otherOrder = Order::query()->create([
        'added_by' => $admin->id,
        'order_number' => 'ORD-FILTER-OTHER',
        'customer_name' => 'Mina Customer',
        'customer_email' => 'mina@example.com',
        'order_type' => 'delivery',
        'payment_method' => 'aba',
        'payment_status' => 'unpaid',
        'status' => 'pending',
        'total_amount' => 1200,
        'placed_at' => Carbon::parse('2026-07-20 10:30:00'),
    ]);
    OrderItem::query()->create([
        'order_id' => $otherOrder->id,
        'product_id' => $otherProduct->id,
        'item_type' => 'product',
        'item_id' => $otherProduct->id,
        'product_name' => $otherProduct->name,
        'quantity' => 1,
        'price' => 1200,
        'line_total' => 1200,
    ]);

    $response = $this
        ->actingAs($admin)
        ->getJson('/api/orders?from_date=2026-07-01&to_date=2026-07-31&payment_method=cash&payment_status=paid&status=completed&product_category=phones&product=iPhone&employee=Sophea&q=Dara');

    $response
        ->assertOk()
        ->assertJsonPath('meta.total', 1)
        ->assertJsonPath('data.0.order_number', 'ORD-FILTER-MATCH');
});
