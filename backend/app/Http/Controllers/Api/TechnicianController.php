<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\TechnicianResource;
use App\Models\Technician;
use Illuminate\Http\Request;

class TechnicianController extends Controller
{
    public function index(Request $request)
    {
        $query = Technician::query()->orderBy('name');

        if ($request->filled('q')) {
            $query->where('name', 'like', '%'.$request->string('q').'%');
        }

        if ($request->filled('availability_status')) {
            $query->where('availability_status', strtolower($request->string('availability_status')));
        }

        $perPage = (int) $request->input('per_page', 10);
        $perPage = max(1, min(50, $perPage));

        return TechnicianResource::collection($query->paginate($perPage)->withQueryString());
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'skill_set' => ['nullable', 'array'],
            'skill_set.*' => ['string', 'max:255'],
            'active_jobs_count' => ['nullable', 'integer', 'min:0'],
            'availability_status' => ['nullable', 'string', 'max:50'],
        ]);

        $technician = Technician::create([
            'name' => $validated['name'],
            'skill_set' => $validated['skill_set'] ?? [],
            'active_jobs_count' => $validated['active_jobs_count'] ?? 0,
            'availability_status' => $validated['availability_status'] ? strtolower($validated['availability_status']) : 'available',
        ]);

        return new TechnicianResource($technician);
    }

    public function show(Technician $technician)
    {
        return new TechnicianResource($technician);
    }

    public function update(Request $request, Technician $technician)
    {
        $validated = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'skill_set' => ['nullable', 'array'],
            'skill_set.*' => ['string', 'max:255'],
            'active_jobs_count' => ['nullable', 'integer', 'min:0'],
            'availability_status' => ['nullable', 'string', 'max:50'],
        ]);

        if (array_key_exists('name', $validated)) {
            $technician->name = $validated['name'];
        }

        if (array_key_exists('skill_set', $validated)) {
            $technician->skill_set = $validated['skill_set'] ?? [];
        }

        if (array_key_exists('active_jobs_count', $validated)) {
            $technician->active_jobs_count = $validated['active_jobs_count'] ?? 0;
        }

        if (array_key_exists('availability_status', $validated)) {
            $technician->availability_status = $validated['availability_status']
                ? strtolower($validated['availability_status'])
                : $technician->availability_status;
        }

        $technician->save();

        return new TechnicianResource($technician);
    }

    public function destroy(Technician $technician)
    {
        $technician->delete();

        return response()->noContent();
    }
}
