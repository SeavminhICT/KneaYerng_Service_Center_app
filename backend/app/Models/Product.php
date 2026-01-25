<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    /** @use HasFactory<\Database\Factories\ProductFactory> */
    use HasFactory;

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
        'name',
        'description',
        'sku',
        'category_id',
        'price',
        'discount',
        'stock',
        'status',
        'brand',
        'warranty',
        'thumbnail',
        'image_gallery',
        'storage_capacity',
        'color',
        'condition',
        'image',
    ];

    protected $casts = [
        'price' => 'decimal:2',
        'discount' => 'decimal:2',
        'image_gallery' => 'array',
        'storage_capacity' => 'array',
        'color' => 'array',
        'condition' => 'array',
    ];

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

}
