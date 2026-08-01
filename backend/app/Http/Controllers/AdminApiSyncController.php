<?php

namespace App\Http\Controllers;

use App\Models\Category;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class AdminApiSyncController extends Controller
{
    private const SETTINGS_KEY = 'api_sync_settings';

    /* ═══════════════════════════════════════════════════════
     |  Page
     ═══════════════════════════════════════════════════════ */

    public function index()
    {
        $settings = session(self::SETTINGS_KEY, [
            'base_url'    => 'http://127.0.0.1:8000',
            'api_token'   => '',
            'shop_domain' => '127.0.0.1:8000',
        ]);

        // Pre-load data server-side so the table renders instantly (no AJAX on load)
        $initialCategories = $this->buildCategoryRecords();
        $initialProducts   = $this->buildProductRecords();

        return view('admin.api-sync.index', compact('settings', 'initialCategories', 'initialProducts'));
    }

    /* ═══════════════════════════════════════════════════════
     |  Save Settings
     ═══════════════════════════════════════════════════════ */

    public function saveSettings(Request $request)
    {
        $request->validate([
            'base_url'    => ['required', 'url'],
            'api_token'   => ['nullable', 'string'],
            'shop_domain' => ['nullable', 'string'],
        ]);

        $settings = [
            'base_url'    => rtrim($request->string('base_url'), '/'),
            'api_token'   => $request->string('api_token'),
            'shop_domain' => $request->string('shop_domain') ?: '127.0.0.1:8000',
        ];

        session([self::SETTINGS_KEY => $settings]);

        return response()->json(['success' => true, 'message' => 'Settings saved successfully.']);
    }

    /* ═══════════════════════════════════════════════════════
     |  Test Connection
     ═══════════════════════════════════════════════════════ */

    public function testConnect(Request $request)
    {
        $request->validate([
            'base_url'  => ['required', 'url'],
            'api_token' => ['nullable', 'string'],
            'type'      => ['required', 'in:categories,products'],
        ]);

        $url      = rtrim($request->string('base_url'), '/');
        $token    = $request->string('api_token');
        $type     = $request->string('type');
        $endpoint = $url . '/' . $type;

        try {
            $http = Http::timeout(15)->acceptJson();
            if ($token) {
                $http = $http->withToken($token);
            }

            $response = $http->get($endpoint);

            if ($response->failed()) {
                return response()->json([
                    'success' => false,
                    'message' => 'API returned HTTP ' . $response->status() . '. Check URL / token.',
                ], 422);
            }

            $body  = $response->json();
            $items = (is_array($body) && isset($body['data'])) ? $body['data'] : $body;

            if (!is_array($items)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unexpected response format. Expected a JSON array or {"data":[...]}.',
                ], 422);
            }

            return response()->json([
                'success'  => true,
                'message'  => 'Connection successful! Found ' . count($items) . ' ' . $type . '.',
                'count'    => count($items),
                'endpoint' => $endpoint,
                'preview'  => array_slice($items, 0, 5),
            ]);

        } catch (\Illuminate\Http\Client\ConnectionException $e) {
            return response()->json(['success' => false, 'message' => 'Cannot reach server: ' . $e->getMessage()], 422);
        } catch (\Throwable $e) {
            Log::error('AdminApiSyncController@testConnect', ['e' => $e->getMessage()]);
            return response()->json(['success' => false, 'message' => 'Error: ' . $e->getMessage()], 500);
        }
    }

    /* ═══════════════════════════════════════════════════════
     |  Get Local Records (for table display)
     ═══════════════════════════════════════════════════════ */

    public function getLocalRecords(Request $request)
    {
        $type    = $request->string('type', 'categories');
        $records = $type === 'categories'
            ? $this->buildCategoryRecords()
            : $this->buildProductRecords();

        return response()->json([
            'success' => true,
            'type'    => $type,
            'total'   => $records->count(),
            'records' => $records->values(),
        ]);
    }

    /* ═══════════════════════════════════════════════════════
     |  Clear ALL records of a type
     ═══════════════════════════════════════════════════════ */

    public function clearType(string $type)
    {
        try {
            if ($type === 'categories') {
                $count = Category::count();
                Category::query()->delete();
            } elseif ($type === 'products') {
                $count = Product::count();
                Product::query()->delete();
            } else {
                return response()->json(['success' => false, 'message' => 'Unknown type.'], 422);
            }
            return response()->json(['success' => true, 'message' => 'Deleted all ' . $count . ' ' . $type . '.']);
        } catch (\Throwable $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }



    /* ═══════════════════════════════════════════════════════
     |  Delete Local Record
     ═══════════════════════════════════════════════════════ */

    public function deleteRecord(Request $request, string $type, int $id)
    {
        try {
            if ($type === 'categories') {
                Category::findOrFail($id)->delete();
            } elseif ($type === 'products') {
                Product::findOrFail($id)->delete();
            } else {
                return response()->json(['success' => false, 'message' => 'Unknown type.'], 422);
            }

            return response()->json(['success' => true, 'message' => ucfirst($type) . ' #' . $id . ' deleted.']);
        } catch (\Throwable $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    /* ═══════════════════════════════════════════════════════
     |  Sync – Categories
     ═══════════════════════════════════════════════════════ */

    public function syncCategories(Request $request)
    {
        [$items, $errResponse] = $this->fetchFromApi($request, 'categories');
        if ($errResponse) return $errResponse;

        $result = $this->upsertCategories($items);
        return response()->json(array_merge(['success' => true, 'message' => "Categories synced. Created: {$result['created']}, Updated: {$result['updated']}."], $result));
    }

    /* ═══════════════════════════════════════════════════════
     |  Sync – Products
     ═══════════════════════════════════════════════════════ */

    public function syncProducts(Request $request)
    {
        [$items, $errResponse] = $this->fetchFromApi($request, 'products');
        if ($errResponse) return $errResponse;

        $result = $this->upsertProducts($items);
        return response()->json(array_merge(['success' => true, 'message' => "Products synced. Created: {$result['created']}, Updated: {$result['updated']}."], $result));
    }

    /* ═══════════════════════════════════════════════════════
     |  Sync All
     ═══════════════════════════════════════════════════════ */

    public function syncAll(Request $request)
    {
        [$catItems, $catErr] = $this->fetchFromApi($request, 'categories');
        [$prodItems, $prodErr] = $this->fetchFromApi($request, 'products');

        $catResult  = $catItems  ? $this->upsertCategories($catItems)  : ['created' => 0, 'updated' => 0, 'errors' => [], 'failed' => true];
        $prodResult = $prodItems ? $this->upsertProducts($prodItems)   : ['created' => 0, 'updated' => 0, 'errors' => [], 'failed' => true];

        return response()->json([
            'success'    => true,
            'message'    => "All synced — Categories: {$catResult['created']} created / {$catResult['updated']} updated | Products: {$prodResult['created']} created / {$prodResult['updated']} updated.",
            'categories' => $catResult,
            'products'   => $prodResult,
        ]);
    }

    /* ═══════════════════════════════════════════════════════
     |  Private helpers
     ═══════════════════════════════════════════════════════ */

    private function fetchFromApi(Request $request, string $type): array
    {
        $request->validate([
            'base_url'  => ['required', 'url'],
            'api_token' => ['nullable', 'string'],
        ]);

        $url      = rtrim($request->string('base_url'), '/');
        $token    = $request->string('api_token');
        $endpoint = $url . '/' . $type;

        try {
            $http = Http::timeout(30)->acceptJson();
            if ($token) $http = $http->withToken($token);

            $response = $http->get($endpoint);

            if ($response->failed()) {
                return [null, response()->json(['success' => false, 'message' => 'API error HTTP ' . $response->status()], 422)];
            }

            $body  = $response->json();
            $items = (is_array($body) && isset($body['data'])) ? $body['data'] : $body;

            if (!is_array($items)) {
                return [null, response()->json(['success' => false, 'message' => 'Unexpected response format.'], 422)];
            }

            return [$items, null];
        } catch (\Throwable $e) {
            Log::error("ApiSync fetchFromApi({$type})", ['e' => $e->getMessage()]);
            return [null, response()->json(['success' => false, 'message' => 'Error: ' . $e->getMessage()], 500)];
        }
    }

    /* ── Private helpers for building record collections ── */

    private function buildCategoryRecords(): \Illuminate\Support\Collection
    {
        return Category::withCount('products')
            ->orderBy('sort_order')
            ->orderByDesc('id')
            ->get()
            ->map(fn ($c) => [
                'id'             => $c->id,
                'name'           => $c->name,
                'slug'           => $c->slug,
                'status'         => $c->status,
                'sort_order'     => $c->sort_order,
                'products_count' => $c->products_count,
                'created_at'     => $c->created_at?->format('d/m/Y H:i'),
            ]);
    }

    private function buildProductRecords(): \Illuminate\Support\Collection
    {
        return Product::with('category:id,name')
            ->orderByDesc('id')
            ->limit(300)
            ->get()
            ->map(fn ($p) => [
                'id'         => $p->id,
                'name'       => $p->name,
                'sku'        => $p->sku ?? '—',
                'category'   => $p->category?->name ?? '—',
                'price'      => $p->price,
                'stock'      => $p->stock,
                'brand'      => $p->brand ?? '—',
                'status'     => $p->status,
                'created_at' => $p->created_at?->format('d/m/Y H:i'),
            ]);
    }

    private function upsertCategories(array $items): array
    {
        $created = 0; $updated = 0; $errors = [];

        foreach ($items as $i => $item) {
            if (!is_array($item)) continue;
            try {
                $name = trim((string) ($item['name'] ?? $item['category_name'] ?? $item['title'] ?? ''));
                if ($name === '') continue;

                $slug   = $item['slug'] ?? (Str::slug($name) . '-' . Str::random(4));
                $status = $item['status'] ?? 'active';
                $sort   = (int) ($item['sort_order'] ?? $item['order'] ?? 0);

                $existing = Category::where('slug', $slug)->orWhere('name', $name)->first();
                if ($existing) {
                    $existing->update(['name' => $name, 'slug' => $slug, 'status' => $status, 'sort_order' => $sort]);
                    $updated++;
                } else {
                    Category::create(['name' => $name, 'slug' => $slug, 'status' => $status, 'sort_order' => $sort, 'added_by' => auth()->id()]);
                    $created++;
                }
            } catch (\Throwable $e) {
                $errors[] = 'Row #' . ($i + 1) . ': ' . $e->getMessage();
            }
        }

        return compact('created', 'updated', 'errors');
    }

    private function upsertProducts(array $items): array
    {
        $created = 0; $updated = 0; $errors = [];

        foreach ($items as $i => $item) {
            if (!is_array($item)) continue;
            try {
                $name = trim((string) ($item['name'] ?? $item['product_name'] ?? $item['title'] ?? ''));
                if ($name === '') continue;

                $sku = $item['sku'] ?? null;

                $categoryId = null;
                if (!empty($item['category_id'])) {
                    $categoryId = Category::find($item['category_id'])?->id;
                } elseif (!empty($item['category'])) {
                    $catName    = is_array($item['category']) ? ($item['category']['name'] ?? '') : $item['category'];
                    $categoryId = Category::where('name', $catName)->value('id');
                }

                $payload = [
                    'name'        => $name,
                    'description' => $item['description'] ?? null,
                    'sku'         => $sku,
                    'category_id' => $categoryId,
                    'price'       => $item['price'] ?? 0,
                    'stock'       => $item['stock'] ?? $item['quantity'] ?? 0,
                    'status'      => $item['status'] ?? 'active',
                    'brand'       => $item['brand'] ?? null,
                ];

                $existing = $sku ? Product::where('sku', $sku)->first() : null;
                $existing = $existing ?? Product::where('name', $name)->first();

                if ($existing) {
                    $existing->update($payload);
                    $updated++;
                } else {
                    Product::create(array_merge($payload, ['added_by' => auth()->id()]));
                    $created++;
                }
            } catch (\Throwable $e) {
                $errors[] = 'Row #' . ($i + 1) . ': ' . $e->getMessage();
            }
        }

        return compact('created', 'updated', 'errors');
    }
}
