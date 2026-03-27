<?php

namespace App\Http\Controllers;

use App\Models\Entrenadores;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class EntrenadoresController extends Controller
{
    public function index()
    {
        $entrenadores = Entrenadores::all();

        if ($entrenadores->isEmpty()) {
            return response()->json([
                'message' => 'No se encontraron entrenadores',
                'status' => 404
            ], 404);
        }

        return response()->json($entrenadores, 200);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'idEntrenadores'=>'required|integer',
            'NumeroDeDocumento'=>'required|integer',
            'AnosDeExperiencia'=>'required|integer',
            'Cargo' => 'required|string|max:30',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

        $entrenadores = Entrenadores::create($request->all());

        return response()->json([
            'message' => 'Entrenador creado exitosamente',
            'data' => $entrenadores
        ], 201);
    }

    public function show($id)
    {
        $entrenadores = Entrenadores::find($id);

        if (!$entrenadores) {
            return response()->json([
                'message' => 'Entrenador no encontrado',
                'status' => 404
            ], 404);
        }

        return response()->json($entrenadores, 200);
    }

    public function update(Request $request, $id)
    {
        $entrenadores = Entrenadores::find($id);

        if (!$entrenadores) {
            return response()->json(['message' => 'Entrenador no encontrado'], 404);
        }

        $validator = Validator::make($request->all(), [
            'idEntrenadores'=>'sometimes|integer',
            'NumeroDeDocumento' => 'sometimes|integer',
            'AnosDeExperiencia' => 'sometimes|integer',
            'Cargo' => 'sometimes|string|max:30',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $entrenadores->update($request->all());

        return response()->json([
            'message' => 'Entrenador actualizado correctamente',
            'data' => $entrenadores
        ], 200);
    }

    public function destroy($id)
    {
        $entrenadores = Entrenadores::find($id);

        if (!$entrenadores) {
            return response()->json(['message' => 'Entrenador no encontrado'], 404);
        }

        $entrenadores->delete();

        return response()->json([
            'message' => 'Entrenador eliminado correctamente'
        ], 200);
    }
}
