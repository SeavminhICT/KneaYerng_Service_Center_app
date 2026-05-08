<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('admin_notification_campaigns', function (Blueprint $table) {
            $table->id();
            $table->foreignId('admin_user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('type', 60);
            $table->string('title', 150);
            $table->text('message')->nullable();
            $table->string('audience', 32)->default('all');
            $table->json('custom_user_ids')->nullable();
            $table->string('deep_link', 1000)->nullable();
            $table->string('action', 32)->default('send_now');
            $table->string('status', 32)->default('sent');
            $table->timestamp('scheduled_for')->nullable();
            $table->json('summary')->nullable();
            $table->json('meta')->nullable();
            $table->timestamps();

            $table->index(['status', 'created_at']);
            $table->index(['admin_user_id', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('admin_notification_campaigns');
    }
};
