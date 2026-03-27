<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Barryvdh\DomPDF\Facade\Pdf;
use App\Models\Jugadores;
use App\Models\RendimientosPartidos;
use App\Models\Entrenadores;

class ReporteController extends Controller
{
    public function generarPdfJugador(Request $request, $idJugadores)
    {
        // ============ 1) Cargar jugador con todas las relaciones =================
        $jugador = Jugadores::with([
            'persona.tiposDeDocumentos',
            'categoria',
            'rendimientosPartidos.partido'
        ])->find($idJugadores);

        if (!$jugador) {
            return response()->json(['message' => 'Jugador no encontrado'], 404);
        }

        // ============ 2) Obtener rendimientos =================
        $rendimientos = $jugador->rendimientosPartidos;

        // ============ 3) Calcular totales =================
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

        // ============ 4) Calcular promedios =================
        $totalPartidos = max(1, $rendimientos->count());

        $promedios = [
            'GolesPromedio' => round($totales['Goles'] / $totalPartidos, 2),
            'AsistenciasPromedio' => round($totales['Asistencias'] / $totalPartidos, 2),
            'TirosPromedio' => round($totales['TirosApuerta'] / $totalPartidos, 2),
            'MinutosPromedio' => round($totales['MinutosJugados'] / $totalPartidos, 2),
        ];

        // ============ 5) Obtener últimos 5 partidos =================
        $ultimosPartidos = $rendimientos
            ->sortByDesc('IdRendimientos')
            ->take(5);

        // ============ 6) Datos para PDF =================
        $data = [
            'jugador' => $jugador,
            'totales' => $totales,
            'promedios' => $promedios,
            'ultimosPartidos' => $ultimosPartidos,
            'totalPartidos' => $rendimientos->count(),
            'fecha_generacion' => now()->format('d/m/Y H:i'),
        ];

        // ============ 7) Generar PDF =================
        $pdf = Pdf::loadView('pdf.reporte_jugador', $data)
                  ->setPaper('a4', 'portrait');

        return $pdf->stream('reporte_jugador_' . $idJugadores . '.pdf');
    }
}