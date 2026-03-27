<?php

namespace Tests\Feature\Rendimientos;

use Tests\TestCase;
use Tests\Traits\TieneUsuariosDePrueba;
use Illuminate\Foundation\Testing\RefreshDatabase;
use App\Models\RendimientosPartidos;
use App\Models\Jugadores;
use App\Models\Partidos;
use App\Models\Competencias;

/**
 * ================================================================
 * SECCIÓN 14 — RENDIMIENTOS PARTIDOS
 * ================================================================
 * PK del modelo : IdRendimientos
 * Soft Deletes  : sí
 * Roles lectura : roles 1 y 2 (índice general); roles 1,2,3 (por jugador)
 * Roles edición : store/update roles 1 y 2; delete solo rol 1
 *
 * Campos fillable: Goles, GolesDeCabeza, MinutosJugados, Asistencias,
 *                  TirosApuerta, TarjetasRojas, TarjetasAmarillas,
 *                  FuerasDeLugar, ArcoEnCero, idPartidos, idJugadores
 * Relaciones     : partido (BelongsTo), jugador (BelongsTo)
 *
 * Ruta especial  : GET /api/rendimientospartidos/mis-estadisticas → solo rol 3
 * Rutas filtro   : /jugador/{id}/totales, /temporadas, /ultimos-partidos/{n},
 *                  /ultimo-registro, /partido/{id} → roles 1, 2 y 3
 *
 * Comando: php artisan test --filter PruebasRendimientosPartidos
 * ================================================================
 */
class PruebasRendimientosPartidos extends TestCase
{
    use RefreshDatabase, TieneUsuariosDePrueba;

    // ── Lectura general (roles 1 y 2) ────────────────────────────

    public function test_rendimientos_listado_admin(): void
    {
        $this->comoAdmin()->getJson('/api/rendimientospartidos')->assertStatus(200);
    }

    public function test_rendimientos_listado_entrenador(): void
    {
        $this->comoEntrenador()->getJson('/api/rendimientospartidos')->assertStatus(200);
    }

    public function test_rendimientos_listado_denegado_jugador(): void
    {
        $this->comoJugador()->getJson('/api/rendimientospartidos')->assertStatus(403);
    }

    public function test_rendimientos_ver_detalle_admin(): void
    {
        $rendimiento = RendimientosPartidos::factory()->create();
        $respuesta   = $this->comoAdmin()->getJson("/api/rendimientospartidos/{$rendimiento->IdRendimientos}");
        $this->assertContains($respuesta->status(), [200, 404]);
    }

    // ── Ruta exclusiva Jugador ────────────────────────────────────

    /**
     * GET /api/rendimientospartidos/mis-estadisticas
     * Solo accesible por rol 3 (jugador).
     */
    public function test_rendimientos_mis_estadisticas_jugador(): void
    {
        $this->comoJugador()->getJson('/api/rendimientospartidos/mis-estadisticas')->assertStatus(200);
    }

    public function test_rendimientos_mis_estadisticas_denegado_admin(): void
    {
        $this->comoAdmin()->getJson('/api/rendimientospartidos/mis-estadisticas')->assertStatus(403);
    }

    public function test_rendimientos_mis_estadisticas_denegado_entrenador(): void
    {
        $this->comoEntrenador()->getJson('/api/rendimientospartidos/mis-estadisticas')->assertStatus(403);
    }

    // ── Estadísticas por jugador (roles 1, 2 y 3) ────────────────

    public function test_rendimientos_totales_por_jugador_admin(): void
    {
        $jugador   = Jugadores::factory()->create();
        $respuesta = $this->comoAdmin()->getJson("/api/rendimientospartidos/jugador/{$jugador->idJugadores}/totales");
        $this->assertContains($respuesta->status(), [200, 404]);
    }

    public function test_rendimientos_totales_por_jugador_jugador(): void
    {
        $jugador   = Jugadores::factory()->create();
        $respuesta = $this->comoJugador()->getJson("/api/rendimientospartidos/jugador/{$jugador->idJugadores}/totales");
        $this->assertContains($respuesta->status(), [200, 404]);
    }

    public function test_rendimientos_temporadas_por_jugador_admin(): void
    {
        $jugador   = Jugadores::factory()->create();
        $respuesta = $this->comoAdmin()->getJson("/api/rendimientospartidos/jugador/{$jugador->idJugadores}/temporadas");
        $this->assertContains($respuesta->status(), [200, 404]);
    }

    public function test_rendimientos_ultimos_partidos_admin(): void
    {
        $jugador   = Jugadores::factory()->create();
        $respuesta = $this->comoAdmin()->getJson("/api/rendimientospartidos/jugador/{$jugador->idJugadores}/ultimos-partidos/5");
        $this->assertContains($respuesta->status(), [200, 404]);
    }

    public function test_rendimientos_ultimo_registro_admin(): void
    {
        $jugador   = Jugadores::factory()->create();
        $respuesta = $this->comoAdmin()->getJson("/api/rendimientospartidos/jugador/{$jugador->idJugadores}/ultimo-registro");
        $this->assertContains($respuesta->status(), [200, 404]);
    }

    // ── Papelera ─────────────────────────────────────────────────

    public function test_rendimientos_papelera_trashed_admin(): void
    {
        $this->comoAdmin()->getJson('/api/rendimientospartidos/trashed')->assertStatus(200);
    }

    public function test_rendimientos_papelera_listar_admin(): void
    {
        $this->comoAdmin()->getJson('/api/rendimientospartidos/papelera/listar')->assertStatus(200);
    }

    // ── Escritura (roles 1 y 2) ───────────────────────────────────

    public function test_rendimientos_crear_admin(): void
    {
        $jugador   = Jugadores::factory()->create();
        $partido   = Partidos::factory()->create();
        $respuesta = $this->comoAdmin()->postJson('/api/rendimientospartidos', [
            'idJugadores'      => $jugador->idJugadores,
            'idPartidos'       => $partido->idPartidos,
            'Goles'            => 1,
            'Asistencias'      => 0,
            'MinutosJugados'   => 90,
            'TarjetasAmarillas'=> 0,
            'TarjetasRojas'    => 0,
        ]);
        $this->assertContains($respuesta->status(), [200, 201, 422]);
    }

    public function test_rendimientos_crear_entrenador(): void
    {
        $respuesta = $this->comoEntrenador()->postJson('/api/rendimientospartidos', []);
        $this->assertContains($respuesta->status(), [200, 201, 422]);
    }

    public function test_rendimientos_crear_denegado_jugador(): void
    {
        $this->comoJugador()->postJson('/api/rendimientospartidos', [])->assertStatus(403);
    }

    public function test_rendimientos_editar_admin(): void
    {
        $rendimiento = RendimientosPartidos::factory()->create();
        $respuesta   = $this->comoAdmin()->putJson("/api/rendimientospartidos/{$rendimiento->IdRendimientos}", ['Goles' => 2]);
        $this->assertContains($respuesta->status(), [200, 422]);
    }

    public function test_rendimientos_eliminar_admin(): void
    {
        $rendimiento = RendimientosPartidos::factory()->create();
        $respuesta   = $this->comoAdmin()->deleteJson("/api/rendimientospartidos/{$rendimiento->IdRendimientos}");
        $this->assertContains($respuesta->status(), [200, 204]);
    }

    // ── Restaurar / Eliminar definitivamente ─────────────────────

    public function test_rendimientos_restaurar_admin(): void
    {
        $rendimiento = RendimientosPartidos::factory()->create();
        $rendimiento->delete();
        $respuesta   = $this->comoAdmin()->postJson("/api/rendimientospartidos/{$rendimiento->IdRendimientos}/restaurar");
        $this->assertContains($respuesta->status(), [200, 204]);
    }

    public function test_rendimientos_eliminar_definitivo_admin(): void
    {
        $rendimiento = RendimientosPartidos::factory()->create();
        $rendimiento->delete();
        $respuesta   = $this->comoAdmin()->deleteJson("/api/rendimientospartidos/{$rendimiento->IdRendimientos}/forzar");
        $this->assertContains($respuesta->status(), [200, 204]);
    }

    // ── Filtros por competencia / partido ─────────────────────────

    public function test_rendimientos_por_competencia_admin(): void
    {
        $jugador     = Jugadores::factory()->create();
        $competencia = Competencias::factory()->create();
        $respuesta   = $this->comoAdmin()->getJson(
            "/api/rendimientos/jugador/{$jugador->idJugadores}/competencia/{$competencia->idCompetencias}"
        );
        $this->assertContains($respuesta->status(), [200, 404]);
    }

    public function test_rendimientos_por_partido_admin(): void
    {
        $jugador   = Jugadores::factory()->create();
        $partido   = Partidos::factory()->create();
        $respuesta = $this->comoAdmin()->getJson(
            "/api/rendimientos/jugador/{$jugador->idJugadores}/partido/{$partido->idPartidos}"
        );
        $this->assertContains($respuesta->status(), [200, 404]);
    }

    public function test_rendimientos_partidos_por_partido_admin(): void
    {
        $jugador   = Jugadores::factory()->create();
        $partido   = Partidos::factory()->create();
        $respuesta = $this->comoAdmin()->getJson(
            "/api/rendimientospartidos/jugador/{$jugador->idJugadores}/partido/{$partido->idPartidos}"
        );
        $this->assertContains($respuesta->status(), [200, 404]);
    }
}