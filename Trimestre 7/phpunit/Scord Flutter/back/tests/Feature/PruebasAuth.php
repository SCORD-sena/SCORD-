<?php

namespace Tests\Feature\Auth;

use Tests\TestCase;
use Tests\Traits\TieneUsuariosDePrueba;
use Illuminate\Foundation\Testing\RefreshDatabase;
use App\Models\Personas;

/**
 * ================================================================
 * SECCIÓN 1 — AUTENTICACIÓN
 * ================================================================
 * Pruebas de registro, inicio de sesión, cierre de sesión y
 * consulta del usuario autenticado.
 *
 * Comando: php artisan test --filter PruebasAuth
 * ================================================================
 */
class PruebasAuth extends TestCase
{
    use RefreshDatabase, TieneUsuariosDePrueba;

    /**
     * POST /api/register
     * Ruta pública. Retorna 422 si faltan campos requeridos.
     */
    public function test_registro_con_datos_incompletos_retorna_422(): void
    {
        $respuesta = $this->postJson('/api/register', []);
        $respuesta->assertStatus(422);
    }

    /**
     * POST /api/register
     * Registro exitoso con todos los campos requeridos.
     * ⚠️  Completa los campos según tu AuthController@register
     */
    public function test_registro_exitoso_retorna_201(): void
    {
        $respuesta = $this->postJson('/api/register', [
            'correo'              => 'nuevo_usuario@test.com',
            'contrasena'          => 'Password123!',
            'NumeroDeDocumento'   => '999888777',
            'Nombre1'             => 'Juan',
            'Apellido1'           => 'Pérez',
            'FechaDeNacimiento'   => '2000-01-01',
            'Genero'              => 'M',
            'idTiposDeDocumentos' => 1,
            'idRoles'             => 3,
            // ⚠️  Agrega los campos adicionales que requiera tu registro
        ]);
        $this->assertContains($respuesta->status(), [200, 201]);
    }

    /**
     * POST /api/login
     * Credenciales incorrectas deben retornar 401 o 422.
     */
    public function test_login_con_credenciales_invalidas_retorna_401(): void
    {
        $respuesta = $this->postJson('/api/login', [
            'correo'     => 'noexiste@test.com',
            'contrasena' => 'contrasena_incorrecta',
        ]);
        $this->assertContains($respuesta->status(), [401, 422]);
    }

    /**
     * POST /api/login
     * Login exitoso retorna 200 con token.
     */
    public function test_login_exitoso_retorna_token(): void
    {
        Personas::factory()->create([
            'correo'     => 'login_prueba@test.com',
            'contrasena' => bcrypt('Password123!'),
            'idRoles'    => 1,
        ]);

        $respuesta = $this->postJson('/api/login', [
            'correo'     => 'login_prueba@test.com',
            'contrasena' => 'Password123!',
        ]);

        $this->assertContains($respuesta->status(), [200, 201]);
        // Si tu login retorna un token JWT puedes descomentar:
        // $respuesta->assertJsonStructure(['token']);
    }

    /** POST /api/logout — Usuario autenticado puede cerrar sesión */
    public function test_logout_usuario_autenticado(): void
    {
        $this->comoAdmin()->postJson('/api/logout')->assertStatus(200);
    }

    /** GET /api/me — Retorna datos del usuario autenticado */
    public function test_me_retorna_datos_del_usuario_autenticado(): void
    {
        $this->comoAdmin()->getJson('/api/me')->assertStatus(200);
    }

    /** GET /api/me — Sin autenticación debe devolver 401/403 */
    public function test_me_denegado_sin_autenticacion(): void
    {
        $this->assertProtegida('get', '/api/me');
    }
}