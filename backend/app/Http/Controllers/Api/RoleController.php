<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Permission;
use App\Models\Role;
use Illuminate\Http\Request;

class RoleController extends Controller
{
    public function index(Request $request)
    {
        $query = Role::query()->withCount('users')->orderBy('name');

        if ($request->filled('q')) {
            $search = trim((string) $request->input('q'));
            $query->where('name', 'like', '%'.$search.'%');
        }

        $roles = $query->get();

        return response()->json([
            'data' => $roles->map(fn (Role $role) => $this->transform($role))->values(),
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255', 'unique:roles,name'],
            'description' => ['nullable', 'string', 'max:1000'],
        ]);

        $role = Role::create($validated);

        return response()->json(['data' => $this->transform($role)], 201);
    }

    public function show(Role $role)
    {
        return response()->json(['data' => $this->transform($role)]);
    }

    public function update(Request $request, Role $role)
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255', 'unique:roles,name,'.$role->id],
            'description' => ['nullable', 'string', 'max:1000'],
        ]);

        $role->update($validated);

        return response()->json(['data' => $this->transform($role)]);
    }

    public function destroy(Role $role)
    {
        $role->delete();

        return response()->json(['message' => 'Role deleted.']);
    }

    public function permissions(Role $role)
    {
        return response()->json([
            'data' => [
                'role_id' => $role->id,
                'role_name' => $role->name,
                'permissions' => $role->permissions()->pluck('permissions.id'),
            ],
        ]);
    }

    public function updatePermissions(Request $request, Role $role)
    {
        $validated = $request->validate([
            'permission_ids' => ['array'],
            'permission_ids.*' => ['integer', 'exists:permissions,id'],
        ]);

        $role->permissions()->sync($validated['permission_ids'] ?? []);

        return response()->json([
            'message' => 'Permissions saved.',
            'data' => [
                'role_id' => $role->id,
                'permissions' => $role->permissions()->pluck('permissions.id'),
            ],
        ]);
    }

    private function transform(Role $role): array
    {
        return [
            'id' => $role->id,
            'name' => $role->name,
            'description' => $role->description,
            'users_count' => $role->users_count ?? null,
            'created_at' => $role->created_at?->toISOString(),
        ];
    }
}
