<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\StoreProductRequest;
use App\Http\Requests\Api\UpdateProductRequest;
use App\Http\Resources\ProductResource;
use App\Models\Part;
use App\Models\Product;
use App\Models\ProductVariant;
use App\Services\RemoveBgService;
use Illuminate\Http\Request;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\ValidationException;

class ProductController extends Controller
{
    public function index(Request $request)
    {
        $relations = ['category', 'addedBy'];
        if ($this->variantsEnabled()) {
            $relations['variants'] = fn ($builder) => $builder->orderBy('sort_order')->orderBy('id');
        }

        $query = Product::query()
            ->with($relations)
            ->orderByDesc('id');

        if ($request->filled('q')) {
            $q = $request->string('q');
            $query->where(function ($builder) use ($q) {
                $builder->where('name', 'like', "%{$q}%")
                    ->orWhere('sku', 'like', "%{$q}%");
            });
        }

        if ($request->filled('status')) {
            $query->where('status', $request->string('status'));
        }

        if ($request->filled('brand')) {
            $query->where('brand', $request->string('brand'));
        }

        if ($request->filled('warranty')) {
            $query->where('warranty', $request->string('warranty'));
        }

        if ($request->filled('tag')) {
            $query->where('tag', strtoupper(str_replace([' ', '-'], '_', trim((string) $request->string('tag')))));
        }

        if ($request->filled('category_id')) {
            $query->where('category_id', $request->integer('category_id'));
        }

        if ($request->filled('category')) {
            $category = trim((string) $request->string('category'));
            $query->whereHas('category', function ($builder) use ($category) {
                $builder->where('name', 'like', $category)
                    ->orWhere('slug', 'like', $category);
            });
        }

        if ($request->boolean('low_stock')) {
            $threshold = (int) ($request->input('threshold', 10));
            $query->where('stock', '<=', $threshold);
        }

        $perPageInput = $request->input('per_page', 25);
        if ($perPageInput === 'all' || (int) $perPageInput === -1) {
            $perPage = 10000;
        } else {
            $perPage = max(1, min((int) $perPageInput, 10000));
        }

        $products = $query->paginate($perPage)->withQueryString();

        return ProductResource::collection($products);
    }

    public function bulkAction(Request $request)
    {
        $validated = $request->validate([
            'action' => ['required', 'string', 'in:activate,deactivate,archive,delete'],
            'ids' => ['required', 'array', 'min:1'],
            'ids.*' => ['integer'],
        ]);

        $action = $validated['action'];
        $ids = $validated['ids'];

        if ($action === 'activate') {
            Product::whereIn('id', $ids)->update(['status' => 'active']);
            return response()->json(['message' => count($ids) . ' product(s) activated successfully.']);
        }

        if ($action === 'deactivate') {
            Product::whereIn('id', $ids)->update(['status' => 'draft']);
            return response()->json(['message' => count($ids) . ' product(s) set to draft.']);
        }

        if ($action === 'archive') {
            Product::whereIn('id', $ids)->update(['status' => 'archived']);
            return response()->json(['message' => count($ids) . ' product(s) archived successfully.']);
        }

        if ($action === 'delete') {
            $actor = $request->user() ?? $request->user('sanctum') ?? auth('web')->user();
            if ($actor && ! ($actor->isAdmin() || (method_exists($actor, 'hasPermission') && $actor->hasPermission('delete_product')) || (method_exists($actor, 'hasPermissionTo') && $actor->hasPermissionTo('delete_product')))) {
                return response()->json(['message' => 'Unauthorized to delete products.'], 403);
            }

            $products = Product::whereIn('id', $ids)->get();
            foreach ($products as $p) {
                $p->delete();
            }

            return response()->json(['message' => count($products) . ' product(s) deleted successfully.']);
        }

        return response()->json(['message' => 'Invalid bulk action.'], 422);
    }

    public function store(StoreProductRequest $request)
    {
        $validated = $request->validated();
        $variantRows = $this->normalizeVariantRows((array) ($validated['variants'] ?? []));

        if (! empty($variantRows) && ! $this->variantsEnabled()) {
            $this->throwVariantsTableMissing();
        }

        unset(
            $validated['image'],
            $validated['thumbnail'],
            $validated['image_gallery'],
            $validated['variants'],
            $validated['variant_images']
        );

        if (! empty($variantRows)) {
            $this->applyVariantDerivedFields($validated, $variantRows);
        }

        if (empty($validated['sku'])) {
            $validated['sku'] = $this->generateSku($validated['name'] ?? '', $validated['brand'] ?? null);
        }

        $thumbnailFile = $request->file('thumbnail') ?? $request->file('image');
        if ($thumbnailFile) {
            $validated['thumbnail'] = $this->storeOptimizedImage($thumbnailFile, 'products/thumbnails');
        }

        if ($request->hasFile('image_gallery')) {
            $galleryPaths = [];
            foreach ((array) $request->file('image_gallery') as $file) {
                $galleryPaths[] = $this->storeOptimizedImage($file, 'products/gallery');
            }
            $validated['image_gallery'] = $galleryPaths;
        }

        $actor = $request->user() ?? $request->user('sanctum');
        $validated['added_by'] = $actor?->id;

        $product = Product::create($validated);
        $this->syncVariants(
            $product,
            $variantRows,
            (array) $request->file('variant_images')
        );
        $this->ensurePartFromProduct($product);

        return new ProductResource($this->loadProductRelations($product));
    }

    public function show(Product $product)
    {
        return new ProductResource($this->loadProductRelations($product));
    }

    public function update(UpdateProductRequest $request, Product $product)
    {
        $validated = $request->validated();
        $hasVariantsPayload = array_key_exists('variants', $validated);
        $variantRows = $this->normalizeVariantRows((array) ($validated['variants'] ?? []));

        if ($hasVariantsPayload && ! empty($variantRows) && ! $this->variantsEnabled()) {
            $this->throwVariantsTableMissing();
        }

        unset(
            $validated['image'],
            $validated['thumbnail'],
            $validated['image_gallery'],
            $validated['variants'],
            $validated['variant_images']
        );

        $thumbnailFile = $request->file('thumbnail') ?? $request->file('image');
        if ($thumbnailFile) {
            $existingThumb = $this->firstNonEmptyPath($product->thumbnail, $product->image);
            if ($existingThumb) {
                $oldPath = $this->toStorageRelativePath($existingThumb);
                Storage::disk('public')->delete($oldPath);
            }

            $validated['thumbnail'] = $this->storeOptimizedImage($thumbnailFile, 'products/thumbnails');
        }

        if ($request->hasFile('image_gallery')) {
            foreach ((array) $product->image_gallery as $oldGalleryPath) {
                if (! $oldGalleryPath) {
                    continue;
                }
                $oldPath = $this->toStorageRelativePath($oldGalleryPath);
                Storage::disk('public')->delete($oldPath);
            }

            $galleryPaths = [];
            foreach ((array) $request->file('image_gallery') as $file) {
                $galleryPaths[] = $this->storeOptimizedImage($file, 'products/gallery');
            }
            $validated['image_gallery'] = $galleryPaths;
        }

        if ($hasVariantsPayload) {
            $this->applyVariantDerivedFields($validated, $variantRows);
        }

        $product->update($validated);
        if ($hasVariantsPayload) {
            $this->syncVariants(
                $product,
                $variantRows,
                (array) $request->file('variant_images')
            );
        }

        return new ProductResource($this->loadProductRelations($product));
    }

    public function destroy(Product $product)
    {
        $existingThumb = $this->firstNonEmptyPath($product->thumbnail, $product->image);
        if ($existingThumb) {
            $oldPath = $this->toStorageRelativePath($existingThumb);
            Storage::disk('public')->delete($oldPath);
        }

        foreach ((array) $product->image_gallery as $oldGalleryPath) {
            if (! $oldGalleryPath) {
                continue;
            }
            $oldPath = $this->toStorageRelativePath($oldGalleryPath);
            Storage::disk('public')->delete($oldPath);
        }

        if ($this->variantsEnabled()) {
            foreach ($product->variants as $variant) {
                if ($variant->image) {
                    $oldPath = $this->toStorageRelativePath($variant->image);
                    Storage::disk('public')->delete($oldPath);
                }
            }
        }

        $product->delete();

        return response()->noContent();
    }

    public function toggleStatus(Product $product)
    {
        $product->status = $product->status === 'active' ? 'draft' : 'active';
        $product->save();

        return new ProductResource($this->loadProductRelations($product));
    }

    private function generateSku(string $name, ?string $brand): string
    {
        $cleanName = strtoupper(preg_replace('/[^A-Za-z0-9]/', '', $name));
        $namePart = substr($cleanName, 0, 2);
        if (strlen($namePart) < 2) {
            $namePart = str_pad($namePart, 2, 'X');
        }

        $cleanBrand = strtoupper(preg_replace('/[^A-Za-z0-9]/', '', (string) $brand));
        if ($cleanBrand === '') {
            $cleanBrand = 'NA';
        }

        $prefix = $namePart.$cleanBrand;
        $sequence = $this->nextSkuSequence($prefix);

        return $prefix.str_pad((string) $sequence, 3, '0', STR_PAD_LEFT);
    }

    private function nextSkuSequence(string $prefix): int
    {
        $skus = Product::query()
            ->where('sku', 'like', $prefix.'%')
            ->pluck('sku');

        $max = 0;
        $pattern = '/^'.preg_quote($prefix, '/').'(\d+)$/';

        foreach ($skus as $sku) {
            if (!is_string($sku)) {
                continue;
            }
            if (preg_match($pattern, $sku, $matches)) {
                $value = (int) $matches[1];
                if ($value > $max) {
                    $max = $value;
                }
            }
        }

        return $max + 1;
    }

    private function ensurePartFromProduct(Product $product): void
    {
        $sku = $product->sku;
        if ($sku) {
            $existing = Part::query()->where('sku', $sku)->exists();
            if ($existing) {
                return;
            }
        } else {
            $query = Part::query()
                ->where('type', 'product')
                ->where('name', $product->name);

            if ($product->brand) {
                $query->where('brand', $product->brand);
            }

            if ($query->exists()) {
                return;
            }
        }

        Part::create([
            'name' => $product->name,
            'type' => 'product',
            'brand' => $product->brand,
            'sku' => $sku,
            'stock' => (int) ($product->stock ?? 0),
            'unit_cost' => (float) ($product->price ?? 0),
            'status' => $this->mapProductStatusToPartStatus($product->status),
            'tag' => $product->tag,
        ]);
    }

    /**
     * @param array<int, mixed> $rawRows
     * @return array<int, array<string, mixed>>
     */
    private function normalizeVariantRows(array $rawRows): array
    {
        $rows = [];

        foreach ($rawRows as $index => $rawRow) {
            if (! is_array($rawRow)) {
                continue;
            }

            $storage = trim((string) ($rawRow['storage_capacity'] ?? ''));
            $color = trim((string) ($rawRow['color'] ?? ''));
            $condition = trim((string) ($rawRow['condition'] ?? ''));
            $ram = trim((string) ($rawRow['ram'] ?? ''));
            $ssd = trim((string) ($rawRow['ssd'] ?? ''));
            $cpu = trim((string) ($rawRow['cpu'] ?? ''));
            $display = trim((string) ($rawRow['display'] ?? ''));
            $country = trim((string) ($rawRow['country'] ?? ''));
            $sku = trim((string) ($rawRow['sku'] ?? ''));
            $image = trim((string) ($rawRow['image'] ?? ''));
            $hasPrice = is_numeric($rawRow['price'] ?? null);
            $hasStock = is_numeric($rawRow['stock'] ?? null);
            $price = $hasPrice ? (float) $rawRow['price'] : 0.0;
            $stock = $hasStock ? (int) $rawRow['stock'] : 0;

            $hasIdentity = $storage !== '' || $color !== '' || $condition !== ''
                || $ram !== '' || $ssd !== '' || $cpu !== '' || $display !== ''
                || $country !== '' || $sku !== '';

            if (! $hasIdentity && ! $hasPrice && ! $hasStock) {
                continue;
            }

            $rows[] = [
                '__row_index' => (int) $index,
                'storage_capacity' => $storage !== '' ? $storage : null,
                'color' => $color !== '' ? $color : null,
                'condition' => $condition !== '' ? $condition : null,
                'ram' => $ram !== '' ? $ram : null,
                'ssd' => $ssd !== '' ? $ssd : null,
                'cpu' => $cpu !== '' ? $cpu : null,
                'display' => $display !== '' ? $display : null,
                'country' => $country !== '' ? $country : null,
                'price' => max($price, 0),
                'stock' => max($stock, 0),
                'sku' => $sku !== '' ? $sku : null,
                'image' => $image !== '' ? $image : null,
            ];
        }

        return $rows;
    }

    /**
     * @param array<string, mixed> $validated
     * @param array<int, array<string, mixed>> $variantRows
     */
    private function applyVariantDerivedFields(array &$validated, array $variantRows): void
    {
        if (empty($variantRows)) {
            $validated['storage_capacity'] = [];
            $validated['color'] = [];
            $validated['condition'] = [];
            $validated['ram'] = [];
            $validated['ssd'] = [];
            $validated['cpu'] = [];
            $validated['display'] = [];
            $validated['country'] = [];

            return;
        }

        $prices = array_map(fn ($row) => (float) ($row['price'] ?? 0), $variantRows);
        $stocks = array_map(fn ($row) => (int) ($row['stock'] ?? 0), $variantRows);

        $validated['price'] = min($prices);
        $validated['stock'] = array_sum($stocks);

        $validated['storage_capacity'] = $this->uniqueVariantValues($variantRows, 'storage_capacity');
        $validated['color'] = $this->uniqueVariantValues($variantRows, 'color');
        $validated['condition'] = $this->uniqueVariantValues($variantRows, 'condition');
        $validated['ram'] = $this->uniqueVariantValues($variantRows, 'ram');
        $validated['ssd'] = $this->uniqueVariantValues($variantRows, 'ssd');
        $validated['cpu'] = $this->uniqueVariantValues($variantRows, 'cpu');
        $validated['display'] = $this->uniqueVariantValues($variantRows, 'display');
        $validated['country'] = $this->uniqueVariantValues($variantRows, 'country');
    }

    /**
     * @param array<int, array<string, mixed>> $variantRows
     * @return array<int, string>
     */
    private function uniqueVariantValues(array $variantRows, string $key): array
    {
        $values = [];
        foreach ($variantRows as $row) {
            $value = trim((string) ($row[$key] ?? ''));
            if ($value === '') {
                continue;
            }
            if (! in_array($value, $values, true)) {
                $values[] = $value;
            }
        }

        return $values;
    }

    /**
     * @param array<int, array<string, mixed>> $variantRows
     * @param array<int|string, UploadedFile> $variantImageFiles
     */
    private function syncVariants(Product $product, array $variantRows, array $variantImageFiles): void
    {
        if (! $this->variantsEnabled()) {
            return;
        }

        $retainedImages = [];
        foreach ($variantRows as $row) {
            $rowIndex = (int) ($row['__row_index'] ?? 0);
            $imageFile = $variantImageFiles[$rowIndex] ?? null;
            if ($imageFile instanceof UploadedFile) {
                continue;
            }
            $existingImage = trim((string) ($row['image'] ?? ''));
            if ($existingImage === '') {
                continue;
            }
            $retainedImages[] = $this->toStorageRelativePath($existingImage);
        }

        foreach ($product->variants as $existingVariant) {
            if ($existingVariant->image) {
                $oldPath = $this->toStorageRelativePath($existingVariant->image);
                if (! in_array($oldPath, $retainedImages, true)) {
                    Storage::disk('public')->delete($oldPath);
                }
            }
        }
        $product->variants()->delete();

        if (empty($variantRows)) {
            return;
        }

        foreach ($variantRows as $order => $row) {
            $rowIndex = (int) ($row['__row_index'] ?? $order);
            unset($row['__row_index']);

            $imageFile = $variantImageFiles[$rowIndex] ?? null;
            if ($imageFile instanceof UploadedFile) {
                $row['image'] = $this->storeOptimizedImage(
                    $imageFile,
                    'products/variants'
                );
            }

            $row['sort_order'] = $order;
            $row['is_active'] = true;

            $product->variants()->create($row);
        }
    }

    private function loadProductRelations(Product $product): Product
    {
        $relations = ['category', 'addedBy'];
        if ($this->variantsEnabled()) {
            $relations['variants'] = fn ($builder) => $builder->orderBy('sort_order')->orderBy('id');
        }

        return $product->load($relations);
    }

    private function variantsEnabled(): bool
    {
        static $exists = null;

        if ($exists === null) {
            $exists = Schema::hasTable((new ProductVariant())->getTable());
        }

        return $exists;
    }

    private function throwVariantsTableMissing(): void
    {
        throw ValidationException::withMessages([
            'variants' => ['Product variants table is missing. Please run migrations first.'],
        ]);
    }

    private function mapProductStatusToPartStatus(?string $status): string
    {
        if ($status === 'draft') {
            return 'inactive';
        }

        if ($status === 'archived') {
            return 'archived';
        }

        return 'active';
    }

    private function firstNonEmptyPath(?string ...$paths): ?string
    {
        foreach ($paths as $path) {
            if (is_string($path) && trim($path) !== '') {
                return $path;
            }
        }

        return null;
    }

    private function toStorageRelativePath(string $path): string
    {
        $clean = trim(str_replace('\\', '/', $path));

        if (str_starts_with($clean, 'http://') || str_starts_with($clean, 'https://')) {
            $parsed = parse_url($clean, PHP_URL_PATH);
            if (is_string($parsed)) {
                $clean = $parsed;
            }
        }

        $clean = ltrim($clean, '/');
        if (str_starts_with($clean, 'storage/')) {
            $clean = substr($clean, strlen('storage/'));
        }

        return $clean;
    }

    private function storeOptimizedImage(UploadedFile $file, string $directory): string
    {
        $disk = 'public';
        $extension = strtolower($file->getClientOriginalExtension() ?: $file->extension() ?: 'jpg');
        $isPng = $extension === 'png';

        $raw = @file_get_contents($file->getRealPath());

        $bgRemoved = $raw !== false
            ? app(RemoveBgService::class)->removeBackground($raw)
            : null;
        if ($bgRemoved !== null) {
            $raw = $bgRemoved;
            $isPng = true;
        }

        $targetExt = $isPng ? 'png' : 'jpg';
        $targetPath = trim($directory, '/').'/'.uniqid('img_', true).'.'.$targetExt;

        $source = $raw !== false ? @imagecreatefromstring($raw) : false;
        if (! $source) {
            if ($bgRemoved !== null) {
                Storage::disk($disk)->put($targetPath, $bgRemoved);

                return 'storage/'.$targetPath;
            }

            $storedPath = $file->store($directory, $disk);

            return 'storage/'.$storedPath;
        }

        $width = imagesx($source);
        $height = imagesy($source);
        $maxSide = 1600;
        $ratio = min($maxSide / max($width, 1), $maxSide / max($height, 1), 1);
        $newWidth = max(1, (int) round($width * $ratio));
        $newHeight = max(1, (int) round($height * $ratio));

        $canvas = imagecreatetruecolor($newWidth, $newHeight);
        if ($isPng) {
            imagealphablending($canvas, false);
            imagesavealpha($canvas, true);
            $transparent = imagecolorallocatealpha($canvas, 0, 0, 0, 127);
            imagefilledrectangle($canvas, 0, 0, $newWidth, $newHeight, $transparent);
        }

        imagecopyresampled($canvas, $source, 0, 0, 0, 0, $newWidth, $newHeight, $width, $height);

        ob_start();
        if ($isPng) {
            imagepng($canvas, null, 8);
        } else {
            imagejpeg($canvas, null, 78);
        }
        $encoded = ob_get_clean();

        imagedestroy($canvas);
        imagedestroy($source);

        if (! is_string($encoded) || $encoded === '') {
            $storedPath = $file->store($directory, $disk);
            return 'storage/'.$storedPath;
        }

        Storage::disk($disk)->put($targetPath, $encoded);

        return 'storage/'.$targetPath;
    }
}
