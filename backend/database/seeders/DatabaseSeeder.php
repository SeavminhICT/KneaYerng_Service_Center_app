<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

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
    }
}
