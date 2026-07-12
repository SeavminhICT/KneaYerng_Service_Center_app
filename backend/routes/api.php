<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\AuthOtpController;
use App\Http\Controllers\AdminNotificationController;
use App\Http\Controllers\Api\AdminMetricsController;
use App\Http\Controllers\Api\AdminUserController;
use App\Http\Controllers\Api\AccessoryController;
use App\Http\Controllers\Api\BannerController;
use App\Http\Controllers\Api\CartController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\CheckoutOptionsController;
use App\Http\Controllers\Api\AdminReportsController;
use App\Http\Controllers\Api\ForgotPasswordController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\OrderTrackingController;
use App\Http\Controllers\Api\OtpController;
use App\Http\Controllers\Api\ProductWarrantyController;
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
use App\Http\Controllers\Api\UpdatesController;
use App\Http\Controllers\Api\VoucherController;
use App\Http\Controllers\Api\VoucherValidationController;
use App\Http\Controllers\Api\PartController;
use App\Http\Controllers\Api\ProductAttributeOptionController;
use App\Http\Controllers\Api\PermissionController;
use App\Http\Controllers\Api\RoleController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::prefix('auth')->group(function () {
    Route::post('send-otp', [AuthOtpController::class, 'sendOtp']);
    Route::post('verify-otp', [AuthOtpController::class, 'verifyOtp']);
    Route::prefix('forgot-password')->group(function () {
        Route::post('send-otp', [ForgotPasswordController::class, 'sendOtp']);
        Route::post('verify-otp', [ForgotPasswordController::class, 'verifyOtp']);
        Route::post('reset-password', [ForgotPasswordController::class, 'resetPassword']);
    });
    Route::post('register', [AuthController::class, 'register']);
    Route::post('login', [AuthController::class, 'login']);
    Route::post('google', [AuthController::class, 'googleLogin']);
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

Route::get('updates', [UpdatesController::class, 'check']);
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
    // ── Product Warranties (customer) ─────────────────────────────────────
    Route::get('product-warranties', [ProductWarrantyController::class, 'index']);
    Route::get('product-warranties/{productWarranty}', [ProductWarrantyController::class, 'show']);

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
    Route::post('support/upload', [SupportChatController::class, 'uploadMedia']);
    Route::post('support/read', [SupportChatController::class, 'markCustomerRead']);
    Route::get('support/unread-count', [SupportChatController::class, 'customerUnreadCount']);
});

Route::post('payments/callback', [PaymentController::class, 'callback']);
Route::post('payments/khpay-callback', [PaymentController::class, 'khpayCallback']);


Route::middleware('admin')->group(function () {
    Route::get('admin/product-warranties', [ProductWarrantyController::class, 'adminIndex'])->middleware('permission:view_warranty_tracking');
    Route::patch('admin/product-warranties/{productWarranty}/void', [ProductWarrantyController::class, 'void'])->middleware('permission:update_warranty_tracking');

    Route::post('admin/notifications/send', [AdminNotificationController::class, 'store'])->middleware('permission:create_notification');
    Route::get('admin/notifications/history', [AdminNotificationController::class, 'history'])->middleware('permission:view_notification');
    Route::get('admin/notifications/recipients', [AdminNotificationController::class, 'recipients'])->middleware('permission:view_notification');
    Route::get('admin/metrics', AdminMetricsController::class)->middleware('permission:view_dashboard');
    Route::middleware('permission:view_sales_report')->group(function () {
        Route::get('admin/reports/sales', [AdminReportsController::class, 'sales']);
        Route::get('admin/reports/inventory', [AdminReportsController::class, 'inventory']);
        Route::get('admin/reports/customers', [AdminReportsController::class, 'customers']);
        Route::get('admin/reports/repairs', [AdminReportsController::class, 'repairs']);
        Route::post('admin/reports/export', [AdminReportsController::class, 'export']);
        Route::get('admin/reports/exports', [AdminReportsController::class, 'exports']);
        Route::get('admin/reports/exports/{exportId}', [AdminReportsController::class, 'download']);
    });
    Route::middleware('permission:view_order,view_dashboard')->group(function () {
        Route::get('admin/orders/summary', [OrderController::class, 'summary']);
        Route::get('admin/orders/export', [OrderController::class, 'export']);
        Route::get('admin/orders/export-pdf', [OrderController::class, 'exportPdf']);
        Route::get('admin/orders/export-excel', [OrderController::class, 'exportExcel']);
    });
    Route::post('admin/orders/{order}/notify-telegram', [TelegramOrderController::class, 'notify'])->middleware('permission:update_order');
    Route::get('admin/staff-options', [OrderTrackingController::class, 'staffOptions'])->middleware('permission:view_tracking_order,view_order');

    Route::get('admin/users', [AdminUserController::class, 'index'])->middleware('permission:view_user');
    Route::post('admin/users', [AdminUserController::class, 'store'])->middleware('permission:create_user');
    Route::get('admin/users/{user}', [AdminUserController::class, 'show'])->middleware('permission:view_user');
    Route::put('admin/users/{user}', [AdminUserController::class, 'update'])->middleware('permission:update_user');
    Route::delete('admin/users/{user}', [AdminUserController::class, 'destroy'])->middleware('permission:delete_user');
    Route::patch('admin/users/{user}/status', [AdminUserController::class, 'updateStatus'])->middleware('permission:update_user');

    Route::get('users', [AdminUserController::class, 'index'])->middleware('permission:view_user');
    Route::post('users', [AdminUserController::class, 'store'])->middleware('permission:create_user');
    Route::get('users/{user}', [AdminUserController::class, 'show'])->middleware('permission:view_user');
    Route::put('users/{user}', [AdminUserController::class, 'update'])->middleware('permission:update_user');
    Route::delete('users/{user}', [AdminUserController::class, 'destroy'])->middleware('permission:delete_user');

    Route::get('roles', [RoleController::class, 'index'])->middleware('permission:view_role');
    Route::post('roles', [RoleController::class, 'store'])->middleware('permission:create_role');
    Route::get('roles/{role}', [RoleController::class, 'show'])->middleware('permission:view_role');
    Route::put('roles/{role}', [RoleController::class, 'update'])->middleware('permission:update_role');
    Route::delete('roles/{role}', [RoleController::class, 'destroy'])->middleware('permission:delete_role');
    Route::get('roles/{role}/permissions', [RoleController::class, 'permissions'])->middleware('permission:view_role');
    Route::put('roles/{role}/permissions', [RoleController::class, 'updatePermissions'])->middleware('permission:update_role');

    Route::get('permissions', [PermissionController::class, 'index'])->middleware('permission:view_permission');
    Route::post('permissions', [PermissionController::class, 'store'])->middleware('permission:create_permission');
    Route::get('permissions/{permission}', [PermissionController::class, 'show'])->middleware('permission:view_permission');
    Route::put('permissions/{permission}', [PermissionController::class, 'update'])->middleware('permission:update_permission');
    Route::delete('permissions/{permission}', [PermissionController::class, 'destroy'])->middleware('permission:delete_permission');
    Route::middleware('permission:update_tracking_order')->group(function () {
        Route::post('admin/orders/{order}/approve', [OrderTrackingController::class, 'approve']);
        Route::post('admin/orders/{order}/reject', [OrderTrackingController::class, 'reject']);
        Route::post('admin/orders/{order}/assign', [OrderTrackingController::class, 'assign']);
        Route::post('admin/orders/{order}/tracking-status', [OrderTrackingController::class, 'updateStatus']);
    });
    Route::post('admin/orders/{order}/qr', [OrderController::class, 'generatePickupQr'])->middleware('permission:view_checking_pickup,view_order');
    Route::post('admin/orders/verify-qr', [OrderController::class, 'verifyPickupQr'])->middleware('permission:update_checking_pickup');
    Route::get('admin/banners', [BannerController::class, 'index'])->middleware('permission:view_banner');
    Route::post('admin/banners', [BannerController::class, 'store'])->middleware('permission:create_banner');
    Route::match(['put', 'patch'], 'admin/banners/{banner}', [BannerController::class, 'update'])->middleware('permission:update_banner');
    Route::delete('admin/banners/{banner}', [BannerController::class, 'destroy'])->middleware('permission:delete_banner');
    Route::post('categories', [CategoryController::class, 'store'])->middleware('permission:create_category');
    Route::match(['put', 'patch'], 'categories/{category}', [CategoryController::class, 'update'])->middleware('permission:update_category');
    Route::delete('categories/{category}', [CategoryController::class, 'destroy'])->middleware('permission:delete_category');
    Route::post('products', [ProductController::class, 'store'])->middleware('permission:create_product');
    Route::match(['put', 'patch'], 'products/{product}', [ProductController::class, 'update'])->middleware('permission:update_product');
    Route::delete('products/{product}', [ProductController::class, 'destroy'])->middleware('permission:delete_product');
    Route::patch('products/{product}/status', [ProductController::class, 'toggleStatus'])->middleware('permission:update_product');
    Route::post('accessories', [AccessoryController::class, 'store'])->middleware('permission:create_accessory');
    Route::match(['put', 'patch'], 'accessories/{accessory}', [AccessoryController::class, 'update'])->middleware('permission:update_accessory');
    Route::delete('accessories/{accessory}', [AccessoryController::class, 'destroy'])->middleware('permission:delete_accessory');
    Route::get('parts', [PartController::class, 'index'])->middleware('permission:view_parts_inventory');
    Route::post('parts', [PartController::class, 'store'])->middleware('permission:create_parts_inventory');
    Route::get('parts/{part}', [PartController::class, 'show'])->middleware('permission:view_parts_inventory');
    Route::match(['put', 'patch'], 'parts/{part}', [PartController::class, 'update'])->middleware('permission:update_parts_inventory');
    Route::delete('parts/{part}', [PartController::class, 'destroy'])->middleware('permission:delete_parts_inventory');
    Route::get('product-attributes', [ProductAttributeOptionController::class, 'index'])->middleware('permission:view_product_master,view_product');
    Route::post('product-attributes', [ProductAttributeOptionController::class, 'store'])->middleware('permission:create_product_master');
    Route::patch('product-attributes/{productAttributeOption}', [ProductAttributeOptionController::class, 'update'])->middleware('permission:update_product_master');
    Route::delete('product-attributes/{productAttributeOption}', [ProductAttributeOptionController::class, 'destroy'])->middleware('permission:delete_product_master');
    Route::get('orders', [OrderController::class, 'index'])->middleware('permission:view_order,view_checking_pickup,view_tracking_order,view_dashboard');
    Route::get('orders/{order}', [OrderController::class, 'show'])->middleware('permission:view_order,view_checking_pickup,view_tracking_order');
    Route::post('orders', [OrderController::class, 'store'])->middleware('permission:create_order');
    Route::match(['put', 'patch'], 'orders/{order}', [OrderController::class, 'update'])->middleware('permission:update_order');
    Route::delete('orders/{order}', [OrderController::class, 'destroy'])->middleware('permission:delete_order');
    Route::get('vouchers', [VoucherController::class, 'index'])->middleware('permission:view_voucher');
    Route::post('vouchers', [VoucherController::class, 'store'])->middleware('permission:create_voucher');
    Route::get('vouchers/{voucher}', [VoucherController::class, 'show'])->middleware('permission:view_voucher');
    Route::match(['put', 'patch'], 'vouchers/{voucher}', [VoucherController::class, 'update'])->middleware('permission:update_voucher');
    Route::delete('vouchers/{voucher}', [VoucherController::class, 'destroy'])->middleware('permission:delete_voucher');
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
    Route::get('admin/support/conversations', [SupportChatController::class, 'adminIndex'])->middleware('permission:view_support_inbox');
    Route::get('admin/support/conversations/{conversation}', [SupportChatController::class, 'adminShow'])->middleware('permission:view_support_inbox');
    Route::post('admin/support/conversations/{conversation}/messages', [SupportChatController::class, 'adminStoreMessage'])->middleware('permission:create_support_inbox,update_support_inbox');
    Route::post('admin/support/upload', [SupportChatController::class, 'uploadMedia'])->middleware('permission:create_support_inbox,update_support_inbox');
    Route::post('admin/support/conversations/{conversation}/status', [SupportChatController::class, 'adminUpdateStatus'])->middleware('permission:update_support_inbox');
    Route::post('admin/support/conversations/{conversation}/assign', [SupportChatController::class, 'adminAssign'])->middleware('permission:update_support_inbox');
});
