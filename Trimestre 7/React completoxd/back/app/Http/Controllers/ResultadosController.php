<?php

namespace App\Http\Controllers;

use App\Models\Resultados;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ResultadosController extends Controller
{
    /**
     * Listar resultados activos (no eliminados)
     */
    public function index()
    {
        $Resultados = Resultados::all();

        // ====== CAMBIO: Devolver array vacío en lugar de 404 ======
        if ($Resultados->isEmpty()) {
            return response()->json([], 200); // ← Array vacío con status 200
        }

        return response()->json($Resultados, 200);
    }

    /**
     * NUEVO: Listar resultados eliminados (papelera)
     */
    public function trashed()
    {
        $Resultados = Resultados::onlyTrashed()->get();

        if ($Resultados->isEmpty()) {
            return response()->json([
                'message' => 'No hay resultados eliminados',
                'status' => 404
            ], 404);
        }

        return response()->json([
            'data' => $Resultados,
            'status' => 200
        ], 200);
    }

    public function show($id)
    {
        $Resultados = Resultados::find($id);

        if (!$Resultados) {
            return response()->json([
                'message' => 'Resultado no encontrado',
                'status' => 404
            ], 404);
        }

        return response()->json($Resultados, 200);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'Marcador' => 'required|string|max:10',
            'PuntosObtenidos' => 'required|integer',
            'Observacion' => 'nullable|string|max:100',
            'idPartidos' => 'required|integer|exists:Partidos,idPartidos',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

        $Resultados = Resultados::create($request->only([
            'Marcador',
            'PuntosObtenidos',
            'Observacion',
            'idPartidos'
        ]));

        $Resultados->refresh();

        return response()->json([
            'message' => 'Resultado creado exitosamente',
            'data' => $Resultados
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $Resultados = Resultados::find($id);

        if (!$Resultados) {
            return response()->json([
                'message' => 'Resultado no encontrado',
                'status' => 404
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'Marcador' => 'sometimes|required|string|max:10',
            'PuntosObtenidos' => 'sometimes|required|integer',
            'Observacion' => 'sometimes|string|max:100',
            'idPartidos' => 'sometimes|required|integer|exists:Partidos,idPartidos',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

        $Resultados->update($request->only([
            'Marcador',
            'PuntosObtenidos',
            'Observacion',
            'idPartidos'
        ]));

        return response()->json([
            'message' => 'Resultado actualizado exitosamente',
            'data' => $Resultados
        ], 200);
    }

    /**
     * MODIFICADO: Eliminar resultado (soft delete)
     */
    public function destroy($id)
    {
        $Resultados = Resultados::find($id);

        if (!$Resultados) {
            return response()->json([
                'message' => 'Resultado no encontrado',
                'status' => 404
            ], 404);
        }

        // Soft delete - solo pone fecha en deleted_at
        $Resultados->delete();

        return response()->json([
            'message' => 'Resultado eliminado correctamente (movido a papelera)'
        ], 200);
    }

    /**
     * NUEVO: Restaurar resultado eliminado
     */
    public function restore($id)
    {
        $Resultados = Resultados::onlyTrashed()->find($id);

        if (!$Resultados) {
            return response()->json([
                'message' => 'Resultado no encontrado en papelera',
                'status' => 404
            ], 404);
        }

        $Resultados->restore();

        return response()->json([
            'message' => 'Resultado restaurado correctamente',
            'data' => $Resultados,
            'status' => 200
        ], 200);
    }

    /**
     * NUEVO: Eliminar permanentemente
     */
    public function forceDelete($id)
    {
        $Resultados = Resultados::onlyTrashed()->find($id);

        if (!$Resultados) {
            return response()->json([
                'message' => 'Resultado no encontrado en papelera',
                'status' => 404
            ], 404);
        }

        $Resultados->forceDelete(); // Eliminación permanente

        return response()->json([
            'message' => 'Resultado eliminado permanentemente',
            'status' => 200
        ], 200);
    }
}