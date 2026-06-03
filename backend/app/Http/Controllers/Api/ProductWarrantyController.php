<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ProductWarranty;
use App\Services\ProductWarrantyService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class ProductWarrantyController extends Controller
{
    public function __construct(private ProductWarrantyService $warrantyService)
    {
    }

    // ── Customer: list own warranties ────────────────────────────────────────

    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        // Backfill any completed orders that don't have warranty records yet
        $this->warrantyService->syncForUser($user->id);

        ProductWarranty::syncExpiredStatuses();

        $status = $request->input('status');
        $query  = ProductWarranty::query()
            ->where('user_id', $user->id)
            ->with(['order:id,order_number,placed_at', 'product:id,name,thumbnail'])
            ->orderByDesc('created_at');

        if (in_array($status, ['active', 'expired', 'void'], true)) {
            $query->where('status', $status);
        }

        $warranties = $query->get()->map(fn ($w) => $this->format($w));

        return response()->json(['data' => $warranties]);
    }

    // ── Customer: single warranty ────────────────────────────────────────────

    public function show(Request $request, ProductWarranty $productWarranty): JsonResponse
    {
        if ((int) $productWarranty->user_id !== (int) $request->user()->id) {
            return response()->json(['message' => 'Forbidden.'], 403);
        }

        ProductWarranty::syncExpiredStatuses();

        return response()->json($this->format($productWarranty->fresh(['order', 'product'])));
    }

    // ── Admin: list all warranties ───────────────────────────────────────────

    public function adminIndex(Request $request): JsonResponse
    {
        Gate::authorize('admin-access');

        ProductWarranty::syncExpiredStatuses();

        $query = ProductWarranty::query()
            ->with(['user:id,first_name,last_name,email', 'order:id,order_number,placed_at', 'product:id,name,thumbnail'])
            ->orderByDesc('created_at');

        if ($s = $request->input('status')) {
            $query->where('status', strtolower($s));
        }
        if ($search = $request->input('search')) {
            $query->where(function ($q) use ($search) {
                $q->where('product_name', 'like', "%{$search}%")
                  ->orWhereHas('user', fn ($uq) => $uq->where('email', 'like', "%{$search}%")
                      ->orWhere('first_name', 'like', "%{$search}%"));
            });
        }

        $perPage = min(50, max(1, (int) $request->input('per_page', 20)));
        $result  = $query->paginate($perPage)->withQueryString();

        return response()->json([
            'data'  => collect($result->items())->map(fn ($w) => $this->formatAdmin($w)),
            'meta'  => [
                'current_page' => $result->currentPage(),
                'last_page'    => $result->lastPage(),
                'total'        => $result->total(),
            ],
        ]);
    }

    // ── Admin: void a warranty ───────────────────────────────────────────────

    public function void(Request $request, ProductWarranty $productWarranty): JsonResponse
    {
        Gate::authorize('admin-access');

        $request->validate(['notes' => ['nullable', 'string', 'max:500']]);

        $productWarranty->update([
            'status' => 'void',
            'notes'  => $request->input('notes'),
        ]);

        return response()->json($this->formatAdmin($productWarranty->fresh()));
    }

    // ── Formatting helpers ───────────────────────────────────────────────────

    private function format(ProductWarranty $w): array
    {
        return [
            'id'             => $w->id,
            'product_name'   => $w->product_name,
            'variant_label'  => $w->variant_label,
            'warranty_period'=> $w->warranty_period,
            'period_label'   => ProductWarrantyService::PERIOD_LABELS[$w->warranty_period] ?? $w->warranty_period,
            'duration_days'  => $w->duration_days,
            'start_date'     => $w->start_date?->toDateString(),
            'end_date'       => $w->end_date?->toDateString(),
            'days_remaining' => $w->days_remaining,
            'progress_percent' => $w->progress_percent,
            'status'         => $w->status,
            'is_active'      => $w->is_active,
            'order_number'   => $w->order?->order_number,
            'order_id'       => $w->order_id,
            'product_thumbnail' => $w->product?->thumbnail,
            'created_at'     => $w->created_at?->toISOString(),
        ];
    }

    private function formatAdmin(ProductWarranty $w): array
    {
        $base = $this->format($w);
        $base['customer_name']  = trim(($w->user?->first_name ?? '').' '.($w->user?->last_name ?? ''));
        $base['customer_email'] = $w->user?->email;
        $base['notes']          = $w->notes;
        return $base;
    }
}
