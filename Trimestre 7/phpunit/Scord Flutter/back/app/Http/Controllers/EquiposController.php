<?php

namespace App\Http\Controllers;
use App\Models\Equipos;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class EquiposController extends Controller
{
    public function index()
    {
        $Equipos = Equipos::all();

        if ($Equipos->isEmpty()) {
            return response()->json([
                'message' => 'No se encontraron equipos',
                'status' => 404
            ], 404);
        }

        return response()->json($Equipos, 200);
    }

    public function show($id)
    {
        $Equipos = Equipos::find($id);

        if (!$Equipos) {
            return response()->json([
                'message' => 'Equipo no encontrado',
                'status' => 404
            ], 404);
        }

        return response()->json($Equipos, 200);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'CantidadJugadores' => 'required|integer',
            'Sub' => 'required|string|max:15',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

        $Equipos = Equipos::create($request->only([
            'CantidadJugadores',
            'Sub'
        ]));

        return response()->json([
            'message' => 'Equipo creado exitosamente',
            'data' => $Equipos->refresh()
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $Equipos = Equipos::find($id);

        if (!$Equipos) {
            return response()->json([
                'message' => 'Equipo no encontrado',
                'status' => 404
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'CantidadJugadores' => 'sometimes|integer',
            'Sub' => 'sometimes|string|max:15',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

        $Equipos->update($request->only([
            'CantidadJugadores',
            'Sub'
        ]));

        return response()->json([
            'message' => 'Equipo actualizado exitosamente',
            'data' => $Equipos->refresh()
        ], 200);
    }

    public function destroy($id)
    {
        $Equipos = Equipos::find($id);

        if (!$Equipos) {
            return response()->json([
                'message' => 'no se pudo eliminar el equipo',
                'status' => 404
            ], 404);
        }

        $Equipos->delete();

        return response()->json([
            'message' => 'equipo eliminado exitosamente',
            'status' => 200
        ], 200);
    }
}