<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\PartsUsageResource;
use App\Models\Part;
use App\Models\PartsUsage;
use App\Models\RepairRequest;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PartsUsageController extends Controller
{
    public function store(Request $request, RepairRequest $repair)
    {
        $validated = $request->validate([
            'part_id' => ['required', 'exists:parts,id'],
            'quantity' => ['required', 'integer', 'min:1'],
        ]);

        $part = Part::findOrFail($validated['part_id']);

        if ($part->stock < $validated['quantity']) {
            return response()->json(['message' => 'Not enough stock for this part.'], 422);
        }

        $usage = DB::transaction(function () use ($repair, $part, $validated) {
            $cost = $part->unit_cost * $validated['quantity'];

            $usage = PartsUsage::create([
                'repair_id' => $repair->id,
                'part_id' => $part->id,
                'quantity' => $validated['quantity'],
                'cost' => $cost,
            ]);

            $part->stock -= $validated['quantity'];
            $part->save();

            $this->recomputePartsCost($repair);

            return $usage;
        });

        return new PartsUsageResource($usage->load('part'));
    }

    /**
     * Total Repair Cost = Parts Cost + Service Fee (labor) + Additional Charges - Discount.
     * Parts Cost is derived from the sum of parts_usages so it can never drift
     * from what was actually deducted from inventory.
     */
    private function recomputePartsCost(RepairRequest $repair): void
    {
        $partsCost = (float) $repair->partsUsages()->sum('cost');

        $quotation = $repair->quotation;
        if ($quotation) {
            $quotation->parts_cost = $partsCost;
            $quotation->total_cost = $partsCost + (float) $quotation->labor_cost;
            $quotation->save();
        }

        $diagnostic = $repair->diagnostic;
        if ($diagnostic) {
            $partNames = $repair->partsUsages()->with('part')->get()
                ->map(fn ($usage) => $usage->part?->name)
                ->filter()
                ->unique()
                ->values()
                ->all();
            $diagnostic->parts_required = $partNames;
            $diagnostic->save();
        }
    }
}
