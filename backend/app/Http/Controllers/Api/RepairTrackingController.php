<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Invoice;
use Illuminate\Http\Request;

class RepairTrackingController extends Controller
{
    /**
     * No-login repair tracking: Invoice ID + the last digits of the
     * customer's phone number. Deliberately returns a trimmed payload (no
     * email, no full phone, no internal ids beyond the invoice/repair) since
     * an Invoice ID alone must never be enough to pull a customer's full
     * profile.
     */
    public function track(Request $request)
    {
        $validated = $request->validate([
            'invoice_number' => ['required', 'string', 'max:100'],
            'phone_last_digits' => ['required', 'string', 'min:3', 'max:15'],
        ]);

        $invoice = Invoice::where('invoice_number', $validated['invoice_number'])
            ->with(['repair.customer', 'repair.technician', 'repair.problems', 'repair.deviceModel', 'repair.statusLogs'])
            ->first();

        $repair = $invoice?->repair;
        $customerPhone = $repair?->customer?->phone;

        if (! $invoice || ! $repair || ! $customerPhone || ! str_ends_with($customerPhone, $validated['phone_last_digits'])) {
            return response()->json(['message' => 'No matching repair job found.'], 404);
        }

        return response()->json([
            'data' => [
                'repair_id' => $repair->id,
                'invoice_number' => $invoice->invoice_number,
                'device_model' => $repair->device_model,
                'problems' => $repair->problems->pluck('name'),
                'status' => $repair->status,
                'status_label' => str_replace('_', ' ', $repair->status),
                'technician_name' => $repair->technician?->name,
                'estimated_total' => $invoice->total,
                'payment_status' => $invoice->payment_status,
                'expected_completion' => $repair->appointment_datetime?->toISOString(),
                'timeline' => $repair->statusLogs->map(fn ($log) => [
                    'status' => $log->status,
                    'note' => $log->note,
                    'logged_at' => $log->logged_at?->toISOString(),
                ]),
            ],
        ]);
    }
}
