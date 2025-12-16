<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('Personas', function (Blueprint $table) {
            // Solo agregamos status (deleted_at ya existe)
            $table->enum('status', ['activo', 'inactivo', 'suspendido'])
                  ->default('activo')
                  ->after('contrasena');
        });
    }

    public function down(): void
    {
        Schema::table('Personas', function (Blueprint $table) {
            $table->dropColumn('status');
            // No tocamos deleted_at porque ya existía antes
        });
    }
};