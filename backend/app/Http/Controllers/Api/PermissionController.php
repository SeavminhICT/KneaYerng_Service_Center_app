<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Permission;
use Illuminate\Http\Request;

class PermissionController extends Controller
{
    public function index(Request $request)
    {
        $query = Permission::query()->orderBy('name');

        if ($request->filled('q')) {
            $search = trim((string) $request->input('q'));
            $query->where('name', 'like', '%'.$search.'%');
        }

        return response()->json([
            'data' => $query->get()->map(fn (Permission $permission) => $this->transform($permission))->values(),
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255', 'unique:permissions,name'],
            'description' => ['nullable', 'string', 'max:1000'],
        ]);

        $permission = Permission::create($validated);

        return response()->json(['data' => $this->transform($permission)], 201);
    }

    public function show(Permission $permission)
    {
        return response()->json(['data' => $this->transform($permission)]);
    }

    public function update(Request $request, Permission $permission)
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255', 'unique:permissions,name,'.$permission->id],
            'description' => ['nullable', 'string', 'max:1000'],
        ]);

        $permission->update($validated);

        return response()->json(['data' => $this->transform($permission)]);
    }

    public function destroy(Permission $permission)
    {
        $permission->delete();

        return response()->json(['message' => 'Permission deleted.']);
    }

    private function transform(Permission $permission): array
    {
        return [
            'id' => $permission->id,
            'name' => $permission->name,
            'description' => $permission->description,
            'created_at' => $permission->created_at?->toISOString(),
        ];
    }
}
