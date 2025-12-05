<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('Equipos', function (Blueprint $table) {
            $table->id('idEquipos');
            $table->integer('CantidadJugadores');
            $table->string('sub', 10);

            $table->timestamps();
                  $table->engine = 'InnoDB';
        });
    }


    
    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('Equipos');
    }
};
