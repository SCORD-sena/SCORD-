<?php

namespace App\Http\Controllers;
use App\Models\cronogramas;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class cronogramasController extends Controller
{
    public function index()
    {
        $cronogramas = cronogramas::all();

        if ($cronogramas->isEmpty()) {
            return response()->json([
                'message' => 'No se encontraron cronogramas',
                'status' => 404
            ], 404);
        }

        return response()->json($cronogramas, 200);
    }


        public function show($id)
    {
        $cronogramas = cronogramas::find($id);

        if (!$cronogramas) {
            return response()->json([
                'message' => 'cronograma no encontrado',
                'status' => 404
            ], 404);
        }

        return response()->json($cronogramas, 200);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'idCronograma' => 'required|integer',
            'FechaDeEventos' => 'required|date',
            'TipoDeEventos' => 'required|string|max:50',
            'CanchaPartido' => 'nullable|string|max:50',
            'Ubicacion' => 'required|string|max:50',
            'SedeEntrenamiento' => 'nullable|string|max:50',
            'Descripcion' => 'required|string|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

        $cronogramas = cronogramas::create($request->all());

        return response()->json([
            'message' => 'cronograma creado exitosamente',
            'data' => $cronogramas
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $cronogramas = cronogramas::find($id);

        if (!$cronogramas) {
            return response()->json([
                'message' => 'cronograma no encontrado',
                'status' => 404
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'idCronograma' => 'sometimes|integer',
            'FechaDeEventos' => 'sometimes|date',
            'TipoDeEventos' => 'sometimes|string|max:50',
            'CanchaPartido' => 'sometimes|string|max:50',
            'Ubicacion' => 'sometimes|string|max:50',
            'SedeEntrenamiento' => 'sometimes|string|max:50',
            'Descripcion' => 'sometimes|string|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

        $cronogramas->update($request->all());

        return response()->json([
            'message' => 'cronograma actualizado exitosamente',
            'data' => $cronogramas
        ], 200);
    }

        public function destroy($id)
    {
        $cronogramas = cronogramas::find($id);


        if (!$cronogramas) {
            return response()->json([
                'message' => 'no se pudo eliminar el cronograma',
                'status' => 404
            ], 404);
        }
            $cronogramas->delete();

            return response()->json([
                'message' => 'cronograma eliminado exitosamente',
                'status' => 200
            ], 200);
        
    }
}
