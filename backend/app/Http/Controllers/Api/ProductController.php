<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\StoreProductRequest;
use App\Http\Requests\Api\UpdateProductRequest;
use App\Http\Resources\ProductResource;
use App\Models\Part;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;

class ProductController extends Controller
{
    public function index(Request $request)
    {
        $query = Product::query()->with('category')->orderByDesc('id');

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

        if ($request->boolean('low_stock')) {
            $threshold = (int) ($request->input('threshold', 10));
            $query->where('stock', '<=', $threshold);
        }

        $products = $query->paginate(10)->withQueryString();

        return ProductResource::collection($products);
    }

    public function store(StoreProductRequest $request)
    {
        $validated = $request->validated();
        unset($validated['image'], $validated['thumbnail'], $validated['image_gallery']);

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

        $product = Product::create($validated);
        $this->ensurePartFromProduct($product);

        return new ProductResource($product->load('category'));
    }

    public function show(Product $product)
    {
        return new ProductResource($product->load('category'));
    }

    public function update(UpdateProductRequest $request, Product $product)
    {
        $validated = $request->validated();
        unset($validated['image'], $validated['thumbnail'], $validated['image_gallery']);

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

        $product->update($validated);

        return new ProductResource($product->load('category'));
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

        $product->delete();

        return response()->noContent();
    }

    public function toggleStatus(Product $product)
    {
        $product->status = $product->status === 'active' ? 'draft' : 'active';
        $product->save();

        return new ProductResource($product->load('category'));
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
        $targetExt = $isPng ? 'png' : 'jpg';
        $targetPath = trim($directory, '/').'/'.uniqid('img_', true).'.'.$targetExt;

        $raw = @file_get_contents($file->getRealPath());
        $source = $raw !== false ? @imagecreatefromstring($raw) : false;
        if (! $source) {
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
