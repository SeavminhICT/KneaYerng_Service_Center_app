<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ProductType extends Model
{
    use HasFactory;

    public const FIELD_DEFINITIONS = [
        'display' => [
            'payload_key' => 'display',
            'master_type' => 'display',
            'label' => 'Display',
            'placeholder' => 'Select display',
        ],
        'cpu' => [
            'payload_key' => 'cpu',
            'master_type' => 'cpu',
            'label' => 'CPU',
            'placeholder' => 'Select CPU',
        ],
        'storage' => [
            'payload_key' => 'storage_capacity',
            'master_type' => 'storage_capacity',
            'label' => 'Storage',
            'placeholder' => 'Select storage',
        ],
        'ram' => [
            'payload_key' => 'ram',
            'master_type' => 'ram',
            'label' => 'RAM',
            'placeholder' => 'Select RAM',
        ],
        'ssd' => [
            'payload_key' => 'ssd',
            'master_type' => 'ssd',
            'label' => 'SSD',
            'placeholder' => 'Select SSD',
        ],
        'color' => [
            'payload_key' => 'color',
            'master_type' => 'color',
            'label' => 'Color',
            'placeholder' => 'Select color',
        ],
        'condition' => [
            'payload_key' => 'condition',
            'master_type' => 'condition',
            'label' => 'Condition',
            'placeholder' => 'Select condition',
        ],
        'country' => [
            'payload_key' => 'country',
            'master_type' => 'country',
            'label' => 'Country',
            'placeholder' => 'Select country',
        ],
    ];

    public const DEFAULT_TYPES = [
        [
            'name' => 'Mobile',
            'slug' => 'mobile',
            'fields' => ['storage', 'color', 'condition', 'country'],
            'required_fields' => ['storage', 'color', 'condition'],
            'sort_order' => 10,
        ],
        [
            'name' => 'Mac',
            'slug' => 'mac',
            'fields' => ['display', 'cpu', 'storage', 'ram', 'ssd', 'color', 'condition', 'country'],
            'required_fields' => ['storage', 'color', 'condition'],
            'sort_order' => 20,
        ],
        [
            'name' => 'Accessory',
            'slug' => 'accessory',
            'fields' => ['color'],
            'required_fields' => [],
            'sort_order' => 30,
        ],
    ];

    protected $fillable = [
        'name',
        'slug',
        'fields',
        'required_fields',
        'sort_order',
    ];

    protected $casts = [
        'fields' => 'array',
        'required_fields' => 'array',
        'sort_order' => 'integer',
    ];

    /**
     * @param Builder<ProductType> $query
     * @return Builder<ProductType>
     */
    public function scopeOrdered(Builder $query): Builder
    {
        return $query->orderBy('sort_order')->orderBy('name')->orderBy('id');
    }

    public function products()
    {
        return $this->hasMany(Product::class, 'product_type', 'slug');
    }

    /**
     * @return array<string, array<string, string>>
     */
    public static function fieldDefinitions(): array
    {
        return self::FIELD_DEFINITIONS;
    }

    /**
     * @return list<string>
     */
    public static function fieldKeys(): array
    {
        return array_keys(self::FIELD_DEFINITIONS);
    }

    /**
     * @return list<string>
     */
    public function normalizedFields(): array
    {
        return self::normalizeFieldList($this->fields ?? []);
    }

    /**
     * @return list<string>
     */
    public function normalizedRequiredFields(): array
    {
        $fields = $this->normalizedFields();

        return array_values(array_filter(
            self::normalizeFieldList($this->required_fields ?? []),
            fn (string $field) => in_array($field, $fields, true)
        ));
    }

    /**
     * @param mixed $fields
     * @return list<string>
     */
    public static function normalizeFieldList(mixed $fields): array
    {
        if (! is_array($fields)) {
            return [];
        }

        $allowed = self::fieldKeys();
        $normalized = [];

        foreach ($fields as $field) {
            $field = trim((string) $field);
            if ($field === '' || ! in_array($field, $allowed, true)) {
                continue;
            }
            if (! in_array($field, $normalized, true)) {
                $normalized[] = $field;
            }
        }

        return $normalized;
    }
}
