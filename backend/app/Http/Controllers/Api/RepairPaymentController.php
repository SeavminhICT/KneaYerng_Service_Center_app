<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Concerns\AuthorizesRepairRequests;
use App\Http\Controllers\Controller;
use App\Http\Resources\RepairPaymentResource;
use App\Models\Invoice;
use App\Models\RepairPayment;
use App\Services\RepairNotificationService;
use Illuminate\Http\Request;

class RepairPaymentController extends Controller
{
    use AuthorizesRepairRequests;

    public function index(Request $request)
    {
        $query = RepairPayment::query()->with('invoice.repair')->orderByDesc('created_at');

        if ($request->filled('status')) {
            $query->where('status', strtolower($request->string('status')));
        }

        $perPage = (int) $request->input('per_page', 10);
        $perPage = max(1, min(50, $perPage));

        return RepairPaymentResource::collection($query->paginate($perPage)->withQueryString());
    }

    public function storeDeposit(Request $request)
    {
        return $this->storePayment($request, 'deposit');
    }

    public function storeFinal(Request $request)
    {
        return $this->storePayment($request, 'final');
    }

    public function paymentsForInvoice(Request $request, Invoice $invoice)
    {
        if ($invoice->repair) {
            if ($response = $this->ensureRepairAccess($request, $invoice->repair)) {
                return $response;
            }
        }

        return RepairPaymentResource::collection($invoice->payments()->orderByDesc('created_at')->get());
    }

    private function storePayment(Request $request, string $type)
    {
        $validated = $request->validate([
            'invoice_id' => ['required', 'exists:invoices,id'],
            'method' => ['required', 'in:qr,card,wallet'],
            'amount' => ['required', 'numeric', 'min:0.01'],
            'status' => ['nullable', 'in:pending,paid,failed'],
            'transaction_ref' => ['nullable', 'string', 'max:150'],
        ]);

        $invoice = Invoice::findOrFail($validated['invoice_id']);
        if ($invoice->repair) {
            if ($response = $this->ensureRepairAccess($request, $invoice->repair)) {
                return $response;
            }
        }

        $status = $validated['status'] ?? 'pending';

        $payment = RepairPayment::create([
            'invoice_id' => $invoice->id,
            'type' => $type,
            'method' => $validated['method'],
            'amount' => $validated['amount'],
            'status' => $status,
            'transaction_ref' => $validated['transaction_ref'] ?? null,
        ]);

        $paidAmount = $invoice->payments()->where('status', 'paid')->sum('amount');
        $hasFailed = $invoice->payments()->where('status', 'failed')->exists();

        if ($paidAmount >= $invoice->total && $invoice->total > 0) {
            $invoice->payment_status = 'paid';
        } elseif ($hasFailed) {
            $invoice->payment_status = 'failed';
        } else {
            $invoice->payment_status = 'pending';
        }

        $invoice->save();

        if ($invoice->repair) {
            RepairNotificationService::notifyAdmin(
                $invoice->repair->id,
                'Payment update',
                ucfirst($type).' payment '.$status.' for invoice '.$invoice->invoice_number.'.',
                'payment'
            );
        }

        return new RepairPaymentResource($payment);
    }
}
