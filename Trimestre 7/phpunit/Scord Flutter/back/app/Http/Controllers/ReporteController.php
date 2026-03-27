<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Barryvdh\DomPDF\Facade\Pdf;
use App\Models\Jugadores;
use App\Models\RendimientosPartidos;
use App\Services\AnalisisIAService;
use Illuminate\Support\Facades\Log; // ← AGREGAR ESTA LÍNEA

class ReporteController extends Controller
{
    /**
     * Generar reporte PDF GENERAL del jugador
     */
    public function generarPdfJugador(Request $request, $idJugadores)
    {
        //TIMEOUT MÁXIMO DE 180 SEGUNDOS (3 MINUTOS)
        set_time_limit(180);
        ini_set('max_execution_time', 180);
        
        Log::info("📄 [PDF] Iniciando generación de PDF para jugador: {$idJugadores}");
        
        $jugador = Jugadores::with([
            'persona.tiposDeDocumentos',
            'categoria',
            'rendimientosPartidos.partido.cronograma'
        ])->find($idJugadores);

        if (!$jugador) {
            return response()->json(['message' => 'Jugador no encontrado'], 404);
        }

        $rendimientos = $jugador->rendimientosPartidos;

        $totales = [
            'Goles' => $rendimientos->sum('Goles'),
            'GolesDeCabeza' => $rendimientos->sum('GolesDeCabeza'),
            'Asistencias' => $rendimientos->sum('Asistencias'),
            'MinutosJugados' => $rendimientos->sum('MinutosJugados'),
            'TirosApuerta' => $rendimientos->sum('TirosApuerta'),
            'TarjetasRojas' => $rendimientos->sum('TarjetasRojas'),
            'TarjetasAmarillas' => $rendimientos->sum('TarjetasAmarillas'),
            'FuerasDeLugar' => $rendimientos->sum('FuerasDeLugar'),
            'ArcoEnCero' => $rendimientos->sum('ArcoEnCero'),
        ];

        $totalPartidos = max(1, $rendimientos->count());

        $promedios = [
            'GolesPromedio' => round($totales['Goles'] / $totalPartidos, 2),
            'AsistenciasPromedio' => round($totales['Asistencias'] / $totalPartidos, 2),
            'TirosPromedio' => round($totales['TirosApuerta'] / $totalPartidos, 2),
            'MinutosPromedio' => round($totales['MinutosJugados'] / $totalPartidos, 2),
        ];

        // Últimos 5 partidos
        $ultimosPartidos = RendimientosPartidos::with('partido.cronograma')
            ->where('idJugadores', $idJugadores)
            ->join('partidos', 'rendimientospartidos.idPartidos', '=', 'partidos.idPartidos')
            ->join('cronogramas', 'partidos.idCronogramas', '=', 'cronogramas.idCronogramas')
            ->orderByDesc('cronogramas.FechaDeEventos')
            ->limit(5)
            ->select('rendimientospartidos.*')
            ->get();

        // GENERAR ANÁLISIS CON IA (CON MANEJO ROBUSTO DE ERRORES)
        $analisisIA = null;
        try {
            Log::info('[PDF] Iniciando generación de análisis IA...');
            
            $iaService = new AnalisisIAService();
            $analisisIA = $iaService->generarAnalisisJugador(
                $jugador, 
                $totales, 
                $promedios, 
                $rendimientos->count(), 
                $ultimosPartidos
            );
            
            if ($analisisIA) {
                Log::info('✅ [PDF] Análisis IA incluido en el reporte');
            } else {
                Log::warning('⚠️ [PDF] No se generó análisis IA, el PDF se generará sin él');
            }
            
        } catch (\Exception $e) {
            Log::error('❌ [PDF] Error al generar análisis IA: ' . $e->getMessage());
            $analisisIA = null;
        }

        $data = [
            'jugador' => $jugador,
            'totales' => $totales,
            'promedios' => $promedios,
            'ultimosPartidos' => $ultimosPartidos,
            'totalPartidos' => $rendimientos->count(),
            'fecha_generacion' => now()->format('d/m/Y H:i'),
            'tipo_reporte' => 'GENERAL',
            'competencia' => null,
            'analisisIA' => $analisisIA,
        ];

        Log::info('[PDF] Generando documento PDF...');
        $pdf = Pdf::loadView('pdf.reporte_jugador', $data)->setPaper('a4', 'portrait');
        
        Log::info('[PDF] PDF generado exitosamente');
        return $pdf->stream('reporte_general_jugador_' . $idJugadores . '.pdf');
    }

    public function generarPdfJugadorCompetencias(Request $request, $idJugadores, $idCompetencias)
    {
        //TIMEOUT MÁXIMO DE 180 SEGUNDOS
        set_time_limit(180);
        ini_set('max_execution_time', 180);
        
        Log::info("📄 [PDF] Iniciando PDF competencia {$idCompetencias} para jugador: {$idJugadores}");
        
        $jugador = Jugadores::with([
            'persona.tiposDeDocumentos',
            'categoria',
            'rendimientosPartidos.partido.cronograma.competencia'
        ])->find($idJugadores);

        if (!$jugador) {
            return response()->json(['message' => 'Jugador no encontrado'], 404);
        }

        // Filtrar rendimientos por competencia
        $rendimientos = RendimientosPartidos::with('partido.cronograma.competencia')
            ->where('idJugadores', $idJugadores)
            ->whereHas('partido.cronograma', function($query) use ($idCompetencias) {
                $query->where('idCompetencias', $idCompetencias);
            })
            ->get();

        // Obtener competencia
        $competencia = \App\Models\Competencias::find($idCompetencias);

        // Calcular estadísticas
        if ($rendimientos->isEmpty()) {
            $totales = [
                'Goles' => 0,
                'GolesDeCabeza' => 0,
                'Asistencias' => 0,
                'MinutosJugados' => 0,
                'TirosApuerta' => 0,
                'TarjetasRojas' => 0,
                'TarjetasAmarillas' => 0,
                'FuerasDeLugar' => 0,
                'ArcoEnCero' => 0,
            ];

            $promedios = [
                'GolesPromedio' => 0,
                'AsistenciasPromedio' => 0,
                'TirosPromedio' => 0,
                'MinutosPromedio' => 0,
            ];

            $ultimosPartidos = collect([]);
            $totalPartidos = 0;
        } else {
            $totales = [
                'Goles' => $rendimientos->sum('Goles'),
                'GolesDeCabeza' => $rendimientos->sum('GolesDeCabeza'),
                'Asistencias' => $rendimientos->sum('Asistencias'),
                'MinutosJugados' => $rendimientos->sum('MinutosJugados'),
                'TirosApuerta' => $rendimientos->sum('TirosApuerta'),
                'TarjetasRojas' => $rendimientos->sum('TarjetasRojas'),
                'TarjetasAmarillas' => $rendimientos->sum('TarjetasAmarillas'),
                'FuerasDeLugar' => $rendimientos->sum('FuerasDeLugar'),
                'ArcoEnCero' => $rendimientos->sum('ArcoEnCero'),
            ];

            $totalPartidos = $rendimientos->count();

            $promedios = [
                'GolesPromedio' => round($totales['Goles'] / $totalPartidos, 2),
                'AsistenciasPromedio' => round($totales['Asistencias'] / $totalPartidos, 2),
                'TirosPromedio' => round($totales['TirosApuerta'] / $totalPartidos, 2),
                'MinutosPromedio' => round($totales['MinutosJugados'] / $totalPartidos, 2),
            ];

            $ultimosPartidos = $rendimientos->sortByDesc(function($rendimiento) {
                return $rendimiento->partido->cronograma->FechaDeEventos ?? '';
            })->take(5);
        }

        // GENERAR ANÁLISIS CON IA
        $analisisIA = null;
        if ($totalPartidos > 0) {
            try {
                Log::info('[PDF] Iniciando análisis IA para competencia...');
                
                $iaService = new AnalisisIAService();
                $analisisIA = $iaService->generarAnalisisJugador(
                    $jugador, 
                    $totales, 
                    $promedios, 
                    $totalPartidos, 
                    $ultimosPartidos,
                    $competencia
                );
                
                if ($analisisIA) {
                    Log::info('✅ [PDF] Análisis IA incluido');
                } else {
                    Log::warning('[PDF] No se generó análisis IA');
                }
                
            } catch (\Exception $e) {
                Log::error('[PDF] Error análisis IA: ' . $e->getMessage());
            }
        }

        $data = [
            'jugador' => $jugador,
            'totales' => $totales,
            'promedios' => $promedios,
            'ultimosPartidos' => $ultimosPartidos,
            'totalPartidos' => $totalPartidos,
            'fecha_generacion' => now()->format('d/m/Y H:i'),
            'tipo_reporte' => 'POR COMPETENCIA',
            'competencia' => $competencia,
            'analisisIA' => $analisisIA,
        ];

        $pdf = Pdf::loadView('pdf.reporte_jugador', $data)->setPaper('a4', 'portrait');
        
        $nombreCompetencia = $competencia ? str_replace(' ', '_', $competencia->Nombre) : 'competencia';
        Log::info('[PDF] PDF generado exitosamente');
        
        return $pdf->stream('reporte_' . $nombreCompetencia . 'jugador' . $idJugadores . '.pdf');
    }
}