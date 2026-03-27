<?php

namespace Tests\Feature\Resultados;

use Tests\TestCase;
use Tests\Traits\TieneUsuariosDePrueba;
use Illuminate\Foundation\Testing\RefreshDatabase;
use App\Models\Resultados;
use App\Models\Partidos;

/**
 * ================================================================
 * SECCIÓN 13 — RESULTADOS
 * ================================================================
 * PK del modelo : idResultados
 * Soft Deletes  : sí
 * Roles lectura : roles 1, 2 y 3
 * Roles edición : store/update roles 1 y 2; delete solo rol 1
 *
 * Campos fillable: idResultados, Marcador, PuntosObtenidos,
 *                  Observacion, idPartidos
 * Relaciones     : Partido (BelongsTo)
 *
 * Comando: php artisan test --filter PruebasResultados
 * ================================================================
 */
class PruebasResultados extends TestCase
{
    use RefreshDatabase, TieneUsuariosDePrueba;

    // ── Lectura (roles 1, 2 y 3) ─────────────────────────────────

    public function test_resultados_listado_admin(): void
    {
        $this->comoAdmin()->getJson('/api/resultados')->assertStatus(200);
    }

    public function test_resultados_listado_entrenador(): void
    {
        $this->comoEntrenador()->getJson('/api/resultados')->assertStatus(200);
    }

    public function test_resultados_listado_jugador(): void
    {
        $this->comoJugador()->getJson('/api/resultados')->assertStatus(200);
    }

    public function test_resultados_ver_detalle_admin(): void
    {
        $resultado = Resultados::factory()->create();
        $this->comoAdmin()->getJson("/api/resultados/{$resultado->idResultados}")->assertStatus(200);
    }

    // ── Papelera ─────────────────────────────────────────────────

    public function test_resultados_papelera_admin(): void
    {
        $this->comoAdmin()->getJson('/api/resultados/papelera/listar')->assertStatus(200);
    }

    public function test_resultados_papelera_denegado_jugador(): void
    {
        $this->comoJugador()->getJson('/api/resultados/papelera/listar')->assertStatus(403);
    }

    // ── Escritura (roles 1 y 2) ───────────────────────────────────

    public function test_resultados_crear_admin(): void
    {
        $partido   = Partidos::factory()->create();
        $respuesta = $this->comoAdmin()->postJson('/api/resultados', [
            'idPartidos'      => $partido->idPartidos,
            'Marcador'        => '2-1',
            'PuntosObtenidos' => 3,
            'Observacion'     => 'Victoria en tiempo reglamentario',
        ]);
        $this->assertContains($respuesta->status(), [200, 201, 422]);
    }

    public function test_resultados_crear_entrenador(): void
    {
        $respuesta = $this->comoEntrenador()->postJson('/api/resultados', []);
        $this->assertContains($respuesta->status(), [200, 201, 422]);
    }

    public function test_resultados_crear_denegado_jugador(): void
    {
        $this->comoJugador()->postJson('/api/resultados', [])->assertStatus(403);
    }

    public function test_resultados_editar_admin(): void
    {
        $resultado = Resultados::factory()->create();
        $respuesta = $this->comoAdmin()->putJson("/api/resultados/{$resultado->idResultados}", ['Marcador' => '3-0']);
        $this->assertContains($respuesta->status(), [200, 422]);
    }

    public function test_resultados_eliminar_admin(): void
    {
        $resultado = Resultados::factory()->create();
        $respuesta = $this->comoAdmin()->deleteJson("/api/resultados/{$resultado->idResultados}");
        $this->assertContains($respuesta->status(), [200, 204]);
    }

    // ── Restaurar / Eliminar definitivamente ─────────────────────

    public function test_resultados_restaurar_admin(): void
    {
        $resultado = Resultados::factory()->create();
        $resultado->delete();
        $respuesta = $this->comoAdmin()->postJson("/api/resultados/{$resultado->idResultados}/restaurar");
        $this->assertContains($respuesta->status(), [200, 204]);
    }

    public function test_resultados_eliminar_definitivo_admin(): void
    {
        $resultado = Resultados::factory()->create();
        $resultado->delete();
        $respuesta = $this->comoAdmin()->deleteJson("/api/resultados/{$resultado->idResultados}/forzar");
        $this->assertContains($respuesta->status(), [200, 204]);
    }
}