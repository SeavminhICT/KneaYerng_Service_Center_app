<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\StoreProductAttributeOptionRequest;
use App\Http\Requests\Api\UpdateProductAttributeOptionRequest;
use App\Http\Resources\ProductAttributeOptionResource;
use App\Models\ProductAttributeOption;
use Illuminate\Http\Request;

class ProductAttributeOptionController extends Controller
{
    public function index(Request $request)
    {
        $query = ProductAttributeOption::query()->orderBy('value');

        if ($request->filled('type')) {
            $query->where('type', $request->string('type'));
        }

        $options = $query->get();

        return ProductAttributeOptionResource::collection($options);
    }

    public function store(StoreProductAttributeOptionRequest $request)
    {
        $validated = $request->validated();

        $option = ProductAttributeOption::firstOrCreate([
            'type' => $validated['type'],
            'value' => $validated['value'],
        ]);

        return new ProductAttributeOptionResource($option);
    }

    public function update(
        UpdateProductAttributeOptionRequest $request,
        ProductAttributeOption $productAttributeOption
    ) {
        $validated = $request->validated();

        $productAttributeOption->update($validated);

        return new ProductAttributeOptionResource($productAttributeOption->fresh());
    }

    public function destroy(ProductAttributeOption $productAttributeOption)
    {
        $productAttributeOption->delete();

        return response()->json(['message' => 'Option deleted.']);
    }
}
