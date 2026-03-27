<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('competencias', function (Blueprint $table) {
            $table->id('idCompetencias');
            $table->string('Nombre', 30);
            $table->string('TipoCompetencia', 30);
            $table->integer('Año');

            $table->unsignedBigInteger('idEquipos');

            // Foreign key Equipos
            $table->foreign('idEquipos')
                  ->references('idEquipos')
                  ->on('equipos')
                  ->onDelete('cascade')
                  ->onUpdate('cascade');



                   $table->timestamps();
                  $table->engine = 'InnoDB';
        });
    }



    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('competencias');
    }
};
