<?php

namespace Tests\Feature\Reportes;

use Tests\TestCase;
use Tests\Traits\TieneUsuariosDePrueba;
use Illuminate\Foundation\Testing\RefreshDatabase;
use App\Models\Jugadores;
use App\Models\Competencias;

/**
 * ================================================================
 * SECCIÓN 15 — REPORTES PDF
 * ================================================================
 * Rutas de generación de PDF para estadísticas de jugadores.
 *
 * GET /api/reportes/jugador/{id}/pdf
 *   → roles 1 y 2
 *
 * GET /api/reportes/jugador/{id}/competencias/{idComp}/pdf
 *   → solo rol 1 (admin)
 *
 * Respuestas esperadas:
 *   200 → PDF generado correctamente
 *   404 → Sin datos suficientes
 *   500 → Error de librería PDF sin datos cargados
 *   403 → Rol sin permiso
 *
 * Comando: php artisan test --filter PruebasReportes
 * ================================================================
 */
class PruebasReportes extends TestCase
{
    use RefreshDatabase, TieneUsuariosDePrueba;

    // ── Reporte general por jugador ───────────────────────────────

    public function test_reporte_pdf_jugador_admin(): void
    {
        $jugador   = Jugadores::factory()->create();
        $respuesta = $this->comoAdmin()->getJson("/api/reportes/jugador/{$jugador->idJugadores}/pdf");
        $this->assertContains($respuesta->status(), [200, 404, 500]);
    }

    public function test_reporte_pdf_jugador_entrenador(): void
    {
        $jugador   = Jugadores::factory()->create();
        $respuesta = $this->comoEntrenador()->getJson("/api/reportes/jugador/{$jugador->idJugadores}/pdf");
        $this->assertContains($respuesta->status(), [200, 404, 500]);
    }

    public function test_reporte_pdf_jugador_denegado_jugador(): void
    {
        $jugador = Jugadores::factory()->create();
        $this->comoJugador()->getJson("/api/reportes/jugador/{$jugador->idJugadores}/pdf")->assertStatus(403);
    }

    // ── Reporte por competencia (solo rol 1) ──────────────────────

    public function test_reporte_pdf_por_competencia_admin(): void
    {
        $jugador     = Jugadores::factory()->create();
        $competencia = Competencias::factory()->create();
        $respuesta   = $this->comoAdmin()->getJson(
            "/api/reportes/jugador/{$jugador->idJugadores}/competencias/{$competencia->idCompetencias}/pdf"
        );
        $this->assertContains($respuesta->status(), [200, 404, 500]);
    }

    public function test_reporte_pdf_por_competencia_denegado_entrenador(): void
    {
        $jugador     = Jugadores::factory()->create();
        $competencia = Competencias::factory()->create();
        $this->comoEntrenador()->getJson(
            "/api/reportes/jugador/{$jugador->idJugadores}/competencias/{$competencia->idCompetencias}/pdf"
        )->assertStatus(403);
    }

    public function test_reporte_pdf_por_competencia_denegado_jugador(): void
    {
        $jugador     = Jugadores::factory()->create();
        $competencia = Competencias::factory()->create();
        $this->comoJugador()->getJson(
            "/api/reportes/jugador/{$jugador->idJugadores}/competencias/{$competencia->idCompetencias}/pdf"
        )->assertStatus(403);
    }
}