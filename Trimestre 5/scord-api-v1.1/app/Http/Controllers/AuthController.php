<?php

namespace App\Http\Controllers;

use App\Models\Personas;  // Asegúrate de importar el modelo Persona
use Illuminate\Support\Facades\Hash;
use Illuminate\Http\Request;
use Tymon\JWTAuth\Facades\JWTAuth;
use Tymon\JWTAuth\Exceptions\JWTException;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        // Recolectar las credenciales del request
        $credentials = [
            'correo' => $request->correo,
            'contraseña' => $request->contraseña,
        ];

        // Verifica que el correo exista y que la contraseña sea válida
        $persona = Personas::where('correo', $request->correo)->first();

        // Verifica si el usuario existe y si la contraseña es correcta
        if (!$persona || !Hash::check($request->contraseña, $persona->contraseña)) {
            return response()->json(['error' => 'Credenciales inválidas'], 401);
        }

        try {
            // Intentar generar el token JWT
            $token = JWTAuth::fromUser($persona);
        } catch (JWTException $e) {
            return response()->json(['error' => 'No se pudo crear el token'], 500);
        }

        // Responder con el token JWT y la información del usuario
        return response()->json([
            'access_token' => $token,
            'token_type' => 'bearer',
            'expires_in' => JWTAuth::factory()->getTTL() * 60,
            'usuario' => $persona->load('rol'), // Aquí cargamos la relación con el rol
        ]);
    }

    public function me()
    {
        // Devuelve los datos del usuario autenticado, incluyendo su rol
        return response()->json(auth()->user()->load('rol'));
    }

    public function logout()
    {
        try {
            // Cerrar sesión y eliminar el token
            auth()->logout();
            return response()->json(['message' => 'Sesión cerrada correctamente']);
        } catch (JWTException $e) {
            return response()->json(['error' => 'No se pudo cerrar sesión'], 500);
        }
    }
}
