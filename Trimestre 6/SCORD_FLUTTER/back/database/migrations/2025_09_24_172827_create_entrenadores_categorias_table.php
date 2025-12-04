<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('EntrenadoresCategorias', function (Blueprint $table) {
            $table->unsignedBigInteger('idEntrenadores');
            $table->unsignedBigInteger('idCategorias');

            // Foreign Key Entrenadores
            $table->foreign('idEntrenadores')
                  ->references('idEntrenadores')
                  ->on('Entrenadores')
                  ->onDelete('cascade')
                  ->onUpdate('cascade');
            // Foreign Key Categorias
            $table->foreign('idCategorias')
                  ->references('idCategorias')
                  ->on('Categorias')
                  ->onDelete('cascade')
                  ->onUpdate('cascade');

            $table->primary(['idEntrenadores', 'idCategorias']);      
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('EntrenadoresCategorias');
    }
};
