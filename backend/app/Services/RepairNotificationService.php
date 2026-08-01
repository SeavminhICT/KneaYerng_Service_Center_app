<?php

namespace App\Services;

use App\Models\RepairNotification;
use App\Models\User;

class RepairNotificationService
{
    public static function notify(?int $userId, ?int $repairId, string $title, ?string $body = null, ?string $type = null, array $payload = []): RepairNotification
    {
        $notification = RepairNotification::create([
            'user_id' => $userId,
            'repair_id' => $repairId,
            'type' => $type,
            'title' => $title,
            'body' => $body,
            'payload' => $payload,
        ]);

        if ($userId) {
            $user = User::find($userId);
            if ($user) {
                app(FirebasePushNotificationService::class)->sendStoredNotification($user, $notification);
            }
        }

        return $notification;
    }

    public static function notifyAdmin(?int $repairId, string $title, ?string $body = null, ?string $type = null, array $payload = []): RepairNotification
    {
        return self::notify(null, $repairId, $title, $body, $type, $payload);
    }
}
