<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('otp_verifications', function (Blueprint $table) {
            $table->id();
            $table->string('destination_type', 10); // email|phone
            $table->string('destination', 255);
            $table->string('purpose', 50);
            $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $table->string('otp_hash', 255);
            $table->string('status', 20)->default('active'); // active|used|expired|locked
            $table->unsignedTinyInteger('attempts')->default(0);
            $table->unsignedTinyInteger('max_attempts')->default(5);
            $table->timestamp('expires_at');
            $table->timestamp('cooldown_until')->nullable();
            $table->timestamp('locked_until')->nullable();
            $table->timestamp('consumed_at')->nullable();
            $table->string('request_ip', 45)->nullable();
            $table->string('device_id', 191)->nullable();
            $table->timestamps();

            $table->index(['destination_type', 'destination', 'purpose'], 'otp_lookup_idx');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('otp_verifications');
    }
};
