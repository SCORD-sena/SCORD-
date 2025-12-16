<?php

namespace App\Http\Controllers;

use App\Models\cronogramas;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class CronogramasController extends Controller
{
    /**
     * Listar cronogramas activos (no eliminados)
     */
    public function index()
    {
        $cronogramas = cronogramas::all();

        // ====== CAMBIO: Devolver array vacío en lugar de 404 ======
        if ($cronogramas->isEmpty()) {
            return response()->json([], 200); // ← Array vacío con status 200
        }

        return response()->json($cronogramas, 200);
    }

    /**
     * NUEVO: Listar cronogramas eliminados (papelera)
     */
    public function trashed()
    {
        $cronogramas = cronogramas::onlyTrashed()->get();

        if ($cronogramas->isEmpty()) {
            return response()->json([
                'message' => 'No hay cronogramas eliminados',
                'status' => 404
            ], 404);
        }

        return response()->json([
            'data' => $cronogramas,
            'status' => 200
        ], 200);
    }

    public function show($id)
    {
        $cronogramas = cronogramas::find($id);

        if (!$cronogramas) {
            return response()->json([
                'message' => 'Cronograma no encontrado',
                'status' => 404
            ], 404);
        }

        return response()->json($cronogramas, 200);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'FechaDeEventos' => 'required|date',
            'Hora' => 'nullable|date_format:H:i:s', // ← NUEVO: formato 24h (HH:MM:SS)
            'TipoDeEventos' => 'required|string|max:50',
            'CanchaPartido' => 'nullable|string|max:50',
            'Ubicacion' => 'required|string|max:50',
            'SedeEntrenamiento' => 'nullable|string|max:50',
            'Descripcion' => 'required|string|max:100',
            'idCategorias' => 'required|integer|exists:categorias,idCategorias',
            'idCompetencias' => 'nullable|integer|exists:competencias,idCompetencias'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

        $cronogramas = cronogramas::create([
            'FechaDeEventos' => $request->FechaDeEventos,
            'Hora' => $request->Hora, // ← NUEVO
            'TipoDeEventos' => $request->TipoDeEventos,
            'CanchaPartido' => $request->CanchaPartido,
            'Ubicacion' => $request->Ubicacion,
            'SedeEntrenamiento' => $request->SedeEntrenamiento,
            'Descripcion' => $request->Descripcion,
            'idCategorias' => $request->idCategorias,
            'idCompetencias' => $request->idCompetencias
        ]);

        $cronogramas->refresh();

        return response()->json([
            'message' => 'Cronograma creado exitosamente',
            'data' => $cronogramas
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $cronogramas = cronogramas::find($id);

        if (!$cronogramas) {
            return response()->json([
                'message' => 'Cronograma no encontrado',
                'status' => 404
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'FechaDeEventos' => 'sometimes|date',
            'Hora' => 'nullable|date_format:H:i:s', // ← NUEVO
            'TipoDeEventos' => 'sometimes|string|max:50',
            'CanchaPartido' => 'nullable|string|max:50',
            'Ubicacion' => 'sometimes|string|max:50',
            'SedeEntrenamiento' => 'nullable|string|max:50',
            'Descripcion' => 'sometimes|string|max:100',
            'idCategorias' => 'sometimes|integer|exists:categorias,idCategorias',
            'idCompetencias' => 'nullable|integer|exists:competencias,idCompetencias'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

        $cronogramas->update($request->only([
            'FechaDeEventos',
            'Hora', // ← NUEVO
            'TipoDeEventos', 
            'CanchaPartido',
            'Ubicacion',
            'SedeEntrenamiento',
            'Descripcion',
            'idCategorias',
            'idCompetencias'
        ]));

        return response()->json([
            'message' => 'Cronograma actualizado exitosamente',
            'data' => $cronogramas
        ], 200);
    }

    /**
     * MODIFICADO: Eliminar cronograma (soft delete)
     */
    public function destroy($id)
    {
        $cronogramas = cronogramas::find($id);

        if (!$cronogramas) {
            return response()->json([
                'message' => 'Cronograma no encontrado',
                'status' => 404
            ], 404);
        }
        
        // Soft delete - solo pone fecha en deleted_at
        $cronogramas->delete();

        return response()->json([
            'message' => 'Cronograma eliminado correctamente (movido a papelera)',
            'status' => 200
        ], 200);
    }

    /**
     * NUEVO: Restaurar cronograma eliminado
     */
    public function restore($id)
    {
        $cronogramas = cronogramas::onlyTrashed()->find($id);

        if (!$cronogramas) {
            return response()->json([
                'message' => 'Cronograma no encontrado en papelera',
                'status' => 404
            ], 404);
        }

        $cronogramas->restore();

        return response()->json([
            'message' => 'Cronograma restaurado correctamente',
            'data' => $cronogramas,
            'status' => 200
        ], 200);
    }

    /**
     * NUEVO: Eliminar permanentemente
     */
    public function forceDelete($id)
    {
        $cronogramas = cronogramas::onlyTrashed()->find($id);

        if (!$cronogramas) {
            return response()->json([
                'message' => 'Cronograma no encontrado en papelera',
                'status' => 404
            ], 404);
        }

        $cronogramas->forceDelete(); // Eliminación permanente

        return response()->json([
            'message' => 'Cronograma eliminado permanentemente',
            'status' => 200
        ], 200);
    }

    /**
     * Obtener cronogramas filtrados por competencia y categoría
     */
    public function getCronogramasByCompetenciaYCategoria($idCompetencias, $idCategorias)
    {
        $cronogramas = cronogramas::where('idCompetencias', $idCompetencias)
                                  ->where('idCategorias', $idCategorias)
                                  ->get();

        if ($cronogramas->isEmpty()) {
            return response()->json([
                'message' => 'No se encontraron cronogramas para esta competencia y categoría',
                'status' => 404
            ], 404);
        }

        return response()->json($cronogramas, 200);
    }
}