<?php

namespace App\Services;

use App\Models\Accessory;
use App\Models\Order;
use App\Models\Part;
use App\Models\Product;
use App\Models\ProductVariant;
use Illuminate\Support\Collection;

class OrderInventoryService
{
    public function deductInventoryForOrder(Order $order): void
    {
        if ($order->inventory_deducted) {
            return;
        }

        $order->loadMissing('items');
        if ($order->items->isEmpty()) {
            $order->inventory_deducted = true;

            return;
        }

        $productIds = [];
        $accessoryIds = [];
        $partIds = [];
        $variantIds = [];

        foreach ($order->items as $item) {
            $itemType = strtolower((string) ($item->item_type ?: ($item->product_id ? 'product' : '')));
            $itemId = (int) ($item->item_id ?: $item->product_id ?: 0);

            if (! $itemId) {
                continue;
            }

            if ($itemType === 'accessory') {
                $accessoryIds[] = $itemId;
            } elseif ($itemType === 'part' || $itemType === 'repair_part') {
                $partIds[] = $itemId;
            } else {
                $productIds[] = $itemId;
                if ($item->product_variant_id) {
                    $variantIds[] = (int) $item->product_variant_id;
                }
            }
        }

        $products = Product::whereIn('id', array_values(array_unique($productIds)))
            ->lockForUpdate()
            ->get()
            ->keyBy('id');
        $accessories = Accessory::whereIn('id', array_values(array_unique($accessoryIds)))
            ->lockForUpdate()
            ->get()
            ->keyBy('id');
        $parts = Part::whereIn('id', array_values(array_unique($partIds)))
            ->lockForUpdate()
            ->get()
            ->keyBy('id');
        $variants = ProductVariant::whereIn('id', array_values(array_unique($variantIds)))
            ->lockForUpdate()
            ->get()
            ->keyBy('id');

        foreach ($order->items as $item) {
            $itemType = strtolower((string) ($item->item_type ?: ($item->product_id ? 'product' : '')));
            $itemId = (int) ($item->item_id ?: $item->product_id ?: 0);

            if (! $itemId) {
                continue;
            }

            $variantId = (int) ($item->product_variant_id ?: 0);
            if ($itemType === 'product' && $variantId > 0) {
                /** @var ProductVariant|null $variant */
                $variant = $variants->get($variantId);
                if (! $variant || (int) $variant->product_id !== $itemId) {
                    throw new \RuntimeException('Selected product variant not found for order item.');
                }

                if ((int) $variant->stock < (int) $item->quantity) {
                    throw new \RuntimeException('Insufficient stock for '.$variant->label().'.');
                }

                continue;
            }

            [$catalogItem, $label] = match ($itemType) {
                'accessory' => [$accessories->get($itemId), 'Accessory'],
                'part', 'repair_part' => [$parts->get($itemId), 'Part'],
                default => [$products->get($itemId), 'Product'],
            };

            if (! $catalogItem) {
                throw new \RuntimeException($label.' not found for order item.');
            }

            if ($catalogItem->stock !== null && (int) $catalogItem->stock < (int) $item->quantity) {
                throw new \RuntimeException('Insufficient stock for '.$catalogItem->name.'.');
            }
        }

        foreach ($order->items as $item) {
            $itemType = strtolower((string) ($item->item_type ?: ($item->product_id ? 'product' : '')));
            $itemId = (int) ($item->item_id ?: $item->product_id ?: 0);

            if (! $itemId) {
                continue;
            }

            $variantId = (int) ($item->product_variant_id ?: 0);
            if ($itemType === 'product' && $variantId > 0) {
                /** @var ProductVariant|null $variant */
                $variant = $variants->get($variantId);
                if (! $variant) {
                    throw new \RuntimeException('Selected product variant not found for order item.');
                }
                $variant->decrement('stock', (int) $item->quantity);

                continue;
            }

            $catalogItem = match ($itemType) {
                'accessory' => $accessories->get($itemId),
                'part', 'repair_part' => $parts->get($itemId),
                default => $products->get($itemId),
            };

            if ($catalogItem && $catalogItem->stock !== null) {
                $catalogItem->decrement('stock', (int) $item->quantity);
            }
        }

        if (! empty($variantIds)) {
            $this->refreshProductVariantAggregates($variants->pluck('product_id')->map(fn ($id) => (int) $id)->all());
        }

        $order->inventory_deducted = true;
    }

    /**
     * @param array<int, int> $productIds
     */
    private function refreshProductVariantAggregates(array $productIds): void
    {
        $ids = array_values(array_unique(array_filter(array_map('intval', $productIds))));
        if (empty($ids)) {
            return;
        }

        $products = Product::query()
            ->whereIn('id', $ids)
            ->lockForUpdate()
            ->get();

        foreach ($products as $product) {
            $variants = ProductVariant::query()
                ->where('product_id', $product->id)
                ->where('is_active', true)
                ->orderBy('sort_order')
                ->orderBy('id')
                ->get();

            if ($variants->isEmpty()) {
                continue;
            }

            $product->stock = (int) $variants->sum('stock');
            $product->price = (float) $variants->min('price');
            $product->storage_capacity = $this->uniqueVariantValues($variants, 'storage_capacity');
            $product->color = $this->uniqueVariantValues($variants, 'color');
            $product->condition = $this->uniqueVariantValues($variants, 'condition');
            $product->ram = $this->uniqueVariantValues($variants, 'ram');
            $product->ssd = $this->uniqueVariantValues($variants, 'ssd');
            $product->save();
        }
    }

    /**
     * @return array<int, string>
     */
    private function uniqueVariantValues(Collection $variants, string $field): array
    {
        return $variants
            ->pluck($field)
            ->map(fn ($value) => trim((string) $value))
            ->filter(fn ($value) => $value !== '')
            ->unique()
            ->values()
            ->all();
    }
}
