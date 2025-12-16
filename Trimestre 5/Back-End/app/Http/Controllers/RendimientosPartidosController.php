<?php

namespace App\Http\Controllers;

use App\Models\RendimientosPartidos;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class RendimientosPartidosController extends Controller
{
    public function index()
    {
        $rendimientos = RendimientosPartidos::all();

        if ($rendimientos->isEmpty()) {
            return response()->json([
                'message' => 'No se encontraron rendimientos de partidos'
            ], 404);
        }

        return response()->json(['data' => $rendimientos], 200);
    }

    public function show($id)
    {
        $rendimiento = RendimientosPartidos::find($id);

        if (!$rendimiento) {
            return response()->json([
                'message' => 'Rendimiento de partido no encontrado'
            ], 404);
        }

        return response()->json(['data' => $rendimiento], 200);
    }

    public function store(Request $request)
    {
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
            'idJugadores' => 'required|integer|exists:Jugadores,idJugadores'
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $rendimiento = RendimientosPartidos::create($request->all());

        return response()->json([
            'message' => 'Rendimiento creado exitosamente',
            'data' => $rendimiento
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $rendimiento = RendimientosPartidos::find($id);

        if (!$rendimiento) {
            return response()->json(['message' => 'Rendimiento no encontrado'], 404);
        }

        $validator = Validator::make($request->all(), [
            'Goles' => 'sometimes|integer',
            'GolesDeCabeza' => 'sometimes|integer',
            'MinutosJugados' => 'sometimes|integer',
            'Asistencias' => 'sometimes|integer',
            'TirosApuerta' => 'sometimes|integer',
            'TarjetasRojas' => 'sometimes|integer',
            'TarjetasAmarillas' => 'sometimes|integer',
            'FuerasDeLugar' => 'sometimes|integer',
            'ArcoEnCero' => 'sometimes|integer',
            'idPartidos' => 'sometimes|integer|exists:Partidos,idPartidos',
            'idJugadores' => 'sometimes|integer|exists:Jugadores,idJugadores'
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $rendimiento->update($request->all());

        return response()->json([
            'message' => 'Rendimiento actualizado',
            'data' => $rendimiento
        ], 200);
    }

    public function destroy($id)
    {
        $rendimiento = RendimientosPartidos::find($id);

        if (!$rendimiento) {
            return response()->json(['message' => 'Rendimiento no encontrado'], 404);
        }

        $rendimiento->delete();

        return response()->json(['message' => 'Rendimiento eliminado'], 200);
    }
}
