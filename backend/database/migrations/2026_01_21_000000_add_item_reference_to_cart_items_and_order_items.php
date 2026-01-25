<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('cart_items', function (Blueprint $table) {
            $table->string('item_type', 30)->nullable()->after('product_id');
            $table->unsignedBigInteger('item_id')->nullable()->after('item_type');
            $table->index(['item_type', 'item_id']);
        });

        Schema::table('order_items', function (Blueprint $table) {
            $table->string('item_type', 30)->nullable()->after('product_id');
            $table->unsignedBigInteger('item_id')->nullable()->after('item_type');
            $table->index(['item_type', 'item_id']);
        });

        DB::table('cart_items')
            ->whereNotNull('product_id')
            ->update([
                'item_type' => 'product',
                'item_id' => DB::raw('product_id'),
            ]);

        DB::table('order_items')
            ->whereNotNull('product_id')
            ->update([
                'item_type' => 'product',
                'item_id' => DB::raw('product_id'),
            ]);
    }

    public function down(): void
    {
        Schema::table('cart_items', function (Blueprint $table) {
            $table->dropIndex(['item_type', 'item_id']);
            $table->dropColumn(['item_type', 'item_id']);
        });

        Schema::table('order_items', function (Blueprint $table) {
            $table->dropIndex(['item_type', 'item_id']);
            $table->dropColumn(['item_type', 'item_id']);
        });
    }
};
