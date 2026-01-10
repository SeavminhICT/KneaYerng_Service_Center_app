<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->string('name')->after('id');
            $table->string('sku')->nullable()->unique()->after('name');
            $table->foreignId('category_id')->nullable()->constrained()->nullOnDelete()->after('sku');
            $table->decimal('price', 12, 2)->default(0)->after('category_id');
            $table->unsignedInteger('stock')->default(0)->after('price');
            $table->string('status')->default('active')->after('stock');
            $table->string('image')->nullable()->after('status');
        });
    }

    public function down(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->dropForeign(['category_id']);
            $table->dropColumn(['name', 'sku', 'category_id', 'price', 'stock', 'status', 'image']);
        });
    }
};

