@php
    $metrics     = $report['metrics']     ?? [];
    $daily       = $report['daily']       ?? [];
    $topItems    = $report['top_items']   ?? [];
    $totalSales  = (float) ($metrics['total_sales']          ?? 0);
    $totalOrders = (int)   ($metrics['total_orders']         ?? 0);
    $avgOrder    = (float) ($metrics['average_order_value']  ?? 0);
    $paidOrders  = (int)   ($metrics['paid_orders']          ?? 0);
    $unpaidOrders= (int)   ($metrics['unpaid_orders']        ?? 0);
    $failedOrders= (int)   ($metrics['failed_orders']        ?? 0);
    $paidRate    = $totalOrders > 0 ? round(($paidOrders / $totalOrders) * 100, 1) : 0;
    $reportType  = 'Sales Report';
    $rangeLabel  = $rangeLabel ?? '';
@endphp
@extends('admin.reports.pdf._layout')

@section('body')

    {{-- ── KPI Row ── --}}
    <div class="section-title">Key Metrics</div>
    <table class="kpi-table">
        <tr>
            <td class="kpi-cell">
                <div class="kpi-label">Total Revenue</div>
                <div class="kpi-value kpi-green">${{ number_format($totalSales, 2) }}</div>
            </td>
            <td class="kpi-cell">
                <div class="kpi-label">Total Orders</div>
                <div class="kpi-value kpi-accent">{{ number_format($totalOrders) }}</div>
            </td>
            <td class="kpi-cell">
                <div class="kpi-label">Avg Order Value</div>
                <div class="kpi-value">${{ number_format($avgOrder, 2) }}</div>
            </td>
            <td class="kpi-cell">
                <div class="kpi-label">Payment Rate</div>
                <div class="kpi-value {{ $paidRate >= 70 ? 'kpi-green' : ($paidRate >= 40 ? 'kpi-amber' : 'kpi-red') }}">{{ $paidRate }}%</div>
            </td>
        </tr>
    </table>

    {{-- ── Payment breakdown + daily summary ── --}}
    <table class="two-col" style="margin-bottom:18px">
        <tr>
            {{-- Payment breakdown --}}
            <td>
                <div class="section-title">Payment Breakdown</div>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Status</th>
                            <th class="text-right">Orders</th>
                            <th class="text-right">Share</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td><span class="badge badge-green">Paid</span></td>
                            <td class="text-right font-bold">{{ $paidOrders }}</td>
                            <td class="text-right text-green">{{ $totalOrders > 0 ? round($paidOrders/$totalOrders*100,1) : 0 }}%</td>
                        </tr>
                        <tr>
                            <td><span class="badge badge-amber">Unpaid</span></td>
                            <td class="text-right font-bold">{{ $unpaidOrders }}</td>
                            <td class="text-right text-amber">{{ $totalOrders > 0 ? round($unpaidOrders/$totalOrders*100,1) : 0 }}%</td>
                        </tr>
                        <tr>
                            <td><span class="badge badge-red">Failed</span></td>
                            <td class="text-right font-bold">{{ $failedOrders }}</td>
                            <td class="text-right text-red">{{ $totalOrders > 0 ? round($failedOrders/$totalOrders*100,1) : 0 }}%</td>
                        </tr>
                    </tbody>
                    <tfoot>
                        <tr>
                            <td>Total</td>
                            <td class="text-right">{{ $totalOrders }}</td>
                            <td class="text-right">100%</td>
                        </tr>
                    </tfoot>
                </table>
            </td>

            {{-- Daily summary (top 10 days) --}}
            <td>
                <div class="section-title">Top Revenue Days</div>
                @php $topDays = collect($daily)->sortByDesc('total')->take(8)->values(); @endphp
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th class="text-right">Orders</th>
                            <th class="text-right">Revenue</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse ($topDays as $day)
                            <tr>
                                <td class="text-muted">{{ \Carbon\Carbon::parse($day['day'])->format('d M Y') }}</td>
                                <td class="text-right">{{ $day['count'] }}</td>
                                <td class="text-right text-green">${{ number_format($day['total'], 2) }}</td>
                            </tr>
                        @empty
                            <tr><td colspan="3" style="text-align:center;color:#94a3b8;padding:12px">No data</td></tr>
                        @endforelse
                    </tbody>
                </table>
            </td>
        </tr>
    </table>

    {{-- ── Top Products ── --}}
    <div class="section-title">Top Products by Revenue</div>
    <table class="data-table">
        <thead>
            <tr>
                <th style="width:30px">#</th>
                <th>Product Name</th>
                <th>Type</th>
                <th class="text-right">Qty Sold</th>
                <th class="text-right">Revenue</th>
                <th class="text-right">Revenue Share</th>
            </tr>
        </thead>
        <tbody>
            @forelse ($topItems as $i => $item)
                @php $share = $totalSales > 0 ? round($item['sales']/$totalSales*100,1) : 0; @endphp
                <tr>
                    <td class="text-center"><span class="rank">{{ $i + 1 }}</span></td>
                    <td class="font-bold">{{ $item['name'] ?? '—' }}</td>
                    <td><span class="badge badge-slate">{{ ucfirst($item['item_type'] ?? '—') }}</span></td>
                    <td class="text-right">{{ number_format($item['quantity'] ?? 0) }}</td>
                    <td class="text-right text-green">${{ number_format($item['sales'] ?? 0, 2) }}</td>
                    <td class="text-right text-muted">{{ $share }}%</td>
                </tr>
            @empty
                <tr><td colspan="6" style="text-align:center;color:#94a3b8;padding:14px">No sales data for this period.</td></tr>
            @endforelse
        </tbody>
        @if (count($topItems))
        <tfoot>
            <tr>
                <td colspan="3">Total (shown)</td>
                <td class="text-right">{{ number_format(collect($topItems)->sum('quantity')) }}</td>
                <td class="text-right">${{ number_format(collect($topItems)->sum('sales'), 2) }}</td>
                <td></td>
            </tr>
        </tfoot>
        @endif
    </table>

    {{-- ── Daily breakdown (all days) ── --}}
    @if (count($daily))
    <div class="section-title" style="margin-top:4px">Daily Breakdown</div>
    <table class="data-table">
        <thead>
            <tr>
                <th>Date</th>
                <th>Day</th>
                <th class="text-right">Orders</th>
                <th class="text-right">Revenue</th>
            </tr>
        </thead>
        <tbody>
            @foreach ($daily as $day)
                <tr>
                    <td class="text-muted">{{ \Carbon\Carbon::parse($day['day'])->format('d M Y') }}</td>
                    <td class="text-muted">{{ \Carbon\Carbon::parse($day['day'])->format('D') }}</td>
                    <td class="text-right">{{ $day['count'] }}</td>
                    <td class="text-right text-green">${{ number_format($day['total'], 2) }}</td>
                </tr>
            @endforeach
        </tbody>
        <tfoot>
            <tr>
                <td colspan="2">Total</td>
                <td class="text-right">{{ number_format(collect($daily)->sum('count')) }}</td>
                <td class="text-right">${{ number_format(collect($daily)->sum('total'), 2) }}</td>
            </tr>
        </tfoot>
    </table>
    @endif

@endsection
