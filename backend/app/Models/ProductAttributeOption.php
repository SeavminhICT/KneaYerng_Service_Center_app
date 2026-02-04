<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ProductAttributeOption extends Model
{
    use HasFactory;

    public const TYPES = [
        'storage_capacity',
        'color',
        'condition',
        'ram',
        'ssd',
        'cpu',
        'display',
        'country',
    ];

    protected $fillable = [
        'type',
        'value',
    ];
}
