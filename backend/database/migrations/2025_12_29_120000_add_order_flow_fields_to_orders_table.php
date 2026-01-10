<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->string('order_type')->default('pickup')->after('customer_email');
            $table->string('payment_method')->default('cod')->after('order_type');
            $table->string('delivery_address')->nullable()->after('payment_method');
            $table->string('delivery_phone')->nullable()->after('delivery_address');
            $table->text('pickup_qr_token')->nullable()->after('delivery_phone');
            $table->timestamp('pickup_qr_generated_at')->nullable()->after('pickup_qr_token');
            $table->timestamp('pickup_verified_at')->nullable()->after('pickup_qr_generated_at');
        });
    }

    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropColumn([
                'order_type',
                'payment_method',
                'delivery_address',
                'delivery_phone',
                'pickup_qr_token',
                'pickup_qr_generated_at',
                'pickup_verified_at',
            ]);
        });
    }
};
