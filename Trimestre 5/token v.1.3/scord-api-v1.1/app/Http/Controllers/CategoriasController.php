<?php

namespace App\Http\Controllers;

use App\Models\Categorias;
use Illuminate\Http\Request;

class CategoriasController extends Controller
{
    // GET /api/categorias
    public function index()
    {
        $Categorias = Categorias::with('TiposCategoria')->get();
        return response()->json($Categorias, 200);
    }

    // POST /api/categorias
    public function store(Request $request)
    {
        $validated = $request->validate([
            'descripcion' => 'required|string|max:20',
            'tiposcategoria' => 'required|string|max:45'
        ]);

        $categorias = Categorias::create($validated);

        return response()->json([
            'message' => 'Categoría creada con éxito',
            'data' => $categorias->load('tipoCategoria')
        ], 201);
    }

    // GET /api/categorias/{id}
    public function show($id)
    {
        $categorias = Categorias::with('tipoCategoria')->findOrFail($id);
        return response()->json($categorias, 200);
    }

    // PUT /api/categorias/{id}
    public function update(Request $request, $id)
    {
        $categorias = Categorias::findOrFail($id);

        $validated = $request->validate([
            'descripcion' => 'required|string|max:20',
            'tiposcategoria' => 'required|exists:tipos_categoria,idTiposCategoria'
        ]);

        $categorias->update($validated);

        return response()->json([
            'message' => 'Categoría actualizada con éxito',
            'data' => $categorias->load('tipoCategoria')
        ], 200);
    }

    // DELETE /api/categorias/{id}
    public function destroy($id)
    {
        $categorias = Categorias::findOrFail($id);
        $categorias->delete();

        return response()->json([
            'message' => 'Categoría eliminada con éxito'
        ], 200);
    }
}

