@php
    $metrics      = $report['metrics']       ?? [];
    $topCustomers = $report['top_customers'] ?? [];
    $reportType   = __('Customer Report');
    $rangeLabel   = $rangeLabel ?? '';
@endphp
@extends('admin.reports.pdf._layout')

@section('body')

    {{-- KPIs --}}
    <div class="section-title">{{ __('Customer Metrics') }}</div>
    <table class="kpi-table">
        <tr>
            <td class="kpi-cell">
                <div class="kpi-label">{{ __('Total Customers') }}</div>
                <div class="kpi-value kpi-accent">{{ number_format($metrics['total_customers'] ?? 0) }}</div>
            </td>
            <td class="kpi-cell">
                <div class="kpi-label">{{ __('New This Period') }}</div>
                <div class="kpi-value kpi-green">{{ number_format($metrics['new_customers'] ?? 0) }}</div>
            </td>
            <td class="kpi-cell">
                <div class="kpi-label">{{ __('Active Customers') }}</div>
                <div class="kpi-value">{{ number_format($metrics['active_customers'] ?? 0) }}</div>
            </td>
            <td class="kpi-cell">
                <div class="kpi-label">{{ __('Repeat Customers') }}</div>
                <div class="kpi-value kpi-amber">{{ number_format($metrics['repeat_customers'] ?? 0) }}</div>
            </td>
        </tr>
    </table>

    {{-- Retention insight --}}
    @php
        $total  = $metrics['total_customers'] ?? 0;
        $active = $metrics['active_customers'] ?? 0;
        $repeat = $metrics['repeat_customers'] ?? 0;
        $retentionRate  = $total  > 0 ? round($active / $total  * 100, 1) : 0;
        $repeatRate     = $active > 0 ? round($repeat / $active * 100, 1) : 0;
    @endphp
    <table class="two-col" style="margin-bottom:18px">
        <tr>
            <td>
                <div class="box">
                    <div class="box-title">{{ __('Retention Rate (Active / Total)') }}</div>
                    <div style="font-size:22px;font-weight:bold;color:{{ $retentionRate >= 50 ? '#16a34a' : '#d97706' }}">{{ $retentionRate }}%</div>
                    <div class="progress-bg" style="margin-top:8px">
                        <div class="progress-fill" style="width:{{ min($retentionRate,100) }}%;background:{{ $retentionRate >= 50 ? '#16a34a' : '#d97706' }}"></div>
                    </div>
                    <div style="font-size:8px;color:#64748b;margin-top:4px">{{ $active }} {{ __('active out of') }} {{ $total }} {{ __('total customers') }}</div>
                </div>
            </td>
            <td>
                <div class="box">
                    <div class="box-title">{{ __('Repeat Purchase Rate') }}</div>
                    <div style="font-size:22px;font-weight:bold;color:{{ $repeatRate >= 30 ? '#16a34a' : '#d97706' }}">{{ $repeatRate }}%</div>
                    <div class="progress-bg" style="margin-top:8px">
                        <div class="progress-fill" style="width:{{ min($repeatRate,100) }}%;background:{{ $repeatRate >= 30 ? '#16a34a' : '#d97706' }}"></div>
                    </div>
                    <div style="font-size:8px;color:#64748b;margin-top:4px">{{ $repeat }} {{ __('repeat out of') }} {{ $active }} {{ __('active customers') }}</div>
                </div>
            </td>
        </tr>
    </table>

    {{-- Top Customers --}}
    <div class="section-title">{{ __('Top Customers by Spending') }}</div>
    <table class="data-table">
        <thead>
            <tr>
                <th style="width:30px">#</th>
                <th>{{ __('Customer Name') }}</th>
                <th>{{ __('Email') }}</th>
                <th>{{ __('Phone') }}</th>
                <th class="text-right">{{ __('Orders') }}</th>
                <th class="text-right">{{ __('Total Spent') }}</th>
                <th class="text-right">{{ __('Avg/Order') }}</th>
            </tr>
        </thead>
        <tbody>
            @forelse ($topCustomers as $i => $c)
                @php $avg = ($c['orders_count'] ?? 0) > 0 ? ($c['total_spent'] ?? 0) / $c['orders_count'] : 0; @endphp
                <tr>
                    <td class="text-center"><span class="rank">{{ $i + 1 }}</span></td>
                    <td class="font-bold">{{ $c['name'] ?? '—' }}</td>
                    <td class="text-muted" style="font-size:8.5px">{{ $c['email'] ?? '—' }}</td>
                    <td class="text-muted" style="font-size:8.5px">{{ $c['phone'] ? '+'.ltrim($c['phone'],'+') : '—' }}</td>
                    <td class="text-right">{{ $c['orders_count'] ?? 0 }}</td>
                    <td class="text-right text-green">${{ number_format($c['total_spent'] ?? 0, 2) }}</td>
                    <td class="text-right text-muted">${{ number_format($avg, 2) }}</td>
                </tr>
            @empty
                <tr><td colspan="7" style="text-align:center;color:#94a3b8;padding:14px">{{ __('No customer activity in this period.') }}</td></tr>
            @endforelse
        </tbody>
        @if (count($topCustomers))
        <tfoot>
            <tr>
                <td colspan="4">{{ __('Totals (shown)') }}</td>
                <td class="text-right">{{ number_format(collect($topCustomers)->sum('orders_count')) }}</td>
                <td class="text-right">${{ number_format(collect($topCustomers)->sum('total_spent'), 2) }}</td>
                <td></td>
            </tr>
        </tfoot>
        @endif
    </table>

@endsection
