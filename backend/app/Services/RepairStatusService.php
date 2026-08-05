<?php

namespace App\Services;

use App\Exceptions\InvalidRepairTransitionException;
use App\Models\RepairRequest;
use App\Models\RepairStatusLog;
use App\Models\User;

/**
 * Single source of truth for the repair workflow: which statuses exist, and
 * which transitions between them are valid. Every place that changes a
 * repair's status should go through transition() so the audit log
 * (repair_status_logs) and the guard stay consistent.
 */
class RepairStatusService
{
    public const STATUS_NEW = 'new';

    public const STATUS_ASSIGNED = 'assigned';

    public const STATUS_ACCEPTED = 'accepted';

    public const STATUS_DIAGNOSING = 'diagnosing';

    public const STATUS_WAITING_CUSTOMER_APPROVAL = 'waiting_customer_approval';

    public const STATUS_APPROVED = 'approved';

    public const STATUS_IN_PROGRESS = 'in_progress';

    public const STATUS_WAITING_PARTS = 'waiting_parts';

    public const STATUS_TESTING = 'testing';

    public const STATUS_REPAIR_COMPLETED = 'repair_completed';

    public const STATUS_READY_FOR_PICKUP = 'ready_for_pickup';

    public const STATUS_DELIVERED = 'delivered';

    public const STATUS_CANNOT_REPAIR = 'cannot_repair';

    public const STATUS_CANCELLED = 'cancelled';

    public const STATUSES = [
        self::STATUS_NEW,
        self::STATUS_ASSIGNED,
        self::STATUS_ACCEPTED,
        self::STATUS_DIAGNOSING,
        self::STATUS_WAITING_CUSTOMER_APPROVAL,
        self::STATUS_APPROVED,
        self::STATUS_IN_PROGRESS,
        self::STATUS_WAITING_PARTS,
        self::STATUS_TESTING,
        self::STATUS_REPAIR_COMPLETED,
        self::STATUS_READY_FOR_PICKUP,
        self::STATUS_DELIVERED,
        self::STATUS_CANNOT_REPAIR,
        self::STATUS_CANCELLED,
    ];

    public const ALLOWED_TRANSITIONS = [
        self::STATUS_NEW => [self::STATUS_ASSIGNED, self::STATUS_CANCELLED],
        self::STATUS_ASSIGNED => [self::STATUS_ACCEPTED, self::STATUS_NEW, self::STATUS_CANCELLED],
        self::STATUS_ACCEPTED => [self::STATUS_DIAGNOSING, self::STATUS_CANCELLED],
        self::STATUS_DIAGNOSING => [
            self::STATUS_WAITING_CUSTOMER_APPROVAL,
            self::STATUS_WAITING_PARTS,
            self::STATUS_CANNOT_REPAIR,
            self::STATUS_CANCELLED,
        ],
        self::STATUS_WAITING_CUSTOMER_APPROVAL => [
            self::STATUS_APPROVED,
            self::STATUS_DIAGNOSING,
            self::STATUS_CANCELLED,
        ],
        self::STATUS_APPROVED => [self::STATUS_IN_PROGRESS, self::STATUS_CANCELLED],
        self::STATUS_IN_PROGRESS => [
            self::STATUS_WAITING_PARTS,
            self::STATUS_TESTING,
            self::STATUS_CANNOT_REPAIR,
        ],
        self::STATUS_WAITING_PARTS => [self::STATUS_IN_PROGRESS, self::STATUS_CANNOT_REPAIR],
        self::STATUS_TESTING => [self::STATUS_REPAIR_COMPLETED, self::STATUS_IN_PROGRESS],
        self::STATUS_REPAIR_COMPLETED => [self::STATUS_READY_FOR_PICKUP],
        self::STATUS_READY_FOR_PICKUP => [self::STATUS_DELIVERED],
        self::STATUS_DELIVERED => [],
        self::STATUS_CANNOT_REPAIR => [self::STATUS_CANCELLED, self::STATUS_DELIVERED],
        self::STATUS_CANCELLED => [],
    ];

    public static function canTransition(string $from, string $to): bool
    {
        return $from === $to || in_array($to, self::allowedNext($from), true);
    }

    /**
     * @return string[]
     */
    public static function allowedNext(string $from): array
    {
        return self::ALLOWED_TRANSITIONS[$from] ?? [];
    }

    /**
     * @throws InvalidRepairTransitionException when the transition isn't allowed and $force is false
     */
    public static function transition(
        RepairRequest $repair,
        string $to,
        ?User $actor,
        bool $force = false,
        ?string $note = null,
        array $meta = []
    ): void {
        if ($repair->status === $to) {
            return;
        }

        if (! $force && ! self::canTransition($repair->status, $to)) {
            throw new InvalidRepairTransitionException($repair->status, $to, self::allowedNext($repair->status));
        }

        $fromStatus = $repair->status;
        $repair->status = $to;
        $repair->save();

        RepairStatusLog::create([
            'repair_id' => $repair->id,
            'from_status' => $fromStatus,
            'status' => $to,
            'note' => $note,
            'meta' => $meta === [] ? null : $meta,
            'updated_by' => $actor?->id,
            'logged_at' => now(),
        ]);
    }
}
