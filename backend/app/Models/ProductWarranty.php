<?php

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class ProductWarranty extends Model
{
    use HasFactory;

    protected $fillable = [
        'order_id',
        'order_item_id',
        'user_id',
        'product_id',
        'product_name',
        'variant_label',
        'warranty_period',
        'duration_days',
        'start_date',
        'end_date',
        'status',
        'notes',
    ];

    protected $casts = [
        'start_date' => 'date',
        'end_date'   => 'date',
    ];

    protected $appends = ['days_remaining', 'is_active', 'progress_percent'];

    // ── Relationships ────────────────────────────────────────────────────────

    public function order()
    {
        return $this->belongsTo(Order::class);
    }

    public function orderItem()
    {
        return $this->belongsTo(OrderItem::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function product()
    {
        return $this->belongsTo(Product::class);
    }

    // ── Computed attributes ──────────────────────────────────────────────────

    public function getDaysRemainingAttribute(): int
    {
        if ($this->status !== 'active') {
            return 0;
        }
        $remaining = (int) now()->startOfDay()->diffInDays($this->end_date, false);
        return max(0, $remaining);
    }

    public function getIsActiveAttribute(): bool
    {
        return $this->status === 'active' && $this->end_date >= now()->startOfDay();
    }

    public function getProgressPercentAttribute(): float
    {
        if ($this->duration_days === 0) {
            return 100.0;
        }
        $elapsed = (int) $this->start_date->diffInDays(now()->startOfDay(), false);
        $percent = ($elapsed / $this->duration_days) * 100;
        return round(min(100, max(0, $percent)), 1);
    }

    // ── Sync expired statuses ────────────────────────────────────────────────

    public static function syncExpiredStatuses(): int
    {
        return static::query()
            ->where('status', 'active')
            ->where('end_date', '<', now()->startOfDay())
            ->update(['status' => 'expired']);
    }
}
