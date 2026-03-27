<?php

namespace App\Http\Controllers;
use App\Models\cronogramas;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class cronogramasController extends Controller
{
    public function index()
    {
        $cronogramas = cronogramas::all();

        if ($cronogramas->isEmpty()) {
            return response()->json([
                'message' => 'No se encontraron cronogramas',
                'status' => 404
            ], 404);
        }

        return response()->json($cronogramas, 200);
    }

    public function show($id)
    {
        $cronogramas = cronogramas::find($id);

        if (!$cronogramas) {
            return response()->json([
                'message' => 'cronograma no encontrado',
                'status' => 404
            ], 404);
        }

        return response()->json($cronogramas, 200);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'FechaDeEventos' => 'required|date',
            'TipoDeEventos' => 'required|string|max:50',
            'CanchaPartido' => 'nullable|string|max:50',
            'Ubicacion' => 'required|string|max:50',
            'SedeEntrenamiento' => 'nullable|string|max:50',
            'Descripcion' => 'required|string|max:100',
<<<<<<< HEAD
            'idCategorias' => 'required|integer|exists:categorias,idCategorias',
            'idCompetencias' => 'nullable|integer|exists:competencias,idCompetencias' // ✅ CORREGIDO: nullable sin required
=======
            'idCategorias' => 'required|integer|exists:categorias,idCategorias' // ✅ CAMBIADO
>>>>>>> 77fbf37e833f546a83348df26e99d07ab761018b
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

        $cronogramas = cronogramas::create([
            'FechaDeEventos' => $request->FechaDeEventos,
            'TipoDeEventos' => $request->TipoDeEventos,
            'CanchaPartido' => $request->CanchaPartido,
            'Ubicacion' => $request->Ubicacion,
            'SedeEntrenamiento' => $request->SedeEntrenamiento,
            'Descripcion' => $request->Descripcion,
<<<<<<< HEAD
            'idCategorias' => $request->idCategorias,
            'idCompetencias' => $request->idCompetencias // Puede ser null para entrenamientos
=======
            'idCategorias' => $request->idCategorias
>>>>>>> 77fbf37e833f546a83348df26e99d07ab761018b
        ]);

        $cronogramas->refresh();

        return response()->json([
            'message' => 'cronograma creado exitosamente',
            'data' => $cronogramas
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $cronogramas = cronogramas::find($id);

        if (!$cronogramas) {
            return response()->json([
                'message' => 'cronograma no encontrado',
                'status' => 404
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'FechaDeEventos' => 'sometimes|date',
            'TipoDeEventos' => 'sometimes|string|max:50',
            'CanchaPartido' => 'nullable|string|max:50',
            'Ubicacion' => 'sometimes|string|max:50',
            'SedeEntrenamiento' => 'nullable|string|max:50',
            'Descripcion' => 'sometimes|string|max:100',
<<<<<<< HEAD
            'idCategorias' => 'sometimes|integer|exists:categorias,idCategorias',
            'idCompetencias' => 'nullable|integer|exists:competencias,idCompetencias' // ✅ CORREGIDO: nullable sin required
=======
            'idCategorias' => 'sometimes|integer|exists:categorias,idCategorias' // ✅ CAMBIADO
>>>>>>> 77fbf37e833f546a83348df26e99d07ab761018b
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

        $cronogramas->update($request->only([
            'FechaDeEventos',
            'TipoDeEventos', 
            'CanchaPartido',
            'Ubicacion',
            'SedeEntrenamiento',
            'Descripcion',
<<<<<<< HEAD
            'idCategorias',
            'idCompetencias'
=======
            'idCategorias'
>>>>>>> 77fbf37e833f546a83348df26e99d07ab761018b
        ]));

        return response()->json([
            'message' => 'cronograma actualizado exitosamente',
            'data' => $cronogramas
        ], 200);
    }

    public function destroy($id)
    {
        $cronogramas = cronogramas::find($id);

        if (!$cronogramas) {
            return response()->json([
                'message' => 'no se pudo eliminar el cronograma',
                'status' => 404
            ], 404);
        }
        
        $cronogramas->delete();

        return response()->json([
            'message' => 'cronograma eliminado exitosamente',
            'status' => 200
        ], 200);
    }
<<<<<<< HEAD

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
=======
>>>>>>> 77fbf37e833f546a83348df26e99d07ab761018b
}