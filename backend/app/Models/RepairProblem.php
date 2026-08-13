<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RepairProblem extends Model
{
    use HasFactory;

    protected $fillable = [
        'added_by',
        'name',
        'service_fee',
        'sort_order',
        'status',
    ];

    protected $casts = [
        'service_fee' => 'decimal:2',
    ];

    public function repairRequests()
    {
        return $this->belongsToMany(RepairRequest::class, 'repair_request_problems', 'problem_id', 'repair_id');
    }

    public function addedBy()
    {
        return $this->belongsTo(User::class, 'added_by');
    }
}
