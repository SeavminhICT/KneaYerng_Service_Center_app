<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (! Schema::hasColumn('products', 'product_type')) {
            Schema::table('products', function (Blueprint $table) {
                $table->string('product_type', 20)->default('mobile')->after('category_id');
            });
        }

        if (Schema::hasTable('product_variants')) {
            Schema::table('product_variants', function (Blueprint $table) {
                $table->string('storage_capacity', 100)->nullable()->change();
                $table->string('color', 100)->nullable()->change();
                $table->string('condition', 100)->nullable()->change();
            });

            Schema::table('product_variants', function (Blueprint $table) {
                if (! Schema::hasColumn('product_variants', 'cpu')) {
                    $table->string('cpu', 150)->nullable()->after('ssd');
                }
                if (! Schema::hasColumn('product_variants', 'display')) {
                    $table->string('display', 150)->nullable()->after('cpu');
                }
                if (! Schema::hasColumn('product_variants', 'country')) {
                    $table->string('country', 100)->nullable()->after('display');
                }
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasColumn('products', 'product_type')) {
            Schema::table('products', function (Blueprint $table) {
                $table->dropColumn('product_type');
            });
        }

        if (Schema::hasTable('product_variants')) {
            Schema::table('product_variants', function (Blueprint $table) {
                foreach (['cpu', 'display', 'country'] as $column) {
                    if (Schema::hasColumn('product_variants', $column)) {
                        $table->dropColumn($column);
                    }
                }
            });
        }
    }
};
