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
            'FechaDeEventos' => 'required|date',
            'TipoDeEventos' => 'required|string|max:50',
            'CanchaPartido' => 'nullable|string|max:50',
            'Ubicacion' => 'required|string|max:50',
            'SedeEntrenamiento' => 'nullable|string|max:50',
            'Descripcion' => 'required|string|max:100',
            'idCategorias' => 'required|integer|exists:Categorias,idCategorias'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

        // Crear el cronograma (el ID se genera automáticamente)
        $cronogramas = cronogramas::create($request->only([
            'FechaDeEventos' => $request->FechaDeEventos,
            'TipoDeEventos' => $request->TipoDeEventos,
            'CanchaPartido' => $request->CanchaPartido,
            'Ubicacion' => $request->Ubicacion,
            'SedeEntrenamiento' => $request->SedeEntrenamiento,
            'Descripcion' => $request->Descripcion,
            'idCategorias' => $request->idCategorias
        ]));

        $cronogramas->refresh(); // Refrescar para obtener el ID generado   

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
            // Para UPDATE, no validar el ID tampoco
            'FechaDeEventos' => 'sometimes|date',
            'TipoDeEventos' => 'sometimes|string|max:50',
            'CanchaPartido' => 'nullable|string|max:50',
            'Ubicacion' => 'sometimes|string|max:50',
            'SedeEntrenamiento' => 'nullable|string|max:50',
            'Descripcion' => 'sometimes|string|max:100',
            'idCategorias' => 'sometimes|integer|exists:Categorias,idCategorias'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

        // Actualizar solo los campos enviados (sin el ID)
        $cronogramas->update($request->only([
            'FechaDeEventos',
            'TipoDeEventos', 
            'CanchaPartido',
            'Ubicacion',
            'SedeEntrenamiento',
            'Descripcion',
            'idCategorias' => $request->idCategorias
        ]));

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