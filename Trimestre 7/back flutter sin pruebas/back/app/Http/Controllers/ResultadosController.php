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
    /**
 * NUEVO: Obtener resultados eliminados con información completa
 * (incluye partido, cronograma y competencia)
 */
public function getTrashed()
{
    try {
        $resultados = Resultados::onlyTrashed()
            ->with([
                'partido.cronograma.competencia',
                'partido.cronograma.categoria'
            ])
            ->get();

        if ($resultados->isEmpty()) {
            return response()->json([
                'message' => 'No hay resultados eliminados',
                'data' => []
            ], 200);
        }

        // Formatear la respuesta con toda la información
        $resultadosFormateados = $resultados->map(function ($resultado) {
            return [
                'idResultados' => $resultado->idResultados,
                'Marcador' => $resultado->Marcador,
                'PuntosObtenidos' => $resultado->PuntosObtenidos,
                'Observacion' => $resultado->Observacion,
                'idPartidos' => $resultado->idPartidos,
                'deleted_at' => $resultado->deleted_at,
                
                // Información del partido
                'partido' => [
                    'idPartidos' => $resultado->partido->idPartidos,
                    'EquipoRival' => $resultado->partido->EquipoRival,
                    'Formacion' => $resultado->partido->Formacion,
                    'cronograma' => [
                        'idCronogramas' => $resultado->partido->cronograma->idCronogramas,
                        'FechaDeEventos' => $resultado->partido->cronograma->FechaDeEventos,
                        'Ubicacion' => $resultado->partido->cronograma->Ubicacion,
                        'competencia' => $resultado->partido->cronograma->competencia ? [
                            'idCompetencias' => $resultado->partido->cronograma->competencia->idCompetencias,
                            'Nombre' => $resultado->partido->cronograma->competencia->Nombre,
                            'TipoCompetencia' => $resultado->partido->cronograma->competencia->TipoCompetencia,
                            'Ano' => $resultado->partido->cronograma->competencia->Ano,
                        ] : null,
                        'categoria' => $resultado->partido->cronograma->categoria ? [
                            'idCategorias' => $resultado->partido->cronograma->categoria->idCategorias,
                            'Descripcion' => $resultado->partido->cronograma->categoria->Descripcion,
                        ] : null
                    ]
                ]
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $resultadosFormateados
        ], 200);

    } catch (\Exception $e) {
        \Log::error('Error en getTrashed de Resultados: ' . $e->getMessage());
        
        return response()->json([
            'message' => 'Error al obtener resultados eliminados',
            'error' => $e->getMessage(),
            'line' => $e->getLine()
        ], 500);
    }
}
}