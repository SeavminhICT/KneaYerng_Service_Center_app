<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Accessory extends Model
{
    /** @use HasFactory<\Database\Factories\AccessoryFactory> */
    use HasFactory;
    use SoftDeletes;

    public const BRANDS = [
        'IPHONE',
        'SAMSUNG',
    ];

    public const WARRANTIES = [
        'NO_WARRANTY',
        '7_DAYS',
        '14_DAYS',
        '1_MONTH',
        '3_MONTHS',
        '6_MONTHS',
        '1_YEAR',
    ];

    protected $fillable = [
        'brand',
        'name',
        'price',
        'discount',
        'description',
        'warranty',
    ];

    protected $casts = [
        'price' => 'decimal:2',
        'discount' => 'decimal:2',
    ];

}
