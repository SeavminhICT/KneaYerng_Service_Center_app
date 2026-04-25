<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            if (! Schema::hasColumn('orders', 'delivery_lat')) {
                $table->decimal('delivery_lat', 10, 7)->nullable()->after('delivery_note');
            }
            if (! Schema::hasColumn('orders', 'delivery_lng')) {
                $table->decimal('delivery_lng', 10, 7)->nullable()->after('delivery_lat');
            }
            if (! Schema::hasColumn('orders', 'telegram_chat_id')) {
                $table->string('telegram_chat_id')->nullable()->after('delivery_lng');
            }
            if (! Schema::hasColumn('orders', 'telegram_message_id')) {
                $table->string('telegram_message_id')->nullable()->after('telegram_chat_id');
            }
            if (! Schema::hasColumn('orders', 'telegram_last_action')) {
                $table->string('telegram_last_action')->nullable()->after('telegram_message_id');
            }
            if (! Schema::hasColumn('orders', 'telegram_last_action_by')) {
                $table->string('telegram_last_action_by')->nullable()->after('telegram_last_action');
            }
            if (! Schema::hasColumn('orders', 'telegram_last_action_at')) {
                $table->timestamp('telegram_last_action_at')->nullable()->after('telegram_last_action_by');
            }
            if (! Schema::hasColumn('orders', 'telegram_message_sent_at')) {
                $table->timestamp('telegram_message_sent_at')->nullable()->after('telegram_last_action_at');
            }
        });
    }

    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropColumn([
                'delivery_lat',
                'delivery_lng',
                'telegram_chat_id',
                'telegram_message_id',
                'telegram_last_action',
                'telegram_last_action_by',
                'telegram_last_action_at',
                'telegram_message_sent_at',
            ]);
        });
    }
};
