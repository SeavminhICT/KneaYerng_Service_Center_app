@php
    $metrics    = $report['metrics']   ?? [];
    $lowStock   = $report['low_stock']  ?? [];
    $topMovers  = $report['top_movers'] ?? [];
    $categories = $report['categories'] ?? [];
    $reportType = __('Inventory & Stock Report');
    $rangeLabel = $rangeLabel ?? '';
@endphp
@extends('admin.reports.pdf._layout')

@section('body')

    {{-- Inventory Summary --}}
    <div class="section-title">{{ __('Inventory & Stock Summary') }}</div>
    <table class="data-table" style="margin-bottom:20px">
        <thead>
            <tr>
                <th>{{ __('Stock Metric') }}</th>
                <th class="text-right">{{ __('Value / Quantity') }}</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td class="font-bold">{{ __('Total Product Catalogs') }}</td>
                <td class="text-right font-bold">{{ number_format($metrics['total_products'] ?? 0) }}</td>
            </tr>
            <tr>
                <td>{{ __('Available Stock Units') }}</td>
                <td class="text-right text-green font-bold">{{ number_format($metrics['available_stock'] ?? 0) }}</td>
            </tr>
            <tr>
                <td>{{ __('Low Stock Items (Below Threshold)') }}</td>
                <td class="text-right text-amber font-bold">{{ number_format($metrics['low_stock_count'] ?? 0) }}</td>
            </tr>
            <tr>
                <td>{{ __('Out of Stock Items') }}</td>
                <td class="text-right text-red font-bold">{{ number_format($metrics['out_of_stock_count'] ?? 0) }}</td>
            </tr>
            <tr>
                <td>{{ __('Incoming Stock Orders') }}</td>
                <td class="text-right text-indigo font-bold">{{ number_format($metrics['incoming_stock'] ?? 0) }}</td>
            </tr>
            <tr>
                <td>{{ __('Damaged / Defective Items') }}</td>
                <td class="text-right text-muted">{{ number_format($metrics['damaged_items'] ?? 0) }}</td>
            </tr>
            <tr style="background:#f0fdf4">
                <td class="font-bold text-green" style="font-size:11px">{{ __('Total Inventory Value ($)') }}</td>
                <td class="text-right font-bold text-green" style="font-size:11px">${{ number_format($metrics['inventory_value'] ?? 0, 2) }}</td>
            </tr>
        </tbody>
    </table>

    <div class="section-title">{{ __('Charts') }}</div>
    <div style="font-weight:bold;margin-bottom:6px">{{ __('Inventory Value') }}</div>
    @php
        $valueMax = max(array_map(fn ($row) => (float) ($row['value'] ?? 0), $categories ?: [['value' => 0]])) ?: 1;
    @endphp
    <table class="chart-table">
        <tbody>
            @foreach ($categories as $cat)
                @php
                    $catValue = (float) ($cat['value'] ?? 0);
                    $barWidth = max(2, (int) round(($catValue / $valueMax) * 160));
                @endphp
                <tr>
                    <td style="width:120px">{{ $cat['name'] ?? '-' }}</td>
                    <td style="width:180px"><div class="bar-bg"><div class="bar-fill" style="width:{{ $barWidth }}px"></div></div></td>
                    <td class="text-right">${{ number_format($catValue, 2) }}</td>
                </tr>
            @endforeach
        </tbody>
    </table>

    {{-- Inventory Value by Category --}}
    <div class="section-title">{{ __('Inventory Value by Category') }}</div>
    <table class="data-table" style="margin-bottom:20px">
        <thead>
            <tr>
                <th>{{ __('Category') }}</th>
                <th class="text-right">{{ __('Catalog Count') }}</th>
                <th class="text-right">{{ __('Category Value ($)') }}</th>
            </tr>
        </thead>
        <tbody>
            @foreach ($categories as $cat)
                <tr>
                    <td class="font-bold">{{ $cat['name'] }}</td>
                    <td class="text-right font-bold">{{ number_format($cat['count']) }}</td>
                    <td class="text-right text-green font-bold">${{ number_format($cat['value'], 2) }}</td>
                </tr>
            @endforeach
        </tbody>
    </table>

    {{-- Low Stock Warning Table --}}
    <div class="section-title">{{ __('Low Stock Warning Items') }}</div>
    <table class="data-table">
        <thead>
            <tr>
                <th style="width:25px">#</th>
                <th>{{ __('Item Name') }}</th>
                <th>{{ __('SKU') }}</th>
                <th>{{ __('Type') }}</th>
                <th class="text-right">{{ __('Stock Level') }}</th>
                <th class="text-right">{{ __('Reorder Level') }}</th>
                <th class="text-right">{{ __('Status') }}</th>
            </tr>
        </thead>
        <tbody>
            @forelse ($lowStock as $i => $item)
                @php $isOut = ($item['stock'] ?? 0) == 0; @endphp
                <tr>
                    <td class="text-center"><span class="rank">{{ $i + 1 }}</span></td>
                    <td class="font-bold">{{ $item['name'] ?? '—' }}</td>
                    <td class="text-muted" style="font-size:8.5px;font-family:monospace">{{ $item['sku'] ?? '—' }}</td>
                    <td><span class="badge badge-slate">{{ ucfirst($item['type'] ?? 'item') }}</span></td>
                    <td class="text-right font-bold {{ $isOut ? 'text-red' : 'text-amber' }}">{{ number_format($item['stock'] ?? 0) }}</td>
                    <td class="text-right text-muted">{{ number_format($item['reorder_level'] ?? 10) }}</td>
                    <td class="text-right">
                        <span class="badge {{ $isOut ? 'badge-red' : 'badge-amber' }}">{{ $item['status'] ?? 'Low Stock' }}</span>
                    </td>
                </tr>
            @empty
                <tr><td colspan="7" style="text-align:center;color:#94a3b8;padding:14px">{{ __('All inventory stock levels are healthy.') }}</td></tr>
            @endforelse
        </tbody>
    </table>

    <div class="section-title">{{ __('Stock Movement') }}</div>
    <table class="data-table">
        <thead>
            <tr>
                <th>{{ __('Date') }}</th>
                <th>{{ __('Product') }}</th>
                <th class="text-right">{{ __('IN') }}</th>
                <th class="text-right">{{ __('OUT') }}</th>
            </tr>
        </thead>
        <tbody>
            @forelse ($topMovers as $item)
                <tr>
                    <td>{{ $end->format('d M Y') }}</td>
                    <td class="font-bold">{{ $item['name'] ?? '-' }}</td>
                    <td class="text-right">0</td>
                    <td class="text-right font-bold">{{ number_format($item['quantity'] ?? 0) }}</td>
                </tr>
            @empty
                <tr><td colspan="4" style="text-align:center;color:#94a3b8;padding:14px">{{ __('No stock movement data available.') }}</td></tr>
            @endforelse
        </tbody>
    </table>

    <div class="section-title">{{ __('Recommendations') }}</div>
    <table class="data-table">
        <tbody>
            <tr><td>{{ __('Review all products at or below reorder level.') }}</td></tr>
            <tr><td>{{ __('Prioritize purchasing for out-of-stock and low-stock items.') }}</td></tr>
            <tr><td>{{ __('Use inventory value by category before approving new stock purchases.') }}</td></tr>
        </tbody>
    </table>

@endsection
