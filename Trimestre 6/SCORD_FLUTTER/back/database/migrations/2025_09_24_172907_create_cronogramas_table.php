<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('Cronogramas', function (Blueprint $table) {
            $table->id('idCronogramas');
            $table->date('FechaDeEventos');
            $table->string('TipoDeEventos', 45);
            $table->string('CanchaPartido', 45)->nullable();
            $table->string('Ubicacion', 45);
            $table->string('SedeEntrenamiento', 45)->nullable();
            $table->string('Descripcion', 45);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('Cronogramas');
    }
};
