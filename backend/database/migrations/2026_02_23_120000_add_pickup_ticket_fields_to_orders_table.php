<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->timestamp('pickup_qr_expires_at')->nullable()->after('pickup_qr_generated_at');
            $table->unsignedBigInteger('pickup_verified_by')->nullable()->after('pickup_verified_at');
        });
    }

    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropColumn([
                'pickup_qr_expires_at',
                'pickup_verified_by',
            ]);
        });
    }
};
