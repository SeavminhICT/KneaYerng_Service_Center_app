<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RepairRequest extends Model
{
    use HasFactory;

    protected $fillable = [
        'customer_id',
        'technician_id',
        'device_model',
        'issue_type',
        'service_type',
        'appointment_datetime',
        'status',
    ];

    protected $casts = [
        'appointment_datetime' => 'datetime',
    ];

    public function customer()
    {
        return $this->belongsTo(User::class, 'customer_id');
    }

    public function technician()
    {
        return $this->belongsTo(Technician::class);
    }

    public function intake()
    {
        return $this->hasOne(Intake::class, 'repair_id');
    }

    public function diagnostic()
    {
        return $this->hasOne(Diagnostic::class, 'repair_id');
    }

    public function quotation()
    {
        return $this->hasOne(Quotation::class, 'repair_id');
    }

    public function statusLogs()
    {
        return $this->hasMany(RepairStatusLog::class, 'repair_id')->orderByDesc('logged_at');
    }

    public function partsUsages()
    {
        return $this->hasMany(PartsUsage::class, 'repair_id');
    }

    public function warranty()
    {
        return $this->hasOne(Warranty::class, 'repair_id');
    }

    public function invoice()
    {
        return $this->hasOne(Invoice::class, 'repair_id');
    }

    public function chatMessages()
    {
        return $this->hasMany(ChatMessage::class, 'repair_id')->orderBy('created_at');
    }
}
