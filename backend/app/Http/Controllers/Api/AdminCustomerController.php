<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class AdminCustomerController extends Controller
{
    /**
     * Lightweight typeahead search over plain customer accounts, reusing the
     * same admin/staff/admin-email exclusion filter as the full customers
     * list page (routes/web.php `customers.index`).
     */
    public function search(Request $request)
    {
        $adminEmails = (array) config('auth.admin_emails', []);
        $search = trim((string) $request->string('q', ''));

        $query = User::query()
            ->where(function ($query) {
                $query->whereNull('is_admin')->orWhere('is_admin', false);
            })
            ->where(function ($query) {
                $query->whereNull('role')->orWhere('role', 'user');
            });

        if (! empty($adminEmails)) {
            $query->where(function ($query) use ($adminEmails) {
                $query->whereNull('email')->orWhereNotIn('email', $adminEmails);
            });
        }

        if ($search !== '') {
            $query->where(function ($q) use ($search) {
                $q->where('first_name', 'like', "%{$search}%")
                    ->orWhere('last_name', 'like', "%{$search}%")
                    ->orWhere('email', 'like', "%{$search}%")
                    ->orWhere('phone', 'like', "%{$search}%");
            });
        }

        $customers = $query->orderByDesc('id')->limit(20)->get(['id', 'first_name', 'last_name', 'email', 'phone']);

        return response()->json([
            'data' => $customers->map(fn (User $user) => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'phone' => $user->phone,
            ]),
        ]);
    }

    /**
     * Quick-create a plain customer account for a walk-in repair job, mirroring
     * AuthController::register()'s plain-customer field set (role=user,
     * status=active, is_admin=false). Password is random — the customer can
     * recover access later via the existing OTP reset flow.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'first_name' => ['required', 'string', 'max:255'],
            'last_name' => ['nullable', 'string', 'max:255'],
            'email' => ['nullable', 'email', 'max:255', 'unique:users,email'],
            'phone' => ['nullable', 'string', 'max:50'],
        ]);

        $user = User::create([
            'first_name' => $validated['first_name'],
            'last_name' => $validated['last_name'] ?? '',
            'email' => $validated['email'] ?? null,
            'phone' => $validated['phone'] ?? null,
            'password' => Hash::make(Str::random(32)),
            'role' => 'user',
            'status' => 'active',
            'is_admin' => false,
        ]);

        return response()->json([
            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'phone' => $user->phone,
            ],
        ], 201);
    }
}
