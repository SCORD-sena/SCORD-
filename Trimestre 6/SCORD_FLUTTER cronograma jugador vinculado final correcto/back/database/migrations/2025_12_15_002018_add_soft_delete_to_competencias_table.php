<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('Competencias', function (Blueprint $table) {
            // Agregar soft delete
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::table('Competencias', function (Blueprint $table) {
            $table->dropSoftDeletes();
        });
    }
};