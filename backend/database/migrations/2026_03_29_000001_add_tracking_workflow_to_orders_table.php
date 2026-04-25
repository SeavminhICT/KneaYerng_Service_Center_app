<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->foreignId('assigned_staff_id')->nullable()->after('user_id')->constrained('users')->nullOnDelete();
            $table->foreignId('approved_by')->nullable()->after('assigned_staff_id')->constrained('users')->nullOnDelete();
            $table->timestamp('approved_at')->nullable()->after('approved_by');
            $table->foreignId('rejected_by')->nullable()->after('approved_at')->constrained('users')->nullOnDelete();
            $table->timestamp('rejected_at')->nullable()->after('rejected_by');
            $table->text('rejected_reason')->nullable()->after('rejected_at');
            $table->foreignId('cancelled_by')->nullable()->after('rejected_reason')->constrained('users')->nullOnDelete();
            $table->timestamp('cancelled_at')->nullable()->after('cancelled_by');
            $table->text('cancelled_reason')->nullable()->after('cancelled_at');
            $table->timestamp('current_status_at')->nullable()->after('status');
        });
    }

    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropConstrainedForeignId('assigned_staff_id');
            $table->dropConstrainedForeignId('approved_by');
            $table->dropConstrainedForeignId('rejected_by');
            $table->dropConstrainedForeignId('cancelled_by');
            $table->dropColumn([
                'approved_at',
                'rejected_at',
                'rejected_reason',
                'cancelled_at',
                'cancelled_reason',
                'current_status_at',
            ]);
        });
    }
};
