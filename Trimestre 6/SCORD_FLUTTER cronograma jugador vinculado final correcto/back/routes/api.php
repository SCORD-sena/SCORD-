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
use App\Http\Controllers\ReporteController;

// ============================================
// RUTAS PÚBLICAS (sin autenticación)
// ============================================
Route::post('register', [AuthController::class, 'register']);
Route::post('login', [AuthController::class, 'login']);

// ============================================
// RUTAS PROTEGIDAS CON JWT
// ============================================
//Route::middleware('jwt.auth')->group(function () {
    
    // ============================================
    // AUTENTICACIÓN - Todos los usuarios
    // ============================================
    Route::post('logout', [AuthController::class, 'logout']);
    Route::get('me', [AuthController::class, 'getUser']);
    
    // ============================================
    // PERSONAS - Solo Admin (rol 1)
    // ============================================
Route::get('personas', [PersonasController::class, 'index'])->middleware('auth_administrador');
Route::get('personas/trashed', [PersonasController::class, 'trashed'])->middleware('auth_administrador'); // NUEVO: Ver papelera
Route::get('personas/{id}', [PersonasController::class, 'show'])->middleware('auth_administrador');
Route::post('personas', [PersonasController::class, 'store'])->middleware('auth_administrador');
Route::put('personas/{id}', [PersonasController::class, 'update'])->middleware('auth_administrador:1,2');
Route::delete('personas/{id}', [PersonasController::class, 'destroy'])->middleware('auth_administrador');
Route::post('personas/{id}/restore', [PersonasController::class, 'restore'])->middleware('auth_administrador'); // NUEVO: Restaurar
Route::delete('personas/{id}/force', [PersonasController::class, 'forceDelete'])->middleware('auth_administrador'); // NUEVO: Eliminar permanente
    
      // ============================================
    // REPORTES ESTADÍSTICAS PDF - ADMIN
    // IMPORTANTE: Rutas específicas ANTES de las genéricas
    // ============================================
    Route::get('reportes/jugador/{idJugadores}/competencias/{idCompetencias}/pdf', 
        [ReporteController::class, 'generarPdfJugadorCompetencias'])
        ->middleware('auth_administrador:1');
    
    // Reporte general (todas las competencias)
    Route::get('reportes/jugador/{idJugadores}/pdf', 
        [ReporteController::class, 'generarPdfJugador'])
        ->middleware('auth_administrador');
    
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
// ============================================
// ENTRENADORES - Admin (todo) | Entrenador (limitado)
// ============================================
Route::get('entrenadores/misCategorias', [EntrenadoresController::class, 'misCategorias'])->middleware('auth_administrador:2');
Route::get('entrenadores/trashed', [EntrenadoresController::class, 'trashed'])->middleware('auth_administrador:1,2'); // NUEVO: Ver papelera
Route::get('entrenadores', [EntrenadoresController::class, 'index'])->middleware('auth_administrador:1,2');
Route::get('entrenadores/{id}', [EntrenadoresController::class, 'show'])->middleware('auth_administrador:1,2');
Route::post('entrenadores', [EntrenadoresController::class, 'store'])->middleware('auth_administrador');
Route::put('entrenadores/{id}', [EntrenadoresController::class, 'update'])->middleware('auth_administrador:1,2');
Route::delete('entrenadores/{id}', [EntrenadoresController::class, 'destroy'])->middleware('auth_administrador');
Route::post('entrenadores/{id}/restore', [EntrenadoresController::class, 'restore'])->middleware('auth_administrador:1,2'); // NUEVO: Restaurar
Route::delete('entrenadores/{id}/force', [EntrenadoresController::class, 'forceDelete'])->middleware('auth_administrador:1'); // NUEVO: Eliminar permanente

    // Rutas para EntrenadorCategorias
    Route::get('entrenador-categorias', [EntrenadoresCategoriasController::class, 'index'])->middleware('auth_administrador:1,2');
    Route::get('entrenador-categorias/{idCategorias}/{idEntrenadores}', [EntrenadoresCategoriasController::class, 'show'])->middleware('auth_administrador:1,2');
    Route::get('entrenadores/persona/{idPersona}', [EntrenadoresController::class, 'getByPersonaId'])->middleware('auth_administrador:1,2');
    Route::get('entrenadores/{idEntrenador}/categorias', [EntrenadoresController::class, 'getCategoriasByEntrenador'])->middleware('auth_administrador:1,2');
    Route::post('entrenador-categorias', [EntrenadoresCategoriasController::class, 'store'])->middleware('auth_administrador:1,2');
    Route::put('entrenador-categorias/{idCategorias}/{idEntrenadores}', [EntrenadoresCategoriasController::class, 'update'])->middleware('auth_administrador:1,2');
    Route::delete('entrenador-categorias/{idCategorias}/{idEntrenadores}', [EntrenadoresCategoriasController::class, 'destroy'])->middleware('auth_administrador:1,2');
    
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
Route::get('jugadores/misDatos', [JugadoresController::class, 'misDatos'])->middleware('auth_administrador:3');
Route::get('jugadores/trashed', [JugadoresController::class, 'trashed'])->middleware('auth_administrador:1,2'); // NUEVO: Ver papelera
Route::get('jugadores', [JugadoresController::class, 'index'])->middleware('auth_administrador:1,2,3');
Route::get('jugadores/{id}', [JugadoresController::class, 'show'])->middleware('auth_administrador:1,2,3');
Route::post('jugadores', [JugadoresController::class, 'store'])->middleware('auth_administrador:1,2');
Route::put('jugadores/{id}', [JugadoresController::class, 'update'])->middleware('auth_administrador:1,2');
Route::delete('jugadores/{id}', [JugadoresController::class, 'destroy'])->middleware('auth_administrador:1,2');
Route::post('jugadores/{id}/restore', [JugadoresController::class, 'restore'])->middleware('auth_administrador:1,2'); // NUEVO: Restaurar
Route::delete('jugadores/{id}/force', [JugadoresController::class, 'forceDelete'])->middleware('auth_administrador:1'); // NUEVO: Eliminar permanente
Route::post('jugadores/{id}/registrar-pago', [JugadoresController::class, 'registrarPago'])->middleware('auth_administrador:1');
    
    // ============================================
    // JUGADORES POR CATEGORÍA 
    // ============================================
    Route::get('categorias/{id}/jugadores', [CategoriasController::class, 'jugadoresPorCategoria'])
        ->middleware('auth_administrador:1,2,3');
    
    // ============================================
    // RUTAS PARA ESTADÍSTICAS PERSONALES DE JUGADOR
    // ============================================
    Route::get('rendimientospartidos/mis-estadisticas', [RendimientosPartidosController::class, 'getMisEstadisticas'])
        ->middleware('auth_administrador:3');
    
// ============================================
    // CRONOGRAMAS - Admin y Entrenador (todo) | Jugador (lectura)
    // ============================================
    Route::get('cronogramas', [CronogramasController::class, 'index'])->middleware('auth_administrador:1,2,3');
    Route::get('cronogramas/papelera/listar', [CronogramasController::class, 'trashed'])->middleware('auth_administrador:1,2'); // NUEVO
    Route::get('cronogramas/{id}', [CronogramasController::class, 'show'])->middleware('auth_administrador:1,2,3');
    Route::post('cronogramas', [CronogramasController::class, 'store'])->middleware('auth_administrador:1,2');
    Route::put('cronogramas/{id}', [CronogramasController::class, 'update'])->middleware('auth_administrador:1,2');
    Route::delete('cronogramas/{id}', [CronogramasController::class, 'destroy'])->middleware('auth_administrador:1,2'); // MODIFICADO (soft delete)
    Route::post('cronogramas/{id}/restaurar', [CronogramasController::class, 'restore'])->middleware('auth_administrador:1,2'); // NUEVO
    Route::delete('cronogramas/{id}/forzar', [CronogramasController::class, 'forceDelete'])->middleware('auth_administrador:1,2'); // NUEVO
    
// ============================================
    // PARTIDOS - Admin y Entrenador (todo) | Jugador (lectura)
    // ============================================
    Route::get('partidos', [PartidosController::class, 'index'])->middleware('auth_administrador:1,2,3');
    Route::get('partidos/papelera/listar', [PartidosController::class, 'trashed'])->middleware('auth_administrador:1,2'); // NUEVO
    Route::get('partidos/{id}', [PartidosController::class, 'show'])->middleware('auth_administrador:1,2,3');
    Route::post('partidos', [PartidosController::class, 'store'])->middleware('auth_administrador:1,2');
    Route::put('partidos/{id}', [PartidosController::class, 'update'])->middleware('auth_administrador:1,2');
    Route::delete('partidos/{id}', [PartidosController::class, 'destroy'])->middleware('auth_administrador:1,2'); // MODIFICADO (soft delete)
    Route::post('partidos/{id}/restaurar', [PartidosController::class, 'restore'])->middleware('auth_administrador:1,2'); // NUEVO
    Route::delete('partidos/{id}/forzar', [PartidosController::class, 'forceDelete'])->middleware('auth_administrador:1,2'); // NUEVO
    
// ============================================
    // COMPETENCIAS - Admin (todo) | Entrenador (lectura)
    // ============================================
    Route::get('competencias', [CompetenciasController::class, 'index'])->middleware('auth_administrador:1,2');
    Route::get('competencias/papelera/listar', [CompetenciasController::class, 'trashed'])->middleware('auth_administrador'); // NUEVO
    Route::get('competencias/{id}', [CompetenciasController::class, 'show'])->middleware('auth_administrador:1,2');
    Route::post('competencias', [CompetenciasController::class, 'store'])->middleware('auth_administrador');
    Route::put('competencias/{id}', [CompetenciasController::class, 'update'])->middleware('auth_administrador');
    Route::delete('competencias/{id}', [CompetenciasController::class, 'destroy'])->middleware('auth_administrador'); // MODIFICADO (soft delete)
    Route::post('competencias/{id}/restaurar', [CompetenciasController::class, 'restore'])->middleware('auth_administrador'); // NUEVO
    Route::delete('competencias/{id}/forzar', [CompetenciasController::class, 'forceDelete'])->middleware('auth_administrador'); // NUEVO
    
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
    Route::get('resultados/papelera/listar', [ResultadosController::class, 'trashed'])->middleware('auth_administrador:1,2'); // NUEVO
    Route::get('resultados/{id}', [ResultadosController::class, 'show'])->middleware('auth_administrador:1,2');
    Route::post('resultados', [ResultadosController::class, 'store'])->middleware('auth_administrador:1,2');
    Route::put('resultados/{id}', [ResultadosController::class, 'update'])->middleware('auth_administrador:1,2');
    Route::delete('resultados/{id}', [ResultadosController::class, 'destroy'])->middleware('auth_administrador:1,2'); // MODIFICADO (soft delete)
    Route::post('resultados/{id}/restaurar', [ResultadosController::class, 'restore'])->middleware('auth_administrador:1,2'); // NUEVO
    Route::delete('resultados/{id}/forzar', [ResultadosController::class, 'forceDelete'])->middleware('auth_administrador:1,2'); // NUEVO
    
    // ============================================
    // RENDIMIENTOS PARTIDOS - Admin y Entrenador
    // ============================================
    // ✅ RUTAS ESPECÍFICAS PRIMERO
    Route::get('rendimientospartidos/jugador/{idJugadores}/totales', [RendimientosPartidosController::class, 'getTotalStatsByPlayer'])->middleware('auth_administrador:1,2,3');
    Route::get('rendimientospartidos/jugador/{idJugadores}/temporadas', [RendimientosPartidosController::class, 'getStatsBySeason'])->middleware('auth_administrador:1,2,3');
    Route::get('rendimientospartidos/jugador/{idJugadores}/ultimos-partidos/{limit?}', [RendimientosPartidosController::class, 'getLastMatches'])->middleware('auth_administrador:1,2');
    Route::get('rendimientospartidos/jugador/{idJugadores}/ultimo-registro', [RendimientosPartidosController::class, 'getLastRecordForEdit'])->middleware('auth_administrador:1,2');
    Route::get('rendimientospartidos/jugador/{idJugadores}/partido/{idPartido}', [RendimientosPartidosController::class, 'obtenerPorPartido'])->middleware('auth_administrador:1,2'); //nuevo
    
    // ✅ RUTAS GENÉRICAS DESPUÉS
Route::get('rendimientospartidos', [RendimientosPartidosController::class, 'index'])->middleware('auth_administrador:1,2');
    Route::get('rendimientospartidos/papelera/listar', [RendimientosPartidosController::class, 'trashed'])->middleware('auth_administrador:1,2'); // NUEVO
    Route::get('rendimientospartidos/{id}', [RendimientosPartidosController::class, 'show'])->middleware('auth_administrador:1,2');
    Route::post('rendimientospartidos', [RendimientosPartidosController::class, 'store'])->middleware('auth_administrador:1,2');
    Route::put('rendimientospartidos/{id}', [RendimientosPartidosController::class, 'update'])->middleware('auth_administrador:1,2');
    Route::delete('rendimientospartidos/{id}', [RendimientosPartidosController::class, 'destroy'])->middleware('auth_administrador:1,2'); // MODIFICADO (soft delete)
    Route::post('rendimientospartidos/{id}/restaurar', [RendimientosPartidosController::class, 'restore'])->middleware('auth_administrador:1,2'); // NUEVO
    Route::delete('rendimientospartidos/{id}/forzar', [RendimientosPartidosController::class, 'forceDelete'])->middleware('auth_administrador:1,2'); // NUEVO
    
    // ============================================
    // PARTIDOS EQUIPOS - Admin y Entrenador
    // ============================================
    Route::get('partidosequipos', [PartidosEquiposController::class, 'index'])->middleware('auth_administrador:1,2');
    Route::post('partidosequipos', [PartidosEquiposController::class, 'store'])->middleware('auth_administrador:1,2');
    Route::put('partidosequipos/{id}', [PartidosEquiposController::class, 'update'])->middleware('auth_administrador:1,2');
    Route::delete('partidosequipos/{id}', [PartidosEquiposController::class, 'destroy'])->middleware('auth_administrador:1,2');
    
 // ============================================
    // CATEGORÍAS - Admin (todo) | Entrenador y Jugador (lectura)
    // ============================================
    Route::get('categorias', [CategoriasController::class, 'index'])->middleware('auth_administrador:1,2,3');
    Route::get('categorias/papelera/listar', [CategoriasController::class, 'trashed'])->middleware('auth_administrador'); // NUEVO
    Route::get('categorias/{id}', [CategoriasController::class, 'show'])->middleware('auth_administrador:1,2,3');
    Route::post('categorias', [CategoriasController::class, 'store'])->middleware('auth_administrador');
    Route::put('categorias/{id}', [CategoriasController::class, 'update'])->middleware('auth_administrador');
    Route::delete('categorias/{id}', [CategoriasController::class, 'destroy'])->middleware('auth_administrador'); // MODIFICADO (soft delete)
    Route::post('categorias/{id}/restaurar', [CategoriasController::class, 'restore'])->middleware('auth_administrador'); // NUEVO
    Route::delete('categorias/{id}/forzar', [CategoriasController::class, 'forceDelete'])->middleware('auth_administrador'); // NUEVO


    // Cronogramas por competencia y categoría
    Route::get('cronogramas/competencia/{idCompetencias}/categoria/{idCategorias}', 
    [cronogramasController::class, 'getCronogramasByCompetenciaYCategoria']);

// Partidos por competencia
    Route::get('partidos/competencia/{idCompetencias}', 
    [PartidosController::class, 'getPartidosByCompetencia']);
    Route::get('competencias/categoria/{idCategorias}', 
    [CompetenciasController::class, 'getCompetenciasByCategoria']);

    // Estadísticas filtradas por competencia
Route::get('/rendimientos/jugador/{idJugadores}/competencia/{idCompetencia}', 
    [RendimientosPartidosController::class, 'getStatsByCompetencia']);

// Estadísticas de un partido específico
Route::get('/rendimientos/jugador/{idJugadores}/partido/{idPartido}', 
    [RendimientosPartidosController::class, 'getStatsByPartido']);
///});