<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;

class AdminUserController extends Controller
{
    /**
     * Dashboard-access roles managed here. Customers (role=user) register
     * through the app and are out of scope for this admin-only CRUD.
     */
    private const DASHBOARD_ROLES = ['admin', 'manager', 'staff', 'technician'];

    public function index(Request $request)
    {
        $perPage = (int) $request->input('per_page', 20);
        $perPage = max(1, min(100, $perPage));

        $query = User::query()
            ->whereIn('role', self::DASHBOARD_ROLES)
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

        if ($request->filled('role')) {
            $query->where('role', $request->input('role'));
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
            'role' => ['required', Rule::in(self::DASHBOARD_ROLES)],
            'status' => ['nullable', Rule::in(['active', 'inactive'])],
            'password' => ['required', 'string', 'min:8', 'max:255'],
        ]);

        $user = User::create([
            'first_name' => trim($validated['first_name']),
            'last_name' => trim((string) ($validated['last_name'] ?? '')),
            'email' => strtolower(trim($validated['email'])),
            'phone' => trim((string) ($validated['phone'] ?? '')),
            'role' => $validated['role'],
            'status' => $validated['status'] ?? 'active',
            'password' => $validated['password'],
            'is_admin' => $validated['role'] === 'admin',
        ]);

        return response()->json([
            'data' => $this->transformUser($user),
        ], 201);
    }

    public function show(User $user)
    {
        $this->abortIfCustomer($user);

        return response()->json(['data' => $this->transformUser($user)]);
    }

    public function update(Request $request, User $user)
    {
        $this->abortIfCustomer($user);

        $validated = $request->validate([
            'first_name' => ['sometimes', 'required', 'string', 'max:255'],
            'last_name' => ['nullable', 'string', 'max:255'],
            'email' => ['sometimes', 'required', 'email', 'max:255', 'unique:users,email,'.$user->id],
            'phone' => ['nullable', 'string', 'max:30'],
            'role' => ['sometimes', 'required', Rule::in(self::DASHBOARD_ROLES)],
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
        if (array_key_exists('role', $validated)) {
            $user->role = $validated['role'];
            $user->is_admin = $validated['role'] === 'admin';
        }
        if (array_key_exists('status', $validated)) {
            $user->status = $validated['status'];
        }
        if (! empty($validated['password'])) {
            $user->password = Hash::make($validated['password']);
        }

        $user->save();

        return response()->json(['data' => $this->transformUser($user)]);
    }

    public function destroy(User $user)
    {
        $this->abortIfCustomer($user);

        $user->delete();

        return response()->json(['message' => 'User deleted.']);
    }

    public function updateStatus(Request $request, User $user)
    {
        $this->abortIfCustomer($user);

        $validated = $request->validate([
            'status' => ['required', Rule::in(['active', 'inactive'])],
        ]);

        $user->status = $validated['status'];
        $user->save();

        return response()->json(['data' => $this->transformUser($user)]);
    }

    private function abortIfCustomer(User $user): void
    {
        if (! in_array($user->role, self::DASHBOARD_ROLES, true)) {
            abort(404);
        }
    }

    private function transformUser(User $user): array
    {
        return [
            'id' => $user->id,
            'name' => $user->name,
            'first_name' => $user->first_name,
            'last_name' => $user->last_name,
            'email' => $user->email,
            'phone' => $user->phone,
            'role' => $user->role,
            'status' => $user->status ?? 'active',
            'created_at' => $user->created_at?->toISOString(),
        ];
    }
}
