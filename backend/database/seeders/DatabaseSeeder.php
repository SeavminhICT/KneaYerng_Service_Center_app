<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Voucher;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Carbon;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // User::factory(10)->create();

        User::updateOrCreate(
            ['email' => 'admin168@gmail.com'],
            [
                'first_name' => 'Admin',
                'last_name' => 'User',
                'role' => 'admin',
                'is_admin' => true,
                'password' => Hash::make('Admin@168'),
            ]
        );

        User::updateOrCreate(
            ['email' => 'test@example.com'],
            [
                'first_name' => 'Test',
                'last_name' => 'User',
                'role' => 'user',
                'password' => Hash::make('password'),
            ]
        );

        Voucher::updateOrCreate(
            ['code' => 'SAVE10'],
            [
                'name' => 'Discount Voucher',
                'discount_type' => 'percent',
                'discount_value' => 10,
                'min_order_amount' => 0,
                'starts_at' => null,
                'expires_at' => Carbon::create(2026, 3, 31, 23, 59, 59),
                'usage_limit_total' => null,
                'usage_limit_per_user' => null,
                'is_active' => true,
                'is_stackable' => false,
                'description' => 'Applicable on all products. Not valid with other promotions.',
            ]
        );

        Voucher::updateOrCreate(
            ['code' => 'WELCOME20'],
            [
                'name' => 'Customer Discount Voucher',
                'discount_type' => 'percent',
                'discount_value' => 20,
                'min_order_amount' => 50,
                'starts_at' => Carbon::create(2026, 2, 1, 0, 0, 0),
                'expires_at' => Carbon::create(2026, 4, 30, 23, 59, 59),
                'usage_limit_total' => null,
                'usage_limit_per_user' => 1,
                'is_active' => true,
                'is_stackable' => false,
                'description' => 'One-time use per customer. Cannot be combined with other offers. Valid for online purchases only.',
            ]
        );
    }
}
