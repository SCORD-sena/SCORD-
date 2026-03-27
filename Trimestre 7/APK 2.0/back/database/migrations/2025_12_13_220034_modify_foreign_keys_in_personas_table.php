<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('Personas', function (Blueprint $table) {
            // 1. Eliminar las foreign keys actuales (usando sus nombres reales)
            $table->dropForeign('fk_Persona_TiposDeDocumentos1');
            $table->dropForeign('fk_Personas_Roles1');
            
            // 2. Crear las nuevas foreign keys (con restrict)
            $table->foreign('idTiposDeDocumentos')
                  ->references('idTiposDeDocumentos')
                  ->on('TiposDeDocumentos')
                  ->onDelete('restrict')
                  ->onUpdate('cascade');
                  
            $table->foreign('idRoles')
                  ->references('idRoles')
                  ->on('Roles')
                  ->onDelete('restrict')
                  ->onUpdate('cascade');
        });
    }

    public function down(): void
    {
        Schema::table('Personas', function (Blueprint $table) {
            // Si hacemos rollback, volvemos a dejar cascade
            $table->dropForeign(['idTiposDeDocumentos']);
            $table->dropForeign(['idRoles']);
            
            $table->foreign('idTiposDeDocumentos')
                  ->references('idTiposDeDocumentos')
                  ->on('TiposDeDocumentos')
                  ->onDelete('cascade')
                  ->onUpdate('cascade');
                  
            $table->foreign('idRoles')
                  ->references('idRoles')
                  ->on('Roles')
                  ->onDelete('cascade')
                  ->onUpdate('cascade');
        });
    }
};