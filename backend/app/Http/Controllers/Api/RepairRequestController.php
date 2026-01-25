<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Concerns\AuthorizesRepairRequests;
use App\Http\Controllers\Controller;
use App\Http\Resources\RepairRequestResource;
use App\Http\Resources\RepairStatusLogResource;
use App\Models\RepairRequest;
use App\Models\RepairStatusLog;
use App\Models\Technician;
use App\Services\RepairNotificationService;
use Illuminate\Http\Request;

class RepairRequestController extends Controller
{
    use AuthorizesRepairRequests;

    private const STATUSES = [
        'received',
        'diagnosing',
        'waiting_approval',
        'in_repair',
        'qc',
        'ready',
        'completed',
    ];

    private const SERVICE_TYPES = [
        'drop_off',
        'pickup',
        'on_site',
    ];

    public function index(Request $request)
    {
        $query = RepairRequest::query()
            ->with(['customer', 'technician'])
            ->orderByDesc('created_at')
            ->orderByDesc('id');

        if ($request->filled('q')) {
            $q = $request->string('q');
            $query->where(function ($builder) use ($q) {
                $builder->where('device_model', 'like', "%{$q}%")
                    ->orWhere('issue_type', 'like', "%{$q}%")
                    ->orWhere('id', $q)
                    ->orWhereHas('customer', function ($customerQuery) use ($q) {
                        $customerQuery->where('first_name', 'like', "%{$q}%")
                            ->orWhere('last_name', 'like', "%{$q}%")
                            ->orWhere('email', 'like', "%{$q}%")
                            ->orWhere('phone', 'like', "%{$q}%");
                    });
            });
        }

        if ($request->filled('status')) {
            $query->where('status', $this->normalizeStatus($request->string('status')));
        }

        if ($request->filled('service_type')) {
            $query->where('service_type', $this->normalizeServiceType($request->string('service_type')));
        }

        $perPage = (int) $request->input('per_page', 10);
        $perPage = max(1, min(50, $perPage));

        return RepairRequestResource::collection($query->paginate($perPage)->withQueryString());
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'customer_id' => ['nullable', 'exists:users,id'],
            'device_model' => ['required', 'string', 'max:255'],
            'issue_type' => ['required', 'string', 'max:255'],
            'service_type' => ['required', 'string'],
            'appointment_datetime' => ['nullable', 'date'],
        ]);

        $actor = $request->user() ?? $request->user('sanctum');

        $serviceType = $this->normalizeServiceType($validated['service_type']);
        if (! in_array($serviceType, self::SERVICE_TYPES, true)) {
            return response()->json(['message' => 'Invalid service type.'], 422);
        }

        $customerId = $actor?->isAdmin()
            ? ($validated['customer_id'] ?? $actor?->id)
            : $actor?->id;

        if (! $customerId) {
            return response()->json(['message' => 'Customer is required.'], 422);
        }

        $repair = RepairRequest::create([
            'customer_id' => $customerId,
            'device_model' => $validated['device_model'],
            'issue_type' => $validated['issue_type'],
            'service_type' => $serviceType,
            'appointment_datetime' => $validated['appointment_datetime'] ?? null,
            'status' => 'received',
        ]);

        $this->logStatus($repair, $actor, $repair->status);
        RepairNotificationService::notifyAdmin($repair->id, 'New repair request', 'Repair #'.$repair->id.' created.');

        return new RepairRequestResource($repair->load(['customer']));
    }

    public function my(Request $request)
    {
        $actor = $request->user() ?? $request->user('sanctum');
        if (! $actor) {
            return response()->json(['message' => 'Unauthorized.'], 401);
        }

        $repairs = RepairRequest::query()
            ->where('customer_id', $actor->id)
            ->orderByDesc('created_at')
            ->paginate(10)
            ->withQueryString();

        return RepairRequestResource::collection($repairs);
    }

    public function show(Request $request, RepairRequest $repair)
    {
        if ($response = $this->ensureRepairAccess($request, $repair)) {
            return $response;
        }

        $repair->load([
            'customer',
            'technician',
            'intake',
            'diagnostic',
            'quotation',
            'warranty',
            'invoice.payments',
            'statusLogs',
            'chatMessages',
        ]);

        return new RepairRequestResource($repair);
    }

    public function assignTechnician(Request $request, RepairRequest $repair)
    {
        $validated = $request->validate([
            'technician_id' => ['required', 'exists:technicians,id'],
        ]);

        $actor = $request->user() ?? $request->user('sanctum');
        $technician = Technician::findOrFail($validated['technician_id']);

        $this->applyTechnicianAssignment($repair, $technician);

        if ($repair->status === 'received') {
            $this->updateStatusValue($repair, $actor, 'diagnosing');
        }

        RepairNotificationService::notify(
            $repair->customer_id,
            $repair->id,
            'Technician assigned',
            'Technician '.$technician->name.' assigned to repair #'.$repair->id.'.',
            'assignment'
        );

        return new RepairRequestResource($repair->load(['technician', 'customer']));
    }

    public function autoAssign(Request $request, RepairRequest $repair)
    {
        $technician = $this->selectTechnician($repair);

        if (! $technician) {
            return response()->json(['message' => 'No technician available.'], 422);
        }

        $actor = $request->user() ?? $request->user('sanctum');
        $this->applyTechnicianAssignment($repair, $technician);

        if ($repair->status === 'received') {
            $this->updateStatusValue($repair, $actor, 'diagnosing');
        }

        RepairNotificationService::notify(
            $repair->customer_id,
            $repair->id,
            'Technician assigned',
            'Technician '.$technician->name.' auto-assigned to repair #'.$repair->id.'.',
            'assignment'
        );

        return new RepairRequestResource($repair->load(['technician', 'customer']));
    }

    public function updateStatus(Request $request, RepairRequest $repair)
    {
        $validated = $request->validate([
            'status' => ['required', 'string'],
        ]);

        $actor = $request->user() ?? $request->user('sanctum');
        $status = $this->normalizeStatus($validated['status']);

        if (! in_array($status, self::STATUSES, true)) {
            return response()->json(['message' => 'Invalid status.'], 422);
        }

        $this->updateStatusValue($repair, $actor, $status);

        RepairNotificationService::notify(
            $repair->customer_id,
            $repair->id,
            'Repair status updated',
            'Repair #'.$repair->id.' status changed to '.$status.'.',
            'status'
        );

        return new RepairRequestResource($repair->load(['customer', 'technician']));
    }

    public function statusTimeline(Request $request, RepairRequest $repair)
    {
        if ($response = $this->ensureRepairAccess($request, $repair)) {
            return $response;
        }

        $logs = $repair->statusLogs()->orderByDesc('logged_at')->get();

        return RepairStatusLogResource::collection($logs);
    }

    private function normalizeStatus(string $status): string
    {
        return str_replace([' ', '-'], '_', strtolower(trim($status)));
    }

    private function normalizeServiceType(string $serviceType): string
    {
        return str_replace([' ', '-'], '_', strtolower(trim($serviceType)));
    }

    private function logStatus(RepairRequest $repair, $actor, string $status): void
    {
        RepairStatusLog::create([
            'repair_id' => $repair->id,
            'status' => $status,
            'updated_by' => $actor?->id,
            'logged_at' => now(),
        ]);
    }

    private function updateStatusValue(RepairRequest $repair, $actor, string $status): void
    {
        if ($repair->status === $status) {
            return;
        }

        $repair->status = $status;
        $repair->save();
        $this->logStatus($repair, $actor, $status);
    }

    private function applyTechnicianAssignment(RepairRequest $repair, Technician $technician): void
    {
        if ((int) $repair->technician_id === (int) $technician->id) {
            return;
        }

        if ($repair->technician_id && (int) $repair->technician_id !== (int) $technician->id) {
            $previous = Technician::find($repair->technician_id);
            if ($previous) {
                $previous->active_jobs_count = max(0, $previous->active_jobs_count - 1);
                $previous->save();
            }
        }

        $repair->technician_id = $technician->id;
        $repair->save();

        $technician->active_jobs_count += 1;
        $technician->save();
    }

    private function selectTechnician(RepairRequest $repair): ?Technician
    {
        $issueType = $repair->issue_type;

        $candidate = Technician::query()
            ->where('availability_status', 'available')
            ->where(function ($query) use ($issueType) {
                $query->whereNull('skill_set')
                    ->orWhereJsonContains('skill_set', $issueType);
            })
            ->orderBy('active_jobs_count')
            ->first();

        if ($candidate) {
            return $candidate;
        }

        return Technician::query()
            ->where('availability_status', 'available')
            ->orderBy('active_jobs_count')
            ->first();
    }
}
