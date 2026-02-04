<?php

namespace App\Http\Controllers;

use App\Models\Category;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class CategoryController extends Controller
{
    public function index(): JsonResponse
    {
        $categories = Category::orderBy('sort_order')
            ->orderBy('id')
            ->get();

        return response()->json($categories);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'slug' => ['nullable', 'string', 'max:255', 'unique:categories,slug'],
            'image' => ['nullable', 'image', 'max:5120'],
            'sort_order' => ['nullable', 'integer', 'min:0'],
        ]);

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
        ]);

        return response()->json([
            'message' => 'Category created successfully',
            'category' => $category,
        ], 201);
    }

    public function show(Category $category): JsonResponse
    {
        return response()->json($category);
    }

    public function update(Request $request, Category $category): JsonResponse
    {
        $validated = $request->validate([
            'name' => ['sometimes', 'required', 'string', 'max:255'],
            'slug' => ['sometimes', 'required', 'string', 'max:255', 'unique:categories,slug,'.$category->id],
            'image' => ['sometimes', 'nullable', 'image', 'max:5120'],
            'sort_order' => ['sometimes', 'required', 'integer', 'min:0'],
        ]);

        if (array_key_exists('name', $validated)) {
            $category->name = $validated['name'];
        }

        if (array_key_exists('slug', $validated)) {
            $category->slug = $validated['slug'];
        } elseif (array_key_exists('name', $validated)) {
        $category->slug = $this->generateUniqueSlug($category->name, $category->id);
        }

        if (array_key_exists('sort_order', $validated)) {
            $category->sort_order = $validated['sort_order'];
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

        return response()->json([
            'message' => 'Category updated successfully',
            'category' => $category,
        ]);
    }

    public function destroy(Category $category): JsonResponse
    {
        if ($category->image) {
            $oldImagePath = str_replace('storage/', '', $category->image);
            Storage::disk('public')->delete($oldImagePath);
        }

        $category->delete();

        return response()->json([
            'message' => 'Category deleted successfully',
        ]);
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
