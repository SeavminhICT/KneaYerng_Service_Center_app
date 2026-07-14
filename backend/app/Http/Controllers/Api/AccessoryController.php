<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\StoreAccessoryRequest;
use App\Http\Requests\Api\UpdateAccessoryRequest;
use App\Http\Resources\AccessoryResource;
use App\Models\Accessory;
use App\Models\Part;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;

class AccessoryController extends Controller
{
    public function index(Request $request)
    {
        $query = Accessory::query()->with('addedBy')->orderByDesc('id');

        if ($request->filled('q')) {
            $query->where('name', 'like', '%'.$request->string('q').'%');
        }

        if ($request->filled('brand')) {
            $query->where('brand', $request->string('brand'));
        }

        if ($request->filled('warranty')) {
            $query->where('warranty', $request->string('warranty'));
        }

        if ($request->filled('min_price')) {
            $query->where('price', '>=', (float) $request->input('min_price'));
        }

        if ($request->filled('max_price')) {
            $query->where('price', '<=', (float) $request->input('max_price'));
        }

        $allowedSorts = ['price', 'created_at', 'name'];
        $sort = $request->input('sort');
        $order = strtolower((string) $request->input('order', 'desc')) === 'asc' ? 'asc' : 'desc';
        if ($sort && in_array($sort, $allowedSorts, true)) {
            $query->orderBy($sort, $order);
        }

        $perPage = (int) $request->input('limit', 10);
        if ($perPage <= 0 || $perPage > 100) {
            $perPage = 10;
        }

        $accessories = $query->paginate($perPage)->withQueryString();

        return AccessoryResource::collection($accessories);
    }

    public function store(StoreAccessoryRequest $request)
    {
        $validated = $request->validated();

        if ($request->hasFile('image')) {
            try {
                $disk = Storage::build(array_merge(config('filesystems.disks.public'), ['throw' => true]));
                $storedPath = $disk->putFile('accessories', $request->file('image'));
                $validated['image'] = 'storage/'.$storedPath;
            } catch (\Throwable $e) {
                Log::error('Accessory image upload failed.', ['error' => $e->getMessage()]);
                return response()->json(['message' => 'Image upload failed: '.$e->getMessage()], 500);
            }
        }

        $actor = $request->user() ?? $request->user('sanctum');
        $validated['added_by'] = $actor?->id;

        $accessory = Accessory::create($validated);
        $this->ensurePartFromAccessory($accessory);

        return new AccessoryResource($accessory->load('addedBy'));
    }

    public function show(Accessory $accessory)
    {
        return new AccessoryResource($accessory->load('addedBy'));
    }

    public function update(UpdateAccessoryRequest $request, Accessory $accessory)
    {
        $validated = $request->validated();

        if ($request->hasFile('image')) {
            if ($accessory->image) {
                $oldImagePath = str_replace('storage/', '', $accessory->image);
                Storage::disk('public')->delete($oldImagePath);
            }

            try {
                $disk = Storage::build(array_merge(config('filesystems.disks.public'), ['throw' => true]));
                $storedPath = $disk->putFile('accessories', $request->file('image'));
                $validated['image'] = 'storage/'.$storedPath;
            } catch (\Throwable $e) {
                Log::error('Accessory image upload failed.', ['error' => $e->getMessage()]);
                return response()->json(['message' => 'Image upload failed: '.$e->getMessage()], 500);
            }
        }

        $accessory->update($validated);

        return new AccessoryResource($accessory->load('addedBy'));
    }

    public function destroy(Accessory $accessory)
    {
        if ($accessory->image) {
            $oldImagePath = str_replace('storage/', '', $accessory->image);
            Storage::disk('public')->delete($oldImagePath);
        }

        $accessory->delete();

        return response()->json(['message' => 'Accessory or repair part deleted successfully']);
    }

    private function ensurePartFromAccessory(Accessory $accessory): void
    {
        $query = Part::query()
            ->where('type', 'accessory')
            ->where('name', $accessory->name);

        if ($accessory->brand) {
            $query->where('brand', $accessory->brand);
        }

        if ($query->exists()) {
            return;
        }

        Part::create([
            'name' => $accessory->name,
            'type' => 'accessory',
            'brand' => $accessory->brand,
            'sku' => null,
            'stock' => (int) ($accessory->stock ?? 0),
            'unit_cost' => (float) ($accessory->price ?? 0),
            'status' => 'active',
            'tag' => $accessory->tag,
        ]);
    }
}
