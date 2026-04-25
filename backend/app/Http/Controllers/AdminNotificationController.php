<?php

namespace App\Http\Controllers;

use App\Models\OrderTrackingNotification;
use App\Models\User;
use App\Services\FirebasePushNotificationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class AdminNotificationController extends Controller
{
    public function __construct(
        private readonly FirebasePushNotificationService $pushNotificationService
    ) {
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'title' => ['required', 'string', 'max:150'],
            'message' => ['nullable', 'string', 'max:4000'],
            'type' => ['required', 'string', Rule::in(['Announcement', 'Alert', 'Document', 'Order'])],
            'target_mode' => ['required', 'string', Rule::in(['all', 'specific'])],
            'target_user_id' => ['nullable', 'integer', 'exists:users,id'],
            'deep_link' => ['nullable', 'string', 'max:1000'],
            'image' => ['nullable', 'image', 'max:5120'],
        ]);

        if (($validated['target_mode'] ?? 'all') === 'specific' && empty($validated['target_user_id'])) {
            return response()->json([
                'message' => 'Please select a user to receive this notification.',
                'errors' => [
                    'target_user_id' => ['Please select a user to receive this notification.'],
                ],
            ], 422);
        }

        $users = $this->resolveRecipients($validated);
        if ($users->isEmpty()) {
            return response()->json(['message' => 'No users found for this notification.'], 422);
        }

        $imageUrl = null;
        if ($request->hasFile('image')) {
            $path = $request->file('image')->store('notifications', 'public');
            $imageUrl = url('/storage/'.$path);
        }

        $normalizedType = strtolower(trim($validated['type']));
        $deepLink = trim((string) ($validated['deep_link'] ?? ''));
        $message = trim((string) ($validated['message'] ?? ''));

        $summary = [
            'targeted_users' => 0,
            'saved_notifications' => 0,
            'device_tokens' => 0,
            'delivered' => 0,
            'failed' => 0,
            'removed_invalid_tokens' => 0,
        ];

        foreach ($users as $user) {
            $summary['targeted_users']++;

            $notification = OrderTrackingNotification::create([
                'user_id' => $user->id,
                'order_id' => $this->extractOrderId($deepLink),
                'type' => 'admin_'.str_replace(' ', '_', $normalizedType),
                'title' => trim($validated['title']),
                'body' => $message,
                'payload' => [
                    'source' => 'admin_dashboard',
                    'deep_link' => $deepLink !== '' ? $deepLink : null,
                    'image_url' => $imageUrl,
                    'display_type' => $normalizedType,
                ],
            ]);
            $summary['saved_notifications']++;

            $dispatch = $this->pushNotificationService->sendStoredNotification(
                $user,
                $notification
            );

            $summary['device_tokens'] += $dispatch['device_tokens'];
            $summary['delivered'] += $dispatch['delivered'];
            $summary['failed'] += $dispatch['failed'];
            $summary['removed_invalid_tokens'] += $dispatch['removed_invalid_tokens'];
        }

        $messageText = $summary['device_tokens'] > 0
            ? 'Notification sent to '.$summary['delivered'].' device(s).'
            : 'Notification saved, but no registered mobile devices were found for the selected user(s).';

        return response()->json([
            'message' => $messageText,
            'summary' => $summary,
        ]);
    }

    private function resolveRecipients(array $validated)
    {
        $query = User::query()
            ->where(function ($builder) {
                $builder
                    ->whereNull('is_admin')
                    ->orWhere('is_admin', false);
            })
            ->where(function ($builder) {
                $builder
                    ->whereNull('role')
                    ->orWhere('role', '!=', 'admin');
            });

        if (($validated['target_mode'] ?? 'all') === 'specific') {
            $query->whereKey($validated['target_user_id']);
        }

        return $query
            ->orderBy('first_name')
            ->orderBy('last_name')
            ->get();
    }

    private function extractOrderId(string $deepLink): ?int
    {
        if (! str_starts_with($deepLink, '/orders/')) {
            return null;
        }

        return filter_var(substr($deepLink, strlen('/orders/')), FILTER_VALIDATE_INT) ?: null;
    }
}
