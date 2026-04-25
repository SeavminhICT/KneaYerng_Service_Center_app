<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\AuthOtpController;
use App\Http\Controllers\Api\AdminMetricsController;
use App\Http\Controllers\Api\AdminUserController;
use App\Http\Controllers\Api\AccessoryController;
use App\Http\Controllers\Api\BannerController;
use App\Http\Controllers\Api\CartController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\CheckoutOptionsController;
use App\Http\Controllers\Api\AdminReportsController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\OrderTrackingController;
use App\Http\Controllers\Api\OtpController;
use App\Http\Controllers\Api\PaymentController;
use App\Http\Controllers\Api\KhqrPaymentController;
use App\Http\Controllers\Api\MediaController;
use App\Http\Controllers\Api\MobileDeviceController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\RepairChatController;
use App\Http\Controllers\Api\RepairDiagnosticController;
use App\Http\Controllers\Api\RepairIntakeController;
use App\Http\Controllers\Api\RepairInvoiceController;
use App\Http\Controllers\Api\RepairNotificationController;
use App\Http\Controllers\Api\RepairPaymentController;
use App\Http\Controllers\Api\RepairQuotationController;
use App\Http\Controllers\Api\RepairRequestController;
use App\Http\Controllers\Api\RepairWarrantyController;
use App\Http\Controllers\Api\SearchController;
use App\Http\Controllers\Api\SupportChatController;
use App\Http\Controllers\Api\TelegramOrderController;
use App\Http\Controllers\Api\TelegramWebhookController;
use App\Http\Controllers\Api\TechnicianController;
use App\Http\Controllers\Api\VoucherController;
use App\Http\Controllers\Api\VoucherValidationController;
use App\Http\Controllers\Api\PartController;
use App\Http\Controllers\Api\ProductAttributeOptionController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::prefix('auth')->group(function () {
    Route::post('send-otp', [AuthOtpController::class, 'sendOtp']);
    Route::post('verify-otp', [AuthOtpController::class, 'verifyOtp']);
    Route::post('register', [AuthController::class, 'register']);
    Route::post('login', [AuthController::class, 'login']);
    Route::post('logout', [AuthController::class, 'logout'])->middleware('auth:sanctum');
    Route::put('user/update', [AuthController::class, 'update'])->middleware('auth:sanctum');
});

Route::post('otp/request', [OtpController::class, 'request']);
Route::post('otp/verify', [OtpController::class, 'verify']);
Route::post('otp/firebase/verify', [OtpController::class, 'verifyFirebasePhone']);
Route::post('password/reset-with-otp', [OtpController::class, 'resetPassword']);
Route::post('telegram/webhook', TelegramWebhookController::class);

Route::prefix('public')->group(function () {
    Route::get('categories', [CategoryController::class, 'index']);
    Route::get('categories/{category}', [CategoryController::class, 'show']);
    Route::get('products', [ProductController::class, 'index']);
    Route::get('products/{product}', [ProductController::class, 'show']);
});

Route::get('banners', [BannerController::class, 'publicIndex']);
Route::get('banners/{banner}', [BannerController::class, 'show']);
Route::get('media/{path}', MediaController::class)->where('path', '.*');
Route::get('search/suggestions', [SearchController::class, 'suggestions']);
Route::get('search/results', [SearchController::class, 'results']);

// Keep validation routes above voucher resource routes to avoid shadowing.
Route::get('vouchers/validate', VoucherValidationController::class);
Route::post('vouchers/validate', VoucherValidationController::class);

Route::get('categories', [CategoryController::class, 'index']);
Route::get('categories/{category}', [CategoryController::class, 'show']);
Route::get('products', [ProductController::class, 'index']);
Route::get('products/{product}', [ProductController::class, 'show']);
Route::get('accessories', [AccessoryController::class, 'index']);
Route::get('accessories/{accessory}', [AccessoryController::class, 'show']);
Route::get('checkout/options', CheckoutOptionsController::class);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('cart', [CartController::class, 'show']);
    Route::post('cart/items', [CartController::class, 'addItem']);
    Route::patch('cart/items/{cartItem}', [CartController::class, 'updateItem']);
    Route::delete('cart/items/{cartItem}', [CartController::class, 'destroyItem']);
    Route::post('cart/checkout', [CartController::class, 'checkout']);
    Route::post('user/orders', [OrderController::class, 'store']);
    Route::get('user/orders', [OrderTrackingController::class, 'myOrders']);
    Route::get('user/tickets', [OrderController::class, 'myTickets']);
    Route::get('user/orders/{order}', [OrderController::class, 'show']);
    Route::get('user/orders/{order}/tracking', [OrderTrackingController::class, 'timeline']);
    Route::post('mobile-devices/token', [MobileDeviceController::class, 'store']);
    Route::post('mobile-devices/token/remove', [MobileDeviceController::class, 'destroy']);
    Route::get('staff/orders/assigned', [OrderTrackingController::class, 'staffAssigned']);
    Route::post('staff/orders/{order}/accept', [OrderTrackingController::class, 'acceptAssigned']);
    Route::post('staff/orders/{order}/status', [OrderTrackingController::class, 'staffUpdateStatus']);
    Route::get('order-notifications', [OrderTrackingController::class, 'notifications']);
    Route::post('order-notifications/{notification}/read', [OrderTrackingController::class, 'markNotificationRead']);
    Route::post('payments', [PaymentController::class, 'store']);
    Route::post('generate-qr', [KhqrPaymentController::class, 'generateQr']);
    Route::post('check-transaction', [KhqrPaymentController::class, 'checkTransaction']);
    Route::post('repairs', [RepairRequestController::class, 'store']);
    Route::get('repairs/my', [RepairRequestController::class, 'my']);
    Route::get('repairs/{repair}', [RepairRequestController::class, 'show']);
    Route::get('repairs/{repair}/quotation', [RepairQuotationController::class, 'show']);
    Route::post('quotations/{quotation}/approve', [RepairQuotationController::class, 'approve']);
    Route::post('quotations/{quotation}/reject', [RepairQuotationController::class, 'reject']);
    Route::post('payments/deposit', [RepairPaymentController::class, 'storeDeposit']);
    Route::post('payments/final', [RepairPaymentController::class, 'storeFinal']);
    Route::get('repairs/{repair}/status-timeline', [RepairRequestController::class, 'statusTimeline']);
    Route::get('repairs/{repair}/chat', [RepairChatController::class, 'index']);
    Route::post('repairs/{repair}/chat', [RepairChatController::class, 'store']);
    Route::get('repairs/{repair}/warranty', [RepairWarrantyController::class, 'show']);
    Route::get('invoices/{invoice}', [RepairInvoiceController::class, 'show']);
    Route::get('invoices/{invoice}/payments', [RepairPaymentController::class, 'paymentsForInvoice']);
    Route::get('notifications', [RepairNotificationController::class, 'index']);
    Route::get('support/conversation', [SupportChatController::class, 'showOrCreateConversation']);
    Route::post('support/messages', [SupportChatController::class, 'storeCustomerMessage']);
    Route::post('support/read', [SupportChatController::class, 'markCustomerRead']);
    Route::get('support/unread-count', [SupportChatController::class, 'customerUnreadCount']);
});

Route::post('payments/callback', [PaymentController::class, 'callback']);

Route::middleware('admin')->group(function () {
    Route::get('admin/metrics', AdminMetricsController::class);
    Route::get('admin/reports/sales', [AdminReportsController::class, 'sales']);
    Route::get('admin/reports/inventory', [AdminReportsController::class, 'inventory']);
    Route::get('admin/reports/customers', [AdminReportsController::class, 'customers']);
    Route::post('admin/reports/export', [AdminReportsController::class, 'export']);
    Route::get('admin/reports/exports', [AdminReportsController::class, 'exports']);
    Route::get('admin/reports/exports/{exportId}', [AdminReportsController::class, 'download']);
    Route::get('admin/orders/summary', [OrderController::class, 'summary']);
    Route::get('admin/orders/export', [OrderController::class, 'export']);
    Route::post('admin/orders/{order}/notify-telegram', [TelegramOrderController::class, 'notify']);
    Route::get('admin/staff-options', [OrderTrackingController::class, 'staffOptions']);
    Route::get('admin/users', [AdminUserController::class, 'index']);
    Route::post('admin/users', [AdminUserController::class, 'store']);
    Route::post('admin/orders/{order}/approve', [OrderTrackingController::class, 'approve']);
    Route::post('admin/orders/{order}/reject', [OrderTrackingController::class, 'reject']);
    Route::post('admin/orders/{order}/assign', [OrderTrackingController::class, 'assign']);
    Route::post('admin/orders/{order}/tracking-status', [OrderTrackingController::class, 'updateStatus']);
    Route::get('orders', [OrderController::class, 'index']);
    Route::get('orders/{order}', [OrderController::class, 'show']);
    Route::post('admin/orders/{order}/qr', [OrderController::class, 'generatePickupQr']);
    Route::post('admin/orders/verify-qr', [OrderController::class, 'verifyPickupQr']);
    Route::get('admin/banners', [BannerController::class, 'index']);
    Route::apiResource('admin/banners', BannerController::class)->except(['index', 'show']);
    Route::apiResource('categories', CategoryController::class)->except(['index', 'show']);
    Route::apiResource('products', ProductController::class)->except(['index', 'show']);
    Route::apiResource('accessories', AccessoryController::class)->except(['index', 'show']);
    Route::apiResource('parts', PartController::class);
    Route::get('product-attributes', [ProductAttributeOptionController::class, 'index']);
    Route::post('product-attributes', [ProductAttributeOptionController::class, 'store']);
    Route::patch('product-attributes/{productAttributeOption}', [ProductAttributeOptionController::class, 'update']);
    Route::delete('product-attributes/{productAttributeOption}', [ProductAttributeOptionController::class, 'destroy']);
    Route::patch('products/{product}/status', [ProductController::class, 'toggleStatus']);
    Route::apiResource('orders', OrderController::class);
    Route::apiResource('vouchers', VoucherController::class);
    Route::get('repairs', [RepairRequestController::class, 'index']);
    Route::post('repairs/{repair}/intake', [RepairIntakeController::class, 'store']);
    Route::get('repairs/{repair}/intake', [RepairIntakeController::class, 'show']);
    Route::post('repairs/{repair}/assign-technician', [RepairRequestController::class, 'assignTechnician']);
    Route::post('repairs/{repair}/auto-assign', [RepairRequestController::class, 'autoAssign']);
    Route::post('repairs/{repair}/diagnostic', [RepairDiagnosticController::class, 'store']);
    Route::post('repairs/{repair}/quotation', [RepairQuotationController::class, 'store']);
    Route::post('repairs/{repair}/status', [RepairRequestController::class, 'updateStatus']);
    Route::post('repairs/{repair}/warranty', [RepairWarrantyController::class, 'store']);
    Route::post('repairs/{repair}/invoice', [RepairInvoiceController::class, 'store']);
    Route::get('invoices', [RepairInvoiceController::class, 'index']);
    Route::get('repair-payments', [RepairPaymentController::class, 'index']);
    Route::get('warranties', [RepairWarrantyController::class, 'index']);
    Route::apiResource('technicians', TechnicianController::class);
    Route::get('admin/support/conversations', [SupportChatController::class, 'adminIndex']);
    Route::get('admin/support/conversations/{conversation}', [SupportChatController::class, 'adminShow']);
    Route::post('admin/support/conversations/{conversation}/messages', [SupportChatController::class, 'adminStoreMessage']);
    Route::post('admin/support/conversations/{conversation}/status', [SupportChatController::class, 'adminUpdateStatus']);
    Route::post('admin/support/conversations/{conversation}/assign', [SupportChatController::class, 'adminAssign']);
});
