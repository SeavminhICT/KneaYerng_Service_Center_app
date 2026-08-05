<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PartsUsage extends Model
{
    use HasFactory;

    protected $fillable = [
        'repair_id',
        'part_id',
        'quantity',
        'cost',
    ];

    protected $casts = [
        'quantity' => 'integer',
        'cost' => 'decimal:2',
    ];

    public function repair()
    {
        return $this->belongsTo(RepairRequest::class, 'repair_id');
    }

    public function part()
    {
        return $this->belongsTo(Part::class);
    }
}
