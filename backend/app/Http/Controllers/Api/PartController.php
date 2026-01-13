<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\PartResource;
use App\Models\Part;
use Illuminate\Http\Request;

class PartController extends Controller
{
    public function index(Request $request)
    {
        $query = Part::query()->orderBy('name');

        if ($request->filled('q')) {
            $query->where('name', 'like', '%'.$request->string('q').'%')
                ->orWhere('sku', 'like', '%'.$request->string('q').'%');
        }

        if ($request->filled('status')) {
            $query->where('status', strtolower($request->string('status')));
        }

        $perPage = (int) $request->input('per_page', 10);
        $perPage = max(1, min(50, $perPage));

        return PartResource::collection($query->paginate($perPage)->withQueryString());
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'sku' => ['nullable', 'string', 'max:100', 'unique:parts,sku'],
            'stock' => ['nullable', 'integer', 'min:0'],
            'unit_cost' => ['nullable', 'numeric', 'min:0'],
            'status' => ['nullable', 'string', 'max:50'],
        ]);

        $part = Part::create([
            'name' => $validated['name'],
            'sku' => $validated['sku'] ?? null,
            'stock' => $validated['stock'] ?? 0,
            'unit_cost' => $validated['unit_cost'] ?? 0,
            'status' => $validated['status'] ? strtolower($validated['status']) : 'active',
        ]);

        return new PartResource($part);
    }

    public function show(Part $part)
    {
        return new PartResource($part);
    }

    public function update(Request $request, Part $part)
    {
        $validated = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'sku' => ['nullable', 'string', 'max:100', 'unique:parts,sku,'.$part->id],
            'stock' => ['nullable', 'integer', 'min:0'],
            'unit_cost' => ['nullable', 'numeric', 'min:0'],
            'status' => ['nullable', 'string', 'max:50'],
        ]);

        if (array_key_exists('name', $validated)) {
            $part->name = $validated['name'];
        }

        if (array_key_exists('sku', $validated)) {
            $part->sku = $validated['sku'];
        }

        if (array_key_exists('stock', $validated)) {
            $part->stock = $validated['stock'] ?? 0;
        }

        if (array_key_exists('unit_cost', $validated)) {
            $part->unit_cost = $validated['unit_cost'] ?? 0;
        }

        if (array_key_exists('status', $validated)) {
            $part->status = $validated['status'] ? strtolower($validated['status']) : $part->status;
        }

        $part->save();

        return new PartResource($part);
    }

    public function destroy(Part $part)
    {
        $part->delete();

        return response()->noContent();
    }
}
