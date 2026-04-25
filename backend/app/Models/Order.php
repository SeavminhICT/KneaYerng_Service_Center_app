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
        'assigned_staff_id',
        'approved_by',
        'approved_at',
        'rejected_by',
        'rejected_at',
        'rejected_reason',
        'cancelled_by',
        'cancelled_at',
        'cancelled_reason',
        'customer_name',
        'customer_email',
        'order_type',
        'payment_method',
        'delivery_address',
        'delivery_phone',
        'delivery_note',
        'delivery_lat',
        'delivery_lng',
        'subtotal',
        'delivery_fee',
        'voucher_id',
        'voucher_code',
        'discount_type',
        'discount_value',
        'discount_amount',
        'pickup_qr_token',
        'pickup_qr_generated_at',
        'pickup_qr_expires_at',
        'pickup_verified_at',
        'pickup_verified_by',
        'total_amount',
        'payment_status',
        'status',
        'current_status_at',
        'inventory_deducted',
        'placed_at',
        'telegram_chat_id',
        'telegram_message_id',
        'telegram_last_action',
        'telegram_last_action_by',
        'telegram_last_action_at',
        'telegram_message_sent_at',
    ];

    protected $casts = [
        'placed_at' => 'datetime',
        'approved_at' => 'datetime',
        'rejected_at' => 'datetime',
        'cancelled_at' => 'datetime',
        'current_status_at' => 'datetime',
        'pickup_qr_generated_at' => 'datetime',
        'pickup_qr_expires_at' => 'datetime',
        'pickup_verified_at' => 'datetime',
        'subtotal' => 'decimal:2',
        'delivery_fee' => 'decimal:2',
        'delivery_lat' => 'decimal:7',
        'delivery_lng' => 'decimal:7',
        'discount_value' => 'decimal:2',
        'discount_amount' => 'decimal:2',
        'total_amount' => 'decimal:2',
        'inventory_deducted' => 'boolean',
        'telegram_last_action_at' => 'datetime',
        'telegram_message_sent_at' => 'datetime',
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

    public function assignedStaff()
    {
        return $this->belongsTo(User::class, 'assigned_staff_id');
    }

    public function approver()
    {
        return $this->belongsTo(User::class, 'approved_by');
    }

    public function rejector()
    {
        return $this->belongsTo(User::class, 'rejected_by');
    }

    public function canceller()
    {
        return $this->belongsTo(User::class, 'cancelled_by');
    }

    public function voucher()
    {
        return $this->belongsTo(Voucher::class);
    }

    public function pickupVerifier()
    {
        return $this->belongsTo(User::class, 'pickup_verified_by');
    }

    public function trackingHistories()
    {
        return $this->hasMany(OrderTrackingHistory::class)->orderBy('created_at');
    }

    public function trackingNotifications()
    {
        return $this->hasMany(OrderTrackingNotification::class);
    }
}
