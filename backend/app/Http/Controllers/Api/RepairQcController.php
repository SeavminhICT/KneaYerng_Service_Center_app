<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\QcCheckResource;
use App\Models\QcCheck;
use App\Models\RepairRequest;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class RepairQcController extends Controller
{
    public const CHECKLIST_ITEMS = [
        'touch',
        'face_id',
        'camera',
        'charging',
        'speaker',
        'microphone',
        'wifi',
        'bluetooth',
    ];

    private const RESULT_VALUES = ['pass', 'fail', 'na'];

    public function store(Request $request, RepairRequest $repair)
    {
        $validated = $request->validate([
            'results' => ['nullable', 'array'],
            'results.*' => [Rule::in(self::RESULT_VALUES)],
            'notes' => ['nullable', 'string'],
        ]);

        $results = [];
        foreach (self::CHECKLIST_ITEMS as $item) {
            $results[$item] = $validated['results'][$item] ?? 'na';
        }

        $overallResult = in_array('fail', $results, true) ? 'fail' : 'pass';
        $actor = $request->user() ?? $request->user('sanctum');

        $qcCheck = QcCheck::updateOrCreate(
            ['repair_id' => $repair->id],
            [
                'results' => $results,
                'overall_result' => $overallResult,
                'notes' => $validated['notes'] ?? null,
                'checked_by' => $actor?->id,
                'checked_at' => now(),
            ]
        );

        return new QcCheckResource($qcCheck);
    }

    public function show(RepairRequest $repair)
    {
        $qcCheck = $repair->qcCheck;

        if (! $qcCheck) {
            return response()->json(['message' => 'QC check not found.'], 404);
        }

        return new QcCheckResource($qcCheck);
    }
}
