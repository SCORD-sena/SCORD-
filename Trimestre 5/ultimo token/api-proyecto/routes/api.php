    <?php


    use Illuminate\Support\Facades\Route;   
    use Illuminate\Http\Request;
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
    use App\Http\Controllers\RolesController;


    // 
    // RUTAS PÚBLICAS (sin autenticación)
    // 

    // Autenticación
    Route::post('register', [AuthController::class, 'register']);
    Route::post('login', [AuthController::class, 'login']);

    // 
    // 
    // RUTAS PROTEGIDAS - Requieren autenticación
    // 

    Route::middleware('auth:api')->group(function () {
        
        // 
        // RUTAS DE AUTENTICACIÓN
        // 
        Route::post('logout', [AuthController::class, 'logout']);
        Route::get('me', [AuthController::class, 'getUser']);

        // 
        // RUTAS SOLO PARA ADMINISTRADORES
        //
        
        Route::middleware('auth.administrador')->group(function () {

            // Control total sobre las entidades
              Route::apiResource('categorias', CategoriasController::class);
              Route::apiResource('competencias', CompetenciasController::class);
              Route::apiResource('cronogramas', cronogramasController::class);
              Route::apiResource('entrenadores', EntrenadoresController::class);
              Route::apiResource('equipos', EquiposController::class);
              Route::apiResource('jugadores', JugadoresController::class);
              Route::apiResource('partidos', PartidosController::class);
              Route::apiResource('personas', PersonasController::class);
              Route::apiResource('rendimientos', RendimientosPartidosController::class);
              Route::apiResource('resultados', ResultadosController::class);
              Route::apiResource('roles', RolesController::class);
              Route::apiResource('tipos-documentos', TiposDeDocumentosController::class);

});
        // 
        // RUTAS SOLO PARA ENTRENADORES
        // 
        Route::middleware('auth.entrenador')->group(function () {
            // Los entrenadores pueden gestionar jugadores y ver cronogramas y partidos
            Route::apiResource('jugadores', JugadoresController::class)->only(['index', 'show', 'update']);
            Route::get('cronogramas', [cronogramasController::class, 'index']);
            Route::get('partidos', [PartidosController::class, 'index']);
        });

        // 
        // RUTAS SOLO PARA JUGADORES
        // 
        Route::middleware('auth.Jugador')->group(function () {
            // Los jugadores pueden ver sus propios datos y cronogramas
            Route::get('jugadores/{id}', [JugadoresController::class, 'show']);
            Route::get('cronogramas', [cronogramasController::class, 'index']);
        });
    });
