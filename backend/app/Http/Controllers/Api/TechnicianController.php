<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\TechnicianResource;
use App\Models\Technician;
use App\Models\User;
use App\Services\RepairStatusService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;

class TechnicianController extends Controller
{
    public function index(Request $request)
    {
        $query = Technician::query()
            ->with('user:id,email,phone')
            ->withCount([
                'repairs as active_repairs_count' => function ($repairQuery) {
                    $repairQuery->whereIn('status', RepairStatusService::TECHNICIAN_BUSY_STATUSES);
                },
            ])
            ->orderBy('name');

        if ($request->filled('q')) {
            $query->where('name', 'like', '%'.$request->string('q').'%');
        }

        if ($request->filled('availability_status')) {
            $query->where('availability_status', strtolower($request->string('availability_status')));
        }

        if ($request->boolean('free_for_assignment')) {
            $query->where('availability_status', 'available')
                ->whereDoesntHave('repairs', function ($repairQuery) {
                    $repairQuery->whereIn('status', RepairStatusService::TECHNICIAN_BUSY_STATUSES);
                });
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
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'phone' => ['nullable', 'string', 'max:50', 'unique:users,phone'],
            'password' => ['required', 'string', 'min:8', 'max:255'],
        ]);

        $user = $this->createUserAccount(
            $validated['name'],
            $validated['email'],
            $validated['phone'] ?? null,
            $validated['password']
        );

        $technician = Technician::create([
            'user_id' => $user->id,
            'name' => $validated['name'],
            'skill_set' => $validated['skill_set'] ?? [],
            'active_jobs_count' => $validated['active_jobs_count'] ?? 0,
            'availability_status' => ! empty($validated['availability_status']) ? strtolower($validated['availability_status']) : 'available',
        ]);

        $technician->setRelation('user', $user);

        return new TechnicianResource($technician);
    }

    public function show(Technician $technician)
    {
        $technician->loadMissing('user:id,email,phone');

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
            'email' => ['nullable', 'email', 'max:255', Rule::unique('users', 'email')->ignore($technician->user_id)],
            'phone' => ['nullable', 'string', 'max:50', Rule::unique('users', 'phone')->ignore($technician->user_id)],
            'password' => ['nullable', 'string', 'min:8', 'max:255'],
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

        if ($technician->user_id) {
            $user = $technician->user;
            if (! empty($validated['email'])) {
                $user->email = strtolower(trim($validated['email']));
            }
            if (! empty($validated['phone'])) {
                $user->phone = trim($validated['phone']);
            }
            if (! empty($validated['password'])) {
                $user->password = Hash::make($validated['password']);
            }
            $user->save();
        } elseif (! empty($validated['email']) && ! empty($validated['password'])) {
            $technician->user_id = $this->createUserAccount(
                $validated['name'] ?? $technician->name,
                $validated['email'],
                $validated['phone'] ?? null,
                $validated['password']
            )->id;
        }

        $technician->save();
        $technician->loadMissing('user:id,email,phone');

        return new TechnicianResource($technician);
    }

    public function destroy(Technician $technician)
    {
        $technician->delete();

        return response()->noContent();
    }

    /**
     * Create the login account (role='technician') a technician uses to sign
     * into the mobile app and receive jobs assigned by admin/sales staff.
     */
    private function createUserAccount(string $name, string $email, ?string $phone, string $password): User
    {
        $nameParts = preg_split('/\s+/', trim($name), 2);

        return User::create([
            'first_name' => $nameParts[0] ?? $name,
            'last_name' => $nameParts[1] ?? '',
            'email' => strtolower(trim($email)),
            'phone' => $phone ? trim($phone) : null,
            'password' => $password,
            'role' => 'technician',
            'status' => 'active',
            'is_admin' => false,
        ]);
    }
}
