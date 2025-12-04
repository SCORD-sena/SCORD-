<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Tymon\JWTAuth\Facades\JWTAuth;
use Tymon\JWTAuth\Exceptions\JWTException;
use Tymon\JWTAuth\Exceptions\TokenExpiredException;
use Tymon\JWTAuth\Exceptions\TokenInvalidException;

class IsAdmin
{
    public function handle(Request $request, Closure $next, ...$allowedRoles)
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
            
            // Si no se pasan roles adicionales, solo verificar admin
            if (empty($allowedRoles)) {
                $allowedRoles = [1]; // Solo admin
            } else {
                // Convertir los roles a enteros
                $allowedRoles = array_map('intval', $allowedRoles);
            }
            
            // Verificar si el usuario tiene uno de los roles permitidos
            if (!in_array($user->idRoles, $allowedRoles)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Acceso denegado. No tienes permisos para esta acción.',
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