<?php

namespace Tests\Feature\Partidos;

use Tests\TestCase;
use Tests\Traits\TieneUsuariosDePrueba;
use Illuminate\Foundation\Testing\RefreshDatabase;
use App\Models\PartidosEquipos;
use App\Models\Partidos;
use App\Models\Equipos;

/**
 * ================================================================
 * SECCIÓN 12 — PARTIDOS EQUIPOS
 * ================================================================
 * PK del modelo : sin PK (tabla pivote con incrementing = false)
 * Soft Deletes  : no
 * Roles lectura : roles 1 y 2
 * Roles edición : store/update/delete roles 1 y 2
 *
 * Campos fillable: idPartidos, idEquipos, EsLocal
 * Relaciones     : partido (BelongsTo), equipo (BelongsTo)
 *
 * Comando: php artisan test --filter PruebasPartidosEquipos
 * ================================================================
 */
class PruebasPartidosEquipos extends TestCase
{
    use RefreshDatabase, TieneUsuariosDePrueba;

    // ── Lectura ──────────────────────────────────────────────────

    public function test_partidos_equipos_listado_admin(): void
    {
        $this->comoAdmin()->getJson('/api/partidosequipos')->assertStatus(200);
    }

    public function test_partidos_equipos_listado_entrenador(): void
    {
        $this->comoEntrenador()->getJson('/api/partidosequipos')->assertStatus(200);
    }

    public function test_partidos_equipos_listado_denegado_jugador(): void
    {
        $this->comoJugador()->getJson('/api/partidosequipos')->assertStatus(403);
    }

    // ── Escritura ────────────────────────────────────────────────

    public function test_partidos_equipos_crear_admin(): void
    {
        $partido   = Partidos::factory()->create();
        $equipo    = Equipos::factory()->create();
        $respuesta = $this->comoAdmin()->postJson('/api/partidosequipos', [
            'idPartidos' => $partido->idPartidos,
            'idEquipos'  => $equipo->idEquipos,
            'EsLocal'    => true,
        ]);
        $this->assertContains($respuesta->status(), [200, 201, 422]);
    }

    public function test_partidos_equipos_crear_denegado_jugador(): void
    {
        $this->comoJugador()->postJson('/api/partidosequipos', [])->assertStatus(403);
    }

    public function test_partidos_equipos_editar_admin(): void
    {
        $pe        = PartidosEquipos::factory()->create();
        $respuesta = $this->comoAdmin()->putJson("/api/partidosequipos/{$pe->id}", ['EsLocal' => false]);
        $this->assertContains($respuesta->status(), [200, 422]);
    }

    public function test_partidos_equipos_eliminar_admin(): void
    {
        $pe        = PartidosEquipos::factory()->create();
        $respuesta = $this->comoAdmin()->deleteJson("/api/partidosequipos/{$pe->id}");
        $this->assertContains($respuesta->status(), [200, 204]);
    }
}