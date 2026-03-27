<?php

namespace Tests\Feature\Partidos;

use Tests\TestCase;
use Tests\Traits\TieneUsuariosDePrueba;
use Illuminate\Foundation\Testing\RefreshDatabase;
use App\Models\Partidos;
use App\Models\cronogramas;
use App\Models\Competencias;

/**
 * ================================================================
 * SECCIÓN 11 — PARTIDOS
 * ================================================================
 * PK del modelo : idPartidos
 * Soft Deletes  : sí
 * Roles lectura : roles 1, 2 y 3
 * Roles edición : store/update roles 1 y 2; delete solo rol 1
 *
 * Campos fillable: Formacion, EquipoRival, idCronogramas
 * Relaciones     : cronograma (BelongsTo), rendimientosPartidos (HasMany),
 *                  resultados (HasMany), PartidosEquipos (HasMany)
 *
 * Ruta especial  : GET /api/partidos/competencia/{id} → roles 1 y 2
 *
 * Comando: php artisan test --filter PruebasPartidos
 * ================================================================
 */
class PruebasPartidos extends TestCase
{
    use RefreshDatabase, TieneUsuariosDePrueba;

    // ── Lectura (roles 1, 2 y 3) ─────────────────────────────────

    public function test_partidos_listado_admin(): void
    {
        $this->comoAdmin()->getJson('/api/partidos')->assertStatus(200);
    }

    public function test_partidos_listado_entrenador(): void
    {
        $this->comoEntrenador()->getJson('/api/partidos')->assertStatus(200);
    }

    public function test_partidos_listado_jugador(): void
    {
        $this->comoJugador()->getJson('/api/partidos')->assertStatus(200);
    }

    public function test_partidos_ver_detalle_admin(): void
    {
        $partido = Partidos::factory()->create();
        $this->comoAdmin()->getJson("/api/partidos/{$partido->idPartidos}")->assertStatus(200);
    }

    // ── Papelera ─────────────────────────────────────────────────

    public function test_partidos_papelera_admin(): void
    {
        $this->comoAdmin()->getJson('/api/partidos/papelera/listar')->assertStatus(200);
    }

    public function test_partidos_papelera_denegado_jugador(): void
    {
        $this->comoJugador()->getJson('/api/partidos/papelera/listar')->assertStatus(403);
    }

    // ── Escritura (roles 1 y 2) ───────────────────────────────────

    public function test_partidos_crear_admin(): void
    {
        $cronograma = cronogramas::factory()->create();
        $respuesta  = $this->comoAdmin()->postJson('/api/partidos', [
            'idCronogramas' => $cronograma->idCronogramas,
            'EquipoRival'   => 'Club Rival FC',
            'Formacion'     => '4-3-3',
        ]);
        $this->assertContains($respuesta->status(), [200, 201, 422]);
    }

    public function test_partidos_crear_entrenador(): void
    {
        $respuesta = $this->comoEntrenador()->postJson('/api/partidos', []);
        $this->assertContains($respuesta->status(), [200, 201, 422]);
    }

    public function test_partidos_crear_denegado_jugador(): void
    {
        $this->comoJugador()->postJson('/api/partidos', [])->assertStatus(403);
    }

    public function test_partidos_editar_admin(): void
    {
        $partido   = Partidos::factory()->create();
        $respuesta = $this->comoAdmin()->putJson("/api/partidos/{$partido->idPartidos}", ['Formacion' => '4-4-2']);
        $this->assertContains($respuesta->status(), [200, 422]);
    }

    public function test_partidos_eliminar_admin(): void
    {
        $partido   = Partidos::factory()->create();
        $respuesta = $this->comoAdmin()->deleteJson("/api/partidos/{$partido->idPartidos}");
        $this->assertContains($respuesta->status(), [200, 204]);
    }

    // ── Restaurar / Eliminar definitivamente ─────────────────────

    public function test_partidos_restaurar_admin(): void
    {
        $partido   = Partidos::factory()->create();
        $partido->delete();
        $respuesta = $this->comoAdmin()->postJson("/api/partidos/{$partido->idPartidos}/restaurar");
        $this->assertContains($respuesta->status(), [200, 204]);
    }

    public function test_partidos_eliminar_definitivo_admin(): void
    {
        $partido   = Partidos::factory()->create();
        $partido->delete();
        $respuesta = $this->comoAdmin()->deleteJson("/api/partidos/{$partido->idPartidos}/forzar");
        $this->assertContains($respuesta->status(), [200, 204]);
    }

    // ── Relación: partidos por competencia ───────────────────────

    public function test_partidos_por_competencia_admin(): void
    {
        $competencia = Competencias::factory()->create();
        $respuesta   = $this->comoAdmin()->getJson("/api/partidos/competencia/{$competencia->idCompetencias}");
        $this->assertContains($respuesta->status(), [200, 404]);
    }
}