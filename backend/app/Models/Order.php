<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    use HasFactory;

    protected $fillable = [
        'order_number',
        'user_id',
        'customer_name',
        'customer_email',
        'order_type',
        'payment_method',
        'delivery_address',
        'delivery_phone',
        'delivery_note',
        'subtotal',
        'delivery_fee',
        'voucher_id',
        'voucher_code',
        'discount_type',
        'discount_value',
        'discount_amount',
        'pickup_qr_token',
        'pickup_qr_generated_at',
        'pickup_verified_at',
        'total_amount',
        'payment_status',
        'status',
        'inventory_deducted',
        'placed_at',
    ];

    protected $casts = [
        'placed_at' => 'datetime',
        'pickup_qr_generated_at' => 'datetime',
        'pickup_verified_at' => 'datetime',
        'subtotal' => 'decimal:2',
        'delivery_fee' => 'decimal:2',
        'discount_value' => 'decimal:2',
        'discount_amount' => 'decimal:2',
        'total_amount' => 'decimal:2',
        'inventory_deducted' => 'boolean',
    ];

    public function items()
    {
        return $this->hasMany(OrderItem::class);
    }

    public function payments()
    {
        return $this->hasMany(Payment::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function voucher()
    {
        return $this->belongsTo(Voucher::class);
    }
}
