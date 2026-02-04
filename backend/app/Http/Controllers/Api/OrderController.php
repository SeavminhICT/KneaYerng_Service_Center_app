<?php

namespace App\Http\Controllers\Api;

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
use App\Models\VoucherRedemption;
use App\Services\VoucherService;
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
        $query->orderByDesc('placed_at')->orderByDesc('id');

        $perPage = (int) $request->input('per_page', 10);
        $perPage = max(1, min(50, $perPage));

        $orders = $query->paginate($perPage)->withQueryString();

        return OrderResource::collection($orders);
    }

    public function summary(Request $request)
    {
        $query = Order::query();
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
        $status = $validated['status'] ?? 'pending';
        $deliveryAddress = $orderType === 'delivery' ? ($validated['delivery_address'] ?? null) : null;
        $deliveryPhone = $orderType === 'delivery' ? ($validated['delivery_phone'] ?? null) : null;
        $deliveryNote = $orderType === 'delivery' ? ($validated['delivery_note'] ?? null) : null;

        $order = Order::create([
            'order_number' => $orderNumber,
            'user_id' => $resolvedUserId,
            'customer_name' => $validated['customer_name'],
            'customer_email' => $validated['customer_email'] ?? null,
            'order_type' => $orderType,
            'payment_method' => $paymentMethod,
            'delivery_address' => $deliveryAddress,
            'delivery_phone' => $deliveryPhone,
            'delivery_note' => $deliveryNote,
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
            'placed_at' => $validated['placed_at'] ?? now(),
        ]);

        $paymentStatus = $paymentStatus ?? $this->mapOrderPaymentStatusToPaymentStatus($orderPaymentStatus, $paymentMethod);
        $payment = Payment::create([
            'order_id' => $order->id,
            'method' => $paymentMethod,
            'status' => $paymentStatus,
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
                'product_name' => $item['product_name'],
                'quantity' => $item['quantity'],
                'price' => $item['price'],
                'line_total' => $item['line_total'],
            ]);
        }

        return new OrderResource($order->load(['items', 'payments']));
    }

    public function show(Request $request, Order $order)
    {
        $actor = $request->user() ?? $request->user('sanctum');

        if ($actor && method_exists($actor, 'isAdmin') && ! $actor->isAdmin()) {
            if ((int) $order->user_id !== (int) $actor->id) {
                return response()->json(['message' => 'Forbidden.'], 403);
            }
        }

        return new OrderResource($order->load(['items', 'payments']));
    }

    public function update(UpdateOrderRequest $request, Order $order)
    {
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

        if ($orderType !== 'delivery') {
            $deliveryAddress = null;
            $deliveryPhone = null;
            $deliveryNote = null;
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
                $deliveryNote
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
                            'product_name' => $item['product_name'],
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
                $order->subtotal = $subtotal;
                $order->delivery_fee = $deliveryFee;
                $discountAmount = min((float) ($order->discount_amount ?? 0), $subtotal);
                $order->discount_amount = $discountAmount;
                $order->total_amount = $subtotal + $deliveryFee - $discountAmount;
                $order->payment_method = $paymentMethod;
                $order->payment_status = $orderPaymentStatus;

                if ($status === 'completed' && $order->status !== 'completed') {
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

        $payload = [
            'order_id' => $order->id,
            'nonce' => Str::random(16),
            'expires_at' => now()->addHours(24)->timestamp,
        ];

        $token = Crypt::encryptString(json_encode($payload));

        $order->pickup_qr_token = $token;
        $order->pickup_qr_generated_at = now();
        $order->save();

        return response()->json([
            'order_id' => $order->id,
            'token' => $token,
        ]);
    }

    public function verifyPickupQr(Request $request)
    {
        $validated = $request->validate([
            'token' => ['required', 'string'],
        ]);

        try {
            $decoded = json_decode(Crypt::decryptString($validated['token']), true);
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

        if (! $order || $order->order_type !== 'pickup') {
            return response()->json(['message' => 'Order not eligible for pickup.'], 422);
        }

        if ($order->pickup_qr_token !== $validated['token']) {
            return response()->json(['message' => 'QR token mismatch.'], 422);
        }

        if ($order->status === 'completed') {
            return response()->json(['message' => 'Order already completed.'], 422);
        }

        try {
            DB::transaction(function () use ($order) {
                $order->status = 'completed';
                $order->pickup_verified_at = now();

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

        return new OrderResource($order->load(['items', 'payments']));
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
            $price = array_key_exists('price', $item)
                ? (float) $item['price']
                : $this->resolveCatalogPrice($itemType, $catalogItem);
            $productName = $item['product_name'] ?? ($catalogItem->name ?? 'Item');

            return [
                'product_id' => $itemType === 'product' ? (int) $itemId : null,
                'item_type' => $itemType,
                'item_id' => (int) $itemId,
                'product_name' => $productName,
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
        if ($order->inventory_deducted) {
            return;
        }

        $order->loadMissing('items');
        if ($order->items->isEmpty()) {
            return;
        }

        $productIds = $order->items
            ->pluck('product_id')
            ->filter()
            ->unique()
            ->values();

        if ($productIds->isEmpty()) {
            $order->inventory_deducted = true;
            return;
        }

        $products = Product::whereIn('id', $productIds)
            ->lockForUpdate()
            ->get()
            ->keyBy('id');

        foreach ($order->items as $item) {
            if (! $item->product_id) {
                continue;
            }
            $product = $products->get($item->product_id);
            if (! $product) {
                throw new \RuntimeException('Product not found for order item.');
            }
            $available = (int) $product->stock;
            if ($available < $item->quantity) {
                throw new \RuntimeException('Insufficient stock for '.$product->name.'.');
            }
        }

        foreach ($order->items as $item) {
            if (! $item->product_id) {
                continue;
            }
            $product = $products->get($item->product_id);
            if ($product) {
                $product->decrement('stock', $item->quantity);
            }
        }

        $order->inventory_deducted = true;
    }

    private function generateOrderNumber(): string
    {
        return 'ORD-'.Str::upper(Str::random(6));
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
            $q = $request->string('q');
            $query->where(function ($builder) use ($q) {
                $builder->where('order_number', 'like', "%{$q}%")
                    ->orWhere('customer_name', 'like', "%{$q}%")
                    ->orWhere('customer_email', 'like', "%{$q}%");
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

        $hour = (int) $placedAt->format('G');

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
