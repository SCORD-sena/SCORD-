<?php

namespace App\Http\Controllers;

use App\Models\Competencias;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class CompetenciasController extends Controller
{
    /**
     * Listar competencias activas (no eliminadas)
     */
    public function index()
    {
        $competencias = Competencias::all();

        // ====== CAMBIO: Devolver array vacío en lugar de 404 ======
        if ($competencias->isEmpty()) {
            return response()->json([], 200); // ← Array vacío con status 200
        }

        return response()->json($competencias, 200);
    }

    /**
     * NUEVO: Listar competencias eliminadas (papelera)
     */
    public function trashed()
    {
        $competencias = Competencias::onlyTrashed()->get();

        if ($competencias->isEmpty()) {
            return response()->json([
                'message' => 'No hay competencias eliminadas',
                'status' => 404
            ], 404);
        }

        return response()->json([
            'data' => $competencias,
            'status' => 200
        ], 200);
    }

    public function show($id)
    {
        $competencia = Competencias::find($id);

        if (!$competencia) {
            return response()->json([
                'message' => 'Competencia no encontrada',
                'status' => 404
            ], 404);
        }

        return response()->json($competencia, 200);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'Nombre' => 'required|string|max:50',
            'TipoCompetencia' => 'required|string|max:30',
            'Ano' => 'required|integer',
            'idEquipos' => 'required|integer|exists:Equipos,idEquipos',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

        $competencia = Competencias::create($request->all());

        return response()->json([
            'message' => 'Competencia creada exitosamente',
            'data' => $competencia
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $competencia = Competencias::find($id);

        if (!$competencia) {
            return response()->json([
                'message' => 'Competencia no encontrada',
                'status' => 404
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'Nombre' => 'sometimes|string|max:50',
            'TipoCompetencia' => 'sometimes|string|max:30',
            'Ano' => 'sometimes|integer',
            'idEquipos' => 'sometimes|integer|exists:Equipos,idEquipos',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

        $competencia->update($request->all());

        return response()->json([
            'message' => 'Competencia actualizada exitosamente',
            'data' => $competencia
        ], 200);
    }

    /**
     * MODIFICADO: Eliminar competencia (soft delete)
     */
    public function destroy($id)
    {
        $competencia = Competencias::find($id);

        if (!$competencia) {
            return response()->json([
                'message' => 'Competencia no encontrada',
                'status' => 404
            ], 404);
        }

        // Soft delete - solo pone fecha en deleted_at
        $competencia->delete();

        return response()->json([
            'message' => 'Competencia eliminada correctamente (movida a papelera)',
            'status' => 200
        ], 200);
    }

    /**
     * NUEVO: Restaurar competencia eliminada
     */
    public function restore($id)
    {
        $competencia = Competencias::onlyTrashed()->find($id);

        if (!$competencia) {
            return response()->json([
                'message' => 'Competencia no encontrada en papelera',
                'status' => 404
            ], 404);
        }

        $competencia->restore();

        return response()->json([
            'message' => 'Competencia restaurada correctamente',
            'data' => $competencia,
            'status' => 200
        ], 200);
    }

    /**
     * NUEVO: Eliminar permanentemente
     */
    public function forceDelete($id)
    {
        $competencia = Competencias::onlyTrashed()->find($id);

        if (!$competencia) {
            return response()->json([
                'message' => 'Competencia no encontrada en papelera',
                'status' => 404
            ], 404);
        }

        $competencia->forceDelete(); // Eliminación permanente

        return response()->json([
            'message' => 'Competencia eliminada permanentemente',
            'status' => 200
        ], 200);
    }

    public function getCompetenciasByCategoria($idCategorias)
    {
        // 1. Buscar competencias que YA tienen cronogramas en esta categoría específica
        $competenciasUsadas = Competencias::whereHas('cronogramas', function($query) use ($idCategorias) {
            $query->where('idCategorias', $idCategorias);
        })->distinct()->get();

        // 2. Buscar competencias que NO han sido usadas en NINGUNA categoría todavía
        $competenciasNuevas = Competencias::doesntHave('cronogramas')->get();

        // 3. Combinar ambas listas (usadas en esta categoría + nuevas sin usar)
        $competencias = $competenciasUsadas->merge($competenciasNuevas);

        return response()->json($competencias, 200);
    }
}