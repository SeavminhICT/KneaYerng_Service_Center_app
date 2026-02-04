<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->string('tag', 50)->nullable()->after('status');
        });

        Schema::table('accessories', function (Blueprint $table) {
            $table->string('tag', 50)->nullable()->after('discount');
        });

        Schema::table('parts', function (Blueprint $table) {
            $table->string('tag', 50)->nullable()->after('status');
        });
    }

    public function down(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->dropColumn('tag');
        });

        Schema::table('accessories', function (Blueprint $table) {
            $table->dropColumn('tag');
        });

        Schema::table('parts', function (Blueprint $table) {
            $table->dropColumn('tag');
        });
    }
};
