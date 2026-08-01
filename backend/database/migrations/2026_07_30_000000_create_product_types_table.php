<?php

use App\Models\ProductType;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('product_types', function (Blueprint $table) {
            $table->id();
            $table->string('name', 80);
            $table->string('slug', 20)->unique();
            $table->json('fields');
            $table->json('required_fields')->nullable();
            $table->unsignedInteger('sort_order')->default(0);
            $table->timestamps();

            $table->index('sort_order');
        });

        $now = now();

        foreach (ProductType::DEFAULT_TYPES as $type) {
            DB::table('product_types')->insert([
                'name' => $type['name'],
                'slug' => $type['slug'],
                'fields' => json_encode($type['fields']),
                'required_fields' => json_encode($type['required_fields']),
                'sort_order' => $type['sort_order'],
                'created_at' => $now,
                'updated_at' => $now,
            ]);
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('product_types');
    }
};
