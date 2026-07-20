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
        '1_DAYS',
        '7_DAYS',
        '14_DAYS',
        '1_MONTH',
        '3_MONTHS',
        '6_MONTHS',
        '1_YEAR',
    ];

    public const TAGS = [
        'HOT_SALE',
        'TOP_SELLER',
        'PROMOTION',
    ];

    public const PRODUCT_TYPES = [
        'mobile',
        'mac',
        'accessory',
    ];

    protected $fillable = [
        'added_by',
        'name',
        'description',
        'sku',
        'category_id',
        'product_type',
        'price',
        'discount',
        'stock',
        'status',
        'tag',
        'brand',
        'warranty',
        'thumbnail',
        'image_gallery',
        'storage_capacity',
        'color',
        'condition',
        'ram',
        'ssd',
        'cpu',
        'display',
        'country',
        'image',
    ];

    protected $casts = [
        'price' => 'decimal:2',
        'discount' => 'decimal:2',
        'image_gallery' => 'array',
        'storage_capacity' => 'array',
        'color' => 'array',
        'condition' => 'array',
        'ram' => 'array',
        'ssd' => 'array',
        'cpu' => 'array',
        'display' => 'array',
        'country' => 'array',
    ];

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function addedBy()
    {
        return $this->belongsTo(User::class, 'added_by');
    }

    public function variants()
    {
        return $this->hasMany(ProductVariant::class)
            ->orderBy('sort_order')
            ->orderBy('id');
    }

}
