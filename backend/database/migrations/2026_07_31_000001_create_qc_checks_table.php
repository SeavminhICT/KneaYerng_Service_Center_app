<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('qc_checks', function (Blueprint $table) {
            $table->id();
            $table->foreignId('repair_id')->unique()->constrained('repair_requests')->cascadeOnDelete();
            $table->json('results')->nullable();
            $table->string('overall_result', 50)->nullable();
            $table->text('notes')->nullable();
            $table->foreignId('checked_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('checked_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('qc_checks');
    }
};
