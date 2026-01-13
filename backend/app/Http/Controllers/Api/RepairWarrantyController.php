<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Concerns\AuthorizesRepairRequests;
use App\Http\Controllers\Controller;
use App\Http\Resources\WarrantyResource;
use App\Models\RepairRequest;
use App\Models\Warranty;
use Illuminate\Http\Request;

class RepairWarrantyController extends Controller
{
    use AuthorizesRepairRequests;

    public function index(Request $request)
    {
        $query = Warranty::query()->with('repair')->orderByDesc('created_at');

        if ($request->filled('status')) {
            $query->where('status', strtolower($request->string('status')));
        }

        $perPage = (int) $request->input('per_page', 10);
        $perPage = max(1, min(50, $perPage));

        return WarrantyResource::collection($query->paginate($perPage)->withQueryString());
    }

    public function store(Request $request, RepairRequest $repair)
    {
        $validated = $request->validate([
            'duration_days' => ['nullable', 'integer', 'min:1'],
            'covered_issues' => ['nullable', 'string'],
            'start_date' => ['nullable', 'date'],
            'end_date' => ['nullable', 'date'],
            'status' => ['nullable', 'string'],
        ]);

        $startDate = $validated['start_date'] ?? null;
        $endDate = $validated['end_date'] ?? null;
        if ($startDate && ! $endDate && ! empty($validated['duration_days'])) {
            $endDate = \Carbon\Carbon::parse($startDate)->addDays((int) $validated['duration_days'])->toDateString();
        }

        $warranty = Warranty::updateOrCreate(
            ['repair_id' => $repair->id],
            [
                'duration_days' => $validated['duration_days'] ?? null,
                'covered_issues' => $validated['covered_issues'] ?? null,
                'start_date' => $startDate,
                'end_date' => $endDate,
                'status' => $validated['status'] ? strtolower($validated['status']) : 'active',
            ]
        );

        return new WarrantyResource($warranty);
    }

    public function show(Request $request, RepairRequest $repair)
    {
        if ($response = $this->ensureRepairAccess($request, $repair)) {
            return $response;
        }

        $warranty = $repair->warranty;
        if (! $warranty) {
            return response()->json(['message' => 'Warranty not found.'], 404);
        }

        return new WarrantyResource($warranty);
    }
}
