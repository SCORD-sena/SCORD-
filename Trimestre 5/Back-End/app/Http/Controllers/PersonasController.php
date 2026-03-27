<?php

namespace App\Http\Controllers;

use App\Models\Personas;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class PersonasController extends Controller
{
    /**
     * Display a listing of the resource.
     * GET /api/personas
     */
    public function index()
    {
        try {
            $personas = Personas::with(['tipoDocumento', 'rol'])
                ->get()
                ->makeHidden(['contrasena']);
            
            return response()->json([
                'success' => true,
                'message' => 'Personas obtenidas exitosamente',
                'data' => $personas,
                'status' => 200
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al obtener personas',
                'error' => $e->getMessage(),
                'status' => 500
            ], 500);
        }
    }

    /**
     * Store a newly created resource in storage.
     * POST /api/personas
     */
    public function store(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'NumeroDeDocumento' => 'required|integer|unique:Personas,NumeroDeDocumento',
                'Nombre1' => 'required|string|max:45',
                'Nombre2' => 'nullable|string|max:45',
                'Apellido1' => 'required|string|max:100',
                'Apellido2' => 'nullable|string|max:45',
                'correo' => 'required|email|max:100|unique:Personas,correo',
                'contrasena' => 'required|string|min:6',
                'FechaDeNacimiento' => 'required|date',
                'Genero' => 'required|in:M,F',
                'Telefono' => 'required|string|max:15',
                'Direccion' => 'required|string|max:255',
                'EpsSisben' => 'nullable|string|max:100',
                'idTiposDeDocumentos' => 'required|integer|exists:TipoDeDocumento,idTiposDeDocumentos',
                'idRoles' => 'required|integer|exists:Roles,idRoles'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Error de validación',
                    'errors' => $validator->errors(),
                    'status' => 400
                ], 400);    
            }

            $persona = Personas::create([
                'NumeroDeDocumento' => $request->NumeroDeDocumento,
                'Nombre1' => $request->Nombre1,
                'Nombre2' => $request->Nombre2,
                'Apellido1' => $request->Apellido1,
                'Apellido2' => $request->Apellido2,
                'correo' => $request->correo,
                'contrasena' => Hash::make($request->contrasena),
                'FechaDeNacimiento' => $request->FechaDeNacimiento,
                'Genero' => $request->Genero,
                'Telefono' => $request->Telefono,
                'Direccion' => $request->Direccion,
                'EpsSisben' => $request->EpsSisben,
                'idTiposDeDocumentos' => $request->idTiposDeDocumentos,
                'idRoles' => $request->idRoles,
            ]);

            $persona->load(['tipoDocumento', 'rol'])->makeHidden(['contrasena']);

            return response()->json([
                'success' => true,
                'message' => 'Persona creada exitosamente',
                'data' => $persona,
                'status' => 201
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al crear persona',
                'error' => $e->getMessage(),
                'status' => 500
            ], 500);
        }
    }

    /**
     * Display the specified resource.
     * GET /api/personas/{id}
     */
    public function show($numeroDocumento)
    {
        try {
            $persona = Personas::with(['tipoDocumento', 'rol'])
                ->where('NumeroDeDocumento', $numeroDocumento)
                ->first();

            if (!$persona) {
                return response()->json([
                    'success' => false,
                    'message' => 'Persona no encontrada',
                    'status' => 404
                ], 404);
            }

            $persona->makeHidden(['contrasena']);

            return response()->json([
                'success' => true,
                'message' => 'Persona encontrada',
                'data' => $persona,
                'status' => 200
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al obtener la persona',
                'error' => $e->getMessage(),
                'status' => 500
            ], 500);
        }
    }

    /**
     * Update the specified resource in storage.
     * PUT/PATCH /api/personas/{id}
     */
    public function update(Request $request, $idpersonas)
    {
        try {
            $persona = Personas::where('NumeroDeDocumento', $idpersonas)->first();
            
            if (!$persona) {
                return response()->json([
                    'success' => false,
                    'message' => 'Persona no encontrada',
                    'status' => 404
                ], 404);    
            }

            $validator = Validator::make($request->all(), [
                'Nombre1' => 'sometimes|string|max:45',
                'Nombre2' => 'sometimes|nullable|string|max:45',
                'Apellido1' => 'sometimes|string|max:100',
                'Apellido2' => 'sometimes|nullable|string|max:45',
                'correo' => 'sometimes|email|max:100|unique:Personas,correo,' . $idpersonas . ',idPersonas',
                'contrasena' => 'sometimes|string|min:6',
                'FechaDeNacimiento' => 'sometimes|date',
                'Genero' => 'sometimes|in:M,F',
                'Telefono' => 'sometimes|string|max:15',
                'Direccion' => 'sometimes|string|max:255',
                'EpsSisben' => 'sometimes|nullable|string|max:100',
                'idTiposDeDocumentos' => 'sometimes|integer|exists:TipoDeDocumento,idTiposDeDocumentos',
                'idRoles' => 'sometimes|integer|exists:Roles,idRoles'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Error de validación',
                    'errors' => $validator->errors(),
                    'status' => 400
                ], 400);    
            }

            $updateData = $request->only([
                'Nombre1', 'Nombre2', 'Apellido1', 'Apellido2', 'correo', 
                'FechaDeNacimiento', 'Genero', 'Telefono', 'Direccion', 
                'EpsSisben', 'idTiposDeDocumentos', 'idRoles'
            ]);

            if ($request->has('contrasena')) {
                $updateData['contrasena'] = Hash::make($request->contrasena);
            }

            $persona->update($updateData);
            $persona->fresh()->load(['tipoDocumento', 'rol'])->makeHidden(['contrasena']);

            return response()->json([
                'success' => true,
                'message' => 'Persona actualizada correctamente',
                'data' => $persona,
                'status' => 200
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al actualizar la persona',
                'error' => $e->getMessage(),
                'status' => 500
            ], 500);
        }
    }

    /**
     * Remove the specified resource from storage.
     * DELETE /api/personas/{id}
     */
    public function destroy($idpersonas)
    {
        try {
            $persona = Personas::where('idPersonas', $idpersonas)->first();

            if (!$persona) {
                return response()->json([
                    'success' => false,
                    'message' => 'Persona no encontrada',
                    'status' => 404
                ], 404);
            }

            // Prevenir que un usuario se elimine a sí mismo
            $currentUser = auth('api')->user();
            if ($persona->NumeroDeDocumento === $currentUser->NumeroDeDocumento) {
                return response()->json([
                    'success' => false,
                    'message' => 'No puedes eliminar tu propia cuenta',
                    'status' => 400
                ], 400);
            }

            $persona->delete();

            return response()->json([
                'success' => true,
                'message' => 'Persona eliminada correctamente',
                'status' => 200
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al eliminar la persona',
                'error' => $e->getMessage(),
                'status' => 500
            ], 500);
        }
    }
}