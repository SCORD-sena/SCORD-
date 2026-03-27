<?php

namespace App\Http\Controllers;

use App\Models\Competencias;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class CompetenciasController extends Controller
{
    /**
     * Listar competencias con filtros y paginación
     */
   public function index(Request $request)
{
    $query = Competencias::with('cronogramas.categoria');

    if ($request->filled('nombre')) {
        $query->where('Nombre', 'LIKE', '%' . $request->nombre . '%');
    }
    if ($request->filled('tipo')) {
        $query->where('TipoCompetencia', 'LIKE', '%' . $request->tipo . '%');
    }
    if ($request->filled('ano')) {
        $query->where('Ano', $request->ano);
    }
    if ($request->filled('idCategorias')) {
        $query->whereHas('cronogramas', function ($q) use ($request) {
            $q->where('idCategorias', $request->idCategorias);
        });
    }

    $camposPermitidos = ['idCompetencias', 'Nombre', 'TipoCompetencia', 'Ano'];
    $sortBy    = in_array($request->get('sort_by'), $camposPermitidos) ? $request->get('sort_by') : 'idCompetencias';
    $sortOrder = $request->get('sort_order', 'asc') === 'desc' ? 'desc' : 'asc';
    $query->orderBy($sortBy, $sortOrder);

    $competencias = $query->paginate(10);

    return response()->json([
        'data' => $competencias->items(),
        'meta' => [
            'total'     => $competencias->total(),
            'last_page' => $competencias->lastPage(),
            'page'      => $competencias->currentPage(),
        ]
    ], 200);
}

    /**
     * Competencias en papelera
     */
    public function trashed()
    {
        $competencias = Competencias::onlyTrashed()->get();

        if ($competencias->isEmpty()) {
            return response()->json([
                'message' => 'No hay competencias eliminadas'
            ], 404);
        }

        return response()->json(['data' => $competencias], 200);
    }

    /**
     * Ver una competencia
     */
    public function show($id)
    {
        $competencia = Competencias::find($id);

        if (!$competencia) {
            return response()->json([
                'message' => 'Competencia no encontrada'
            ], 404);
        }

        return response()->json($competencia, 200);
    }

    /**
     * Crear competencia
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'Nombre'          => 'required|string|max:50',
            'TipoCompetencia' => 'required|string|max:30',
            'Ano'             => 'required|integer|min:1900|max:2100',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors'  => $validator->errors()
            ], 422);
        }

        $competencia = Competencias::create(
            $request->only(['Nombre', 'TipoCompetencia', 'Ano'])
        );

        return response()->json([
            'message' => 'Competencia creada exitosamente',
            'data'    => $competencia
        ], 201);
    }

    /**
     * Actualizar competencia
     */
    public function update(Request $request, $id)
    {
        $competencia = Competencias::find($id);

        if (!$competencia) {
            return response()->json([
                'message' => 'Competencia no encontrada'
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'Nombre'          => 'sometimes|string|max:50',
            'TipoCompetencia' => 'sometimes|string|max:30',
            'Ano'             => 'sometimes|integer|min:1900|max:2100',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors'  => $validator->errors()
            ], 422);
        }

        $competencia->update(
            $request->only(['Nombre', 'TipoCompetencia', 'Ano'])
        );

        return response()->json([
            'message' => 'Competencia actualizada exitosamente',
            'data'    => $competencia
        ], 200);
    }

    /**
     * Soft delete
     */
    public function destroy($id)
    {
        $competencia = Competencias::find($id);

        if (!$competencia) {
            return response()->json([
                'message' => 'Competencia no encontrada'
            ], 404);
        }

        $competencia->delete();

        return response()->json([
            'message' => 'Competencia movida a papelera'
        ], 200);
    }

    /**
     * Restaurar competencia
     */
    public function restore($id)
    {
        $competencia = Competencias::onlyTrashed()->find($id);

        if (!$competencia) {
            return response()->json([
                'message' => 'Competencia no encontrada en papelera'
            ], 404);
        }

        $competencia->restore();

        return response()->json([
            'message' => 'Competencia restaurada correctamente',
            'data'    => $competencia
        ], 200);
    }

    /**
     * Eliminar permanentemente
     */
    public function forceDelete($id)
    {
        $competencia = Competencias::onlyTrashed()->find($id);

        if (!$competencia) {
            return response()->json([
                'message' => 'Competencia no encontrada en papelera'
            ], 404);
        }

        $competencia->forceDelete();

        return response()->json([
            'message' => 'Competencia eliminada permanentemente'
        ], 200);
    }

    /**
     * Competencias disponibles para una categoría específica
     * (puente a través de Cronogramas)
     */
    public function getCompetenciasByCategoria($idCategorias)
    {
        try {
            // Las que ya tienen cronograma en esta categoría
            $usadas = Competencias::whereHas('cronogramas', function ($q) use ($idCategorias) {
                $q->where('idCategorias', $idCategorias);
            })->get();

            // Las que aún no tienen ningún cronograma
            $nuevas = Competencias::doesntHave('cronogramas')->get();

            $result = $usadas
                ->merge($nuevas)
                ->unique('idCompetencias')
                ->values();

            return response()->json($result, 200);

        } catch (\Exception $e) {
            \Log::error('Error en getCompetenciasByCategoria: ' . $e->getMessage());

            return response()->json([
                'message' => 'Error al obtener competencias',
                'error'   => $e->getMessage()
            ], 500);
        }
    }
}