<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class OtpVerification extends Model
{
    use HasFactory;

    protected $fillable = [
        'destination_type',
        'destination',
        'purpose',
        'user_id',
        'otp_hash',
        'status',
        'attempts',
        'max_attempts',
        'expires_at',
        'cooldown_until',
        'locked_until',
        'consumed_at',
        'request_ip',
        'device_id',
    ];

    protected $casts = [
        'expires_at' => 'datetime',
        'cooldown_until' => 'datetime',
        'locked_until' => 'datetime',
        'consumed_at' => 'datetime',
    ];
}
