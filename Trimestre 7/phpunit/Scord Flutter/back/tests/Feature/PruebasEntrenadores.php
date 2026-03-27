<?php

namespace Tests\Feature\Entrenadores;

use Tests\TestCase;
use Tests\Traits\TieneUsuariosDePrueba;
use Illuminate\Foundation\Testing\RefreshDatabase;
use App\Models\Entrenadores;
use App\Models\Personas;

/**
 * ================================================================
 * SECCIÓN 6 — ENTRENADORES
 * ================================================================
 * PK del modelo : idEntrenadores
 * Soft Deletes  : sí
 * Roles lectura : roles 1 y 2
 * Roles edición : store/delete solo rol 1; update roles 1 y 2
 *
 * Campos fillable: idPersonas, AnosDeExperiencia, Cargo
 * Relaciones     : persona (BelongsTo con withTrashed), categorias (M:M)
 *
 * Ruta especial  : GET /api/entrenadores/misCategorias → solo rol 2
 *
 * Comando: php artisan test --filter PruebasEntrenadores
 * ================================================================
 */
class PruebasEntrenadores extends TestCase
{
    use RefreshDatabase, TieneUsuariosDePrueba;

    // ── Lectura (roles 1 y 2) ────────────────────────────────────

    public function test_entrenadores_listado_admin(): void
    {
        $this->comoAdmin()->getJson('/api/entrenadores')->assertStatus(200);
    }

    public function test_entrenadores_listado_entrenador(): void
    {
        $this->comoEntrenador()->getJson('/api/entrenadores')->assertStatus(200);
    }

    public function test_entrenadores_listado_denegado_jugador(): void
    {
        $this->comoJugador()->getJson('/api/entrenadores')->assertStatus(403);
    }

    public function test_entrenadores_ver_detalle_admin(): void
    {
        $entrenador = Entrenadores::factory()->create();
        $this->comoAdmin()->getJson("/api/entrenadores/{$entrenador->idEntrenadores}")->assertStatus(200);
    }

    // ── Ruta exclusiva Entrenador ─────────────────────────────────

    /**
     * GET /api/entrenadores/misCategorias
     * Solo accesible por rol 2 (entrenador).
     */
    public function test_entrenadores_mis_categorias_entrenador(): void
    {
        $this->comoEntrenador()->getJson('/api/entrenadores/misCategorias')->assertStatus(200);
    }

    public function test_entrenadores_mis_categorias_denegado_admin(): void
    {
        $this->comoAdmin()->getJson('/api/entrenadores/misCategorias')->assertStatus(403);
    }

    public function test_entrenadores_mis_categorias_denegado_jugador(): void
    {
        $this->comoJugador()->getJson('/api/entrenadores/misCategorias')->assertStatus(403);
    }

    // ── Papelera ─────────────────────────────────────────────────

    public function test_entrenadores_papelera_admin(): void
    {
        $this->comoAdmin()->getJson('/api/entrenadores/trashed')->assertStatus(200);
    }

    public function test_entrenadores_papelera_entrenador(): void
    {
        $this->comoEntrenador()->getJson('/api/entrenadores/trashed')->assertStatus(200);
    }

    // ── Escritura (store/delete solo rol 1) ──────────────────────

    public function test_entrenadores_crear_admin(): void
    {
        $persona   = Personas::factory()->create(['idRoles' => 2]);
        $respuesta = $this->comoAdmin()->postJson('/api/entrenadores', [
            'idPersonas'        => $persona->idPersonas,
            'AnosDeExperiencia' => 5,
            'Cargo'             => 'Entrenador Principal',
        ]);
        $this->assertContains($respuesta->status(), [200, 201, 422]);
    }

    public function test_entrenadores_crear_denegado_entrenador(): void
    {
        $this->comoEntrenador()->postJson('/api/entrenadores', [])->assertStatus(403);
    }

    public function test_entrenadores_editar_admin(): void
    {
        $entrenador = Entrenadores::factory()->create();
        $respuesta  = $this->comoAdmin()->putJson("/api/entrenadores/{$entrenador->idEntrenadores}", ['Cargo' => 'Asistente']);
        $this->assertContains($respuesta->status(), [200, 422]);
    }

    public function test_entrenadores_editar_entrenador(): void
    {
        $entrenador = Entrenadores::factory()->create();
        $respuesta  = $this->comoEntrenador()->putJson("/api/entrenadores/{$entrenador->idEntrenadores}", ['Cargo' => 'Asistente']);
        $this->assertContains($respuesta->status(), [200, 422]);
    }

    public function test_entrenadores_eliminar_admin(): void
    {
        $entrenador = Entrenadores::factory()->create();
        $respuesta  = $this->comoAdmin()->deleteJson("/api/entrenadores/{$entrenador->idEntrenadores}");
        $this->assertContains($respuesta->status(), [200, 204]);
    }

    public function test_entrenadores_eliminar_denegado_entrenador(): void
    {
        $entrenador = Entrenadores::factory()->create();
        $this->comoEntrenador()->deleteJson("/api/entrenadores/{$entrenador->idEntrenadores}")->assertStatus(403);
    }

    // ── Restaurar / Eliminar definitivamente ─────────────────────

    public function test_entrenadores_restaurar_admin(): void
    {
        $entrenador = Entrenadores::factory()->create();
        $entrenador->delete();
        $respuesta  = $this->comoAdmin()->postJson("/api/entrenadores/{$entrenador->idEntrenadores}/restore");
        $this->assertContains($respuesta->status(), [200, 204]);
    }

    public function test_entrenadores_eliminar_definitivo_solo_admin(): void
    {
        $entrenador = Entrenadores::factory()->create();
        $entrenador->delete();
        $respuesta  = $this->comoAdmin()->deleteJson("/api/entrenadores/{$entrenador->idEntrenadores}/force");
        $this->assertContains($respuesta->status(), [200, 204]);
    }

    public function test_entrenadores_eliminar_definitivo_denegado_entrenador(): void
    {
        $entrenador = Entrenadores::factory()->create();
        $entrenador->delete();
        $this->comoEntrenador()->deleteJson("/api/entrenadores/{$entrenador->idEntrenadores}/force")->assertStatus(403);
    }
}