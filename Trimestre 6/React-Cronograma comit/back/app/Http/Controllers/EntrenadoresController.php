<?php

namespace App\Http\Controllers;

use App\Models\Entrenadores;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class EntrenadoresController extends Controller
{
    public function index()
    {
        $entrenadores = Entrenadores::with(['persona.tiposDeDocumentos', 'categorias'])->get();

        if ($entrenadores->isEmpty()) {
            return response()->json([
                'message' => 'No se encontraron entrenadores',
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

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'idPersonas' => 'required|integer|exists:Personas,idPersonas',
            'AnosDeExperiencia' => 'required|integer',
            'Cargo' => 'required|string|max:30',
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

    public function destroy($id)
    {
        $entrenador = Entrenadores::find($id);

        if (!$entrenador) {
            return response()->json([
                'message' => 'Entrenador no encontrado',
                'status' => 404
            ], 404);
        }

        $entrenador->categorias()->detach();
        $entrenador->delete();

        return response()->json([
            'message' => 'Entrenador eliminado correctamente',
            'status' => 200
        ], 200);
    }

    /**
     * Obtener las categorías del entrenador autenticado
     * Este método es el que faltaba en tu controller
     */
    /**
 * Obtener las categorías del entrenador autenticado
 */
public function misCategorias()
{
    try {
        // Obtener el usuario autenticado (es una instancia de Personas)
        $persona = auth()->user();
        
        if (!$persona) {
            return response()->json([
                'message' => 'Usuario no autenticado',
                'status' => 401
            ], 401);
        }
        
        // Verificar que el usuario sea entrenador
        if (!$persona->isEntrenador()) {
            return response()->json([
                'message' => 'El usuario no tiene rol de entrenador',
                'status' => 403
            ], 403);
        }
        
        // Buscar el entrenador por idPersonas usando first() en lugar de get()
        $entrenador = Entrenadores::where('idPersonas', $persona->idPersonas)
            ->with('categorias') // Eager loading de categorías
            ->first();
        
        if (!$entrenador) {
            return response()->json([
                'message' => 'No se encontró registro de entrenador para este usuario',
                'status' => 404
            ], 404);
        }
        
        // Retornar las categorías
        return response()->json([
            'data' => $entrenador->categorias,
            'status' => 200
        ], 200);
        
    } catch (\Exception $e) {
        return response()->json([
            'message' => 'Error al obtener categorías',
            'error' => $e->getMessage(),
            'status' => 500
        ], 500);
    }
}
    }
