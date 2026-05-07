<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('cart_items', function (Blueprint $table) {
            $table->foreignId('product_variant_id')
                ->nullable()
                ->after('item_id')
                ->constrained('product_variants')
                ->nullOnDelete();
            $table->string('variant_label', 255)->nullable()->after('product_name');
            $table->index(['product_id', 'product_variant_id'], 'cart_items_product_variant_idx');
        });

        Schema::table('order_items', function (Blueprint $table) {
            $table->foreignId('product_variant_id')
                ->nullable()
                ->after('item_id')
                ->constrained('product_variants')
                ->nullOnDelete();
            $table->string('variant_label', 255)->nullable()->after('product_name');
            $table->index(['product_id', 'product_variant_id'], 'order_items_product_variant_idx');
        });
    }

    public function down(): void
    {
        Schema::table('cart_items', function (Blueprint $table) {
            $table->dropIndex('cart_items_product_variant_idx');
            $table->dropConstrainedForeignId('product_variant_id');
            $table->dropColumn('variant_label');
        });

        Schema::table('order_items', function (Blueprint $table) {
            $table->dropIndex('order_items_product_variant_idx');
            $table->dropConstrainedForeignId('product_variant_id');
            $table->dropColumn('variant_label');
        });
    }
};

