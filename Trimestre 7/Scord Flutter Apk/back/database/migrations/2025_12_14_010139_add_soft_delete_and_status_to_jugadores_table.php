<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('Jugadores', function (Blueprint $table) {
            // Agregar soft delete
            $table->softDeletes();
            
            // Agregar campo de status
            $table->enum('status', ['activo', 'inactivo', 'retirado'])
                  ->default('activo')
                  ->after('TelefonoTutor');
        });
    }

    public function down(): void
    {
        Schema::table('Jugadores', function (Blueprint $table) {
            $table->dropSoftDeletes();
            $table->dropColumn('status');
        });
    }
};