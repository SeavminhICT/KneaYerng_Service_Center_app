<?php

namespace App\Http\Controllers\Api;

use App\Exceptions\InvalidRepairTransitionException;
use App\Http\Controllers\Controller;
use App\Http\Resources\RepairRequestResource;
use App\Models\Part;
use App\Models\RepairRequest;
use App\Models\Technician;
use App\Services\RepairNotificationService;
use App\Services\RepairStatusService;
use Illuminate\Http\Request;

class TechnicianRepairController extends Controller
{
    private const TECHNICIAN_ALLOWED_STATUSES = [
        RepairStatusService::STATUS_DIAGNOSING,
        RepairStatusService::STATUS_WAITING_CUSTOMER_APPROVAL,
        RepairStatusService::STATUS_WAITING_PARTS,
        RepairStatusService::STATUS_IN_PROGRESS,
        RepairStatusService::STATUS_TESTING,
        RepairStatusService::STATUS_REPAIR_COMPLETED,
        RepairStatusService::STATUS_READY_FOR_PICKUP,
        RepairStatusService::STATUS_CANNOT_REPAIR,
    ];

    public function assigned(Request $request)
    {
        $actor = $request->user() ?? $request->user('sanctum');
        $technician = $this->requireTechnician($actor);
        if ($technician instanceof \Illuminate\Http\JsonResponse) {
            return $technician;
        }

        $repairs = RepairRequest::query()
            ->where('technician_id', $technician->id)
            ->with(['customer', 'technician', 'deviceModel', 'problems', 'quotation', 'invoice'])
            ->orderByDesc('created_at')
            ->paginate((int) $request->input('per_page', 20))
            ->withQueryString();

        return RepairRequestResource::collection($repairs);
    }

    public function accept(Request $request, RepairRequest $repair)
    {
        $actor = $request->user() ?? $request->user('sanctum');
        $fromStatus = $repair->status;

        try {
            RepairStatusService::transition($repair, RepairStatusService::STATUS_ACCEPTED, $actor);
        } catch (InvalidRepairTransitionException $e) {
            return response()->json(['message' => $e->getMessage(), 'allowed_next' => $e->allowedNext], 422);
        }

        RepairNotificationService::notifyAdmin(
            $repair->id,
            'Technician accepted job',
            'Repair #'.$repair->id.' was accepted by the assigned technician.',
            'assignment'
        );
        RepairNotificationService::notify(
            $repair->customer_id,
            $repair->id,
            'Repair accepted by technician',
            'Technician accepted repair #'.$repair->id.' and will begin diagnosis.',
            'status',
            ['from_status' => $fromStatus, 'to_status' => RepairStatusService::STATUS_ACCEPTED, 'deep_link' => '/repairs/'.$repair->id]
        );

        return new RepairRequestResource($repair->fresh(['customer', 'technician']));
    }

    public function reject(Request $request, RepairRequest $repair)
    {
        $validated = $request->validate([
            'reason' => ['required', 'string', 'max:1000'],
        ]);

        $actor = $request->user() ?? $request->user('sanctum');
        $technician = Technician::where('user_id', $actor->id)->firstOrFail();
        $fromStatus = $repair->status;

        try {
            RepairStatusService::transition(
                $repair,
                RepairStatusService::STATUS_NEW,
                $actor,
                force: true,
                note: $validated['reason']
            );
        } catch (InvalidRepairTransitionException $e) {
            return response()->json(['message' => $e->getMessage(), 'allowed_next' => $e->allowedNext], 422);
        }

        $repair->technician_id = null;
        $repair->save();

        $technician->active_jobs_count = max(0, $technician->active_jobs_count - 1);
        $technician->save();

        RepairNotificationService::notifyAdmin(
            $repair->id,
            'Technician rejected job',
            'Repair #'.$repair->id.' was rejected: '.$validated['reason'],
            'assignment'
        );
        RepairNotificationService::notify(
            $repair->customer_id,
            $repair->id,
            'Repair assignment update',
            'Repair #'.$repair->id.' is waiting for reassignment.',
            'assignment',
            ['from_status' => $fromStatus, 'to_status' => RepairStatusService::STATUS_NEW, 'deep_link' => '/repairs/'.$repair->id]
        );

        return new RepairRequestResource($repair->fresh(['customer', 'technician']));
    }

    public function requestReassignment(Request $request, RepairRequest $repair)
    {
        $validated = $request->validate([
            'reason' => ['required', 'string', 'max:1000'],
        ]);

        RepairNotificationService::notifyAdmin(
            $repair->id,
            'Reassignment requested',
            'Technician requested reassignment for repair #'.$repair->id.': '.$validated['reason'],
            'assignment'
        );

        return response()->json(['message' => 'Reassignment request sent.']);
    }

    public function status(Request $request, RepairRequest $repair)
    {
        $validated = $request->validate([
            'status' => ['required', 'string', 'in:'.implode(',', self::TECHNICIAN_ALLOWED_STATUSES)],
            'note' => ['nullable', 'string', 'max:1000'],
        ]);

        $actor = $request->user() ?? $request->user('sanctum');
        $fromStatus = $repair->status;

        try {
            RepairStatusService::transition($repair, $validated['status'], $actor, note: $validated['note'] ?? null);
        } catch (InvalidRepairTransitionException $e) {
            return response()->json(['message' => $e->getMessage(), 'allowed_next' => $e->allowedNext], 422);
        }

        RepairNotificationService::notify(
            $repair->customer_id,
            $repair->id,
            'Repair status updated',
            'Repair #'.$repair->id.' status changed to '.$validated['status'].'.',
            'status',
            ['from_status' => $fromStatus, 'to_status' => $validated['status'], 'deep_link' => '/repairs/'.$repair->id]
        );

        return new RepairRequestResource($repair->fresh(['customer', 'technician']));
    }

    /**
     * Lightweight read-only parts list for the technician's parts-usage
     * picker — the full /parts CRUD endpoint is admin-permission gated and
     * technician accounts aren't RBAC-admin, so they need their own way to
     * browse what's in stock.
     */
    public function parts(Request $request)
    {
        $actor = $request->user() ?? $request->user('sanctum');
        $technician = $this->requireTechnician($actor);
        if ($technician instanceof \Illuminate\Http\JsonResponse) {
            return $technician;
        }

        $parts = Part::query()
            ->where('status', 'active')
            ->where('stock', '>', 0)
            ->orderBy('name')
            ->get(['id', 'name', 'sku', 'stock', 'unit_cost']);

        return response()->json(['data' => $parts]);
    }

    private function requireTechnician($actor)
    {
        if (! $actor) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        $technician = Technician::where('user_id', $actor->id)->first();

        if (! $technician) {
            return response()->json(['message' => 'Forbidden.'], 403);
        }

        return $technician;
    }
}
