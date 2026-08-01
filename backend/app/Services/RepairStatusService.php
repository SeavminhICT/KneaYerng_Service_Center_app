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
    public const STATUSES = [
        'received',
        'waiting_diagnosis',
        'diagnosing',
        'waiting_approval',
        'in_repair',
        'qc',
        'ready',
        'completed',
    ];

    public const ALLOWED_TRANSITIONS = [
        'received' => ['waiting_diagnosis'],
        'waiting_diagnosis' => ['diagnosing'],
        'diagnosing' => ['waiting_approval'],
        'waiting_approval' => ['in_repair', 'diagnosing'],
        'in_repair' => ['qc'],
        'qc' => ['ready', 'in_repair'],
        'ready' => ['completed'],
        'completed' => [],
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
    public static function transition(RepairRequest $repair, string $to, ?User $actor, bool $force = false): void
    {
        if ($repair->status === $to) {
            return;
        }

        if (! $force && ! self::canTransition($repair->status, $to)) {
            throw new InvalidRepairTransitionException($repair->status, $to, self::allowedNext($repair->status));
        }

        $repair->status = $to;
        $repair->save();

        RepairStatusLog::create([
            'repair_id' => $repair->id,
            'status' => $to,
            'updated_by' => $actor?->id,
            'logged_at' => now(),
        ]);
    }
}
