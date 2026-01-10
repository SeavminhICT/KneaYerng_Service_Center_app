<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->text('description')->nullable()->after('name');
            $table->decimal('discount', 12, 2)->default(0)->after('price');
            $table->string('brand')->nullable()->after('status');
            $table->string('thumbnail')->nullable()->after('brand');
            $table->json('image_gallery')->nullable()->after('thumbnail');
            $table->json('storage_capacity')->nullable()->after('image_gallery');
            $table->json('color')->nullable()->after('storage_capacity');
            $table->json('condition')->nullable()->after('color');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->dropColumn([
                'description',
                'discount',
                'brand',
                'thumbnail',
                'image_gallery',
                'storage_capacity',
                'color',
                'condition',
            ]);
        });
    }
};
