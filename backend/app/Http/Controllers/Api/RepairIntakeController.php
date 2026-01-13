<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\IntakeResource;
use App\Models\Intake;
use App\Models\RepairRequest;
use Illuminate\Http\Request;

class RepairIntakeController extends Controller
{
    public function store(Request $request, RepairRequest $repair)
    {
        $validated = $request->validate([
            'imei_serial' => ['nullable', 'string', 'max:100'],
            'device_condition_checklist' => ['nullable', 'array'],
            'device_condition_checklist.*' => ['string', 'max:255'],
            'intake_photos' => ['nullable', 'array'],
            'intake_photos.*' => ['string', 'max:255'],
            'notes' => ['nullable', 'string'],
        ]);

        $intake = Intake::updateOrCreate(
            ['repair_id' => $repair->id],
            [
                'imei_serial' => $validated['imei_serial'] ?? null,
                'device_condition_checklist' => $validated['device_condition_checklist'] ?? [],
                'intake_photos' => $validated['intake_photos'] ?? [],
                'notes' => $validated['notes'] ?? null,
            ]
        );

        return new IntakeResource($intake);
    }

    public function show(RepairRequest $repair)
    {
        $intake = $repair->intake;

        if (! $intake) {
            return response()->json(['message' => 'Intake not found.'], 404);
        }

        return new IntakeResource($intake);
    }
}
