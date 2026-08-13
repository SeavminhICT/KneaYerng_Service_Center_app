<?php

namespace Database\Seeders;

use App\Models\RepairProblem;
use Illuminate\Database\Seeder;

class RepairProblemSeeder extends Seeder
{
    public const PROBLEMS = [
        'Screen broken' => 15.00,
        'Touch screen not working' => 15.00,
        'Battery drains fast' => 10.00,
        "Won't power on" => 20.00,
        'Charging port issue' => 12.00,
        'Camera not working' => 15.00,
        'Speaker not working' => 10.00,
        'Microphone not working' => 10.00,
        'Face ID / Fingerprint issue' => 20.00,
        'Wi-Fi / Bluetooth issue' => 15.00,
        'Water damage' => 25.00,
        'Software error' => 10.00,
        'Random restart' => 15.00,
        'Data loss' => 20.00,
        'Other' => 5.00,
    ];

    public function run(): void
    {
        $sortOrder = 0;
        foreach (self::PROBLEMS as $name => $fee) {
            RepairProblem::updateOrCreate(
                ['name' => $name],
                ['service_fee' => $fee, 'sort_order' => $sortOrder, 'status' => 'active']
            );
            $sortOrder++;
        }
    }
}
