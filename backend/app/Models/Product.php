<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    /** @use HasFactory<\Database\Factories\ProductFactory> */
    use HasFactory;

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
