<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RepairStatusLog extends Model
{
    use HasFactory;

    protected $fillable = [
        'repair_id',
        'status',
        'updated_by',
        'logged_at',
    ];

    protected $casts = [
        'logged_at' => 'datetime',
    ];

    public function repair()
    {
        return $this->belongsTo(RepairRequest::class, 'repair_id');
    }

    public function updatedBy()
    {
        return $this->belongsTo(User::class, 'updated_by');
    }
}
