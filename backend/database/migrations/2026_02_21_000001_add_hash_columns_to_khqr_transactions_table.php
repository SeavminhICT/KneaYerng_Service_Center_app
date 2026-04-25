<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('khqr_transactions', function (Blueprint $table) {
            $table->string('md5', 64)->nullable()->after('transaction_id');
            $table->string('full_hash', 128)->nullable()->after('md5');
            $table->index('md5');
            $table->index('full_hash');
        });
    }

    public function down(): void
    {
        Schema::table('khqr_transactions', function (Blueprint $table) {
            $table->dropIndex(['md5']);
            $table->dropIndex(['full_hash']);
            $table->dropColumn(['md5', 'full_hash']);
        });
    }
};
