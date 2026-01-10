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
        'pickup_qr_token',
        'pickup_qr_generated_at',
        'pickup_verified_at',
        'total_amount',
        'payment_status',
        'status',
        'placed_at',
    ];

    protected $casts = [
        'placed_at' => 'datetime',
        'pickup_qr_generated_at' => 'datetime',
        'pickup_verified_at' => 'datetime',
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
}

