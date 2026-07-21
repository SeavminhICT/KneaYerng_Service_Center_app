<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Accessory;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Part;
use App\Models\Product;
use App\Models\RepairRequest;
use App\Models\User;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class AdminReportsController extends Controller
{
    private function authorizeAccess(): void
    {
        $user = auth()->user();
        if ($user && ($user->isAdmin() || $user->isStaff() || (method_exists($user, 'hasPermissionTo') && $user->hasPermissionTo('view_sales_report')))) {
            return;
        }
        Gate::authorize('admin-access');
    }

    public function sales(Request $request)
    {
        $this->authorizeAccess();

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
        $this->authorizeAccess();

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
        $this->authorizeAccess();

        [$start, $end, $label, $preset] = $this->resolveRange($request);
        $report = $this->buildCustomerReport($start, $end);

        return response()->json([
            'range' => $this->rangePayload($start, $end, $label, $preset),
            'metrics' => $report['metrics'],
            'top_customers' => $report['top_customers'],
        ]);
    }

    public function repairs(Request $request)
    {
        $this->authorizeAccess();

        [$start, $end, $label, $preset] = $this->resolveRange($request);
        $report = $this->buildRepairsReport($start, $end);

        return response()->json([
            'range'          => $this->rangePayload($start, $end, $label, $preset),
            'metrics'        => $report['metrics'],
            'by_status'      => $report['by_status'],
            'by_service_type'=> $report['by_service_type'],
            'recent'         => $report['recent'],
        ]);
    }

    public function export(Request $request)
    {
        $this->authorizeAccess();

        $validated = $request->validate([
            'type' => ['required', 'string', 'in:sales,inventory,customers,repairs'],
            'format' => ['required', 'string', 'in:excel,csv,pdf'],
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
        $fileExt = ($format === 'pdf') ? 'pdf' : (($format === 'excel') ? 'xlsx' : 'csv');
        $fileBase = "{$type}-report-{$start->format('Ymd')}-{$end->format('Ymd')}";

        if ($format === 'csv' || $format === 'excel') {
            if ($type === 'sales') {
                [$content, $rowCount] = $this->buildSalesCsv($start, $end);
            } elseif ($type === 'inventory') {
                [$content, $rowCount] = $this->buildInventoryCsv($threshold);
            } elseif ($type === 'repairs') {
                [$content, $rowCount] = $this->buildRepairsCsv($start, $end);
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
        $path = "reports/{$id}.{$fileExt}";
        $fileName = "{$fileBase}.{$fileExt}";
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
        $this->authorizeAccess();

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
        $this->authorizeAccess();

        $export = $this->findExport($exportId);
        if (! $export) {
            return response()->json(['message' => 'Export not found.'], 404);
        }

        $disk = Storage::disk('local');
        if (! $disk->exists($export['path'])) {
            return response()->json(['message' => 'Export file missing.'], 404);
        }

        $contentType = 'text/csv; charset=UTF-8';
        if (($export['format'] ?? '') === 'pdf') {
            $contentType = 'application/pdf';
        } elseif (($export['format'] ?? '') === 'excel') {
            $contentType = 'application/vnd.ms-excel; charset=UTF-8';
        }

        $headers = [
            'Content-Type' => $contentType,
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
        fputs($handle, "\xEF\xBB\xBF");
        fputcsv($handle, ['KneaYerng Service Center - Sales Analytics Report']);
        fputcsv($handle, ['Period:', $start->format('d M Y') . ' to ' . $end->format('d M Y')]);
        fputcsv($handle, ['Generated:', now()->format('Y-m-d H:i:s T')]);
        fputcsv($handle, []);
        fputcsv($handle, [
            'Order Number',
            'Customer Name',
            'Customer Email',
            'Order Type',
            'Payment Method',
            'Subtotal ($)',
            'Delivery Fee ($)',
            'Discount Amount ($)',
            'Total Amount ($)',
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
        fputs($handle, "\xEF\xBB\xBF");
        fputcsv($handle, ['KneaYerng Service Center - Inventory & Stock Report']);
        fputcsv($handle, ['Low Stock Threshold:', $threshold]);
        fputcsv($handle, ['Generated:', now()->format('Y-m-d H:i:s T')]);
        fputcsv($handle, []);
        fputcsv($handle, [
            'Item Type',
            'Name',
            'SKU',
            'Stock Quantity',
            'Status',
            'Unit Price ($)',
        ]);

        $rowCount = 0;

        Product::query()
            ->select(['name', 'sku', 'stock', 'status', 'price'])
            ->orderBy('name')
            ->chunk(500, function ($products) use ($handle, &$rowCount) {
                foreach ($products as $product) {
                    fputcsv($handle, [
                        'Product',
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
                        'Accessory',
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
                        'Part',
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
        fputs($handle, "\xEF\xBB\xBF");
        fputcsv($handle, ['KneaYerng Service Center - Customer Intelligence Report']);
        fputcsv($handle, ['Period:', $start->format('d M Y') . ' to ' . $end->format('d M Y')]);
        fputcsv($handle, ['Generated:', now()->format('Y-m-d H:i:s T')]);
        fputcsv($handle, []);
        fputcsv($handle, [
            'Customer Name',
            'Email',
            'Phone',
            'Orders Count',
            'Total Spent ($)',
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
        $rangeLabel = $start->format('d M Y').' – '.$end->format('d M Y');

        if ($type === 'sales') {
            $report = $this->buildSalesReport($start, $end);
            return Pdf::loadView('admin.reports.pdf.sales', compact('report', 'start', 'end', 'rangeLabel'))
                ->setPaper('a4', 'portrait')
                ->output();
        }

        if ($type === 'inventory') {
            $report = $this->buildInventoryReport($start, $end, $threshold);
            return Pdf::loadView('admin.reports.pdf.inventory', compact('report', 'start', 'end', 'rangeLabel'))
                ->setPaper('a4', 'portrait')
                ->output();
        }

        if ($type === 'repairs') {
            $report = $this->buildRepairsReport($start, $end);
            return Pdf::loadView('admin.reports.pdf.repairs', compact('report', 'start', 'end', 'rangeLabel'))
                ->setPaper('a4', 'portrait')
                ->output();
        }

        $report = $this->buildCustomerReport($start, $end);
        return Pdf::loadView('admin.reports.pdf.customers', compact('report', 'start', 'end', 'rangeLabel'))
            ->setPaper('a4', 'portrait')
            ->output();
    }

    private function buildRepairsReport(Carbon $start, Carbon $end): array
    {
        $base = RepairRequest::query()->whereBetween('created_at', [$start, $end]);

        $total     = (clone $base)->count();
        $completed = (clone $base)->where('status', 'completed')->count();
        $inProgress = (clone $base)->whereNotIn('status', ['completed'])->count();

        $byStatus = (clone $base)
            ->selectRaw('status, COUNT(*) as count')
            ->groupBy('status')
            ->orderBy('status')
            ->get()
            ->map(fn ($r) => ['status' => $r->status, 'count' => (int) $r->count])
            ->values()
            ->all();

        $byServiceType = (clone $base)
            ->selectRaw('service_type, COUNT(*) as count')
            ->groupBy('service_type')
            ->orderBy('service_type')
            ->get()
            ->map(fn ($r) => ['service_type' => $r->service_type, 'count' => (int) $r->count])
            ->values()
            ->all();

        $recent = RepairRequest::query()
            ->with(['customer:id,first_name,last_name,email', 'technician:id,name'])
            ->whereBetween('created_at', [$start, $end])
            ->orderByDesc('created_at')
            ->limit(10)
            ->get()
            ->map(function (RepairRequest $r) {
                $name = trim(($r->customer?->first_name ?? '').' '.($r->customer?->last_name ?? ''));
                return [
                    'id'             => $r->id,
                    'device_model'   => $r->device_model,
                    'issue_type'     => $r->issue_type,
                    'service_type'   => $r->service_type,
                    'status'         => $r->status,
                    'customer_name'  => $name !== '' ? $name : ($r->customer?->email ?? 'Guest'),
                    'technician_name'=> $r->technician?->name ?? '—',
                    'created_at'     => $r->created_at?->toDateTimeString(),
                ];
            })
            ->values()
            ->all();

        return [
            'metrics' => [
                'total_requests' => $total,
                'completed'      => $completed,
                'in_progress'    => $inProgress,
            ],
            'by_status'       => $byStatus,
            'by_service_type' => $byServiceType,
            'recent'          => $recent,
        ];
    }

    private function buildRepairsCsv(Carbon $start, Carbon $end): array
    {
        $handle = fopen('php://temp', 'w+');
        fputs($handle, "\xEF\xBB\xBF");
        fputcsv($handle, ['KneaYerng Service Center - Repair Operations Report']);
        fputcsv($handle, ['Period:', $start->format('d M Y') . ' to ' . $end->format('d M Y')]);
        fputcsv($handle, ['Generated:', now()->format('Y-m-d H:i:s T')]);
        fputcsv($handle, []);
        fputcsv($handle, [
            'ID',
            'Customer Name',
            'Customer Email',
            'Device Model',
            'Issue Type',
            'Service Type',
            'Status',
            'Technician',
            'Appointment Datetime',
            'Created At',
        ]);

        $rowCount = 0;
        RepairRequest::query()
            ->with(['customer:id,first_name,last_name,email', 'technician:id,name'])
            ->whereBetween('created_at', [$start, $end])
            ->orderByDesc('created_at')
            ->chunk(500, function ($repairs) use ($handle, &$rowCount) {
                foreach ($repairs as $repair) {
                    $name = trim(($repair->customer?->first_name ?? '').' '.($repair->customer?->last_name ?? ''));
                    fputcsv($handle, [
                        $repair->id,
                        $name !== '' ? $name : 'Guest',
                        $repair->customer?->email,
                        $repair->device_model,
                        $repair->issue_type,
                        $repair->service_type,
                        $repair->status,
                        $repair->technician?->name,
                        $repair->appointment_datetime?->toDateTimeString(),
                        $repair->created_at?->toDateTimeString(),
                    ]);
                    $rowCount += 1;
                }
            });

        rewind($handle);
        $content = stream_get_contents($handle);
        fclose($handle);

        return [$content, $rowCount];
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
