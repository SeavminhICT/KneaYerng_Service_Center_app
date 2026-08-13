<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\RepairProblemResource;
use App\Models\RepairProblem;
use Illuminate\Http\Request;

class RepairProblemController extends Controller
{
    public function index(Request $request)
    {
        $query = RepairProblem::query()->orderBy('sort_order')->orderBy('name');

        if ($request->filled('q')) {
            $query->where('name', 'like', '%'.$request->string('q').'%');
        }

        if ($request->filled('status')) {
            $query->where('status', $request->string('status'));
        }

        $perPage = max(1, min((int) $request->integer('per_page', 100), 200));

        return RepairProblemResource::collection($query->paginate($perPage)->withQueryString());
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'service_fee' => ['required', 'numeric', 'min:0'],
            'sort_order' => ['nullable', 'integer', 'min:0'],
            'status' => ['nullable', 'string', 'in:active,inactive'],
        ]);

        $actor = $request->user() ?? $request->user('sanctum');

        $problem = RepairProblem::create([
            'added_by' => $actor?->id,
            'name' => $validated['name'],
            'service_fee' => $validated['service_fee'],
            'sort_order' => $validated['sort_order'] ?? 0,
            'status' => $validated['status'] ?? 'active',
        ]);

        return new RepairProblemResource($problem);
    }

    public function update(Request $request, RepairProblem $repairProblem)
    {
        $validated = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'service_fee' => ['sometimes', 'required', 'numeric', 'min:0'],
            'sort_order' => ['nullable', 'integer', 'min:0'],
            'status' => ['nullable', 'string', 'in:active,inactive'],
        ]);

        $repairProblem->fill($validated);
        $repairProblem->save();

        return new RepairProblemResource($repairProblem);
    }

    public function destroy(RepairProblem $repairProblem)
    {
        $repairProblem->delete();

        return response()->noContent();
    }
}
