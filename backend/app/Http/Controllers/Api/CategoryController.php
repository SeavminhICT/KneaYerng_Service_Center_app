<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\StoreCategoryRequest;
use App\Http\Requests\Api\UpdateCategoryRequest;
use App\Http\Resources\CategoryResource;
use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class CategoryController extends Controller
{
    public function index(Request $request)
    {
        $query = Category::query()->withCount('products')->orderBy('sort_order')->orderBy('id');

        if ($request->filled('q')) {
            $q = $request->string('q');
            $query->where('name', 'like', "%{$q}%");
        }

        $categories = $query->paginate(10)->withQueryString();

        return CategoryResource::collection($categories);
    }

    public function store(StoreCategoryRequest $request)
    {
        $validated = $request->validated();

        $imagePath = null;
        if ($request->hasFile('image')) {
            $storedPath = $request->file('image')->store('categories', 'public');
            $imagePath = 'storage/'.$storedPath;
        }

        $slug = $validated['slug'] ?? $this->generateUniqueSlug($validated['name']);

        $category = Category::create([
            'name' => $validated['name'],
            'slug' => $slug,
            'image' => $imagePath,
            'sort_order' => $validated['sort_order'] ?? 0,
            'status' => $validated['status'] ?? 'active',
        ]);

        return new CategoryResource($category->loadCount('products'));
    }

    public function show(Category $category)
    {
        return new CategoryResource($category->loadCount('products'));
    }

    public function update(UpdateCategoryRequest $request, Category $category)
    {
        $validated = $request->validated();

        if (array_key_exists('name', $validated)) {
            $category->name = $validated['name'];
        }

        if (array_key_exists('slug', $validated) && $validated['slug']) {
            $category->slug = $validated['slug'];
        } elseif (array_key_exists('name', $validated)) {
        $category->slug = $this->generateUniqueSlug($category->name, $category->id);
        }

        if (array_key_exists('sort_order', $validated)) {
            $category->sort_order = $validated['sort_order'];
        }

        if (array_key_exists('status', $validated)) {
            $category->status = $validated['status'];
        }

        if ($request->hasFile('image')) {
            if ($category->image) {
                $oldImagePath = str_replace('storage/', '', $category->image);
                Storage::disk('public')->delete($oldImagePath);
            }

            $storedPath = $request->file('image')->store('categories', 'public');
            $category->image = 'storage/'.$storedPath;
        }

        $category->save();

        return new CategoryResource($category->loadCount('products'));
    }

    public function destroy(Category $category)
    {
        if ($category->image) {
            $oldImagePath = str_replace('storage/', '', $category->image);
            Storage::disk('public')->delete($oldImagePath);
        }

        $category->delete();

        return response()->noContent();
    }

    private function generateUniqueSlug(string $name, ?int $ignoreId = null): string
    {
        $prefix = $this->slugPrefix($name);
        $sequence = $this->nextSlugSequence($prefix, $ignoreId);

        return $prefix.str_pad((string) $sequence, 3, '0', STR_PAD_LEFT);
    }

    private function slugPrefix(string $name): string
    {
        $cleanName = strtoupper(preg_replace('/[^A-Za-z0-9]/', '', $name));
        $prefix = substr($cleanName, 0, 2);
        if (strlen($prefix) < 2) {
            $prefix = str_pad($prefix, 2, 'X');
        }

        return $prefix;
    }

    private function nextSlugSequence(string $prefix, ?int $ignoreId = null): int
    {
        $query = Category::query()->where('slug', 'like', $prefix.'%');

        if ($ignoreId !== null) {
            $query->where('id', '!=', $ignoreId);
        }

        $slugs = $query->pluck('slug');
        $max = 0;
        $pattern = '/^'.preg_quote($prefix, '/').'(\d+)$/';

        foreach ($slugs as $slug) {
            if (!is_string($slug)) {
                continue;
            }
            if (preg_match($pattern, $slug, $matches)) {
                $value = (int) $matches[1];
                if ($value > $max) {
                    $max = $value;
                }
            }
        }

        return $max + 1;
    }
}
