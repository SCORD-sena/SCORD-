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
}