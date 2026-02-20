<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Accessory;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Part;
use App\Models\Product;
use App\Models\User;
use App\Support\Reports\SimplePdf;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class AdminReportsController extends Controller
{
    public function sales(Request $request)
    {
        Gate::authorize('admin-access');

        [$start, $end, $label, $preset] = $this->resolveRange($request);
        $report = $this->buildSalesReport($start, $end);

        return response()->json([
            'range' => $this->rangePayload($start, $end, $label, $preset),
            'metrics' => $report['metrics'],
            'top_items' => $report['top_items'],
            'daily' => $report['daily'],
        ]);
    }

    public function inventory(Request $request)
    {
        Gate::authorize('admin-access');

        [$start, $end, $label, $preset] = $this->resolveRange($request);
        $threshold = $this->resolveThreshold($request);
        $report = $this->buildInventoryReport($start, $end, $threshold);

        return response()->json([
            'range' => $this->rangePayload($start, $end, $label, $preset),
            'threshold' => $threshold,
            'metrics' => $report['metrics'],
            'low_stock' => $report['low_stock'],
            'top_movers' => $report['top_movers'],
        ]);
    }

    public function customers(Request $request)
    {
        Gate::authorize('admin-access');

        [$start, $end, $label, $preset] = $this->resolveRange($request);
        $report = $this->buildCustomerReport($start, $end);

        return response()->json([
            'range' => $this->rangePayload($start, $end, $label, $preset),
            'metrics' => $report['metrics'],
            'top_customers' => $report['top_customers'],
        ]);
    }

    public function export(Request $request)
    {
        Gate::authorize('admin-access');

        $validated = $request->validate([
            'type' => ['required', 'string', 'in:sales,inventory,customers'],
            'format' => ['required', 'string', 'in:csv,pdf'],
            'preset' => ['nullable', 'string'],
            'start' => ['nullable', 'date_format:Y-m-d'],
            'end' => ['nullable', 'date_format:Y-m-d'],
            'threshold' => ['nullable', 'integer', 'min:0', 'max:1000'],
        ]);

        [$start, $end, $label, $preset] = $this->resolveRange($request);
        $type = $validated['type'];
        $format = $validated['format'];
        $threshold = $this->resolveThreshold($request);

        $content = '';
        $rowCount = 0;
        $fileBase = "{$type}-report-{$start->format('Ymd')}-{$end->format('Ymd')}";

        if ($format === 'csv') {
            if ($type === 'sales') {
                [$content, $rowCount] = $this->buildSalesCsv($start, $end);
            } elseif ($type === 'inventory') {
                [$content, $rowCount] = $this->buildInventoryCsv($threshold);
            } else {
                [$content, $rowCount] = $this->buildCustomerCsv($start, $end);
            }
        } else {
            $content = $this->buildPdf($type, $start, $end, $threshold);
            $rowCount = 0;
        }

        $disk = Storage::disk('local');
        $disk->makeDirectory('reports');

        $id = (string) Str::uuid();
        $path = "reports/{$id}.{$format}";
        $fileName = "{$fileBase}.{$format}";
        $disk->put($path, $content);

        $export = [
            'id' => $id,
            'type' => $type,
            'format' => $format,
            'filename' => $fileName,
            'path' => $path,
            'row_count' => $rowCount,
            'range' => $this->rangePayload($start, $end, $label, $preset),
            'generated_at' => now()->toDateTimeString(),
            'threshold' => $threshold,
        ];

        $this->storeExport($export);

        return response()->json([
            'export' => $export,
            'download_url' => url('/api/admin/reports/exports/'.$id),
        ]);
    }

    public function exports()
    {
        Gate::authorize('admin-access');

        $disk = Storage::disk('local');
        $exports = [];

        foreach ($this->readExports() as $export) {
            if (! isset($export['id'], $export['path'])) {
                continue;
            }
            if (! $disk->exists($export['path'])) {
                continue;
            }
            $export['size'] = $disk->size($export['path']);
            $export['download_url'] = url('/api/admin/reports/exports/'.$export['id']);
            $exports[] = $export;
        }

        if (count($exports) !== count($this->readExports())) {
            $this->writeExports($exports);
        }

        return response()->json([
            'exports' => $exports,
        ]);
    }

    public function download(string $exportId)
    {
        Gate::authorize('admin-access');

        $export = $this->findExport($exportId);
        if (! $export) {
            return response()->json(['message' => 'Export not found.'], 404);
        }

        $disk = Storage::disk('local');
        if (! $disk->exists($export['path'])) {
            return response()->json(['message' => 'Export file missing.'], 404);
        }

        $headers = [
            'Content-Type' => $export['format'] === 'pdf' ? 'application/pdf' : 'text/csv',
        ];

        return $disk->download($export['path'], $export['filename'] ?? basename($export['path']), $headers);
    }

    private function buildSalesReport(Carbon $start, Carbon $end): array
    {
        $metricsQuery = Order::query();
        $this->applyOrderRange($metricsQuery, $start, $end);

        $summary = $metricsQuery->selectRaw('
            COALESCE(SUM(total_amount), 0) as total_sales,
            COUNT(*) as total_orders,
            SUM(CASE WHEN payment_status = "paid" THEN 1 ELSE 0 END) as paid_orders,
            SUM(CASE WHEN payment_status = "unpaid" THEN 1 ELSE 0 END) as unpaid_orders,
            SUM(CASE WHEN payment_status = "failed" THEN 1 ELSE 0 END) as failed_orders
        ')->first();

        $totalSales = (float) ($summary->total_sales ?? 0);
        $totalOrders = (int) ($summary->total_orders ?? 0);
        $averageOrderValue = $totalOrders > 0 ? round($totalSales / $totalOrders, 2) : 0;

        $dailyQuery = Order::query();
        $this->applyOrderRange($dailyQuery, $start, $end);
        $daily = $dailyQuery
            ->selectRaw('DATE(COALESCE(placed_at, created_at)) as day, COALESCE(SUM(total_amount), 0) as total, COUNT(*) as count')
            ->groupBy('day')
            ->orderBy('day')
            ->get()
            ->map(function ($row) {
                return [
                    'day' => $row->day,
                    'total' => (float) $row->total,
                    'count' => (int) $row->count,
                ];
            })
            ->values()
            ->all();

        $topItems = $this->queryTopItems($start, $end, 5, 'sales');

        return [
            'metrics' => [
                'total_sales' => $totalSales,
                'total_orders' => $totalOrders,
                'average_order_value' => (float) $averageOrderValue,
                'paid_orders' => (int) ($summary->paid_orders ?? 0),
                'unpaid_orders' => (int) ($summary->unpaid_orders ?? 0),
                'failed_orders' => (int) ($summary->failed_orders ?? 0),
            ],
            'daily' => $daily,
            'top_items' => $topItems,
        ];
    }

    private function buildInventoryReport(Carbon $start, Carbon $end, int $threshold): array
    {
        $productCount = Product::count();
        $accessoryCount = Accessory::count();
        $partCount = Part::count();
        $stockUnits = (int) Product::sum('stock') + (int) Accessory::sum('stock') + (int) Part::sum('stock');

        $lowProducts = Product::query()
            ->select(['id', 'name', 'stock', 'sku', 'status', 'price'])
            ->where('stock', '<=', $threshold)
            ->orderBy('stock')
            ->limit(5)
            ->get()
            ->map(function (Product $product) {
                return [
                    'type' => 'product',
                    'name' => $product->name,
                    'sku' => $product->sku,
                    'stock' => (int) ($product->stock ?? 0),
                ];
            });

        $lowAccessories = Accessory::query()
            ->select(['id', 'name', 'stock'])
            ->where('stock', '<=', $threshold)
            ->orderBy('stock')
            ->limit(5)
            ->get()
            ->map(function (Accessory $accessory) {
                return [
                    'type' => 'accessory',
                    'name' => $accessory->name,
                    'sku' => null,
                    'stock' => (int) ($accessory->stock ?? 0),
                ];
            });

        $lowParts = Part::query()
            ->select(['id', 'name', 'stock', 'sku'])
            ->where('stock', '<=', $threshold)
            ->orderBy('stock')
            ->limit(5)
            ->get()
            ->map(function (Part $part) {
                return [
                    'type' => 'part',
                    'name' => $part->name,
                    'sku' => $part->sku,
                    'stock' => (int) ($part->stock ?? 0),
                ];
            });

        $lowStock = $lowProducts
            ->merge($lowAccessories)
            ->merge($lowParts)
            ->sortBy('stock')
            ->values()
            ->take(10)
            ->all();

        $topMovers = $this->queryTopItems($start, $end, 5, 'quantity');

        return [
            'metrics' => [
                'total_products' => $productCount,
                'total_accessories' => $accessoryCount,
                'total_parts' => $partCount,
                'stock_units' => $stockUnits,
                'low_stock_count' => count($lowStock),
            ],
            'low_stock' => $lowStock,
            'top_movers' => $topMovers,
        ];
    }

    private function buildCustomerReport(Carbon $start, Carbon $end): array
    {
        $baseQuery = $this->customerBaseQuery();
        $totalCustomers = (clone $baseQuery)->count();
        $newCustomers = (clone $baseQuery)->whereBetween('created_at', [$start, $end])->count();
        $activeCustomers = (clone $baseQuery)->whereHas('orders', function (Builder $query) use ($start, $end) {
            $this->applyOrderRange($query, $start, $end);
        })->count();

        $repeatCustomers = (clone $baseQuery)
            ->withCount(['orders as orders_in_range' => function (Builder $query) use ($start, $end) {
                $this->applyOrderRange($query, $start, $end);
            }])
            ->having('orders_in_range', '>=', 2)
            ->count();

        $topCustomers = $this->queryTopCustomers($start, $end, 5);

        return [
            'metrics' => [
                'total_customers' => $totalCustomers,
                'new_customers' => $newCustomers,
                'active_customers' => $activeCustomers,
                'repeat_customers' => $repeatCustomers,
            ],
            'top_customers' => $topCustomers,
        ];
    }

    private function buildSalesCsv(Carbon $start, Carbon $end): array
    {
        $handle = fopen('php://temp', 'w+');
        fputcsv($handle, [
            'Order Number',
            'Customer Name',
            'Customer Email',
            'Order Type',
            'Payment Method',
            'Subtotal',
            'Delivery Fee',
            'Discount Amount',
            'Total Amount',
            'Payment Status',
            'Status',
            'Placed At',
        ]);

        $rowCount = 0;
        $query = Order::query();
        $this->applyOrderRange($query, $start, $end);
        $query->orderByDesc('placed_at')->orderByDesc('id');

        $query->select([
            'order_number',
            'customer_name',
            'customer_email',
            'order_type',
            'payment_method',
            'subtotal',
            'delivery_fee',
            'discount_amount',
            'total_amount',
            'payment_status',
            'status',
            'placed_at',
            'created_at',
        ])->chunk(500, function ($orders) use ($handle, &$rowCount) {
            foreach ($orders as $order) {
                $timestamp = $order->placed_at ?? $order->created_at;
                fputcsv($handle, [
                    $order->order_number,
                    $order->customer_name,
                    $order->customer_email,
                    $order->order_type,
                    $order->payment_method,
                    $order->subtotal,
                    $order->delivery_fee,
                    $order->discount_amount,
                    $order->total_amount,
                    $order->payment_status,
                    $order->status,
                    $timestamp ? $timestamp->toDateTimeString() : null,
                ]);
                $rowCount += 1;
            }
        });

        rewind($handle);
        $content = stream_get_contents($handle);
        fclose($handle);

        return [$content, $rowCount];
    }

    private function buildInventoryCsv(int $threshold): array
    {
        $handle = fopen('php://temp', 'w+');
        fputcsv($handle, [
            'Item Type',
            'Name',
            'SKU',
            'Stock',
            'Status',
            'Unit Price',
        ]);

        $rowCount = 0;

        Product::query()
            ->select(['name', 'sku', 'stock', 'status', 'price'])
            ->orderBy('name')
            ->chunk(500, function ($products) use ($handle, &$rowCount) {
                foreach ($products as $product) {
                    fputcsv($handle, [
                        'product',
                        $product->name,
                        $product->sku,
                        $product->stock,
                        $product->status,
                        $product->price,
                    ]);
                    $rowCount += 1;
                }
            });

        Accessory::query()
            ->select(['name', 'stock', 'price'])
            ->orderBy('name')
            ->chunk(500, function ($accessories) use ($handle, &$rowCount) {
                foreach ($accessories as $accessory) {
                    fputcsv($handle, [
                        'accessory',
                        $accessory->name,
                        null,
                        $accessory->stock,
                        null,
                        $accessory->price,
                    ]);
                    $rowCount += 1;
                }
            });

        Part::query()
            ->select(['name', 'sku', 'stock', 'status', 'unit_cost'])
            ->orderBy('name')
            ->chunk(500, function ($parts) use ($handle, &$rowCount) {
                foreach ($parts as $part) {
                    fputcsv($handle, [
                        'part',
                        $part->name,
                        $part->sku,
                        $part->stock,
                        $part->status,
                        $part->unit_cost,
                    ]);
                    $rowCount += 1;
                }
            });

        rewind($handle);
        $content = stream_get_contents($handle);
        fclose($handle);

        return [$content, $rowCount];
    }

    private function buildCustomerCsv(Carbon $start, Carbon $end): array
    {
        $handle = fopen('php://temp', 'w+');
        fputcsv($handle, [
            'Customer Name',
            'Email',
            'Phone',
            'Orders Count',
            'Total Spent',
        ]);

        $rowCount = 0;
        $query = $this->customerOrdersQuery($start, $end);

        $query->orderByDesc('total_spent')->chunk(500, function ($customers) use ($handle, &$rowCount) {
            foreach ($customers as $customer) {
                $name = trim(($customer->first_name ?? '').' '.($customer->last_name ?? ''));
                fputcsv($handle, [
                    $name !== '' ? $name : 'Customer',
                    $customer->email,
                    $customer->phone,
                    $customer->orders_count,
                    $customer->total_spent,
                ]);
                $rowCount += 1;
            }
        });

        rewind($handle);
        $content = stream_get_contents($handle);
        fclose($handle);

        return [$content, $rowCount];
    }

    private function buildPdf(string $type, Carbon $start, Carbon $end, int $threshold): string
    {
        if ($type === 'sales') {
            $report = $this->buildSalesReport($start, $end);
            $lines = [
                'Sales Report',
                'Range: '.$start->toDateString().' to '.$end->toDateString(),
                'Total Sales: '.number_format($report['metrics']['total_sales'], 2),
                'Total Orders: '.$report['metrics']['total_orders'],
                'Average Order Value: '.number_format($report['metrics']['average_order_value'], 2),
                'Paid Orders: '.$report['metrics']['paid_orders'],
                'Unpaid Orders: '.$report['metrics']['unpaid_orders'],
                'Failed Orders: '.$report['metrics']['failed_orders'],
                '',
                'Top Items',
            ];

            foreach ($report['top_items'] as $index => $item) {
                $lines[] = ($index + 1).'. '.$item['name'].' ('.$item['item_type'].') - Qty '.$item['quantity'].', Sales '.number_format($item['sales'], 2);
            }

            return SimplePdf::fromLines($lines);
        }

        if ($type === 'inventory') {
            $report = $this->buildInventoryReport($start, $end, $threshold);
            $lines = [
                'Inventory Report',
                'Range: '.$start->toDateString().' to '.$end->toDateString(),
                'Total Products: '.$report['metrics']['total_products'],
                'Total Accessories: '.$report['metrics']['total_accessories'],
                'Total Parts: '.$report['metrics']['total_parts'],
                'Stock Units: '.$report['metrics']['stock_units'],
                'Low Stock Threshold: '.$threshold,
                '',
                'Low Stock Items',
            ];

            foreach ($report['low_stock'] as $index => $item) {
                $lines[] = ($index + 1).'. '.$item['name'].' ('.$item['type'].') - Stock '.$item['stock'];
            }

            $lines[] = '';
            $lines[] = 'Top Movers';
            foreach ($report['top_movers'] as $index => $item) {
                $lines[] = ($index + 1).'. '.$item['name'].' ('.$item['item_type'].') - Qty '.$item['quantity'];
            }

            return SimplePdf::fromLines($lines);
        }

        $report = $this->buildCustomerReport($start, $end);
        $lines = [
            'Customer Report',
            'Range: '.$start->toDateString().' to '.$end->toDateString(),
            'Total Customers: '.$report['metrics']['total_customers'],
            'New Customers: '.$report['metrics']['new_customers'],
            'Active Customers: '.$report['metrics']['active_customers'],
            'Repeat Customers: '.$report['metrics']['repeat_customers'],
            '',
            'Top Customers',
        ];

        foreach ($report['top_customers'] as $index => $customer) {
            $lines[] = ($index + 1).'. '.$customer['name'].' - Orders '.$customer['orders_count'].', Spent '.number_format($customer['total_spent'], 2);
        }

        return SimplePdf::fromLines($lines);
    }

    private function queryTopItems(Carbon $start, Carbon $end, int $limit, string $orderBy): array
    {
        $query = OrderItem::query()
            ->join('orders', 'orders.id', '=', 'order_items.order_id')
            ->select([
                'order_items.item_type',
                'order_items.item_id',
                'order_items.product_name',
                DB::raw('SUM(order_items.quantity) as quantity'),
                DB::raw('COALESCE(SUM(order_items.line_total), 0) as sales'),
            ]);

        $this->applyOrderRange($query, $start, $end, 'orders');

        $query->groupBy('order_items.item_type', 'order_items.item_id', 'order_items.product_name');

        if ($orderBy === 'quantity') {
            $query->orderByDesc('quantity');
        } else {
            $query->orderByDesc('sales');
        }

        return $query->limit($limit)
            ->get()
            ->map(function ($row) {
                return [
                    'item_type' => $row->item_type ?? 'product',
                    'item_id' => $row->item_id,
                    'name' => $row->product_name,
                    'quantity' => (int) $row->quantity,
                    'sales' => (float) $row->sales,
                ];
            })
            ->values()
            ->all();
    }

    private function queryTopCustomers(Carbon $start, Carbon $end, int $limit): array
    {
        $query = $this->customerOrdersQuery($start, $end);
        $query->orderByDesc('total_spent')->limit($limit);

        return $query->get()
            ->map(function ($row) {
                $name = trim(($row->first_name ?? '').' '.($row->last_name ?? ''));
                return [
                    'id' => $row->id,
                    'name' => $name !== '' ? $name : 'Customer',
                    'email' => $row->email,
                    'phone' => $row->phone,
                    'orders_count' => (int) $row->orders_count,
                    'total_spent' => (float) $row->total_spent,
                ];
            })
            ->values()
            ->all();
    }

    private function customerOrdersQuery(Carbon $start, Carbon $end): Builder
    {
        $adminEmails = (array) config('auth.admin_emails', []);

        $query = Order::query()
            ->join('users', 'orders.user_id', '=', 'users.id')
            ->whereNotNull('orders.user_id')
            ->where(function (Builder $builder) {
                $builder->whereNull('users.is_admin')
                    ->orWhere('users.is_admin', false);
            })
            ->where(function (Builder $builder) {
                $builder->whereNull('users.role')
                    ->orWhere('users.role', '!=', 'admin');
            })
            ->select([
                'users.id',
                'users.first_name',
                'users.last_name',
                'users.email',
                'users.phone',
                DB::raw('COUNT(*) as orders_count'),
                DB::raw('COALESCE(SUM(orders.total_amount), 0) as total_spent'),
            ]);

        if (! empty($adminEmails)) {
            $query->whereNotIn('users.email', $adminEmails);
        }

        $this->applyOrderRange($query, $start, $end, 'orders');

        $query->groupBy('users.id', 'users.first_name', 'users.last_name', 'users.email', 'users.phone');

        return $query;
    }

    private function resolveRange(Request $request): array
    {
        $timezone = config('app.timezone') ?: 'UTC';
        $preset = (string) $request->input('preset', 'last_30_days');
        $startInput = $request->input('start');
        $endInput = $request->input('end');

        if ($startInput && $endInput) {
            try {
                $start = Carbon::createFromFormat('Y-m-d', $startInput, $timezone)->startOfDay();
                $end = Carbon::createFromFormat('Y-m-d', $endInput, $timezone)->endOfDay();
                if ($end->lessThan($start)) {
                    [$start, $end] = [$end->copy()->startOfDay(), $start->copy()->endOfDay()];
                }
                return [$start, $end, $start->toDateString().' to '.$end->toDateString(), 'custom'];
            } catch (\Throwable $exception) {
                // fallback to preset
            }
        }

        $now = now($timezone);
        switch ($preset) {
            case 'last_7_days':
                $start = $now->copy()->subDays(6)->startOfDay();
                $end = $now->copy()->endOfDay();
                $label = 'Last 7 days';
                break;
            case 'last_90_days':
                $start = $now->copy()->subDays(89)->startOfDay();
                $end = $now->copy()->endOfDay();
                $label = 'Last 90 days';
                break;
            case 'this_month':
                $start = $now->copy()->startOfMonth();
                $end = $now->copy()->endOfDay();
                $label = 'This month';
                break;
            case 'last_month':
                $start = $now->copy()->subMonthNoOverflow()->startOfMonth();
                $end = $now->copy()->subMonthNoOverflow()->endOfMonth();
                $label = 'Last month';
                break;
            case 'year_to_date':
                $start = $now->copy()->startOfYear();
                $end = $now->copy()->endOfDay();
                $label = 'Year to date';
                break;
            default:
                $start = $now->copy()->subDays(29)->startOfDay();
                $end = $now->copy()->endOfDay();
                $label = 'Last 30 days';
                $preset = 'last_30_days';
                break;
        }

        return [$start, $end, $label, $preset];
    }

    private function resolveThreshold(Request $request): int
    {
        return max(0, (int) $request->input('threshold', 10));
    }

    private function applyOrderRange(Builder $query, Carbon $start, Carbon $end, string $table = 'orders'): void
    {
        $query->where(function (Builder $builder) use ($start, $end, $table) {
            $builder->whereBetween("{$table}.placed_at", [$start, $end])
                ->orWhere(function (Builder $inner) use ($start, $end, $table) {
                    $inner->whereNull("{$table}.placed_at")
                        ->whereBetween("{$table}.created_at", [$start, $end]);
                });
        });
    }

    private function customerBaseQuery(): Builder
    {
        $adminEmails = (array) config('auth.admin_emails', []);

        $query = User::query()
            ->where(function (Builder $builder) {
                $builder->whereNull('is_admin')
                    ->orWhere('is_admin', false);
            })
            ->where(function (Builder $builder) {
                $builder->whereNull('role')
                    ->orWhere('role', '!=', 'admin');
            });

        if (! empty($adminEmails)) {
            $query->whereNotIn('email', $adminEmails);
        }

        return $query;
    }

    private function rangePayload(Carbon $start, Carbon $end, string $label, string $preset): array
    {
        return [
            'start' => $start->toDateString(),
            'end' => $end->toDateString(),
            'label' => $label,
            'preset' => $preset,
        ];
    }

    private function exportsIndexPath(): string
    {
        return Storage::disk('local')->path('reports/exports.json');
    }

    private function readExports(): array
    {
        $path = $this->exportsIndexPath();
        if (! file_exists($path)) {
            return [];
        }

        $raw = file_get_contents($path);
        if ($raw === false) {
            return [];
        }

        $data = json_decode($raw, true);
        return is_array($data) ? $data : [];
    }

    private function writeExports(array $exports): void
    {
        $path = $this->exportsIndexPath();
        $directory = dirname($path);
        if (! is_dir($directory)) {
            mkdir($directory, 0755, true);
        }

        file_put_contents($path, json_encode(array_values($exports), JSON_PRETTY_PRINT), LOCK_EX);
    }

    private function storeExport(array $export): void
    {
        $exports = $this->readExports();
        array_unshift($exports, $export);
        $exports = array_slice($exports, 0, 20);
        $this->writeExports($exports);
    }

    private function findExport(string $exportId): ?array
    {
        foreach ($this->readExports() as $export) {
            if (($export['id'] ?? null) === $exportId) {
                return $export;
            }
        }

        return null;
    }
}
