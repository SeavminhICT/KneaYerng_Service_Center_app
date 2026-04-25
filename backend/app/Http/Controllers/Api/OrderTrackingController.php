<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\OrderResource;
use App\Http\Resources\OrderTrackingHistoryResource;
use App\Http\Resources\OrderTrackingNotificationResource;
use App\Models\Order;
use App\Models\OrderTrackingNotification;
use App\Models\User;
use App\Services\OrderTrackingService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class OrderTrackingController extends Controller
{
    public function __construct(
        private readonly OrderTrackingService $trackingService
    ) {
    }

    public function myOrders(Request $request)
    {
        $actor = $this->requireActor($request);

        $query = Order::query()
            ->where('user_id', $actor->id)
            ->with([
                'assignedStaff',
                'trackingHistories.actor',
                'trackingHistories.assignedStaff',
                'items',
                'payments',
            ])
            ->orderByDesc('placed_at')
            ->orderByDesc('id');

        if ($request->filled('order_type')) {
            $query->where('order_type', $request->string('order_type'));
        }

        return OrderResource::collection($query->get());
    }

    public function timeline(Request $request, Order $order)
    {
        $actor = $this->requireActor($request);
        $this->authorizeOrderAccess($actor, $order);

        $order->load([
            'assignedStaff',
            'trackingHistories.actor',
            'trackingHistories.assignedStaff',
        ]);

        return response()->json([
            'data' => [
                'order_id' => $order->id,
                'status' => $order->status,
                'timeline' => $this->trackingService->buildTimeline($order),
                'history' => OrderTrackingHistoryResource::collection($order->trackingHistories),
            ],
        ]);
    }

    public function staffAssigned(Request $request)
    {
        $actor = $this->requireActor($request);
        if (! $actor->isStaff()) {
            return response()->json(['message' => 'Forbidden.'], 403);
        }

        $orders = Order::query()
            ->where('assigned_staff_id', $actor->id)
            ->where('order_type', 'delivery')
            ->with([
                'assignedStaff',
                'trackingHistories.actor',
                'trackingHistories.assignedStaff',
                'items',
                'payments',
            ])
            ->orderByDesc('current_status_at')
            ->orderByDesc('id')
            ->get();

        return OrderResource::collection($orders);
    }

    public function approve(Request $request, Order $order)
    {
        $actor = $this->requireActor($request);
        $this->ensureAdmin($actor);
        $this->ensureTrackedDelivery($order);

        DB::transaction(function () use ($order, $actor) {
            $this->trackingService->transition($order, OrderTrackingService::STATUS_APPROVED, $actor, [
                'note' => 'Approved by admin.',
            ]);
        });

        return new OrderResource($this->freshTrackedOrder($order));
    }

    public function reject(Request $request, Order $order)
    {
        $actor = $this->requireActor($request);
        $this->ensureAdmin($actor);
        $this->ensureTrackedDelivery($order);

        $validated = $request->validate([
            'reason' => ['required', 'string', 'max:1000'],
        ]);

        DB::transaction(function () use ($order, $actor, $validated) {
            $this->trackingService->transition($order, OrderTrackingService::STATUS_REJECTED, $actor, [
                'note' => $validated['reason'],
            ]);
        });

        return new OrderResource($this->freshTrackedOrder($order));
    }

    public function assign(Request $request, Order $order)
    {
        $actor = $this->requireActor($request);
        $this->ensureAdmin($actor);
        $this->ensureTrackedDelivery($order);

        $validated = $request->validate([
            'staff_user_id' => ['required', 'exists:users,id'],
            'note' => ['nullable', 'string', 'max:1000'],
            'override' => ['nullable', 'boolean'],
        ]);

        $staff = User::findOrFail($validated['staff_user_id']);

        DB::transaction(function () use ($order, $staff, $actor, $validated) {
            $this->trackingService->assignStaff(
                $order,
                $staff,
                $actor,
                $validated['note'] ?? null,
                (bool) ($validated['override'] ?? false)
            );
        });

        return new OrderResource($this->freshTrackedOrder($order));
    }

    public function updateStatus(Request $request, Order $order)
    {
        $actor = $this->requireActor($request);
        $this->ensureAdmin($actor);
        $this->ensureTrackedDelivery($order);

        $validated = $request->validate([
            'status' => ['required', 'string'],
            'note' => ['nullable', 'string', 'max:1000'],
            'override' => ['nullable', 'boolean'],
        ]);

        DB::transaction(function () use ($order, $actor, $validated) {
            $this->trackingService->transition($order, $validated['status'], $actor, [
                'note' => $validated['note'] ?? null,
                'override' => (bool) ($validated['override'] ?? false),
            ]);
        });

        return new OrderResource($this->freshTrackedOrder($order));
    }

    public function acceptAssigned(Request $request, Order $order)
    {
        $actor = $this->requireActor($request);
        if (! $actor->isStaff() || (int) $order->assigned_staff_id !== (int) $actor->id) {
            return response()->json(['message' => 'Forbidden.'], 403);
        }

        $this->ensureTrackedDelivery($order);

        DB::transaction(function () use ($order, $actor) {
            $this->trackingService->transition($order, OrderTrackingService::STATUS_IN_PROGRESS, $actor, [
                'note' => 'Staff accepted the task.',
            ]);
        });

        return new OrderResource($this->freshTrackedOrder($order));
    }

    public function staffUpdateStatus(Request $request, Order $order)
    {
        $actor = $this->requireActor($request);
        if (! $actor->isStaff() || (int) $order->assigned_staff_id !== (int) $actor->id) {
            return response()->json(['message' => 'Forbidden.'], 403);
        }

        $this->ensureTrackedDelivery($order);

        $validated = $request->validate([
            'status' => ['required', 'in:in_progress,on_the_way,arrived,completed'],
            'note' => ['nullable', 'string', 'max:1000'],
        ]);

        DB::transaction(function () use ($order, $actor, $validated) {
            $this->trackingService->transition($order, $validated['status'], $actor, [
                'note' => $validated['note'] ?? null,
            ]);
        });

        return new OrderResource($this->freshTrackedOrder($order));
    }

    public function notifications(Request $request)
    {
        $actor = $this->requireActor($request);

        $perPage = (int) $request->input('per_page', 20);
        $perPage = max(1, min(50, $perPage));

        $notifications = OrderTrackingNotification::query()
            ->where('user_id', $actor->id)
            ->orderByDesc('created_at')
            ->paginate($perPage)
            ->withQueryString();

        return OrderTrackingNotificationResource::collection($notifications);
    }

    public function markNotificationRead(Request $request, OrderTrackingNotification $notification)
    {
        $actor = $this->requireActor($request);
        if ((int) $notification->user_id !== (int) $actor->id) {
            return response()->json(['message' => 'Forbidden.'], 403);
        }

        if (! $notification->read_at) {
            $notification->read_at = now();
            $notification->save();
        }

        return new OrderTrackingNotificationResource($notification);
    }

    public function staffOptions(Request $request)
    {
        $actor = $this->requireActor($request);
        $this->ensureAdmin($actor);

        $staff = User::query()
            ->whereIn('role', ['staff', 'technician'])
            ->orderBy('first_name')
            ->orderBy('last_name')
            ->get(['id', 'first_name', 'last_name', 'email', 'phone', 'role']);

        return response()->json([
            'data' => $staff->map(fn (User $user) => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'phone' => $user->phone,
                'role' => $user->role,
            ])->values(),
        ]);
    }

    private function freshTrackedOrder(Order $order): Order
    {
        return $order->fresh([
            'assignedStaff',
            'approver',
            'rejector',
            'canceller',
            'trackingHistories.actor',
            'trackingHistories.assignedStaff',
            'items',
            'payments',
        ]);
    }

    private function requireActor(Request $request): User
    {
        $actor = $request->user() ?? $request->user('sanctum');
        abort_unless($actor instanceof User, 401, 'Unauthorized.');

        return $actor;
    }

    private function authorizeOrderAccess(User $actor, Order $order): void
    {
        if ($actor->isAdmin()) {
            return;
        }

        if ($actor->isStaff() && (int) $order->assigned_staff_id === (int) $actor->id) {
            return;
        }

        abort_unless((int) $order->user_id === (int) $actor->id, 403, 'Forbidden.');
    }

    private function ensureAdmin(User $actor): void
    {
        abort_unless($actor->isAdmin(), 403, 'Forbidden.');
    }

    private function ensureTrackedDelivery(Order $order): void
    {
        abort_unless($this->trackingService->isTrackedDelivery($order), 422, 'Tracking workflow is only for delivery orders.');
    }
}
