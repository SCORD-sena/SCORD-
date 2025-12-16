<?php

namespace App\Http\Middleware;

use Closure;
use Tymon\JWTAuth\Facades\JWTAuth;

use Tymon\JWTAuth\Exceptions\JWTException;

class Roles
{
    public function handle($request, Closure $next, ...$roles)
    {
        try {
            // Autenticar usuario desde el token
            $Personas = JWTAuth::parseToken()->authenticate();

            if (!$Personas) {
                return response()->json(['error' => 'Usuario no encontrado'], 404);
            }

            // Verificar si el usuario tiene alguno de los roles permitidos
            if (!in_array($Personas->idRoles, $roles)) {
                return response()->json(['error' => 'No tienes permisos para acceder a esta ruta'], 403);
            }

        } catch (JWTException $e) {
            return response()->json(['error' => 'Token inválido o ausente'], 401);
        }

        return $next($request);
    }
}
