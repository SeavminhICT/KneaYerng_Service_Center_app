<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('repair_request_problems', function (Blueprint $table) {
            $table->id();
            $table->foreignId('repair_id')->constrained('repair_requests')->cascadeOnDelete();
            $table->foreignId('problem_id')->constrained('repair_problems')->cascadeOnDelete();
            $table->timestamps();

            $table->unique(['repair_id', 'problem_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('repair_request_problems');
    }
};
