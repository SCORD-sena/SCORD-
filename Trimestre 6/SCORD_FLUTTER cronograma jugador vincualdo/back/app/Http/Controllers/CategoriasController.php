<?php

namespace App\Http\Controllers;

use App\Models\Categorias;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class CategoriasController extends Controller
{
    /**
     * Listar categorías activas (no eliminadas)
     */
    public function index()
    {
        $categorias = Categorias::all();

        // ====== CAMBIO: Devolver array vacío en lugar de 404 ======
        if ($categorias->isEmpty()) {
            return response()->json([], 200); // ← Array vacío con status 200
        }

        return response()->json($categorias, 200);
    }

    /**
     * NUEVO: Listar categorías eliminadas (papelera)
     */
    public function trashed()
    {
        $categorias = Categorias::onlyTrashed()->get();

        if ($categorias->isEmpty()) {
            return response()->json([
                'message' => 'No hay categorías eliminadas',
                'status' => 404
            ], 404);
        }

        return response()->json([
            'data' => $categorias,
            'status' => 200
        ], 200);
    }

    public function show($id)
    {
        $categoria = Categorias::find($id);

        if (!$categoria) {
            return response()->json([
                'message' => 'Categoría no encontrada',
                'status' => 404
            ], 404);
        }

        return response()->json($categoria, 200);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'Descripcion'    => 'required|string|max:20',
            'TiposCategoria' => 'required|string|max:30'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors'  => $validator->errors()
            ], 422);
        }

        $categoria = Categorias::create($request->all());

        return response()->json([
            'message' => 'Categoría creada exitosamente',
            'data' => $categoria
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $categoria = Categorias::find($id);

        if (!$categoria) {
            return response()->json([
                'message' => 'Categoría no encontrada',
                'status'  => 404
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'Descripcion'    => 'sometimes|required|string|max:20',
            'TiposCategoria' => 'sometimes|required|string|max:30'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors'  => $validator->errors()
            ], 422);
        }

        $categoria->update($request->all());

        return response()->json([
            'message' => 'Categoría actualizada correctamente',
            'data' => $categoria
        ], 200);
    }

    /**
     * MODIFICADO: Eliminar categoría (soft delete)
     */
    public function destroy($id)
    {
        $categoria = Categorias::find($id);

        if (!$categoria) {
            return response()->json([
                'message' => 'Categoría no encontrada',
                'status'  => 404
            ], 404);
        }

        // Soft delete - solo pone fecha en deleted_at
        $categoria->delete();

        return response()->json([
            'message' => 'Categoría eliminada correctamente (movida a papelera)'
        ], 200);
    }

    /**
     * NUEVO: Restaurar categoría eliminada
     */
    public function restore($id)
    {
        $categoria = Categorias::onlyTrashed()->find($id);

        if (!$categoria) {
            return response()->json([
                'message' => 'Categoría no encontrada en papelera',
                'status' => 404
            ], 404);
        }

        $categoria->restore();

        return response()->json([
            'message' => 'Categoría restaurada correctamente',
            'data' => $categoria,
            'status' => 200
        ], 200);
    }

    /**
     * NUEVO: Eliminar permanentemente
     */
    public function forceDelete($id)
    {
        $categoria = Categorias::onlyTrashed()->find($id);

        if (!$categoria) {
            return response()->json([
                'message' => 'Categoría no encontrada en papelera',
                'status' => 404
            ], 404);
        }

        $categoria->forceDelete(); // Eliminación permanente

        return response()->json([
            'message' => 'Categoría eliminada permanentemente',
            'status' => 200
        ], 200);
    }

    public function jugadoresPorCategoria($id)
    {
        $jugadores = \App\Models\Jugadores::where('idCategorias', $id)->get();

        return response()->json([
            'data' => $jugadores
        ], 200);
    }
}