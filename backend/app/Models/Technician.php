<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Technician extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'skill_set',
        'active_jobs_count',
        'availability_status',
    ];

    protected $casts = [
        'skill_set' => 'array',
    ];

    public function repairs()
    {
        return $this->hasMany(RepairRequest::class);
    }
}
