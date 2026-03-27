<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Tymon\JWTAuth\Facades\JWTAuth;
use Tymon\JWTAuth\Exceptions\JWTException;
use Tymon\JWTAuth\Exceptions\TokenExpiredException;
use Tymon\JWTAuth\Exceptions\TokenInvalidException;

class IsEntrenador
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
            
            // Validar rol de entrenador
            if ($user->Role !== 'entrenador') {
                return response()->json([
                    'success' => false,
                    'message' => 'Acceso denegado. Solo entrenadores.',
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
