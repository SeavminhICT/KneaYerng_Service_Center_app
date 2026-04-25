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
        ]);

        $device = MobileDeviceToken::query()->updateOrCreate(
            ['token' => $validated['token']],
            [
                'user_id' => $actor->id,
                'platform' => $validated['platform'] ?? null,
                'last_used_at' => now(),
            ]
        );

        return response()->json([
            'data' => [
                'id' => $device->id,
                'platform' => $device->platform,
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

    private function requireActor(Request $request): User
    {
        $actor = $request->user() ?? $request->user('sanctum');
        abort_unless($actor instanceof User, 401, 'Unauthorized.');

        return $actor;
    }
}
