<?php
use App\Http\Controllers\AuthController;
use Illuminate\Http\Request;
use App\Http\Controllers\JugadoresController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\EntrenadoresController;
use App\Http\Controllers\TiposDeDocumentosController;
use App\Http\Controllers\PersonasController;
use App\Http\Controllers\cronogramasController;
use App\Http\Controllers\PartidosController;
use App\Http\Controllers\CompetenciasController;
use App\Http\Controllers\EquiposController;
use App\Http\Controllers\ResultadosController;
use App\Http\Controllers\RendimientosPartidosController;
use App\Http\Controllers\RolesController;

//personas
Route::get('personas', [PersonasController::class, 'index']);  // Obtener todos los entrenadores
Route::get('personas/{id}', [PersonasController::class, 'show']);  // Obtener entrenador por id
Route::post('personas', [PersonasController::class, 'store']);  // Crear nuevo entrenador
Route::put('personas/{id}', [PersonasController::class, 'update']);  // Actualizar entrenador
Route::delete('personas/{id}', [PersonasController::class, 'destroy']);  // Eliminar entrenador

//Entrenadores
Route::get('entrenadores', [EntrenadoresController::class, 'index']);  // Obtener todos los entrenadores
Route::get('entrenadores/{id}', [EntrenadoresController::class, 'show']);  // Obtener entrenador por id
Route::post('entrenadores', [EntrenadoresController::class, 'store']);  // Crear nuevo entrenador
Route::put('entrenadores/{id}', [EntrenadoresController::class, 'update']);  // Actualizar entrenador
Route::delete('entrenadores/{id}', [EntrenadoresController::class, 'destroy']);  // Eliminar entrenador

//tipodedocumento
Route::apiResource('tiposdedocumentos', TiposDeDocumentosController::class);

//jugadores
Route::apiResource('Jugadores', JugadoresController::class);

//cronogramas
Route::get('cronogramas', [cronogramasController::class, 'index']);  // Obtener todos los cronogramas
Route::get('cronogramas/{id}', [cronogramasController::class, 'show']);  // Obtener cronograma por id
Route::post('cronogramas', [cronogramasController::class, 'store']);  // Crear nuevo cronograma
Route::put('cronogramas/{id}', [cronogramasController::class, 'update']);  // Actualizar cronograma
Route::delete('cronogramas/{id}', [cronogramasController::class, 'destroy']);  // Eliminar cronograma

//partidos
Route::get('Partidos', [PartidosController::class, 'index']);  // Obtener todos los partidos
Route::get('Partidos/{id}', [PartidosController::class, 'show']);  // Obtener partido por id
Route::post('Partidos', [PartidosController::class, 'store']);  // Crear nuevo partido
Route::put('Partidos/{id}', [PartidosController::class, 'update']);  // Actualizar partido
Route::delete('Partidos/{id}', [PartidosController::class, 'destroy']);  // Eliminar partido

//competencias
Route::get('Competencias', [CompetenciasController::class, 'index']);  // Obtener todas las competencias
Route::get('Competencias/{id}', [CompetenciasController::class, 'show']);  // Obtener competencia por id
Route::post('Competencias', [CompetenciasController::class, 'store']);  // Crear nueva competencia
Route::put('Competencias/{id}', [CompetenciasController::class, 'update']);  // Actualizar competencia
Route::delete('Competencias/{id}', [CompetenciasController::class, 'destroy']);  // Eliminar competencia

//equipos
Route::get('Equipos', [EquiposController::class, 'index']);  // Obtener todos los equipos
Route::get('Equipos/{id}', [EquiposController::class, 'show']);  // Obtener equipo por id
Route::post('Equipos', [EquiposController::class, 'store']);  // Crear nuevo equipo
Route::put('Equipos/{id}', [EquiposController::class, 'update']);  // Actualizar equipo
Route::delete('Equipos/{id}', [EquiposController::class, 'destroy']);  // Eliminar equipo

//resultados
Route::get('Resultados', [ResultadosController::class, 'index']);  // Obtener todos los resultados
Route::get('Resultados/{id}', [ResultadosController::class, 'show']);  // Obtener resultado por id
Route::post('Resultados', [ResultadosController::class, 'store']);  // Crear nuevo resultado
Route::put('Resultados/{id}', [ResultadosController::class, 'update']);  // Actualizar resultado
Route::delete('Resultados/{id}', [ResultadosController::class, 'destroy']);  // Eliminar resultado

//rendimientospartidos
Route::get('RendimientosPartidos', [RendimientosPartidosController::class, 'index']);  // Obtener todos los rendimientos de partidos
Route::get('RendimientosPartidos/{id}', [RendimientosPartidosController::class, 'show']);  // Obtener rendimiento de partido por id
Route::post('RendimientosPartidos', [RendimientosPartidosController::class, 'store']);  // Crear nuevo rendimiento de partido
Route::put('RendimientosPartidos/{id}', [RendimientosPartidosController::class, 'update']);  // Actualizar rendimiento de partido
Route::delete('RendimientosPartidos/{id}', [RendimientosPartidosController::class, 'destroy']);  // Eliminar rendimiento de partido

// =====================================================
// RUTAS DE AUTENTICACIÓN
// =====================================================

// ---------------------
// RUTAS PÚBLICAS (sin token ni roles)
// ---------------------
Route::post('/login', [AuthController::class, 'login'])->name('login'); // Login para obtener token
Route::get('/roles', [RolesController::class, 'index']);  // Ver todos los roles (público)
Route::get('/roles/{id}', [RolesController::class, 'show']); // Ver un rol por ID (público)

// ---------------------
// RUTAS PARA CUALQUIER USUARIO AUTENTICADO (roles 1, 2, 3)
// ---------------------
Route::middleware(['roles:1,2,3'])->group(function () {
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);
    
    // Rutas que cualquier usuario autenticado puede usar
    Route::get('/perfil', function () {
        return response()->json(['message' => 'Tu perfil de usuario']);
    });
});

// ---------------------
// RUTAS SOLO ADMINISTRADOR (idRoles = 1)
// ---------------------
Route::middleware(['roles:1'])->group(function () {
    // Gestión de roles (solo admin)
    Route::post('/roles', [RolesController::class, 'store']);       // Crear rol
    Route::put('/roles/{id}', [RolesController::class, 'update']); // Actualizar rol
    Route::delete('/roles/{id}', [RolesController::class, 'destroy']); // Eliminar rol

    // Dashboard de administrador
    Route::get('/admin/dashboard', function () {
        return response()->json(['message' => 'Bienvenido administrador']);
    });

    // El admin puede gestionar todo
    Route::get('/admin/usuarios', function () {
        return response()->json(['message' => 'Lista de todos los usuarios']);
    });
});

// ---------------------
// RUTAS ADMINISTRADOR Y ENTRENADOR (roles 1 y 2)
// ---------------------
Route::middleware(['roles:1,2'])->group(function () {
    // Rutas que pueden usar admin y entrenadores
    Route::get('/gestion/equipos', function () {
        return response()->json(['message' => 'Gestión de equipos']);
    });
    
    Route::get('/gestion/partidos', function () {
        return response()->json(['message' => 'Gestión de partidos']);
    });
});

// ---------------------
// RUTAS SOLO ENTRENADOR (idRoles = 2)
// ---------------------
Route::middleware(['roles:2'])->group(function () {
    Route::get('/entrenador/panel', function () {
        return response()->json(['message' => 'Bienvenido entrenador']);
    });
    
    Route::get('/entrenador/mis-equipos', function () {
        return response()->json(['message' => 'Equipos que entrenas']);
    });
});

// ---------------------
// RUTAS SOLO JUGADOR (idRoles = 3)
// ---------------------
Route::middleware(['roles:3'])->group(function () {
    Route::get('/jugador/perfil', function () {
        return response()->json(['message' => 'Bienvenido jugador']);
    });
    
    Route::get('/jugador/estadisticas', function () {
        return response()->json(['message' => 'Tus estadísticas personales']);
    });
});

// ---------------------
// RUTA DE PRUEBA PARA DEBUGGEAR
// ---------------------
Route::middleware(['roles:1,2,3'])->get('/test-auth', function (Request $request) {
    return response()->json([
        'success' => true,
        'message' => '¡La autenticación funciona!',
        'usuario' => $request->user(),
        'timestamp' => now()
    ]);
});