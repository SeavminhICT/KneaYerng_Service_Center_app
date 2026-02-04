<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\StorePartRequest;
use App\Http\Requests\Api\UpdatePartRequest;
use App\Http\Resources\PartResource;
use App\Models\Part;
use Illuminate\Http\Request;

class PartController extends Controller
{
    public function index(Request $request)
    {
        $query = Part::query()->orderByDesc('id');

        if ($request->filled('q')) {
            $q = $request->string('q');
            $query->where(function ($builder) use ($q) {
                $builder->where('name', 'like', "%{$q}%")
                    ->orWhere('sku', 'like', "%{$q}%")
                    ->orWhere('brand', 'like', "%{$q}%")
                    ->orWhere('type', 'like', "%{$q}%");
            });
        }

        $perPage = (int) $request->input('per_page', 10);
        $perPage = max(1, min(50, $perPage));

        $parts = $query->paginate($perPage)->withQueryString();

        return PartResource::collection($parts);
    }

    public function store(StorePartRequest $request)
    {
        $part = Part::create($request->validated());

        return new PartResource($part);
    }

    public function show(Part $part)
    {
        return new PartResource($part);
    }

    public function update(UpdatePartRequest $request, Part $part)
    {
        $part->fill($request->validated());
        $part->save();

        return new PartResource($part);
    }

    public function destroy(Part $part)
    {
        $part->delete();

        return response()->noContent();
    }
}
