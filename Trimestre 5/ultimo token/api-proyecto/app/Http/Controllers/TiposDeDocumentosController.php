<?php

namespace App\Http\Controllers;

use App\Models\TipoDeDocumento;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class TiposDeDocumentosController extends Controller
{
    public function index()
    {
        $tiposdedocumentos = TipoDeDocumento::all();

        if ($tiposdedocumentos->isEmpty()) {
            return response()->json([
                'message' => 'No se encontraron tipos de documentos',
                'status' => 404
            ], 404);
        }

        return response()->json($tiposdedocumentos, 200);
    }

    public function store(Request $request)
    {
        // Validar los datos de entrada
        $validator = Validator::make($request->all(), [
            'Descripcion' => 'required|string|max:50|unique:tiposdedocumentos,Descripcion',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

        // Crear el nuevo tipo de documento
        $tiposdedocumentos = TipoDeDocumento::create($request->all());

        return response()->json([
            'message' => 'Tipo de documento creado exitosamente',
            'data' => $tiposdedocumentos
        ], 201);
    }

    public function show($id)
    {
        $tiposdedocumentos = TipoDeDocumento::find($id);

        if (!$tiposdedocumentos) {
            return response()->json([
                'message' => 'Tipo de documento no encontrado',
                'status' => 404
            ], 404);
        }

        return response()->json($tiposdedocumentos, 200);
    }

    public function update(Request $request, $id)
    {
        $tiposdedocumentos = TipoDeDocumento::find($id);

        if (!$tiposdedocumentos) {
            return response()->json(['message' => 'Tipo de documento no encontrado'], 404);
        }

        // Validación de los datos entrantes
        $validator = Validator::make($request->all(), [
            'Descripcion' => 'sometimes|string|max:50|unique:tiposdedocumentos,Descripcion,' . $tiposdedocumentos->idTiposDeDocumento,
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

        // Actualizar el tipo de documento
        $tiposdedocumentos->update($request->all());

        return response()->json([
            'message' => 'Tipo de documento actualizado correctamente',
            'data' => $tiposdedocumentos
        ], 200);
    }

    public function destroy($id)
    {
        $tiposdedocumentos = TipoDeDocumento::find($id);

        if (!$tiposdedocumentos) {
            return response()->json([
                'message' => 'Tipo de documento no encontrado',
                'status' => 404
            ], 404);
        }

        // Verificar si el tipo de documento tiene registros asociados (como personas)
        if ($tiposdedocumentos->personas()->exists()) {
            return response()->json([
                'message' => 'No se puede eliminar el tipo de documento, existen personas asociadas',
            ], 400);
        }

        $tiposdedocumentos->delete();

        return response()->json([
            'message' => 'Tipo de documento eliminado correctamente',
        ], 200);
    }
}
