<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Voucher extends Model
{
    /** @use HasFactory<\Database\Factories\VoucherFactory> */
    use HasFactory;

    protected $fillable = [
        'code',
        'name',
        'discount_type',
        'discount_value',
        'min_order_amount',
        'starts_at',
        'expires_at',
        'usage_limit_total',
        'usage_limit_per_user',
        'is_active',
        'is_stackable',
        'description',
    ];

    protected $casts = [
        'discount_value' => 'decimal:2',
        'min_order_amount' => 'decimal:2',
        'starts_at' => 'datetime',
        'expires_at' => 'datetime',
        'is_active' => 'boolean',
        'is_stackable' => 'boolean',
    ];

    public function redemptions()
    {
        return $this->hasMany(VoucherRedemption::class);
    }

    public function setCodeAttribute($value): void
    {
        $this->attributes['code'] = strtoupper(trim((string) $value));
    }

    public function setDiscountTypeAttribute($value): void
    {
        $this->attributes['discount_type'] = strtolower(trim((string) $value));
    }
}
