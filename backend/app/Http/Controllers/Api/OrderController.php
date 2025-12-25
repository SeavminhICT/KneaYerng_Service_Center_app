<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\StoreOrderRequest;
use App\Http\Requests\Api\UpdateOrderRequest;
use App\Http\Resources\OrderResource;
use App\Models\Order;
use App\Models\OrderItem;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class OrderController extends Controller
{
    public function index(Request $request)
    {
        $query = Order::query()->orderByDesc('placed_at')->orderByDesc('id');

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
            $query->where('payment_status', $request->string('payment_status'));
        }

        $perPage = (int) $request->input('per_page', 10);
        $perPage = max(1, min(50, $perPage));

        $orders = $query->paginate($perPage)->withQueryString();

        return OrderResource::collection($orders);
    }

    public function store(StoreOrderRequest $request)
    {
        $validated = $request->validated();
        $items = $validated['items'] ?? [];

        $orderNumber = $validated['order_number'] ?? $this->generateOrderNumber();
        $totalAmount = collect($items)->sum(fn ($item) => $item['price'] * $item['quantity']);

        $order = Order::create([
            'order_number' => $orderNumber,
            'user_id' => $validated['user_id'] ?? null,
            'customer_name' => $validated['customer_name'],
            'customer_email' => $validated['customer_email'] ?? null,
            'total_amount' => $totalAmount,
            'payment_status' => $validated['payment_status'],
            'status' => $validated['status'],
            'placed_at' => $validated['placed_at'] ?? now(),
        ]);

        foreach ($items as $item) {
            OrderItem::create([
                'order_id' => $order->id,
                'product_id' => $item['product_id'] ?? null,
                'product_name' => $item['product_name'],
                'quantity' => $item['quantity'],
                'price' => $item['price'],
            ]);
        }

        return new OrderResource($order->load('items'));
    }

    public function show(Order $order)
    {
        return new OrderResource($order->load('items'));
    }

    public function update(UpdateOrderRequest $request, Order $order)
    {
        $validated = $request->validated();

        $order->fill(collect($validated)->except('items')->toArray());

        if (array_key_exists('items', $validated)) {
            $order->items()->delete();

            foreach ($validated['items'] as $item) {
                OrderItem::create([
                    'order_id' => $order->id,
                    'product_id' => $item['product_id'] ?? null,
                    'product_name' => $item['product_name'],
                    'quantity' => $item['quantity'],
                    'price' => $item['price'],
                ]);
            }
        }

        if (array_key_exists('items', $validated)) {
            $order->total_amount = collect($validated['items'])->sum(fn ($item) => $item['price'] * $item['quantity']);
        }

        $order->save();

        return new OrderResource($order->load('items'));
    }

    public function destroy(Order $order)
    {
        $order->delete();

        return response()->noContent();
    }

    private function generateOrderNumber(): string
    {
        return 'ORD-'.Str::upper(Str::random(6));
    }
}

