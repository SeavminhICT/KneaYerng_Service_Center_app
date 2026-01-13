<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('technicians', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->json('skill_set')->nullable();
            $table->unsignedInteger('active_jobs_count')->default(0);
            $table->string('availability_status', 50)->default('available');
            $table->timestamps();
        });

        Schema::create('repair_requests', function (Blueprint $table) {
            $table->id();
            $table->foreignId('customer_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('technician_id')->nullable()->constrained('technicians')->nullOnDelete();
            $table->string('device_model');
            $table->string('issue_type');
            $table->string('service_type', 50);
            $table->dateTime('appointment_datetime')->nullable();
            $table->string('status', 50)->default('received');
            $table->timestamps();

            $table->index('status');
            $table->index('customer_id');
        });

        Schema::create('intakes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('repair_id')->constrained('repair_requests')->cascadeOnDelete();
            $table->string('imei_serial', 100)->nullable();
            $table->json('device_condition_checklist')->nullable();
            $table->json('intake_photos')->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();

            $table->unique('repair_id');
        });

        Schema::create('diagnostics', function (Blueprint $table) {
            $table->id();
            $table->foreignId('repair_id')->constrained('repair_requests')->cascadeOnDelete();
            $table->text('problem_description')->nullable();
            $table->json('parts_required')->nullable();
            $table->decimal('labor_cost', 12, 2)->default(0);
            $table->text('diagnostic_notes')->nullable();
            $table->timestamps();

            $table->unique('repair_id');
        });

        Schema::create('quotations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('repair_id')->constrained('repair_requests')->cascadeOnDelete();
            $table->decimal('parts_cost', 12, 2)->default(0);
            $table->decimal('labor_cost', 12, 2)->default(0);
            $table->decimal('total_cost', 12, 2)->default(0);
            $table->string('status', 50)->default('pending');
            $table->timestamp('customer_approved_at')->nullable();
            $table->timestamps();

            $table->unique('repair_id');
        });

        Schema::create('repair_status_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('repair_id')->constrained('repair_requests')->cascadeOnDelete();
            $table->string('status', 50);
            $table->foreignId('updated_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('logged_at')->useCurrent();
            $table->timestamps();
        });

        Schema::create('parts', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('sku', 100)->nullable()->unique();
            $table->unsignedInteger('stock')->default(0);
            $table->decimal('unit_cost', 12, 2)->default(0);
            $table->string('status', 50)->default('active');
            $table->timestamps();
        });

        Schema::create('parts_usages', function (Blueprint $table) {
            $table->id();
            $table->foreignId('repair_id')->constrained('repair_requests')->cascadeOnDelete();
            $table->foreignId('part_id')->constrained('parts')->restrictOnDelete();
            $table->unsignedInteger('quantity');
            $table->decimal('cost', 12, 2)->default(0);
            $table->timestamps();
        });

        Schema::create('warranties', function (Blueprint $table) {
            $table->id();
            $table->foreignId('repair_id')->constrained('repair_requests')->cascadeOnDelete();
            $table->unsignedInteger('duration_days')->nullable();
            $table->text('covered_issues')->nullable();
            $table->date('start_date')->nullable();
            $table->date('end_date')->nullable();
            $table->string('status', 50)->default('active');
            $table->timestamps();

            $table->unique('repair_id');
        });

        Schema::create('invoices', function (Blueprint $table) {
            $table->id();
            $table->foreignId('repair_id')->constrained('repair_requests')->cascadeOnDelete();
            $table->string('invoice_number', 100)->unique();
            $table->decimal('subtotal', 12, 2)->default(0);
            $table->decimal('tax', 12, 2)->default(0);
            $table->decimal('total', 12, 2)->default(0);
            $table->string('payment_status', 50)->default('pending');
            $table->timestamps();

            $table->unique('repair_id');
        });

        Schema::create('repair_payments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('invoice_id')->constrained('invoices')->cascadeOnDelete();
            $table->string('type', 50);
            $table->string('method', 50);
            $table->decimal('amount', 12, 2);
            $table->string('status', 50)->default('pending');
            $table->string('transaction_ref', 150)->nullable();
            $table->timestamps();
        });

        Schema::create('chat_messages', function (Blueprint $table) {
            $table->id();
            $table->foreignId('repair_id')->constrained('repair_requests')->cascadeOnDelete();
            $table->string('sender_type', 50);
            $table->text('message');
            $table->timestamps();
        });

        Schema::create('repair_notifications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('repair_id')->nullable()->constrained('repair_requests')->nullOnDelete();
            $table->string('type', 50)->nullable();
            $table->string('title', 150);
            $table->text('body')->nullable();
            $table->timestamp('read_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('repair_notifications');
        Schema::dropIfExists('chat_messages');
        Schema::dropIfExists('repair_payments');
        Schema::dropIfExists('invoices');
        Schema::dropIfExists('warranties');
        Schema::dropIfExists('parts_usages');
        Schema::dropIfExists('parts');
        Schema::dropIfExists('repair_status_logs');
        Schema::dropIfExists('quotations');
        Schema::dropIfExists('diagnostics');
        Schema::dropIfExists('intakes');
        Schema::dropIfExists('repair_requests');
        Schema::dropIfExists('technicians');
    }
};
