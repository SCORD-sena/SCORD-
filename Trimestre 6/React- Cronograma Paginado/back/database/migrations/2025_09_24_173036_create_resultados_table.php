<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('Resultados', function (Blueprint $table) {
            $table->id('idResultados');
            $table->string('Marcador', 10);
            $table->integer('PuntosObtenidos');
            $table->string('Observacion', 100)->nullable();
            $table->unsignedBigInteger('idPartidos');

            //fk de Partidos
            $table->foreign('idPartidos')
                  ->references('idPartidos')
                  ->on('Partidos')
                  ->onDelete('cascade')
                  ->onUpdate('cascade');

        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('Resultados');
    }
};
