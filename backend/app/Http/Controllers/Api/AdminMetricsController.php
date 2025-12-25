<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\Product;
use App\Models\User;
use Illuminate\Support\Facades\Gate;

class AdminMetricsController extends Controller
{
    public function __invoke()
    {
        Gate::authorize('admin-access');

        return response()->json([
            'total_sales' => (float) Order::sum('total_amount'),
            'total_orders' => Order::count(),
            'total_products' => Product::count(),
            'total_customers' => User::count(),
        ]);
    }
}
