<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\OrderTrackingNotificationResource;
use App\Models\OrderTrackingNotification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class GuestNotificationController extends Controller
{
    public function index(Request $request)
    {
        $validated = $request->validate([
            'guest_device_id' => ['required', 'string', 'max:64'],
            'per_page' => ['nullable', 'integer'],
        ]);

        $perPage = max(1, min(50, (int) ($validated['per_page'] ?? 20)));

        $notifications = OrderTrackingNotification::query()
            ->whereNull('user_id')
            ->where('guest_device_id', $validated['guest_device_id'])
            ->orderByDesc('created_at')
            ->paginate($perPage)
            ->withQueryString();

        return OrderTrackingNotificationResource::collection($notifications);
    }

    public function markRead(Request $request, OrderTrackingNotification $notification): JsonResponse|OrderTrackingNotificationResource
    {
        $validated = $request->validate([
            'guest_device_id' => ['required', 'string', 'max:64'],
        ]);

        if ($notification->user_id !== null
            || $notification->guest_device_id !== $validated['guest_device_id']) {
            return response()->json(['message' => 'Forbidden.'], 403);
        }

        if (! $notification->read_at) {
            $notification->read_at = now();
            $notification->save();
        }

        return new OrderTrackingNotificationResource($notification);
    }
}
