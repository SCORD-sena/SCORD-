<?php

namespace Tests\Feature\Competencias;

use Tests\TestCase;
use Tests\Traits\TieneUsuariosDePrueba;
use Illuminate\Foundation\Testing\RefreshDatabase;
use App\Models\Competencias;
use App\Models\Categorias;
use App\Models\Equipos;

/**
 * ================================================================
 * SECCIÓN 8 — COMPETENCIAS
 * ================================================================
 * PK del modelo : idCompetencias
 * Soft Deletes  : sí
 * Roles lectura : roles 1 y 2
 * Roles edición : store/delete solo rol 1
 *
 * Campos fillable: idCompetencias, Nombre, TipoCompetencia, Ano, idEquipos
 * Relaciones     : equipos (BelongsTo), cronogramas (HasMany)
 *
 * Ruta especial  : POST /api/competencias/with-categoria → roles 1 y 2
 * Ruta especial  : GET  /api/competencias/categoria/{id} → roles 1 y 2
 *
 * Comando: php artisan test --filter PruebasCompetencias
 * ================================================================
 */
class PruebasCompetencias extends TestCase
{
    use RefreshDatabase, TieneUsuariosDePrueba;

    // ── Lectura ──────────────────────────────────────────────────

    public function test_competencias_listado_admin(): void
    {
        $this->comoAdmin()->getJson('/api/competencias')->assertStatus(200);
    }

    public function test_competencias_listado_entrenador(): void
    {
        $this->comoEntrenador()->getJson('/api/competencias')->assertStatus(200);
    }

    public function test_competencias_listado_denegado_jugador(): void
    {
        $this->comoJugador()->getJson('/api/competencias')->assertStatus(403);
    }

    public function test_competencias_ver_detalle_admin(): void
    {
        $competencia = Competencias::factory()->create();
        $this->comoAdmin()->getJson("/api/competencias/{$competencia->idCompetencias}")->assertStatus(200);
    }

    // ── Papelera ─────────────────────────────────────────────────

    public function test_competencias_papelera_admin(): void
    {
        $this->comoAdmin()->getJson('/api/competencias/papelera/listar')->assertStatus(200);
    }

    // ── Escritura ────────────────────────────────────────────────

    public function test_competencias_crear_admin(): void
    {
        $equipo    = Equipos::factory()->create();
        $respuesta = $this->comoAdmin()->postJson('/api/competencias', [
            'Nombre'          => 'Torneo Apertura',
            'TipoCompetencia' => 'Liga',
            'Ano'             => 2025,
            'idEquipos'       => $equipo->idEquipos,
        ]);
        $this->assertContains($respuesta->status(), [200, 201, 422]);
    }

    public function test_competencias_crear_denegado_entrenador(): void
    {
        $this->comoEntrenador()->postJson('/api/competencias', [])->assertStatus(403);
    }

    /**
     * POST /api/competencias/with-categoria
     * Crea competencia y categoría juntas — accesible por roles 1 y 2.
     */
    public function test_competencias_crear_con_categoria_admin(): void
    {
        $respuesta = $this->comoAdmin()->postJson('/api/competencias/with-categoria', [
            // ⚠️  Completa con los campos combinados de competencia + categoría
        ]);
        $this->assertContains($respuesta->status(), [200, 201, 422]);
    }

    public function test_competencias_crear_con_categoria_entrenador(): void
    {
        $respuesta = $this->comoEntrenador()->postJson('/api/competencias/with-categoria', []);
        $this->assertContains($respuesta->status(), [200, 201, 422]);
    }

    public function test_competencias_editar_admin(): void
    {
        $competencia = Competencias::factory()->create();
        $respuesta   = $this->comoAdmin()->putJson("/api/competencias/{$competencia->idCompetencias}", ['Nombre' => 'Torneo Clausura']);
        $this->assertContains($respuesta->status(), [200, 422]);
    }

    public function test_competencias_eliminar_admin(): void
    {
        $competencia = Competencias::factory()->create();
        $respuesta   = $this->comoAdmin()->deleteJson("/api/competencias/{$competencia->idCompetencias}");
        $this->assertContains($respuesta->status(), [200, 204]);
    }

    // ── Restaurar / Eliminar definitivamente ─────────────────────

    public function test_competencias_restaurar_admin(): void
    {
        $competencia = Competencias::factory()->create();
        $competencia->delete();
        $respuesta   = $this->comoAdmin()->postJson("/api/competencias/{$competencia->idCompetencias}/restaurar");
        $this->assertContains($respuesta->status(), [200, 204]);
    }

    public function test_competencias_eliminar_definitivo_admin(): void
    {
        $competencia = Competencias::factory()->create();
        $competencia->delete();
        $respuesta   = $this->comoAdmin()->deleteJson("/api/competencias/{$competencia->idCompetencias}/forzar");
        $this->assertContains($respuesta->status(), [200, 204]);
    }

    // ── Relación: competencias por categoría ─────────────────────

    public function test_competencias_por_categoria_admin(): void
    {
        $categoria = Categorias::factory()->create();
        $respuesta = $this->comoAdmin()->getJson("/api/competencias/categoria/{$categoria->idCategorias}");
        $this->assertContains($respuesta->status(), [200, 404]);
    }

    public function test_competencias_por_categoria_entrenador(): void
    {
        $categoria = Categorias::factory()->create();
        $respuesta = $this->comoEntrenador()->getJson("/api/competencias/categoria/{$categoria->idCategorias}");
        $this->assertContains($respuesta->status(), [200, 404]);
    }
}