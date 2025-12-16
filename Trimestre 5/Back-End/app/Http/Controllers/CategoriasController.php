<?php

namespace App\Http\Controllers;

use App\Models\Categorias;
use App\Models\Jugadores;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class CategoriasController extends Controller
{
    public function index()
    {
        $categorias = Categorias::all();

        if ($categorias->isEmpty()) {
            return response()->json(['message' => 'No se encontraron categorías'], 404);
        }

        return response()->json(['data' => $categorias], 200);
    }

    public function show($id)
    {
        $categoria = Categorias::find($id);

        if (!$categoria) {
            return response()->json(['message' => 'Categoría no encontrada'], 404);
        }

        return response()->json(['data' => $categoria], 200);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'Descripcion' => 'required|string|max:20',
            'TiposCategoria' => 'required|string|max:30'
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $categoria = Categorias::create($request->all());

        return response()->json(['data' => $categoria], 201);
    }

    public function update(Request $request, $id)
    {
        $categoria = Categorias::find($id);

        if (!$categoria) {
            return response()->json(['message' => 'Categoría no encontrada'], 404);
        }

        $validator = Validator::make($request->all(), [
            'Descripcion' => 'sometimes|string|max:20',
            'TiposCategoria' => 'sometimes|string|max:30'
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $categoria->update($request->all());

        return response()->json(['data' => $categoria], 200);
    }

    public function destroy($id)
    {
        $categoria = Categorias::find($id);

        if (!$categoria) {
            return response()->json(['message' => 'Categoría no encontrada'], 404);
        }

        $categoria->delete();

        return response()->json(['message' => 'Categoría eliminada'], 200);
    }

   public function jugadores($categoriaId): JsonResponse
{
    try {
        // Verificar si la categoría existe
        $categoria = Categorias::find($categoriaId);
        if (!$categoria) {
            return response()->json(['message' => 'Categoría no encontrada'], 404);
        }

        $jugadores = DB::table('Jugadores')
            ->join('Personas', 'Jugadores.idPersonas', '=', 'Personas.idPersonas') // Corregido: idPersonas
            ->where('Jugadores.idCategorias', $categoriaId)
            ->select(
                'Jugadores.idJugadores as id',
                'Jugadores.Dorsal',
                'Jugadores.Posicion',
                'Personas.Nombre1',
                'Personas.Nombre2',
                'Personas.Apellido1',
                'Personas.Apellido2',
                'Personas.NumeroDeDocumento'
            )
            ->get();

        if ($jugadores->isEmpty()) {
            return response()->json(['data' => []], 200);
        }

        // Formatear el nombre completo
        $jugadoresFormateados = $jugadores->map(function($jugador) {
            $nombreCompleto = trim(
                ($jugador->Nombre1 ?? '') . ' ' . 
                ($jugador->Nombre2 ?? '') . ' ' . 
                ($jugador->Apellido1 ?? '') . ' ' . 
                ($jugador->Apellido2 ?? '')
            );
            
            return [
                'id' => $jugador->id,
                'nombre' => $nombreCompleto ?: 'Nombre no disponible',
                'dorsal' => $jugador->Dorsal,
                'posicion' => $jugador->Posicion,
                'numeroDocumento' => $jugador->NumeroDeDocumento
            ];
        });

        return response()->json(['data' => $jugadoresFormateados], 200);

    } catch (\Exception $e) {
        return response()->json(['error' => $e->getMessage()], 500);
    }
}
}
  