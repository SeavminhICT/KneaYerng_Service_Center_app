<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\Api\AdminMetricsController;
use App\Http\Controllers\Api\AccessoryController;
use App\Http\Controllers\Api\BannerController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\PaymentController;
use App\Http\Controllers\Api\ProductController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::prefix('auth')->group(function () {
    Route::post('register', [AuthController::class, 'register']);
    Route::post('verify-otp', [AuthController::class, 'verifyOtp']);
    Route::post('resend-otp', [AuthController::class, 'resendOtp']);
    Route::post('login', [AuthController::class, 'login']);
    Route::post('logout', [AuthController::class, 'logout'])->middleware('auth:sanctum');
    Route::put('user/update', [AuthController::class, 'update'])->middleware('auth:sanctum');
});

Route::prefix('public')->group(function () {
    Route::get('categories', [CategoryController::class, 'index']);
    Route::get('categories/{category}', [CategoryController::class, 'show']);
    Route::get('products', [ProductController::class, 'index']);
    Route::get('products/{product}', [ProductController::class, 'show']);
});

Route::get('banners', [BannerController::class, 'publicIndex']);
Route::get('banners/{banner}', [BannerController::class, 'show']);

Route::get('categories', [CategoryController::class, 'index']);
Route::get('categories/{category}', [CategoryController::class, 'show']);
Route::get('products', [ProductController::class, 'index']);
Route::get('products/{product}', [ProductController::class, 'show']);
Route::get('accessories', [AccessoryController::class, 'index']);
Route::get('accessories/{accessory}', [AccessoryController::class, 'show']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('user/orders', [OrderController::class, 'store']);
    Route::get('user/orders/{order}', [OrderController::class, 'show']);
    Route::post('payments', [PaymentController::class, 'store']);
});

Route::post('payments/callback', [PaymentController::class, 'callback']);

Route::middleware('admin')->group(function () {
    Route::get('admin/metrics', AdminMetricsController::class);
    Route::get('orders', [OrderController::class, 'index']);
    Route::get('orders/{order}', [OrderController::class, 'show']);
    Route::post('admin/orders/{order}/qr', [OrderController::class, 'generatePickupQr']);
    Route::post('admin/orders/verify-qr', [OrderController::class, 'verifyPickupQr']);
    Route::get('admin/banners', [BannerController::class, 'index']);
    Route::apiResource('admin/banners', BannerController::class)->except(['index', 'show']);
    Route::apiResource('categories', CategoryController::class)->except(['index', 'show']);
    Route::apiResource('products', ProductController::class)->except(['index', 'show']);
    Route::apiResource('accessories', AccessoryController::class)->except(['index', 'show']);
    Route::patch('products/{product}/status', [ProductController::class, 'toggleStatus']);
    Route::apiResource('orders', OrderController::class);
});
