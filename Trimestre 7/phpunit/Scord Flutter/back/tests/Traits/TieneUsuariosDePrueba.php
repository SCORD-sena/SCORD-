<?php

namespace Tests\Traits;

use App\Models\Personas;

/**
 * Trait reutilizable con setUp y helpers de autenticación.
 * Úsalo en cada TestCase con: use RefreshDatabase, TieneUsuariosDePrueba;
 *
 * ROLES:
 *   1 → Administrador  → acceso total
 *   2 → Entrenador     → lectura + operaciones propias
 *   3 → Jugador        → lectura limitada + datos propios
 */
trait TieneUsuariosDePrueba
{
    protected Personas $admin;       // Rol 1 — acceso total
    protected Personas $entrenador;  // Rol 2 — acceso limitado
    protected Personas $jugador;     // Rol 3 — lectura propia

    protected function setUp(): void
    {
        parent::setUp();

        $this->admin      = Personas::factory()->create(['idRoles' => 1]);
        $this->entrenador = Personas::factory()->create(['idRoles' => 2]);
        $this->jugador    = Personas::factory()->create(['idRoles' => 3]);
    }

    // ── Atajos para actingAs ─────────────────────────────────────

    /** Autentica como Administrador (rol 1) */
    protected function comoAdmin(): static
    {
        return $this->actingAs($this->admin);
    }

    /** Autentica como Entrenador (rol 2) */
    protected function comoEntrenador(): static
    {
        return $this->actingAs($this->entrenador);
    }

    /** Autentica como Jugador (rol 3) */
    protected function comoJugador(): static
    {
        return $this->actingAs($this->jugador);
    }

    // ── Aserciones reutilizables ─────────────────────────────────

    /**
     * Verifica que una ruta devuelve 401 o 403 sin autenticación.
     * Uso: $this->assertProtegida('get', '/api/personas');
     */
    protected function assertProtegida(string $metodo, string $uri): void
    {
        $respuesta = $this->{$metodo . 'Json'}($uri);
        $this->assertContains(
            $respuesta->status(),
            [401, 403],
            "La ruta [{$metodo}] {$uri} debería estar protegida pero devolvió {$respuesta->status()}"
        );
    }

    /**
     * Verifica que una ruta permite lectura (200) para un actor dado.
     */
    protected function assertPuedeLeer($actor, string $uri): void
    {
        $actor->getJson($uri)->assertStatus(200);
    }

    /**
     * Verifica que una ruta devuelve 403 para un actor dado.
     */
    protected function assertDenegadoPara($actor, string $uri, string $metodo = 'get'): void
    {
        $actor->{$metodo . 'Json'}($uri)->assertStatus(403);
    }
}