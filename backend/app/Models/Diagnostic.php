<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Diagnostic extends Model
{
    use HasFactory;

    protected $fillable = [
        'repair_id',
        'problem_description',
        'parts_required',
        'labor_cost',
        'diagnostic_notes',
    ];

    protected $casts = [
        'parts_required' => 'array',
    ];

    public function repair()
    {
        return $this->belongsTo(RepairRequest::class, 'repair_id');
    }
}
