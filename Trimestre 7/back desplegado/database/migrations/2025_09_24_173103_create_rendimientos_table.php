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
        Schema::create('RendimientosPartidos', function (Blueprint $table) {
            $table->id('idRendimientos');
            $table->integer('Goles')->nullable();
            $table->integer('GolesDeCabeza')->nullable();
            $table->integer('MinutosJugados')->nullable();
            $table->integer('Asistencias')->nullable();
            $table->integer('TirosApuerta')->nullable();
            $table->integer('TarjetasRojas')->nullable();
            $table->integer('TarjetasAmarillas')->nullable();
            $table->string('FuerasDeLugar', 45)->nullable();
            $table->integer('ArcoEnCero')->nullable();
            $table->unsignedBigInteger('idPartidos');
            $table->unsignedBigInteger('idJugadores');

            //fk de partidos
            $table->foreign('idPartidos')
                  ->references('idPartidos')
                  ->on('Partidos')
                  ->onDelete('cascade')
                  ->onUpdate('cascade');
            //fk de jugadores
            $table->foreign('idJugadores')
                  ->references('idJugadores')
                  ->on('Jugadores')
                  ->onDelete('cascade')
                  ->onUpdate('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('RendimientosPartidos');
    }
};
