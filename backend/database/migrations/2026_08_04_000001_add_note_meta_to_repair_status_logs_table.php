<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('repair_status_logs', function (Blueprint $table) {
            $table->string('from_status')->nullable()->after('repair_id');
            $table->text('note')->nullable()->after('status');
            $table->json('meta')->nullable()->after('note');
        });
    }

    public function down(): void
    {
        Schema::table('repair_status_logs', function (Blueprint $table) {
            $table->dropColumn(['from_status', 'note', 'meta']);
        });
    }
};
