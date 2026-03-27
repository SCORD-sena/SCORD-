<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('Categorias', function (Blueprint $table) {
            $table->id('idCategorias');
            $table->string('Descripcion', 45);
            $table->string('TiposCategoria', 45);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('Categorias');
    }
};
