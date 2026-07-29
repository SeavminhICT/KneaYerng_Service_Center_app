@php
    $metrics      = $report['metrics']      ?? [];
    $daily        = $report['daily']        ?? [];
    $topItems     = $report['top_items']    ?? [];
    $topCustomers = $report['top_customers']?? [];
    $totalSales   = (float) ($metrics['total_sales']         ?? 0);
    $totalOrders  = (int)   ($metrics['total_orders']        ?? 0);
    $netRevenue   = (float) ($metrics['net_revenue']          ?? $totalSales);
    $discount     = (float) ($metrics['discount_amount']     ?? 0);
    $tax          = (float) ($metrics['tax_amount']          ?? 0);
    $shipping     = (float) ($metrics['shipping_amount']     ?? 0);
    $returned     = (int)   ($metrics['returned_orders']     ?? 0);
    $refund       = (float) ($metrics['refund_amount']       ?? 0);
    $avgOrder     = (float) ($metrics['average_order_value'] ?? 0);
    $profit       = (float) ($metrics['profit']              ?? 0);
    $reportType   = __('Sales Report');
    $rangeLabel   = $rangeLabel ?? '';
@endphp
@extends('admin.reports.pdf._layout')

@section('body')

    {{-- ── Sales Summary Table ── --}}
    <div class="section-title">{{ __('Sales Summary') }}</div>
    <table class="data-table" style="margin-bottom:20px">
        <thead>
            <tr>
                <th>{{ __('Metric Description') }}</th>
                <th class="text-right">{{ __('Amount / Count') }}</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td class="font-bold">{{ __('Total Orders') }}</td>
                <td class="text-right font-bold">{{ number_format($totalOrders) }}</td>
            </tr>
            <tr>
                <td>{{ __('Total Revenue') }}</td>
                <td class="text-right text-green font-bold">${{ number_format($totalSales, 2) }}</td>
            </tr>
            <tr>
                <td>{{ __('Net Revenue') }}</td>
                <td class="text-right font-bold text-accent">${{ number_format($netRevenue, 2) }}</td>
            </tr>
            <tr>
                <td>{{ __('Discount') }}</td>
                <td class="text-right text-amber">${{ number_format($discount, 2) }}</td>
            </tr>
            <tr>
                <td>{{ __('Tax') }}</td>
                <td class="text-right">${{ number_format($tax, 2) }}</td>
            </tr>
            <tr>
                <td>{{ __('Shipping Fee') }}</td>
                <td class="text-right">${{ number_format($shipping, 2) }}</td>
            </tr>
            <tr>
                <td>{{ __('Returned Orders') }}</td>
                <td class="text-right text-red">{{ number_format($returned) }}</td>
            </tr>
            <tr>
                <td>{{ __('Refund Amount') }}</td>
                <td class="text-right text-red">${{ number_format($refund, 2) }}</td>
            </tr>
            <tr>
                <td>{{ __('Average Order Value (AOV)') }}</td>
                <td class="text-right font-bold">${{ number_format($avgOrder, 2) }}</td>
            </tr>
            <tr style="background:#f0fdf4">
                <td class="font-bold text-green" style="font-size:11px">{{ __('Estimated Net Profit') }}</td>
                <td class="text-right font-bold text-green" style="font-size:11px">${{ number_format($profit, 2) }}</td>
            </tr>
        </tbody>
    </table>

    {{-- ── Product Performance Table ── --}}
    <div class="section-title">{{ __('Charts') }}</div>
    <div style="font-weight:bold;margin-bottom:6px">{{ __('Sales Trend') }}</div>
    @php
        $trendRows = array_slice($daily, -8);
        $trendMax = max(array_map(fn ($row) => (float) ($row['total'] ?? 0), $trendRows ?: [['total' => 0]])) ?: 1;
    @endphp
    <table class="chart-table">
        <tbody>
            @forelse ($trendRows as $row)
                @php
                    $trendValue = (float) ($row['total'] ?? 0);
                    $barWidth = max(2, (int) round(($trendValue / $trendMax) * 160));
                @endphp
                <tr>
                    <td style="width:80px">{{ \Illuminate\Support\Carbon::parse($row['day'])->format('d M') }}</td>
                    <td style="width:180px"><div class="bar-bg"><div class="bar-fill" style="width:{{ $barWidth }}px"></div></div></td>
                    <td class="text-right">${{ number_format($trendValue, 2) }}</td>
                </tr>
            @empty
                <tr><td>{{ __('No sales trend data available.') }}</td></tr>
            @endforelse
        </tbody>
    </table>

    <div class="section-title">{{ __('Product Performance') }}</div>
    <table class="data-table" style="margin-bottom:20px">
        <thead>
            <tr>
                <th style="width:25px">#</th>
                <th>{{ __('Product') }}</th>
                <th>{{ __('Type') }}</th>
                <th class="text-right">{{ __('Sold') }}</th>
                <th class="text-right">{{ __('Revenue') }}</th>
                <th class="text-right">{{ __('Est. Profit') }}</th>
            </tr>
        </thead>
        <tbody>
            @forelse ($topItems as $i => $item)
                @php
                    $itemSales = (float)($item['sales'] ?? 0);
                    $itemProfit = round($itemSales * 0.35, 2);
                @endphp
                <tr>
                    <td class="text-center"><span class="rank">{{ $i + 1 }}</span></td>
                    <td class="font-bold">{{ $item['name'] ?? '—' }}</td>
                    <td><span class="badge badge-slate">{{ ucfirst($item['item_type'] ?? 'product') }}</span></td>
                    <td class="text-right font-bold">{{ number_format($item['quantity'] ?? 0) }}</td>
                    <td class="text-right text-green font-bold">${{ number_format($itemSales, 2) }}</td>
                    <td class="text-right text-accent font-bold">${{ number_format($itemProfit, 2) }}</td>
                </tr>
            @empty
                <tr><td colspan="6" style="text-align:center;color:#94a3b8;padding:14px">{{ __('No product sales recorded in this period.') }}</td></tr>
            @endforelse
        </tbody>
    </table>

    {{-- ── Top Customers Table ── --}}
    @if (count($topCustomers))
    <div class="section-title">{{ __('Top Customers') }}</div>
    <table class="data-table">
        <thead>
            <tr>
                <th style="width:25px">#</th>
                <th>{{ __('Customer Name') }}</th>
                <th>{{ __('Email / Phone') }}</th>
                <th class="text-right">{{ __('Orders') }}</th>
                <th class="text-right">{{ __('Spending') }}</th>
            </tr>
        </thead>
        <tbody>
            @foreach ($topCustomers as $i => $c)
                <tr>
                    <td class="text-center"><span class="rank">{{ $i + 1 }}</span></td>
                    <td class="font-bold">{{ $c['name'] ?? 'Guest Customer' }}</td>
                    <td class="text-muted" style="font-size:8.5px">{{ $c['email'] ?? $c['phone'] ?? '—' }}</td>
                    <td class="text-right font-bold">{{ $c['orders_count'] ?? 0 }}</td>
                    <td class="text-right text-green font-bold">${{ number_format($c['total_spent'] ?? 0, 2) }}</td>
                </tr>
            @endforeach
        </tbody>
    </table>
    @endif

@endsection
