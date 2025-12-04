<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('Jugadores', function (Blueprint $table) {
            $table->id('idJugadores');
            $table->integer('Dorsal');
            $table->string('Posicion', 35);
            $table->string('Upz', 40)->nullable();
            $table->decimal('Estatura', 3, 2)->nullable();
            $table->string('NomTutor1', 30);
            $table->string('NomTutor2', 30)->nullable();
            $table->string('ApeTutor1', 15);
            $table->string('ApeTutor2', 15);
            $table->string('TelefonoTutor', 10);
            $table->unsignedBigInteger('NumeroDeDocumento');
            $table->unsignedBigInteger('idCategorias');

            // Foreign Key de Personas
            $table->foreign('NumeroDeDocumento')
                  ->references('NumeroDeDocumento')
                  ->on('Personas')
                  ->onDelete('cascade')
                  ->onUpdate('cascade');
            // Foreign Key de Categorias
            $table->foreign('idCategorias')
                  ->references('idCategorias')
                  ->on('Categorias')
                  ->onDelete('cascade')
                  ->onUpdate('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('Jugadores');
    }
};
