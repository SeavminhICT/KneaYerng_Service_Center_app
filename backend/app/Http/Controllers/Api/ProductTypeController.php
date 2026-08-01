<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\StoreProductTypeRequest;
use App\Http\Requests\Api\UpdateProductTypeRequest;
use App\Http\Resources\ProductTypeResource;
use App\Models\Product;
use App\Models\ProductType;
use Illuminate\Http\Request;

class ProductTypeController extends Controller
{
    public function index(Request $request)
    {
        $query = ProductType::query()->withCount('products')->ordered();

        return ProductTypeResource::collection($query->get())
            ->additional(['fields' => ProductType::fieldDefinitions()]);
    }

    public function store(StoreProductTypeRequest $request)
    {
        $validated = $request->validated();
        $validated['fields'] = ProductType::normalizeFieldList($validated['fields'] ?? []);
        $validated['required_fields'] = ProductType::normalizeFieldList($validated['required_fields'] ?? []);

        $productType = ProductType::create($validated);

        return (new ProductTypeResource($productType))
            ->response()
            ->setStatusCode(201);
    }

    public function update(UpdateProductTypeRequest $request, ProductType $productType)
    {
        $validated = $request->validated();
        $validated['fields'] = ProductType::normalizeFieldList($validated['fields'] ?? []);
        $validated['required_fields'] = ProductType::normalizeFieldList($validated['required_fields'] ?? []);

        $productType->update($validated);

        return new ProductTypeResource($productType->fresh());
    }

    public function destroy(ProductType $productType)
    {
        if (ProductType::query()->count() <= 1) {
            return response()->json(['message' => 'At least one product type is required.'], 422);
        }

        if (Product::query()->where('product_type', $productType->slug)->exists()) {
            return response()->json(['message' => 'This product type is used by products and cannot be deleted.'], 422);
        }

        $productType->delete();

        return response()->json(['message' => 'Product type deleted.']);
    }
}
