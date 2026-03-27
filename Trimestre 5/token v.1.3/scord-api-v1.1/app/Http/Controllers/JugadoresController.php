<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\jugadores;
use Illuminate\Support\Facades\Validator;



class JugadoresController extends Controller
{
    public function index()
    {
        $Jugadores = jugadores::all();
        if($Jugadores->isEmpty()){
            return response()->json([
                'message'=>'jugadores no encontrados',
                'status'=>'404'
            ],404);
    }
    return response()->json($Jugadores,201);
}
public function store(Request $request)
 {
        $validator = Validator::make($request->all(), [
            'Dorsal' => 'required|integer',
            'Posicion' => 'required|string|max:25',
            'upz'=> 'nullable|string|max:40',
            'Estatura'=> 'nullable|numeric',
            'NomTutor1'=> 'required|string||max:30',
            'NomTutor2'=> 'nullable|string|max:30',
            'ApeTutor1'=> 'required|string|max:30',
            'ApeTutor2'=> 'required|string|max:30',
            'TelefonoTutor' => 'required|integer',
            'idCategorias' => 'required|integer|exists:Categorias,idCategorias',
            'NumeroDeDocumento' => 'required|integer|exists:Personas,NumeroDeDocumento',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

        $jugador = Jugadores::create($request->all());

        return response()->json([
            'message' => 'Jugador creado exitosamente',
            'data' => $jugador
        ], 201);
    }

    public function show($id)
    {
        $jugador = Jugadores::find($id);

        if (!$jugador) {
            return response()->json([
                'message' => 'Jugador no encontrado',
                'status' => 404
            ], 404);
        }

        return response()->json($jugador, 200);
    }

    public function update(Request $request, $id)
    {
        $jugador = Jugadores::find($id);

        if (!$jugador) {
            return response()->json(['message' => 'Jugador no encontrado'], 404);
        }

        $validator = Validator::make($request->all(), [
            'Dorsal' => 'sometimes|integer',
            'Posicion' => 'sometimes|string|max:25',
            'upz'=> 'sometimes|string|max:40',
            'Estatura'=> 'sometimes|numeric',
            'NomTutor1'=> 'sometimes|string||max:30',
            'NomTutor2'=> 'sometimes|string|max:30',
            'ApeTutor1'=> 'sometimes|string|max:30',
            'ApeTutor2'=> 'sometimes|string|max:30',
            'TelefonoTutor' => 'sometimes|integer',
            'NumeroDeDocumento' => 'sometimes|integer|exists:Personas,NumeroDeDocumento',
            'idCategorias' => 'sometimes|integer|exists:categorias,idCategorias',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $jugador->update($request->all());

        return response()->json([
            'message' => 'Jugador actualizado correctamente',
            'data' => $jugador
        ], 200);
    }

    public function destroy($id)
    {
        $jugador = Jugadores::find($id);

        if (!$jugador) {
            return response()->json(['message' => 'Jugador no encontrado'], 404);
        }

        $jugador->delete();

        return response()->json([
            'message' => 'Jugador eliminado correctamente'
        ], 200);
    }
}

