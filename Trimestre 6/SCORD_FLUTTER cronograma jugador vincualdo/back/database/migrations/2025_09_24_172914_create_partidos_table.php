<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('Partidos', function (Blueprint $table) {
            $table->id('idPartidos');
            $table->string('Formacion', 10);
            $table->string('EquipoRival', 45);
            $table->unsignedBigInteger('idCronogramas');

            // Foreign Key
            $table->foreign('idCronogramas')
                  ->references('idCronogramas')
                  ->on('Cronogramas')
                  ->onDelete('cascade')
                  ->onUpdate('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('Partidos');
    }
};
