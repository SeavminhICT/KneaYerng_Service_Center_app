<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Concerns\AuthorizesRepairRequests;
use App\Http\Controllers\Controller;
use App\Http\Resources\InvoiceResource;
use App\Models\Invoice;
use App\Models\RepairRequest;
use App\Services\RepairNotificationService;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class RepairInvoiceController extends Controller
{
    use AuthorizesRepairRequests;

    public function index(Request $request)
    {
        $query = Invoice::query()->with('repair')->orderByDesc('created_at');

        if ($request->filled('payment_status')) {
            $query->where('payment_status', strtolower($request->string('payment_status')));
        }

        $perPage = (int) $request->input('per_page', 10);
        $perPage = max(1, min(50, $perPage));

        return InvoiceResource::collection($query->paginate($perPage)->withQueryString());
    }

    public function store(Request $request, RepairRequest $repair)
    {
        $validated = $request->validate([
            'tax' => ['nullable', 'numeric', 'min:0'],
            'payment_status' => ['nullable', 'string'],
        ]);

        $repair->load(['partsUsages', 'diagnostic', 'quotation']);

        $partsTotal = $repair->partsUsages->sum(function ($usage) {
            return $usage->quantity * $usage->cost;
        });

        $laborCost = $repair->diagnostic?->labor_cost ?? 0;

        if ($partsTotal <= 0 && $repair->quotation) {
            $partsTotal = $repair->quotation->parts_cost;
        }

        if ($laborCost <= 0 && $repair->quotation) {
            $laborCost = $repair->quotation->labor_cost;
        }

        $subtotal = $partsTotal + $laborCost;
        $tax = $validated['tax'] ?? 0;
        $total = $subtotal + $tax;

        $invoice = Invoice::firstOrNew(['repair_id' => $repair->id]);
        if (! $invoice->exists) {
            $invoice->invoice_number = 'INV-'.Str::upper(Str::random(8));
            $invoice->payment_status = 'pending';
        }

        $invoice->subtotal = $subtotal;
        $invoice->tax = $tax;
        $invoice->total = $total;

        if (! empty($validated['payment_status'])) {
            $invoice->payment_status = strtolower($validated['payment_status']);
        }

        $invoice->save();

        RepairNotificationService::notify(
            $repair->customer_id,
            $repair->id,
            'Invoice generated',
            'Invoice '.$invoice->invoice_number.' ready for repair #'.$repair->id.'.',
            'invoice'
        );

        return new InvoiceResource($invoice->load('payments'));
    }

    public function show(Request $request, Invoice $invoice)
    {
        $repair = $invoice->repair;
        if ($repair) {
            if ($response = $this->ensureRepairAccess($request, $repair)) {
                return $response;
            }
        }

        return new InvoiceResource($invoice->load('payments'));
    }
}
