<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\TipoDeDocumento;

class TiposDeDocumentosController extends Controller
{
    public function index()
    {
        $tiposdedocumentos = TipoDeDocumento::all();

        if($tiposdedocumentos->isEmpty()){
            return response()->json([
                'message'=>'no se encontraron tipos de documentos',
                'status'=>'400'
            ],400);
        }
        return response()->json($tiposdedocumentos,200);
    }
    
    public function store(Request $request)
    {
        // Validar los datos de entrada
        $validated = $request->validate([
            'Descripcion' => 'required|string|max:50|unique:tiposdedocumentos,Descripcion',
        ]);

        // Crear el registro
        $tiposdedocumentos = TipoDeDocumento::create($validated);

        // Respuesta en JSON
        return response()->json([
            'message' => 'Tipo de documento creado con éxito',
            'data' => $tiposdedocumentos
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $tiposdedocumentos = TipoDeDocumento::findOrFail($id);

        // Validación con unique, ignorando el mismo registro
        $validated = $request->validate([
            'Descripcion' => 'required|string|max:50|unique:tiposdedocumentos,Descripcion,' . $tiposdedocumentos->idTiposDeDocumentos . ',idTiposDeDocumentos',
        ]);

        $tiposdedocumentos->update($validated);

        return response()->json([
            'message' => 'Tipo de documento actualizado con éxito',
            'data' => $tiposdedocumentos
        ]);
    }

    public function destroy($id)
    {
        $tiposdedocumentos = TipoDeDocumento::find($id);

        if (!$tiposdedocumentos) {
            return response()->json([
                'message' => 'Tipo de documento no encontrado',
            ], 404);
        }

        // Verificar si hay personas asociadas
        if ($tiposdedocumentos->personas()->exists()) {
            return response()->json([
                'message' => 'No se puede eliminar: existen personas asociadas a este tipo de documento',
            ], 400);
        }

        $tiposdedocumentos->delete();

        return response()->json([
            'message' => 'Tipo de documento eliminado con éxito',
        ], 200);
    }
}
