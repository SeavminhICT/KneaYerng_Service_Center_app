<?php

use App\Http\Controllers\AdminNotificationController;
use App\Http\Controllers\ProfileController;
use App\Models\KhqrTransaction;
use App\Models\Payment;
use App\Models\User;
use App\Models\Voucher;
use App\Models\Part;
use App\Models\ProductAttributeOption;
use Illuminate\Support\Facades\Route;

Route::redirect('/', '/login');

Route::get('/dashboard', function () {
    $user = request()->user();

    if ($user instanceof User && $user->canAccessAdminPanel()) {
        return redirect()->route('admin.dashboard');
    }

    return redirect()->route('profile.edit');
})->middleware('auth')->name('dashboard');

Route::get('language/{locale}', function ($locale) {
    if (in_array($locale, ['en', 'km'])) {
        session()->put('locale', $locale);
    }
    return redirect()->back();
})->name('locale.set');


Route::prefix('admin')->name('admin.')->middleware(['admin'])->group(function () {
    // Landing page for every web admin user; the statistics inside the page
    // only render for roles holding view_dashboard.
    Route::view('/dashboard', 'admin.dashboard')->name('dashboard');
    Route::get('/notifications', function () {
        $adminEmails = (array) config('auth.admin_emails', []);
        $users = User::query()
            ->select(['id', 'first_name', 'last_name', 'email', 'phone'])
            ->where(function ($query) {
                $query->whereNull('is_admin')
                    ->orWhere('is_admin', false);
            })
            ->where(function ($query) {
                $query->whereNull('role')
                    ->orWhere('role', '!=', 'admin');
            });

        if (! empty($adminEmails)) {
            $users->whereNotIn('email', $adminEmails);
        }

        return view('admin.notifications.index', [
            'users' => $users
                ->orderBy('first_name')
                ->orderBy('last_name')
                ->get(),
        ]);
    })->name('notifications.index')->middleware('permission:view_notification');
    Route::post('/notifications/send', [AdminNotificationController::class, 'store'])->name('notifications.store')->middleware('permission:create_notification');
    Route::get('/notifications/history', [AdminNotificationController::class, 'history'])->name('notifications.history')->middleware('permission:view_notification');

    Route::view('/categories', 'admin.categories.index')->name('categories.index')->middleware('permission:view_category');
    Route::view('/categories/create', 'admin.categories.create')->name('categories.create')->middleware('permission:create_category');
    Route::get('/categories/{category}/edit', function (\App\Models\Category $category) {
        return view('admin.categories.edit', ['categoryId' => $category->id]);
    })->name('categories.edit')->middleware('permission:update_category');

    Route::view('/banners', 'admin.banners.index')->name('banners.index')->middleware('permission:view_banner');

    Route::view('/products', 'admin.products.index')->name('products.index')->middleware('permission:view_product');
    Route::get('/products/create', function () {
        return view('admin.products.create', [
            'categories' => \App\Models\Category::query()
                ->orderBy('sort_order')
                ->orderBy('id')
                ->get(['id', 'name']),
        ]);
    })->name('products.create')->middleware('permission:create_product');
    Route::get('/products/{product}/edit', function (\App\Models\Product $product) {
        return view('admin.products.edit', [
            'product' => $product,
            'productId' => $product->id,
            'categories' => \App\Models\Category::query()
                ->orderBy('sort_order')
                ->orderBy('id')
                ->get(['id', 'name']),
        ]);
    })->name('products.edit')->middleware('permission:update_product');
    Route::view('/product-attributes', 'admin.product-attributes.index')->name('product-attributes.index')->middleware('permission:view_product_master');

    Route::view('/accessories', 'admin.accessories.index')->name('accessories.index')->middleware('permission:view_accessory');
    Route::view('/accessories/create', 'admin.accessories.create')->name('accessories.create')->middleware('permission:create_accessory');
    Route::get('/accessories/{accessory}/edit', function (\App\Models\Accessory $accessory) {
        return view('admin.accessories.edit', ['accessoryId' => $accessory->id]);
    })->name('accessories.edit')->middleware('permission:update_accessory');

    Route::view('/orders', 'admin.orders.index')->name('orders.index')->middleware('permission:view_order');
    Route::view('/orders/pickup', 'admin.orders.pickup')->name('orders.pickup')->middleware('permission:view_checking_pickup');
    Route::view('/orders/tracking', 'admin.orders.tracking')->name('orders.tracking')->middleware('permission:view_tracking_order');
    Route::get('/orders/{order}', function (\App\Models\Order $order) {
        return view('admin.orders.show', ['orderId' => $order->id]);
    })->name('orders.show')->middleware('permission:view_order,view_checking_pickup,view_tracking_order');

    Route::view('/repairs', 'admin.repairs.index')->name('repairs.index');
    Route::get('/repairs/{repair}', function (\App\Models\RepairRequest $repair) {
        return view('admin.repairs.show', ['repairId' => $repair->id]);
    })->name('repairs.show');
    Route::view('/support', 'admin.support.index')->name('support.index')->middleware('permission:view_support_inbox');

    Route::view('/technicians', 'admin.technicians.index')->name('technicians.index');

    Route::view('/vouchers', 'admin.vouchers.index')->name('vouchers.index')->middleware('permission:view_voucher');
    Route::view('/vouchers/create', 'admin.vouchers.create')->name('vouchers.create')->middleware('permission:create_voucher');
    Route::get('/vouchers/{voucher}/edit', function (Voucher $voucher) {
        return view('admin.vouchers.edit', ['voucherId' => $voucher->id]);
    })->name('vouchers.edit')->middleware('permission:update_voucher');

    Route::view('/parts', 'admin.parts.index')->name('parts.index')->middleware('permission:view_parts_inventory');
    Route::view('/parts/create', 'admin.parts.create')->name('parts.create')->middleware('permission:create_parts_inventory');
    Route::get('/parts/{part}/edit', function (Part $part) {
        return view('admin.parts.edit', ['partId' => $part->id]);
    })->name('parts.edit')->middleware('permission:update_parts_inventory');

    Route::view('/inventory/warranties', 'admin.inventory.warranties')->name('inventory.warranties')->middleware('permission:view_warranty_tracking');

    Route::view('/finance/invoices', 'admin.finance.invoices')->name('finance.invoices');
    Route::view('/finance/payments', 'admin.finance.payments')->name('finance.payments');
    Route::view('/finance/reports', 'admin.finance.reports')->name('finance.reports');

    Route::get('/customers/{user}', function (User $user) {
        $adminEmails = (array) config('auth.admin_emails', []);
        if (in_array($user->email, $adminEmails, true) || $user->isAdmin()) {
            abort(403);
        }
        $orders     = $user->orders()->orderByDesc('id')->limit(20)->get();
        $repairs    = $user->repairRequests()->orderByDesc('id')->limit(20)->get();
        $totalSpent = (float) $user->orders()->sum('total_amount');

        return view('admin.customers.show', [
            'customer'   => $user,
            'orders'     => $orders,
            'repairs'    => $repairs,
            'totalSpent' => $totalSpent,
        ]);
    })->name('customers.show')->middleware('permission:view_customer');

    Route::delete('/customers/{user}', function (User $user) {
        $adminEmails = (array) config('auth.admin_emails', []);
        if (in_array($user->email, $adminEmails, true) || $user->isAdmin()) {
            abort(403);
        }
        $user->tokens()->delete();
        $user->delete();

        return redirect()->route('admin.customers.index')
            ->with('success', 'Customer deleted successfully.');
    })->name('customers.destroy')->middleware('permission:delete_customer');

    Route::get('/customers', function () {
        $adminEmails = (array) config('auth.admin_emails', []);
        $search  = trim(request('search', ''));
        $segment = request('segment', '');

        $baseQuery = User::query()
            ->where(function ($query) {
                $query->whereNull('is_admin')
                    ->orWhere('is_admin', false);
            })
            ->where(function ($query) {
                $query->whereNull('role')
                    ->orWhere('role', 'user');
            });

        if (! empty($adminEmails)) {
            $baseQuery->where(function ($query) use ($adminEmails) {
                $query->whereNull('email')
                    ->orWhereNotIn('email', $adminEmails);
            });
        }

        // Search by name, email or phone
        if ($search !== '') {
            $baseQuery->where(function ($q) use ($search) {
                $q->where('first_name', 'like', "%{$search}%")
                  ->orWhere('last_name',  'like', "%{$search}%")
                  ->orWhere('email',      'like', "%{$search}%")
                  ->orWhere('phone',      'like', "%{$search}%");
            });
        }

        $customersCount = (clone $baseQuery)->count();
        $customers = $baseQuery
            ->withCount('orders')
            ->withSum('orders', 'total_amount')
            ->orderByDesc('id')
            ->get();

        // Segment filter (applied in-memory after eager loading)
        if ($segment !== '') {
            $customers = $customers->filter(function ($customer) use ($segment) {
                $ordersCount = $customer->orders_count ?? 0;
                $isVerified  = (bool) ($customer->otp_verified_at ?? $customer->email_verified_at);
                return match ($segment) {
                    'vip'      => $ordersCount >= 3,
                    'new'      => $ordersCount === 0,
                    'inactive' => ! $isVerified,
                    default    => true,
                };
            });
        }

        return view('admin.customers.index', [
            'customers'      => $customers,
            'customersCount' => $customersCount,
        ]);
    })->name('customers.index')->middleware('permission:view_customer');

    Route::get('/payments', function () {
        $payments = Payment::query()
            ->with([
                'order:id,order_number,customer_name,payment_status',
                'khqrTransaction:id,transaction_id,status,checked_at,paid_at',
            ])
            ->latest('id')
            ->paginate(20);

        $todayAmount = (float) Payment::query()
            ->where('status', 'success')
            ->whereDate('paid_at', today())
            ->sum('amount');

        $pendingCount = Payment::query()
            ->whereIn('status', ['pending', 'processing'])
            ->count();

        $reconciliationCount = Payment::query()
            ->with('khqrTransaction:id,transaction_id,status')
            ->whereNotNull('transaction_id')
            ->get()
            ->filter(function (Payment $payment) {
                $khqr = $payment->khqrTransaction;
                if (! $khqr) {
                    return false;
                }

                $paymentSuccessful = $payment->status === 'success';
                $khqrSuccessful = $khqr->status === 'SUCCESS';

                return $paymentSuccessful !== $khqrSuccessful;
            })
            ->count();

        $khqrPendingCount = KhqrTransaction::query()
            ->whereIn('status', ['PENDING', 'NOT_FOUND'])
            ->count();

        return view('admin.payments.index', [
            'todayAmount' => $todayAmount,
            'pendingCount' => $pendingCount,
            'reconciliationCount' => $reconciliationCount,
            'khqrPendingCount' => $khqrPendingCount,
            'payments' => $payments,
        ]);
    })->name('payments.index')->middleware('permission:view_payment');
    Route::view('/reports', 'admin.reports.index')->name('reports.index')->middleware('permission:view_sales_report');
    Route::view('/settings', 'admin.settings.index')->name('settings.index')->middleware('permission:view_setting');
    Route::view('/users', 'admin.users.index')->name('users.index')->middleware('permission:view_user');
    Route::view('/roles', 'admin.roles.index')->name('roles.index')->middleware('permission:view_role');
    Route::view('/permissions', 'admin.permissions.index')->name('permissions.index')->middleware('permission:view_permission');
    // Permission assignment now lives on the combined Roles & Permissions page.
    Route::redirect('/roles/assign-permissions', '/admin/roles')->name('roles.assign-permissions');
});

Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
});

require __DIR__.'/auth.php';
