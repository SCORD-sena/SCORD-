<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('Entrenadores', function (Blueprint $table) {
            $table->id('idEntrenadores');
            $table->string('AnosDeExperiencia', 45);
            $table->string('Cargo', 45);
            $table->unsignedBigInteger('NumeroDeDocumento');

            // Foreign Key
            $table->foreign('NumeroDeDocumento')
                  ->references('NumeroDeDocumento')
                  ->on('Personas')
                  ->onDelete('cascade')
                  ->onUpdate('cascade'); 
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('Entrenadores');
    }
};
