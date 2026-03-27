<?php

namespace App\Http\Controllers;

use App\Models\Competencias;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class CompetenciasController extends Controller
{
    // ============================================
    // 📋 LISTAR COMPETENCIAS CON FILTROS Y PAGINACIÓN
    // ============================================
    public function index(Request $request)
    {
        try {
            // 🔧 Cargar relación con categorías
            $query = Competencias::with('categoria');
            
            // ✅ FILTROS
            if ($request->filled('nombre')) {
                $query->where('Nombre', 'like', '%' . $request->nombre . '%');
            }
            
            if ($request->filled('tipo')) {
                $query->where('TipoCompetencia', 'like', '%' . $request->tipo . '%');
            }
            
            if ($request->filled('ano')) {
                $query->where('Ano', $request->ano);
            }
            
            if ($request->filled('idCategorias')) {
                $query->where('idCategorias', $request->idCategorias);
            }
            
            // ✅ ORDENAMIENTO
            $sortBy = $request->get('sort_by', 'idCompetencias');
            $sortOrder = $request->get('sort_order', 'asc');
            $query->orderBy($sortBy, $sortOrder);
            
            // ✅ PAGINACIÓN
            $perPage = $request->get('per_page', 10);
            $competencias = $query->paginate($perPage);
            
            return response()->json([
                'data' => $competencias->items(),
                'meta' => [
                    'current_page' => $competencias->currentPage(),
                    'last_page' => $competencias->lastPage(),
                    'per_page' => $competencias->perPage(),
                    'total' => $competencias->total(),
                    'from' => $competencias->firstItem(),
                    'to' => $competencias->lastItem(),
                ]
            ], 200);
            
        } catch (\Exception $e) {
            \Log::error('Error en index de competencias: ' . $e->getMessage());
            
            return response()->json([
                'message' => 'Error al cargar competencias',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // ============================================
    // 🗑️ LISTAR PAPELERA
    // ============================================
    public function trashed()
    {
        $competencias = Competencias::onlyTrashed()->with('categoria')->get();

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

    // ============================================
    // 👁️ VER UNA COMPETENCIA
    // ============================================
    public function show($id)
    {
        $competencia = Competencias::with('categoria')->find($id);

        if (!$competencia) {
            return response()->json([
                'message' => 'Competencia no encontrada',
                'status' => 404
            ], 404);
        }

        return response()->json($competencia, 200);
    }

    // ============================================
    // ➕ CREAR COMPETENCIA
    // ============================================
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'Nombre' => 'required|string|max:50',
            'TipoCompetencia' => 'required|string|max:30',
            'Ano' => 'required|integer|min:1900|max:2100',
            'idCategorias' => 'required|integer|exists:categorias,idCategorias',
        ], [
            'Nombre.required' => 'El nombre es requerido',
            'Nombre.max' => 'El nombre no puede exceder 50 caracteres',
            'TipoCompetencia.required' => 'El tipo de competencia es requerido',
            'TipoCompetencia.max' => 'El tipo no puede exceder 30 caracteres',
            'Ano.required' => 'El año es requerido',
            'Ano.integer' => 'El año debe ser un número',
            'Ano.min' => 'El año debe ser mayor a 1900',
            'Ano.max' => 'El año debe ser menor a 2100',
            'idCategorias.required' => 'Debe seleccionar una categoría',
            'idCategorias.exists' => 'La categoría seleccionada no existe',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

        $competencia = Competencias::create($request->all());
        $competencia->load('categoria');

        return response()->json([
            'message' => 'Competencia creada exitosamente',
            'data' => $competencia
        ], 201);
    }

    // ============================================
    // ✏️ ACTUALIZAR COMPETENCIA
    // ============================================
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
            'Ano' => 'sometimes|integer|min:1900|max:2100',
            'idCategorias' => 'sometimes|integer|exists:categorias,idCategorias',
        ], [
            'Nombre.max' => 'El nombre no puede exceder 50 caracteres',
            'TipoCompetencia.max' => 'El tipo no puede exceder 30 caracteres',
            'Ano.integer' => 'El año debe ser un número',
            'Ano.min' => 'El año debe ser mayor a 1900',
            'Ano.max' => 'El año debe ser menor a 2100',
            'idCategorias.exists' => 'La categoría seleccionada no existe',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

        $competencia->update($request->all());
        $competencia->load('categoria');

        return response()->json([
            'message' => 'Competencia actualizada exitosamente',
            'data' => $competencia
        ], 200);
    }

    // ============================================
    // 🗑️ ELIMINAR (SOFT DELETE)
    // ============================================
    public function destroy($id)
    {
        $competencia = Competencias::find($id);

        if (!$competencia) {
            return response()->json([
                'message' => 'Competencia no encontrada',
                'status' => 404
            ], 404);
        }

        $competencia->delete();

        return response()->json([
            'message' => 'Competencia eliminada correctamente (movida a papelera)',
            'status' => 200
        ], 200);
    }

    // ============================================
    // ♻️ RESTAURAR
    // ============================================
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
        $competencia->load('categoria');

        return response()->json([
            'message' => 'Competencia restaurada correctamente',
            'data' => $competencia,
            'status' => 200
        ], 200);
    }

    // ============================================
    // 💀 ELIMINAR PERMANENTEMENTE
    // ============================================
    public function forceDelete($id)
    {
        $competencia = Competencias::onlyTrashed()->find($id);

        if (!$competencia) {
            return response()->json([
                'message' => 'Competencia no encontrada en papelera',
                'status' => 404
            ], 404);
        }

        $competencia->forceDelete();

        return response()->json([
            'message' => 'Competencia eliminada permanentemente',
            'status' => 200
        ], 200);
    }

    // ============================================
    // 📊 OBTENER COMPETENCIAS POR CATEGORÍA
    // ============================================
    public function getCompetenciasByCategoria($idCategorias)
    {
        try {
            $competenciasUsadas = Competencias::whereHas('cronogramas', function($query) use ($idCategorias) {
                $query->where('idCategorias', $idCategorias);
            })->get();

            $competenciasNuevas = Competencias::doesntHave('cronogramas')->get();

            $competencias = $competenciasUsadas
                ->merge($competenciasNuevas)
                ->unique('idCompetencias')
                ->values();

            return response()->json($competencias, 200);
            
        } catch (\Exception $e) {
            \Log::error('Error en getCompetenciasByCategoria: ' . $e->getMessage());
            
            return response()->json([
                'message' => 'Error al obtener competencias',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}