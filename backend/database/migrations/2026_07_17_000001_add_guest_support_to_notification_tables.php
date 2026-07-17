<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('mobile_device_tokens', function (Blueprint $table) {
            $table->dropForeign(['user_id']);
        });

        Schema::table('mobile_device_tokens', function (Blueprint $table) {
            $table->unsignedBigInteger('user_id')->nullable()->change();
            $table->foreign('user_id')->references('id')->on('users')->nullOnDelete();
            $table->string('guest_device_id', 64)->nullable()->index();
            $table->string('device_name', 120)->nullable();
            $table->string('app_version', 32)->nullable();
        });

        Schema::table('order_tracking_notifications', function (Blueprint $table) {
            $table->string('guest_device_id', 64)->nullable()->index();
            $table->foreignId('campaign_id')
                ->nullable()
                ->constrained('admin_notification_campaigns')
                ->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('order_tracking_notifications', function (Blueprint $table) {
            $table->dropConstrainedForeignId('campaign_id');
            $table->dropIndex(['guest_device_id']);
            $table->dropColumn('guest_device_id');
        });

        Schema::table('mobile_device_tokens', function (Blueprint $table) {
            $table->dropIndex(['guest_device_id']);
            $table->dropColumn(['guest_device_id', 'device_name', 'app_version']);
        });

        Schema::table('mobile_device_tokens', function (Blueprint $table) {
            $table->dropForeign(['user_id']);
        });

        Schema::table('mobile_device_tokens', function (Blueprint $table) {
            $table->unsignedBigInteger('user_id')->nullable(false)->change();
            $table->foreign('user_id')->references('id')->on('users')->cascadeOnDelete();
        });
    }
};
