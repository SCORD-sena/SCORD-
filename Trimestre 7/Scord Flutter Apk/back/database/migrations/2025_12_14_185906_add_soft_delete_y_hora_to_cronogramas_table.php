<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('Cronogramas', function (Blueprint $table) {
            // Agregar columna hora
            $table->time('Hora')->nullable()->after('FechaDeEventos');
            
            // Agregar soft delete
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::table('Cronogramas', function (Blueprint $table) {
            $table->dropColumn('Hora');
            $table->dropSoftDeletes();
        });
    }
};