<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\DiagnosticResource;
use App\Models\Diagnostic;
use App\Models\RepairRequest;
use App\Models\RepairStatusLog;
use Illuminate\Http\Request;

class RepairDiagnosticController extends Controller
{
    public function store(Request $request, RepairRequest $repair)
    {
        $validated = $request->validate([
            'problem_description' => ['nullable', 'string'],
            'parts_required' => ['nullable', 'array'],
            'parts_required.*' => ['string', 'max:255'],
            'labor_cost' => ['nullable', 'numeric', 'min:0'],
            'diagnostic_notes' => ['nullable', 'string'],
        ]);

        $diagnostic = Diagnostic::updateOrCreate(
            ['repair_id' => $repair->id],
            [
                'problem_description' => $validated['problem_description'] ?? null,
                'parts_required' => $validated['parts_required'] ?? [],
                'labor_cost' => $validated['labor_cost'] ?? 0,
                'diagnostic_notes' => $validated['diagnostic_notes'] ?? null,
            ]
        );

        if ($repair->status === 'received') {
            $repair->status = 'diagnosing';
            $repair->save();
            RepairStatusLog::create([
                'repair_id' => $repair->id,
                'status' => 'diagnosing',
                'updated_by' => $request->user()?->id,
                'logged_at' => now(),
            ]);
        }

        return new DiagnosticResource($diagnostic);
    }
}
