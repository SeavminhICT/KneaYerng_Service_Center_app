<?php

namespace App\Services;

use App\Models\MobileDeviceToken;
use App\Models\OrderTrackingNotification;
use App\Models\User;
use Kreait\Firebase\Contract\Messaging;
use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\AndroidConfig;
use Kreait\Firebase\Messaging\ApnsConfig;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;
use Throwable;

class FirebasePushNotificationService
{
    private ?Messaging $messaging = null;

    public function __construct()
    {
        $credentials = (string) config('services.firebase.credentials', '');
        $projectId = (string) config('services.firebase.project_id', '');

        if (trim($credentials) === '') {
            return;
        }

        $factory = (new Factory())
            ->withServiceAccount($this->resolveCredentialsPath($credentials));

        if (trim($projectId) !== '') {
            $factory = $factory->withProjectId($projectId);
        }

        $this->messaging = $factory->createMessaging();
    }

    public function sendOrderTrackingNotification(User $user, OrderTrackingNotification $notification): void
    {
        $this->sendStoredNotification($user, $notification);
    }

    public function sendStoredNotification(User $user, OrderTrackingNotification $notification): array
    {
        if (! $this->messaging) {
            return [
                'device_tokens' => 0,
                'delivered' => 0,
                'failed' => 0,
                'removed_invalid_tokens' => 0,
            ];
        }

        $tokens = $user->mobileDeviceTokens()
            ->pluck('token')
            ->filter()
            ->unique()
            ->values();

        if ($tokens->isEmpty()) {
            return [
                'device_tokens' => 0,
                'delivered' => 0,
                'failed' => 0,
                'removed_invalid_tokens' => 0,
            ];
        }

        $payload = is_array($notification->payload) ? $notification->payload : [];
        $badgeCount = max(1, OrderTrackingNotification::query()
            ->where('user_id', $user->id)
            ->whereNull('read_at')
            ->count());
        $data = $this->normalizeData([
            'title' => $notification->title,
            'body' => $notification->body ?? 'Your order tracking status was updated.',
            'type' => $notification->type,
            'notification_id' => $notification->id,
            'badge' => $badgeCount,
            'order_id' => $notification->order_id,
            'order_number' => $payload['order_number'] ?? null,
            'from_status' => $payload['from_status'] ?? null,
            'to_status' => $payload['to_status'] ?? null,
            'deep_link' => $payload['deep_link'] ?? ($notification->order_id ? '/orders/'.$notification->order_id : null),
            'image_url' => $payload['image_url'] ?? null,
        ]);
        $androidConfig = AndroidConfig::fromArray([
            'priority' => 'high',
            'notification' => [
                'channel_id' => 'order_tracking_updates',
                'sound' => 'default',
                'default_sound' => true,
                'default_vibrate_timings' => true,
                'visibility' => 'PUBLIC',
                'notification_priority' => 'PRIORITY_MAX',
                'notification_count' => $badgeCount,
            ],
        ]);
        $apnsPayload = [
            'aps' => [
                'sound' => 'default',
                'badge' => $badgeCount,
                'content-available' => 1,
                'mutable-content' => 1,
                'interruption-level' => 'active',
            ],
        ];
        $apnsConfigData = [
            'headers' => [
                'apns-priority' => '10',
                'apns-push-type' => 'alert',
            ],
            'payload' => $apnsPayload,
        ];
        if (! empty($payload['image_url'])) {
            $apnsConfigData['fcm_options'] = [
                'image' => $payload['image_url'],
            ];
        }
        $apnsConfig = ApnsConfig::fromArray($apnsConfigData);

        $summary = [
            'device_tokens' => $tokens->count(),
            'delivered' => 0,
            'failed' => 0,
            'removed_invalid_tokens' => 0,
        ];

        foreach ($tokens as $token) {
            try {
                $message = CloudMessage::withTarget('token', $token)
                    ->withNotification(Notification::create(
                        $notification->title,
                        $notification->body ?? 'Your order tracking status was updated.'
                    ))
                    ->withAndroidConfig($androidConfig)
                    ->withApnsConfig($apnsConfig)
                    ->withData($data);

                $this->messaging->send($message);
                $summary['delivered']++;
            } catch (Throwable $exception) {
                $summary['failed']++;
                if ($this->shouldForgetToken($exception)) {
                    MobileDeviceToken::query()->where('token', $token)->delete();
                    $summary['removed_invalid_tokens']++;
                }
            }
        }

        return $summary;
    }

    private function normalizeData(array $data): array
    {
        $normalized = [];
        foreach ($data as $key => $value) {
            if ($value === null || $value === '') {
                continue;
            }

            if (is_bool($value)) {
                $normalized[$key] = $value ? 'true' : 'false';
                continue;
            }

            if (is_scalar($value)) {
                $normalized[$key] = (string) $value;
                continue;
            }

            $encoded = json_encode($value);
            if ($encoded !== false) {
                $normalized[$key] = $encoded;
            }
        }

        return $normalized;
    }

    private function shouldForgetToken(Throwable $exception): bool
    {
        $message = strtolower($exception->getMessage());

        return str_contains($message, 'requested entity was not found')
            || str_contains($message, 'registration token is not a valid')
            || str_contains($message, 'not a valid fcm registration token');
    }

    private function resolveCredentialsPath(string $credentials): string
    {
        $trimmed = trim($credentials);
        if ($trimmed === '') {
            return $trimmed;
        }

        $isAbsoluteUnix = str_starts_with($trimmed, DIRECTORY_SEPARATOR);
        $isAbsoluteWindows = (bool) preg_match('/^[A-Za-z]:\\\\/', $trimmed);

        if ($isAbsoluteUnix || $isAbsoluteWindows) {
            return $trimmed;
        }

        return base_path($trimmed);
    }
}
