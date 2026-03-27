<?php

namespace App\Http\Controllers;

use App\Models\Personas;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class PersonasController extends Controller
{
    /**
     * Obtener todos los usuarios (solo admin)
     */
    public function getAllUsers()
    {
        try {
            $personas = Personas::with('tipoDocumento')
                ->select('NumeroDocumento', 'Nombre1', 'Nombre2', 'Apellido1', 'Apellido2', 
                        'Email', 'Telefono', 'Role', 'TipoDocumento_idTipoDocumento', 'Edad', 'Direccion')
                ->get();
            
            return response()->json([
                'success' => true,
                'message' => 'Usuarios obtenidos exitosamente',
                'data' => $personas,
                'status' => 200
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al obtener usuarios',
                'error' => $e->getMessage(),
                'status' => 500
            ], 500);
        }
    }

    /**
     * Obtener usuario por NumeroDocumento (solo admin)
     */
    public function getUserById($numeroDocumento)
    {
        try {
            $personas = Personas::with('tipoDocumento')
                ->where('NumeroDocumento', $numeroDocumento)
                ->first();

            if (!$personas) {
                return response()->json([
                    'success' => false,
                    'message' => 'Usuario no encontrado',
                    'status' => 404
                ], 404);
            }

            // Ocultar contraseña en la respuesta
            $personas->makeHidden(['Contraseña']);

            return response()->json([
                'success' => true,
                'message' => 'Usuario encontrado',
                'data' => $personas,
                'status' => 200
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al obtener el usuario',
                'error' => $e->getMessage(),
                'status' => 500
            ], 500);
        }
    }

    /**
     * Actualizar usuario (solo admin)
     */
    public function updateUserById(Request $request, $numeroDocumento)
    {
        try {
            $personas = Personas::where('NumeroDocumento', $numeroDocumento)->first();
            
            if (!$personas) {
                return response()->json([
                    'success' => false,
                    'message' => 'Usuario no encontrado',
                    'status' => 404
                ], 404);    
            }

            $validator = Validator::make($request->all(), [
                'Nombre1' => 'sometimes|string|max:45',
                'Nombre2' => 'sometimes|nullable|string|max:45',
                'Apellido1' => 'sometimes|string|max:100',
                'Apellido2' => 'sometimes|nullable|string|max:45',
                'Email' => 'sometimes|email|max:100|unique:Usuarios,Email,' . $numeroDocumento . ',NumeroDocumento',
                'Contraseña' => 'sometimes|string|min:6|max:255',
                'FechaNacimiento' => 'sometimes|date',
                'Direccion' => 'sometimes|string|max:255',
                'Telefono' => 'sometimes|string|max:15',
                'Edad' => 'sometimes|integer|min:0|max:120',
                'Role' => 'sometimes|in:user,admin',
                'TipoDocumento_idTipoDocumento' => 'sometimes|integer|exists:TipoDocumento,idTipoDocumento'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Error de validación',
                    'errors' => $validator->errors(),
                    'status' => 400
                ], 400);    
            }

            // Preparar datos para actualizar
            $updateData = $request->only([
                'Nombre1', 'Nombre2', 'Apellido1', 'Apellido2', 'Email', 
                'FechaNacimiento', 'Direccion', 'Telefono', 'Edad', 'Role', 'TipoDocumento_idTipoDocumento'
            ]);

            // Si se incluye contraseña, encriptarla
            if ($request->has('Contraseña')) {
                $updateData['Contraseña'] = Hash::make($request->Contraseña);
            }

            $personas->update($updateData);

            // Refrescar y ocultar contraseña
            $personas->fresh()->load('tipoDocumento')->makeHidden(['Contraseña']);

            return response()->json([
                'success' => true,
                'message' => 'Usuario actualizado correctamente',
                'data' => $personas,
                'status' => 200
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al actualizar el usuario',
                'error' => $e->getMessage(),
                'status' => 500
            ], 500);
        }
    }

    /**
     * Eliminar usuario (solo admin)
     */
    public function deleteUserById($numeroDocumento)
    {
        try {
            $personas = Personas::where('NumeroDocumento', $numeroDocumento)->first();

            if (!$personas) {
                return response()->json([
                    'success' => false,
                    'message' => 'Usuario no encontrado',
                    'status' => 404
                ], 404);
            }

            // Prevenir que un admin se elimine a sí mismo
            $currentUser = auth('api')->user();
            if ($personas->NumeroDocumento === $currentUser->NumeroDocumento) {
                return response()->json([
                    'success' => false,
                    'message' => 'No puedes eliminar tu propia cuenta',
                    'status' => 400
                ], 400);
            }

            $personas->delete();

            return response()->json([
                'success' => true,
                'message' => 'Usuario eliminado correctamente',
                'status' => 200
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al eliminar el usuario',
                'error' => $e->getMessage(),
                'status' => 500
            ], 500);
        }
    }
}