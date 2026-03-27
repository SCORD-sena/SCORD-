<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('PartidosEquipos', function (Blueprint $table) {
            $table->unsignedBigInteger('idPartidos');
            $table->unsignedBigInteger('idEquipos');
            $table->boolean('EsLocal');

            // Definir claves foráneas de partidos
            $table->foreign('idPartidos')
                   ->references('idPartidos')
                   ->on('Partidos')
                   ->onDelete('cascade')
                   ->onUpdate('cascade');
            // Definir claves foráneas de equipos
            $table->foreign('idEquipos')
                   ->references('idEquipos')
                   ->on('Equipos')
                   ->onDelete('cascade')
                   ->onUpdate('cascade');

                   
            $table->primary(['idPartidos', 'idEquipos']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('PartidosEquipos');
    }
};
