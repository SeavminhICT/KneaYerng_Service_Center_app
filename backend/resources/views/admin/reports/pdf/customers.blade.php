@php
    $metrics      = $report['metrics']       ?? [];
    $topCustomers = $report['top_customers'] ?? [];
    $locations    = $report['locations']     ?? [];
    $demographics = $report['demographics']   ?? [];
    $reportType   = __('Customer Intelligence Report');
    $rangeLabel   = $rangeLabel ?? '';
@endphp
@extends('admin.reports.pdf._layout')

@section('body')

    {{-- Customer Intelligence Summary --}}
    <div class="section-title">{{ __('Customer Intelligence Summary') }}</div>
    <table class="data-table" style="margin-bottom:20px">
        <thead>
            <tr>
                <th>{{ __('Customer Metric') }}</th>
                <th class="text-right">{{ __('Value') }}</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td class="font-bold">{{ __('Total Customers') }}</td>
                <td class="text-right font-bold text-accent">{{ number_format($metrics['total_customers'] ?? 0) }}</td>
            </tr>
            <tr>
                <td>{{ __('New Customers (This Period)') }}</td>
                <td class="text-right text-green font-bold">{{ number_format($metrics['new_customers'] ?? 0) }}</td>
            </tr>
            <tr>
                <td>{{ __('Active / Returning Customers') }}</td>
                <td class="text-right text-indigo font-bold">{{ number_format($metrics['active_customers'] ?? 0) }}</td>
            </tr>
            <tr>
                <td>{{ __('Repeat Customers (2+ Orders)') }}</td>
                <td class="text-right text-purple font-bold">{{ number_format($metrics['repeat_customers'] ?? 0) }}</td>
            </tr>
            <tr>
                <td>{{ __('VIP Customers ($500+ Spent)') }}</td>
                <td class="text-right text-green font-bold">{{ number_format($metrics['vip_customers'] ?? 0) }}</td>
            </tr>
            <tr>
                <td>{{ __('Inactive Customers') }}</td>
                <td class="text-right text-amber">{{ number_format($metrics['inactive_customers'] ?? 0) }}</td>
            </tr>
            <tr>
                <td>{{ __('Average Spending per Customer') }}</td>
                <td class="text-right font-bold text-green">${{ number_format($metrics['avg_spending'] ?? 0, 2) }}</td>
            </tr>
            <tr>
                <td>{{ __('Average Order Value (AOV)') }}</td>
                <td class="text-right font-bold">${{ number_format($metrics['avg_order_value'] ?? 0, 2) }}</td>
            </tr>
            <tr style="background:#eff6ff">
                <td class="font-bold text-accent" style="font-size:11px">{{ __('Customer Lifetime Value (CLV)') }}</td>
                <td class="text-right font-bold text-accent" style="font-size:11px">${{ number_format($metrics['clv'] ?? 0, 2) }}</td>
            </tr>
        </tbody>
    </table>

    <div class="section-title">{{ __('Charts') }}</div>
    @php
        $growthRows = [
            ['label' => 'New Customers', 'value' => (float) ($metrics['new_customers'] ?? 0)],
            ['label' => 'Returning Customers', 'value' => (float) ($metrics['repeat_customers'] ?? 0)],
            ['label' => 'VIP Customers', 'value' => (float) ($metrics['vip_customers'] ?? 0)],
            ['label' => 'Inactive Customers', 'value' => (float) ($metrics['inactive_customers'] ?? 0)],
        ];
        $growthMax = max(array_map(fn ($row) => $row['value'], $growthRows)) ?: 1;
    @endphp
    <div style="font-weight:bold;margin-bottom:6px">{{ __('Customer Growth') }}</div>
    <table class="chart-table">
        <tbody>
            @foreach ($growthRows as $row)
                @php $barWidth = max(2, (int) round(($row['value'] / $growthMax) * 160)); @endphp
                <tr>
                    <td style="width:120px">{{ $row['label'] }}</td>
                    <td style="width:180px"><div class="bar-bg"><div class="bar-fill" style="width:{{ $barWidth }}px"></div></div></td>
                    <td class="text-right">{{ number_format($row['value']) }}</td>
                </tr>
            @endforeach
        </tbody>
    </table>

    {{-- Locations & Demographics Breakdown --}}
    <table class="two-col" style="margin-bottom:20px">
        <tr>
            <td>
                <div class="section-title">{{ __('Customer Locations') }}</div>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>{{ __('City / Province') }}</th>
                            <th class="text-right">{{ __('Customers') }}</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($locations as $loc)
                            <tr>
                                <td>{{ $loc['city'] }}</td>
                                <td class="text-right font-bold">{{ number_format($loc['count']) }}</td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </td>
            <td>
                <div class="section-title">{{ __('Age Demographics') }}</div>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>{{ __('Age Group') }}</th>
                            <th class="text-right">{{ __('Share (%)') }}</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($demographics as $demo)
                            <tr>
                                <td>{{ $demo['group'] }}</td>
                                <td class="text-right font-bold text-indigo">{{ $demo['pct'] }}%</td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </td>
        </tr>
    </table>

    {{-- Top Customers --}}
    <div class="section-title">{{ __('Top Customers Leaderboard') }}</div>
    <table class="data-table">
        <thead>
            <tr>
                <th style="width:25px">#</th>
                <th>{{ __('Customer Name') }}</th>
                <th>{{ __('Email') }}</th>
                <th>{{ __('Phone') }}</th>
                <th class="text-right">{{ __('Orders') }}</th>
                <th class="text-right">{{ __('Total Spent') }}</th>
            </tr>
        </thead>
        <tbody>
            @forelse ($topCustomers as $i => $c)
                <tr>
                    <td class="text-center"><span class="rank">{{ $i + 1 }}</span></td>
                    <td class="font-bold">{{ $c['name'] ?? 'Guest Customer' }}</td>
                    <td class="text-muted" style="font-size:8.5px">{{ $c['email'] ?? '—' }}</td>
                    <td class="text-muted" style="font-size:8.5px">{{ $c['phone'] ? '+'.ltrim($c['phone'],'+') : '—' }}</td>
                    <td class="text-right font-bold">{{ $c['orders_count'] ?? 0 }}</td>
                    <td class="text-right text-green font-bold">${{ number_format($c['total_spent'] ?? 0, 2) }}</td>
                </tr>
            @empty
                <tr><td colspan="6" style="text-align:center;color:#94a3b8;padding:14px">{{ __('No customer records found.') }}</td></tr>
            @endforelse
        </tbody>
    </table>

@endsection
