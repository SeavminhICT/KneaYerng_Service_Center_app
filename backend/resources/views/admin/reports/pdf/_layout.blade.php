<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<style>
    * { margin: 0; padding: 0; box-sizing: border-box; }

    body {
        font-family: DejaVu Sans, sans-serif;
        font-size: 10px;
        color: #1e293b;
        background: #ffffff;
    }

    /* ── Page layout ── */
    .page { padding: 0; }

    /* ── Header ── */
    .header {
        background: #1e293b;
        padding: 22px 30px 18px;
        color: #fff;
    }
    .header-top {
        display: flex; /* dompdf supports basic flex */
        justify-content: space-between;
        align-items: flex-start;
    }
    .company-name {
        font-size: 18px;
        font-weight: bold;
        color: #f8fafc;
        letter-spacing: 0.5px;
    }
    .company-sub {
        font-size: 9px;
        color: #94a3b8;
        margin-top: 3px;
        letter-spacing: 1px;
        text-transform: uppercase;
    }
    .report-badge {
        background: #4f46e5;
        color: #fff;
        padding: 5px 14px;
        border-radius: 20px;
        font-size: 9px;
        font-weight: bold;
        letter-spacing: 1px;
        text-transform: uppercase;
    }
    .header-divider {
        height: 1px;
        background: rgba(255,255,255,0.12);
        margin: 14px 0 12px;
    }
    .header-meta {
        font-size: 9px;
        color: #94a3b8;
    }
    .header-meta span {
        color: #e2e8f0;
        font-weight: bold;
    }

    /* ── Content area ── */
    .content { padding: 22px 30px; }

    /* ── Section title ── */
    .section-title {
        font-size: 11px;
        font-weight: bold;
        color: #0f172a;
        text-transform: uppercase;
        letter-spacing: 1px;
        margin-bottom: 10px;
        padding-bottom: 6px;
        border-bottom: 2px solid #4f46e5;
    }

    /* ── KPI cards (table-based for dompdf) ── */
    .kpi-table { width: 100%; border-collapse: separate; border-spacing: 6px; margin-bottom: 20px; }
    .kpi-cell {
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        padding: 12px 14px;
        width: 25%;
        vertical-align: top;
    }
    .kpi-label {
        font-size: 8px;
        color: #64748b;
        text-transform: uppercase;
        letter-spacing: 0.8px;
        font-weight: bold;
    }
    .kpi-value {
        font-size: 18px;
        font-weight: bold;
        color: #0f172a;
        margin-top: 5px;
    }
    .kpi-accent { color: #4f46e5; }
    .kpi-green  { color: #16a34a; }
    .kpi-red    { color: #dc2626; }
    .kpi-amber  { color: #d97706; }

    /* ── Data table ── */
    .data-table {
        width: 100%;
        border-collapse: collapse;
        margin-bottom: 20px;
        font-size: 9.5px;
    }
    .data-table thead tr {
        background: #1e293b;
        color: #fff;
    }
    .data-table thead th {
        padding: 8px 10px;
        text-align: left;
        font-size: 8px;
        text-transform: uppercase;
        letter-spacing: 0.8px;
        font-weight: bold;
    }
    .data-table thead th.text-right { text-align: right; }
    .data-table thead th.text-center { text-align: center; }

    .data-table tbody tr:nth-child(even)  { background: #f8fafc; }
    .data-table tbody tr:nth-child(odd)   { background: #ffffff; }
    .data-table tbody td {
        padding: 7px 10px;
        border-bottom: 1px solid #e2e8f0;
        vertical-align: middle;
    }
    .data-table tbody td.text-right  { text-align: right; }
    .data-table tbody td.text-center { text-align: center; }
    .data-table tbody td.font-bold   { font-weight: bold; }
    .data-table tbody td.text-green  { color: #16a34a; font-weight: bold; }
    .data-table tbody td.text-red    { color: #dc2626; font-weight: bold; }
    .data-table tbody td.text-amber  { color: #d97706; font-weight: bold; }
    .data-table tbody td.text-muted  { color: #64748b; }
    .data-table tfoot td {
        padding: 8px 10px;
        font-weight: bold;
        font-size: 10px;
        background: #f1f5f9;
        border-top: 2px solid #cbd5e1;
    }
    .data-table tfoot td.text-right { text-align: right; }

    /* ── Badge ── */
    .badge {
        display: inline-block;
        padding: 2px 8px;
        border-radius: 10px;
        font-size: 8px;
        font-weight: bold;
    }
    .badge-green  { background: #dcfce7; color: #166534; }
    .badge-amber  { background: #fef9c3; color: #854d0e; }
    .badge-red    { background: #fee2e2; color: #991b1b; }
    .badge-blue   { background: #dbeafe; color: #1e40af; }
    .badge-purple { background: #ede9fe; color: #5b21b6; }
    .badge-slate  { background: #f1f5f9; color: #334155; }

    /* ── 2-column layout ── */
    .two-col { width: 100%; border-collapse: separate; border-spacing: 10px; }
    .two-col td { width: 50%; vertical-align: top; }

    /* ── Box ── */
    .box {
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        padding: 14px;
        background: #f8fafc;
        margin-bottom: 14px;
    }
    .box-title {
        font-size: 9px;
        font-weight: bold;
        color: #64748b;
        text-transform: uppercase;
        letter-spacing: 0.8px;
        margin-bottom: 8px;
    }

    /* ── Divider ── */
    .divider { height: 1px; background: #e2e8f0; margin: 16px 0; }

    /* ── Footer ── */
    .footer {
        background: #f8fafc;
        border-top: 1px solid #e2e8f0;
        padding: 10px 30px;
        font-size: 8px;
        color: #94a3b8;
    }
    .footer-inner { display: flex; justify-content: space-between; }

    /* ── Rank circle ── */
    .rank {
        display: inline-block;
        width: 18px;
        height: 18px;
        line-height: 18px;
        border-radius: 50%;
        background: #e0e7ff;
        color: #4338ca;
        font-size: 8px;
        font-weight: bold;
        text-align: center;
    }

    /* ── Progress bar ── */
    .progress-bg {
        background: #e2e8f0;
        border-radius: 4px;
        height: 6px;
        width: 100%;
    }
    .progress-fill {
        background: #16a34a;
        border-radius: 4px;
        height: 6px;
    }
</style>
</head>
<body>
<div class="page">

    {{-- Header --}}
    <div class="header">
        <table style="width:100%;border-collapse:collapse">
            <tr>
                <td>
                    <div class="company-name">KneaYerng Service Center</div>
                    <div class="company-sub">Mobile App Sales Platform · Phnom Penh, Cambodia</div>
                </td>
                <td style="text-align:right;vertical-align:top">
                    <span class="report-badge">{{ strtoupper($reportType ?? __('Report')) }}</span>
                </td>
            </tr>
        </table>
        <div class="header-divider"></div>
        <div class="header-meta">
            <table style="width:100%;border-collapse:collapse">
                <tr>
                    <td>{{ __('Period') }}: <span>{{ $rangeLabel ?? '—' }}</span></td>
                    <td style="text-align:center">{{ __('From') }}: <span>{{ $start->format('d M Y') }}</span> &nbsp;→&nbsp; {{ __('To') }}: <span>{{ $end->format('d M Y') }}</span></td>
                    <td style="text-align:right">{{ __('Generated') }}: <span>{{ now()->format('d M Y, H:i') }} ICT</span></td>
                </tr>
            </table>
        </div>
    </div>

    {{-- Body --}}
    <div class="content">
        @yield('body')
    </div>

    {{-- Footer --}}
    <div class="footer">
        <table style="width:100%;border-collapse:collapse">
            <tr>
                <td>KneaYerng Service Center — {{ __('Confidential Report') }}</td>
                <td style="text-align:center">{{ __('Generated via Admin Portal') }}</td>
                <td style="text-align:right">{{ __('Page') }} 1</td>
            </tr>
        </table>
    </div>

</div>
</body>
</html>
