<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\Product;
use App\Models\User;
use Illuminate\Support\Facades\Gate;

class AdminMetricsController extends Controller
{
    public function __invoke()
    {
        Gate::authorize('admin-access');

        return response()->json([
            'total_sales' => (float) Order::sum('total_amount'),
            'total_orders' => Order::count(),
            'total_products' => Product::count(),
            'total_customers' => User::count(),
            'weekly_sales' => $this->weeklySales(12),
        ]);
    }

    private function weeklySales(int $weeks): array
    {
        $weeks = max(1, $weeks);
        $currentWeekStart = now()->startOfWeek();
        $rangeStart = $currentWeekStart->copy()->subWeeks($weeks - 1)->startOfWeek()->startOfDay();
        $rangeEnd = $currentWeekStart->copy()->endOfWeek()->endOfDay();

        $orders = Order::query()
            ->select(['total_amount', 'placed_at', 'created_at'])
            ->where(function ($query) use ($rangeStart, $rangeEnd) {
                $query->whereBetween('placed_at', [$rangeStart, $rangeEnd])
                    ->orWhere(function ($query) use ($rangeStart, $rangeEnd) {
                        $query->whereNull('placed_at')
                            ->whereBetween('created_at', [$rangeStart, $rangeEnd]);
                    });
            })
            ->get();

        $totalsByWeek = [];
        foreach ($orders as $order) {
            $timestamp = $order->placed_at ?? $order->created_at;
            if (! $timestamp) {
                continue;
            }
            $weekKey = $timestamp->copy()->startOfWeek()->toDateString();
            if (! array_key_exists($weekKey, $totalsByWeek)) {
                $totalsByWeek[$weekKey] = ['total' => 0.0, 'count' => 0];
            }
            $totalsByWeek[$weekKey]['total'] += (float) $order->total_amount;
            $totalsByWeek[$weekKey]['count'] += 1;
        }

        $series = [];
        $cursor = $rangeStart->copy();
        for ($i = 0; $i < $weeks; $i++) {
            $weekStart = $cursor->copy()->startOfWeek();
            $weekEnd = $cursor->copy()->endOfWeek();
            $weekKey = $weekStart->toDateString();
            $weekTotal = $totalsByWeek[$weekKey]['total'] ?? 0.0;
            $weekCount = $totalsByWeek[$weekKey]['count'] ?? 0;
            $series[] = [
                'week_start' => $weekStart->toDateString(),
                'week_end' => $weekEnd->toDateString(),
                'label' => $weekStart->format('M j'),
                'total' => round($weekTotal, 2),
                'order_count' => $weekCount,
            ];
            $cursor->addWeek();
        }

        return $series;
    }
}
