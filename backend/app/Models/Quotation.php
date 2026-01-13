<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Quotation extends Model
{
    use HasFactory;

    protected $fillable = [
        'repair_id',
        'parts_cost',
        'labor_cost',
        'total_cost',
        'status',
        'customer_approved_at',
    ];

    protected $casts = [
        'customer_approved_at' => 'datetime',
    ];

    public function repair()
    {
        return $this->belongsTo(RepairRequest::class, 'repair_id');
    }
}
