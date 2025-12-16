<?php

namespace App\Http\Controllers;

use App\Models\Partidos;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class PartidosController extends Controller
{
    /**
     * Listar partidos activos (no eliminados)
     */
    public function index()
    {
        $Partidos = Partidos::all();

        // ====== CAMBIO: Devolver array vacío en lugar de 404 ======
        if ($Partidos->isEmpty()) {
            return response()->json([], 200); // ← Array vacío con status 200
        }

        return response()->json($Partidos, 200);
    }

    /**
     * NUEVO: Listar partidos eliminados (papelera)
     */
    public function trashed()
    {
        $Partidos = Partidos::onlyTrashed()->get();

        if ($Partidos->isEmpty()) {
            return response()->json([
                'message' => 'No hay partidos eliminados',
                'status' => 404
            ], 404);
        }

        return response()->json([
            'data' => $Partidos,
            'status' => 200
        ], 200);
    }

    public function show($id)
    {
        $Partidos = Partidos::find($id);

        if (!$Partidos) {
            return response()->json([
                'message' => 'Partido no encontrado',
                'status' => 404
            ], 404);
        }

        return response()->json($Partidos, 200);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [   
            'Formacion' => 'required|string|max:50',
            'EquipoRival' => 'required|string|max:50',
            'idCronogramas' => 'required|integer'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

        $Partidos = Partidos::create($request->only([
            'Formacion',
            'EquipoRival',
            'idCronogramas'
        ]));

        $Partidos->refresh();

        return response()->json([
            'message' => 'Información del partido creada exitosamente',
            'data' => $Partidos
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $Partidos = Partidos::find($id);

        if (!$Partidos) {
            return response()->json([
                'message' => 'Partido no encontrado',
                'status' => 404
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'Formacion' => 'sometimes|required|string|max:50',
            'EquipoRival' => 'sometimes|required|string|max:50',
            'idCronogramas' => 'sometimes|required|integer'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

        $Partidos->update($request->only([
            'Formacion',
            'EquipoRival',
            'idCronogramas'
        ]));

        return response()->json([
            'message' => 'Información del partido actualizada exitosamente',
            'data' => $Partidos
        ], 200);
    }

    /**
     * MODIFICADO: Eliminar partido (soft delete)
     */
    public function destroy($id)
    {
        $Partidos = Partidos::find($id);

        if (!$Partidos) {
            return response()->json([
                'message' => 'Partido no encontrado',
                'status' => 404
            ], 404);
        }

        // Soft delete - solo pone fecha en deleted_at
        $Partidos->delete();

        return response()->json([
            'message' => 'Partido eliminado correctamente (movido a papelera)'
        ], 200);
    }

    /**
     * NUEVO: Restaurar partido eliminado
     */
    public function restore($id)
    {
        $Partidos = Partidos::onlyTrashed()->find($id);

        if (!$Partidos) {
            return response()->json([
                'message' => 'Partido no encontrado en papelera',
                'status' => 404
            ], 404);
        }

        $Partidos->restore();

        return response()->json([
            'message' => 'Partido restaurado correctamente',
            'data' => $Partidos,
            'status' => 200
        ], 200);
    }

    /**
     * NUEVO: Eliminar permanentemente
     */
    public function forceDelete($id)
    {
        $Partidos = Partidos::onlyTrashed()->find($id);

        if (!$Partidos) {
            return response()->json([
                'message' => 'Partido no encontrado en papelera',
                'status' => 404
            ], 404);
        }

        $Partidos->forceDelete(); // Eliminación permanente

        return response()->json([
            'message' => 'Partido eliminado permanentemente',
            'status' => 200
        ], 200);
    }

    /**
     * Obtener partidos por competencia (a través de cronogramas)
     */
    public function getPartidosByCompetencia($idCompetencias)
    {
        $partidos = Partidos::whereHas('cronogramas', function($query) use ($idCompetencias) {
            $query->where('idCompetencias', $idCompetencias);
        })->with('cronogramas')->get();

        if ($partidos->isEmpty()) {
            return response()->json([
                'message' => 'No se encontraron partidos para esta competencia',
                'status' => 404
            ], 404);
        }

        return response()->json($partidos, 200);
    }
}