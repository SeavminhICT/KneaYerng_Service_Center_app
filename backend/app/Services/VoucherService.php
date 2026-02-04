<?php

namespace App\Services;

use App\Models\Voucher;
use App\Models\VoucherRedemption;
use Illuminate\Validation\ValidationException;

class VoucherService
{
    public function evaluate(?string $code, float $subtotal, int $userId, bool $lock = false): ?array
    {
        $normalized = strtoupper(trim((string) $code));
        if ($normalized === '') {
            return null;
        }

        $query = Voucher::query();
        if ($lock) {
            $query->lockForUpdate();
        }

        $voucher = $query->where('code', $normalized)->first();
        if (! $voucher || ! $voucher->is_active) {
            throw ValidationException::withMessages([
                'voucher_code' => ['Voucher code is invalid or inactive.'],
            ]);
        }

        $now = now();
        if ($voucher->starts_at && $now->lt($voucher->starts_at)) {
            throw ValidationException::withMessages([
                'voucher_code' => ['Voucher is not active yet.'],
            ]);
        }

        if ($voucher->expires_at && $now->gt($voucher->expires_at)) {
            throw ValidationException::withMessages([
                'voucher_code' => ['Voucher has expired.'],
            ]);
        }

        $minOrderAmount = (float) $voucher->min_order_amount;
        if ($minOrderAmount > 0 && $subtotal < $minOrderAmount) {
            throw ValidationException::withMessages([
                'voucher_code' => ['Minimum order amount not met for this voucher.'],
            ]);
        }

        $usageQuery = VoucherRedemption::where('voucher_id', $voucher->id);
        if ($lock) {
            $usageQuery->lockForUpdate();
        }
        $totalUsed = $usageQuery->count();
        if ($voucher->usage_limit_total !== null && $totalUsed >= $voucher->usage_limit_total) {
            throw ValidationException::withMessages([
                'voucher_code' => ['Voucher usage limit reached.'],
            ]);
        }

        $userUsageQuery = VoucherRedemption::where('voucher_id', $voucher->id)
            ->where('user_id', $userId);
        if ($lock) {
            $userUsageQuery->lockForUpdate();
        }
        $userUsed = $userUsageQuery->count();
        if ($voucher->usage_limit_per_user !== null && $userUsed >= $voucher->usage_limit_per_user) {
            throw ValidationException::withMessages([
                'voucher_code' => ['Voucher usage limit reached for this account.'],
            ]);
        }

        $discountAmount = $this->calculateDiscount($voucher, $subtotal);

        return [
            'voucher' => $voucher,
            'discount_amount' => $discountAmount,
        ];
    }

    private function calculateDiscount(Voucher $voucher, float $subtotal): float
    {
        $discountValue = (float) $voucher->discount_value;
        $subtotal = max($subtotal, 0);

        if ($voucher->discount_type === 'percent') {
            $percent = max(0, min(100, $discountValue));
            $amount = $subtotal * ($percent / 100);
        } elseif ($voucher->discount_type === 'fixed') {
            $amount = $discountValue;
        } else {
            throw ValidationException::withMessages([
                'voucher_code' => ['Voucher configuration is invalid.'],
            ]);
        }

        return round(min($amount, $subtotal), 2);
    }
}
