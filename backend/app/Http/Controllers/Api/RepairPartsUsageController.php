<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\PartsUsageResource;
use App\Models\Part;
use App\Models\PartsUsage;
use App\Models\RepairRequest;
use Illuminate\Http\Request;

class RepairPartsUsageController extends Controller
{
    public function index(RepairRequest $repair)
    {
        $usages = $repair->partsUsages()->with('part')->orderByDesc('created_at')->get();

        return PartsUsageResource::collection($usages);
    }

    public function store(Request $request, RepairRequest $repair)
    {
        $validated = $request->validate([
            'part_id' => ['required', 'exists:parts,id'],
            'quantity' => ['required', 'integer', 'min:1'],
            'cost' => ['nullable', 'numeric', 'min:0'],
        ]);

        $part = Part::findOrFail($validated['part_id']);
        $quantity = (int) $validated['quantity'];

        if ($part->stock < $quantity) {
            return response()->json(['message' => 'Insufficient stock.'], 422);
        }

        $cost = $validated['cost'] ?? $part->unit_cost;

        $usage = PartsUsage::create([
            'repair_id' => $repair->id,
            'part_id' => $part->id,
            'quantity' => $quantity,
            'cost' => $cost,
        ]);

        $part->stock = $part->stock - $quantity;
        $part->save();

        return new PartsUsageResource($usage->load('part'));
    }
}
