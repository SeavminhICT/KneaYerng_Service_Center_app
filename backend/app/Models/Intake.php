<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Intake extends Model
{
    use HasFactory;

    protected $fillable = [
        'repair_id',
        'imei_serial',
        'device_condition_checklist',
        'intake_photos',
        'notes',
    ];

    protected $casts = [
        'device_condition_checklist' => 'array',
        'intake_photos' => 'array',
    ];

    public function repair()
    {
        return $this->belongsTo(RepairRequest::class, 'repair_id');
    }
}
