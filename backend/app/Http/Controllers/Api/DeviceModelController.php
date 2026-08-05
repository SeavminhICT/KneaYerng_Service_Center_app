<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\DeviceModelResource;
use App\Models\DeviceModel;
use Illuminate\Http\Request;

class DeviceModelController extends Controller
{
    public function index(Request $request)
    {
        $query = DeviceModel::query()->orderBy('sort_order')->orderBy('brand')->orderBy('model_name');

        if ($request->filled('q')) {
            $q = $request->string('q');
            $query->where(function ($builder) use ($q) {
                $builder->where('brand', 'like', "%{$q}%")
                    ->orWhere('model_name', 'like', "%{$q}%");
            });
        }

        if ($request->filled('status')) {
            $query->where('status', $request->string('status'));
        }

        $perPage = max(1, min((int) $request->integer('per_page', 100), 200));

        return DeviceModelResource::collection($query->paginate($perPage)->withQueryString());
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'brand' => ['required', 'string', 'max:255'],
            'model_name' => ['required', 'string', 'max:255'],
            'sort_order' => ['nullable', 'integer', 'min:0'],
            'status' => ['nullable', 'string', 'in:active,inactive'],
        ]);

        $actor = $request->user() ?? $request->user('sanctum');

        $deviceModel = DeviceModel::create([
            'added_by' => $actor?->id,
            'brand' => $validated['brand'],
            'model_name' => $validated['model_name'],
            'sort_order' => $validated['sort_order'] ?? 0,
            'status' => $validated['status'] ?? 'active',
        ]);

        return new DeviceModelResource($deviceModel);
    }

    public function update(Request $request, DeviceModel $deviceModel)
    {
        $validated = $request->validate([
            'brand' => ['sometimes', 'string', 'max:255'],
            'model_name' => ['sometimes', 'string', 'max:255'],
            'sort_order' => ['nullable', 'integer', 'min:0'],
            'status' => ['nullable', 'string', 'in:active,inactive'],
        ]);

        $deviceModel->fill($validated);
        $deviceModel->save();

        return new DeviceModelResource($deviceModel);
    }

    public function destroy(DeviceModel $deviceModel)
    {
        $deviceModel->delete();

        return response()->noContent();
    }
}
