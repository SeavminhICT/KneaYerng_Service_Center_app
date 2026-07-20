<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MobileDeviceToken;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MobileDeviceController extends Controller
{
    public function store(Request $request): JsonResponse
    {
        $actor = $this->requireActor($request);

        $validated = $request->validate([
            'token' => ['required', 'string', 'max:512'],
            'platform' => ['nullable', 'string', 'in:android,ios,web'],
            'guest_device_id' => ['nullable', 'string', 'max:64'],
            'device_name' => ['nullable', 'string', 'max:120'],
            'app_version' => ['nullable', 'string', 'max:32'],
        ]);

        $device = MobileDeviceToken::query()->updateOrCreate(
            ['token' => $validated['token']],
            array_filter([
                'user_id' => $actor->id,
                'platform' => $validated['platform'] ?? null,
                'guest_device_id' => $validated['guest_device_id'] ?? null,
                'device_name' => $validated['device_name'] ?? null,
                'app_version' => $validated['app_version'] ?? null,
                'last_used_at' => now(),
            ], fn ($value) => $value !== null)
        );

        return response()->json([
            'data' => [
                'id' => $device->id,
                'platform' => $device->platform,
                'last_used_at' => $device->last_used_at?->toISOString(),
            ],
        ]);
    }

    public function storeGuest(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'token' => ['required', 'string', 'max:512'],
            'guest_device_id' => ['required', 'string', 'max:64'],
            'platform' => ['nullable', 'string', 'in:android,ios,web'],
            'device_name' => ['nullable', 'string', 'max:120'],
            'app_version' => ['nullable', 'string', 'max:32'],
        ]);

        $existing = MobileDeviceToken::query()
            ->where('token', $validated['token'])
            ->first();

        $attributes = [
            'guest_device_id' => $validated['guest_device_id'],
            'platform' => $validated['platform'] ?? $existing?->platform,
            'device_name' => $validated['device_name'] ?? $existing?->device_name,
            'app_version' => $validated['app_version'] ?? $existing?->app_version,
            'last_used_at' => now(),
        ];

        if ($existing) {
            // Never downgrade a token already linked to a signed-in user.
            $existing->fill($attributes);
            $existing->save();
            $device = $existing;
        } else {
            $device = MobileDeviceToken::create($attributes + [
                'user_id' => null,
                'token' => $validated['token'],
            ]);
        }

        return response()->json([
            'data' => [
                'id' => $device->id,
                'platform' => $device->platform,
                'guest_device_id' => $device->guest_device_id,
                'last_used_at' => $device->last_used_at?->toISOString(),
            ],
        ]);
    }

    public function destroy(Request $request): JsonResponse
    {
        $actor = $this->requireActor($request);

        $validated = $request->validate([
            'token' => ['required', 'string', 'max:512'],
        ]);

        MobileDeviceToken::query()
            ->where('user_id', $actor->id)
            ->where('token', $validated['token'])
            ->delete();

        return response()->json(['message' => 'Device token removed.']);
    }

    public function destroyGuest(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'token' => ['required', 'string', 'max:512'],
            'guest_device_id' => ['required', 'string', 'max:64'],
        ]);

        MobileDeviceToken::query()
            ->whereNull('user_id')
            ->where('guest_device_id', $validated['guest_device_id'])
            ->where('token', $validated['token'])
            ->delete();

        return response()->json(['message' => 'Device token removed.']);
    }

    private function requireActor(Request $request): User
    {
        $actor = $request->user() ?? $request->user('sanctum');
        abort_unless($actor instanceof User, 401, 'Unauthorized.');

        return $actor;
    }
}
