<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Role;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class AdminUserController extends Controller
{
    /**
     * Legacy operational roles kept for delivery/repair assignment. Web admin
     * accounts are managed through the roles table and the user_roles pivot.
     */
    private const LEGACY_ROLES = ['staff', 'technician'];

    public function index(Request $request)
    {
        $perPage = (int) $request->input('per_page', 20);
        $perPage = max(1, min(100, $perPage));

        $query = User::query()
            ->with('roles:id,name')
            ->where(function ($builder) {
                $builder
                    ->whereHas('roles')
                    ->orWhereIn('role', self::LEGACY_ROLES);
            })
            ->where(function ($builder) {
                $builder->whereNull('is_admin')->orWhere('is_admin', false);
            })
            ->where(function ($builder) {
                $builder->whereNull('role')->orWhere('role', '!=', 'admin');
            })
            ->orderBy('first_name')
            ->orderBy('last_name')
            ->orderBy('id');

        if ($request->filled('q')) {
            $search = trim((string) $request->input('q'));
            $query->where(function ($builder) use ($search) {
                $builder
                    ->where('first_name', 'like', '%'.$search.'%')
                    ->orWhere('last_name', 'like', '%'.$search.'%')
                    ->orWhere('email', 'like', '%'.$search.'%')
                    ->orWhere('phone', 'like', '%'.$search.'%');
            });
        }

        if ($request->filled('role_id')) {
            $roleId = (int) $request->input('role_id');
            $query->whereHas('roles', fn ($builder) => $builder->where('roles.id', $roleId));
        }

        if ($request->filled('status')) {
            $query->where('status', $request->input('status'));
        }

        $users = $query->paginate($perPage)->withQueryString();

        return response()->json([
            'data' => $users->getCollection()->map(fn (User $user) => $this->transformUser($user))->values(),
            'meta' => [
                'current_page' => $users->currentPage(),
                'last_page' => $users->lastPage(),
                'per_page' => $users->perPage(),
                'total' => $users->total(),
            ],
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'first_name' => ['required', 'string', 'max:255'],
            'last_name' => ['nullable', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'phone' => ['nullable', 'string', 'max:30'],
            'role_id' => ['required', 'integer', 'exists:roles,id'],
            'password' => ['required', 'string', 'min:8', 'max:255'],
        ]);

        $role = Role::findOrFail($validated['role_id']);

        $user = User::create([
            'first_name' => trim($validated['first_name']),
            'last_name' => trim((string) ($validated['last_name'] ?? '')),
            'email' => strtolower(trim($validated['email'])),
            'phone' => trim((string) ($validated['phone'] ?? '')),
            'role' => $this->legacyRoleFor($role),
            'status' => 'active',
            'password' => $validated['password'],
            'is_admin' => false,
        ]);

        $user->roles()->sync([$role->id]);
        $user->load('roles:id,name');

        return response()->json([
            'data' => $this->transformUser($user),
        ], 201);
    }

    public function show(User $user)
    {
        $this->abortIfUnmanaged($user);

        $user->load('roles:id,name');

        return response()->json(['data' => $this->transformUser($user)]);
    }

    public function update(Request $request, User $user)
    {
        $this->abortIfUnmanaged($user);

        $validated = $request->validate([
            'first_name' => ['sometimes', 'required', 'string', 'max:255'],
            'last_name' => ['nullable', 'string', 'max:255'],
            'email' => ['sometimes', 'required', 'email', 'max:255', 'unique:users,email,'.$user->id],
            'phone' => ['nullable', 'string', 'max:30'],
            'role_id' => ['sometimes', 'required', 'integer', 'exists:roles,id'],
            'status' => ['sometimes', Rule::in(['active', 'inactive'])],
            'password' => ['nullable', 'string', 'min:8', 'max:255'],
        ]);

        if (array_key_exists('first_name', $validated)) {
            $user->first_name = trim($validated['first_name']);
        }
        if (array_key_exists('last_name', $validated)) {
            $user->last_name = trim((string) $validated['last_name']);
        }
        if (array_key_exists('email', $validated)) {
            $user->email = strtolower(trim($validated['email']));
        }
        if (array_key_exists('phone', $validated)) {
            $user->phone = trim((string) $validated['phone']);
        }
        if (array_key_exists('status', $validated)) {
            $user->status = $validated['status'];
        }
        if (! empty($validated['password'])) {
            $user->password = Hash::make($validated['password']);
        }

        if (array_key_exists('role_id', $validated)) {
            $role = Role::findOrFail($validated['role_id']);
            $user->role = $this->legacyRoleFor($role);
            $user->is_admin = false;
            $user->roles()->sync([$role->id]);
        }

        $user->save();
        $user->load('roles:id,name');

        return response()->json(['data' => $this->transformUser($user)]);
    }

    public function destroy(User $user)
    {
        $this->abortIfUnmanaged($user);

        $user->roles()->detach();
        $user->tokens()->delete();
        $user->delete();

        return response()->json(['message' => 'User deleted.']);
    }

    public function updateStatus(Request $request, User $user)
    {
        $this->abortIfUnmanaged($user);

        $validated = $request->validate([
            'status' => ['required', Rule::in(['active', 'inactive'])],
        ]);

        $user->status = $validated['status'];
        $user->save();

        return response()->json(['data' => $this->transformUser($user)]);
    }

    private function abortIfUnmanaged(User $user): void
    {
        if ($user->is_admin || $user->role === 'admin') {
            abort(404);
        }

        if (! $user->roles()->exists() && ! in_array($user->role, self::LEGACY_ROLES, true)) {
            abort(404);
        }
    }

    /**
     * Keep the legacy users.role column meaningful: staff/technician roles
     * still drive delivery and repair assignment, everything else becomes a
     * generic web admin account (never 'admin' or 'user' so these accounts
     * gain no super admin rights and never show up as customers).
     */
    private function legacyRoleFor(Role $role): string
    {
        $name = Str::snake(strtolower(trim($role->name)));

        return in_array($name, self::LEGACY_ROLES, true) ? $name : 'webadmin';
    }

    private function transformUser(User $user): array
    {
        $role = $user->roles->first();

        return [
            'id' => $user->id,
            'name' => $user->name,
            'first_name' => $user->first_name,
            'last_name' => $user->last_name,
            'email' => $user->email,
            'phone' => $user->phone,
            'role' => $user->role,
            'role_id' => $role?->id,
            'role_name' => $role?->name ?? ucfirst((string) $user->role),
            'status' => $user->status ?? 'active',
            'created_at' => $user->created_at?->toISOString(),
        ];
    }
}
