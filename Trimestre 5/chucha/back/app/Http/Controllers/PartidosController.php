<?php

namespace App\Http\Controllers;
use App\Models\Partidos;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class PartidosController extends Controller
{
    public function index()
    {
        $Partidos = Partidos::all();

        if ($Partidos->isEmpty()) {
            return response()->json([
                'message' => 'No se encontraron partidos',
                'status' => 404
            ], 404);
        }

        return response()->json($Partidos, 200);
    }

    public function show($id)
    {
        $Partidos = Partidos::find($id);

        if (!$Partidos) {
            return response()->json([
                'message' => 'partido no encontrado',
                'status' => 404
            ], 404);
        }

        return response()->json($Partidos, 200);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [   
            'Formacion' => 'required|string|max:50',
            'EquipoRival' => 'required|string|max:50',
            'idCronogramas' => 'required|integer'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

        $Partidos = Partidos::create($request->only([
            'Formacion',
            'EquipoRival',
            'idCronogramas'
        ]));

        $Partidos->refresh();

        return response()->json([
            'message' => 'información del partido creada exitosamente',
            'data' => $Partidos
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $Partidos = Partidos::find($id);

        if (!$Partidos) {
            return response()->json([
                'message' => 'partido no encontrado',
                'status' => 404
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'Formacion' => 'sometimes|required|string|max:50',
            'EquipoRival' => 'sometimes|required|string|max:50',
            'idCronogramas' => 'sometimes|required|integer'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

        $Partidos->update($request->only([
            'Formacion',
            'EquipoRival',
            'idCronogramas'
        ]));

        return response()->json([
            'message' => 'información del partido actualizada exitosamente',
            'data' => $Partidos
        ], 200);
    }

    public function destroy($id)
    {
        $Partidos = Partidos::find($id);

        if (!$Partidos) {
            return response()->json([
                'message' => 'partido no encontrado',
                'status' => 404
            ], 404);
        }

        $Partidos->delete();

        return response()->json([
            'message' => 'información del partido eliminada exitosamente'
        ], 200);
    }
}