<?php

use App\Http\Controllers\ProfileController;
use App\Models\User;
use App\Models\Voucher;
use App\Models\Part;
use App\Models\ProductAttributeOption;
use Illuminate\Support\Facades\Route;

Route::redirect('/', '/login');


Route::prefix('admin')->name('admin.')->middleware(['admin'])->group(function () {
    Route::view('/dashboard', 'admin.dashboard')->name('dashboard');

    Route::view('/categories', 'admin.categories.index')->name('categories.index');
    Route::view('/categories/create', 'admin.categories.create')->name('categories.create');
    Route::get('/categories/{category}/edit', function (\App\Models\Category $category) {
        return view('admin.categories.edit', ['categoryId' => $category->id]);
    })->name('categories.edit');

    Route::view('/banners', 'admin.banners.index')->name('banners.index');

    Route::view('/products', 'admin.products.index')->name('products.index');
    Route::view('/products/create', 'admin.products.create')->name('products.create');
    Route::get('/products/{product}/edit', function (\App\Models\Product $product) {
        return view('admin.products.edit', ['productId' => $product->id]);
    })->name('products.edit');
    Route::view('/product-attributes', 'admin.product-attributes.index')->name('product-attributes.index');

    Route::view('/accessories', 'admin.accessories.index')->name('accessories.index');
    Route::view('/accessories/create', 'admin.accessories.create')->name('accessories.create');
    Route::get('/accessories/{accessory}/edit', function (\App\Models\Accessory $accessory) {
        return view('admin.accessories.edit', ['accessoryId' => $accessory->id]);
    })->name('accessories.edit');

    Route::view('/orders', 'admin.orders.index')->name('orders.index');
    Route::get('/orders/{order}', function (\App\Models\Order $order) {
        return view('admin.orders.show', ['orderId' => $order->id]);
    })->name('orders.show');

    Route::view('/repairs', 'admin.repairs.index')->name('repairs.index');
    Route::get('/repairs/{repair}', function (\App\Models\RepairRequest $repair) {
        return view('admin.repairs.show', ['repairId' => $repair->id]);
    })->name('repairs.show');

    Route::view('/technicians', 'admin.technicians.index')->name('technicians.index');

    Route::view('/vouchers', 'admin.vouchers.index')->name('vouchers.index');
    Route::view('/vouchers/create', 'admin.vouchers.create')->name('vouchers.create');
    Route::get('/vouchers/{voucher}/edit', function (Voucher $voucher) {
        return view('admin.vouchers.edit', ['voucherId' => $voucher->id]);
    })->name('vouchers.edit');

    Route::view('/parts', 'admin.parts.index')->name('parts.index');
    Route::view('/parts/create', 'admin.parts.create')->name('parts.create');
    Route::get('/parts/{part}/edit', function (Part $part) {
        return view('admin.parts.edit', ['partId' => $part->id]);
    })->name('parts.edit');

    Route::view('/inventory/warranties', 'admin.inventory.warranties')->name('inventory.warranties');

    Route::view('/finance/invoices', 'admin.finance.invoices')->name('finance.invoices');
    Route::view('/finance/payments', 'admin.finance.payments')->name('finance.payments');
    Route::view('/finance/reports', 'admin.finance.reports')->name('finance.reports');

    Route::get('/customers', function () {
        $adminEmails = (array) config('auth.admin_emails', []);
        $baseQuery = User::query()
            ->where(function ($query) {
                $query->whereNull('is_admin')
                    ->orWhere('is_admin', false);
            })
            ->where(function ($query) {
                $query->whereNull('role')
                    ->orWhere('role', '!=', 'admin');
            });

        if (! empty($adminEmails)) {
            $baseQuery->whereNotIn('email', $adminEmails);
        }

        $customersCount = (clone $baseQuery)->count();
        $customers = $baseQuery
            ->withCount('orders')
            ->withSum('orders', 'total_amount')
            ->orderByDesc('id')
            ->get();

        return view('admin.customers.index', [
            'customers' => $customers,
            'customersCount' => $customersCount,
        ]);
    })->name('customers.index');
    Route::view('/payments', 'admin.payments.index')->name('payments.index');
    Route::view('/reports', 'admin.reports.index')->name('reports.index');
    Route::view('/settings', 'admin.settings.index')->name('settings.index');
    Route::view('/users', 'admin.users.index')->name('users.index');
});

Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
});

require __DIR__.'/auth.php';
