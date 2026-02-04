<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\StoreVoucherRequest;
use App\Http\Requests\Api\UpdateVoucherRequest;
use App\Http\Resources\VoucherResource;
use App\Models\Voucher;
use Illuminate\Http\Request;

class VoucherController extends Controller
{
    public function index(Request $request)
    {
        $query = Voucher::query()->withCount('redemptions')->orderByDesc('id');

        if ($request->filled('q')) {
            $q = $request->string('q');
            $query->where(function ($builder) use ($q) {
                $builder->where('code', 'like', "%{$q}%")
                    ->orWhere('name', 'like', "%{$q}%");
            });
        }

        if ($request->filled('active')) {
            $active = filter_var($request->input('active'), FILTER_VALIDATE_BOOLEAN, FILTER_NULL_ON_FAILURE);
            if ($active !== null) {
                $query->where('is_active', $active);
            }
        }

        $perPage = (int) $request->input('per_page', 10);
        $perPage = max(1, min(50, $perPage));

        $vouchers = $query->paginate($perPage)->withQueryString();

        return VoucherResource::collection($vouchers);
    }

    public function store(StoreVoucherRequest $request)
    {
        $validated = $request->validated();

        $voucher = Voucher::create([
            'code' => $validated['code'],
            'name' => $validated['name'] ?? null,
            'discount_type' => $validated['discount_type'],
            'discount_value' => $validated['discount_value'],
            'min_order_amount' => $validated['min_order_amount'] ?? 0,
            'starts_at' => $validated['starts_at'] ?? null,
            'expires_at' => $validated['expires_at'] ?? null,
            'usage_limit_total' => $validated['usage_limit_total'] ?? null,
            'usage_limit_per_user' => $validated['usage_limit_per_user'] ?? null,
            'is_active' => array_key_exists('is_active', $validated) ? (bool) $validated['is_active'] : true,
            'is_stackable' => array_key_exists('is_stackable', $validated) ? (bool) $validated['is_stackable'] : false,
            'description' => $validated['description'] ?? null,
        ]);

        return new VoucherResource($voucher->loadCount('redemptions'));
    }

    public function show(Voucher $voucher)
    {
        return new VoucherResource($voucher->loadCount('redemptions'));
    }

    public function update(UpdateVoucherRequest $request, Voucher $voucher)
    {
        $validated = $request->validated();

        $voucher->fill($validated);

        if (array_key_exists('min_order_amount', $validated) && $validated['min_order_amount'] === null) {
            $voucher->min_order_amount = 0;
        }

        $voucher->save();

        return new VoucherResource($voucher->loadCount('redemptions'));
    }

    public function destroy(Voucher $voucher)
    {
        $voucher->delete();

        return response()->noContent();
    }
}
