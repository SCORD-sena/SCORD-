<?php

namespace App\Http\Controllers;

use App\Models\RendimientosPartidos;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class RendimientosPartidosController extends Controller
{
    public function index()
    {
        $RendimientosPartidos = RendimientosPartidos::all();

        if ($RendimientosPartidos->isEmpty()) {
            return response()->json([
                'message' => 'No se encontraron rendimientos de partidos',
                'status' => 404
            ], 404);
        }

        return response()->json($RendimientosPartidos, 200);
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
 * Formato compatible con Flutter
 */
public function getTotalStatsByPlayer($idJugadores)
{
    try {
        $rendimientos = RendimientosPartidos::where('idJugadores', $idJugadores)->get();
        
        if ($rendimientos->isEmpty()) {
            return response()->json([
                'message' => 'No hay estadísticas para este jugador',
                'data' => null
            ], 404);
        }
        
        // Calcular totales con los nombres exactos que espera Flutter
        $totales = [
            'goles' => $rendimientos->sum('Goles'),
            'goles_cabeza' => $rendimientos->sum('GolesDeCabeza'),
            'asistencias' => $rendimientos->sum('Asistencias'),
            'tiros_puerta' => $rendimientos->sum('TirosApuerta'),
            'fueras_juego' => $rendimientos->sum('FuerasDeLugar'),
            'partidos_jugados' => $rendimientos->count(),
            'tarjetas_amarillas' => $rendimientos->sum('TarjetasAmarillas'),
            'tarjetas_rojas' => $rendimientos->sum('TarjetasRojas'),
        ];

        return response()->json([
            'data' => $totales
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
            'idPartidos' => 'required|integer|exists:Partidos,idPartidos',  // FK requerida
            'idJugadores' => 'required|integer|exists:Jugadores,idJugadores', // FK requerida
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

    public function destroy($id)
    {
        $RendimientosPartidos = RendimientosPartidos::find($id);

        if (!$RendimientosPartidos) {
            return response()->json([
                'message' => 'Rendimiento de partido no encontrado',
                'status' => 404
            ], 404);
        }

        $RendimientosPartidos->delete();

        return response()->json([
            'message' => 'Rendimiento de partido eliminado exitosamente'
        ], 200);
    }
}