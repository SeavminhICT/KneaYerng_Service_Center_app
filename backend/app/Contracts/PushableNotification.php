<?php

namespace App\Contracts;

use App\Models\User;

/**
 * Anything that can be delivered as a Firebase push notification via
 * FirebasePushNotificationService. Implemented by OrderTrackingNotification
 * (also reused for admin broadcast campaigns and support chat) and by
 * RepairNotification.
 */
interface PushableNotification
{
    public function getPushTitle(): string;

    public function getPushBody(): string;

    public function getPushType(): ?string;

    /**
     * Domain-specific data fields merged into the FCM data payload
     * (e.g. order_id/deep_link, or repair_id/from_status/to_status).
     *
     * @return array<string, mixed>
     */
    public function getPushPayload(): array;

    public function getPushAndroidChannelId(): string;

    public function getPushBadgeCount(User $user): int;
}
