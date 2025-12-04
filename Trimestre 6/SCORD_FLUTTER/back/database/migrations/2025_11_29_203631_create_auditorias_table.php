<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('auditorias', function (Blueprint $table) {
            $table->id();
            $table->string('tabla');
            $table->unsignedBigInteger('registro_id');
            $table->string('accion');
            $table->unsignedBigInteger('idPersonas')->nullable();
            $table->json('datos_anteriores')->nullable();
            $table->json('datos_nuevos')->nullable();
            $table->string('ip')->nullable();
            $table->text('user_agent')->nullable();
            $table->timestamps();

            $table->index(['tabla', 'registro_id']);
            $table->index('idPersonas');
            $table->index('accion');
            $table->index('created_at');
            
            $table->foreign('idPersonas')
                  ->references('idPersonas')
                  ->on('Personas')
                  ->onDelete('set null');
        });
    }

    public function down()
    {
        Schema::dropIfExists('auditorias');
    }
};