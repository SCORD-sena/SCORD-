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
Route::post('logout', [AuthController::class, 'logout']);
Route::get('me', [AuthController::class, 'getUser']);

// ============================================
// PERSONAS - ACCESO PÚBLICO TEMPORAL
// ============================================
Route::get('personas', [PersonasController::class, 'index']);
Route::get('personas/{id}', [PersonasController::class, 'show']);
Route::post('personas', [PersonasController::class, 'store']);
Route::put('personas/{id}', [PersonasController::class, 'update']);
Route::delete('personas/{id}', [PersonasController::class, 'destroy']);

// ============================================
// ROLES - ACCESO PÚBLICO TEMPORAL
// ============================================
Route::get('roles', [RolesController::class, 'index']);
Route::get('roles/{id}', [RolesController::class, 'show']);
Route::post('roles', [RolesController::class, 'store']);
Route::put('roles/{id}', [RolesController::class, 'update']);
Route::delete('roles/{id}', [RolesController::class, 'destroy']);

// ============================================
// ENTRENADORES - ACCESO PÚBLICO TEMPORAL
// ============================================
Route::get('entrenadores/misCategorias', [EntrenadoresController::class, 'misCategorias']);
Route::get('entrenadores', [EntrenadoresController::class, 'index']);
Route::get('entrenadores/{id}', [EntrenadoresController::class, 'show']);
Route::post('entrenadores', [EntrenadoresController::class, 'store']);
Route::put('entrenadores/{id}', [EntrenadoresController::class, 'update']);
Route::delete('entrenadores/{id}', [EntrenadoresController::class, 'destroy']);

// ============================================
// TIPOS DE DOCUMENTOS - ACCESO PÚBLICO TEMPORAL
// ============================================
Route::get('tiposdedocumentos', [TiposDeDocumentosController::class, 'index']);
Route::get('tiposdedocumentos/{id}', [TiposDeDocumentosController::class, 'show']);
Route::post('tiposdedocumentos', [TiposDeDocumentosController::class, 'store']);
Route::put('tiposdedocumentos/{id}', [TiposDeDocumentosController::class, 'update']);
Route::delete('tiposdedocumentos/{id}', [TiposDeDocumentosController::class, 'destroy']);

// ============================================
// JUGADORES - ACCESO PÚBLICO TEMPORAL
// ============================================
Route::get('jugadores', [JugadoresController::class, 'index']);
Route::get('jugadores/{id}', [JugadoresController::class, 'show']);
Route::post('jugadores', [JugadoresController::class, 'store']);
Route::put('jugadores/{id}', [JugadoresController::class, 'update']);
Route::delete('jugadores/{id}', [JugadoresController::class, 'destroy']);

// ============================================
// CRONOGRAMAS - ACCESO PÚBLICO TEMPORAL
// ============================================
Route::get('cronogramas', [cronogramasController::class, 'index']);
Route::get('cronogramas/{id}', [cronogramasController::class, 'show']);
Route::post('cronogramas', [cronogramasController::class, 'store']);
Route::put('cronogramas/{id}', [cronogramasController::class, 'update']);
Route::delete('cronogramas/{id}', [cronogramasController::class, 'destroy']);

// ============================================
// PARTIDOS - ACCESO PÚBLICO TEMPORAL
// ============================================
Route::get('partidos', [PartidosController::class, 'index']);
Route::get('partidos/{id}', [PartidosController::class, 'show']);
Route::post('partidos', [PartidosController::class, 'store']);
Route::put('partidos/{id}', [PartidosController::class, 'update']);
Route::delete('partidos/{id}', [PartidosController::class, 'destroy']);

// ============================================
// COMPETENCIAS - ACCESO PÚBLICO TEMPORAL
// ============================================
Route::get('competencias', [CompetenciasController::class, 'index']);
Route::get('competencias/{id}', [CompetenciasController::class, 'show']);
Route::post('competencias', [CompetenciasController::class, 'store']);
Route::put('competencias/{id}', [CompetenciasController::class, 'update']);
Route::delete('competencias/{id}', [CompetenciasController::class, 'destroy']);

// ============================================
// EQUIPOS - ACCESO PÚBLICO TEMPORAL
// ============================================
Route::get('equipos', [EquiposController::class, 'index']);
Route::get('equipos/{id}', [EquiposController::class, 'show']);
Route::post('equipos', [EquiposController::class, 'store']);
Route::put('equipos/{id}', [EquiposController::class, 'update']);
Route::delete('equipos/{id}', [EquiposController::class, 'destroy']);

// ============================================
// RESULTADOS - ACCESO PÚBLICO TEMPORAL
// ============================================
Route::get('resultados', [ResultadosController::class, 'index']);
Route::get('resultados/{id}', [ResultadosController::class, 'show']);
Route::post('resultados', [ResultadosController::class, 'store']);
Route::put('resultados/{id}', [ResultadosController::class, 'update']);
Route::delete('resultados/{id}', [ResultadosController::class, 'destroy']);

// ============================================
// RENDIMIENTOS PARTIDOS - ACCESO PÚBLICO TEMPORAL
// ============================================
// Rutas específicas primero
Route::get('rendimientospartidos/jugador/{idJugadores}/totales', [RendimientosPartidosController::class, 'getTotalStatsByPlayer']);
Route::get('rendimientospartidos/jugador/{idJugadores}/temporadas', [RendimientosPartidosController::class, 'getStatsBySeason']);
Route::get('rendimientospartidos/jugador/{idJugadores}/ultimos-partidos/{limit?}', [RendimientosPartidosController::class, 'getLastMatches']);
Route::get('rendimientospartidos/jugador/{idJugadores}/ultimo-registro', [RendimientosPartidosController::class, 'getLastRecordForEdit']);

// Rutas genéricas después
Route::get('rendimientospartidos', [RendimientosPartidosController::class, 'index']);
Route::get('rendimientospartidos/{id}', [RendimientosPartidosController::class, 'show']);
Route::post('rendimientospartidos', [RendimientosPartidosController::class, 'store']);
Route::put('rendimientospartidos/{id}', [RendimientosPartidosController::class, 'update']);
Route::delete('rendimientospartidos/{id}', [RendimientosPartidosController::class, 'destroy']);

// ============================================
// PARTIDOS EQUIPOS - ACCESO PÚBLICO TEMPORAL
// ============================================
Route::get('partidosequipos', [PartidosEquiposController::class, 'index']);
Route::post('partidosequipos', [PartidosEquiposController::class, 'store']);
Route::put('partidosequipos/{id}', [PartidosEquiposController::class, 'update']);
Route::delete('partidosequipos/{id}', [PartidosEquiposController::class, 'destroy']);

// ============================================
// CATEGORÍAS - ACCESO PÚBLICO TEMPORAL
// ============================================
Route::get('categorias', [CategoriasController::class, 'index']);
Route::get('categorias/{id}', [CategoriasController::class, 'show']);
Route::post('categorias', [CategoriasController::class, 'store']);
Route::put('categorias/{id}', [CategoriasController::class, 'update']);
Route::delete('categorias/{id}', [CategoriasController::class, 'destroy']);