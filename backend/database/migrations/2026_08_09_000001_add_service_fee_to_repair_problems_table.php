<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('repair_problems', function (Blueprint $table) {
            $table->decimal('service_fee', 12, 2)->default(0)->after('name');
        });
    }

    public function down(): void
    {
        Schema::table('repair_problems', function (Blueprint $table) {
            $table->dropColumn('service_fee');
        });
    }
};
