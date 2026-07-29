@php
    $totalParts = $parts->count();
    $totalStock = (int) $parts->sum('stock');
    $inventoryValue = $parts->sum(fn ($part) => (int) $part->stock * (float) $part->unit_cost);
    $activeParts = $parts->where('status', 'active')->count();
    $lowStockParts = $parts->filter(fn ($part) => (int) $part->stock > 0 && (int) $part->stock <= 5)->count();

    $tagLabels = [
        'HOT_SALE' => 'Hot Sale',
        'TOP_SELLER' => 'Top Seller',
        'PROMOTION' => 'Promotion',
    ];
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

    .content { padding: 16px 24px 36px; }

    .kpi-table { width: 100%; border-collapse: separate; border-spacing: 6px; margin-bottom: 16px; }
    .kpi-cell {
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        border-radius: 6px;
        padding: 10px 12px;
        width: 20%;
        vertical-align: top;
    }
    .kpi-label { font-size: 7px; color: #64748b; text-transform: uppercase; letter-spacing: 0.8px; font-weight: bold; }
    .kpi-value { font-size: 15px; font-weight: bold; color: #0f172a; margin-top: 4px; }
    .kpi-accent { color: #4f46e5; }
    .kpi-green { color: #16a34a; }
    .kpi-amber { color: #d97706; }

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

    .data-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 8px;
    }
    .data-table thead tr { background: #1e293b; color: #fff; }
    .data-table thead th {
        padding: 7px;
        text-align: left;
        font-size: 7px;
        text-transform: uppercase;
        letter-spacing: 0.7px;
        font-weight: bold;
    }
    .data-table thead th.right { text-align: right; }
    .data-table thead th.center { text-align: center; }

    .data-table tbody tr:nth-child(even) { background: #f8fafc; }
    .data-table tbody tr:nth-child(odd) { background: #ffffff; }
    .data-table tbody td {
        padding: 5px 7px;
        border-bottom: 1px solid #e2e8f0;
        vertical-align: middle;
    }
    .data-table tbody td.right { text-align: right; }
    .data-table tbody td.center { text-align: center; }
    .data-table tbody td.mono { font-size: 7.5px; color: #334155; }

    .data-table tfoot td {
        padding: 6px 7px;
        font-weight: bold;
        font-size: 9px;
        background: #f1f5f9;
        border-top: 2px solid #cbd5e1;
    }
    .data-table tfoot td.right { text-align: right; color: #16a34a; }

    .badge {
        display: inline-block;
        padding: 2px 6px;
        border-radius: 8px;
        font-size: 7px;
        font-weight: bold;
    }
    .badge-green { background: #dcfce7; color: #166534; }
    .badge-amber { background: #fef9c3; color: #854d0e; }
    .badge-red { background: #fee2e2; color: #991b1b; }
    .badge-blue { background: #dbeafe; color: #1e40af; }
    .badge-slate { background: #f1f5f9; color: #334155; }

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

<div class="header">
    <table style="width:100%;border-collapse:collapse">
        <tr>
            <td>
                <div class="company-name">KneaYerng Service Center</div>
                <div class="company-sub">Mobile App Sales Platform - Phnom Penh, Cambodia</div>
            </td>
            <td style="text-align:right;vertical-align:top">
                <span class="report-badge">{{ __('Parts Inventory') }}</span>
            </td>
        </tr>
    </table>
    <div class="header-divider"></div>
    <div class="header-meta">
        <table style="width:100%;border-collapse:collapse">
            <tr>
                <td>{{ __('Records') }}: <span>{{ number_format($totalParts) }}</span></td>
                <td style="text-align:center">{{ __('Inventory Value') }}: <span>${{ number_format($inventoryValue, 2) }}</span></td>
                <td style="text-align:right">{{ __('Generated') }}: <span>{{ $generatedAt }}</span></td>
            </tr>
        </table>
    </div>
</div>

<div class="content">
    <table class="kpi-table">
        <tr>
            <td class="kpi-cell">
                <div class="kpi-label">{{ __('Total Parts') }}</div>
                <div class="kpi-value kpi-accent">{{ number_format($totalParts) }}</div>
            </td>
            <td class="kpi-cell">
                <div class="kpi-label">{{ __('Stock Units') }}</div>
                <div class="kpi-value">{{ number_format($totalStock) }}</div>
            </td>
            <td class="kpi-cell">
                <div class="kpi-label">{{ __('Inventory Value') }}</div>
                <div class="kpi-value kpi-green">${{ number_format($inventoryValue, 2) }}</div>
            </td>
            <td class="kpi-cell">
                <div class="kpi-label">{{ __('Active Parts') }}</div>
                <div class="kpi-value kpi-green">{{ number_format($activeParts) }}</div>
            </td>
            <td class="kpi-cell">
                <div class="kpi-label">{{ __('Low Stock') }}</div>
                <div class="kpi-value kpi-amber">{{ number_format($lowStockParts) }}</div>
            </td>
        </tr>
    </table>

    <div class="section-title">{{ __('Filtered Parts List') }}</div>
    <table class="data-table">
        <thead>
            <tr>
                <th style="width:24px">#</th>
                <th style="width:110px">{{ __('Name') }}</th>
                <th style="width:70px">{{ __('Type') }}</th>
                <th style="width:70px">{{ __('Brand') }}</th>
                <th style="width:82px">{{ __('SKU') }}</th>
                <th style="width:44px" class="right">{{ __('Stock') }}</th>
                <th style="width:62px" class="right">{{ __('Unit Cost') }}</th>
                <th style="width:70px" class="right">{{ __('Value') }}</th>
                <th style="width:64px" class="center">{{ __('Status') }}</th>
                <th style="width:76px" class="center">{{ __('Tag') }}</th>
                <th style="width:84px">{{ __('Created') }}</th>
            </tr>
        </thead>
        <tbody>
            @forelse($parts as $i => $part)
                @php
                    $status = strtolower((string) ($part->status ?? ''));
                    $statusBadge = match ($status) {
                        'active' => 'badge-green',
                        'archived' => 'badge-amber',
                        'inactive' => 'badge-slate',
                        default => 'badge-slate',
                    };
                    $tag = (string) ($part->tag ?? '');
                    $tagBadge = match ($tag) {
                        'HOT_SALE' => 'badge-red',
                        'TOP_SELLER' => 'badge-blue',
                        'PROMOTION' => 'badge-amber',
                        default => 'badge-slate',
                    };
                    $stock = (int) ($part->stock ?? 0);
                    $unitCost = (float) ($part->unit_cost ?? 0);
                    $rowValue = $stock * $unitCost;
                @endphp
                <tr>
                    <td>{{ $i + 1 }}</td>
                    <td>{{ $part->name ?: '--' }}</td>
                    <td>{{ $part->type ?: '--' }}</td>
                    <td>{{ $part->brand ?: '--' }}</td>
                    <td class="mono">{{ $part->sku ?: '--' }}</td>
                    <td class="right">{{ number_format($stock) }}</td>
                    <td class="right">${{ number_format($unitCost, 2) }}</td>
                    <td class="right" style="font-weight:bold">${{ number_format($rowValue, 2) }}</td>
                    <td class="center"><span class="badge {{ $statusBadge }}">{{ $status ? ucwords($status) : '--' }}</span></td>
                    <td class="center"><span class="badge {{ $tagBadge }}">{{ $tag ? ($tagLabels[$tag] ?? ucwords(strtolower(str_replace('_', ' ', $tag)))) : '--' }}</span></td>
                    <td class="mono">{{ $part->created_at ? $part->created_at->format('d M Y H:i') : '--' }}</td>
                </tr>
            @empty
                <tr>
                    <td colspan="11" style="text-align:center;color:#94a3b8;padding:20px">
                        {{ __('No parts found for the selected filters.') }}
                    </td>
                </tr>
            @endforelse
        </tbody>
        @if($totalParts > 0)
        <tfoot>
            <tr>
                <td colspan="5">{{ __('Total') }} ({{ number_format($totalParts) }} {{ __('parts') }})</td>
                <td class="right">{{ number_format($totalStock) }}</td>
                <td></td>
                <td class="right">${{ number_format($inventoryValue, 2) }}</td>
                <td colspan="3"></td>
            </tr>
        </tfoot>
        @endif
    </table>
</div>

<div class="footer">
    <table style="width:100%;border-collapse:collapse">
        <tr>
            <td>KneaYerng Service Center - {{ __('Confidential Export') }}</td>
            <td style="text-align:center">{{ __('Generated via Admin Portal') }}</td>
            <td style="text-align:right">{{ $generatedAt }}</td>
        </tr>
    </table>
</div>

</body>
</html>
