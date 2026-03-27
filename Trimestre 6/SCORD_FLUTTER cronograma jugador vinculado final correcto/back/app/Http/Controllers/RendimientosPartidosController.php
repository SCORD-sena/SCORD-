<?php

namespace App\Http\Controllers;

use App\Models\RendimientosPartidos;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class RendimientosPartidosController extends Controller
{
    /**
     * Listar rendimientos activos (no eliminados)
     */
    public function index()
    {
        $RendimientosPartidos = RendimientosPartidos::all();

        // ====== CAMBIO: Devolver array vacío en lugar de 404 ======
        if ($RendimientosPartidos->isEmpty()) {
            return response()->json([], 200); // ← Array vacío con status 200
        }

        return response()->json($RendimientosPartidos, 200);
    }

    /**
     * NUEVO: Listar rendimientos eliminados (papelera)
     */
    public function trashed()
    {
        $RendimientosPartidos = RendimientosPartidos::onlyTrashed()->get();

        if ($RendimientosPartidos->isEmpty()) {
            return response()->json([
                'message' => 'No hay rendimientos eliminados',
                'status' => 404
            ], 404);
        }

        return response()->json([
            'data' => $RendimientosPartidos,
            'status' => 200
        ], 200);
    }

    public function show($id)
    {
        $RendimientosPartidos = RendimientosPartidos::find($id);

        if (!$RendimientosPartidos) {
            return response()->json([
                'message' => 'Rendimiento de partido no encontrado',
                'status' => 404
            ], 404);
        }

        return response()->json($RendimientosPartidos, 200);
    }

    /**
     * Obtener estadísticas totales de un jugador
     */
    public function getTotalStatsByPlayer($idJugadores)
    {
        try {
            $totalStats = RendimientosPartidos::where('idJugadores', $idJugadores)
    ->selectRaw('
        COALESCE(SUM(Goles), 0) as total_goles,
        COALESCE(SUM(GolesDeCabeza), 0) as total_goles_cabeza,
        COALESCE(SUM(MinutosJugados), 0) as total_minutos_jugados,
        COALESCE(SUM(Asistencias), 0) as total_asistencias,
        COALESCE(SUM(TirosApuerta), 0) as total_tiros_apuerta,
        COALESCE(SUM(TarjetasRojas), 0) as total_tarjetas_rojas,
        COALESCE(SUM(TarjetasAmarillas), 0) as total_tarjetas_amarillas,
        COALESCE(SUM(ArcoEnCero), 0) as total_arco_en_cero,
        COALESCE(SUM(FuerasDeLugar), 0) as total_fueras_de_lugar,
        COUNT(*) as total_partidos_jugados
    ')
    ->first();

            // Calcular promedios
            $partidosJugados = $totalStats->total_partidos_jugados;
            
            if ($partidosJugados > 0) {
                $promedios = [
                    'goles_por_partido' => round($totalStats->total_goles / $partidosJugados, 2),
                    'asistencias_por_partido' => round($totalStats->total_asistencias / $partidosJugados, 2),
                    'minutos_por_partido' => round($totalStats->total_minutos_jugados / $partidosJugados, 2),
                    'tiros_apuerta_por_partido' => round($totalStats->total_tiros_apuerta / $partidosJugados, 2)
                ];
            } else {
                $promedios = [
                    'goles_por_partido' => 0,
                    'asistencias_por_partido' => 0,
                    'minutos_por_partido' => 0,
                    'tiros_apuerta_por_partido' => 0
                ];
            }

            return response()->json([
                'success' => true,
                'data' => [
                    'totales' => $totalStats,
                    'promedios' => $promedios,
                    'partidos_jugados' => $partidosJugados
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al obtener estadísticas del jugador',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Obtener estadísticas por temporada (si tienes campo temporada)
     */
    public function getStatsBySeason($idJugadores)
    {
        try {
            // Si tienes campo temporada en tu tabla Partidos, puedes hacer join
            $statsBySeason = RendimientosPartidos::where('idJugadores', $idJugadores)
                ->join('Partidos', 'RendimientosPartidos.idPartidos', '=', 'Partidos.idPartidos')
                ->selectRaw('
                    Partidos.temporada as temporada,
                    COALESCE(SUM(RendimientosPartidos.Goles), 0) as goles,
                    COALESCE(SUM(RendimientosPartidos.Asistencias), 0) as asistencias,
                    COALESCE(SUM(RendimientosPartidos.MinutosJugados), 0) as minutos_jugados,
                    COALESCE(SUM(RendimientosPartidos.TirosApuerta), 0) as tiros_apuerta,
                    COUNT(*) as partidos_jugados
                ')
                ->groupBy('Partidos.temporada')
                ->get();

            return response()->json([
                'success' => true,
                'data' => $statsBySeason
            ], 200);

        } catch (\Exception $e) {
            // Si no tienes el campo temporada, devolver estadísticas generales
            return $this->getTotalStatsByPlayer($idJugadores);
        }
    }

    /**
     * Obtener últimos partidos de un jugador con sus estadísticas - CORREGIDO
     */
    public function getLastMatches($idJugadores, $limit = 5)
    {
        try {
            // Versión simplificada y corregida sin join problemático
            $lastMatches = RendimientosPartidos::where('idJugadores', $idJugadores)
                ->orderBy('IdRendimientos', 'desc')
                ->limit($limit)
                ->get();

            return response()->json([
                'success' => true,
                'data' => $lastMatches
            ], 200);

        } catch (\Exception $e) {
            // Log del error para debugging
            \Log::error('Error en getLastMatches - Jugador: ' . $idJugadores . ' - Error: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Error al obtener últimos partidos',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Obtener el último registro de un jugador para edición
     */
    public function getLastRecordForEdit($idJugadores)
    {
        try {
            $lastRecord = RendimientosPartidos::where('idJugadores', $idJugadores)
                ->orderBy('IdRendimientos', 'desc')
                ->first();

            if (!$lastRecord) {
                return response()->json([
                    'success' => false,
                    'message' => 'No se encontraron registros para este jugador',
                    'data' => null
                ], 404);
            }

            return response()->json([
                'success' => true,
                'data' => $lastRecord
            ], 200);

        } catch (\Exception $e) {
            \Log::error('Error en getLastRecordForEdit - Jugador: ' . $idJugadores . ' - Error: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Error al obtener el último registro',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function store(Request $request)
    {
        // Validación con PK y FK requeridas
        $validator = Validator::make($request->all(), [
            'Goles' => 'nullable|integer',
            'GolesDeCabeza' => 'nullable|integer',
            'MinutosJugados' => 'nullable|integer',
            'Asistencias' => 'nullable|integer',
            'TirosApuerta' => 'nullable|integer',
            'TarjetasRojas' => 'nullable|integer',
            'TarjetasAmarillas' => 'nullable|integer',
            'FuerasDeLugar' => 'nullable|integer',
            'ArcoEnCero' => 'nullable|integer',
            'idPartidos' => 'required|integer|exists:Partidos,idPartidos',
            'idJugadores' => 'required|integer|exists:Jugadores,idJugadores',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

        // Filtramos solo los campos que hayan sido enviados en el request
        $data = $request->only([
            'Goles',
            'GolesDeCabeza',
            'MinutosJugados',
            'Asistencias',
            'TirosApuerta',
            'TarjetasRojas',
            'TarjetasAmarillas',
            'FuerasDeLugar',
            'ArcoEnCero',
            'idPartidos',
            'idJugadores'
        ]);

        // Creamos el rendimiento de partido
        $RendimientosPartidos = RendimientosPartidos::create($data);

        $RendimientosPartidos->refresh();

        return response()->json([
            'message' => 'Rendimiento de partido creado exitosamente',
            'data' => $RendimientosPartidos
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $RendimientosPartidos = RendimientosPartidos::find($id);

        if (!$RendimientosPartidos) {
            return response()->json([
                'message' => 'Rendimiento de partido no encontrado',
                'status' => 404
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'Goles' => 'nullable|integer',
            'GolesDeCabeza' => 'nullable|integer',
            'MinutosJugados' => 'nullable|integer',
            'Asistencias' => 'nullable|integer',
            'TirosApuerta' => 'nullable|integer',
            'TarjetasRojas' => 'nullable|integer',
            'TarjetasAmarillas' => 'nullable|integer',
            'FuerasDeLugar' => 'nullable|integer',
            'ArcoEnCero' => 'nullable|integer',
            'idPartidos' => 'required|integer|exists:Partidos,idPartidos',
            'idJugadores' => 'required|integer|exists:Jugadores,idJugadores',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

        $data = $request->only([
            'Goles',
            'GolesDeCabeza',
            'MinutosJugados',
            'Asistencias',
            'TirosApuerta',
            'TarjetasRojas',
            'TarjetasAmarillas',
            'FuerasDeLugar',
            'ArcoEnCero',
            'idPartidos',
            'idJugadores'
        ]);

        $RendimientosPartidos->update($data);
        
        $RendimientosPartidos->refresh();

        return response()->json([
            'message' => 'Rendimiento de partido actualizado exitosamente',
            'data' => $RendimientosPartidos
        ], 200);
    }

    /**
     * MODIFICADO: Eliminar rendimiento (soft delete)
     */
    public function destroy($id)
    {
        $RendimientosPartidos = RendimientosPartidos::find($id);

        if (!$RendimientosPartidos) {
            return response()->json([
                'message' => 'Rendimiento de partido no encontrado',
                'status' => 404
            ], 404);
        }

        // Soft delete - solo pone fecha en deleted_at
        $RendimientosPartidos->delete();

        return response()->json([
            'message' => 'Rendimiento eliminado correctamente (movido a papelera)'
        ], 200);
    }

    /**
     * NUEVO: Restaurar rendimiento eliminado
     */
    public function restore($id)
    {
        $RendimientosPartidos = RendimientosPartidos::onlyTrashed()->find($id);

        if (!$RendimientosPartidos) {
            return response()->json([
                'message' => 'Rendimiento no encontrado en papelera',
                'status' => 404
            ], 404);
        }

        $RendimientosPartidos->restore();

        return response()->json([
            'message' => 'Rendimiento restaurado correctamente',
            'data' => $RendimientosPartidos,
            'status' => 200
        ], 200);
    }

    /**
     * NUEVO: Eliminar permanentemente
     */
    public function forceDelete($id)
    {
        $RendimientosPartidos = RendimientosPartidos::onlyTrashed()->find($id);

        if (!$RendimientosPartidos) {
            return response()->json([
                'message' => 'Rendimiento no encontrado en papelera',
                'status' => 404
            ], 404);
        }

        $RendimientosPartidos->forceDelete(); // Eliminación permanente

        return response()->json([
            'message' => 'Rendimiento eliminado permanentemente',
            'status' => 200
        ], 200);
    }

    /**
     * Obtener estadísticas de un jugador filtradas por competencia
     */
    public function getStatsByCompetencia($idJugadores, $idCompetencia)
    {
        try {
            // Obtener estadísticas sumadas de todos los partidos de esa competencia
            $stats = RendimientosPartidos::where('RendimientosPartidos.idJugadores', $idJugadores)
                ->join('Partidos', 'RendimientosPartidos.idPartidos', '=', 'Partidos.idPartidos')
                ->join('Cronogramas', 'Partidos.idCronogramas', '=', 'Cronogramas.idCronogramas')
                ->where('Cronogramas.idCompetencias', $idCompetencia)
                ->selectRaw('
                    COALESCE(SUM(RendimientosPartidos.Goles), 0) as total_goles,
                    COALESCE(SUM(RendimientosPartidos.GolesDeCabeza), 0) as total_goles_cabeza,
                    COALESCE(SUM(RendimientosPartidos.MinutosJugados), 0) as total_minutos_jugados,
                    COALESCE(SUM(RendimientosPartidos.Asistencias), 0) as total_asistencias,
                    COALESCE(SUM(RendimientosPartidos.TirosApuerta), 0) as total_tiros_apuerta,
                    COALESCE(SUM(RendimientosPartidos.TarjetasRojas), 0) as total_tarjetas_rojas,
                    COALESCE(SUM(RendimientosPartidos.TarjetasAmarillas), 0) as total_tarjetas_amarillas,
                    COALESCE(SUM(RendimientosPartidos.ArcoEnCero), 0) as total_arco_en_cero,
                    COALESCE(SUM(RendimientosPartidos.FuerasDeLugar), 0) as total_fueras_de_lugar,
                    COUNT(*) as total_partidos_jugados
                ')
                ->first();

            // Calcular promedios
            $partidosJugados = $stats->total_partidos_jugados;
            
            if ($partidosJugados > 0) {
                $promedios = [
                    'goles_por_partido' => round($stats->total_goles / $partidosJugados, 2),
                    'asistencias_por_partido' => round($stats->total_asistencias / $partidosJugados, 2),
                    'minutos_por_partido' => round($stats->total_minutos_jugados / $partidosJugados, 2),
                    'tiros_apuerta_por_partido' => round($stats->total_tiros_apuerta / $partidosJugados, 2)
                ];
            } else {
                $promedios = [
                    'goles_por_partido' => 0,
                    'asistencias_por_partido' => 0,
                    'minutos_por_partido' => 0,
                    'tiros_apuerta_por_partido' => 0
                ];
            }

            return response()->json([
                'success' => true,
                'data' => [
                    'totales' => $stats,
                    'promedios' => $promedios,
                    'partidos_jugados' => $partidosJugados
                ]
            ], 200);

        } catch (\Exception $e) {
            \Log::error('Error en getStatsByCompetencia - Jugador: ' . $idJugadores . ' - Competencia: ' . $idCompetencia . ' - Error: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Error al obtener estadísticas por competencia',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Obtener estadísticas de un jugador en un partido específico
     */
    public function getStatsByPartido($idJugadores, $idPartido)
    {
        try {
            // Obtener el rendimiento de ese partido específico
            $rendimiento = RendimientosPartidos::where('idJugadores', $idJugadores)
                ->where('idPartidos', $idPartido)
                ->first();

            if (!$rendimiento) {
                // Si no existe rendimiento para ese partido, devolver estadísticas en 0
                return response()->json([
                    'success' => true,
                    'data' => [
                        'totales' => [
                            'total_goles' => 0,
                            'total_goles_cabeza' => 0,
                            'total_minutos_jugados' => 0,
                            'total_asistencias' => 0,
                            'total_tiros_apuerta' => 0,
                            'total_tarjetas_rojas' => 0,
                            'total_tarjetas_amarillas' => 0,
                            'total_arco_en_cero' => 0,
                            'total_fueras_de_lugar' => 0,
                            'total_partidos_jugados' => 0
                        ],
                        'promedios' => [
                            'goles_por_partido' => 0,
                            'asistencias_por_partido' => 0,
                            'minutos_por_partido' => 0,
                            'tiros_apuerta_por_partido' => 0
                        ],
                        'partidos_jugados' => 0,
                        'mensaje' => 'El jugador no tiene estadísticas registradas en este partido'
                    ]
                ], 200);
            }

            // Formatear datos como estadísticas totales para mantener consistencia
            $totales = [
                'total_goles' => $rendimiento->Goles ?? 0,
                'total_goles_cabeza' => $rendimiento->GolesDeCabeza ?? 0,
                'total_minutos_jugados' => $rendimiento->MinutosJugados ?? 0,
                'total_asistencias' => $rendimiento->Asistencias ?? 0,
                'total_tiros_apuerta' => $rendimiento->TirosApuerta ?? 0,
                'total_tarjetas_rojas' => $rendimiento->TarjetasRojas ?? 0,
                'total_tarjetas_amarillas' => $rendimiento->TarjetasAmarillas ?? 0,
                'total_arco_en_cero' => $rendimiento->ArcoEnCero ?? 0,
                'total_fueras_de_lugar' => $rendimiento->FuerasDeLugar ?? 0,
                'total_partidos_jugados' => 1
            ];

            // Para un solo partido, los promedios son iguales a los valores
            $promedios = [
                'goles_por_partido' => $totales['total_goles'],
                'asistencias_por_partido' => $totales['total_asistencias'],
                'minutos_por_partido' => $totales['total_minutos_jugados'],
                'tiros_apuerta_por_partido' => $totales['total_tiros_apuerta']
            ];

            return response()->json([
                'success' => true,
                'data' => [
                    'totales' => (object) $totales,
                    'promedios' => $promedios,
                    'partidos_jugados' => 1,
                    'rendimiento_id' => $rendimiento->IdRendimientos
                ]
            ], 200);

        } catch (\Exception $e) {
            \Log::error('Error en getStatsByPartido - Jugador: ' . $idJugadores . ' - Partido: ' . $idPartido . ' - Error: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Error al obtener estadísticas del partido',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    /**
     * 🆕 Obtener el rendimiento completo de un jugador en un partido específico (para editar)
     * GET /api/rendimientospartidos/jugador/{idJugador}/partido/{idPartido}
     */
    public function obtenerPorPartido($idJugadores, $idPartido)
    {
        try {
            $rendimiento = RendimientosPartidos::where('idJugadores', $idJugadores)
                ->where('idPartidos', $idPartido)
                ->first();

            if (!$rendimiento) {
                return response()->json([
                    'success' => false,
                    'message' => 'No se encontró rendimiento para este jugador en este partido',
                    'data' => null
                ], 404);
            }

            return response()->json([
                'success' => true,
                'data' => $rendimiento
            ], 200);
            
        } catch (\Exception $e) {
            \Log::error('Error en obtenerPorPartido - Jugador: ' . $idJugadores . ' - Partido: ' . $idPartido . ' - Error: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Error al obtener rendimiento',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}