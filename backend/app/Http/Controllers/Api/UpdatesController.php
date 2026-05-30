<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Product;
use App\Models\Banner;
use App\Models\Accessory;
use Illuminate\Http\JsonResponse;
use Carbon\Carbon;

class UpdatesController extends Controller
{
    /**
     * Get the latest update timestamps for critical cacheable resources.
     *
     * @return JsonResponse
     */
    public function check(): JsonResponse
    {
        $formatTime = function ($dateTime) {
            if (!$dateTime) {
                return '1970-01-01T00:00:00Z';
            }
            return Carbon::parse($dateTime)->toIso8601String();
        };

        return response()->json([
            'data' => [
                'categories' => $formatTime(Category::max('updated_at')),
                'products' => $formatTime(Product::max('updated_at')),
                'banners' => $formatTime(Banner::max('updated_at')),
                'accessories' => $formatTime(Accessory::max('updated_at')),
            ]
        ]);
    }
}
