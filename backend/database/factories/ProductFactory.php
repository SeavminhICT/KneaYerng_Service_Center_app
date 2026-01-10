<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Product>
 */
class ProductFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'name' => fake()->words(3, true),
            'description' => fake()->sentence(12),
            'sku' => fake()->unique()->bothify('SKU-#####'),
            'price' => fake()->randomFloat(2, 10, 500),
            'discount' => fake()->randomFloat(2, 0, 50),
            'stock' => fake()->numberBetween(0, 200),
            'status' => 'active',
            'brand' => fake()->company(),
            'storage_capacity' => ['64GB', '128GB'],
            'color' => ['Black', 'Silver'],
            'condition' => ['New'],
        ];
    }
}
