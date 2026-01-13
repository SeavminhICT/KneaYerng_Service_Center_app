<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Concerns\AuthorizesRepairRequests;
use App\Http\Controllers\Controller;
use App\Http\Resources\QuotationResource;
use App\Models\Quotation;
use App\Models\RepairRequest;
use App\Models\RepairStatusLog;
use App\Services\RepairNotificationService;
use Illuminate\Http\Request;

class RepairQuotationController extends Controller
{
    use AuthorizesRepairRequests;

    private const QUOTE_STATUSES = ['pending', 'approved', 'rejected'];

    public function store(Request $request, RepairRequest $repair)
    {
        $validated = $request->validate([
            'parts_cost' => ['nullable', 'numeric', 'min:0'],
            'labor_cost' => ['nullable', 'numeric', 'min:0'],
            'status' => ['nullable', 'string'],
        ]);

        $status = $this->normalizeQuoteStatus($validated['status'] ?? 'pending');
        if (! in_array($status, self::QUOTE_STATUSES, true)) {
            return response()->json(['message' => 'Invalid quotation status.'], 422);
        }

        $partsCost = $validated['parts_cost'] ?? 0;
        $laborCost = $validated['labor_cost'] ?? 0;
        $totalCost = $partsCost + $laborCost;

        $quotation = Quotation::updateOrCreate(
            ['repair_id' => $repair->id],
            [
                'parts_cost' => $partsCost,
                'labor_cost' => $laborCost,
                'total_cost' => $totalCost,
                'status' => $status,
                'customer_approved_at' => $status === 'approved' ? now() : null,
            ]
        );

        if ($status === 'pending') {
            $this->setRepairStatus($repair, $request->user(), 'waiting_approval');
            RepairNotificationService::notify(
                $repair->customer_id,
                $repair->id,
                'Quotation ready',
                'Quotation ready for repair #'.$repair->id.'.',
                'quotation'
            );
        }

        if ($status === 'approved') {
            $this->setRepairStatus($repair, $request->user(), 'in_repair');
            RepairNotificationService::notifyAdmin(
                $repair->id,
                'Quotation approved',
                'Quotation approved for repair #'.$repair->id.'.',
                'quotation'
            );
        }

        if ($status === 'rejected') {
            $this->setRepairStatus($repair, $request->user(), 'diagnosing');
            RepairNotificationService::notifyAdmin(
                $repair->id,
                'Quotation rejected',
                'Quotation rejected for repair #'.$repair->id.'.',
                'quotation'
            );
        }

        return new QuotationResource($quotation);
    }

    public function show(Request $request, RepairRequest $repair)
    {
        if ($response = $this->ensureRepairAccess($request, $repair)) {
            return $response;
        }

        $quotation = $repair->quotation;
        if (! $quotation) {
            return response()->json(['message' => 'Quotation not found.'], 404);
        }

        return new QuotationResource($quotation);
    }

    public function approve(Request $request, Quotation $quotation)
    {
        $repair = $quotation->repair;

        if ($response = $this->ensureRepairAccess($request, $repair)) {
            return $response;
        }

        $quotation->status = 'approved';
        $quotation->customer_approved_at = now();
        $quotation->save();

        $this->setRepairStatus($repair, $request->user(), 'in_repair');

        RepairNotificationService::notifyAdmin(
            $repair->id,
            'Quotation approved',
            'Customer approved quotation for repair #'.$repair->id.'.',
            'quotation'
        );

        return new QuotationResource($quotation);
    }

    public function reject(Request $request, Quotation $quotation)
    {
        $repair = $quotation->repair;

        if ($response = $this->ensureRepairAccess($request, $repair)) {
            return $response;
        }

        $quotation->status = 'rejected';
        $quotation->customer_approved_at = null;
        $quotation->save();

        $this->setRepairStatus($repair, $request->user(), 'diagnosing');

        RepairNotificationService::notifyAdmin(
            $repair->id,
            'Quotation rejected',
            'Customer rejected quotation for repair #'.$repair->id.'.',
            'quotation'
        );

        return new QuotationResource($quotation);
    }

    private function normalizeQuoteStatus(string $status): string
    {
        return str_replace([' ', '-'], '_', strtolower(trim($status)));
    }

    private function setRepairStatus(RepairRequest $repair, $actor, string $status): void
    {
        if ($repair->status === $status) {
            return;
        }

        $repair->status = $status;
        $repair->save();

        RepairStatusLog::create([
            'repair_id' => $repair->id,
            'status' => $status,
            'updated_by' => $actor?->id,
            'logged_at' => now(),
        ]);
    }
}
