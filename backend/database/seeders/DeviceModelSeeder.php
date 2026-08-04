<?php

namespace Database\Seeders;

use App\Models\DeviceModel;
use Illuminate\Database\Seeder;

class DeviceModelSeeder extends Seeder
{
    public const MODELS = [
        ['Apple', 'iPhone 16 Pro Max'],
        ['Apple', 'iPhone 16 Pro'],
        ['Apple', 'iPhone 16'],
        ['Apple', 'iPhone 15 Pro Max'],
        ['Apple', 'iPhone 15 Pro'],
        ['Apple', 'iPhone 15'],
        ['Apple', 'iPhone 14 Pro Max'],
        ['Apple', 'iPhone 14'],
        ['Apple', 'iPad Pro 12.9'],
        ['Apple', 'MacBook Pro 14'],
        ['Apple', 'MacBook Air M3'],
        ['Samsung', 'Galaxy S24 Ultra'],
        ['Samsung', 'Galaxy S23'],
        ['Samsung', 'Galaxy A54'],
        ['Xiaomi', 'Redmi Note 13'],
        ['Oppo', 'Reno 11'],
        ['Vivo', 'V29'],
    ];

    public function run(): void
    {
        foreach (self::MODELS as $index => [$brand, $modelName]) {
            DeviceModel::updateOrCreate(
                ['brand' => $brand, 'model_name' => $modelName],
                ['sort_order' => $index, 'status' => 'active']
            );
        }
    }
}
