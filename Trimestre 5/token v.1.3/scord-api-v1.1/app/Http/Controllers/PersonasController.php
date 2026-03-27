<?php

namespace App\Http\Controllers;

use App\Models\Personas;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class PersonasController extends Controller
{
    public function index()
    {
        $personas = Personas::all();

        if ($personas->isEmpty()) {
            return response()->json([
                'message' => 'No se encontraron personas',
                'status' => 404
            ], 404);
        }

        return response()->json($personas, 200);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'NumeroDeDocumento' => 'required|unique:Personas',
            'Nombre1' => 'required|string|max:30',
            'Nombre2'=>'required|string|max:30',
            'Apellido1' => 'required|string|max:30',
            'Apellido2' => 'required|string|max:30',
            'FechaDeNacimiento' => 'required|date',
            'Genero' => 'required|string|max:9',
            'EpsSisben'=>'required|string|max:38',
            'Direccion'=>'required|string|max:40',
            'Telefono' => 'required|string|max:10',
            'correo' => 'required|email|unique:Personas',
            'contraseña' => 'required|max:255|confirmed',
            'idTiposDeDocumentos' => 'required|exists:TiposDeDocumentos,idTiposDeDocumentos',
            'idRoles' => 'required|exists:Roles,idRoles',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

         // 🔒 Encriptar contraseña
    $data = $request->all();
    $data['contraseña'] = bcrypt($data['contraseña']);

    $personas = Personas::create($data);

        return response()->json([
            'message' => 'Persona creada exitosamente',
            'data' => $personas
        ], 201);
    }

    public function show($id)
    {
        $personas = Personas::find($id);

        if (!$personas) {
            return response()->json([
                'message' => 'Persona no encontrada',
                'status' => 404
            ], 404);
        }

        return response()->json($personas, 200);
    }

    public function update(Request $request, $id)
    {
        $personas = Personas::find($id);

        if (!$personas) {
            return response()->json(['message' => 'Persona no encontrada'], 404);
        }

        $validator = Validator::make($request->all(), [
            'NumeroDeDocumento' => 'sometimes|integer',
            'Nombre1' => 'sometimes|string|max:30',
            'Nombre2' => 'sometimes|string|max:30',
            'Apellido1' => 'sometimes|string|max:30',
            'Apellido2' => 'sometimes|string|max:30',
            'Genero' => 'sometimes|string|max:9',
            'Telefono' => 'sometimes|string|max:10',
            'EpsSisben'=> 'sometimes|string|max:38',
            'Direccion' => 'sometimes|string|max:40',
            'FechaDeNacimiento' => 'sometimes|date',
            'correo' => 'sometimes|email|unique:personas,correo,' . $personas->id,
            'contraseña' => 'sometimes|string|max:255|confirmed',
            'idTiposDeDocumentos' => 'sometimes|integer|exists:tiposdedocumentos,idTiposDeDocumentos',
            'idRoles'=> 'sometimes|integer|exists|Roles,idRoles',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $personas->update($request->all());

        return response()->json([
            'message' => 'Persona actualizada correctamente',
            'data' => $personas
        ], 200);
    }

    public function destroy($id)
    {
        $personas = Personas::find($id);

        if (!$personas) {
            return response()->json([
                'message' => 'Persona no eliminada',
                'status'=>'404'
            ], 404);
        }

        $personas->delete();

        return response()->json([
            'message' => 'Persona eliminada correctamente'
        ], 200);
    }
}
