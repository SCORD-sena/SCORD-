<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('Personas', function (Blueprint $table) {
            $table->id('idPersonas');
            $table->string('Nombre1', 30);
            $table->string('Nombre2', 30)->nullable();
            $table->string('Apellido1', 30);
            $table->string('Apellido2', 30);
            $table->date('FechaDeNacimiento');
            $table->string('Genero', 9);
            $table->string('Telefono', 10);
            $table->string('EpsSisben', 38);
            $table->string('Direccion', 40);
            $table->string('Correo', 50);
            $table->string('Contraseña', 255);

            // Columnas para relaciones
            $table->unsignedBigInteger('idTiposDeDocumentos');
            $table->unsignedBigInteger('idRoles');

            // Foreign Key de TiposDeDocumentos
            $table->foreign('idTiposDeDocumentos')
                  ->references('idTiposDeDocumentos')
                  ->on('TiposDeDocumentos')
                  ->onDelete('cascade')
                  ->onUpdate('cascade');
            // Foreign Key de Roles
            $table->foreign('idRoles')
                  ->references('idRoles')
                  ->on('Roles')
                  ->onDelete('cascade')
                  ->onUpdate('cascade');

        });
    }

    public function down(): void
    {
        Schema::dropIfExists('Personas');
    }
};

