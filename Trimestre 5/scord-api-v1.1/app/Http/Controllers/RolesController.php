<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use App\Models\Roles;

class RolesController extends Controller
{
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'idRoles' => 'required|integer|in:1,2,3|unique:Roles,idRoles',
            'TipoDeRol' => 'required|string|max:13|unique:Roles',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

        $rol = Roles::create([
            'TipoDeRol' => $request->TipoDeRol,
            'idRoles' => $request->idRoles,
        ]);

        return response()->json([
            'message' => 'Rol registrado con éxito',
            'rol' => $rol
        ], 201);
    }

    public function index()
    {
        return response()->json(Roles::all());
    }

    public function show($id)
    {
        $rol = Roles::find($id);

        if (!$rol) {
            return response()->json(['message' => 'Rol no encontrado'], 404);
        }

        return response()->json($rol);
    }

    public function update(Request $request, $id)
    {
        $rol = Roles::find($id);

        if (!$rol) {
            return response()->json(['message' => 'Rol no encontrado'], 404);
        }

        $validator = Validator::make($request->all(), [
            'TipoDeRol' => 'required|string|max:13',
            'idRoles' => 'required|integer|unique:Roles,idRoles,' . $id . ',idRoles',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

        $rol->update([
            'TipoDeRol' => $request->TipoDeRol,
            'idRoles' => $request->idRoles,
        ]);

        return response()->json([
            'message' => 'Rol actualizado con éxito',
            'rol' => $rol
        ]);
    }

    public function destroy($id)
    {
        $rol = Roles::find($id);

        if (!$rol) {
            return response()->json(['message' => 'Rol no encontrado'], 404);
        }

        $rol->delete();

        return response()->json(['message' => 'Rol eliminado con éxito']);
    }
}
