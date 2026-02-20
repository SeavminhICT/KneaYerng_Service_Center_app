<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\VoucherResource;
use App\Services\VoucherService;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class VoucherValidationController extends Controller
{
    public function __invoke(Request $request)
    {
        $code = $request->input('code')
            ?? $request->input('voucher_code')
            ?? $request->input('promo_code');
        $subtotal = (float) $request->input('subtotal', 0);

        if (! is_string($code) || trim($code) === '') {
            return response()->json([
                'message' => 'Please enter a promo code.',
                'valid' => false,
            ], 422);
        }

        $actor = $request->user() ?? $request->user('sanctum');
        $userId = $actor?->id ?? 0;

        try {
            $voucherService = app(VoucherService::class);
            $voucherData = $voucherService->evaluate($code, $subtotal, $userId);
        } catch (ValidationException $exception) {
            $message = $exception->errors()['voucher_code'][0] ?? 'Voucher code is not valid.';
            return response()->json([
                'message' => $message,
                'valid' => false,
            ], 422);
        }

        if (! $voucherData || empty($voucherData['voucher'])) {
            return response()->json([
                'message' => 'Voucher code is not valid.',
                'valid' => false,
            ], 422);
        }

        $voucher = $voucherData['voucher'];
        $discountAmount = (float) ($voucherData['discount_amount'] ?? 0);

        $payload = (new VoucherResource($voucher))->toArray($request);
        $payload['min_order'] = (float) ($voucher->min_order_amount ?? 0);
        $payload['discount_amount'] = $discountAmount;

        return response()->json([
            'valid' => true,
            'message' => 'Promo code applied successfully.',
            'data' => $payload,
        ]);
    }
}
