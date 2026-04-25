<?php

namespace App\Services;

use App\Models\Order;
use App\Models\OrderTrackingHistory;
use App\Models\OrderTrackingNotification;
use App\Models\User;
use Illuminate\Validation\ValidationException;

class OrderTrackingService
{
    public function __construct(
        private readonly FirebasePushNotificationService $pushNotificationService
    ) {
    }

    public const STATUS_CREATED = 'created';
    public const STATUS_PENDING_APPROVAL = 'pending_approval';
    public const STATUS_APPROVED = 'approved';
    public const STATUS_ASSIGNED = 'assigned';
    public const STATUS_IN_PROGRESS = 'in_progress';
    public const STATUS_ON_THE_WAY = 'on_the_way';
    public const STATUS_ARRIVED = 'arrived';
    public const STATUS_COMPLETED = 'completed';
    public const STATUS_CANCELLED = 'cancelled';
    public const STATUS_REJECTED = 'rejected';

    public static function deliveryStatuses(): array
    {
        return [
            self::STATUS_CREATED,
            self::STATUS_PENDING_APPROVAL,
            self::STATUS_APPROVED,
            self::STATUS_ASSIGNED,
            self::STATUS_IN_PROGRESS,
            self::STATUS_ON_THE_WAY,
            self::STATUS_ARRIVED,
            self::STATUS_COMPLETED,
            self::STATUS_CANCELLED,
            self::STATUS_REJECTED,
        ];
    }

    public static function timelineStatuses(): array
    {
        return [
            self::STATUS_CREATED,
            self::STATUS_PENDING_APPROVAL,
            self::STATUS_APPROVED,
            self::STATUS_ASSIGNED,
            self::STATUS_IN_PROGRESS,
            self::STATUS_ON_THE_WAY,
            self::STATUS_ARRIVED,
            self::STATUS_COMPLETED,
        ];
    }

    public static function labels(): array
    {
        return [
            self::STATUS_CREATED => 'Created',
            self::STATUS_PENDING_APPROVAL => 'Pending Approval',
            self::STATUS_APPROVED => 'Approved',
            self::STATUS_ASSIGNED => 'Assigned',
            self::STATUS_IN_PROGRESS => 'In Progress',
            self::STATUS_ON_THE_WAY => 'On the Way',
            self::STATUS_ARRIVED => 'Arrived',
            self::STATUS_COMPLETED => 'Completed',
            self::STATUS_CANCELLED => 'Cancelled',
            self::STATUS_REJECTED => 'Rejected',
        ];
    }

    public static function descriptions(): array
    {
        return [
            self::STATUS_CREATED => 'Request was created in the app.',
            self::STATUS_PENDING_APPROVAL => 'Waiting for admin approval.',
            self::STATUS_APPROVED => 'Admin approved the request.',
            self::STATUS_ASSIGNED => 'Task assigned to staff.',
            self::STATUS_IN_PROGRESS => 'Staff accepted and started the task.',
            self::STATUS_ON_THE_WAY => 'Staff is on the way.',
            self::STATUS_ARRIVED => 'Staff arrived at the destination.',
            self::STATUS_COMPLETED => 'Request completed successfully.',
            self::STATUS_CANCELLED => 'Request was cancelled.',
            self::STATUS_REJECTED => 'Request was rejected by admin.',
        ];
    }

    public function bootstrapDeliveryOrder(Order $order, ?User $actor = null): Order
    {
        if (! $this->isTrackedDelivery($order)) {
            return $order;
        }

        if ($order->trackingHistories()->exists()) {
            return $order;
        }

        $order->status = self::STATUS_CREATED;
        $order->current_status_at = now();
        $order->save();

        $this->recordHistory($order, null, self::STATUS_CREATED, $actor, [
            'note' => 'Customer created the request.',
        ]);

        return $this->transition($order, self::STATUS_PENDING_APPROVAL, $actor, [
            'override' => true,
            'note' => 'Request is waiting for admin approval.',
        ]);
    }

    public function transition(Order $order, string $toStatus, ?User $actor = null, array $options = []): Order
    {
        $toStatus = strtolower(trim($toStatus));
        $fromStatus = strtolower((string) $order->status);
        $override = (bool) ($options['override'] ?? false);
        $note = $options['note'] ?? null;
        $assignedStaff = $options['assigned_staff'] ?? null;

        if (! in_array($toStatus, self::deliveryStatuses(), true)) {
            throw ValidationException::withMessages([
                'status' => ['Unsupported delivery tracking status.'],
            ]);
        }

        if (! $override && ! $this->canTransition($fromStatus, $toStatus)) {
            throw ValidationException::withMessages([
                'status' => ['Invalid status transition.'],
            ]);
        }

        if ($toStatus === self::STATUS_ASSIGNED && ! ($assignedStaff instanceof User) && ! $order->assigned_staff_id) {
            throw ValidationException::withMessages([
                'assigned_staff_id' => ['Assign a staff member before moving to Assigned.'],
            ]);
        }

        if ($toStatus === self::STATUS_IN_PROGRESS && $order->assigned_staff_id && $actor && $actor->isStaff() && (int) $actor->id !== (int) $order->assigned_staff_id) {
            throw ValidationException::withMessages([
                'status' => ['Only the assigned staff member can start this task.'],
            ]);
        }

        if ($assignedStaff instanceof User) {
            $order->assigned_staff_id = $assignedStaff->id;
        }

        $now = now();
        if ($toStatus === self::STATUS_APPROVED) {
            $order->approved_by = $actor?->id;
            $order->approved_at = $now;
            $order->rejected_by = null;
            $order->rejected_at = null;
            $order->rejected_reason = null;
        }

        if ($toStatus === self::STATUS_REJECTED) {
            $order->rejected_by = $actor?->id;
            $order->rejected_at = $now;
            $order->rejected_reason = $note;
        }

        if ($toStatus === self::STATUS_CANCELLED) {
            $order->cancelled_by = $actor?->id;
            $order->cancelled_at = $now;
            $order->cancelled_reason = $note;
        }

        $order->status = $toStatus;
        $order->current_status_at = $now;
        $order->save();

        $this->recordHistory($order, $fromStatus ?: null, $toStatus, $actor, [
            'override' => $override,
            'note' => $note,
            'assigned_staff_id' => $order->assigned_staff_id,
        ]);

        $this->createNotifications($order, $fromStatus ?: null, $toStatus, $actor, $note);

        return $order;
    }

    public function assignStaff(Order $order, User $staff, ?User $actor = null, ?string $note = null, bool $override = false): Order
    {
        if (! $staff->isStaff()) {
            throw ValidationException::withMessages([
                'assigned_staff_id' => ['Selected user is not a staff account.'],
            ]);
        }

        $order->assigned_staff_id = $staff->id;
        $order->save();

        return $this->transition($order, self::STATUS_ASSIGNED, $actor, [
            'assigned_staff' => $staff,
            'note' => $note ?: 'Task assigned to '.$staff->name.'.',
            'override' => $override,
        ]);
    }

    public function canTransition(?string $fromStatus, string $toStatus): bool
    {
        $map = [
            self::STATUS_CREATED => [self::STATUS_PENDING_APPROVAL],
            self::STATUS_PENDING_APPROVAL => [self::STATUS_APPROVED, self::STATUS_REJECTED, self::STATUS_CANCELLED],
            self::STATUS_APPROVED => [self::STATUS_ASSIGNED, self::STATUS_CANCELLED],
            self::STATUS_ASSIGNED => [self::STATUS_IN_PROGRESS, self::STATUS_CANCELLED],
            self::STATUS_IN_PROGRESS => [self::STATUS_ON_THE_WAY, self::STATUS_CANCELLED],
            self::STATUS_ON_THE_WAY => [self::STATUS_ARRIVED, self::STATUS_CANCELLED],
            self::STATUS_ARRIVED => [self::STATUS_COMPLETED, self::STATUS_CANCELLED],
            self::STATUS_COMPLETED => [],
            self::STATUS_CANCELLED => [],
            self::STATUS_REJECTED => [],
        ];

        return in_array($toStatus, $map[$fromStatus] ?? [], true);
    }

    public function allowedTransitions(Order $order, ?User $actor = null): array
    {
        if (! $this->isTrackedDelivery($order)) {
            return [];
        }

        $current = strtolower((string) $order->status);
        $options = [];
        foreach (self::deliveryStatuses() as $status) {
            if ($this->canTransition($current, $status)) {
                $options[] = [
                    'value' => $status,
                    'label' => self::labels()[$status] ?? $status,
                ];
            }
        }

        if ($actor && $actor->isAdmin()) {
            foreach (self::deliveryStatuses() as $status) {
                if (! collect($options)->contains(fn ($item) => $item['value'] === $status)) {
                    $options[] = [
                        'value' => $status,
                        'label' => self::labels()[$status] ?? $status,
                        'override_only' => true,
                    ];
                }
            }
        }

        usort($options, function (array $a, array $b) {
            return array_search($a['value'], self::deliveryStatuses(), true) <=> array_search($b['value'], self::deliveryStatuses(), true);
        });

        return $options;
    }

    public function buildTimeline(Order $order): array
    {
        $historyByStatus = $order->trackingHistories->keyBy('to_status');
        $current = strtolower((string) $order->status);
        $currentIndex = array_search($current, self::timelineStatuses(), true);
        $currentIndex = $currentIndex === false ? 0 : $currentIndex;

        return array_map(function (string $status, int $index) use ($historyByStatus, $current, $currentIndex) {
            $history = $historyByStatus->get($status);
            $isCompleted = in_array($current, [self::STATUS_CANCELLED, self::STATUS_REJECTED], true)
                ? $history !== null
                : $index < $currentIndex;
            $isCurrent = $current === $status;

            return [
                'status' => $status,
                'label' => self::labels()[$status] ?? $status,
                'description' => self::descriptions()[$status] ?? null,
                'done' => $isCompleted || $isCurrent,
                'current' => $isCurrent,
                'upcoming' => ! $isCompleted && ! $isCurrent,
                'at' => $history?->created_at?->toISOString(),
            ];
        }, self::timelineStatuses(), array_keys(self::timelineStatuses()));
    }

    public function isTrackedDelivery(Order $order): bool
    {
        return strtolower((string) $order->order_type) === 'delivery';
    }

    private function recordHistory(Order $order, ?string $fromStatus, string $toStatus, ?User $actor, array $options = []): OrderTrackingHistory
    {
        return OrderTrackingHistory::create([
            'order_id' => $order->id,
            'from_status' => $fromStatus,
            'to_status' => $toStatus,
            'changed_by_user_id' => $actor?->id,
            'changed_by_role' => $this->resolveRole($actor),
            'assigned_staff_id' => $options['assigned_staff_id'] ?? null,
            'override_used' => (bool) ($options['override'] ?? false),
            'note' => $options['note'] ?? null,
            'meta' => $options['meta'] ?? null,
        ]);
    }

    private function createNotifications(Order $order, ?string $fromStatus, string $toStatus, ?User $actor, ?string $note): void
    {
        $label = self::labels()[$toStatus] ?? $toStatus;
        $title = 'Order '.$order->order_number.' updated';
        $body = 'Status changed to '.$label.'.';
        if ($note) {
            $body .= ' '.$note;
        }

        $userIds = collect([
            $order->user_id,
            $order->assigned_staff_id,
        ])
            ->filter()
            ->unique()
            ->values();

        foreach ($userIds as $userId) {
            $notification = OrderTrackingNotification::create([
                'user_id' => $userId,
                'order_id' => $order->id,
                'type' => 'order_status_changed',
                'title' => $title,
                'body' => $body,
                'payload' => [
                    'order_id' => $order->id,
                    'order_number' => $order->order_number,
                    'from_status' => $fromStatus,
                    'to_status' => $toStatus,
                    'changed_by_user_id' => $actor?->id,
                    'changed_by_name' => $actor?->name,
                    'changed_by_role' => $this->resolveRole($actor),
                ],
            ]);

            $recipient = (int) $order->user_id === (int) $userId
                ? $order->user
                : ((int) $order->assigned_staff_id === (int) $userId ? $order->assignedStaff : User::find($userId));

            if ($recipient instanceof User) {
                $this->pushNotificationService->sendOrderTrackingNotification($recipient, $notification);
            }
        }
    }

    private function resolveRole(?User $actor): ?string
    {
        if (! $actor) {
            return null;
        }

        if ($actor->isAdmin()) {
            return 'admin';
        }

        if ($actor->isStaff()) {
            return 'staff';
        }

        return 'user';
    }
}
