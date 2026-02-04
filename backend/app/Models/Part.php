<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Part extends Model
{
    use HasFactory;

    public const STATUSES = [
        'active',
        'inactive',
        'archived',
    ];

    public const TAGS = [
        'HOT_SALE',
        'TOP_SELLER',
        'PROMOTION',
    ];

    protected $fillable = [
        'name',
        'type',
        'brand',
        'sku',
        'stock',
        'unit_cost',
        'status',
        'tag',
    ];

    protected $casts = [
        'unit_cost' => 'decimal:2',
        'stock' => 'integer',
    ];
}
