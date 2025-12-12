<?php

namespace App\Http\Controllers;

use App\Models\Categorias;
use App\Models\Jugadores;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class CategoriasController extends Controller
{
    public function index()
    {
        $categorias = Categorias::all();

        if ($categorias->isEmpty()) {
            return response()->json([
                'message' => 'No se encontraron categorías',
                'status' => 404
            ], 404);
        }

        return response()->json($categorias, 200);
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
            'idCategorias'  =>  'required|integer',
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

        return response()->json($categoria, 201);
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
            'idCategorias'  =>  'sometimes|required|integer',
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

        return response()->json($categoria, 200);
    }

    public function destroy($id)
    {
        $categoria = Categorias::find($id);

        if (!$categoria) {
            return response()->json([
                'message' => 'Categoría no encontrada',
                'status'  => 404
            ], 404);
        }

        $categoria->delete();

        return response()->json([
            'message' => 'Categoría eliminada con éxito'
        ], 200);
    }

    /**
 * ✅ Obtener todos los jugadores de una categoría específica
 * 
 * @param int $id - ID de la categoría
 * @return \Illuminate\Http\JsonResponse
 */
public function getJugadoresPorCategoria($id)
{
    try {
        // Verificar si la categoría existe
        $categoria = Categorias::find($id);
        
        if (!$categoria) {
            return response()->json([
                'message' => 'Categoría no encontrada',
                'status' => 404
            ], 404);
        }

        // Obtener jugadores de esa categoría con sus relaciones
        $jugadores = Jugadores::where('idCategorias', $id)
            ->with(['persona.tiposDeDocumentos', 'categoria'])
            ->get();

        // Si no hay jugadores, devolver un array vacío pero con código 200
        if ($jugadores->isEmpty()) {
            return response()->json([
                'message' => 'No hay jugadores en esta categoría',
                'data' => [],
                'categoria' => [
                    'idCategorias' => $categoria->idCategorias,
                    'Descripcion' => $categoria->Descripcion,
                    'TiposCategoria' => $categoria->TiposCategoria
                ]
            ], 200);
        }

        return response()->json([
            'message' => 'Jugadores obtenidos exitosamente',
            'data' => $jugadores,
            'categoria' => [
                'idCategorias' => $categoria->idCategorias,
                'Descripcion' => $categoria->Descripcion,
                'TiposCategoria' => $categoria->TiposCategoria
            ]
        ], 200);

    } catch (\Exception $e) {
        return response()->json([
            'message' => 'Error al obtener jugadores de la categoría',
            'error' => $e->getMessage(),
            'status' => 500
        ], 500);
    }
}
}
