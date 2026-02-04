<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->foreignId('voucher_id')->nullable()->constrained()->nullOnDelete()->after('delivery_fee');
            $table->string('voucher_code')->nullable()->after('voucher_id');
            $table->string('discount_type')->nullable()->after('voucher_code');
            $table->decimal('discount_value', 12, 2)->default(0)->after('discount_type');
            $table->decimal('discount_amount', 12, 2)->default(0)->after('discount_value');
        });
    }

    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropColumn([
                'voucher_id',
                'voucher_code',
                'discount_type',
                'discount_value',
                'discount_amount',
            ]);
        });
    }
};
