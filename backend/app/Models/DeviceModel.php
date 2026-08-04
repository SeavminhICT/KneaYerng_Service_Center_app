<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DeviceModel extends Model
{
    use HasFactory;

    protected $fillable = [
        'added_by',
        'brand',
        'model_name',
        'sort_order',
        'status',
    ];

    public function repairRequests()
    {
        return $this->hasMany(RepairRequest::class, 'device_model_id');
    }

    public function addedBy()
    {
        return $this->belongsTo(User::class, 'added_by');
    }
}
