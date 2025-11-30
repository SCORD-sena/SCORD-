<?php

namespace App\Http\Controllers;

use App\Models\Categorias;
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
}
