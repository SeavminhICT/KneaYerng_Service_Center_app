@php
    $totalOrders    = $orders->count();
    $totalRevenue   = $orders->sum('total_amount');
    $paidOrders     = $orders->where('payment_status', 'paid')->count();
    $completedOrders= $orders->whereIn('status', ['completed', 'delivered'])->count();
@endphp
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<style>
    * { margin: 0; padding: 0; box-sizing: border-box; }

    body {
        font-family: DejaVu Sans, sans-serif;
        font-size: 9px;
        color: #1e293b;
        background: #ffffff;
    }

    /* ── Header ── */
    .header {
        background: #1e293b;
        padding: 16px 24px 14px;
        color: #fff;
    }
    .company-name {
        font-size: 16px;
        font-weight: bold;
        color: #f8fafc;
        letter-spacing: 0.5px;
    }
    .company-sub {
        font-size: 8px;
        color: #94a3b8;
        margin-top: 2px;
        letter-spacing: 1px;
        text-transform: uppercase;
    }
    .report-badge {
        background: #4f46e5;
        color: #fff;
        padding: 4px 12px;
        border-radius: 20px;
        font-size: 8px;
        font-weight: bold;
        letter-spacing: 1px;
        text-transform: uppercase;
    }
    .header-divider {
        height: 1px;
        background: rgba(255,255,255,0.12);
        margin: 10px 0 8px;
    }
    .header-meta {
        font-size: 8px;
        color: #94a3b8;
    }
    .header-meta span {
        color: #e2e8f0;
        font-weight: bold;
    }

    /* ── Content ── */
    .content { padding: 16px 24px; }

    /* ── KPI cards (table-based for dompdf) ── */
    .kpi-table { width: 100%; border-collapse: separate; border-spacing: 6px; margin-bottom: 16px; }
    .kpi-cell {
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        border-radius: 6px;
        padding: 10px 12px;
        width: 25%;
        vertical-align: top;
    }
    .kpi-label { font-size: 7px; color: #64748b; text-transform: uppercase; letter-spacing: 0.8px; font-weight: bold; }
    .kpi-value { font-size: 16px; font-weight: bold; color: #0f172a; margin-top: 4px; }
    .kpi-accent { color: #4f46e5; }
    .kpi-green  { color: #16a34a; }
    .kpi-amber  { color: #d97706; }

    /* ── Section title ── */
    .section-title {
        font-size: 9px;
        font-weight: bold;
        color: #0f172a;
        text-transform: uppercase;
        letter-spacing: 1px;
        margin-bottom: 8px;
        padding-bottom: 4px;
        border-bottom: 2px solid #4f46e5;
    }

    /* ── Data table ── */
    .data-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 8px;
    }
    .data-table thead tr { background: #1e293b; color: #fff; }
    .data-table thead th {
        padding: 7px 7px;
        text-align: left;
        font-size: 7px;
        text-transform: uppercase;
        letter-spacing: 0.7px;
        font-weight: bold;
    }
    .data-table thead th.right { text-align: right; }
    .data-table thead th.center { text-align: center; }

    .data-table tbody tr:nth-child(even) { background: #f8fafc; }
    .data-table tbody tr:nth-child(odd)  { background: #ffffff; }
    .data-table tbody td {
        padding: 5px 7px;
        border-bottom: 1px solid #e2e8f0;
        vertical-align: middle;
    }
    .data-table tbody td.right  { text-align: right; }
    .data-table tbody td.center { text-align: center; }
    .data-table tbody td.mono   { font-size: 7.5px; color: #334155; }

    .data-table tfoot td {
        padding: 6px 7px;
        font-weight: bold;
        font-size: 9px;
        background: #f1f5f9;
        border-top: 2px solid #cbd5e1;
    }
    .data-table tfoot td.right { text-align: right; color: #16a34a; }

    /* ── Badges ── */
    .badge {
        display: inline-block;
        padding: 2px 6px;
        border-radius: 8px;
        font-size: 7px;
        font-weight: bold;
    }
    .badge-green  { background: #dcfce7; color: #166534; }
    .badge-amber  { background: #fef9c3; color: #854d0e; }
    .badge-red    { background: #fee2e2; color: #991b1b; }
    .badge-blue   { background: #dbeafe; color: #1e40af; }
    .badge-purple { background: #ede9fe; color: #5b21b6; }
    .badge-slate  { background: #f1f5f9; color: #334155; }

    /* ── Footer ── */
    .footer {
        background: #f8fafc;
        border-top: 1px solid #e2e8f0;
        padding: 8px 24px;
        font-size: 7px;
        color: #94a3b8;
        position: fixed;
        bottom: 0;
        left: 0;
        right: 0;
    }
</style>
</head>
<body>

{{-- ── Header ── --}}
<div class="header">
    <table style="width:100%;border-collapse:collapse">
        <tr>
            <td>
                <div class="company-name">KneaYerng Service Center</div>
                <div class="company-sub">Mobile App Sales Platform · Phnom Penh, Cambodia</div>
            </td>
            <td style="text-align:right;vertical-align:top">
                <span class="report-badge">{{ __('Orders Export') }}</span>
            </td>
        </tr>
    </table>
    <div class="header-divider"></div>
    <div class="header-meta">
        <table style="width:100%;border-collapse:collapse">
            <tr>
                <td>{{ __('Records') }}: <span>{{ number_format($totalOrders) }}</span></td>
                <td style="text-align:center">{{ __('Total Revenue') }}: <span>${{ number_format($totalRevenue, 2) }}</span></td>
                <td style="text-align:right">{{ __('Generated') }}: <span>{{ $generatedAt }}</span></td>
            </tr>
        </table>
    </div>
</div>

{{-- ── Content ── --}}
<div class="content">

    {{-- KPI Summary --}}
    <table class="kpi-table">
        <tr>
            <td class="kpi-cell">
                <div class="kpi-label">{{ __('Total Orders') }}</div>
                <div class="kpi-value kpi-accent">{{ number_format($totalOrders) }}</div>
            </td>
            <td class="kpi-cell">
                <div class="kpi-label">{{ __('Total Revenue') }}</div>
                <div class="kpi-value kpi-green">${{ number_format($totalRevenue, 2) }}</div>
            </td>
            <td class="kpi-cell">
                <div class="kpi-label">{{ __('Paid Orders') }}</div>
                <div class="kpi-value kpi-green">{{ number_format($paidOrders) }}
                    @if($totalOrders > 0)
                        <span style="font-size:10px;color:#64748b;font-weight:normal">({{ round($paidOrders / $totalOrders * 100, 1) }}%)</span>
                    @endif
                </div>
            </td>
            <td class="kpi-cell">
                <div class="kpi-label">{{ __('Completed') }}</div>
                <div class="kpi-value">{{ number_format($completedOrders) }}</div>
            </td>
        </tr>
    </table>

    {{-- Orders Table --}}
    <div class="section-title">{{ __('Order List') }}</div>
    <table class="data-table">
        <thead>
            <tr>
                <th style="width:22px">#</th>
                <th style="width:90px">{{ __('Order #') }}</th>
                <th style="width:85px">{{ __('Customer') }}</th>
                <th style="width:48px" class="center">{{ __('Type') }}</th>
                <th style="width:60px">{{ __('Payment') }}</th>
                <th style="width:58px" class="right">{{ __('Subtotal') }}</th>
                <th style="width:50px" class="right">{{ __('Del. Fee') }}</th>
                <th style="width:55px" class="right">{{ __('Discount') }}</th>
                <th style="width:62px" class="right">{{ __('Total') }}</th>
                <th style="width:62px" class="center">{{ __('Pay Status') }}</th>
                <th style="width:72px" class="center">{{ __('Order Status') }}</th>
                <th style="width:90px">{{ __('Date') }}</th>
            </tr>
        </thead>
        <tbody>
            @forelse($orders as $i => $order)
                @php
                    $timestamp  = $order->placed_at ?? $order->created_at;
                    $payStatus  = strtolower((string) ($order->payment_status ?? ''));
                    $payBadge   = match ($payStatus) {
                        'paid'              => 'badge-green',
                        'unpaid', 'pending' => 'badge-amber',
                        'refunded'          => 'badge-purple',
                        default             => 'badge-slate',
                    };
                    $orderStatus = strtolower((string) ($order->status ?? ''));
                    $stBadge = match (true) {
                        in_array($orderStatus, ['completed', 'delivered'])                                        => 'badge-green',
                        in_array($orderStatus, ['cancelled', 'rejected'])                                         => 'badge-red',
                        in_array($orderStatus, ['in_progress', 'on_the_way', 'assigned', 'processing', 'approved']) => 'badge-blue',
                        in_array($orderStatus, ['pending_approval', 'created', 'pending'])                        => 'badge-amber',
                        default                                                                                   => 'badge-slate',
                    };
                @endphp
                <tr>
                    <td>{{ $i + 1 }}</td>
                    <td class="mono">{{ $order->order_number }}</td>
                    <td>{{ $order->customer_name }}</td>
                    <td class="center"><span class="badge badge-slate">{{ ucfirst($order->order_type ?? '') }}</span></td>
                    <td>{{ ucfirst(str_replace('_', ' ', $order->payment_method ?? '')) }}</td>
                    <td class="right">${{ number_format($order->subtotal ?? 0, 2) }}</td>
                    <td class="right">${{ number_format($order->delivery_fee ?? 0, 2) }}</td>
                    <td class="right">${{ number_format($order->discount_amount ?? 0, 2) }}</td>
                    <td class="right" style="font-weight:bold">${{ number_format($order->total_amount ?? 0, 2) }}</td>
                    <td class="center"><span class="badge {{ $payBadge }}">{{ ucfirst($payStatus) }}</span></td>
                    <td class="center"><span class="badge {{ $stBadge }}">{{ ucwords(str_replace('_', ' ', $orderStatus)) }}</span></td>
                    <td class="mono">{{ $timestamp ? $timestamp->format('d M Y H:i') : '—' }}</td>
                </tr>
            @empty
                <tr>
                    <td colspan="12" style="text-align:center;color:#94a3b8;padding:20px">
                        {{ __('No orders found for the selected filters.') }}
                    </td>
                </tr>
            @endforelse
        </tbody>
        @if($totalOrders > 0)
        <tfoot>
            <tr>
                <td colspan="5">{{ __('Total') }} ({{ number_format($totalOrders) }} {{ __('orders') }})</td>
                <td class="right">${{ number_format($orders->sum('subtotal'), 2) }}</td>
                <td class="right">${{ number_format($orders->sum('delivery_fee'), 2) }}</td>
                <td class="right">${{ number_format($orders->sum('discount_amount'), 2) }}</td>
                <td class="right">${{ number_format($totalRevenue, 2) }}</td>
                <td colspan="3"></td>
            </tr>
        </tfoot>
        @endif
    </table>

</div>

{{-- ── Footer ── --}}
<div class="footer">
    <table style="width:100%;border-collapse:collapse">
        <tr>
            <td>KneaYerng Service Center — {{ __('Confidential Export') }}</td>
            <td style="text-align:center">{{ __('Generated via Admin Portal') }}</td>
            <td style="text-align:right">{{ $generatedAt }}</td>
        </tr>
    </table>
</div>

</body>
</html>
