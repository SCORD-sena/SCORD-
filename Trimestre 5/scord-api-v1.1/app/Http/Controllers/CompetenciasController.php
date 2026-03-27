<?php

namespace App\Http\Controllers;
use App\Models\Competencias;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;


class CompetenciasController extends Controller
{
    public function index()
    {
        $Competencias = Competencias::all();

        if ($Competencias->isEmpty()) {
            return response()->json([
                'message' => 'No se encontraron competencias',
                'status' => 404
            ], 404);
        }

        return response()->json($Competencias, 200);
    }

        public function show($id)
    {
        $Competencias = Competencias::find($id);

        if (!$Competencias) {
            return response()->json([
                'message' => 'Competencia no encontrada',
                'status' => 404
            ], 404);
        }

        return response()->json($Competencias, 200);
    }

    public function store (Request $request)
    {
        $validator = Validator::make($request->all(), [
            'Nombre' => 'required|string|max:30',
            'TipoCompetencia' => 'required|string|max:50',
            'Año' => 'required|integer',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

        $Competencias = Competencias::create($request->all());

        return response()->json([
            'message' => 'Competencia creada exitosamente',
            'data' => $Competencias
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $Competencias = Competencias::find($id);

        if (!$Competencias) {
            return response()->json([
                'message' => 'Competencia no encontrada',
                'status' => 404
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'Nombre' => 'sometimes|string|max:30',
            'TipoCompetencia' => 'sometimes|string|max:50',
            'Año' => 'sometimes|integer',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

        $Competencias->update($request->all());

        return response()->json([
            'message' => 'Competencia actualizada exitosamente',
            'data' => $Competencias
        ], 200);
    }

    public function destroy($id)
    {
        $Competencias = Competencias::find($id);

        if (!$Competencias) {
            return response()->json([
                'message' => 'no se pudo eliminar la competencia',
                'status' => 404
            ], 404);
        }

        $Competencias->delete();

        return response()->json([
                'message' => 'competencia eliminada exitosamente',
                'status' => 200
            ], 200);
        
    }
}