<?php

namespace App\Http\Controllers;

use App\Models\Jugadores;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;

class JugadoresController extends Controller
{
    public function index()
    {
        $jugadores = Jugadores::all();
        if ($jugadores->isEmpty()) {
            return response()->json(['message' => 'No se encontraron jugadores'], 404);
        }
        return response()->json(['data' => $jugadores], 200);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'Dorsal' => 'required|integer',
            'Posicion' => 'required|string|max:25',
            'upz' => 'nullable|string|max:40',
            'Estatura' => 'nullable|numeric',
            'NomTutor1' => 'required|string|max:30',
            'NomTutor2' => 'nullable|string|max:30',
            'ApeTutor1' => 'required|string|max:30',
            'ApeTutor2' => 'required|string|max:30',
            'TelefonoTutor' => 'required|integer',
            'idCategorias' => 'required|integer|exists:Categorias,idCategorias',
            'idPersonas' => 'required|integer|exists:Personas,idPersonas',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $jugador = Jugadores::create($request->all());

        return response()->json(['data' => $jugador], 201);
    }

    public function show($id)
    {
        $jugador = Jugadores::find($id);

        if (!$jugador) {
            return response()->json(['message' => 'Jugador no encontrado'], 404);
        }

        return response()->json(['data' => $jugador], 200);
    }

    public function update(Request $request, $id)
    {
        $jugador = Jugadores::find($id);

        if (!$jugador) {
            return response()->json(['message' => 'Jugador no encontrado'], 404);
        }

        $validator = Validator::make($request->all(), [
            'Dorsal' => 'sometimes|integer',
            'Posicion' => 'sometimes|string|max:25',
            'upz' => 'sometimes|string|max:40',
            'Estatura' => 'sometimes|numeric',
            'NomTutor1' => 'sometimes|string|max:30',
            'NomTutor2' => 'sometimes|string|max:30',
            'ApeTutor1' => 'sometimes|string|max:30',
            'ApeTutor2' => 'sometimes|string|max:30',
            'TelefonoTutor' => 'sometimes|integer',
            'idCategorias' => 'sometimes|integer|exists:Categorias,idCategorias',
            'idPersonas' => 'sometimes|integer|exists:Personas,idPersonas',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $jugador->update($request->all());

        return response()->json(['data' => $jugador], 200);
    }

    public function destroy($id)
    {
        $jugador = Jugadores::find($id);

        if (!$jugador) {
            return response()->json(['message' => 'Jugador no encontrado'], 404);
        }

        $jugador->delete();

        return response()->json(['message' => 'Jugador eliminado'], 200);
    }

    public function rendimientos($id)
    {
        try {
            $jugador = Jugadores::find($id);

            if (!$jugador) {
                return response()->json(['message' => 'Jugador no encontrado'], 404);
            }

            $estadisticas = DB::table('rendimientospartidos')
                ->where('idjugadores', $id)
                ->selectRaw('
                    COALESCE(SUM(Goles), 0) as goles,
                    COALESCE(SUM(GolesDeCabeza), 0) as goles_cabeza,
                    COALESCE(SUM(MinutosJugados), 0) as minutos_jugados,
                    COALESCE(SUM(Asistencias), 0) as asistencias,
                    COALESCE(SUM(TirosApuerta), 0) as tiros_puerta,
                    COALESCE(SUM(TarjetasRojas), 0) as tarjetas_rojas,
                    COALESCE(SUM(TarjetasAmarillas), 0) as tarjetas_amarillas,
                    COALESCE(SUM(FuerasDeLugar), 0) as fueras_juego,
                    COALESCE(SUM(ArcoEnCero), 0) as arco_cero,
                    COALESCE(COUNT(DISTINCT idPartidos), 0) as partidos_jugados
                ')
                ->first();

            return response()->json([
                'data' => [
                    'jugador_id' => $jugador->idjugadores,
                    'nombre' => 'Dorsal ' . $jugador->Dorsal . ' - ' . $jugador->NomTutor1,
                    'estadisticas' => $estadisticas
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    // 🚀 Nuevo método para comparar jugadores
    public function compararJugadores(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'ids' => 'required|array',
            'ids.*' => 'integer|exists:Jugadores,idJugadores',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $ids = $request->input('ids');

        $jugadores = Jugadores::whereIn('idJugadores', $ids)->get();

        $resultado = $jugadores->map(function ($jugador) {
            $estadisticas = DB::table('rendimientospartidos')
                ->where('idJugadores', $jugador->idJugadores)
                ->selectRaw('
                    COALESCE(SUM(Goles), 0) as goles,
                    COALESCE(SUM(GolesDeCabeza), 0) as goles_cabeza,
                    COALESCE(SUM(MinutosJugados), 0) as minutos_jugados,
                    COALESCE(SUM(Asistencias), 0) as asistencias,
                    COALESCE(SUM(TirosApuerta), 0) as tiros_puerta,
                    COALESCE(SUM(TarjetasRojas), 0) as tarjetas_rojas,
                    COALESCE(SUM(TarjetasAmarillas), 0) as tarjetas_amarillas,
                    COALESCE(SUM(FuerasDeLugar), 0) as fueras_juego,
                    COALESCE(SUM(ArcoEnCero), 0) as arco_cero,
                    COALESCE(COUNT(DISTINCT idPartidos), 0) as partidos_jugados
                ')
                ->first();

            return [
                'jugador_id' => $jugador->idJugadores,
                'nombre' => 'Dorsal ' . $jugador->Dorsal . ' - ' . $jugador->NomTutor1,
                'estadisticas' => $estadisticas
            ];
        });

        return response()->json(['data' => $resultado], 200);
    }
}
