<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('device_models', function (Blueprint $table) {
            $table->id();
            $table->string('brand');
            $table->string('model_name');
            $table->unsignedInteger('sort_order')->default(0);
            $table->string('status')->default('active');
            $table->foreignId('added_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('device_models');
    }
};
