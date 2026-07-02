@php
    $metrics   = $report['metrics']    ?? [];
    $lowStock  = $report['low_stock']  ?? [];
    $topMovers = $report['top_movers'] ?? [];
    $reportType = __('Inventory Report');
    $rangeLabel = $rangeLabel ?? '';
@endphp
@extends('admin.reports.pdf._layout')

@section('body')

    {{-- KPIs --}}
    <div class="section-title">{{ __('Inventory Overview') }}</div>
    <table class="kpi-table">
        <tr>
            <td class="kpi-cell">
                <div class="kpi-label">{{ __('Products') }}</div>
                <div class="kpi-value kpi-accent">{{ number_format($metrics['total_products'] ?? 0) }}</div>
            </td>
            <td class="kpi-cell">
                <div class="kpi-label">{{ __('Accessories') }}</div>
                <div class="kpi-value kpi-accent">{{ number_format($metrics['total_accessories'] ?? 0) }}</div>
            </td>
            <td class="kpi-cell">
                <div class="kpi-label">{{ __('Parts') }}</div>
                <div class="kpi-value kpi-accent">{{ number_format($metrics['total_parts'] ?? 0) }}</div>
            </td>
            <td class="kpi-cell">
                <div class="kpi-label">{{ __('Low Stock Items') }}</div>
                <div class="kpi-value {{ ($metrics['low_stock_count'] ?? 0) > 0 ? 'kpi-red' : 'kpi-green' }}">
                    {{ number_format($metrics['low_stock_count'] ?? 0) }}
                </div>
            </td>
        </tr>
    </table>

    <table class="two-col" style="margin-bottom:18px">
        {{-- Low stock --}}
        <tr>
            <td>
                <div class="section-title">{{ __('Low / Out of Stock Items') }}</div>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>{{ __('Item Name') }}</th>
                            <th>{{ __('Type') }}</th>
                            <th>{{ __('SKU') }}</th>
                            <th class="text-right">{{ __('Stock') }}</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse ($lowStock as $i => $item)
                            <tr>
                                <td class="text-center" style="width:22px">{{ $i + 1 }}</td>
                                <td class="font-bold">{{ $item['name'] ?? '—' }}</td>
                                <td><span class="badge badge-slate">{{ ucfirst($item['type'] ?? '—') }}</span></td>
                                <td class="text-muted" style="font-size:8px">{{ $item['sku'] ?? '—' }}</td>
                                <td class="text-right {{ ($item['stock'] ?? 1) == 0 ? 'text-red' : 'text-amber' }}">
                                    {{ $item['stock'] ?? 0 }}
                                </td>
                            </tr>
                        @empty
                            <tr><td colspan="5" style="text-align:center;color:#16a34a;padding:12px">✓ {{ __('All items above threshold') }}</td></tr>
                        @endforelse
                    </tbody>
                </table>
            </td>

            {{-- Top movers --}}
            <td>
                <div class="section-title">{{ __('Top Movers (Qty Sold)') }}</div>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>{{ __('Item Name') }}</th>
                            <th>{{ __('Type') }}</th>
                            <th class="text-right">{{ __('Qty') }}</th>
                            <th class="text-right">{{ __('Revenue') }}</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse ($topMovers as $i => $item)
                            <tr>
                                <td class="text-center"><span class="rank">{{ $i + 1 }}</span></td>
                                <td class="font-bold">{{ $item['name'] ?? '—' }}</td>
                                <td><span class="badge badge-purple">{{ ucfirst($item['item_type'] ?? '—') }}</span></td>
                                <td class="text-right font-bold">{{ number_format($item['quantity'] ?? 0) }}</td>
                                <td class="text-right text-green">${{ number_format($item['sales'] ?? 0, 2) }}</td>
                            </tr>
                        @empty
                            <tr><td colspan="5" style="text-align:center;color:#94a3b8;padding:12px">{{ __('No movement data') }}</td></tr>
                        @endforelse
                    </tbody>
                </table>
            </td>
        </tr>
    </table>

    {{-- Summary note --}}
    <div class="box" style="background:#fff7ed;border-color:#fed7aa">
        <div class="box-title" style="color:#9a3412">{{ __('Stock Health Summary') }}</div>
        <div style="font-size:9.5px;color:#374151;line-height:1.6">
            @php
                $total    = ($metrics['total_products'] ?? 0) + ($metrics['total_accessories'] ?? 0) + ($metrics['total_parts'] ?? 0);
                $lowCount = $metrics['low_stock_count'] ?? 0;
                $healthPct = $total > 0 ? round((($total - $lowCount) / $total) * 100, 1) : 100;
            @endphp
            {{ __('Total catalogue items') }}: <strong>{{ number_format($total) }}</strong> &nbsp;·&nbsp;
            {{ __('Low stock') }}: <strong style="color:#dc2626">{{ $lowCount }}</strong> &nbsp;·&nbsp;
            {{ __('Healthy stock') }}: <strong style="color:#16a34a">{{ $total - $lowCount }}</strong>
            &nbsp; (<strong>{{ $healthPct }}%</strong> {{ __('of catalogue is adequately stocked') }})
        </div>
    </div>

@endsection
