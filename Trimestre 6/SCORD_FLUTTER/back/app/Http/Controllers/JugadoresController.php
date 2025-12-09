<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Jugadores;
use Illuminate\Support\Facades\Validator;

class JugadoresController extends Controller
{
    public function index()
    {
        $jugadores = Jugadores::with(['persona.tiposDeDocumentos', 'categoria'])->get();
        
        if($jugadores->isEmpty()){
            return response()->json([
                'message'=>'jugadores no encontrados',
                'status'=>'404'
            ],404);
        }
        return response()->json($jugadores, 200);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'Dorsal' => 'required|integer',
            'Posicion' => 'required|string|max:25',
            'Upz'=> 'nullable|string|max:40',
            'Estatura'=> 'nullable|numeric',
            'NomTutor1'=> 'required|string|max:30',
            'NomTutor2'=> 'nullable|string|max:30',
            'ApeTutor1'=> 'required|string|max:30',
            'ApeTutor2'=> 'nullable|string|max:30',
            'TelefonoTutor' => 'required|string',
            'idPersonas' => 'required|integer|exists:Personas,idPersonas',
            'idCategorias' => 'required|integer|exists:Categorias,idCategorias',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

        $jugadores = Jugadores::create($request->all());
        
        $jugadores->load(['persona.tiposDeDocumentos', 'categoria']);

        return response()->json([
            'message' => 'Jugador creado exitosamente',
            'data' => $jugadores
        ], 201);
    }

    public function show($id)
    {
        $jugadores = Jugadores::with(['persona.tiposDeDocumentos', 'categoria'])->find($id);

        if (!$jugadores) {
            return response()->json([
                'message' => 'Jugador no encontrado',
                'status' => 404
            ], 404);
        }

        return response()->json($jugadores, 200);
    }

    public function update(Request $request, $id)
    {
        $jugadores = Jugadores::find($id);

        if (!$jugadores) {
            return response()->json(['message' => 'Jugador no encontrado'], 404);
        }

        $validator = Validator::make($request->all(), [
            'Dorsal' => 'sometimes|integer',
            'Posicion' => 'sometimes|string|max:25',
            'Upz'=> 'sometimes|string|max:40',
            'Estatura'=> 'sometimes|numeric',
            'NomTutor1'=> 'sometimes|string|max:30',
            'NomTutor2'=> 'sometimes|string|max:30',
            'ApeTutor1'=> 'sometimes|string|max:30',
            'ApeTutor2'=> 'sometimes|string|max:30',
            'TelefonoTutor' => 'sometimes|string',
            'idPersonas' => 'sometimes|integer|exists:Personas,idPersonas',
            'idCategorias' => 'sometimes|integer|exists:Categorias,idCategorias',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $jugadores->update($request->all());
        
        $jugadores->load(['persona.tiposDeDocumentos', 'categoria']);

        return response()->json([
            'message' => 'Jugador actualizado correctamente',
            'data' => $jugadores
        ], 200);
    }

    public function destroy($id)
    {
        $jugadores = Jugadores::find($id);

        if (!$jugadores) {
            return response()->json(['message' => 'Jugador no encontrado'], 404);
        }

        $jugadores->delete();

        return response()->json([
            'message' => 'Jugador eliminado correctamente'
        ], 200);
    }

    /**
     * Obtener datos del jugador autenticado
     */
    public function misDatos()
    {
        try {
            $persona = auth()->user();
            
            if (!$persona) {
                return response()->json([
                    'message' => 'Usuario no autenticado',
                    'status' => 401
                ], 401);
            }
            
            if (!$persona->isJugador()) {
                return response()->json([
                    'message' => 'El usuario no tiene rol de jugador',
                    'status' => 403
                ], 403);
            }
            
            $jugador = Jugadores::where('idPersonas', $persona->idPersonas)
                ->with(['persona.tiposDeDocumentos', 'categoria'])
                ->first();
            
            if (!$jugador) {
                return response()->json([
                    'message' => 'No se encontró registro de jugador para este usuario',
                    'status' => 404
                ], 404);
            }
            
            // Formatear la respuesta para el frontend
            $response = [
                // Datos de Persona
                'Nombre1' => $jugador->persona->Nombre1,
                'Nombre2' => $jugador->persona->Nombre2,
                'Apellido1' => $jugador->persona->Apellido1,
                'Apellido2' => $jugador->persona->Apellido2,
                'FechaDeNacimiento' => $jugador->persona->FechaDeNacimiento,
                'Genero' => $jugador->persona->Genero,
                'Telefono' => $jugador->persona->Telefono,
                'correo' => $jugador->persona->correo,
                'Direccion' => $jugador->persona->Direccion,
                
                // Datos de Jugador
                'idJugadores' => $jugador->idJugadores,
                'Dorsal' => $jugador->Dorsal,
                'Posicion' => $jugador->Posicion,
                'Estatura' => $jugador->Estatura,
                'Upz' => $jugador->Upz,
                'NomTutor1' => $jugador->NomTutor1,
                'NomTutor2' => $jugador->NomTutor2,
                'ApeTutor1' => $jugador->ApeTutor1,
                'ApeTutor2' => $jugador->ApeTutor2,
                'TelefonoTutor' => $jugador->TelefonoTutor,
                
                // Datos de Categoría
                'Categoria' => $jugador->categoria->Descripcion ?? null,
                'idCategorias' => $jugador->idCategorias,
            ];
            
            return response()->json([
                'success' => true,
                'data' => $response,
                'status' => 200
            ], 200);
            
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error al obtener datos del jugador',
                'error' => $e->getMessage(),
                'status' => 500
            ], 500);
        }
    }
}