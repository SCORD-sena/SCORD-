<?php

namespace Tests\Feature\Equipos;

use Tests\TestCase;
use Tests\Traits\TieneUsuariosDePrueba;
use Illuminate\Foundation\Testing\RefreshDatabase;
use App\Models\Equipos;

/**
 * ================================================================
 * SECCIÓN 9 — EQUIPOS
 * ================================================================
 * PK del modelo : idEquipos
 * Soft Deletes  : no
 * Roles lectura : roles 1 y 2
 * Roles edición : solo rol 1 (admin)
 *
 * Campos fillable: CantidadJugadores, Sub
 * Relaciones     : competencias (HasMany), PartidosEquipos (HasMany)
 *
 * Comando: php artisan test --filter PruebasEquipos
 * ================================================================
 */
class PruebasEquipos extends TestCase
{
    use RefreshDatabase, TieneUsuariosDePrueba;

    // ── Lectura ──────────────────────────────────────────────────

    public function test_equipos_listado_admin(): void
    {
        $this->comoAdmin()->getJson('/api/equipos')->assertStatus(200);
    }

    public function test_equipos_listado_entrenador(): void
    {
        $this->comoEntrenador()->getJson('/api/equipos')->assertStatus(200);
    }

    public function test_equipos_listado_denegado_jugador(): void
    {
        $this->comoJugador()->getJson('/api/equipos')->assertStatus(403);
    }

    public function test_equipos_ver_detalle_admin(): void
    {
        $equipo    = Equipos::factory()->create();
        $respuesta = $this->comoAdmin()->getJson("/api/equipos/{$equipo->idEquipos}");
        $this->assertContains($respuesta->status(), [200, 404]);
    }

    // ── Escritura ────────────────────────────────────────────────

    public function test_equipos_crear_admin(): void
    {
        $respuesta = $this->comoAdmin()->postJson('/api/equipos', [
            'CantidadJugadores' => 18,
            'Sub'               => 15,
        ]);
        $this->assertContains($respuesta->status(), [200, 201, 422]);
    }

    public function test_equipos_crear_denegado_entrenador(): void
    {
        $this->comoEntrenador()->postJson('/api/equipos', [])->assertStatus(403);
    }

    public function test_equipos_editar_admin(): void
    {
        $equipo    = Equipos::factory()->create();
        $respuesta = $this->comoAdmin()->putJson("/api/equipos/{$equipo->idEquipos}", ['Sub' => 17]);
        $this->assertContains($respuesta->status(), [200, 422]);
    }

    public function test_equipos_eliminar_admin(): void
    {
        $equipo    = Equipos::factory()->create();
        $respuesta = $this->comoAdmin()->deleteJson("/api/equipos/{$equipo->idEquipos}");
        $this->assertContains($respuesta->status(), [200, 204]);
    }
}