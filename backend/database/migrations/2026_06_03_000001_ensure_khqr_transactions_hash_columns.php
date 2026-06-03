<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Idempotent guard: add md5 / full_hash to khqr_transactions if they are
 * missing.  The original 2026_02_21 migration may never have run on some
 * production servers, leaving the table without these columns and causing
 * every QR-generate request to crash with "Column not found: 1054".
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('khqr_transactions', function (Blueprint $table) {
            if (! Schema::hasColumn('khqr_transactions', 'md5')) {
                $table->string('md5', 64)->nullable()->after('transaction_id');
                $table->index('md5');
            }

            if (! Schema::hasColumn('khqr_transactions', 'full_hash')) {
                $table->string('full_hash', 128)->nullable()->after('md5');
                $table->index('full_hash');
            }
        });
    }

    public function down(): void
    {
        Schema::table('khqr_transactions', function (Blueprint $table) {
            if (Schema::hasColumn('khqr_transactions', 'full_hash')) {
                $table->dropIndex(['full_hash']);
                $table->dropColumn('full_hash');
            }

            if (Schema::hasColumn('khqr_transactions', 'md5')) {
                $table->dropIndex(['md5']);
                $table->dropColumn('md5');
            }
        });
    }
};
