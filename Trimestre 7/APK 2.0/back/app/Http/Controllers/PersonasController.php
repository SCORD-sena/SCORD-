<?php

namespace App\Http\Controllers;

use App\Models\Personas;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class PersonasController extends Controller
{
    /**
     * Mostrar todas las personas activas (no eliminadas)
     */
    public function index()
    {
        // Solo personas activas y no eliminadas
        $personas = Personas::with(['tiposDeDocumentos', 'rol', 'jugadores'])
                           ->get();

        if ($personas->isEmpty()) {
            return response()->json([
                'message' => 'No se encontraron personas',
                'status' => 404
            ], 404);
        }

        return response()->json([
            'data' => $personas,
            'status' => 200
        ], 200);
    }

    /**
     * NUEVO: Mostrar personas eliminadas (papelera)
     */
    public function trashed()
    {
        $personas = Personas::onlyTrashed()
                           ->with(['tiposDeDocumentos', 'rol'])
                           ->get();

        if ($personas->isEmpty()) {
            return response()->json([
                'message' => 'No hay personas eliminadas',
                'status' => 404
            ], 404);
        }

        return response()->json([
            'data' => $personas,
            'status' => 200
        ], 200);
    }

    /**
     * Guardar una nueva persona
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'NumeroDeDocumento' => 'required|string|max:20|unique:Personas',
            'Nombre1' => 'required|string|max:50',
            'Apellido1' => 'required|string|max:50',
            'correo' => 'required|email|unique:Personas',
            'contrasena' => 'required|string|min:6',
            'idTiposDeDocumentos' => 'required|integer|exists:TiposDeDocumentos,idTiposDeDocumentos',
            'idRoles' => 'required|integer|exists:Roles,idRoles',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'errors' => $validator->errors(),
                'status' => 422
            ], 422);
        }

        try {
            $persona = Personas::create([
                'NumeroDeDocumento' => $request->NumeroDeDocumento,
                'Nombre1' => $request->Nombre1,
                'Nombre2' => $request->Nombre2,
                'Apellido1' => $request->Apellido1,
                'Apellido2' => $request->Apellido2,
                'FechaDeNacimiento' => $request->FechaDeNacimiento,
                'Genero' => $request->Genero,
                'Telefono' => $request->Telefono,
                'EpsSisben' => $request->EpsSisben,
                'Direccion' => $request->Direccion,
                'correo' => $request->correo,
                'contrasena' => bcrypt($request->contrasena),
                'idTiposDeDocumentos' => $request->idTiposDeDocumentos,
                'idRoles' => $request->idRoles,
            ]);

            // Cargar las relaciones si es necesario
            $persona->load(['tiposDeDocumentos', 'rol']);

            // Excluir contraseña de la respuesta
            $persona->makeHidden(['contrasena']);

            return response()->json([
                'message' => 'Persona creada correctamente',
                'data' => $persona,
                'status' => 201
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error al crear la persona',
                'error' => $e->getMessage(),
                'status' => 500
            ], 500);
        }
    }

    /**
     * Mostrar persona por ID
     */
    public function show($id)
    {
        $persona = Personas::with(['tiposDeDocumentos', 'rol', 'jugadores'])->find($id);

        if (!$persona) {
            return response()->json([
                'message' => 'Persona no encontrada',
                'status' => 404
            ], 404);
        }

        return response()->json([
            'data' => $persona,
            'status' => 200
        ], 200);
    }

    /**
     * Actualizar persona
     */
    public function update(Request $request, $id)
    {
        $persona = Personas::find($id);

        if (!$persona) {
            return response()->json([
                'message' => 'Persona no encontrada',
                'status' => 404
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'NumeroDeDocumento' => 'sometimes|string|max:20|unique:Personas,NumeroDeDocumento,' . $persona->idPersonas . ',idPersonas',
            'Nombre1' => 'sometimes|string|max:50',
            'Apellido1' => 'sometimes|string|max:50',
            'correo' => 'sometimes|email|unique:Personas,correo,' . $persona->idPersonas . ',idPersonas',
            'contrasena' => 'sometimes|string|min:6',
            'idTiposDeDocumentos' => 'sometimes|integer|exists:TiposDeDocumentos,idTiposDeDocumentos',
            'idRoles' => 'sometimes|integer|exists:Roles,idRoles',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'errors' => $validator->errors(),
                'status' => 422
            ], 422);
        }

        $data = $request->only([
            'NumeroDeDocumento',
            'Nombre1',
            'Nombre2',
            'Apellido1',
            'Apellido2',
            'FechaDeNacimiento',
            'Genero',
            'Telefono',
            'EpsSisben',
            'Direccion',
            'correo',
            'idTiposDeDocumentos',
            'idRoles',
        ]);

        if ($request->has('contrasena')) {
            $data['contrasena'] = bcrypt($request->contrasena);
        }

        $persona->update($data);

        return response()->json([
            'message' => 'Persona actualizada correctamente',
            'data' => $persona,
            'status' => 200
        ], 200);
    }

    /**
     * MODIFICADO: Eliminar persona (soft delete)
     */
    public function destroy($id)
    {
        $persona = Personas::find($id);

        if (!$persona) {
            return response()->json([
                'message' => 'Persona no encontrada',
                'status' => 404
            ], 404);
        }

        // Soft delete - solo pone fecha en deleted_at
        $persona->delete();

        return response()->json([
            'message' => 'Persona eliminada correctamente (movida a papelera)',
            'status' => 200
        ], 200);
    }

    /**
     * NUEVO: Restaurar persona eliminada
     */
    public function restore($id)
    {
        $persona = Personas::onlyTrashed()->find($id);

        if (!$persona) {
            return response()->json([
                'message' => 'Persona no encontrada en papelera',
                'status' => 404
            ], 404);
        }

        $persona->restore();

        return response()->json([
            'message' => 'Persona restaurada correctamente',
            'data' => $persona,
            'status' => 200
        ], 200);
    }

    /**
     * NUEVO: Eliminar permanentemente
     */
    public function forceDelete($id)
    {
        $persona = Personas::onlyTrashed()->find($id);

        if (!$persona) {
            return response()->json([
                'message' => 'Persona no encontrada en papelera',
                'status' => 404
            ], 404);
        }

        $persona->forceDelete(); // Eliminación permanente

        return response()->json([
            'message' => 'Persona eliminada permanentemente',
            'status' => 200
        ], 200);
    }
}