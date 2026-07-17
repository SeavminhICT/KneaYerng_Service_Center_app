<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class MobileDeviceToken extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'guest_device_id',
        'token',
        'platform',
        'device_name',
        'app_version',
        'last_used_at',
    ];

    protected $casts = [
        'last_used_at' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
