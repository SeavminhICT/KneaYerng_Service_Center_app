@php
    $invoice = $repair->invoice;
    $customer = $repair->customer;
    $quotation = $repair->quotation;
    $diagnostic = $repair->diagnostic;

    $quoteParts = (float) ($quotation?->parts_cost ?? 0);
    $quoteLabor = (float) ($quotation?->labor_cost ?? $diagnostic?->labor_cost ?? 0);

    $lineItems = collect();

    if ($quoteParts > 0 || $quoteLabor > 0) {
        if ($quoteParts > 0) {
            $lineItems->push([
                'qty' => 1,
                'description' => 'Repair parts',
                'unit_price' => $quoteParts,
                'amount' => $quoteParts,
            ]);
        }

        if ($quoteLabor > 0) {
            $lineItems->push([
                'qty' => 1,
                'description' => 'Labor service',
                'unit_price' => $quoteLabor,
                'amount' => $quoteLabor,
            ]);
        }
    } else {
        foreach ($repair->problems as $problem) {
            $fee = (float) ($problem->service_fee ?? 0);
            $lineItems->push([
                'qty' => 1,
                'description' => $problem->name,
                'unit_price' => $fee,
                'amount' => $fee,
            ]);
        }
    }

    $subtotal = (float) ($invoice?->subtotal ?? $lineItems->sum('amount'));
    if ($lineItems->isEmpty() && $subtotal > 0) {
        $lineItems->push([
            'qty' => 1,
            'description' => 'Repair service',
            'unit_price' => $subtotal,
            'amount' => $subtotal,
        ]);
    }

    $tax = (float) ($invoice?->tax ?? 0);
    $total = (float) ($invoice?->total ?? ($subtotal + $tax));
    $invoiceDateSource = $invoice?->created_at ?? $repair->created_at ?? now();
    $invoiceNumber = $invoice?->invoice_number ?? 'INV-'.$repair->id;
    $customerName = $customer?->name ?: 'Walk-in Customer';
    $customerContact = collect([$customer?->phone, $customer?->email])->filter()->implode(' / ');
    $serviceType = \Illuminate\Support\Str::of($repair->service_type ?? 'drop_off')->replace('_', ' ')->title();
    $paymentStatus = \Illuminate\Support\Str::of($invoice?->payment_status ?? 'pending')->replace('_', ' ')->title();
@endphp

<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{{ __('Invoice') }} {{ $invoiceNumber }}</title>
    <style>
        :root {
            color: #111827;
            background: #f3f4f6;
            font-family: Arial, Helvetica, sans-serif;
        }

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            background: #f3f4f6;
            color: #111827;
        }

        .screen-actions {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            max-width: 920px;
            margin: 24px auto 0;
            padding: 0 16px;
        }

        .button {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-height: 40px;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            padding: 0 16px;
            background: #ffffff;
            color: #111827;
            font-size: 14px;
            font-weight: 700;
            text-decoration: none;
            cursor: pointer;
        }

        .button-primary {
            border-color: #2563eb;
            background: #2563eb;
            color: #ffffff;
        }

        .invoice-page {
            width: min(920px, calc(100vw - 32px));
            min-height: 1180px;
            margin: 18px auto 32px;
            padding: 64px;
            background: #ffffff;
            box-shadow: 0 16px 40px rgba(15, 23, 42, 0.12);
        }

        .header {
            display: flex;
            justify-content: space-between;
            gap: 40px;
        }

        .company-name {
            margin: 0 0 18px;
            font-size: 24px;
            font-weight: 800;
        }

        .company-details,
        .muted {
            color: #374151;
            font-size: 14px;
            line-height: 1.5;
        }

        .invoice-title {
            margin: 0;
            font-size: 28px;
            font-weight: 900;
            letter-spacing: 0;
            text-align: right;
        }

        .meta-grid {
            margin-top: 118px;
            display: grid;
            grid-template-columns: 1fr 1fr 260px;
            gap: 44px;
        }

        .section-title {
            margin: 0 0 8px;
            font-size: 14px;
            font-weight: 800;
        }

        .meta-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 14px;
        }

        .meta-table th {
            width: 44%;
            padding: 0 18px 10px 0;
            text-align: right;
            font-weight: 800;
            white-space: nowrap;
        }

        .meta-table td {
            padding: 0 0 10px;
            text-align: right;
        }

        .items {
            width: 100%;
            margin-top: 54px;
            border-collapse: collapse;
            font-size: 14px;
        }

        .items th,
        .items td {
            border: 1px solid #a3a3a3;
            padding: 11px 12px;
        }

        .items th {
            background: #f1f1f1;
            font-size: 13px;
            font-weight: 900;
            text-align: center;
        }

        .items td:nth-child(1),
        .items td:nth-child(3),
        .items td:nth-child(4) {
            text-align: right;
            white-space: nowrap;
        }

        .totals {
            display: flex;
            justify-content: flex-end;
            margin-top: 12px;
        }

        .totals table {
            width: 320px;
            border-collapse: collapse;
            font-size: 14px;
        }

        .totals th,
        .totals td {
            padding: 10px 12px;
            text-align: right;
        }

        .totals th {
            font-weight: 700;
        }

        .total-row th,
        .total-row td {
            border: 1px solid #a3a3a3;
            background: #f5f5f5;
            font-size: 20px;
            font-weight: 900;
        }

        .footer {
            margin-top: 180px;
            display: grid;
            grid-template-columns: 1fr 220px;
            gap: 48px;
            align-items: end;
        }

        .signature-line {
            border-top: 1px solid #111827;
            padding-top: 8px;
            text-align: center;
            font-size: 13px;
            font-weight: 700;
        }

        @media (max-width: 720px) {
            .invoice-page {
                width: 100%;
                min-height: 0;
                margin: 12px 0 0;
                padding: 28px 18px;
                box-shadow: none;
            }

            .header,
            .meta-grid,
            .footer {
                grid-template-columns: 1fr;
                display: grid;
                gap: 24px;
            }

            .meta-grid {
                margin-top: 48px;
            }

            .invoice-title,
            .meta-table th,
            .meta-table td {
                text-align: left;
            }

            .items {
                font-size: 12px;
            }
        }

        @media print {
            :root,
            body {
                background: #ffffff;
            }

            .screen-actions {
                display: none;
            }

            .invoice-page {
                width: auto;
                min-height: auto;
                margin: 0;
                padding: 24mm;
                box-shadow: none;
            }
        }
    </style>
</head>
<body>
    <div class="screen-actions">
        <a class="button" href="{{ route('admin.repairs.show', $repair) }}">{{ __('Back to Repair') }}</a>
        <button class="button button-primary" type="button" onclick="window.print()">{{ __('Print Invoice') }}</button>
    </div>

    <main class="invoice-page">
        <header class="header">
            <div>
                <h1 class="company-name">{{ config('app.name', 'Ky Servicer Center') }}</h1>
                <div class="company-details">
                    <div>Mobile Repair Service</div>
                    <div>Phnom Penh, Cambodia</div>
                    <div>Repair #{{ $repair->id }} - {{ $serviceType }}</div>
                </div>
            </div>
            <div>
                <h2 class="invoice-title">{{ __('INVOICE') }}</h2>
            </div>
        </header>

        <section class="meta-grid">
            <div>
                <h3 class="section-title">{{ __('Bill To') }}</h3>
                <div class="muted">
                    <div><strong>{{ $customerName }}</strong></div>
                    @if ($customerContact)
                        <div>{{ $customerContact }}</div>
                    @endif
                    <div>{{ $repair->device_model ?: __('Device not specified') }}</div>
                    <div>{{ $repair->issue_type ?: __('Repair service') }}</div>
                </div>
            </div>

            <div>
                <h3 class="section-title">{{ __('Service') }}</h3>
                <div class="muted">
                    <div>{{ __('Repair Ticket') }} #{{ $repair->id }}</div>
                    <div>{{ __('Status') }}: {{ \Illuminate\Support\Str::of($repair->status)->replace('_', ' ')->title() }}</div>
                    <div>{{ __('Payment') }}: {{ $paymentStatus }}</div>
                </div>
            </div>

            <div>
                <table class="meta-table">
                    <tr>
                        <th>{{ __('Invoice #') }}</th>
                        <td>{{ $invoiceNumber }}</td>
                    </tr>
                    <tr>
                        <th>{{ __('Invoice Date') }}</th>
                        <td>{{ $invoiceDateSource->format('d/m/Y') }}</td>
                    </tr>
                    <tr>
                        <th>{{ __('P.O.#') }}</th>
                        <td>REP-{{ str_pad((string) $repair->id, 4, '0', STR_PAD_LEFT) }}</td>
                    </tr>
                    <tr>
                        <th>{{ __('Due Date') }}</th>
                        <td>{{ $invoiceDateSource->copy()->addDays(15)->format('d/m/Y') }}</td>
                    </tr>
                </table>
            </div>
        </section>

        <table class="items">
            <thead>
                <tr>
                    <th style="width: 72px;">{{ __('QTY') }}</th>
                    <th>{{ __('DESCRIPTION') }}</th>
                    <th style="width: 150px;">{{ __('UNIT PRICE') }}</th>
                    <th style="width: 150px;">{{ __('AMOUNT') }}</th>
                </tr>
            </thead>
            <tbody>
                @forelse ($lineItems as $item)
                    <tr>
                        <td>{{ $item['qty'] }}</td>
                        <td>{{ $item['description'] }}</td>
                        <td>${{ number_format($item['unit_price'], 2) }}</td>
                        <td>${{ number_format($item['amount'], 2) }}</td>
                    </tr>
                @empty
                    <tr>
                        <td>1</td>
                        <td>{{ __('Repair service') }}</td>
                        <td>$0.00</td>
                        <td>$0.00</td>
                    </tr>
                @endforelse
            </tbody>
        </table>

        <section class="totals">
            <table>
                <tr>
                    <th>{{ __('Subtotal') }}</th>
                    <td>${{ number_format($subtotal, 2) }}</td>
                </tr>
                <tr>
                    <th>{{ __('Tax') }}</th>
                    <td>${{ number_format($tax, 2) }}</td>
                </tr>
                <tr class="total-row">
                    <th>{{ __('TOTAL') }}</th>
                    <td>${{ number_format($total, 2) }}</td>
                </tr>
            </table>
        </section>

        <footer class="footer">
            <div class="muted">
                <h3 class="section-title">{{ __('Terms & Conditions') }}</h3>
                <div>{{ __('Payment is due within 15 days.') }}</div>
                <div>{{ __('Please keep this invoice for repair pickup and warranty reference.') }}</div>
            </div>
            <div class="signature-line">{{ __('Authorized Signature') }}</div>
        </footer>
    </main>
</body>
</html>
