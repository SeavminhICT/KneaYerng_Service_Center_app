<?php

namespace App\Http\Controllers\Api;

use App\Events\AdminOrderCreated;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\StoreOrderRequest;
use App\Http\Requests\Api\UpdateOrderRequest;
use App\Http\Resources\OrderResource;
use App\Models\Accessory;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Payment;
use App\Models\Part;
use App\Models\Product;
use App\Models\ProductVariant;
use App\Models\VoucherRedemption;
use App\Services\PickupTicketService;
use App\Services\OrderPaymentService;
use App\Services\OrderInventoryService;
use App\Services\OrderTrackingService;
use App\Services\TelegramOrderService;
use App\Services\VoucherService;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Contracts\Encryption\DecryptException;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\Crypt;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class OrderController extends Controller
{
    public function index(Request $request)
    {
        $query = Order::query();
        $this->applyOrderFilters($request, $query);
        $query->with(['assignedStaff']);
        $query->orderByDesc('placed_at')->orderByDesc('id');

        $perPage = (int) $request->input('per_page', 10);
        $perPage = max(1, min(50, $perPage));

        $orders = $query->paginate($perPage)->withQueryString();

        return OrderResource::collection($orders);
    }

    public function myTickets(Request $request)
    {
        $actor = $request->user() ?? $request->user('sanctum');
        if (! $actor) {
            return response()->json(['message' => 'Unauthorized.'], 401);
        }

        $query = Order::query()
            ->where('user_id', $actor->id)
            ->where('order_type', 'pickup')
            ->whereNotNull('pickup_qr_token');

        if ($request->filled('status')) {
            $query->where('status', $request->string('status'));
        }

        $query->orderByDesc('placed_at')->orderByDesc('id');

        $orders = $query->with(['items'])->get();

        return OrderResource::collection($orders);
    }

    public function summary(Request $request)
    {
        $query = Order::query();

        if (! $request->filled('from_date') && ! $request->filled('to_date')) {
            $today = \Illuminate\Support\Carbon::today('Asia/Phnom_Penh');
            $query->where(function ($builder) use ($today) {
                $builder->whereDate('placed_at', $today)
                    ->orWhere(function ($q) use ($today) {
                        $q->whereNull('placed_at')
                          ->whereDate('created_at', $today);
                    });
            });
        }

        $this->applyOrderFilters($request, $query);

        $summary = $this->emptyShiftSummary();

        $query->select(['id', 'placed_at', 'created_at', 'total_amount'])
            ->orderBy('id')
            ->chunkById(500, function ($orders) use (&$summary) {
                foreach ($orders as $order) {
                    $timestamp = $order->placed_at ?? $order->created_at;
                    $this->accumulateShiftSummary($summary, $timestamp, $order->total_amount);
                }
            });

        return response()->json([
            'summary' => $summary,
            'shifts' => $this->shiftDefinitions(),
        ]);
    }

    public function export(Request $request)
    {
        $query = Order::query();
        $this->applyOrderFilters($request, $query);
        $query->orderByDesc('placed_at')->orderByDesc('id');

        $fileName = 'orders-' . now()->format('Ymd-His') . '.csv';

        return response()->streamDownload(function () use ($query) {
            $handle = fopen('php://output', 'w');
            fputcsv($handle, [
                'Order Number',
                'Customer Name',
                'Customer Email',
                'Order Type',
                'Payment Method',
                'Subtotal',
                'Delivery Fee',
                'Voucher Code',
                'Discount Type',
                'Discount Value',
                'Discount Amount',
                'Total Amount',
                'Payment Status',
                'Status',
                'Placed At',
            ]);

            $query->select([
                'order_number',
                'customer_name',
                'customer_email',
                'order_type',
                'payment_method',
                'subtotal',
                'delivery_fee',
                'voucher_code',
                'discount_type',
                'discount_value',
                'discount_amount',
                'total_amount',
                'payment_status',
                'status',
                'placed_at',
                'created_at',
            ])->chunk(500, function ($orders) use ($handle) {
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
                        $order->voucher_code,
                        $order->discount_type,
                        $order->discount_value,
                        $order->discount_amount,
                        $order->total_amount,
                        $order->payment_status,
                        $order->status,
                        $timestamp ? $timestamp->toDateTimeString() : null,
                    ]);
                }
            });

            fclose($handle);
        }, $fileName, ['Content-Type' => 'text/csv']);
    }

    public function exportPdf(Request $request)
    {
        $query = Order::query();
        $this->applyOrderFilters($request, $query);
        $query->orderByDesc('placed_at')->orderByDesc('id');

        $orders = $query->select([
            'order_number', 'customer_name', 'customer_email', 'order_type',
            'payment_method', 'subtotal', 'delivery_fee', 'discount_amount',
            'total_amount', 'payment_status', 'status', 'placed_at', 'created_at',
        ])->limit(1000)->get();

        $generatedAt = now()->format('d M Y, H:i') . ' ICT';
        $fileName = 'orders-' . now()->format('Ymd-His') . '.pdf';

        $pdf = Pdf::loadView('admin.orders.pdf.export', compact('orders', 'generatedAt'))
            ->setPaper('a4', 'landscape');

        return $pdf->download($fileName);
    }

    public function exportExcel(Request $request)
    {
        $query = Order::query();
        $this->applyOrderFilters($request, $query);
        $query->orderByDesc('placed_at')->orderByDesc('id');

        $orders = $query->select([
            'order_number', 'customer_name', 'customer_email', 'order_type',
            'payment_method', 'subtotal', 'delivery_fee', 'voucher_code',
            'discount_amount', 'total_amount', 'payment_status', 'status',
            'placed_at', 'created_at',
        ])->limit(5000)->get();

        $fileName = 'orders-' . now()->format('Ymd-His') . '.xls';
        $xml = $this->buildOrderExcelXml($orders);

        return response($xml, 200, [
            'Content-Type'        => 'application/vnd.ms-excel; charset=UTF-8',
            'Content-Disposition' => 'attachment; filename="' . $fileName . '"',
            'Pragma'              => 'no-cache',
            'Cache-Control'       => 'must-revalidate, post-check=0, pre-check=0',
            'Expires'             => '0',
        ]);
    }

    private function buildOrderExcelXml($orders): string
    {
        $now = now()->format('d M Y, H:i') . ' ICT';
        $count = $orders->count();

        $xml  = '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
        $xml .= '<?mso-application progid="Excel.Sheet"?>' . "\n";
        $xml .= '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"' . "\n";
        $xml .= ' xmlns:o="urn:schemas-microsoft-com:office:office"' . "\n";
        $xml .= ' xmlns:x="urn:schemas-microsoft-com:office:excel"' . "\n";
        $xml .= ' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet">' . "\n";

        // ── Styles ──
        $xml .= '<Styles>' . "\n";
        $xml .= '<Style ss:ID="s_title"><Font ss:Bold="1" ss:Size="14" ss:Color="#1E293B"/></Style>' . "\n";
        $xml .= '<Style ss:ID="s_meta"><Font ss:Size="9" ss:Color="#64748B"/></Style>' . "\n";
        $xml .= '<Style ss:ID="s_hdr"><Font ss:Bold="1" ss:Color="#FFFFFF" ss:Size="9"/><Interior ss:Color="#1E293B" ss:Pattern="Solid"/><Alignment ss:Horizontal="Center" ss:Vertical="Center"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#4F46E5"/></Borders></Style>' . "\n";
        $xml .= '<Style ss:ID="s_odd"><Font ss:Size="9" ss:Color="#1E293B"/><Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/></Borders></Style>' . "\n";
        $xml .= '<Style ss:ID="s_even"><Font ss:Size="9" ss:Color="#1E293B"/><Interior ss:Color="#F8FAFC" ss:Pattern="Solid"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/></Borders></Style>' . "\n";
        $xml .= '<Style ss:ID="s_num_odd"><Font ss:Size="9" ss:Color="#1E293B"/><Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/><NumberFormat ss:Format="#,##0.00"/><Alignment ss:Horizontal="Right"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/></Borders></Style>' . "\n";
        $xml .= '<Style ss:ID="s_num_even"><Font ss:Size="9" ss:Color="#1E293B"/><Interior ss:Color="#F8FAFC" ss:Pattern="Solid"/><NumberFormat ss:Format="#,##0.00"/><Alignment ss:Horizontal="Right"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/></Borders></Style>' . "\n";
        $xml .= '<Style ss:ID="s_foot_label"><Font ss:Bold="1" ss:Size="9" ss:Color="#0F172A"/><Interior ss:Color="#F1F5F9" ss:Pattern="Solid"/><Borders><Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#CBD5E1"/></Borders></Style>' . "\n";
        $xml .= '<Style ss:ID="s_foot_num"><Font ss:Bold="1" ss:Size="9" ss:Color="#16A34A"/><Interior ss:Color="#F1F5F9" ss:Pattern="Solid"/><NumberFormat ss:Format="#,##0.00"/><Alignment ss:Horizontal="Right"/><Borders><Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#CBD5E1"/></Borders></Style>' . "\n";
        $xml .= '<Style ss:ID="s_paid"><Font ss:Bold="1" ss:Size="9" ss:Color="#166534"/><Interior ss:Color="#DCFCE7" ss:Pattern="Solid"/><Alignment ss:Horizontal="Center"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/></Borders></Style>' . "\n";
        $xml .= '<Style ss:ID="s_unpaid"><Font ss:Bold="1" ss:Size="9" ss:Color="#854D0E"/><Interior ss:Color="#FEF9C3" ss:Pattern="Solid"/><Alignment ss:Horizontal="Center"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/></Borders></Style>' . "\n";
        $xml .= '<Style ss:ID="s_refunded"><Font ss:Bold="1" ss:Size="9" ss:Color="#5B21B6"/><Interior ss:Color="#EDE9FE" ss:Pattern="Solid"/><Alignment ss:Horizontal="Center"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/></Borders></Style>' . "\n";
        $xml .= '<Style ss:ID="s_st_done"><Font ss:Bold="1" ss:Size="9" ss:Color="#166534"/><Alignment ss:Horizontal="Center"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/></Borders></Style>' . "\n";
        $xml .= '<Style ss:ID="s_st_fail"><Font ss:Bold="1" ss:Size="9" ss:Color="#991B1B"/><Alignment ss:Horizontal="Center"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/></Borders></Style>' . "\n";
        $xml .= '<Style ss:ID="s_st_prog"><Font ss:Bold="1" ss:Size="9" ss:Color="#1E40AF"/><Alignment ss:Horizontal="Center"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/></Borders></Style>' . "\n";
        $xml .= '<Style ss:ID="s_st_def"><Font ss:Size="9" ss:Color="#475569"/><Alignment ss:Horizontal="Center"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/></Borders></Style>' . "\n";
        $xml .= '</Styles>' . "\n";

        // ── Worksheet ──
        $xml .= '<Worksheet ss:Name="Orders">' . "\n";
        $xml .= '<Table ss:DefaultColumnWidth="80">' . "\n";

        // Column widths (13 columns total)
        foreach ([40, 110, 120, 65, 85, 70, 65, 70, 75, 70, 80, 75, 110] as $w) {
            $xml .= '<Column ss:Width="' . $w . '"/>' . "\n";
        }

        // Title row
        $xml .= '<Row ss:Height="28"><Cell ss:MergeAcross="12" ss:StyleID="s_title"><Data ss:Type="String">KneaYerng Service Center — Orders Export</Data></Cell></Row>' . "\n";
        $xml .= '<Row ss:Height="16"><Cell ss:MergeAcross="12" ss:StyleID="s_meta"><Data ss:Type="String">Generated: ' . htmlspecialchars($now) . '   |   Total records: ' . $count . '</Data></Cell></Row>' . "\n";
        $xml .= '<Row ss:Height="8"></Row>' . "\n";

        // Header row
        $headers = ['#', 'Order Number', 'Customer Name', 'Type', 'Payment Method', 'Subtotal ($)', 'Del. Fee ($)', 'Discount ($)', 'Total ($)', 'Voucher', 'Pay Status', 'Order Status', 'Date'];
        $xml .= '<Row ss:Height="22">' . "\n";
        foreach ($headers as $h) {
            $xml .= '<Cell ss:StyleID="s_hdr"><Data ss:Type="String">' . htmlspecialchars($h) . '</Data></Cell>' . "\n";
        }
        $xml .= '</Row>' . "\n";

        // Data rows
        $totalAmount = 0.0;
        foreach ($orders as $i => $order) {
            $even = ($i % 2 === 1);
            $rowStyle = $even ? 's_even' : 's_odd';
            $numStyle = $even ? 's_num_even' : 's_num_odd';

            $payStatus = strtolower((string) ($order->payment_status ?? ''));
            $payStyle  = match ($payStatus) {
                'paid'             => 's_paid',
                'unpaid', 'pending' => 's_unpaid',
                'refunded'          => 's_refunded',
                default             => $rowStyle,
            };

            $orderStatus = strtolower((string) ($order->status ?? ''));
            $stStyle = match (true) {
                \in_array($orderStatus, ['completed', 'delivered'])                                       => 's_st_done',
                \in_array($orderStatus, ['cancelled', 'rejected'])                                        => 's_st_fail',
                \in_array($orderStatus, ['in_progress', 'on_the_way', 'assigned', 'processing', 'approved']) => 's_st_prog',
                default                                                                                   => 's_st_def',
            };

            $timestamp = $order->placed_at ?? $order->created_at;
            $dateStr   = $timestamp ? $timestamp->format('d M Y H:i') : '';
            $amount    = (float) ($order->total_amount ?? 0);
            $totalAmount += $amount;

            $xml .= '<Row ss:Height="18">' . "\n";
            $xml .= '<Cell ss:StyleID="' . $rowStyle . '"><Data ss:Type="Number">' . ($i + 1) . '</Data></Cell>' . "\n";
            $xml .= '<Cell ss:StyleID="' . $rowStyle . '"><Data ss:Type="String">' . htmlspecialchars((string) ($order->order_number ?? '')) . '</Data></Cell>' . "\n";
            $xml .= '<Cell ss:StyleID="' . $rowStyle . '"><Data ss:Type="String">' . htmlspecialchars((string) ($order->customer_name ?? '')) . '</Data></Cell>' . "\n";
            $xml .= '<Cell ss:StyleID="' . $rowStyle . '"><Data ss:Type="String">' . ucfirst((string) ($order->order_type ?? '')) . '</Data></Cell>' . "\n";
            $xml .= '<Cell ss:StyleID="' . $rowStyle . '"><Data ss:Type="String">' . ucfirst(str_replace('_', ' ', (string) ($order->payment_method ?? ''))) . '</Data></Cell>' . "\n";
            $xml .= '<Cell ss:StyleID="' . $numStyle . '"><Data ss:Type="Number">' . (float) ($order->subtotal ?? 0) . '</Data></Cell>' . "\n";
            $xml .= '<Cell ss:StyleID="' . $numStyle . '"><Data ss:Type="Number">' . (float) ($order->delivery_fee ?? 0) . '</Data></Cell>' . "\n";
            $xml .= '<Cell ss:StyleID="' . $numStyle . '"><Data ss:Type="Number">' . (float) ($order->discount_amount ?? 0) . '</Data></Cell>' . "\n";
            $xml .= '<Cell ss:StyleID="' . $numStyle . '"><Data ss:Type="Number">' . $amount . '</Data></Cell>' . "\n";
            $xml .= '<Cell ss:StyleID="' . $rowStyle . '"><Data ss:Type="String">' . htmlspecialchars((string) ($order->voucher_code ?? '')) . '</Data></Cell>' . "\n";
            $xml .= '<Cell ss:StyleID="' . $payStyle . '"><Data ss:Type="String">' . ucfirst($payStatus) . '</Data></Cell>' . "\n";
            $xml .= '<Cell ss:StyleID="' . $stStyle . '"><Data ss:Type="String">' . ucwords(str_replace('_', ' ', $orderStatus)) . '</Data></Cell>' . "\n";
            $xml .= '<Cell ss:StyleID="' . $rowStyle . '"><Data ss:Type="String">' . $dateStr . '</Data></Cell>' . "\n";
            $xml .= '</Row>' . "\n";
        }

        // Totals row — merges cols 0-7 (MergeAcross=7), then Total at col 8, then 4 empties
        $xml .= '<Row ss:Height="20">' . "\n";
        $xml .= '<Cell ss:MergeAcross="7" ss:StyleID="s_foot_label"><Data ss:Type="String">TOTAL (' . $count . ' orders)</Data></Cell>' . "\n";
        $xml .= '<Cell ss:StyleID="s_foot_num"><Data ss:Type="Number">' . round($totalAmount, 2) . '</Data></Cell>' . "\n";
        $xml .= '<Cell ss:StyleID="s_foot_label"><Data ss:Type="String"></Data></Cell>' . "\n";
        $xml .= '<Cell ss:StyleID="s_foot_label"><Data ss:Type="String"></Data></Cell>' . "\n";
        $xml .= '<Cell ss:StyleID="s_foot_label"><Data ss:Type="String"></Data></Cell>' . "\n";
        $xml .= '<Cell ss:StyleID="s_foot_label"><Data ss:Type="String"></Data></Cell>' . "\n";
        $xml .= '</Row>' . "\n";

        $xml .= '</Table>' . "\n";
        $xml .= '</Worksheet>' . "\n";
        $xml .= '</Workbook>';

        return $xml;
    }

    public function store(StoreOrderRequest $request)
    {
        $validated = $request->validated();
        $items = $this->normalizeOrderItems($validated['items'] ?? []);
        $actor = $request->user() ?? $request->user('sanctum');

        $resolvedUserId = $this->resolveUserId($actor, $validated);
        $voucherCode = $validated['voucher_code'] ?? null;
        if ($voucherCode && ! $resolvedUserId) {
            throw ValidationException::withMessages([
                'voucher_code' => ['Voucher requires an authenticated customer.'],
            ]);
        }
        if ($voucherCode && $actor && method_exists($actor, 'isAdmin') && $actor->isAdmin() && empty($validated['user_id'])) {
            throw ValidationException::withMessages([
                'voucher_code' => ['Voucher requires a registered customer (user_id).'],
            ]);
        }

        $orderNumber = $validated['order_number'] ?? $this->generateOrderNumber();
        $orderType = $validated['order_type'] ?? 'pickup';
        $deliveryFee = $this->resolveDeliveryFee($orderType, $validated['delivery_fee'] ?? null);
        $subtotal = $this->calculateSubtotal($items);
        $voucherService = app(VoucherService::class);
        $voucherData = $voucherService->evaluate(
            $voucherCode,
            $subtotal,
            $resolvedUserId ?: 0
        );
        $voucher = $voucherData['voucher'] ?? null;
        $discountAmount = $voucherData['discount_amount'] ?? 0;
        $discountAmount = min($discountAmount, $subtotal);
        $totalAmount = max($subtotal - $discountAmount, 0) + $deliveryFee;
        $paymentMethod = $validated['payment_method'] ?? 'cod';
        [$orderPaymentStatus, $paymentStatus] = $this->normalizePaymentStatusInput(
            $validated['payment_status'] ?? null,
            $paymentMethod
        );
        $status = $validated['status'] ?? ($orderType === 'delivery'
            ? OrderTrackingService::STATUS_CREATED
            : 'pending');
        $deliveryAddress = $orderType === 'delivery' ? ($validated['delivery_address'] ?? null) : null;
        $deliveryPhone = $orderType === 'delivery' ? ($validated['delivery_phone'] ?? null) : null;
        $deliveryNote = $orderType === 'delivery' ? ($validated['delivery_note'] ?? null) : null;
        $deliveryLat = $orderType === 'delivery' ? ($validated['delivery_lat'] ?? null) : null;
        $deliveryLng = $orderType === 'delivery' ? ($validated['delivery_lng'] ?? null) : null;

        try {
            $order = DB::transaction(function () use (
                $validated,
                $resolvedUserId,
                $orderNumber,
                $orderType,
                $paymentMethod,
                $deliveryAddress,
                $deliveryPhone,
                $deliveryNote,
                $deliveryLat,
                $deliveryLng,
                $subtotal,
                $deliveryFee,
                $voucher,
                $discountAmount,
                $totalAmount,
                $orderPaymentStatus,
                $status,
                $paymentStatus,
                $items
            ) {
                $order = Order::create([
                    'order_number' => $orderNumber,
                    'user_id' => $resolvedUserId,
                    'assigned_staff_id' => $validated['assigned_staff_id'] ?? null,
                    'customer_name' => $validated['customer_name'],
                    'customer_email' => $validated['customer_email'] ?? null,
                    'order_type' => $orderType,
                    'payment_method' => $paymentMethod,
                    'delivery_address' => $deliveryAddress,
                    'delivery_phone' => $deliveryPhone,
                    'delivery_note' => $deliveryNote,
                    'delivery_lat' => $deliveryLat,
                    'delivery_lng' => $deliveryLng,
                    'subtotal' => $subtotal,
                    'delivery_fee' => $deliveryFee,
                    'voucher_id' => $voucher?->id,
                    'voucher_code' => $voucher?->code,
                    'discount_type' => $voucher?->discount_type,
                    'discount_value' => $voucher?->discount_value ?? 0,
                    'discount_amount' => $discountAmount,
                    'total_amount' => $totalAmount,
                    'payment_status' => $orderPaymentStatus,
                    'status' => $status,
                    'current_status_at' => now(),
                    'placed_at' => $validated['placed_at'] ?? now(),
                ]);

                $resolvedPaymentStatus = $paymentStatus ?? $this->mapOrderPaymentStatusToPaymentStatus($orderPaymentStatus, $paymentMethod);
                $payment = Payment::create([
                    'order_id' => $order->id,
                    'method' => $paymentMethod,
                    'status' => $resolvedPaymentStatus,
                    'amount' => $totalAmount,
                ]);

                if ($payment->status === 'success') {
                    $payment->paid_at = now();
                    $payment->save();
                }

                if ($voucher && $resolvedUserId) {
                    VoucherRedemption::create([
                        'voucher_id' => $voucher->id,
                        'user_id' => $resolvedUserId,
                        'order_id' => $order->id,
                        'redeemed_at' => now(),
                    ]);
                }

                Log::info('Payment created for order.', [
                    'order_id' => $order->id,
                    'payment_id' => $payment->id,
                    'status' => $payment->status,
                    'method' => $payment->method,
                ]);

                foreach ($items as $item) {
                    OrderItem::create([
                        'order_id' => $order->id,
                        'product_id' => $item['product_id'] ?? null,
                        'item_type' => $item['item_type'] ?? null,
                        'item_id' => $item['item_id'] ?? null,
                        'product_variant_id' => $item['product_variant_id'] ?? null,
                        'product_name' => $item['product_name'],
                        'variant_label' => $item['variant_label'] ?? null,
                        'quantity' => $item['quantity'],
                        'price' => $item['price'],
                        'line_total' => $item['line_total'],
                    ]);
                }

                app(OrderInventoryService::class)->deductInventoryForOrder($order);
                $order->save();

                return $order;
            });
        } catch (\RuntimeException $exception) {
            return response()->json(['message' => $exception->getMessage()], 422);
        }

        if ($orderPaymentStatus === 'paid') {
            app(OrderPaymentService::class)->markOrderPaid($order, $paymentMethod, [
                'status' => $paymentStatus ?? 'success',
                'amount' => $totalAmount,
            ]);
        }

        if ($orderType === 'delivery') {
            try {
                app(OrderTrackingService::class)->bootstrapDeliveryOrder($order, $actor);
            } catch (\Throwable $exception) {
                Log::warning('Failed to bootstrap delivery order tracking.', [
                    'order_id' => $order->id,
                    'error' => $exception->getMessage(),
                ]);
            }
        }

        try {
            $order = $order->load([
                'items',
                'payments',
                'assignedStaff',
                'approver',
                'rejector',
                'canceller',
                'trackingHistories.actor',
                'trackingHistories.assignedStaff',
            ]);
        } catch (\Throwable $exception) {
            Log::warning('Failed to eager-load order relations.', [
                'order_id' => $order->id,
                'error' => $exception->getMessage(),
            ]);
        }

        try {
            // Delay Telegram notification for QR code payments (aba) until payment is confirmed successful.
            if ($order->payment_status === 'paid' || !in_array($order->payment_method, ['aba'], true)) {
                app(TelegramOrderService::class)->sendOrderMessage($order);
            }
        } catch (\Throwable $exception) {
            Log::warning('Failed to send Telegram order notification.', [
                'order_id' => $order->id,
                'error' => $exception->getMessage(),
            ]);
        }

        try {
            event(new AdminOrderCreated($order));
        } catch (\Throwable $exception) {
            Log::warning('Failed to broadcast admin order event.', [
                'order_id' => $order->id,
                'error' => $exception->getMessage(),
            ]);
        }

        return new OrderResource($order);
    }

    public function show(Request $request, Order $order)
    {
        $actor = $request->user() ?? $request->user('sanctum');

        if ($actor && method_exists($actor, 'isAdmin') && ! $actor->isAdmin()) {
            if (
                (! method_exists($actor, 'isStaff') || ! $actor->isStaff() || (int) $order->assigned_staff_id !== (int) $actor->id) &&
                (int) $order->user_id !== (int) $actor->id
            ) {
                return response()->json(['message' => 'Forbidden.'], 403);
            }
        }

        return new OrderResource($order->load([
            'items',
            'payments',
            'assignedStaff',
            'approver',
            'rejector',
            'canceller',
            'trackingHistories.actor',
            'trackingHistories.assignedStaff',
        ]));
    }

    public function update(UpdateOrderRequest $request, Order $order)
    {
        $previousPaymentStatus = $order->payment_status;
        $validated = $request->validated();
        $paymentMethod = $validated['payment_method'] ?? ($order->payment_method ?? 'cod');
        $orderType = $validated['order_type'] ?? ($order->order_type ?? 'pickup');
        $status = $validated['status'] ?? $order->status;
        $deliveryFee = array_key_exists('delivery_fee', $validated)
            ? $this->resolveDeliveryFee($orderType, $validated['delivery_fee'])
            : ($orderType === 'delivery' ? (float) ($order->delivery_fee ?? 0) : 0);

        $normalizedItems = null;
        if (array_key_exists('items', $validated)) {
            $normalizedItems = $this->normalizeOrderItems($validated['items']);
        }

        $paymentStatusProvided = array_key_exists('payment_status', $validated);
        $paymentStatusSync = $paymentStatusProvided;
        if ($paymentStatusProvided) {
            [$orderPaymentStatus, $paymentStatus] = $this->normalizePaymentStatusInput(
                $validated['payment_status'],
                $paymentMethod
            );
        } else {
            $orderPaymentStatus = $order->payment_status;
            $paymentStatus = null;
        }

        if (
            ! $paymentStatusProvided
            && $status === 'completed'
            && in_array($paymentMethod, ['cod', 'cash'], true)
            && $orderPaymentStatus === 'unpaid'
        ) {
            $orderPaymentStatus = 'paid';
            $paymentStatusSync = true;
        }

        $deliveryAddress = array_key_exists('delivery_address', $validated)
            ? $validated['delivery_address']
            : $order->delivery_address;
        $deliveryPhone = array_key_exists('delivery_phone', $validated)
            ? $validated['delivery_phone']
            : $order->delivery_phone;
        $deliveryNote = array_key_exists('delivery_note', $validated)
            ? $validated['delivery_note']
            : $order->delivery_note;
        $deliveryLat = array_key_exists('delivery_lat', $validated)
            ? $validated['delivery_lat']
            : $order->delivery_lat;
        $deliveryLng = array_key_exists('delivery_lng', $validated)
            ? $validated['delivery_lng']
            : $order->delivery_lng;

        if ($orderType !== 'delivery') {
            $deliveryAddress = null;
            $deliveryPhone = null;
            $deliveryNote = null;
            $deliveryLat = null;
            $deliveryLng = null;
        }

        try {
            DB::transaction(function () use (
                $order,
                $validated,
                $normalizedItems,
                $orderType,
                $deliveryFee,
                $paymentMethod,
                $orderPaymentStatus,
                $paymentStatus,
                $paymentStatusSync,
                $status,
                $deliveryAddress,
                $deliveryPhone,
                $deliveryNote,
                $deliveryLat,
                $deliveryLng
            ) {
                $order->fill(collect($validated)->except(['items', 'payment_status', 'status', 'delivery_fee'])->toArray());

                if ($normalizedItems !== null) {
                    $order->items()->delete();

                    foreach ($normalizedItems as $item) {
                        OrderItem::create([
                            'order_id' => $order->id,
                            'product_id' => $item['product_id'] ?? null,
                            'item_type' => $item['item_type'] ?? null,
                            'item_id' => $item['item_id'] ?? null,
                            'product_variant_id' => $item['product_variant_id'] ?? null,
                            'product_name' => $item['product_name'],
                            'variant_label' => $item['variant_label'] ?? null,
                            'quantity' => $item['quantity'],
                            'price' => $item['price'],
                            'line_total' => $item['line_total'],
                        ]);
                    }
                }

                $order->load('items');
                $subtotal = $normalizedItems !== null
                    ? $this->calculateSubtotal($normalizedItems)
                    : $this->calculateSubtotalFromOrder($order);

                $order->order_type = $orderType;
                $order->delivery_address = $deliveryAddress;
                $order->delivery_phone = $deliveryPhone;
                $order->delivery_note = $deliveryNote;
                $order->delivery_lat = $deliveryLat;
                $order->delivery_lng = $deliveryLng;
                $order->subtotal = $subtotal;
                $order->delivery_fee = $deliveryFee;
                $discountAmount = min((float) ($order->discount_amount ?? 0), $subtotal);
                $order->discount_amount = $discountAmount;
                $order->total_amount = $subtotal + $deliveryFee - $discountAmount;
                $order->payment_method = $paymentMethod;
                $order->payment_status = $orderPaymentStatus;

                if (
                    in_array($status, ['completed', 'delivered'], true) &&
                    ! in_array($order->status, ['completed', 'delivered'], true)
                ) {
                    $this->deductInventoryForOrder($order);
                }

                $order->status = $status;
                $order->save();

                if ($paymentStatusSync || array_key_exists('payment_method', $validated)) {
                    $this->syncPaymentForOrder($order, $paymentMethod, $orderPaymentStatus, $paymentStatus);
                }
            });
        } catch (\RuntimeException $exception) {
            return response()->json(['message' => $exception->getMessage()], 422);
        }

        if ($previousPaymentStatus !== 'paid' && $order->payment_status === 'paid') {
            app(OrderPaymentService::class)->markOrderPaid($order, $order->payment_method, [
                'amount' => (float) $order->total_amount,
            ]);
        }

        return new OrderResource($order->load(['items', 'payments']));
    }

    public function destroy(Order $order)
    {
        $order->delete();

        return response()->noContent();
    }

    public function generatePickupQr(Request $request, Order $order)
    {
        if ($order->order_type !== 'pickup') {
            return response()->json(['message' => 'QR is only available for pickup orders.'], 422);
        }

        if ($order->payment_status !== 'paid') {
            return response()->json(['message' => 'Payment is not confirmed.'], 422);
        }

        try {
            $ticket = app(PickupTicketService::class)->issueForOrder($order);
        } catch (\RuntimeException $exception) {
            return response()->json(['message' => $exception->getMessage()], 422);
        }

        return response()->json([
            'order_id'  => $order->id,
            'ticket_id' => $ticket['ticket_id'],
            'token'     => $ticket['token'],
            'qr_code'   => $ticket['qr_code'],
            'issued_at' => $ticket['issued_at']?->toISOString(),
            'expires_at' => $ticket['expires_at']?->toISOString(),
        ]);
    }

    public function verifyPickupQr(Request $request)
    {
        $validated = $request->validate([
            'token'     => ['nullable', 'string'],
            'qr_code'   => ['nullable', 'string'],
            'ticket_id' => ['nullable', 'string'],
        ]);

        $token    = $validated['token'] ?? null;
        $qrCode   = $validated['qr_code'] ?? null;
        $ticketId = $validated['ticket_id'] ?? null;

        // Auto-detect short QR code sent in the legacy token field
        // (scanner captures QR content and sends it as token).
        if (! $qrCode && $token && strlen($token) <= 24 && preg_match('/^[A-Z0-9]+$/i', $token)) {
            $qrCode = strtoupper($token);
            $token  = null;
        }

        if (! $token && ! $qrCode && ! $ticketId) {
            return response()->json(['message' => 'QR token or ticket id is required.'], 422);
        }

        $orderFromTicket = null;

        // Resolve by short QR code
        if ($qrCode && ! $token) {
            $orderFromTicket = Order::where('pickup_qr_short_code', strtoupper($qrCode))->first();
            if (! $orderFromTicket) {
                return response()->json(['message' => 'QR code not found.'], 404);
            }
            if (! $orderFromTicket->pickup_qr_token) {
                return response()->json(['message' => 'Ticket QR not issued.'], 422);
            }
            $token = $orderFromTicket->pickup_qr_token;
        }

        // Resolve by ticket_id
        if (! $token && $ticketId) {
            $ticketId = trim($ticketId);
            if ($ticketId === '') {
                return response()->json(['message' => 'Ticket id is required.'], 422);
            }
            if (str_starts_with($ticketId, 'TCK-')) {
                $ticketId = substr($ticketId, 4);
            }
            if (is_numeric($ticketId)) {
                $orderFromTicket = Order::find((int) $ticketId);
            } else {
                $orderFromTicket = Order::where('order_number', $ticketId)->first();
            }

            if (! $orderFromTicket) {
                return response()->json(['message' => 'Ticket not found.'], 404);
            }
            if (! $orderFromTicket->pickup_qr_token) {
                return response()->json(['message' => 'Ticket QR not issued.'], 422);
            }
            $token = $orderFromTicket->pickup_qr_token;
        }

        try {
            $decoded = json_decode(Crypt::decryptString($token), true);
        } catch (DecryptException $exception) {
            return response()->json(['message' => 'Invalid QR token.'], 422);
        }

        if (! is_array($decoded) || empty($decoded['order_id']) || empty($decoded['expires_at'])) {
            return response()->json(['message' => 'Invalid QR token.'], 422);
        }

        if ((int) $decoded['expires_at'] < now()->timestamp) {
            return response()->json(['message' => 'QR token expired.'], 422);
        }

        $order = Order::find($decoded['order_id']);
        if ($orderFromTicket && (int) $orderFromTicket->id !== (int) $order->id) {
            return response()->json(['message' => 'Ticket does not match order.'], 422);
        }

        if (! $order || $order->order_type !== 'pickup') {
            return response()->json(['message' => 'Order not eligible for pickup.'], 422);
        }

        if ($order->pickup_qr_token !== $token) {
            return response()->json(['message' => 'QR token mismatch.'], 422);
        }

        if ($order->status === 'completed') {
            return response()->json(['message' => 'Order already completed.'], 422);
        }

        if ($order->payment_status !== 'paid') {
            return response()->json(['message' => 'Payment not confirmed.'], 422);
        }

        $actor = $request->user() ?? $request->user('sanctum');

        try {
            DB::transaction(function () use ($order, $actor) {
                $order->status = 'completed';
                $order->pickup_verified_at = now();
                if ($actor) {
                    $order->pickup_verified_by = $actor->id;
                }

                if (in_array($order->payment_method, ['cod', 'cash'], true) && $order->payment_status !== 'paid') {
                    $order->payment_status = 'paid';
                }

                $this->deductInventoryForOrder($order);
                $this->syncPaymentForOrder($order, $order->payment_method, $order->payment_status, null);
                $order->save();
            });
        } catch (\RuntimeException $exception) {
            return response()->json(['message' => $exception->getMessage()], 422);
        }

        return new OrderResource($order->load(['items', 'payments', 'pickupVerifier']));
    }

    private function normalizeOrderItems(array $items): array
    {
        return array_map(function (array $item) {
            $itemId = $item['item_id'] ?? $item['product_id'] ?? null;
            if (! $itemId) {
                throw ValidationException::withMessages([
                    'items' => ['Each item must reference a product, accessory, or repair part.'],
                ]);
            }

            $resolved = $this->resolveCatalogItem($item['item_type'] ?? null, (int) $itemId);
            if (! $resolved) {
                throw ValidationException::withMessages([
                    'items' => ['Each item must reference a valid product, accessory, or repair part.'],
                ]);
            }

            $itemType = $resolved['type'];
            $catalogItem = $resolved['item'];
            $quantity = (int) $item['quantity'];
            $variantId = null;
            $variantLabel = null;
            $defaultPrice = $this->resolveCatalogPrice($itemType, $catalogItem);

            if ($itemType === 'product') {
                $rawVariantId = $item['product_variant_id'] ?? null;
                if ($rawVariantId !== null && $rawVariantId !== '') {
                    $variantId = (int) $rawVariantId;
                    $variant = $this->resolveProductVariant($catalogItem, $variantId);
                    if (! $variant) {
                        throw ValidationException::withMessages([
                            'items' => ['Selected variant is not available for this product.'],
                        ]);
                    }

                    if ((int) $variant->stock < $quantity) {
                        throw ValidationException::withMessages([
                            'items' => ['Insufficient stock for selected product variant.'],
                        ]);
                    }

                    $defaultPrice = (float) $variant->price;
                    $variantLabel = trim((string) ($item['variant_label'] ?? ''));
                    if ($variantLabel === '') {
                        $variantLabel = $this->buildVariantLabel($variant);
                    }
                } elseif ($catalogItem->variants()->where('is_active', true)->exists()) {
                    throw ValidationException::withMessages([
                        'items' => ['Please select a product variant.'],
                    ]);
                }
            }

            $price = array_key_exists('price', $item)
                ? (float) $item['price']
                : $defaultPrice;
            $productName = $item['product_name'] ?? ($catalogItem->name ?? 'Item');

            return [
                'product_id' => $itemType === 'product' ? (int) $itemId : null,
                'item_type' => $itemType,
                'item_id' => (int) $itemId,
                'product_variant_id' => $variantId,
                'product_name' => $productName,
                'variant_label' => $variantLabel,
                'quantity' => $quantity,
                'price' => $price,
                'line_total' => $price * $quantity,
            ];
        }, $items);
    }

    private function calculateSubtotal(array $items): float
    {
        return array_reduce($items, function (float $carry, array $item) {
            return $carry + (float) $item['line_total'];
        }, 0.0);
    }

    private function calculateSubtotalFromOrder(Order $order): float
    {
        return $order->items->sum(function (OrderItem $item) {
            return $item->line_total ?? ($item->price * $item->quantity);
        });
    }

    private function resolveDeliveryFee(string $orderType, $deliveryFee): float
    {
        if ($orderType !== 'delivery') {
            return 0;
        }

        if ($deliveryFee === null || $deliveryFee === '') {
            return (float) config('orders.delivery_fee', 0);
        }

        return (float) $deliveryFee;
    }

    private function normalizePaymentStatusInput(?string $status, string $paymentMethod): array
    {
        if (! $status) {
            return ['unpaid', null];
        }

        $normalized = strtolower($status);
        if (in_array($normalized, ['pending', 'processing', 'success', 'failed'], true)) {
            return [
                $this->mapPaymentStatusToOrderStatus($normalized),
                $normalized,
            ];
        }

        return [
            $normalized,
            $this->mapOrderPaymentStatusToPaymentStatus($normalized, $paymentMethod),
        ];
    }

    private function mapPaymentStatusToOrderStatus(string $paymentStatus): string
    {
        if ($paymentStatus === 'success') {
            return 'paid';
        }

        if ($paymentStatus === 'failed') {
            return 'failed';
        }

        return 'unpaid';
    }

    private function mapOrderPaymentStatusToPaymentStatus(string $orderPaymentStatus, string $paymentMethod): string
    {
        if ($orderPaymentStatus === 'paid') {
            return 'success';
        }

        if ($orderPaymentStatus === 'failed') {
            return 'failed';
        }

        if ($orderPaymentStatus === 'refunded') {
            return 'failed';
        }

        if (in_array($paymentMethod, ['aba', 'card', 'wallet', 'bank'], true)) {
            return 'processing';
        }

        return 'pending';
    }

    private function syncPaymentForOrder(
        Order $order,
        string $paymentMethod,
        string $orderPaymentStatus,
        ?string $paymentStatus
    ): void {
        $payment = $order->payments()->latest()->first();

        if (! $payment) {
            $payment = Payment::create([
                'order_id' => $order->id,
                'method' => $paymentMethod,
                'status' => 'pending',
                'amount' => $order->total_amount,
            ]);
        }

        $payment->method = $paymentMethod;

        if ($paymentStatus) {
            $payment->status = $paymentStatus;
            $payment->paid_at = $paymentStatus === 'success' ? now() : null;
        } else {
            $payment->status = $this->mapOrderPaymentStatusToPaymentStatus($orderPaymentStatus, $paymentMethod);
            $payment->paid_at = $payment->status === 'success' ? now() : null;
        }

        $payment->amount = $order->total_amount;
        $payment->save();
    }

    private function deductInventoryForOrder(Order $order): void
    {
        app(OrderInventoryService::class)->deductInventoryForOrder($order);
    }

    private function generateOrderNumber(): string
    {
        $prefix = 'KYAPP00'.now()->format('ymd');
        for ($attempt = 0; $attempt < 5; $attempt++) {
            $candidate = $prefix.Str::upper(Str::random(4));
            if (! Order::where('order_number', $candidate)->exists()) {
                return $candidate;
            }
        }

        return $prefix.Str::upper(Str::random(6));
    }

    private function resolveUserId($actor, array $validated): ?int
    {
        if (! $actor) {
            return $validated['user_id'] ?? null;
        }

        if (method_exists($actor, 'isAdmin') && $actor->isAdmin()) {
            return $validated['user_id'] ?? $actor->id;
        }

        return $actor->id;
    }

    private function resolveCatalogItem(?string $itemType, int $itemId): ?array
    {
        $normalizedType = $this->normalizeItemType($itemType);
        if ($normalizedType) {
            $item = $this->findCatalogItem($normalizedType, $itemId);
            return $item ? ['type' => $normalizedType, 'item' => $item] : null;
        }

        foreach (['product', 'accessory', 'part'] as $candidate) {
            $item = $this->findCatalogItem($candidate, $itemId);
            if ($item) {
                return ['type' => $candidate, 'item' => $item];
            }
        }

        return null;
    }

    private function normalizeItemType(?string $itemType): ?string
    {
        if (! $itemType) {
            return null;
        }

        $normalized = strtolower($itemType);

        if ($normalized === 'repair_part') {
            return 'part';
        }

        return $normalized;
    }

    private function findCatalogItem(string $itemType, int $itemId)
    {
        if ($itemType === 'accessory') {
            return Accessory::find($itemId);
        }

        if ($itemType === 'part') {
            return Part::find($itemId);
        }

        return Product::find($itemId);
    }

    private function resolveProductVariant(Product $product, int $variantId): ?ProductVariant
    {
        return $product->variants()
            ->where('is_active', true)
            ->where('id', $variantId)
            ->first();
    }

    private function buildVariantLabel(ProductVariant $variant): string
    {
        $parts = [
            trim((string) $variant->storage_capacity),
            trim((string) $variant->color),
            trim((string) $variant->condition),
        ];

        return implode(' / ', array_values(array_filter($parts, fn ($value) => $value !== '')));
    }

    private function resolveCatalogPrice(string $itemType, $catalogItem): float
    {
        if ($itemType === 'part') {
            return (float) ($catalogItem->unit_cost ?? 0);
        }

        return (float) ($catalogItem->price ?? 0);
    }

    private function applyOrderFilters(Request $request, Builder $query): void
    {
        if ($request->filled('q')) {
            $q = (string) $request->string('q');
            $query->where(function ($builder) use ($q) {
                $builder->where('order_number', 'like', "%{$q}%")
                    ->orWhere('customer_name', 'like', "%{$q}%")
                    ->orWhere('customer_email', 'like', "%{$q}%");

                if (is_numeric($q)) {
                    $builder->orWhere('id', (int) $q);
                }
            });
        }

        if ($request->filled('status')) {
            $query->where('status', $request->string('status'));
        }

        if ($request->filled('payment_status')) {
            $status = strtolower((string) $request->string('payment_status'));
            if (in_array($status, ['pending', 'processing', 'success', 'failed'], true)) {
                $status = $this->mapPaymentStatusToOrderStatus($status);
            }
            $query->where('payment_status', $status);
        }

        if ($request->filled('order_type')) {
            $query->where('order_type', $request->string('order_type'));
        }

        if ($request->filled('from_date')) {
            $fromRaw = (string) $request->input('from_date');
            try {
                $fromDate = \Illuminate\Support\Carbon::parse($fromRaw);
                $query->where(function ($builder) use ($fromDate) {
                    $builder->whereDate('placed_at', '>=', $fromDate)
                        ->orWhereDate('created_at', '>=', $fromDate);
                });
            } catch (\Throwable $exception) {
            }
        }

        if ($request->filled('to_date')) {
            $toRaw = (string) $request->input('to_date');
            try {
                $toDate = \Illuminate\Support\Carbon::parse($toRaw);
                $query->where(function ($builder) use ($toDate) {
                    $builder->whereDate('placed_at', '<=', $toDate)
                        ->orWhereDate('created_at', '<=', $toDate);
                });
            } catch (\Throwable $exception) {
            }
        }
    }

    private function shiftDefinitions(): array
    {
        return [
            ['key' => 'morning', 'label' => 'Morning', 'start' => 6, 'end' => 12],
            ['key' => 'afternoon', 'label' => 'Afternoon', 'start' => 12, 'end' => 18],
            ['key' => 'evening', 'label' => 'Evening', 'start' => 18, 'end' => 22],
            ['key' => 'night', 'label' => 'Night', 'start' => 22, 'end' => 6],
        ];
    }

    private function emptyShiftSummary(): array
    {
        return [
            'morning' => ['count' => 0, 'amount' => 0.0],
            'afternoon' => ['count' => 0, 'amount' => 0.0],
            'evening' => ['count' => 0, 'amount' => 0.0],
            'night' => ['count' => 0, 'amount' => 0.0],
        ];
    }

    private function resolveShiftKey($placedAt): ?string
    {
        if (! $placedAt) {
            return null;
        }

        $hour = (int) $placedAt->copy()->setTimezone('Asia/Phnom_Penh')->format('G');

        if ($hour >= 6 && $hour < 12) {
            return 'morning';
        }

        if ($hour >= 12 && $hour < 18) {
            return 'afternoon';
        }

        if ($hour >= 18 && $hour < 22) {
            return 'evening';
        }

        return 'night';
    }

    private function accumulateShiftSummary(array &$summary, $placedAt, $totalAmount): void
    {
        $shiftKey = $this->resolveShiftKey($placedAt);
        if (! $shiftKey || ! array_key_exists($shiftKey, $summary)) {
            return;
        }

        $summary[$shiftKey]['count'] += 1;
        $summary[$shiftKey]['amount'] += (float) $totalAmount;
    }
}
