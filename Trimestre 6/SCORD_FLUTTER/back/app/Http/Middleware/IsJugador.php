<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Tymon\JWTAuth\Facades\JWTAuth;
use Tymon\JWTAuth\Exceptions\JWTException;
use Tymon\JWTAuth\Exceptions\TokenExpiredException;
use Tymon\JWTAuth\Exceptions\TokenInvalidException;

class IsJugador
{
    public function handle(Request $request, Closure $next)
    {
        try {
            // Verificar y obtener el usuario del token
            $user = JWTAuth::parseToken()->authenticate();
            
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Usuario no encontrado'
                ], 404);
            }
            
            // Cargar la relación del rol si no está cargada
            if (!$user->relationLoaded('rol')) {
                $user->load('rol');
            }
            
            // Validar rol de jugador usando idRoles (3 = jugador)
            if ($user->idRoles !== 3) {
                return response()->json([
                    'success' => false,
                    'message' => 'Acceso denegado. Solo jugadores.',
                    'status' => 403
                ], 403);
            }

            // Agregar el usuario al request para usar en controllers
            $request->merge(['auth_user' => $user]);
            
        } catch (TokenExpiredException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Token expirado'
            ], 401);
            
        } catch (TokenInvalidException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Token inválido'
            ], 401);
            
        } catch (JWTException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Token no proporcionado'
            ], 401);
        }

        return $next($request);
    }
}