<?php

use App\Http\Controllers\RolesController;
use Illuminate\Support\Facades\Route;   
use App\Http\Controllers\AuthController;
use App\Http\Controllers\CategoriasController;
use App\Http\Controllers\JugadoresController;
use App\Http\Controllers\EntrenadoresController;
use App\Http\Controllers\TiposDeDocumentosController;
use App\Http\Controllers\PersonasController;
use App\Http\Controllers\cronogramasController;
use App\Http\Controllers\PartidosController;
use App\Http\Controllers\CompetenciasController;
use App\Http\Controllers\EquiposController;
use App\Http\Controllers\ResultadosController;
use App\Http\Controllers\RendimientosPartidosController;
use App\Http\Controllers\PartidosEquiposController;

// ============================================
// RUTAS PÚBLICAS (sin autenticación)
// ============================================
Route::post('register', [AuthController::class, 'register']);
Route::post('login', [AuthController::class, 'login']);

// ============================================
// RUTAS PROTEGIDAS CON JWT
// ============================================
Route::middleware('jwt.auth')->group(function () {
    
    // ============================================
    // AUTENTICACIÓN - Todos los usuarios
    // ============================================
    Route::post('logout', [AuthController::class, 'logout']);
    Route::get('me', [AuthController::class, 'getUser']);
    
    // ============================================
    // PERSONAS - Solo Admin (rol 1)
    // ============================================
    Route::get('personas', [PersonasController::class, 'index'])->middleware('auth_administrador');
    Route::get('personas/{id}', [PersonasController::class, 'show'])->middleware('auth_administrador');
    Route::post('personas', [PersonasController::class, 'store'])->middleware('auth_administrador');
    Route::put('personas/{id}', [PersonasController::class, 'update'])->middleware('auth_administrador');
    Route::delete('personas/{id}', [PersonasController::class, 'destroy'])->middleware('auth_administrador');
    
    // ============================================
    // ROLES - Solo Admin (rol 1)
    // ============================================
    Route::get('roles', [RolesController::class, 'index'])->middleware('auth_administrador');
    Route::get('roles/{id}', [RolesController::class, 'show'])->middleware('auth_administrador');
    Route::post('roles', [RolesController::class, 'store'])->middleware('auth_administrador');
    Route::put('roles/{id}', [RolesController::class, 'update'])->middleware('auth_administrador');
    Route::delete('roles/{id}', [RolesController::class, 'destroy'])->middleware('auth_administrador');
    
    // ============================================
    // ENTRENADORES - Admin (todo) | Entrenador (limitado)
    // ============================================
    Route::get('entrenadores', [EntrenadoresController::class, 'index'])->middleware('auth_administrador:1,2');
    Route::get('entrenadores/{id}', [EntrenadoresController::class, 'show'])->middleware('auth_administrador:1,2');
    Route::post('entrenadores', [EntrenadoresController::class, 'store'])->middleware('auth_administrador');
    Route::put('entrenadores/{id}', [EntrenadoresController::class, 'update'])->middleware('auth_administrador:1,2');
    Route::delete('entrenadores/{id}', [EntrenadoresController::class, 'destroy'])->middleware('auth_administrador');
    
    // ============================================
    // TIPOS DE DOCUMENTOS - Admin (todo) | Entrenador (lectura)
    // ============================================
    Route::get('tiposdedocumentos', [TiposDeDocumentosController::class, 'index'])->middleware('auth_administrador:1,2');
    Route::get('tiposdedocumentos/{id}', [TiposDeDocumentosController::class, 'show'])->middleware('auth_administrador:1,2');
    Route::post('tiposdedocumentos', [TiposDeDocumentosController::class, 'store'])->middleware('auth_administrador');
    Route::put('tiposdedocumentos/{id}', [TiposDeDocumentosController::class, 'update'])->middleware('auth_administrador');
    Route::delete('tiposdedocumentos/{id}', [TiposDeDocumentosController::class, 'destroy'])->middleware('auth_administrador');
    
    // ============================================
    // JUGADORES - Admin y Entrenador (todo) | Jugador (ver propio)
    // ============================================
    Route::get('jugadores', [JugadoresController::class, 'index'])->middleware('auth_administrador:1,2');
    Route::get('jugadores/{id}', [JugadoresController::class, 'show'])->middleware('auth_administrador:1,2,3');
    Route::post('jugadores', [JugadoresController::class, 'store'])->middleware('auth_administrador:1,2');
    Route::put('jugadores/{id}', [JugadoresController::class, 'update'])->middleware('auth_administrador:1,2');
    Route::delete('jugadores/{id}', [JugadoresController::class, 'destroy'])->middleware('auth_administrador:1,2');
    Route::get('categorias/{id}/jugadores', [CategoriasController::class, 'jugadoresPorCategoria'])
    ->middleware('auth_administrador:1,2');

    
    // ============================================
    // CRONOGRAMAS - Admin y Entrenador (todo) | Jugador (lectura)
    // ============================================
    Route::get('cronogramas', [cronogramasController::class, 'index'])->middleware('auth_administrador:1,2,3');
    Route::get('cronogramas/{id}', [cronogramasController::class, 'show'])->middleware('auth_administrador:1,2,3');
    Route::post('cronogramas', [cronogramasController::class, 'store'])->middleware('auth_administrador:1,2');
    Route::put('cronogramas/{id}', [cronogramasController::class, 'update'])->middleware('auth_administrador:1,2');
    Route::delete('cronogramas/{id}', [cronogramasController::class, 'destroy'])->middleware('auth_administrador:1,2');
    
    // ============================================
    // PARTIDOS - Admin y Entrenador (todo) | Jugador (lectura)
    // ============================================
    Route::get('partidos', [PartidosController::class, 'index'])->middleware('auth_administrador:1,2,3');
    Route::get('partidos/{id}', [PartidosController::class, 'show'])->middleware('auth_administrador:1,2,3');
    Route::post('partidos', [PartidosController::class, 'store'])->middleware('auth_administrador:1,2');
    Route::put('partidos/{id}', [PartidosController::class, 'update'])->middleware('auth_administrador:1,2');
    Route::delete('partidos/{id}', [PartidosController::class, 'destroy'])->middleware('auth_administrador:1,2');
    
    // ============================================
    // COMPETENCIAS - Admin (todo) | Entrenador (lectura)
    // ============================================
    Route::get('competencias', [CompetenciasController::class, 'index'])->middleware('auth_administrador:1,2');
    Route::get('competencias/{id}', [CompetenciasController::class, 'show'])->middleware('auth_administrador:1,2');
    Route::post('competencias', [CompetenciasController::class, 'store'])->middleware('auth_administrador');
    Route::put('competencias/{id}', [CompetenciasController::class, 'update'])->middleware('auth_administrador');
    Route::delete('competencias/{id}', [CompetenciasController::class, 'destroy'])->middleware('auth_administrador');
    
    // ============================================
    // EQUIPOS - Admin (todo) | Entrenador (lectura)
    // ============================================
    Route::get('equipos', [EquiposController::class, 'index'])->middleware('auth_administrador:1,2');
    Route::get('equipos/{id}', [EquiposController::class, 'show'])->middleware('auth_administrador:1,2');
    Route::post('equipos', [EquiposController::class, 'store'])->middleware('auth_administrador');
    Route::put('equipos/{id}', [EquiposController::class, 'update'])->middleware('auth_administrador');
    Route::delete('equipos/{id}', [EquiposController::class, 'destroy'])->middleware('auth_administrador');
    
    // ============================================
    // RESULTADOS - Admin y Entrenador
    // ============================================
    Route::get('resultados', [ResultadosController::class, 'index'])->middleware('auth_administrador:1,2');
    Route::get('resultados/{id}', [ResultadosController::class, 'show'])->middleware('auth_administrador:1,2');
    Route::post('resultados', [ResultadosController::class, 'store'])->middleware('auth_administrador:1,2');
    Route::put('resultados/{id}', [ResultadosController::class, 'update'])->middleware('auth_administrador:1,2');
    Route::delete('resultados/{id}', [ResultadosController::class, 'destroy'])->middleware('auth_administrador:1,2');
    
    // ============================================
    // RENDIMIENTOS PARTIDOS - Admin y Entrenador
    // ============================================
    // ✅ RUTAS ESPECÍFICAS PRIMERO
Route::get('rendimientospartidos/jugador/{idJugadores}/totales', [RendimientosPartidosController::class, 'getTotalStatsByPlayer'])->middleware('auth_administrador:1,2');
Route::get('rendimientospartidos/jugador/{idJugadores}/temporadas', [RendimientosPartidosController::class, 'getStatsBySeason'])->middleware('auth_administrador:1,2');
Route::get('rendimientospartidos/jugador/{idJugadores}/ultimos-partidos/{limit?}', [RendimientosPartidosController::class, 'getLastMatches'])->middleware('auth_administrador:1,2');
Route::get('rendimientospartidos/jugador/{idJugadores}/ultimo-registro', [RendimientosPartidosController::class, 'getLastRecordForEdit'])->middleware('auth_administrador:1,2');

// ✅ RUTAS GENÉRICAS DESPUÉS
Route::get('rendimientospartidos', [RendimientosPartidosController::class, 'index'])->middleware('auth_administrador:1,2');
Route::get('rendimientospartidos/{id}', [RendimientosPartidosController::class, 'show'])->middleware('auth_administrador:1,2');
Route::post('rendimientospartidos', [RendimientosPartidosController::class, 'store'])->middleware('auth_administrador:1,2');
Route::put('rendimientospartidos/{id}', [RendimientosPartidosController::class, 'update'])->middleware('auth_administrador:1,2');
Route::delete('rendimientospartidos/{id}', [RendimientosPartidosController::class, 'destroy'])->middleware('auth_administrador:1,2');
    // ============================================
    // PARTIDOS EQUIPOS - Admin y Entrenador
    // ============================================
    Route::get('partidosequipos', [PartidosEquiposController::class, 'index'])->middleware('auth_administrador:1,2');
    Route::post('partidosequipos', [PartidosEquiposController::class, 'store'])->middleware('auth_administrador:1,2');
    Route::put('partidosequipos/{id}', [PartidosEquiposController::class, 'update'])->middleware('auth_administrador:1,2');
    Route::delete('partidosequipos/{id}', [PartidosEquiposController::class, 'destroy'])->middleware('auth_administrador:1,2');
    
    // ============================================
    // CATEGORÍAS - Admin (todo) | Entrenador (lectura)
    // ============================================
    Route::get('categorias', [CategoriasController::class, 'index'])->middleware('auth_administrador:1,2');
    Route::get('categorias/{id}', [CategoriasController::class, 'show'])->middleware('auth_administrador:1,2');
    Route::post('categorias', [CategoriasController::class, 'store'])->middleware('auth_administrador');
    Route::put('categorias/{id}', [CategoriasController::class, 'update'])->middleware('auth_administrador');
    Route::delete('categorias/{id}', [CategoriasController::class, 'destroy'])->middleware('auth_administrador');
});