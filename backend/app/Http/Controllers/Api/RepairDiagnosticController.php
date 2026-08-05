<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\DiagnosticResource;
use App\Models\Diagnostic;
use App\Models\RepairRequest;
use App\Services\RepairStatusService;
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

        if (in_array($repair->status, [
            RepairStatusService::STATUS_NEW,
            RepairStatusService::STATUS_ASSIGNED,
            RepairStatusService::STATUS_ACCEPTED,
        ], true)) {
            // Diagnostic entry means diagnosis has effectively started, whether or
            // not the technician formally accepted first — force past the normal
            // new -> assigned -> accepted -> diagnosing sequence.
            $actor = $request->user() ?? $request->user('sanctum');
            RepairStatusService::transition($repair, RepairStatusService::STATUS_DIAGNOSING, $actor, force: true);
        }

        return new DiagnosticResource($diagnostic);
    }
}
