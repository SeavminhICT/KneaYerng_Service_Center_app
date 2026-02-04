<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->json('ram')->nullable()->after('condition');
            $table->json('ssd')->nullable()->after('ram');
            $table->json('cpu')->nullable()->after('ssd');
            $table->json('display')->nullable()->after('cpu');
            $table->json('country')->nullable()->after('display');
        });
    }

    public function down(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->dropColumn(['ram', 'ssd', 'cpu', 'display', 'country']);
        });
    }
};
