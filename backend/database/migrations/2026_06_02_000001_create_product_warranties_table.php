<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('product_warranties', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained()->onDelete('cascade');
            $table->foreignId('order_item_id')->constrained()->onDelete('cascade');
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->unsignedBigInteger('product_id')->nullable();
            $table->foreign('product_id')->references('id')->on('products')->onDelete('set null');
            $table->string('product_name');
            $table->string('variant_label')->nullable();
            $table->string('warranty_period');          // e.g. '1_YEAR', '6_MONTHS'
            $table->unsignedInteger('duration_days');
            $table->date('start_date');
            $table->date('end_date');
            $table->string('status')->default('active'); // active | expired | void
            $table->text('notes')->nullable();
            $table->timestamps();

            $table->unique(['order_item_id']); // one warranty per ordered item
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('product_warranties');
    }
};
