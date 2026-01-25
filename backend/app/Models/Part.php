<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Part extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'type',
        'brand',
        'sku',
        'stock',
        'unit_cost',
        'status',
    ];

    protected $casts = [
        'unit_cost' => 'decimal:2',
    ];
}
