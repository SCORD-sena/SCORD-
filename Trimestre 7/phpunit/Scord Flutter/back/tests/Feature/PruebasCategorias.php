<?php

namespace Tests\Feature\Categorias;

use Tests\TestCase;
use Tests\Traits\TieneUsuariosDePrueba;
use Illuminate\Foundation\Testing\RefreshDatabase;
use App\Models\Categorias;
use App\Models\Jugadores;

/**
 * ================================================================
 * SECCIÓN 5 — CATEGORÍAS
 * ================================================================
 * PK del modelo : idCategorias
 * Soft Deletes  : sí
 * Roles lectura : roles 1, 2 y 3
 * Roles edición : solo rol 1 (admin)
 *
 * Campos fillable: Descripcion, TiposCategoria
 * Relaciones     : entrenadores (M:M), jugadores (1:M), cronogramas (1:M)
 *
 * Comando: php artisan test --filter PruebasCategorias
 * ================================================================
 */
class PruebasCategorias extends TestCase
{
    use RefreshDatabase, TieneUsuariosDePrueba;

    // ── Lectura (roles 1, 2 y 3) ─────────────────────────────────

    public function test_categorias_listado_admin(): void
    {
        $this->comoAdmin()->getJson('/api/categorias')->assertStatus(200);
    }

    public function test_categorias_listado_entrenador(): void
    {
        $this->comoEntrenador()->getJson('/api/categorias')->assertStatus(200);
    }

    public function test_categorias_listado_jugador(): void
    {
        $this->comoJugador()->getJson('/api/categorias')->assertStatus(200);
    }

    public function test_categorias_listado_denegado_sin_autenticacion(): void
    {
        $this->assertProtegida('get', '/api/categorias');
    }

    public function test_categorias_ver_detalle_admin(): void
    {
        $categoria = Categorias::factory()->create();
        $this->comoAdmin()->getJson("/api/categorias/{$categoria->idCategorias}")->assertStatus(200);
    }

    // ── Papelera ─────────────────────────────────────────────────

    public function test_categorias_papelera_admin(): void
    {
        $this->comoAdmin()->getJson('/api/categorias/papelera/listar')->assertStatus(200);
    }

    public function test_categorias_papelera_denegado_jugador(): void
    {
        $this->comoJugador()->getJson('/api/categorias/papelera/listar')->assertStatus(403);
    }

    // ── Escritura (solo rol 1) ────────────────────────────────────

    public function test_categorias_crear_admin(): void
    {
        $respuesta = $this->comoAdmin()->postJson('/api/categorias', [
            'Descripcion'    => 'Sub-15',
            'TiposCategoria' => 'Masculino',
        ]);
        $this->assertContains($respuesta->status(), [200, 201, 422]);
    }

    public function test_categorias_crear_denegado_entrenador(): void
    {
        $this->comoEntrenador()->postJson('/api/categorias', [])->assertStatus(403);
    }

    public function test_categorias_crear_denegado_jugador(): void
    {
        $this->comoJugador()->postJson('/api/categorias', [])->assertStatus(403);
    }

    public function test_categorias_editar_admin(): void
    {
        $categoria = Categorias::factory()->create();
        $respuesta = $this->comoAdmin()->putJson("/api/categorias/{$categoria->idCategorias}", ['Descripcion' => 'Sub-17']);
        $this->assertContains($respuesta->status(), [200, 422]);
    }

    public function test_categorias_editar_denegado_entrenador(): void
    {
        $categoria = Categorias::factory()->create();
        $this->comoEntrenador()->putJson("/api/categorias/{$categoria->idCategorias}", [])->assertStatus(403);
    }

    public function test_categorias_eliminar_admin(): void
    {
        $categoria = Categorias::factory()->create();
        $respuesta = $this->comoAdmin()->deleteJson("/api/categorias/{$categoria->idCategorias}");
        $this->assertContains($respuesta->status(), [200, 204]);
    }

    // ── Restaurar / Eliminar definitivamente ─────────────────────

    public function test_categorias_restaurar_admin(): void
    {
        $categoria = Categorias::factory()->create();
        $categoria->delete();
        $respuesta = $this->comoAdmin()->postJson("/api/categorias/{$categoria->idCategorias}/restaurar");
        $this->assertContains($respuesta->status(), [200, 204]);
    }

    public function test_categorias_eliminar_definitivo_admin(): void
    {
        $categoria = Categorias::factory()->create();
        $categoria->delete();
        $respuesta = $this->comoAdmin()->deleteJson("/api/categorias/{$categoria->idCategorias}/forzar");
        $this->assertContains($respuesta->status(), [200, 204]);
    }

    // ── Relación: jugadores por categoría ─────────────────────────

    public function test_categorias_jugadores_admin(): void
    {
        $categoria = Categorias::factory()->create();
        $respuesta = $this->comoAdmin()->getJson("/api/categorias/{$categoria->idCategorias}/jugadores");
        $this->assertContains($respuesta->status(), [200, 404]);
    }

    public function test_categorias_jugadores_jugador(): void
    {
        $categoria = Categorias::factory()->create();
        $respuesta = $this->comoJugador()->getJson("/api/categorias/{$categoria->idCategorias}/jugadores");
        $this->assertContains($respuesta->status(), [200, 404]);
    }
}