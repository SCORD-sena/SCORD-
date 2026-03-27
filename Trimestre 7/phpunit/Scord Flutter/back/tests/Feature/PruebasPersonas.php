<?php

namespace Tests\Feature\Personas;

use Tests\TestCase;
use Tests\Traits\TieneUsuariosDePrueba;
use Illuminate\Foundation\Testing\RefreshDatabase;
use App\Models\Personas;

/**
 * ================================================================
 * SECCIÓN 2 — PERSONAS
 * ================================================================
 * PK del modelo : idPersonas
 * Soft Deletes  : sí
 * Roles lectura : solo rol 1 (admin)
 * Roles edición : roles 1 y 2 en update; solo 1 en store/delete
 *
 * Comando: php artisan test --filter PruebasPersonas
 * ================================================================
 */
class PruebasPersonas extends TestCase
{
    use RefreshDatabase, TieneUsuariosDePrueba;

    // ── Lectura ──────────────────────────────────────────────────

    public function test_personas_listado_admin(): void
    {
        $this->comoAdmin()->getJson('/api/personas')->assertStatus(200);
    }

    public function test_personas_listado_denegado_entrenador(): void
    {
        $this->comoEntrenador()->getJson('/api/personas')->assertStatus(403);
    }

    public function test_personas_listado_denegado_jugador(): void
    {
        $this->comoJugador()->getJson('/api/personas')->assertStatus(403);
    }

    public function test_personas_listado_denegado_sin_autenticacion(): void
    {
        $this->assertProtegida('get', '/api/personas');
    }

    public function test_personas_ver_detalle_admin(): void
    {
        $persona = Personas::factory()->create();
        $this->comoAdmin()->getJson("/api/personas/{$persona->idPersonas}")->assertStatus(200);
    }

    // ── Papelera ─────────────────────────────────────────────────

    public function test_personas_papelera_admin(): void
    {
        $this->comoAdmin()->getJson('/api/personas/trashed')->assertStatus(200);
    }

    public function test_personas_papelera_denegado_entrenador(): void
    {
        $this->comoEntrenador()->getJson('/api/personas/trashed')->assertStatus(403);
    }

    // ── Escritura ────────────────────────────────────────────────

    public function test_personas_crear_admin(): void
    {
        $respuesta = $this->comoAdmin()->postJson('/api/personas', [
            'Nombre1'             => 'Juan',
            'Nombre2'             => 'Carlos',
            'Apellido1'           => 'Pérez',
            'Apellido2'           => 'Gómez',
            'NumeroDeDocumento'   => '123456789',
            'FechaDeNacimiento'   => '2000-01-01',
            'Genero'              => 'M',
            'Telefono'            => '3001234567',
            'correo'              => 'juan@test.com',
            'contrasena'          => 'Password123!',
            'idTiposDeDocumentos' => 1,
            'idRoles'             => 3,
        ]);
        $this->assertContains($respuesta->status(), [200, 201, 422]);
    }

    public function test_personas_crear_denegado_entrenador(): void
    {
        $this->comoEntrenador()->postJson('/api/personas', [])->assertStatus(403);
    }

    /**
     * PUT /api/personas/{id}
     * El middleware permite roles 1 y 2 en este endpoint.
     */
    public function test_personas_editar_admin(): void
    {
        $persona  = Personas::factory()->create();
        $respuesta = $this->comoAdmin()->putJson("/api/personas/{$persona->idPersonas}", ['Nombre1' => 'Editado']);
        $this->assertContains($respuesta->status(), [200, 422]);
    }

    public function test_personas_editar_entrenador(): void
    {
        $persona  = Personas::factory()->create();
        $respuesta = $this->comoEntrenador()->putJson("/api/personas/{$persona->idPersonas}", ['Nombre1' => 'Editado']);
        $this->assertContains($respuesta->status(), [200, 422]);
    }

    public function test_personas_editar_denegado_jugador(): void
    {
        $persona = Personas::factory()->create();
        $this->comoJugador()->putJson("/api/personas/{$persona->idPersonas}", [])->assertStatus(403);
    }

    public function test_personas_eliminar_admin(): void
    {
        $persona  = Personas::factory()->create();
        $respuesta = $this->comoAdmin()->deleteJson("/api/personas/{$persona->idPersonas}");
        $this->assertContains($respuesta->status(), [200, 204]);
    }

    public function test_personas_eliminar_denegado_entrenador(): void
    {
        $persona = Personas::factory()->create();
        $this->comoEntrenador()->deleteJson("/api/personas/{$persona->idPersonas}")->assertStatus(403);
    }

    // ── Restaurar / Eliminar definitivamente ─────────────────────

    public function test_personas_restaurar_admin(): void
    {
        $persona = Personas::factory()->create();
        $persona->delete();
        $respuesta = $this->comoAdmin()->postJson("/api/personas/{$persona->idPersonas}/restore");
        $this->assertContains($respuesta->status(), [200, 204]);
    }

    public function test_personas_eliminar_definitivo_admin(): void
    {
        $persona = Personas::factory()->create();
        $persona->delete();
        $respuesta = $this->comoAdmin()->deleteJson("/api/personas/{$persona->idPersonas}/force");
        $this->assertContains($respuesta->status(), [200, 204]);
    }

    public function test_personas_eliminar_definitivo_denegado_entrenador(): void
    {
        $persona = Personas::factory()->create();
        $persona->delete();
        $this->comoEntrenador()->deleteJson("/api/personas/{$persona->idPersonas}/force")->assertStatus(403);
    }
}