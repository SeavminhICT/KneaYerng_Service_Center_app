<?php

namespace App\Services;

use App\Models\RepairNotification;

class RepairNotificationService
{
    public static function notify(?int $userId, ?int $repairId, string $title, ?string $body = null, ?string $type = null): RepairNotification
    {
        return RepairNotification::create([
            'user_id' => $userId,
            'repair_id' => $repairId,
            'type' => $type,
            'title' => $title,
            'body' => $body,
        ]);
    }

    public static function notifyAdmin(?int $repairId, string $title, ?string $body = null, ?string $type = null): RepairNotification
    {
        return self::notify(null, $repairId, $title, $body, $type);
    }
}
