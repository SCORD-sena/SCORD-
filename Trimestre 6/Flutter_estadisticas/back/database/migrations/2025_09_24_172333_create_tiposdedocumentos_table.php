<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tiposdedocumentos', function (Blueprint $table) {
            $table->id('idTiposDeDocumentos');
            $table->string('Descripcion', 30);
        });
    }


    
    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('tiposdedocumentos');
    }
};
