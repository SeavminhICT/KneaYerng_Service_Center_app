<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AdminNotificationCampaign extends Model
{
    use HasFactory;

    protected $fillable = [
        'admin_user_id',
        'type',
        'title',
        'message',
        'audience',
        'custom_user_ids',
        'deep_link',
        'action',
        'status',
        'scheduled_for',
        'summary',
        'meta',
    ];

    protected $casts = [
        'custom_user_ids' => 'array',
        'scheduled_for' => 'datetime',
        'summary' => 'array',
        'meta' => 'array',
    ];

    public function adminUser()
    {
        return $this->belongsTo(User::class, 'admin_user_id');
    }
}
