<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Part extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'sku',
        'stock',
        'unit_cost',
        'status',
    ];

    public function usages()
    {
        return $this->hasMany(PartsUsage::class);
    }
}
