<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RepairNotification extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'repair_id',
        'type',
        'title',
        'body',
        'read_at',
    ];

    protected $casts = [
        'read_at' => 'datetime',
    ];

    public function repair()
    {
        return $this->belongsTo(RepairRequest::class, 'repair_id');
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
