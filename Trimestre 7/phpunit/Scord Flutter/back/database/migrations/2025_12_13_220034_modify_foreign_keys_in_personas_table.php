<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
 public function up(): void
{
    DB::statement('SET FOREIGN_KEY_CHECKS=0;');

    Schema::table('Personas', function (Blueprint $table) {
        // Primero eliminar las FKs que ya existen
        $table->dropForeign(['idTiposDeDocumentos']);
        $table->dropForeign(['idRoles']);

        // Luego crearlas con las nuevas reglas (restrict)
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

    DB::statement('SET FOREIGN_KEY_CHECKS=1;');
}

public function down(): void
{
    DB::statement('SET FOREIGN_KEY_CHECKS=0;');
    
    Schema::table('Personas', function (Blueprint $table) {
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
    
    DB::statement('SET FOREIGN_KEY_CHECKS=1;');
}
};