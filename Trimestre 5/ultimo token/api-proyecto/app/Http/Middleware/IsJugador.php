<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class IsJugador
{
    public function handle(Request $request, Closure $next)
    {
        $user = $request->auth_user ?? auth('api')->user();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Usuario no autenticado',
                'status' => 401
            ], 401);
        }

        if ($user->Role !== 'jugador') {
            return response()->json([
                'success' => false,
                'message' => 'Acceso denegado. Solo jugadores.',
                'status' => 403
            ], 403);
        }

        return $next($request);
    }
}
