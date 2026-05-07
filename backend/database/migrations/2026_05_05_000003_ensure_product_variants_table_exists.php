<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('product_variants')) {
            return;
        }

        Schema::create('product_variants', function (Blueprint $table) {
            $table->id();
            $table->foreignId('product_id')->constrained()->cascadeOnDelete();
            $table->string('storage_capacity', 100);
            $table->string('color', 100);
            $table->string('condition', 100);
            $table->string('ram', 100)->nullable();
            $table->string('ssd', 100)->nullable();
            $table->decimal('price', 12, 2)->default(0);
            $table->unsignedInteger('stock')->default(0);
            $table->string('sku', 120)->nullable()->unique();
            $table->string('image')->nullable();
            $table->boolean('is_active')->default(true);
            $table->unsignedInteger('sort_order')->default(0);
            $table->timestamps();

            $table->index(['product_id', 'is_active']);
            $table->index(['product_id', 'storage_capacity', 'color', 'condition'], 'product_variants_lookup_idx');
        });
    }

    public function down(): void
    {
        // This migration is a repair guard. Do not drop table on rollback.
    }
};

