<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('voucher_redemptions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('voucher_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('order_id')->constrained()->cascadeOnDelete();
            $table->timestamp('redeemed_at')->nullable();
            $table->timestamps();

            $table->unique(['voucher_id', 'order_id']);
            $table->index(['voucher_id', 'user_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('voucher_redemptions');
    }
};
