<?php

namespace Tests\Feature\Jugadores;

use Tests\TestCase;
use Tests\Traits\TieneUsuariosDePrueba;
use Illuminate\Foundation\Testing\RefreshDatabase;
use App\Models\Jugadores;
use App\Models\Personas;
use App\Models\Categorias;

/**
 * ================================================================
 * SECCIÓN 7 — JUGADORES
 * ================================================================
 * PK del modelo : idJugadores
 * Soft Deletes  : sí
 * Roles lectura : roles 1, 2 y 3
 * Roles edición : store/update roles 1 y 2; delete solo rol 1
 *
 * Campos fillable: Dorsal, Posicion, Upz, Estatura, NomTutor1,
 *                  NomTutor2, ApeTutor1, ApeTutor2, TelefonoTutor,
 *                  idPersonas, idCategorias, fechaIngresoClub,
 *                  fechaVencimientoMensualidad
 * Relaciones     : persona (BelongsTo), categoria (BelongsTo),
 *                  rendimientosPartidos (HasMany)
 *
 * Ruta especial  : GET /api/jugadores/misDatos → solo rol 3
 * Ruta especial  : POST /api/jugadores/{id}/registrar-pago → solo rol 1
 *
 * Comando: php artisan test --filter PruebasJugadores
 * ================================================================
 */
class PruebasJugadores extends TestCase
{
    use RefreshDatabase, TieneUsuariosDePrueba;

    // ── Lectura (roles 1, 2 y 3) ─────────────────────────────────

    public function test_jugadores_listado_admin(): void
    {
        $this->comoAdmin()->getJson('/api/jugadores')->assertStatus(200);
    }

    public function test_jugadores_listado_entrenador(): void
    {
        $this->comoEntrenador()->getJson('/api/jugadores')->assertStatus(200);
    }

    public function test_jugadores_listado_jugador(): void
    {
        $this->comoJugador()->getJson('/api/jugadores')->assertStatus(200);
    }

    public function test_jugadores_listado_denegado_sin_autenticacion(): void
    {
        $this->assertProtegida('get', '/api/jugadores');
    }

    public function test_jugadores_ver_detalle_admin(): void
    {
        $jugador = Jugadores::factory()->create();
        $this->comoAdmin()->getJson("/api/jugadores/{$jugador->idJugadores}")->assertStatus(200);
    }

    // ── Ruta exclusiva Jugador ────────────────────────────────────

    /**
     * GET /api/jugadores/misDatos
     * Solo accesible por rol 3 (jugador).
     */
    public function test_jugadores_mis_datos_jugador(): void
    {
        $this->comoJugador()->getJson('/api/jugadores/misDatos')->assertStatus(200);
    }

    public function test_jugadores_mis_datos_denegado_admin(): void
    {
        $this->comoAdmin()->getJson('/api/jugadores/misDatos')->assertStatus(403);
    }

    public function test_jugadores_mis_datos_denegado_entrenador(): void
    {
        $this->comoEntrenador()->getJson('/api/jugadores/misDatos')->assertStatus(403);
    }

    // ── Papelera (roles 1 y 2) ────────────────────────────────────

    public function test_jugadores_papelera_admin(): void
    {
        $this->comoAdmin()->getJson('/api/jugadores/trashed')->assertStatus(200);
    }

    public function test_jugadores_papelera_entrenador(): void
    {
        $this->comoEntrenador()->getJson('/api/jugadores/trashed')->assertStatus(200);
    }

    public function test_jugadores_papelera_denegado_jugador(): void
    {
        $this->comoJugador()->getJson('/api/jugadores/trashed')->assertStatus(403);
    }

    // ── Escritura (roles 1 y 2) ───────────────────────────────────

    public function test_jugadores_crear_admin(): void
    {
        $persona   = Personas::factory()->create(['idRoles' => 3]);
        $categoria = Categorias::factory()->create();
        $respuesta = $this->comoAdmin()->postJson('/api/jugadores', [
            'idPersonas'   => $persona->idPersonas,
            'idCategorias' => $categoria->idCategorias,
            'Dorsal'       => 10,
            'Posicion'     => 'Delantero',
        ]);
        $this->assertContains($respuesta->status(), [200, 201, 422]);
    }

    public function test_jugadores_crear_entrenador(): void
    {
        $respuesta = $this->comoEntrenador()->postJson('/api/jugadores', []);
        $this->assertContains($respuesta->status(), [200, 201, 422]);
    }

    public function test_jugadores_crear_denegado_jugador(): void
    {
        $this->comoJugador()->postJson('/api/jugadores', [])->assertStatus(403);
    }

    public function test_jugadores_editar_admin(): void
    {
        $jugador   = Jugadores::factory()->create();
        $respuesta = $this->comoAdmin()->putJson("/api/jugadores/{$jugador->idJugadores}", ['Dorsal' => 99]);
        $this->assertContains($respuesta->status(), [200, 422]);
    }

    public function test_jugadores_editar_denegado_jugador(): void
    {
        $jugador = Jugadores::factory()->create();
        $this->comoJugador()->putJson("/api/jugadores/{$jugador->idJugadores}", [])->assertStatus(403);
    }

    public function test_jugadores_eliminar_admin(): void
    {
        $jugador   = Jugadores::factory()->create();
        $respuesta = $this->comoAdmin()->deleteJson("/api/jugadores/{$jugador->idJugadores}");
        $this->assertContains($respuesta->status(), [200, 204]);
    }

    // ── Registro de pago (solo rol 1) ─────────────────────────────

    public function test_jugadores_registrar_pago_admin(): void
    {
        $jugador   = Jugadores::factory()->create();
        $respuesta = $this->comoAdmin()->postJson("/api/jugadores/{$jugador->idJugadores}/registrar-pago", []);
        $this->assertContains($respuesta->status(), [200, 422]);
    }

    public function test_jugadores_registrar_pago_denegado_entrenador(): void
    {
        $jugador = Jugadores::factory()->create();
        $this->comoEntrenador()->postJson("/api/jugadores/{$jugador->idJugadores}/registrar-pago", [])->assertStatus(403);
    }

    public function test_jugadores_registrar_pago_denegado_jugador(): void
    {
        $jugador = Jugadores::factory()->create();
        $this->comoJugador()->postJson("/api/jugadores/{$jugador->idJugadores}/registrar-pago", [])->assertStatus(403);
    }

    // ── Restaurar / Eliminar definitivamente ─────────────────────

    public function test_jugadores_restaurar_admin(): void
    {
        $jugador   = Jugadores::factory()->create();
        $jugador->delete();
        $respuesta = $this->comoAdmin()->postJson("/api/jugadores/{$jugador->idJugadores}/restore");
        $this->assertContains($respuesta->status(), [200, 204]);
    }

    public function test_jugadores_eliminar_definitivo_solo_admin(): void
    {
        $jugador   = Jugadores::factory()->create();
        $jugador->delete();
        $respuesta = $this->comoAdmin()->deleteJson("/api/jugadores/{$jugador->idJugadores}/force");
        $this->assertContains($respuesta->status(), [200, 204]);
    }

    public function test_jugadores_eliminar_definitivo_denegado_entrenador(): void
    {
        $jugador = Jugadores::factory()->create();
        $jugador->delete();
        $this->comoEntrenador()->deleteJson("/api/jugadores/{$jugador->idJugadores}/force")->assertStatus(403);
    }
}