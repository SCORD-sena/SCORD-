<?php

namespace Tests\Feature\Cronogramas;

use Tests\TestCase;
use Tests\Traits\TieneUsuariosDePrueba;
use Illuminate\Foundation\Testing\RefreshDatabase;
use App\Models\cronogramas;
use App\Models\Competencias;
use App\Models\Categorias;

/**
 * ================================================================
 * SECCIÓN 10 — CRONOGRAMAS
 * ================================================================
 * PK del modelo : idCronogramas
 * Soft Deletes  : sí
 * Roles lectura : roles 1, 2 y 3
 * Roles edición : store/update roles 1 y 2; delete solo rol 1
 *
 * Campos fillable: FechaDeEventos, Hora, TipoDeEventos, CanchaPartido,
 *                  Ubicacion, SedeEntrenamiento, Descripcion,
 *                  idCategorias, idCompetencias
 * Relaciones     : partidos (HasMany), categoria (BelongsTo),
 *                  competencia (BelongsTo)
 *
 * Ruta especial  : GET /api/cronogramas/competencia/{id}/categoria/{id}
 *
 * Comando: php artisan test --filter PruebasCronogramas
 * ================================================================
 */
class PruebasCronogramas extends TestCase
{
    use RefreshDatabase, TieneUsuariosDePrueba;

    // ── Lectura (roles 1, 2 y 3) ─────────────────────────────────

    public function test_cronogramas_listado_admin(): void
    {
        $this->comoAdmin()->getJson('/api/cronogramas')->assertStatus(200);
    }

    public function test_cronogramas_listado_entrenador(): void
    {
        $this->comoEntrenador()->getJson('/api/cronogramas')->assertStatus(200);
    }

    public function test_cronogramas_listado_jugador(): void
    {
        $this->comoJugador()->getJson('/api/cronogramas')->assertStatus(200);
    }

    public function test_cronogramas_ver_detalle_admin(): void
    {
        $cronograma = cronogramas::factory()->create();
        $this->comoAdmin()->getJson("/api/cronogramas/{$cronograma->idCronogramas}")->assertStatus(200);
    }

    // ── Papelera ─────────────────────────────────────────────────

    public function test_cronogramas_papelera_admin(): void
    {
        $this->comoAdmin()->getJson('/api/cronogramas/papelera/listar')->assertStatus(200);
    }

    public function test_cronogramas_papelera_denegado_jugador(): void
    {
        $this->comoJugador()->getJson('/api/cronogramas/papelera/listar')->assertStatus(403);
    }

    // ── Escritura (roles 1 y 2) ───────────────────────────────────

    public function test_cronogramas_crear_admin(): void
    {
        $competencia = Competencias::factory()->create();
        $categoria   = Categorias::factory()->create();
        $respuesta   = $this->comoAdmin()->postJson('/api/cronogramas', [
            'idCompetencias' => $competencia->idCompetencias,
            'idCategorias'   => $categoria->idCategorias,
            'FechaDeEventos' => '2025-06-15',
            'Hora'           => '10:00',
            'TipoDeEventos'  => 'Partido',
        ]);
        $this->assertContains($respuesta->status(), [200, 201, 422]);
    }

    public function test_cronogramas_crear_entrenador(): void
    {
        $respuesta = $this->comoEntrenador()->postJson('/api/cronogramas', []);
        $this->assertContains($respuesta->status(), [200, 201, 422]);
    }

    public function test_cronogramas_crear_denegado_jugador(): void
    {
        $this->comoJugador()->postJson('/api/cronogramas', [])->assertStatus(403);
    }

    public function test_cronogramas_editar_admin(): void
    {
        $cronograma = cronogramas::factory()->create();
        $respuesta  = $this->comoAdmin()->putJson("/api/cronogramas/{$cronograma->idCronogramas}", ['Descripcion' => 'Actualizado']);
        $this->assertContains($respuesta->status(), [200, 422]);
    }

    public function test_cronogramas_eliminar_admin(): void
    {
        $cronograma = cronogramas::factory()->create();
        $respuesta  = $this->comoAdmin()->deleteJson("/api/cronogramas/{$cronograma->idCronogramas}");
        $this->assertContains($respuesta->status(), [200, 204]);
    }

    // ── Restaurar / Eliminar definitivamente ─────────────────────

    public function test_cronogramas_restaurar_admin(): void
    {
        $cronograma = cronogramas::factory()->create();
        $cronograma->delete();
        $respuesta  = $this->comoAdmin()->postJson("/api/cronogramas/{$cronograma->idCronogramas}/restaurar");
        $this->assertContains($respuesta->status(), [200, 204]);
    }

    public function test_cronogramas_eliminar_definitivo_admin(): void
    {
        $cronograma = cronogramas::factory()->create();
        $cronograma->delete();
        $respuesta  = $this->comoAdmin()->deleteJson("/api/cronogramas/{$cronograma->idCronogramas}/forzar");
        $this->assertContains($respuesta->status(), [200, 204]);
    }

    // ── Relación: cronogramas por competencia y categoría ─────────

    public function test_cronogramas_por_competencia_y_categoria_admin(): void
    {
        $competencia = Competencias::factory()->create();
        $categoria   = Categorias::factory()->create();
        $respuesta   = $this->comoAdmin()->getJson(
            "/api/cronogramas/competencia/{$competencia->idCompetencias}/categoria/{$categoria->idCategorias}"
        );
        $this->assertContains($respuesta->status(), [200, 404]);
    }
}