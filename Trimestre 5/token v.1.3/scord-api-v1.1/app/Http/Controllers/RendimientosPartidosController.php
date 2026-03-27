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

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'idRendimientosP' => 'required|integer',
            'Goles' => 'nullable|integer',
            'GolesDeCabeza' => 'nullable|integer',
            'MinutosJugados' => 'nullable|integer',
            'Asistencias' => 'nullable|integer',
            'TirosApuerta' => 'nullable|integer',
            'TarjetasRojas' => 'nullable|integer',
            'TarjetasAmarillas' => 'nullable|integer',
            'FuerasDeLugar' => 'nullable|string|max:45',
            'ArcoEnCero' => 'nullable|integer',
            'idPartido' => 'required|integer',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

        $RendimientosPartidos = RendimientosPartidos::create($request->all());

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
            'idRendimientosP' => 'sometimes|integer',
            'Goles' => 'sometimes|integer',
            'GolesDeCabeza' => 'sometimes|integer',
            'MinutosJugados' => 'sometimes|integer',
            'Asistencias' => 'sometimes|integer',
            'TirosApuerta' => 'sometimes|integer',
            'TarjetasRojas' => 'sometimes|integer',
            'TarjetasAmarillas' => 'sometimes|integer',
            'FuerasDeLugar' => 'sometimes|string|max:45',
            'ArcoEnCero' => 'sometimes|integer',
            'idPartido' => 'sometimes|integer',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

        $RendimientosPartidos->update($request->all());

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