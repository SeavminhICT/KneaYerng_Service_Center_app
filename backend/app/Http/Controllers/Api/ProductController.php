<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\StoreProductRequest;
use App\Http\Requests\Api\UpdateProductRequest;
use App\Http\Resources\ProductResource;
use App\Models\Product;
use Illuminate\Http\Request;
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

        $thumbnailFile = $request->file('thumbnail') ?? $request->file('image');
        if ($thumbnailFile) {
            $storedPath = $thumbnailFile->store('products/thumbnails', 'public');
            $validated['thumbnail'] = 'storage/'.$storedPath;
        }

        if ($request->hasFile('image_gallery')) {
            $galleryPaths = [];
            foreach ((array) $request->file('image_gallery') as $file) {
                $storedPath = $file->store('products/gallery', 'public');
                $galleryPaths[] = 'storage/'.$storedPath;
            }
            $validated['image_gallery'] = $galleryPaths;
        }

        $product = Product::create($validated);

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
            $existingThumb = $product->thumbnail ?? $product->image;
            if ($existingThumb) {
                $oldPath = str_replace('storage/', '', $existingThumb);
                Storage::disk('public')->delete($oldPath);
            }

            $storedPath = $thumbnailFile->store('products/thumbnails', 'public');
            $validated['thumbnail'] = 'storage/'.$storedPath;
        }

        if ($request->hasFile('image_gallery')) {
            foreach ((array) $product->image_gallery as $oldGalleryPath) {
                if (! $oldGalleryPath) {
                    continue;
                }
                $oldPath = str_replace('storage/', '', $oldGalleryPath);
                Storage::disk('public')->delete($oldPath);
            }

            $galleryPaths = [];
            foreach ((array) $request->file('image_gallery') as $file) {
                $storedPath = $file->store('products/gallery', 'public');
                $galleryPaths[] = 'storage/'.$storedPath;
            }
            $validated['image_gallery'] = $galleryPaths;
        }

        $product->update($validated);

        return new ProductResource($product->load('category'));
    }

    public function destroy(Product $product)
    {
        $existingThumb = $product->thumbnail ?? $product->image;
        if ($existingThumb) {
            $oldPath = str_replace('storage/', '', $existingThumb);
            Storage::disk('public')->delete($oldPath);
        }

        foreach ((array) $product->image_gallery as $oldGalleryPath) {
            if (! $oldGalleryPath) {
                continue;
            }
            $oldPath = str_replace('storage/', '', $oldGalleryPath);
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
}

