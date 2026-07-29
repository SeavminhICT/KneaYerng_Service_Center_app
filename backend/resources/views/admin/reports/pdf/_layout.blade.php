<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<style>
    * { box-sizing: border-box; }
    body {
        margin: 0;
        font-family: DejaVu Sans, Arial, sans-serif;
        font-size: 10px;
        color: #111827;
        background: #ffffff;
    }
    .page { padding: 24px 28px 18px; }
    .doc-header {
        border: 1px solid #d1d5db;
        padding: 16px 18px 12px;
        margin-bottom: 18px;
    }
    .header-table, .meta-table, .filter-table, .data-table, .kpi-table, .chart-table, .two-col {
        width: 100%;
        border-collapse: collapse;
    }
    .logo-cell { width: 86px; vertical-align: middle; }
    .logo-box {
        width: 66px;
        height: 48px;
        border: 1px solid #d1d5db;
        text-align: center;
        line-height: 48px;
        font-size: 9px;
        font-weight: bold;
        color: #374151;
        background: #f9fafb;
    }
    .logo-img { max-width: 70px; max-height: 52px; }
    .company-name {
        font-size: 17px;
        font-weight: bold;
        text-align: center;
        letter-spacing: .6px;
        color: #111827;
    }
    .system-name {
        margin-top: 3px;
        font-size: 10px;
        text-align: center;
        color: #4b5563;
        text-transform: uppercase;
        letter-spacing: .7px;
    }
    .report-name {
        margin-top: 10px;
        padding-top: 10px;
        border-top: 1px solid #d1d5db;
        text-align: center;
        font-size: 18px;
        font-weight: bold;
        letter-spacing: .8px;
        text-transform: uppercase;
    }
    .meta-table { margin-top: 12px; }
    .meta-table td, .filter-table td {
        border: 1px solid #e5e7eb;
        padding: 6px 8px;
        vertical-align: top;
    }
    .meta-label, .filter-label {
        width: 18%;
        background: #f3f4f6;
        color: #374151;
        font-weight: bold;
    }
    .section-title {
        margin: 16px 0 8px;
        padding: 6px 8px;
        border-left: 4px solid #6b7280;
        background: #f3f4f6;
        font-size: 11px;
        font-weight: bold;
        color: #111827;
        text-transform: uppercase;
        letter-spacing: .6px;
    }
    .kpi-table { border-spacing: 0; margin-bottom: 12px; }
    .kpi-cell {
        border: 1px solid #d1d5db;
        background: #f9fafb;
        padding: 10px;
        width: 25%;
        vertical-align: top;
    }
    .kpi-label {
        color: #6b7280;
        font-size: 8px;
        font-weight: bold;
        text-transform: uppercase;
        letter-spacing: .6px;
    }
    .kpi-value {
        margin-top: 4px;
        color: #111827;
        font-size: 15px;
        font-weight: bold;
    }
    .data-table { margin-bottom: 14px; }
    .data-table th {
        background: #e5e7eb;
        border: 1px solid #9ca3af;
        color: #111827;
        padding: 7px 8px;
        text-align: left;
        font-size: 8.5px;
        text-transform: uppercase;
        letter-spacing: .5px;
    }
    .data-table td {
        border: 1px solid #d1d5db;
        padding: 7px 8px;
        vertical-align: top;
    }
    .data-table tbody tr:nth-child(even) td { background: #f9fafb; }
    .data-table tfoot td {
        background: #f3f4f6;
        border-top: 2px solid #9ca3af;
        font-weight: bold;
    }
    .text-right { text-align: right; }
    .text-center { text-align: center; }
    .font-bold { font-weight: bold; }
    .text-muted { color: #6b7280; }
    .text-green { color: #047857; }
    .text-red { color: #b91c1c; }
    .text-amber { color: #b45309; }
    .text-indigo, .text-purple, .text-accent { color: #374151; }
    .badge {
        display: inline-block;
        padding: 2px 6px;
        border: 1px solid #d1d5db;
        background: #f9fafb;
        color: #374151;
        font-size: 8px;
        font-weight: bold;
    }
    .rank {
        display: inline-block;
        min-width: 18px;
        padding: 2px 4px;
        border: 1px solid #d1d5db;
        background: #f3f4f6;
        text-align: center;
        font-size: 8px;
        font-weight: bold;
    }
    .two-col { margin-bottom: 14px; }
    .two-col td { width: 50%; vertical-align: top; padding-right: 8px; }
    .chart-table { margin-bottom: 12px; }
    .chart-table td {
        border: 1px solid #e5e7eb;
        padding: 5px 7px;
    }
    .bar-bg { width: 160px; height: 8px; background: #e5e7eb; }
    .bar-fill { height: 8px; background: #4b5563; }
    .footer {
        border-top: 1px solid #d1d5db;
        margin-top: 16px;
        padding-top: 8px;
        font-size: 8px;
        color: #6b7280;
    }
</style>
@php
    $logoPath = public_path('images/Logo_KYSC.png');
    $logoSrc = file_exists($logoPath) ? 'data:image/png;base64,'.base64_encode(file_get_contents($logoPath)) : '';
    $generatedBy = $generatedBy ?? 'Admin';
    $filters = $filters ?? [];
    $branch = $filters['branch'] ?? '';
    $activeFilters = array_filter($filters, fn ($value) => trim((string) $value) !== '');
@endphp
</head>
<body>
<div class="page">
    <div class="doc-header">
        <table class="header-table">
            <tr>
                <td class="logo-cell">
                    @if ($logoSrc)
                        <img class="logo-img" src="{{ $logoSrc }}" alt="Logo">
                    @else
                        <div class="logo-box">LOGO</div>
                    @endif
                </td>
                <td>
                    <div class="company-name">LNK STORE MANAGEMENT SYSTEM</div>
                    <div class="system-name">Knea Yerng Service Center</div>
                    <div class="report-name">{{ strtoupper($reportType ?? 'Report') }}</div>
                </td>
                <td class="logo-cell">&nbsp;</td>
            </tr>
        </table>

        <table class="meta-table">
            <tr>
                <td class="meta-label">Report Date</td>
                <td>{{ $rangeLabel ?? '-' }}</td>
                <td class="meta-label">Generated By</td>
                <td>{{ $generatedBy }}</td>
            </tr>
            <tr>
                <td class="meta-label">Generated Time</td>
                <td>{{ now()->format('d M Y H:i') }}</td>
                <td class="meta-label">Branch</td>
                <td>{{ $branch !== '' ? $branch : 'All' }}</td>
            </tr>
        </table>

        @if (count($activeFilters))
            <table class="filter-table" style="margin-top:8px">
                <tr>
                    <td class="filter-label">Employee</td>
                    <td>{{ ($filters['employee'] ?? '') ?: 'All' }}</td>
                    <td class="filter-label">Payment Method</td>
                    <td>{{ ($filters['payment_method'] ?? '') ?: 'All' }}</td>
                </tr>
                <tr>
                    <td class="filter-label">Order Status</td>
                    <td>{{ ($filters['order_status'] ?? '') ?: 'All' }}</td>
                    <td class="filter-label">Customer</td>
                    <td>{{ ($filters['customer'] ?? '') ?: 'All' }}</td>
                </tr>
                <tr>
                    <td class="filter-label">Product Category</td>
                    <td>{{ ($filters['product_category'] ?? '') ?: 'All' }}</td>
                    <td class="filter-label">Product</td>
                    <td>{{ ($filters['product'] ?? '') ?: 'All' }}</td>
                </tr>
            </table>
        @endif
    </div>

    @yield('body')

    <div class="footer">
        <table style="width:100%;border-collapse:collapse">
            <tr>
                <td>Generated by LNK Ecommerce Management System</td>
                <td style="text-align:center">Confidential</td>
                <td style="text-align:right">Page 1</td>
            </tr>
        </table>
    </div>
</div>
</body>
</html>
