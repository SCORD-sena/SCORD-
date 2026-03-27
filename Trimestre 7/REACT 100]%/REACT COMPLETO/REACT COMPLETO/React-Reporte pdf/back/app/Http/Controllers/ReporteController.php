<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Barryvdh\DomPDF\Facade\Pdf;
use App\Models\Jugadores;
use App\Models\RendimientosPartidos;

class ReporteController extends Controller
{
    /**
     * Generar reporte PDF GENERAL del jugador
     */
    public function generarPdfJugador(Request $request, $idJugadores)
    {
        $jugador = Jugadores::with([
            'persona.tiposDeDocumentos',
            'categoria',
            'rendimientosPartidos.partido.cronogramas' // ← Correcto
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
        $ultimosPartidos = RendimientosPartidos::with('partido.cronogramas')
            ->where('idJugadores', $idJugadores)
            ->join('partidos', 'rendimientospartidos.idPartidos', '=', 'partidos.idPartidos')
            ->join('cronogramas', 'partidos.idCronogramas', '=', 'cronogramas.idCronogramas')
            ->orderByDesc('cronogramas.FechaDeEventos') // ← Usar FechaDeEventos del cronograma
            ->limit(5)
            ->select('rendimientospartidos.*')
            ->get();

        $data = [
            'jugador' => $jugador,
            'totales' => $totales,
            'promedios' => $promedios,
            'ultimosPartidos' => $ultimosPartidos,
            'totalPartidos' => $rendimientos->count(),
            'fecha_generacion' => now()->format('d/m/Y H:i'),
            'tipo_reporte' => 'GENERAL',
            'competencia' => null,
        ];

        $pdf = Pdf::loadView('pdf.reporte_jugador', $data)->setPaper('a4', 'portrait');
        return $pdf->stream('reporte_general_jugador_' . $idJugadores . '.pdf');
    }

    /**
     * Generar reporte PDF POR COMPETENCIA
     */
    public function generarPdfJugadorCompetencias(Request $request, $idJugadores, $idCompetencias)
{
    $jugador = Jugadores::with([
        'persona.tiposDeDocumentos',
        'categoria',
        'rendimientosPartidos.partido.cronogramas.competencia'
    ])->find($idJugadores);

    if (!$jugador) {
        return response()->json(['message' => 'Jugador no encontrado'], 404);
    }

    // Filtrar rendimientos por competencia
    $rendimientos = RendimientosPartidos::with('partido.cronogramas.competencia')
        ->where('idJugadores', $idJugadores)
        ->whereHas('partido.cronogramas', function($query) use ($idCompetencias) {
    $query->where('idCompetencias', $idCompetencias);
})
->get();

//Obtener competencia aunque no haya rendimientos
$competencia = \App\Models\Competencias::find($idCompetencias);

    


    // 🆕 Si no hay rendimientos, generar con estadísticas en 0
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

        $ultimosPartidos = collect([]); // Colección vacía
        $totalPartidos = 0;
    } else {
        // Calcular estadísticas normales
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

        // Ordenar por fecha
        $ultimosPartidos = $rendimientos->sortByDesc(function($rendimiento) {
            return $rendimiento->partido->cronogramas->FechaDeEventos ?? '';
        })->take(5);
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
    ];

    $pdf = Pdf::loadView('pdf.reporte_jugador', $data)->setPaper('a4', 'portrait');
    
    $nombreCompetencia = $competencia ? str_replace(' ', '_', $competencia->Nombre) : 'competencia';
    return $pdf->stream('reporte_' . $nombreCompetencia . '_jugador_' . $idJugadores . '.pdf');
}
}