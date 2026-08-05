<?php

namespace Database\Seeders;

use App\Models\RepairProblem;
use Illuminate\Database\Seeder;

class RepairProblemSeeder extends Seeder
{
    public const PROBLEMS = [
        'Screen broken',
        'Touch screen not working',
        'Battery drains fast',
        "Won't power on",
        'Charging port issue',
        'Camera not working',
        'Speaker not working',
        'Microphone not working',
        'Face ID / Fingerprint issue',
        'Wi-Fi / Bluetooth issue',
        'Water damage',
        'Software error',
        'Random restart',
        'Data loss',
        'Other',
    ];

    public function run(): void
    {
        foreach (self::PROBLEMS as $index => $name) {
            RepairProblem::updateOrCreate(
                ['name' => $name],
                ['sort_order' => $index, 'status' => 'active']
            );
        }
    }
}
