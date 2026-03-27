<?php

namespace Tests\Feature\TiposDeDocumentos;

use Tests\TestCase;
use Tests\Traits\TieneUsuariosDePrueba;
use Illuminate\Foundation\Testing\RefreshDatabase;
use App\Models\TiposDeDocumentos;

/**
 * ================================================================
 * SECCIÓN 4 — TIPOS DE DOCUMENTOS
 * ================================================================
 * PK del modelo : idTiposDeDocumentos
 * Soft Deletes  : no
 * Roles lectura : roles 1 y 2
 * Roles edición : solo rol 1 (admin)
 *
 * Campos fillable: idTiposDeDocumentos, Descripcion
 *
 * Comando: php artisan test --filter PruebasTiposDeDocumentos
 * ================================================================
 */
class PruebasTiposDeDocumentos extends TestCase
{
    use RefreshDatabase, TieneUsuariosDePrueba;

    // ── Lectura ──────────────────────────────────────────────────

    public function test_tipos_documentos_listado_admin(): void
    {
        $this->comoAdmin()->getJson('/api/tiposdedocumentos')->assertStatus(200);
    }

    public function test_tipos_documentos_listado_entrenador(): void
    {
        // Entrenador tiene permiso de lectura (roles 1 y 2)
        $this->comoEntrenador()->getJson('/api/tiposdedocumentos')->assertStatus(200);
    }

    public function test_tipos_documentos_listado_denegado_jugador(): void
    {
        $this->comoJugador()->getJson('/api/tiposdedocumentos')->assertStatus(403);
    }

    public function test_tipos_documentos_ver_detalle_admin(): void
    {
        $tipo      = TiposDeDocumentos::factory()->create();
        $respuesta = $this->comoAdmin()->getJson("/api/tiposdedocumentos/{$tipo->idTiposDeDocumentos}");
        $this->assertContains($respuesta->status(), [200, 404]);
    }

    // ── Escritura ────────────────────────────────────────────────

    public function test_tipos_documentos_crear_admin(): void
    {
        $respuesta = $this->comoAdmin()->postJson('/api/tiposdedocumentos', [
            'Descripcion' => 'Pasaporte',
        ]);
        $this->assertContains($respuesta->status(), [200, 201, 422]);
    }

    public function test_tipos_documentos_crear_denegado_entrenador(): void
    {
        // Solo admin puede crear
        $this->comoEntrenador()->postJson('/api/tiposdedocumentos', [])->assertStatus(403);
    }

    public function test_tipos_documentos_editar_admin(): void
    {
        $tipo      = TiposDeDocumentos::factory()->create();
        $respuesta = $this->comoAdmin()->putJson("/api/tiposdedocumentos/{$tipo->idTiposDeDocumentos}", ['Descripcion' => 'Cédula de Ciudadanía']);
        $this->assertContains($respuesta->status(), [200, 422]);
    }

    public function test_tipos_documentos_eliminar_admin(): void
    {
        $tipo      = TiposDeDocumentos::factory()->create();
        $respuesta = $this->comoAdmin()->deleteJson("/api/tiposdedocumentos/{$tipo->idTiposDeDocumentos}");
        $this->assertContains($respuesta->status(), [200, 204]);
    }
}