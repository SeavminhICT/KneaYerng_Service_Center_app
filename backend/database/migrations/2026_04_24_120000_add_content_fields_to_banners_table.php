<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('banners', function (Blueprint $table) {
            $table->string('badge_label')->nullable()->after('image');
            $table->string('title')->nullable()->after('badge_label');
            $table->text('subtitle')->nullable()->after('title');
            $table->string('cta_label')->nullable()->after('subtitle');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('banners', function (Blueprint $table) {
            $table->dropColumn([
                'badge_label',
                'title',
                'subtitle',
                'cta_label',
            ]);
        });
    }
};
