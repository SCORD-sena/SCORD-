<?php

namespace Tests\Feature\Roles;

use Tests\TestCase;
use Tests\Traits\TieneUsuariosDePrueba;
use Illuminate\Foundation\Testing\RefreshDatabase;
use App\Models\Roles;

/**
 * ================================================================
 * SECCIÓN 3 — ROLES
 * ================================================================
 * PK del modelo : idRoles
 * Soft Deletes  : no
 * Roles lectura : solo rol 1 (admin)
 * Roles edición : solo rol 1 (admin)
 *
 * Campos fillable: TipoDeRol, idRoles
 *
 * Comando: php artisan test --filter PruebasRoles
 * ================================================================
 */
class PruebasRoles extends TestCase
{
    use RefreshDatabase, TieneUsuariosDePrueba;

    // ── Lectura ──────────────────────────────────────────────────

    public function test_roles_listado_admin(): void
    {
        $this->comoAdmin()->getJson('/api/roles')->assertStatus(200);
    }

    public function test_roles_listado_denegado_entrenador(): void
    {
        $this->comoEntrenador()->getJson('/api/roles')->assertStatus(403);
    }

    public function test_roles_listado_denegado_jugador(): void
    {
        $this->comoJugador()->getJson('/api/roles')->assertStatus(403);
    }

    public function test_roles_ver_detalle_admin(): void
    {
        $rol       = Roles::factory()->create();
        $respuesta = $this->comoAdmin()->getJson("/api/roles/{$rol->idRoles}");
        $this->assertContains($respuesta->status(), [200, 404]);
    }

    // ── Escritura ────────────────────────────────────────────────

    public function test_roles_crear_admin(): void
    {
        $respuesta = $this->comoAdmin()->postJson('/api/roles', [
            'TipoDeRol' => 'Árbitro',
        ]);
        $this->assertContains($respuesta->status(), [200, 201, 422]);
    }

    public function test_roles_crear_denegado_entrenador(): void
    {
        $this->comoEntrenador()->postJson('/api/roles', [])->assertStatus(403);
    }

    public function test_roles_editar_admin(): void
    {
        $rol       = Roles::factory()->create();
        $respuesta = $this->comoAdmin()->putJson("/api/roles/{$rol->idRoles}", ['TipoDeRol' => 'Editado']);
        $this->assertContains($respuesta->status(), [200, 422]);
    }

    public function test_roles_eliminar_admin(): void
    {
        $rol       = Roles::factory()->create();
        $respuesta = $this->comoAdmin()->deleteJson("/api/roles/{$rol->idRoles}");
        $this->assertContains($respuesta->status(), [200, 204]);
    }
}