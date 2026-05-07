<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ProductVariant extends Model
{
    use HasFactory;

    protected $fillable = [
        'product_id',
        'storage_capacity',
        'color',
        'condition',
        'ram',
        'ssd',
        'price',
        'stock',
        'sku',
        'image',
        'is_active',
        'sort_order',
    ];

    protected $casts = [
        'price' => 'decimal:2',
        'stock' => 'integer',
        'is_active' => 'boolean',
        'sort_order' => 'integer',
    ];

    public function product()
    {
        return $this->belongsTo(Product::class);
    }

    public function label(): string
    {
        $parts = [
            trim((string) $this->storage_capacity),
            trim((string) $this->color),
            trim((string) $this->condition),
        ];

        return implode(' / ', array_values(array_filter($parts, fn ($value) => $value !== '')));
    }
}
