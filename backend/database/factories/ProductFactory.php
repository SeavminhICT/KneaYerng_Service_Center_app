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
            'name' => $this->faker->words(3, true),
            'description' => $this->faker->sentence(12),
            'sku' => $this->faker->unique()->bothify('SKU-#####'),
            'price' => $this->faker->randomFloat(2, 10, 500),
            'discount' => $this->faker->randomFloat(2, 0, 50),
            'stock' => $this->faker->numberBetween(0, 200),
            'status' => 'active',
            'brand' => $this->faker->company(),
            'storage_capacity' => ['64GB', '128GB'],
            'color' => ['Black', 'Silver'],
            'condition' => ['New'],
        ];
    }
}
