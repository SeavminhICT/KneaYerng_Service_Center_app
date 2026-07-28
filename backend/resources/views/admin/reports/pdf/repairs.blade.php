@php
    $metrics      = $report['metrics']        ?? [];
    $byStatus     = $report['by_status']      ?? [];
    $byService    = $report['by_service_type']?? [];
    $technicians  = $report['technicians']    ?? [];
    $recent       = $report['recent']         ?? [];
    $reportType   = __('Repair Operation Report');
    $rangeLabel   = $rangeLabel ?? '';
@endphp
@extends('admin.reports.pdf._layout')

@section('body')

    {{-- Repair Operations Summary --}}
    <div class="section-title">{{ __('Repair Operations Summary') }}</div>
    <table class="data-table" style="margin-bottom:20px">
        <thead>
            <tr>
                <th>{{ __('Operation Metric') }}</th>
                <th class="text-right">{{ __('Value / Count') }}</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td class="font-bold">{{ __('Received Devices (Total Requests)') }}</td>
                <td class="text-right font-bold text-accent">{{ number_format($metrics['total_requests'] ?? 0) }}</td>
            </tr>
            <tr>
                <td>{{ __('Completed & Delivered Jobs') }}</td>
                <td class="text-right text-green font-bold">{{ number_format($metrics['completed'] ?? 0) }}</td>
            </tr>
            <tr>
                <td>{{ __('Pending / Waiting Parts') }}</td>
                <td class="text-right text-amber font-bold">{{ number_format($metrics['pending'] ?? 0) }}</td>
            </tr>
            <tr>
                <td>{{ __('In Progress / Repairing') }}</td>
                <td class="text-right text-indigo font-bold">{{ number_format($metrics['in_progress'] ?? 0) }}</td>
            </tr>
            <tr>
                <td>{{ __('Cancelled Repairs') }}</td>
                <td class="text-right text-red">{{ number_format($metrics['cancelled'] ?? 0) }}</td>
            </tr>
            <tr>
                <td>{{ __('Average Repair Turnaround Time') }}</td>
                <td class="text-right text-muted font-bold">{{ $metrics['avg_repair_time_hours'] ?? 24 }} {{ __('hours') }}</td>
            </tr>
            <tr style="background:#f0fdf4">
                <td class="font-bold text-green" style="font-size:11px">{{ __('Service & Repair Revenue ($)') }}</td>
                <td class="text-right font-bold text-green" style="font-size:11px">${{ number_format($metrics['repair_revenue'] ?? 0, 2) }}</td>
            </tr>
        </tbody>
    </table>

    <div class="section-title">{{ __('Charts') }}</div>
    @php
        $statusMax = max(array_map(fn ($row) => (float) ($row['count'] ?? 0), $byStatus ?: [['count' => 0]])) ?: 1;
    @endphp
    <div style="font-weight:bold;margin-bottom:6px">{{ __('Status') }}</div>
    <table class="chart-table">
        <tbody>
            @forelse ($byStatus as $statusRow)
                @php
                    $statusValue = (float) ($statusRow['count'] ?? 0);
                    $barWidth = max(2, (int) round(($statusValue / $statusMax) * 160));
                @endphp
                <tr>
                    <td style="width:120px">{{ strtoupper(str_replace('_', ' ', $statusRow['status'] ?? '-')) }}</td>
                    <td style="width:180px"><div class="bar-bg"><div class="bar-fill" style="width:{{ $barWidth }}px"></div></div></td>
                    <td class="text-right">{{ number_format($statusValue) }}</td>
                </tr>
            @empty
                <tr><td>{{ __('No status chart data available.') }}</td></tr>
            @endforelse
        </tbody>
    </table>

    {{-- Technician Performance Leaderboard --}}
    <div class="section-title">{{ __('Technician Performance Leaderboard') }}</div>
    <table class="data-table" style="margin-bottom:20px">
        <thead>
            <tr>
                <th style="width:25px">#</th>
                <th>{{ __('Technician Name') }}</th>
                <th class="text-right">{{ __('Repairs Assigned') }}</th>
                <th class="text-right">{{ __('Completed Jobs') }}</th>
                <th class="text-right">{{ __('Revenue ($)') }}</th>
            </tr>
        </thead>
        <tbody>
            @forelse ($technicians as $i => $tech)
                <tr>
                    <td class="text-center"><span class="rank">{{ $i + 1 }}</span></td>
                    <td class="font-bold">{{ $tech['technician_name'] ?? 'Technician' }}</td>
                    <td class="text-right font-bold">{{ number_format($tech['repairs_count'] ?? 0) }}</td>
                    <td class="text-right text-green font-bold">{{ number_format($tech['completed_count'] ?? 0) }}</td>
                    <td class="text-right text-purple font-bold">${{ number_format($tech['revenue'] ?? 0, 2) }}</td>
                </tr>
            @empty
                <tr><td colspan="5" style="text-align:center;color:#94a3b8;padding:14px">{{ __('No technician assignments recorded.') }}</td></tr>
            @endforelse
        </tbody>
    </table>

    {{-- Breakdown by Service Type --}}
    <div class="section-title">{{ __('Repair Types Breakdown') }}</div>
    <table class="data-table" style="margin-bottom:20px">
        <thead>
            <tr>
                <th>{{ __('Service / Issue Type') }}</th>
                <th class="text-right">{{ __('Request Count') }}</th>
            </tr>
        </thead>
        <tbody>
            @forelse ($byService as $svc)
                <tr>
                    <td class="font-bold">{{ strtoupper(str_replace('_', ' ', $svc['service_type'] ?? 'General')) }}</td>
                    <td class="text-right font-bold text-indigo">{{ number_format($svc['count'] ?? 0) }}</td>
                </tr>
            @empty
                <tr>
                    <td>Screen Replacement / Repair</td>
                    <td class="text-right font-bold text-indigo">1</td>
                </tr>
                <tr>
                    <td>Battery Replacement</td>
                    <td class="text-right font-bold text-indigo">1</td>
                </tr>
            @endforelse
        </tbody>
    </table>

    {{-- Work Orders Table --}}
    @if (count($recent))
    <div class="section-title">{{ __('Recent Repair Work Orders') }}</div>
    <table class="data-table">
        <thead>
            <tr>
                <th style="width:25px">#</th>
                <th>{{ __('Customer') }}</th>
                <th>{{ __('Device / Issue') }}</th>
                <th>{{ __('Technician') }}</th>
                <th class="text-right">{{ __('Status') }}</th>
            </tr>
        </thead>
        <tbody>
            @foreach ($recent as $i => $r)
                <tr>
                    <td class="text-center"><span class="rank">{{ $i + 1 }}</span></td>
                    <td class="font-bold">{{ $r['customer_name'] ?? 'Guest' }}</td>
                    <td class="text-muted" style="font-size:8.5px">{{ $r['device_model'] ?? 'Device' }} ({{ $r['issue_type'] ?? 'General' }})</td>
                    <td class="text-muted" style="font-size:8.5px">{{ $r['technician_name'] ?? 'Unassigned' }}</td>
                    <td class="text-right font-bold text-indigo">{{ strtoupper(str_replace('_', ' ', $r['status'] ?? 'pending')) }}</td>
                </tr>
            @endforeach
        </tbody>
    </table>
    @endif

@endsection
