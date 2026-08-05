<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\TechnicianResource;
use App\Models\Technician;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class TechnicianController extends Controller
{
    public function index(Request $request)
    {
        $query = Technician::query()->orderBy('name');

        if ($request->filled('q')) {
            $query->where('name', 'like', '%'.$request->string('q').'%');
        }

        if ($request->filled('availability_status')) {
            $query->where('availability_status', strtolower($request->string('availability_status')));
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
            'phone' => ['nullable', 'string', 'max:50'],
        ]);

        $userId = ! empty($validated['phone'])
            ? $this->linkUserAccount($validated['phone'], $validated['name'])->id
            : null;

        $technician = Technician::create([
            'user_id' => $userId,
            'name' => $validated['name'],
            'skill_set' => $validated['skill_set'] ?? [],
            'active_jobs_count' => $validated['active_jobs_count'] ?? 0,
            'availability_status' => ! empty($validated['availability_status']) ? strtolower($validated['availability_status']) : 'available',
        ]);

        return new TechnicianResource($technician);
    }

    public function show(Technician $technician)
    {
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
            'phone' => ['nullable', 'string', 'max:50'],
        ]);

        if (! $technician->user_id && ! empty($validated['phone'])) {
            $technician->user_id = $this->linkUserAccount($validated['phone'], $validated['name'] ?? $technician->name)->id;
        }

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

        $technician->save();

        return new TechnicianResource($technician);
    }

    public function destroy(Technician $technician)
    {
        $technician->delete();

        return response()->noContent();
    }

    /**
     * Find-or-create the User account a technician logs in with (same OTP-phone
     * flow as customers, distinguished only by role='technician'), so the
     * mobile app can route them to the technician experience after login.
     */
    private function linkUserAccount(string $phone, string $name): User
    {
        $existing = User::where('phone', $phone)->first();
        if ($existing) {
            if ($existing->role !== 'technician') {
                $existing->role = 'technician';
                $existing->save();
            }

            return $existing;
        }

        $nameParts = preg_split('/\s+/', trim($name), 2);

        return User::create([
            'first_name' => $nameParts[0] ?? $name,
            'last_name' => $nameParts[1] ?? '',
            'phone' => $phone,
            'password' => Hash::make(Str::random(32)),
            'role' => 'technician',
            'status' => 'active',
            'is_admin' => false,
        ]);
    }
}
