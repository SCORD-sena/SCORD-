<?php

namespace App\Http\Controllers;

use App\Models\PartidosEquipos;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class PartidosEquiposController extends Controller
{
    public function index()
    {
        $relaciones = PartidosEquipos::all();

        if ($relaciones->isEmpty()) {
            return response()->json([
                'message' => 'No se encontraron relaciones',
                'status' => 404
            ], 404);
        }

        return response()->json([
            'message' => 'Relaciones encontradas',
            'data' => $relaciones
        ], 200);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'idPartidos' => 'required|integer',
            'idEquipos'  => 'required|integer',
            'EsLocal'    => 'required|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

        $relacion = PartidosEquipos::create($request->only([
            'idPartidos',
            'idEquipos',
            'EsLocal'
        ]));

        return response()->json([
            'message' => 'Relación creada exitosamente',
            'data' => $relacion->refresh()
        ], 201);
    }

    public function update(Request $request, $idPartidos, $idEquipos)
    {
        $relacion = PartidosEquipos::where('idPartidos', $idPartidos)
                                   ->where('idEquipos', $idEquipos)
                                   ->first();

        if (!$relacion) {
            return response()->json([
                'message' => 'Relación no encontrada',
                'status' => 404
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'EsLocal' => 'sometimes|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

        $relacion->update($request->only([
            'EsLocal'
        ]));

        return response()->json([
            'message' => 'Relación actualizada exitosamente',
            'data' => $relacion->refresh()
        ], 200);
    }

    public function destroy($idPartidos, $idEquipos)
    {
        $deleted = PartidosEquipos::where('idPartidos', $idPartidos)
                                  ->where('idEquipos', $idEquipos)
                                  ->delete();

        if ($deleted === 0) {
            return response()->json([
                'message' => 'Relación no encontrada',
                'status' => 404
            ], 404);
        }

        return response()->json([
            'message' => 'Relación eliminada exitosamente',
            'deleted_rows' => $deleted
        ], 200);
    }
}