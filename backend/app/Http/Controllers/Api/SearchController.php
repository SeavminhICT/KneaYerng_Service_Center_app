<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\AccessoryResource;
use App\Http\Resources\CategoryResource;
use App\Http\Resources\ProductResource;
use App\Models\Accessory;
use App\Models\Category;
use App\Models\Product;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;

class SearchController extends Controller
{
    public function suggestions(Request $request)
    {
        $query = $this->sanitizeQuery($request->query('q'));
        $limit = max(1, min((int) $request->integer('limit', 8), 12));

        if ($query === '') {
            return response()->json([
                'query' => '',
                'data' => [],
                'popular_searches' => $this->popularSearches(),
            ]);
        }

        $terms = $this->searchTerms($query);
        $poolLimit = min(60, max($limit * 6, 24));

        $products = Product::query()
            ->with('category')
            ->where('status', 'active')
            ->where(function (Builder $builder) use ($query) {
                $this->applyProductSearch($builder, $query);
            })
            ->orderByDesc('id')
            ->limit($poolLimit)
            ->get()
            ->sortByDesc(fn (Product $product) => $this->productScore($product, $query, $terms))
            ->take($limit)
            ->values();

        $accessories = Accessory::query()
            ->where(function (Builder $builder) use ($query) {
                $this->applyAccessorySearch($builder, $query);
            })
            ->orderByDesc('id')
            ->limit($poolLimit)
            ->get()
            ->sortByDesc(fn (Accessory $accessory) => $this->accessoryScore($accessory, $query, $terms))
            ->take($limit)
            ->values();

        $categories = Category::query()
            ->withCount('products')
            ->where('status', 'active')
            ->where(function (Builder $builder) use ($query) {
                $this->applyCategorySearch($builder, $query);
            })
            ->orderBy('sort_order')
            ->orderBy('name')
            ->limit(12)
            ->get()
            ->sortByDesc(fn (Category $category) => $this->categoryScore($category, $query, $terms))
            ->take(4)
            ->values();

        $brands = $this->matchingBrands($query)->take(4);
        $repairServices = $this->repairServiceMatches($query)->take(4);

        $suggestions = collect()
            ->merge($products->map(function (Product $product) {
                return [
                    'type' => 'product',
                    'label' => $product->name,
                    'value' => $product->name,
                    'subtitle' => $this->joinSubtitle([
                        'Product',
                        $product->brand,
                        $product->category?->name,
                    ]),
                ];
            }))
            ->merge($accessories->map(function (Accessory $accessory) {
                return [
                    'type' => 'accessory',
                    'label' => $accessory->name,
                    'value' => $accessory->name,
                    'subtitle' => $this->joinSubtitle([
                        'Accessory',
                        $accessory->brand,
                    ]),
                ];
            }))
            ->merge($repairServices->map(function (array $service) {
                return [
                    'type' => 'repair',
                    'label' => $service['title'],
                    'value' => $service['title'],
                    'subtitle' => 'Repair service',
                ];
            }))
            ->merge($brands->map(function (string $brand) {
                return [
                    'type' => 'brand',
                    'label' => $brand,
                    'value' => $brand,
                    'subtitle' => 'Brand',
                ];
            }))
            ->merge($categories->map(function (Category $category) {
                return [
                    'type' => 'category',
                    'label' => $category->name,
                    'value' => $category->name,
                    'subtitle' => 'Category',
                ];
            }))
            ->unique(fn (array $item) => strtolower($item['type'].'|'.$item['label']))
            ->take($limit)
            ->values();

        return response()->json([
            'query' => $query,
            'data' => $suggestions,
            'popular_searches' => $this->popularSearches(),
        ]);
    }

    public function results(Request $request)
    {
        $query = $this->sanitizeQuery($request->query('q'));

        if ($query === '') {
            return response()->json([
                'query' => '',
                'products' => [],
                'accessories' => [],
                'categories' => [],
                'brands' => [],
                'repair_services' => [],
                'popular_searches' => $this->popularSearches(),
            ]);
        }

        $terms = $this->searchTerms($query);

        $products = Product::query()
            ->with('category')
            ->where('status', 'active')
            ->where(function (Builder $builder) use ($query) {
                $this->applyProductSearch($builder, $query);
            })
            ->orderByDesc('id')
            ->limit(80)
            ->get()
            ->sortByDesc(fn (Product $product) => $this->productScore($product, $query, $terms))
            ->take(24)
            ->values();

        $accessories = Accessory::query()
            ->where(function (Builder $builder) use ($query) {
                $this->applyAccessorySearch($builder, $query);
            })
            ->orderByDesc('id')
            ->limit(50)
            ->get()
            ->sortByDesc(fn (Accessory $accessory) => $this->accessoryScore($accessory, $query, $terms))
            ->take(16)
            ->values();

        $categories = Category::query()
            ->withCount('products')
            ->where('status', 'active')
            ->where(function (Builder $builder) use ($query) {
                $this->applyCategorySearch($builder, $query);
            })
            ->orderBy('sort_order')
            ->orderBy('name')
            ->limit(20)
            ->get()
            ->sortByDesc(fn (Category $category) => $this->categoryScore($category, $query, $terms))
            ->take(8)
            ->values();

        $brands = $this->matchingBrands($query)->take(8)->values();
        $repairServices = $this->repairServiceMatches($query)->take(8)->values();

        return response()->json([
            'query' => $query,
            'products' => ProductResource::collection($products)->resolve($request),
            'accessories' => AccessoryResource::collection($accessories)->resolve($request),
            'categories' => CategoryResource::collection($categories)->resolve($request),
            'brands' => $brands,
            'repair_services' => $repairServices,
            'popular_searches' => $this->popularSearches(),
        ]);
    }

    private function applyProductSearch(Builder $builder, string $query): void
    {
        foreach ($this->searchTerms($query) as $term) {
            $builder->orWhere(function (Builder $nested) use ($term) {
                $nested->where('name', 'like', '%'.$term.'%')
                    ->orWhere('sku', 'like', '%'.$term.'%')
                    ->orWhere('brand', 'like', '%'.$term.'%')
                    ->orWhere('tag', 'like', '%'.$term.'%')
                    ->orWhere('description', 'like', '%'.$term.'%')
                    ->orWhereHas('category', function (Builder $categoryQuery) use ($term) {
                        $categoryQuery->where('name', 'like', '%'.$term.'%')
                            ->orWhere('slug', 'like', '%'.$term.'%');
                    });
            });
        }
    }

    private function applyAccessorySearch(Builder $builder, string $query): void
    {
        foreach ($this->searchTerms($query) as $term) {
            $builder->orWhere(function (Builder $nested) use ($term) {
                $nested->where('name', 'like', '%'.$term.'%')
                    ->orWhere('brand', 'like', '%'.$term.'%')
                    ->orWhere('tag', 'like', '%'.$term.'%')
                    ->orWhere('description', 'like', '%'.$term.'%');
            });
        }
    }

    private function applyCategorySearch(Builder $builder, string $query): void
    {
        foreach ($this->searchTerms($query) as $term) {
            $builder->orWhere('name', 'like', '%'.$term.'%')
                ->orWhere('slug', 'like', '%'.$term.'%');
        }
    }

    private function matchingBrands(string $query): Collection
    {
        $terms = $this->searchTerms($query);
        $brands = collect();

        foreach ($terms as $term) {
            $products = Product::query()
                ->whereNotNull('brand')
                ->where('brand', 'like', '%'.$term.'%')
                ->pluck('brand');

            $accessories = Accessory::query()
                ->whereNotNull('brand')
                ->where('brand', 'like', '%'.$term.'%')
                ->pluck('brand');

            $brands = $brands->merge($products)->merge($accessories);
        }

        return $brands
            ->filter(fn ($brand) => is_string($brand) && trim($brand) !== '')
            ->map(fn (string $brand) => trim($brand))
            ->unique(fn (string $brand) => strtolower($brand))
            ->sort(function (string $a, string $b) use ($query, $terms) {
                $scoreA = $this->fieldScore($a, $query, $terms, 100, 70, 40, 10);
                $scoreB = $this->fieldScore($b, $query, $terms, 100, 70, 40, 10);

                return $scoreA === $scoreB ? strcasecmp($a, $b) : $scoreB <=> $scoreA;
            })
            ->values();
    }

    private function repairServiceMatches(string $query): Collection
    {
        $terms = $this->searchTerms($query);

        return collect($this->repairServices())
            ->map(function (array $service) use ($query, $terms) {
                $score = $this->fieldScore($service['title'], $query, $terms, 100, 70, 40, 12)
                    + $this->fieldScore(implode(' ', $service['keywords']), $query, $terms, 30, 20, 12, 5)
                    + $this->fieldScore($service['description'], $query, $terms, 10, 7, 4, 1);

                if ($score === 0) {
                    return null;
                }

                $service['score'] = $score;

                return $service;
            })
            ->filter()
            ->sortByDesc('score')
            ->values()
            ->map(function (array $service) {
                unset($service['score']);
                return $service;
            });
    }

    private function searchTerms(string $query): array
    {
        $normalized = $this->sanitizeQuery($query);
        if ($normalized === '') {
            return [];
        }

        $terms = collect([$normalized])
            ->merge(preg_split('/\s+/', $normalized) ?: [])
            ->map(fn ($term) => trim((string) $term))
            ->filter(fn ($term) => $term !== '' && mb_strlen($term) >= 2)
            ->unique()
            ->values()
            ->all();

        return $terms;
    }

    /**
     * Relevance score for a single text field against the query. An exact
     * match scores highest, a prefix match next, then a plain substring
     * match. Individual word matches (e.g. a lone "13") add a small bonus
     * on top so short/generic terms can't outrank a real name match.
     */
    private function fieldScore(?string $haystack, string $query, array $terms, int $exact, int $prefix, int $contains, int $term): int
    {
        $haystack = trim((string) $haystack);
        if ($haystack === '') {
            return 0;
        }

        $h = mb_strtolower($haystack);
        $q = mb_strtolower(trim($query));
        if ($q === '') {
            return 0;
        }

        if ($h === $q) {
            $score = $exact;
        } elseif (str_starts_with($h, $q)) {
            $score = $prefix;
        } elseif (str_contains($h, $q)) {
            $score = $contains;
        } else {
            $score = 0;
        }

        foreach ($terms as $t) {
            $t = mb_strtolower($t);
            if ($t === '' || $t === $q || mb_strlen($t) < 2) {
                continue;
            }
            if (str_contains($h, $t)) {
                $score += $term;
            }
        }

        return $score;
    }

    private function productScore(Product $product, string $query, array $terms): int
    {
        return $this->fieldScore($product->name, $query, $terms, 100, 70, 40, 10)
            + $this->fieldScore($product->sku, $query, $terms, 50, 35, 20, 6)
            + $this->fieldScore($product->category?->name, $query, $terms, 25, 18, 10, 4)
            + $this->fieldScore($product->brand, $query, $terms, 20, 14, 8, 3)
            + $this->fieldScore($product->tag, $query, $terms, 20, 14, 8, 3)
            + $this->fieldScore($product->description, $query, $terms, 10, 7, 4, 1);
    }

    private function accessoryScore(Accessory $accessory, string $query, array $terms): int
    {
        return $this->fieldScore($accessory->name, $query, $terms, 100, 70, 40, 10)
            + $this->fieldScore($accessory->tag, $query, $terms, 20, 14, 8, 3)
            + $this->fieldScore($accessory->brand, $query, $terms, 20, 14, 8, 3)
            + $this->fieldScore($accessory->description, $query, $terms, 10, 7, 4, 1);
    }

    private function categoryScore(Category $category, string $query, array $terms): int
    {
        return $this->fieldScore($category->name, $query, $terms, 100, 70, 40, 10)
            + $this->fieldScore($category->slug, $query, $terms, 40, 28, 16, 4);
    }

    private function sanitizeQuery(?string $value): string
    {
        $query = trim((string) $value);
        if ($query === '') {
            return '';
        }

        return mb_substr(preg_replace('/\s+/', ' ', $query) ?? $query, 0, 80);
    }

    private function popularSearches(): array
    {
        return [
            'iPhone',
            'Samsung',
            'MacBook repair',
            'screen repair',
            'battery replacement',
        ];
    }

    private function joinSubtitle(array $parts): string
    {
        return collect($parts)
            ->filter(fn ($value) => is_string($value) && trim($value) !== '')
            ->map(fn ($value) => trim((string) $value))
            ->implode(' | ');
    }

    private function repairServices(): array
    {
        return [
            [
                'id' => 'iphone-screen-repair',
                'title' => 'iPhone screen repair',
                'description' => 'Display replacement and touch diagnostics for iPhone models.',
                'keywords' => ['iphone', 'screen repair', 'display', 'glass', 'touch'],
            ],
            [
                'id' => 'iphone-battery-replacement',
                'title' => 'iPhone battery replacement',
                'description' => 'Battery health check and safe battery replacement for iPhone devices.',
                'keywords' => ['iphone', 'battery', 'replacement', 'power'],
            ],
            [
                'id' => 'samsung-screen-repair',
                'title' => 'Samsung screen repair',
                'description' => 'OLED and display repair for Samsung phones and tablets.',
                'keywords' => ['samsung', 'screen repair', 'display', 'glass'],
            ],
            [
                'id' => 'samsung-battery-replacement',
                'title' => 'Samsung battery replacement',
                'description' => 'Battery replacement and charging diagnostics for Samsung devices.',
                'keywords' => ['samsung', 'battery', 'replacement', 'charging'],
            ],
            [
                'id' => 'charging-port-repair',
                'title' => 'Charging port repair',
                'description' => 'Charging connector cleaning, repair, and replacement for phones and tablets.',
                'keywords' => ['charging port', 'charger', 'usb', 'lightning', 'type c'],
            ],
            [
                'id' => 'macbook-screen-repair',
                'title' => 'MacBook screen repair',
                'description' => 'Panel replacement and display troubleshooting for MacBook devices.',
                'keywords' => ['macbook', 'screen repair', 'display', 'laptop'],
            ],
            [
                'id' => 'macbook-keyboard-repair',
                'title' => 'MacBook keyboard repair',
                'description' => 'Keyboard, trackpad, and top case repair for MacBook devices.',
                'keywords' => ['macbook', 'keyboard', 'trackpad', 'laptop'],
            ],
            [
                'id' => 'water-damage-cleaning',
                'title' => 'Water damage cleaning',
                'description' => 'Cleaning and diagnostics after liquid damage for phones and laptops.',
                'keywords' => ['water damage', 'liquid', 'cleaning', 'diagnostic'],
            ],
        ];
    }
}
