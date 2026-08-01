<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class QcCheck extends Model
{
    use HasFactory;

    protected $fillable = [
        'repair_id',
        'results',
        'overall_result',
        'notes',
        'checked_by',
        'checked_at',
    ];

    protected $casts = [
        'results' => 'array',
        'checked_at' => 'datetime',
    ];

    public function repair()
    {
        return $this->belongsTo(RepairRequest::class, 'repair_id');
    }

    public function checkedBy()
    {
        return $this->belongsTo(User::class, 'checked_by');
    }
}
