<?php

namespace App\Http\Controllers;

use App\Models\EntrenadoresCategorias;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class EntrenadoresCategoriasController extends Controller
{
    public function index()
    {
        $relaciones = EntrenadoresCategorias::all();

        if ($relaciones->isEmpty()) {
            return response()->json([
                'message' => 'No se encontraron relaciones',
                'status' => 404
            ], 404);
        }

        return response()->json([
            'message' => 'Relaciones encontradas',
            'data' => $relaciones
        ], 200);
    }

    public function show($idCategorias, $idEntrenadores)
    {
        $relacion = EntrenadoresCategorias::where('idCategorias', $idCategorias)
                                          ->where('idEntrenadores', $idEntrenadores)
                                          ->first();

        if (!$relacion) {
            return response()->json([
                'message' => 'Relación no encontrada',
                'status' => 404
            ], 404);
        }

        return response()->json([
            'message' => 'Relación encontrada',
            'data' => $relacion
        ], 200);
    }

    public function update(Request $request, $idCategorias, $idEntrenadores)
    {
        $relacion = EntrenadoresCategorias::where('idCategorias', $idCategorias)
                                          ->where('idEntrenadores', $idEntrenadores)
                                          ->first();

        if (!$relacion) {
            return response()->json([
                'message' => 'Relación no encontrada',
                'status' => 404
            ], 404);
        }

        return response()->json([
            'message' => 'Relación consultada exitosamente',
            'data' => $relacion
        ], 200);
    }

    public function destroy($idCategorias, $idEntrenadores)
    {
        $deleted = EntrenadoresCategorias::where('idCategorias', $idCategorias)
                                         ->where('idEntrenadores', $idEntrenadores)
                                         ->delete();

        if ($deleted === 0) {
            return response()->json([
                'message' => 'Relación no encontrada',
                'status' => 404
            ], 404);
        }

        return response()->json([
            'message' => 'Relación eliminada exitosamente',
            'deleted_rows' => $deleted
        ], 200);
    }
}
