<?php

namespace App\Http\Controllers;

use App\Models\Personas;
use App\Models\TipoDeDocumento;
use App\Models\Roles;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Tymon\JWTAuth\Facades\JWTAuth;
use Tymon\JWTAuth\Exceptions\JWTException;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'NumeroDeDocumento' => 'required|numeric|unique:Personas,NumeroDeDocumento',
            'Nombre1' => 'required|string|max:30',
            'Nombre2' => 'nullable|string|max:30',
            'Apellido1' => 'required|string|max:30',
            'Apellido2' => 'required|string|max:30',
            'FechaDeNacimiento' => 'required|date',
            'Genero' => 'required|string|max:9',
            'EpsSisben' => 'required|string|max:38',
            'Direccion' => 'required|string|max:40',
            'Telefono' => 'required|string|max:10',
            'correo' => 'required|email|unique:Personas,correo',
            'contrasena' => 'required|string|min:8|max:255|confirmed',
            'idTiposDeDocumentos' => 'required|exists:TiposDeDocumentos,idTiposDeDocumentos',
            'idRoles' => 'required|exists:Roles,idRoles|in:1,2,3',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Error de validación de los datos',
                'errors' => $validator->errors(),
            ], 400);
        }

        try {
            $personas = Personas::create([
                'NumeroDeDocumento' => $request->NumeroDeDocumento,
                'Nombre1' => $request->Nombre1,
                'Nombre2' => $request->Nombre2,
                'Apellido1' => $request->Apellido1,
                'Apellido2' => $request->Apellido2,
                'FechaDeNacimiento' => $request->FechaDeNacimiento,
                'Genero' => $request->Genero,
                'EpsSisben' => $request->EpsSisben,
                'Direccion' => $request->Direccion,
                'Telefono' => $request->Telefono,
                'correo' => $request->correo,
                'contrasena' => Hash::make($request->contrasena),
                'idTiposDeDocumentos' => $request->idTiposDeDocumentos,
                'idRoles' => $request->idRoles,
            ]);

            // Cargar las relaciones
            $personas->load(['tipoDocumento', 'rol']);

            // Excluir contraseña de la respuesta
            $personas->makeHidden(['contrasena']);

            return response()->json([
                'success' => true,
                'message' => 'Usuario registrado exitosamente',
                'data' => $personas,
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al registrar el usuario',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'correo' => 'required|email',
            'contrasena' => 'required|string|min:8',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Error de validación',
                'errors' => $validator->errors(),
            ], 400);
        }

        try {
            // Buscar usuario por email con sus relaciones
            $personas = Personas::with(['tipoDocumento', 'rol'])
                ->where('correo', $request->correo)
                ->first();
            
            if (!$personas) {
                return response()->json([
                    'success' => false,
                    'message' => 'Credenciales incorrectas'
                ], 401);
            }

            // Verificar contraseña usando el método del modelo
            if (!Hash::check($request->contrasena, $personas->getAuthPassword())) {
                return response()->json([
                    'success' => false,
                    'message' => 'Credenciales incorrectas'
                ], 401);
            }

            // Crear token JWT
            $token = JWTAuth::fromUser($personas);

            return response()->json([
                'success' => true,
                'message' => 'Login exitoso',
                'token' => $token,
                'user' => [
                    'NumeroDeDocumento' => $personas->NumeroDeDocumento,
                    'Nombre1' => $personas->Nombre1,
                    'Nombre2' => $personas->Nombre2,
                    'Apellido1' => $personas->Apellido1,
                    'Apellido2' => $personas->Apellido2,
                    'correo' => $personas->correo,
                    'Telefono' => $personas->Telefono,
                    'Direccion' => $personas->Direccion,
                    'FechaDeNacimiento' => $personas->FechaDeNacimiento,
                    'Genero' => $personas->Genero,
                    'EpsSisben' => $personas->EpsSisben,
                    'TipoDocumento' => $personas->tipoDocumento,
                    'Rol' => $personas->rol
                ]
            ], 200);

        } catch (JWTException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al crear token',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function getUser()
    {
        try {
            $personas = auth('api')->user();
            
            if (!$personas) {
                return response()->json([
                    'success' => false,
                    'message' => 'Usuario no encontrado',
                ], 404);
            }

            // Obtener el usuario completo con las relaciones
            $user = Personas::with(['tipoDocumento', 'rol'])
                ->where('NumeroDeDocumento', $personas->NumeroDeDocumento)
                ->first();

            return response()->json([
                'success' => true,
                'message' => 'Usuario obtenido exitosamente',
                'data' => [
                    'NumeroDeDocumento' => $personas->NumeroDeDocumento,
                    'Nombre1' => $personas->Nombre1,
                    'Nombre2' => $personas->Nombre2,
                    'Apellido1' => $personas->Apellido1,
                    'Apellido2' => $personas->Apellido2,
                    'correo' => $personas->correo,
                    'Telefono' => $personas->Telefono,
                    'Direccion' => $personas->Direccion,
                    'FechaDeNacimiento' => $personas->FechaDeNacimiento,
                    'Genero' => $personas->Genero,
                    'EpsSisben' => $personas->EpsSisben,
                    'TipoDocumento' => $personas->tipoDocumento,
                    'Rol' => $personas->rol
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al obtener usuario',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    public function logout()
    {
        try {
            JWTAuth::invalidate(JWTAuth::getToken());

            return response()->json([
                'success' => true,
                'message' => 'Sesión cerrada exitosamente',
            ], 200);

        } catch (JWTException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al cerrar sesión',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    public function refresh()
    {
        try {
            $token = JWTAuth::refresh(JWTAuth::getToken());
            
            return response()->json([
                'success' => true,
                'message' => 'Token renovado exitosamente',
                'token' => $token
            ], 200);

        } catch (JWTException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al renovar token',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}