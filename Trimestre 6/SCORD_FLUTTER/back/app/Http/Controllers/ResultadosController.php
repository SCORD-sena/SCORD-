<?php

namespace App\Http\Controllers;
use App\Models\Resultados;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ResultadosController extends Controller
{
    public function index()
    {
        $Resultados = Resultados::all();

        if ($Resultados->isEmpty()) {
            return response()->json([
                'message' => 'No se encontraron resultados',
                'status' => 404
            ], 404);
        }

        return response()->json($Resultados, 200);
    }

    public function show($id)
    {
        $Resultados = Resultados::find($id);

        if (!$Resultados) {
            return response()->json([
                'message' => 'Resultado no encontrado',
                'status' => 404
            ], 404);
        }

        return response()->json($Resultados, 200);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'Marcador' => 'required|string|max:10',
            'PuntosObtenidos' => 'required|integer',
            'Observacion' => 'nullable|string|max:100',
            'idPartidos' => 'required|integer|exists:Partidos,idPartidos',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

        $Resultados = Resultados::create($request->only([
            'Marcador',
            'PuntosObtenidos',
            'Observacion',
            'idPartidos'
        ]));

        $Resultados->refresh();

        return response()->json([
            'message' => 'Resultado creado exitosamente',
            'data' => $Resultados
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $Resultados = Resultados::find($id);

        if (!$Resultados) {
            return response()->json([
                'message' => 'Resultado no encontrado',
                'status' => 404
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'Marcador' => 'sometimes|required|string|max:10',
            'PuntosObtenidos' => 'sometimes|required|integer',
            'Observacion' => 'sometimes|string|max:100',
            'idPartidos' => 'sometimes|required|integer|exists:Partidos,idPartidos',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

        $Resultados->update($request->only([
            'Marcador',
            'PuntosObtenidos',
            'Observacion',
            'idPartidos'
        ]));

        return response()->json([
            'message' => 'Resultado actualizado exitosamente',
            'data' => $Resultados
        ], 200);
    }

    public function destroy($id)
    {
        $Resultados = Resultados::find($id);

        if (!$Resultados) {
            return response()->json([
                'message' => 'Resultado no encontrado',
                'status' => 404
            ], 404);
        }

        $Resultados->delete();

        return response()->json([
            'message' => 'Resultado eliminado exitosamente'
        ], 200);
    }
}
