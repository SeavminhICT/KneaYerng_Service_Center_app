@php
    $metrics       = $report['metrics']        ?? [];
    $byStatus      = $report['by_status']      ?? [];
    $byServiceType = $report['by_service_type'] ?? [];
    $recent        = $report['recent']          ?? [];
    $total         = (int) ($metrics['total_requests'] ?? 0);
    $completed     = (int) ($metrics['completed']      ?? 0);
    $inProgress    = (int) ($metrics['in_progress']    ?? 0);
    $completionRate = $total > 0 ? round($completed / $total * 100, 1) : 0;
    $reportType    = __('Repair Requests Report');
    $rangeLabel    = $rangeLabel ?? '';

    $statusColors = [
        'received'         => 'badge-blue',
        'diagnosing'       => 'badge-purple',
        'waiting_approval' => 'badge-amber',
        'in_repair'        => 'badge-amber',
        'qc'               => 'badge-purple',
        'ready'            => 'badge-green',
        'completed'        => 'badge-green',
    ];
    $serviceLabels = [
        'drop_off' => __('Drop-off'),
        'pickup'   => __('Pickup'),
        'on_site'  => __('On-site'),
    ];
@endphp
@extends('admin.reports.pdf._layout')

@section('body')

    {{-- ── KPI Row ── --}}
    <div class="section-title">{{ __('Key Metrics') }}</div>
    <table class="kpi-table">
        <tr>
            <td class="kpi-cell">
                <div class="kpi-label">{{ __('Total Requests') }}</div>
                <div class="kpi-value kpi-accent">{{ number_format($total) }}</div>
            </td>
            <td class="kpi-cell">
                <div class="kpi-label">{{ __('Completed') }}</div>
                <div class="kpi-value kpi-green">{{ number_format($completed) }}</div>
            </td>
            <td class="kpi-cell">
                <div class="kpi-label">{{ __('In Progress') }}</div>
                <div class="kpi-value kpi-amber">{{ number_format($inProgress) }}</div>
            </td>
            <td class="kpi-cell">
                <div class="kpi-label">{{ __('Completion Rate') }}</div>
                <div class="kpi-value {{ $completionRate >= 70 ? 'kpi-green' : ($completionRate >= 40 ? 'kpi-amber' : 'kpi-red') }}">{{ $completionRate }}%</div>
            </td>
        </tr>
    </table>

    {{-- ── Status breakdown + Service type ── --}}
    <table class="two-col" style="margin-bottom:18px">
        <tr>
            <td>
                <div class="section-title">{{ __('Requests by Status') }}</div>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>{{ __('Status') }}</th>
                            <th class="text-right">{{ __('Count') }}</th>
                            <th class="text-right">{{ __('Share') }}</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse ($byStatus as $row)
                            @php
                                $badgeClass = $statusColors[$row['status']] ?? 'badge-slate';
                                $share = $total > 0 ? round($row['count'] / $total * 100, 1) : 0;
                                $label = ucfirst(str_replace('_', ' ', $row['status']));
                            @endphp
                            <tr>
                                <td><span class="badge {{ $badgeClass }}">{{ $label }}</span></td>
                                <td class="text-right font-bold">{{ $row['count'] }}</td>
                                <td class="text-right text-muted">{{ $share }}%</td>
                            </tr>
                        @empty
                            <tr><td colspan="3" style="text-align:center;color:#94a3b8;padding:12px">{{ __('No data') }}</td></tr>
                        @endforelse
                    </tbody>
                    <tfoot>
                        <tr>
                            <td>{{ __('Total') }}</td>
                            <td class="text-right">{{ $total }}</td>
                            <td class="text-right">100%</td>
                        </tr>
                    </tfoot>
                </table>
            </td>
            <td>
                <div class="section-title">{{ __('Requests by Service Type') }}</div>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>{{ __('Service Type') }}</th>
                            <th class="text-right">{{ __('Count') }}</th>
                            <th class="text-right">{{ __('Share') }}</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse ($byServiceType as $row)
                            @php
                                $share = $total > 0 ? round($row['count'] / $total * 100, 1) : 0;
                                $label = $serviceLabels[$row['service_type']] ?? ucfirst(str_replace('_', ' ', $row['service_type']));
                            @endphp
                            <tr>
                                <td><span class="badge badge-slate">{{ $label }}</span></td>
                                <td class="text-right font-bold">{{ $row['count'] }}</td>
                                <td class="text-right text-muted">{{ $share }}%</td>
                            </tr>
                        @empty
                            <tr><td colspan="3" style="text-align:center;color:#94a3b8;padding:12px">{{ __('No data') }}</td></tr>
                        @endforelse
                    </tbody>
                    <tfoot>
                        <tr>
                            <td>{{ __('Total') }}</td>
                            <td class="text-right">{{ $total }}</td>
                            <td class="text-right">100%</td>
                        </tr>
                    </tfoot>
                </table>
            </td>
        </tr>
    </table>

    {{-- ── Recent Requests ── --}}
    <div class="section-title">{{ __('Recent Repair Requests') }}</div>
    <table class="data-table">
        <thead>
            <tr>
                <th style="width:30px">#</th>
                <th>{{ __('Customer') }}</th>
                <th>{{ __('Device / Issue') }}</th>
                <th>{{ __('Service') }}</th>
                <th>{{ __('Technician') }}</th>
                <th class="text-center">{{ __('Status') }}</th>
                <th class="text-right">{{ __('Date') }}</th>
            </tr>
        </thead>
        <tbody>
            @forelse ($recent as $i => $r)
                @php
                    $badgeClass  = $statusColors[$r['status']] ?? 'badge-slate';
                    $statusLabel = ucfirst(str_replace('_', ' ', $r['status']));
                    $svcLabel    = $serviceLabels[$r['service_type']] ?? ucfirst(str_replace('_', ' ', $r['service_type']));
                    $date        = $r['created_at'] ? \Carbon\Carbon::parse($r['created_at'])->format('d M Y') : '—';
                @endphp
                <tr>
                    <td class="text-center"><span class="rank">{{ $i + 1 }}</span></td>
                    <td class="font-bold">{{ $r['customer_name'] ?? '—' }}</td>
                    <td class="text-muted">{{ ($r['device_model'] ?? '—') . ' / ' . ($r['issue_type'] ?? '—') }}</td>
                    <td><span class="badge badge-slate">{{ $svcLabel }}</span></td>
                    <td class="text-muted">{{ $r['technician_name'] ?? '—' }}</td>
                    <td class="text-center"><span class="badge {{ $badgeClass }}">{{ $statusLabel }}</span></td>
                    <td class="text-right text-muted">{{ $date }}</td>
                </tr>
            @empty
                <tr><td colspan="7" style="text-align:center;color:#94a3b8;padding:14px">{{ __('No repair requests for this period.') }}</td></tr>
            @endforelse
        </tbody>
    </table>

@endsection
