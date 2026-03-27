<?php

namespace App\Http\Controllers;

use App\Models\Entrenadores;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class EntrenadoresController extends Controller
{
    /**
     * Listar entrenadores activos (no eliminados)
     */
    public function index()
{
    $entrenadores = Entrenadores::with([
                          'persona' => function($query) {
                              $query->withTrashed(); // Incluir personas eliminadas
                          },
                          'persona.tiposDeDocumentos',
                          'categorias'
                      ])
                      ->get();

    if ($entrenadores->isEmpty()) {
        return response()->json([], 200); // Array vacío
    }

    return response()->json([
        'data' => $entrenadores,
        'status' => 200
    ], 200);
}

    /**
     * NUEVO: Listar entrenadores eliminados (papelera)
     */
    public function trashed()
    {
        $entrenadores = Entrenadores::onlyTrashed()
                                    ->with(['persona.tiposDeDocumentos', 'categorias'])
                                    ->get();

        if ($entrenadores->isEmpty()) {
            return response()->json([
                'message' => 'No hay entrenadores eliminados',
                'status' => 404
            ], 404);
        }

        return response()->json([
            'data' => $entrenadores,
            'status' => 200
        ], 200);
    }

    public function show($id)
    {
        $entrenador = Entrenadores::with(['persona.tiposDeDocumentos', 'categorias'])->find($id);

        if (!$entrenador) {
            return response()->json([
                'message' => 'Entrenador no encontrado',
                'status' => 404
            ], 404);
        }

        return response()->json([
            'data' => $entrenador,
            'status' => 200
        ], 200);
    }

    // Obtener entrenador por ID de persona
    public function getByPersonaId($idPersona)
    {
        $entrenador = Entrenadores::with(['persona.tiposDeDocumentos', 'categorias'])
            ->where('idPersonas', $idPersona)
            ->first();
        
        if (!$entrenador) {
            return response()->json([
                'message' => 'Entrenador no encontrado',
                'status' => 404
            ], 404);
        }
        
        return response()->json([
            'message' => 'Entrenador encontrado',
            'data' => $entrenador,
            'status' => 200
        ], 200);
    }

    // Obtener categorías de un entrenador
    public function getCategoriasByEntrenador($idEntrenador)
    {
        $entrenador = Entrenadores::with('categorias')->find($idEntrenador);
        
        if (!$entrenador) {
            return response()->json([
                'message' => 'Entrenador no encontrado',
                'status' => 404
            ], 404);
        }
        
        return response()->json([
            'message' => 'Categorías del entrenador',
            'data' => $entrenador->categorias,
            'status' => 200
        ], 200);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'idPersonas' => 'required|integer|exists:Personas,idPersonas',
            'AnosDeExperiencia' => 'required|integer',
            'Cargo' => 'required|string|max:30',
            'categorias' => 'required|array|min:1',
            'categorias.*' => 'integer|exists:Categorias,idCategorias'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors(),
                'status' => 422
            ], 422);
        }

        $entrenador = Entrenadores::create(
            $request->only(['idPersonas', 'AnosDeExperiencia', 'Cargo'])
        );

        $entrenador->categorias()->attach($request->categorias);

        return response()->json([
            'message' => 'Entrenador creado exitosamente',
            'data' => $entrenador->load(['persona.tiposDeDocumentos', 'categorias']),
            'status' => 201
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $entrenador = Entrenadores::find($id);

        if (!$entrenador) {
            return response()->json([
                'message' => 'Entrenador no encontrado',
                'status' => 404
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'idPersonas' => 'sometimes|integer|exists:Personas,idPersonas',
            'AnosDeExperiencia' => 'sometimes|integer',
            'Cargo' => 'sometimes|string|max:30',
            'categorias' => 'sometimes|array',
            'categorias.*' => 'integer|exists:Categorias,idCategorias'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors(),
                'status' => 422
            ], 422);
        }

        $entrenador->update(
            $request->only(['idPersonas', 'AnosDeExperiencia', 'Cargo'])
        );

        if ($request->has('categorias')) {
            $entrenador->categorias()->sync($request->categorias);
        }

        return response()->json([
            'message' => 'Entrenador actualizado correctamente',
            'data' => $entrenador->load(['persona.tiposDeDocumentos', 'categorias']),
            'status' => 200
        ], 200);
    }

    /**
     * MODIFICADO: Eliminar entrenador (soft delete)
     */
    public function destroy($id)
    {
        $entrenador = Entrenadores::find($id);

        if (!$entrenador) {
            return response()->json([
                'message' => 'Entrenador no encontrado',
                'status' => 404
            ], 404);
        }

        // Soft delete - NO eliminamos las relaciones con categorías
        $entrenador->delete();

        return response()->json([
            'message' => 'Entrenador eliminado correctamente (movido a papelera)',
            'status' => 200
        ], 200);
    }

    /**
     * NUEVO: Restaurar entrenador eliminado
     */
    public function restore($id)
    {
        $entrenador = Entrenadores::onlyTrashed()->find($id);

        if (!$entrenador) {
            return response()->json([
                'message' => 'Entrenador no encontrado en papelera',
                'status' => 404
            ], 404);
        }

        $entrenador->restore();

        return response()->json([
            'message' => 'Entrenador restaurado correctamente',
            'data' => $entrenador->load(['persona.tiposDeDocumentos', 'categorias']),
            'status' => 200
        ], 200);
    }

    /**
     * NUEVO: Eliminar permanentemente
     */
    public function forceDelete($id)
    {
        $entrenador = Entrenadores::onlyTrashed()->find($id);

        if (!$entrenador) {
            return response()->json([
                'message' => 'Entrenador no encontrado en papelera',
                'status' => 404
            ], 404);
        }

        // Eliminar relaciones con categorías antes de borrar permanentemente
        $entrenador->categorias()->detach();
        
        $entrenador->forceDelete(); // Eliminación permanente

        return response()->json([
            'message' => 'Entrenador eliminado permanentemente',
            'status' => 200
        ], 200);
    }

    // Obtener las categorías del entrenador autenticado
    public function misCategorias(Request $request)
    {
        // Obtener el usuario autenticado desde el JWT
        $user = auth()->user();
        
        if (!$user) {
            return response()->json([
                'message' => 'No autenticado',
                'status' => 401
            ], 401);
        }
        
        // Buscar el entrenador por idPersonas
        $entrenador = Entrenadores::with('categorias')
            ->where('idPersonas', $user->idPersonas)
            ->first();
        
        if (!$entrenador) {
            return response()->json([
                'message' => 'Entrenador no encontrado para este usuario',
                'status' => 404
            ], 404);
        }
        
        // Retornar solo las categorías
        return response()->json([
            'message' => 'Categorías del entrenador',
            'data' => $entrenador->categorias,
            'status' => 200
        ], 200);
    }
}