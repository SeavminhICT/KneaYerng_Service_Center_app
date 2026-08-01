<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\Product;
use App\Models\User;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

class AdminMetricsController extends Controller
{
    public function __invoke(Request $request)
    {
        [$start, $end, $label, $preset] = $this->resolveRange($request);

        if ($start === null) {
            $totalSales = (float) Order::sum('total_amount');
            $totalOrders = Order::count();
        } else {
            $ordersQuery = $this->ordersInRangeQuery($start, $end);
            $totalSales = (float) (clone $ordersQuery)->sum('total_amount');
            $totalOrders = (clone $ordersQuery)->count();
        }

        return response()->json([
            'range' => [
                'preset' => $preset,
                'label' => $label,
                'start' => $start?->toDateString(),
                'end' => $end->toDateString(),
            ],
            'total_sales' => $totalSales,
            'total_orders' => $totalOrders,
            'total_products' => Product::count(),
            'total_customers' => User::count(),
            'sales_series' => $this->salesSeries($start, $end),
        ]);
    }

    private function resolveRange(Request $request): array
    {
        $preset = (string) $request->query('range', 'all');
        $now = now();

        if ($preset === 'custom') {
            $startInput = $request->query('start_date');
            $endInput = $request->query('end_date');

            try {
                $start = $startInput ? Carbon::parse($startInput)->startOfDay() : $now->copy()->subDays(6)->startOfDay();
                $end = $endInput ? Carbon::parse($endInput)->endOfDay() : $now->copy()->endOfDay();
            } catch (\Throwable $exception) {
                $start = $now->copy()->subDays(6)->startOfDay();
                $end = $now->copy()->endOfDay();
            }

            if ($start->greaterThan($end)) {
                [$start, $end] = [$end->copy()->startOfDay(), $start->copy()->endOfDay()];
            }

            return [$start, $end, $start->toDateString().' - '.$end->toDateString(), 'custom'];
        }

        $end = $now->copy()->endOfDay();

        switch ($preset) {
            case 'today':
                $start = $now->copy()->startOfDay();
                $label = 'Today';
                break;
            case 'yesterday':
                $start = $now->copy()->subDay()->startOfDay();
                $end = $now->copy()->subDay()->endOfDay();
                $label = 'Yesterday';
                break;
            case '7_days':
                $start = $now->copy()->subDays(6)->startOfDay();
                $label = 'Last 7 days';
                break;
            case '1_month':
                $start = $now->copy()->subMonthNoOverflow()->startOfDay();
                $label = 'Last 1 month';
                break;
            case '2_months':
                $start = $now->copy()->subMonthsNoOverflow(2)->startOfDay();
                $label = 'Last 2 months';
                break;
            case '3_months':
                $start = $now->copy()->subMonthsNoOverflow(3)->startOfDay();
                $label = 'Last 3 months';
                break;
            case '6_months':
                $start = $now->copy()->subMonthsNoOverflow(6)->startOfDay();
                $label = 'Last 6 months';
                break;
            case '1_year':
                $start = $now->copy()->subYearNoOverflow()->startOfDay();
                $label = 'Last 1 year';
                break;
            case 'all':
            default:
                $start = null;
                $label = 'All time';
                $preset = 'all';
                break;
        }

        return [$start, $end, $label, $preset];
    }

    private function ordersInRangeQuery(Carbon $start, Carbon $end): Builder
    {
        return Order::query()->where(function (Builder $query) use ($start, $end) {
            $query->whereBetween('placed_at', [$start, $end])
                ->orWhere(function (Builder $inner) use ($start, $end) {
                    $inner->whereNull('placed_at')
                        ->whereBetween('created_at', [$start, $end]);
                });
        });
    }

    private function salesSeries(?Carbon $start, Carbon $end): array
    {
        $seriesStart = $start ? $start->copy() : $this->earliestOrderDate($end);
        $totalDays = max(1, $seriesStart->diffInDays($end) + 1);

        if ($totalDays <= 2) {
            $unit = 'hour';
        } elseif ($totalDays <= 64) {
            $unit = 'day';
        } elseif ($totalDays <= 200) {
            $unit = 'week';
        } else {
            $unit = 'month';
        }

        $orders = Order::query()
            ->select(['total_amount', 'placed_at', 'created_at'])
            ->where(function (Builder $query) use ($seriesStart, $end) {
                $query->whereBetween('placed_at', [$seriesStart, $end])
                    ->orWhere(function (Builder $inner) use ($seriesStart, $end) {
                        $inner->whereNull('placed_at')
                            ->whereBetween('created_at', [$seriesStart, $end]);
                    });
            })
            ->get();

        $totalsByBucket = [];
        foreach ($orders as $order) {
            $timestamp = $order->placed_at ?? $order->created_at;
            if (! $timestamp) {
                continue;
            }
            $key = $this->bucketKey($timestamp, $unit);
            if (! array_key_exists($key, $totalsByBucket)) {
                $totalsByBucket[$key] = ['total' => 0.0, 'count' => 0];
            }
            $totalsByBucket[$key]['total'] += (float) $order->total_amount;
            $totalsByBucket[$key]['count'] += 1;
        }

        $series = [];
        $cursor = $this->bucketStart($seriesStart, $unit);

        while ($cursor->lessThanOrEqualTo($end)) {
            $key = $this->bucketKey($cursor, $unit);
            $bucket = $totalsByBucket[$key] ?? ['total' => 0.0, 'count' => 0];

            $series[] = [
                'label' => $this->bucketLabel($cursor, $unit),
                'total' => round($bucket['total'], 2),
                'order_count' => $bucket['count'],
            ];

            $cursor = $this->advanceBucket($cursor, $unit);

            if (count($series) >= 366) {
                break;
            }
        }

        return $series;
    }

    private function earliestOrderDate(Carbon $end): Carbon
    {
        $earliest = Order::query()->whereNotNull('placed_at')->min('placed_at')
            ?? Order::query()->min('created_at');

        if (! $earliest) {
            return $end->copy()->subWeeks(11)->startOfWeek();
        }

        $earliest = Carbon::parse($earliest)->startOfDay();

        return $earliest->greaterThan($end) ? $end->copy() : $earliest;
    }

    private function bucketStart(Carbon $moment, string $unit): Carbon
    {
        return match ($unit) {
            'hour' => $moment->copy()->startOfHour(),
            'day' => $moment->copy()->startOfDay(),
            'week' => $moment->copy()->startOfWeek(),
            default => $moment->copy()->startOfMonth(),
        };
    }

    private function bucketKey(Carbon $moment, string $unit): string
    {
        return match ($unit) {
            'hour' => $moment->copy()->startOfHour()->toDateTimeString(),
            'day' => $moment->copy()->startOfDay()->toDateString(),
            'week' => $moment->copy()->startOfWeek()->toDateString(),
            default => $moment->copy()->startOfMonth()->toDateString(),
        };
    }

    private function bucketLabel(Carbon $bucketStart, string $unit): string
    {
        return match ($unit) {
            'hour' => $bucketStart->format('g A'),
            'day' => $bucketStart->format('M j'),
            'week' => $bucketStart->format('M j'),
            default => $bucketStart->format('M Y'),
        };
    }

    private function advanceBucket(Carbon $bucketStart, string $unit): Carbon
    {
        return match ($unit) {
            'hour' => $bucketStart->copy()->addHour(),
            'day' => $bucketStart->copy()->addDay(),
            'week' => $bucketStart->copy()->addWeek(),
            default => $bucketStart->copy()->addMonthNoOverflow(),
        };
    }
}
