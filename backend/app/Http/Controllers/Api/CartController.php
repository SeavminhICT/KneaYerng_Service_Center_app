<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\CartResource;
use App\Http\Resources\OrderResource;
use App\Models\Accessory;
use App\Models\Cart;
use App\Models\CartItem;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Part;
use App\Models\Payment;
use App\Models\Product;
use App\Models\VoucherRedemption;
use App\Services\VoucherService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class CartController extends Controller
{
    public function show(Request $request)
    {
        $user = $request->user();
        $cart = $this->getOrCreateCart($user->id)->load('items');

        return new CartResource($cart);
    }

    public function addItem(Request $request)
    {
        $user = $request->user();
        $validated = $request->validate([
            'product_id' => ['required_without_all:item_type,item_id', 'nullable', 'integer'],
            'item_type' => ['nullable', 'in:product,accessory,part,repair_part'],
            'item_id' => ['nullable', 'integer'],
            'quantity' => ['nullable', 'integer', 'min:1'],
        ]);

        $quantity = (int) ($validated['quantity'] ?? 1);
        $itemId = (int) ($validated['item_id'] ?? $validated['product_id']);
        $itemType = $validated['item_type'] ?? null;
        if (! $itemId) {
            return response()->json(['message' => 'Item id is required.'], 422);
        }
        $resolved = $this->resolveCatalogItem($itemType, $itemId);

        if (! $resolved) {
            return response()->json(['message' => 'Selected item is not available.'], 422);
        }

        $itemType = $resolved['type'];
        $catalogItem = $resolved['item'];
        $cart = $this->getOrCreateCart($user->id);

        $item = $cart->items()
            ->where('item_type', $itemType)
            ->where('item_id', $itemId)
            ->first();

        if (! $item && $itemType === 'product') {
            $item = $cart->items()->whereNull('item_type')->where('product_id', $itemId)->first();
        }

        $newQuantity = $item ? ($item->quantity + $quantity) : $quantity;

        $availableStock = $this->resolveCatalogStock($itemType, $catalogItem);
        if ($availableStock !== null && $availableStock < $newQuantity) {
            return response()->json(['message' => 'Insufficient stock available.'], 422);
        }

        if ($item) {
            if (! $item->item_type) {
                $item->item_type = $itemType;
                $item->item_id = $itemId;
            }
            if ($itemType === 'product' && ! $item->product_id) {
                $item->product_id = $itemId;
            }
            if (! $item->product_name) {
                $item->product_name = $this->resolveCatalogName($itemType, $catalogItem);
            }
            $item->quantity = $newQuantity;
            $item->line_total = $item->unit_price * $newQuantity;
            $item->save();
        } else {
            $unitPrice = $this->resolveCatalogPrice($itemType, $catalogItem);
            $cart->items()->create([
                'product_id' => $itemType === 'product' ? $itemId : null,
                'item_type' => $itemType,
                'item_id' => $itemId,
                'product_name' => $this->resolveCatalogName($itemType, $catalogItem),
                'unit_price' => $unitPrice,
                'quantity' => $newQuantity,
                'line_total' => $unitPrice * $newQuantity,
            ]);
        }

        return new CartResource($cart->load('items'));
    }

    public function updateItem(Request $request, CartItem $cartItem)
    {
        $user = $request->user();
        if ($cartItem->cart?->user_id !== $user->id) {
            return response()->json(['message' => 'Forbidden.'], 403);
        }

        $validated = $request->validate([
            'quantity' => ['required', 'integer', 'min:1'],
        ]);

        $newQuantity = (int) $validated['quantity'];
        $itemType = $cartItem->item_type ?? 'product';
        $itemId = $cartItem->item_id ?? $cartItem->product_id;
        if ($itemId) {
            $resolved = $this->resolveCatalogItem($itemType, (int) $itemId);
            if ($resolved) {
                $availableStock = $this->resolveCatalogStock($resolved['type'], $resolved['item']);
                if ($availableStock !== null && $availableStock < $newQuantity) {
                    return response()->json(['message' => 'Insufficient stock available.'], 422);
                }
            }
        }

        $cartItem->quantity = $newQuantity;
        $cartItem->line_total = $cartItem->unit_price * $newQuantity;
        $cartItem->save();

        return new CartResource($cartItem->cart->load('items'));
    }

    public function destroyItem(Request $request, CartItem $cartItem)
    {
        $user = $request->user();
        if ($cartItem->cart?->user_id !== $user->id) {
            return response()->json(['message' => 'Forbidden.'], 403);
        }

        $cart = $cartItem->cart;
        $cartItem->delete();

        return new CartResource($cart->load('items'));
    }

    public function checkout(Request $request)
    {
        $user = $request->user();
        $validated = $request->validate([
            'customer_name' => ['required', 'string', 'max:255'],
            'customer_email' => ['nullable', 'email', 'max:255'],
            'order_type' => ['nullable', 'in:pickup,delivery'],
            'payment_method' => ['nullable', 'in:cod,aba,card,wallet,bank,cash'],
            'delivery_address' => ['required_if:order_type,delivery', 'nullable', 'string', 'max:255'],
            'delivery_phone' => ['required_if:order_type,delivery', 'nullable', 'string', 'max:50'],
            'delivery_note' => ['nullable', 'string', 'max:1000'],
            'delivery_fee' => ['nullable', 'numeric', 'min:0'],
            'payment_status' => ['nullable', 'in:unpaid,paid,failed,refunded,pending,processing,success'],
            'voucher_code' => ['nullable', 'string', 'max:50'],
        ]);

        $cart = $this->getOrCreateCart($user->id)->load('items');
        if ($cart->items->isEmpty()) {
            return response()->json(['message' => 'Cart is empty.'], 422);
        }

        $orderType = $validated['order_type'] ?? 'pickup';
        $deliveryFee = $this->resolveDeliveryFee($orderType, $validated['delivery_fee'] ?? null);
        $subtotal = $cart->items->sum('line_total');
        $paymentMethod = $validated['payment_method'] ?? 'cod';
        [$orderPaymentStatus, $paymentStatus] = $this->normalizePaymentStatusInput(
            $validated['payment_status'] ?? null,
            $paymentMethod
        );
        $voucherCode = $validated['voucher_code'] ?? null;
        $voucherService = app(VoucherService::class);

        $deliveryAddress = $orderType === 'delivery' ? ($validated['delivery_address'] ?? null) : null;
        $deliveryPhone = $orderType === 'delivery' ? ($validated['delivery_phone'] ?? null) : null;
        $deliveryNote = $orderType === 'delivery' ? ($validated['delivery_note'] ?? null) : null;

        $order = DB::transaction(function () use (
            $cart,
            $user,
            $validated,
            $orderType,
            $deliveryFee,
            $subtotal,
            $paymentMethod,
            $orderPaymentStatus,
            $paymentStatus,
            $deliveryAddress,
            $deliveryPhone,
            $deliveryNote,
            $voucherCode,
            $voucherService
        ) {
            $voucherData = $voucherService->evaluate($voucherCode, $subtotal, $user->id, true);
            $voucher = $voucherData['voucher'] ?? null;
            $discountAmount = $voucherData['discount_amount'] ?? 0;
            $discountAmount = min($discountAmount, $subtotal);
            $totalAmount = max($subtotal - $discountAmount, 0) + $deliveryFee;

            $order = Order::create([
                'order_number' => $this->generateOrderNumber(),
                'user_id' => $user->id,
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
                'status' => 'pending',
                'placed_at' => now(),
            ]);

            foreach ($cart->items as $item) {
                OrderItem::create([
                    'order_id' => $order->id,
                    'product_id' => $item->item_type === 'product' ? $item->item_id : null,
                    'item_type' => $item->item_type ?? 'product',
                    'item_id' => $item->item_id ?? $item->product_id,
                    'product_name' => $item->product_name,
                    'quantity' => $item->quantity,
                    'price' => $item->unit_price,
                    'line_total' => $item->line_total,
                ]);
            }

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

            if ($voucher) {
                VoucherRedemption::create([
                    'voucher_id' => $voucher->id,
                    'user_id' => $user->id,
                    'order_id' => $order->id,
                    'redeemed_at' => now(),
                ]);
            }

            $cart->items()->delete();
            $cart->delete();

            return $order;
        });

        return new OrderResource($order->load(['items', 'payments']));
    }

    private function getOrCreateCart(int $userId): Cart
    {
        return Cart::firstOrCreate(['user_id' => $userId]);
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

    private function resolveCatalogName(string $itemType, $catalogItem): string
    {
        return $catalogItem->name ?? 'Item';
    }

    private function resolveCatalogPrice(string $itemType, $catalogItem): float
    {
        if ($itemType === 'part') {
            return (float) ($catalogItem->unit_cost ?? 0);
        }

        return (float) ($catalogItem->price ?? 0);
    }

    private function resolveCatalogStock(string $itemType, $catalogItem): ?int
    {
        if ($itemType === 'product') {
            return $catalogItem->stock !== null ? (int) $catalogItem->stock : null;
        }

        if ($itemType === 'part') {
            return $catalogItem->stock !== null ? (int) $catalogItem->stock : null;
        }

        return null;
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

    private function generateOrderNumber(): string
    {
        return 'ORD-'.Str::upper(Str::random(6));
    }
}
