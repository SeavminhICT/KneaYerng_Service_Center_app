<?php

namespace App\Services;

use App\Models\AdminNotificationCampaign;
use App\Models\MobileDeviceToken;
use App\Models\OrderTrackingNotification;
use App\Models\User;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Collection as SupportCollection;
use Illuminate\Support\Facades\Schema;

class AdminNotificationCampaignSender
{
    private ?bool $guestSchemaReady = null;

    private ?bool $campaignSchemaReady = null;

    public function __construct(
        private readonly FirebasePushNotificationService $pushNotificationService
    ) {
    }

    /**
     * The guest/campaign columns ship in a migration that may not have run
     * yet on a freshly deployed server. Degrade gracefully (skip guest
     * targeting and read stats) instead of throwing a 500 on every send.
     */
    private function guestSchemaReady(): bool
    {
        return $this->guestSchemaReady ??= Schema::hasColumn('mobile_device_tokens', 'guest_device_id');
    }

    private function campaignSchemaReady(): bool
    {
        return $this->campaignSchemaReady ??= Schema::hasColumn('order_tracking_notifications', 'campaign_id');
    }

    public function countRecipients(string $audience, array $customUserIds): int
    {
        $count = 0;

        if ($this->targetsRegisteredUsers($audience)) {
            $query = $this->buildBaseRecipientQuery();
            $this->applyAudienceFilter($query, $audience, $customUserIds);
            $count += $query->count();
        }

        if ($this->targetsGuestDevices($audience)) {
            $count += $this->buildGuestDeviceQuery()
                ->distinct()
                ->count('guest_device_id');
        }

        return $count;
    }

    /**
     * Deliver the campaign: store one notification per recipient (user or
     * guest device) and push it to every registered token. Recipients that
     * already have a stored row for this campaign are skipped, so retries
     * never duplicate notifications.
     *
     * @return array<string, int>
     */
    public function send(AdminNotificationCampaign $campaign): array
    {
        $summary = [
            'targeted_users' => 0,
            'guest_devices' => 0,
            'saved_notifications' => 0,
            'device_tokens' => 0,
            'delivered' => 0,
            'failed' => 0,
            'removed_invalid_tokens' => 0,
        ];

        $audience = (string) $campaign->audience;
        $customUserIds = array_map('intval', (array) ($campaign->custom_user_ids ?? []));
        $deepLink = trim((string) ($campaign->deep_link ?? ''));
        $imageUrl = $campaign->meta['image_url'] ?? null;
        $normalizedType = strtolower(trim((string) $campaign->type));

        $basePayload = [
            'source' => 'admin_dashboard',
            'deep_link' => $deepLink !== '' ? $deepLink : null,
            'image_url' => $imageUrl,
            'display_type' => (string) $campaign->type,
            'campaign_id' => $campaign->id,
            'audience' => $audience,
        ];
        $canTrackCampaign = $this->campaignSchemaReady();
        $notificationAttributes = [
            'order_id' => $this->extractOrderId($deepLink),
            'type' => 'admin_'.str_replace(' ', '_', $normalizedType),
            'title' => (string) $campaign->title,
            'body' => (string) ($campaign->message ?? ''),
            'payload' => $basePayload,
        ];
        if ($canTrackCampaign) {
            $notificationAttributes['campaign_id'] = $campaign->id;
        }

        if ($this->targetsRegisteredUsers($audience)) {
            $users = $this->resolveRecipients($audience, $customUserIds);
            $summary['targeted_users'] = $users->count();
            $alreadyNotified = [];
            if ($canTrackCampaign) {
                $alreadyNotified = OrderTrackingNotification::query()
                    ->where('campaign_id', $campaign->id)
                    ->whereNotNull('user_id')
                    ->pluck('user_id')
                    ->all();
            }
            $alreadyNotified = array_flip($alreadyNotified);

            foreach ($users as $user) {
                if (isset($alreadyNotified[$user->id])) {
                    continue;
                }

                $notification = OrderTrackingNotification::create(
                    $notificationAttributes + ['user_id' => $user->id]
                );
                $summary['saved_notifications']++;

                $dispatch = $this->pushNotificationService->sendStoredNotification($user, $notification);
                $summary['device_tokens'] += $dispatch['device_tokens'];
                $summary['delivered'] += $dispatch['delivered'];
                $summary['failed'] += $dispatch['failed'];
                $summary['removed_invalid_tokens'] += $dispatch['removed_invalid_tokens'];
            }
        }

        if ($this->targetsGuestDevices($audience)) {
            $guestTokens = $this->buildGuestDeviceQuery()
                ->get(['guest_device_id', 'token'])
                ->groupBy('guest_device_id');
            $summary['guest_devices'] = $guestTokens->count();
            $alreadyNotified = OrderTrackingNotification::query()
                ->where('campaign_id', $campaign->id)
                ->whereNotNull('guest_device_id')
                ->pluck('guest_device_id')
                ->all();
            $alreadyNotified = array_flip($alreadyNotified);

            foreach ($guestTokens as $guestDeviceId => $devices) {
                if (isset($alreadyNotified[$guestDeviceId])) {
                    continue;
                }

                $notification = OrderTrackingNotification::create(
                    $notificationAttributes + ['guest_device_id' => (string) $guestDeviceId]
                );
                $summary['saved_notifications']++;

                $badgeCount = OrderTrackingNotification::query()
                    ->whereNull('user_id')
                    ->where('guest_device_id', (string) $guestDeviceId)
                    ->whereNull('read_at')
                    ->count();
                $dispatch = $this->pushNotificationService->sendNotificationToTokens(
                    $devices->pluck('token'),
                    $notification,
                    $badgeCount
                );
                $summary['device_tokens'] += $dispatch['device_tokens'];
                $summary['delivered'] += $dispatch['delivered'];
                $summary['failed'] += $dispatch['failed'];
                $summary['removed_invalid_tokens'] += $dispatch['removed_invalid_tokens'];
            }
        }

        $campaign->summary = $summary;
        $campaign->status = 'sent';
        $campaign->save();

        return $summary;
    }

    public function resolveRecipients(string $audience, array $customUserIds): Collection
    {
        $query = $this->buildBaseRecipientQuery();
        $this->applyAudienceFilter($query, $audience, $customUserIds);

        return $query
            ->orderBy('first_name')
            ->orderBy('last_name')
            ->get();
    }

    public function buildBaseRecipientQuery(): Builder
    {
        return User::query()
            ->where(function (Builder $builder) {
                $builder
                    ->whereNull('is_admin')
                    ->orWhere('is_admin', false);
            })
            ->where(function (Builder $builder) {
                $builder
                    ->whereNull('role')
                    ->orWhere('role', '!=', 'admin');
            });
    }

    private function buildGuestDeviceQuery(): Builder
    {
        return MobileDeviceToken::query()
            ->whereNull('user_id')
            ->whereNotNull('guest_device_id')
            ->where('guest_device_id', '!=', '');
    }

    private function targetsRegisteredUsers(string $audience): bool
    {
        return $audience !== 'guests';
    }

    private function targetsGuestDevices(string $audience): bool
    {
        return in_array($audience, ['all', 'guests'], true) && $this->guestSchemaReady();
    }

    private function applyAudienceFilter(Builder $query, string $audience, array $customUserIds): void
    {
        switch ($audience) {
            case 'active':
                $query->whereHas('mobileDeviceTokens', function (Builder $builder) {
                    $builder->where('last_used_at', '>=', now()->subDays(30));
                });
                break;

            case 'new':
                $query->where('created_at', '>=', now()->subDays(14));
                break;

            case 'inactive':
                $query->whereDoesntHave('mobileDeviceTokens', function (Builder $builder) {
                    $builder->where('last_used_at', '>=', now()->subDays(30));
                });
                break;

            case 'premium':
                $query->where(function (Builder $builder) {
                    $builder
                        ->whereHas('orders', function (Builder $orderQuery) {
                            $orderQuery->where('total_amount', '>=', 300);
                        })
                        ->orWhereHas('orders', function (Builder $orderQuery) {
                            $orderQuery
                                ->selectRaw('user_id')
                                ->groupBy('user_id')
                                ->havingRaw('COUNT(*) >= 3');
                        });
                });
                break;

            case 'custom':
                $query->whereKey($customUserIds === [] ? [0] : $customUserIds);
                break;

            case 'all':
            case 'registered':
            default:
                break;
        }
    }

    public function extractOrderId(string $deepLink): ?int
    {
        if (! str_starts_with($deepLink, '/orders/')) {
            return null;
        }

        return filter_var(substr($deepLink, strlen('/orders/')), FILTER_VALIDATE_INT) ?: null;
    }

    /**
     * Stored/read counts per campaign for admin delivery statistics.
     *
     * @param  iterable<int>  $campaignIds
     * @return SupportCollection<int, object{stored: int, read: int}>
     */
    public function receiptCounts(iterable $campaignIds): SupportCollection
    {
        $ids = collect($campaignIds)->filter()->unique()->values();
        if ($ids->isEmpty() || ! $this->campaignSchemaReady()) {
            return collect();
        }

        return OrderTrackingNotification::query()
            ->selectRaw('campaign_id, COUNT(*) as stored, SUM(CASE WHEN read_at IS NOT NULL THEN 1 ELSE 0 END) as `read`')
            ->whereIn('campaign_id', $ids)
            ->groupBy('campaign_id')
            ->get()
            ->keyBy('campaign_id');
    }
}
