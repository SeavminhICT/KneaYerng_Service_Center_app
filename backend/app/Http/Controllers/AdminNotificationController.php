<?php

namespace App\Http\Controllers;

use App\Jobs\SendAdminNotificationCampaign;
use App\Models\AdminNotificationCampaign;
use App\Models\User;
use App\Services\AdminNotificationCampaignSender;
use Carbon\Carbon;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class AdminNotificationController extends Controller
{
    private const TYPE_OPTIONS = [
        'Announcement',
        'Promotion',
        'Alert',
        'Info',
        'Reminder',
        // Keep legacy values for existing dashboard compatibility.
        'Document',
        'Order',
    ];

    private const AUDIENCE_OPTIONS = [
        'all',
        'registered',
        'guests',
        'active',
        'new',
        'inactive',
        'premium',
        'custom',
    ];

    public function __construct(
        private readonly AdminNotificationCampaignSender $campaignSender
    ) {
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'title' => ['required', 'string', 'max:150'],
            'message' => ['nullable', 'string', 'max:4000'],
            'type' => ['required', 'string', Rule::in(self::TYPE_OPTIONS)],
            'audience' => ['nullable', 'string', Rule::in(self::AUDIENCE_OPTIONS)],
            'target_mode' => ['nullable', 'string', Rule::in(['all', 'specific', 'registered', 'guests'])],
            'target_user_id' => ['nullable', 'integer', 'exists:users,id'],
            'custom_user_ids' => ['nullable', 'array'],
            'custom_user_ids.*' => ['integer', 'exists:users,id'],
            'deep_link' => ['nullable', 'string', 'max:1000'],
            'image' => ['nullable', 'image', 'max:5120'],
            'action' => ['nullable', 'string', Rule::in(['send_now', 'schedule', 'save_draft', 'send', 'draft'])],
            'scheduled_for' => ['nullable', 'date'],
        ]);

        $action = $this->normalizeAction($validated['action'] ?? null);
        $audience = $this->normalizeAudience(
            $validated['audience'] ?? null,
            $validated['target_mode'] ?? null,
        );
        $customUserIds = $this->normalizeCustomUserIds(
            $validated['custom_user_ids'] ?? null,
            $validated['target_user_id'] ?? null,
            $audience,
        );

        if ($audience === 'custom' && empty($customUserIds)) {
            $legacySpecific = strtolower(
                trim((string) ($validated['target_mode'] ?? ''))
            ) === 'specific';
            $errorKey = $legacySpecific ? 'target_user_id' : 'custom_user_ids';
            return response()->json([
                'message' => 'Please choose at least one user for custom segment.',
                'errors' => [
                    $errorKey => ['Please choose at least one user for custom segment.'],
                ],
            ], 422);
        }

        $scheduledFor = null;
        if (! empty($validated['scheduled_for'])) {
            try {
                $scheduledFor = Carbon::parse((string) $validated['scheduled_for']);
            } catch (\Throwable) {
                return response()->json([
                    'message' => 'Invalid schedule date/time.',
                    'errors' => [
                        'scheduled_for' => ['Invalid schedule date/time.'],
                    ],
                ], 422);
            }
        }

        if ($action === 'schedule') {
            if (! $scheduledFor) {
                return response()->json([
                    'message' => 'Please choose a schedule time.',
                    'errors' => [
                        'scheduled_for' => ['Please choose a schedule time.'],
                    ],
                ], 422);
            }

            if ($scheduledFor->isPast()) {
                return response()->json([
                    'message' => 'Schedule time must be in the future.',
                    'errors' => [
                        'scheduled_for' => ['Schedule time must be in the future.'],
                    ],
                ], 422);
            }
        }

        $recipientCount = $this->campaignSender->countRecipients($audience, $customUserIds);
        if (in_array($action, ['send_now', 'schedule'], true) && $recipientCount === 0) {
            return response()->json([
                'message' => 'No recipients found for this audience.',
                'errors' => [
                    'audience' => ['No recipients found for this audience.'],
                ],
            ], 422);
        }

        $imageUrl = null;
        if ($request->hasFile('image')) {
            $path = $request->file('image')->store('notifications', 'public');
            $imageUrl = url('/storage/'.$path);
        }

        $actor = $request->user() ?? $request->user('sanctum');
        $deepLink = trim((string) ($validated['deep_link'] ?? ''));
        $message = trim((string) ($validated['message'] ?? ''));

        $status = match ($action) {
            'save_draft' => 'draft',
            'schedule' => 'scheduled',
            default => 'queued',
        };

        $campaign = AdminNotificationCampaign::create([
            'admin_user_id' => $actor?->id,
            'type' => (string) $validated['type'],
            'title' => trim((string) $validated['title']),
            'message' => $message,
            'audience' => $audience,
            'custom_user_ids' => $audience === 'custom' ? $customUserIds : null,
            'deep_link' => $deepLink !== '' ? $deepLink : null,
            'action' => $action,
            'status' => $status,
            'scheduled_for' => $scheduledFor,
            'summary' => [
                'targeted_recipients' => $recipientCount,
                'saved_notifications' => 0,
                'device_tokens' => 0,
                'delivered' => 0,
                'failed' => 0,
                'removed_invalid_tokens' => 0,
            ],
            'meta' => [
                'image_url' => $imageUrl,
            ],
        ]);

        if ($action === 'send_now') {
            SendAdminNotificationCampaign::dispatch($campaign->id);
            $messageText = 'Notification queued for delivery to '.$recipientCount.' recipient(s). Delivery stats will appear in Sent History.';
        } elseif ($action === 'schedule') {
            $messageText = 'Notification scheduled for '.$scheduledFor?->toDayDateTimeString().'.';
        } else {
            $messageText = 'Notification draft saved.';
        }

        $campaign = $campaign->fresh();

        return response()->json([
            'message' => $messageText,
            'summary' => $campaign->summary ?? [],
            'history_item' => $this->transformCampaign($campaign),
        ]);
    }

    public function history(Request $request): JsonResponse
    {
        $limit = (int) $request->input('limit', 30);
        $limit = max(5, min(100, $limit));

        $items = AdminNotificationCampaign::query()
            ->with('adminUser:id,first_name,last_name,email')
            ->latest('created_at')
            ->limit($limit)
            ->get();

        $receipts = $this->campaignSender->receiptCounts($items->pluck('id'));

        return response()->json([
            'data' => $items
                ->map(fn (AdminNotificationCampaign $campaign) => $this->transformCampaign($campaign, $receipts->get($campaign->id)))
                ->values(),
        ]);
    }

    public function recipients(Request $request): JsonResponse
    {
        $limit = (int) $request->input('limit', 30);
        $limit = max(5, min(100, $limit));
        $search = trim((string) $request->input('q', ''));

        $query = $this->campaignSender->buildBaseRecipientQuery()
            ->withCount('orders')
            ->withSum('orders', 'total_amount')
            ->with(['mobileDeviceTokens' => function ($builder) {
                $builder
                    ->select(['id', 'user_id', 'last_used_at'])
                    ->orderByDesc('last_used_at');
            }]);

        if ($search !== '') {
            $query->where(function (Builder $builder) use ($search) {
                $builder
                    ->where('first_name', 'like', '%'.$search.'%')
                    ->orWhere('last_name', 'like', '%'.$search.'%')
                    ->orWhere('email', 'like', '%'.$search.'%')
                    ->orWhere('phone', 'like', '%'.$search.'%');
            });
        }

        $users = $query
            ->orderBy('first_name')
            ->orderBy('last_name')
            ->limit($limit)
            ->get(['id', 'first_name', 'last_name', 'email', 'phone', 'created_at']);

        return response()->json([
            'data' => $users->map(function (User $user) {
                $ordersCount = (int) ($user->orders_count ?? 0);
                $ordersTotal = (float) ($user->orders_sum_total_amount ?? 0);
                $lastActiveAt = $user->mobileDeviceTokens->first()?->last_used_at;
                $isActive = $lastActiveAt !== null && $lastActiveAt->greaterThanOrEqualTo(now()->subDays(30));
                $isNew = $user->created_at !== null && $user->created_at->greaterThanOrEqualTo(now()->subDays(14));
                $isPremium = $ordersCount >= 3 || $ordersTotal >= 300;

                return [
                    'id' => $user->id,
                    'name' => trim($user->name ?: trim(($user->first_name ?? '').' '.($user->last_name ?? ''))),
                    'email' => $user->email,
                    'phone' => $user->phone,
                    'orders_count' => $ordersCount,
                    'orders_total' => $ordersTotal,
                    'last_active_at' => $lastActiveAt?->toISOString(),
                    'segments' => [
                        'active' => $isActive,
                        'new' => $isNew,
                        'inactive' => ! $isActive,
                        'premium' => $isPremium,
                    ],
                ];
            })->values(),
        ]);
    }

    private function normalizeAction(?string $raw): string
    {
        $value = strtolower(trim((string) $raw));

        return match ($value) {
            'schedule' => 'schedule',
            'save_draft', 'draft' => 'save_draft',
            default => 'send_now',
        };
    }

    private function normalizeAudience(?string $audience, ?string $targetMode): string
    {
        $normalized = strtolower(trim((string) $audience));
        if (in_array($normalized, self::AUDIENCE_OPTIONS, true)) {
            return $normalized;
        }

        $legacy = strtolower(trim((string) $targetMode));

        return match ($legacy) {
            'specific' => 'custom',
            'guests' => 'guests',
            'registered' => 'registered',
            default => 'all',
        };
    }

    /**
     * @return array<int>
     */
    private function normalizeCustomUserIds(mixed $rawCustom, mixed $legacyTargetUserId, string $audience): array
    {
        $ids = [];

        if (is_array($rawCustom)) {
            foreach ($rawCustom as $value) {
                $parsed = filter_var($value, FILTER_VALIDATE_INT);
                if ($parsed !== false && $parsed > 0) {
                    $ids[] = (int) $parsed;
                }
            }
        }

        if ($audience === 'custom' && empty($ids)) {
            $legacyParsed = filter_var($legacyTargetUserId, FILTER_VALIDATE_INT);
            if ($legacyParsed !== false && $legacyParsed > 0) {
                $ids[] = (int) $legacyParsed;
            }
        }

        return array_values(array_unique($ids));
    }

    private function transformCampaign(AdminNotificationCampaign $campaign, ?object $receipts = null): array
    {
        $summary = $campaign->summary ?? [];
        if ($receipts !== null) {
            $summary['stored_notifications'] = (int) $receipts->stored;
            $summary['read'] = (int) $receipts->read;
        }

        return [
            'id' => $campaign->id,
            'type' => $campaign->type,
            'title' => $campaign->title,
            'message' => $campaign->message,
            'audience' => $campaign->audience,
            'custom_user_ids' => $campaign->custom_user_ids ?? [],
            'deep_link' => $campaign->deep_link,
            'action' => $campaign->action,
            'status' => $campaign->status,
            'scheduled_for' => $campaign->scheduled_for?->toISOString(),
            'summary' => $summary,
            'created_at' => $campaign->created_at?->toISOString(),
            'created_by' => [
                'id' => $campaign->adminUser?->id,
                'name' => trim((string) ($campaign->adminUser?->name ?? '')),
                'email' => $campaign->adminUser?->email,
            ],
        ];
    }
}
