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

    /**
     * ✅ NUEVO MÉTODO: Obtener perfil simplificado del jugador autenticado (para estadísticas)
     * Este método devuelve solo los datos esenciales necesarios para cargar estadísticas
     */
    public function miPerfil()
    {
        try {
            $persona = auth()->user();
            
            if (!$persona) {
                return response()->json([
                    'success' => false,
                    'message' => 'Usuario no autenticado'
                ], 401);
            }
            
            // Buscar el jugador asociado al usuario autenticado
            $jugador = Jugadores::where('idPersonas', $persona->idPersonas)
                ->with('persona')
                ->first();
            
            if (!$jugador) {
                return response()->json([
                    'success' => false,
                    'message' => 'No se encontró información del jugador'
                ], 404);
            }
            
            return response()->json([
                'success' => true,
                'data' => $jugador
            ], 200);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al obtener el perfil del jugador',
                'error' => $e->getMessage()
            ], 500);
        }
    }



    /**
 * Comparar estadísticas entre dos jugadores
 * 
 * @param Request $request
 * @return \Illuminate\Http\JsonResponse
    */
public function compararJugadores(Request $request)
{
    try {
        $validator = Validator::make($request->all(), [
            'idJugador1' => 'required|integer|exists:Jugadores,idJugadores',
            'idJugador2' => 'required|integer|exists:Jugadores,idJugadores',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

        $idJugador1 = $request->idJugador1;
        $idJugador2 = $request->idJugador2;

        // Obtener estadísticas del jugador 1
        $estadisticas1 = \App\Models\RendimientosPartidos::where('idJugadores', $idJugador1)
            ->selectRaw('
                COUNT(*) as PartidosJugados,
                COALESCE(SUM(Goles), 0) as Goles,
                COALESCE(SUM(GolesDeCabeza), 0) as GolesDeCabeza,
                COALESCE(SUM(Asistencias), 0) as Asistencias,
                COALESCE(SUM(TirosApuerta), 0) as TirosApuerta,
                COALESCE(SUM(FuerasDeJuego), 0) as FuerasDeJuego,
                COALESCE(SUM(TarjetasAmarillas), 0) as TarjetasAmarillas,
                COALESCE(SUM(TarjetasRojas), 0) as TarjetasRojas
            ')
            ->first();

        // Obtener estadísticas del jugador 2
        $estadisticas2 = \App\Models\RendimientosPartidos::where('idJugadores', $idJugador2)
            ->selectRaw('
                COUNT(*) as PartidosJugados,
                COALESCE(SUM(Goles), 0) as Goles,
                COALESCE(SUM(GolesDeCabeza), 0) as GolesDeCabeza,
                COALESCE(SUM(Asistencias), 0) as Asistencias,
                COALESCE(SUM(TirosApuerta), 0) as TirosApuerta,
                COALESCE(SUM(FuerasDeJuego), 0) as FuerasDeJuego,
                COALESCE(SUM(TarjetasAmarillas), 0) as TarjetasAmarillas,
                COALESCE(SUM(TarjetasRojas), 0) as TarjetasRojas
            ')
            ->first();

        return response()->json([
            'success' => true,
            'jugador1' => $estadisticas1,
            'jugador2' => $estadisticas2,
            'diferencias' => [
                'Goles' => ($estadisticas1->Goles ?? 0) - ($estadisticas2->Goles ?? 0),
                'GolesDeCabeza' => ($estadisticas1->GolesDeCabeza ?? 0) - ($estadisticas2->GolesDeCabeza ?? 0),
                'Asistencias' => ($estadisticas1->Asistencias ?? 0) - ($estadisticas2->Asistencias ?? 0),
                'TirosApuerta' => ($estadisticas1->TirosApuerta ?? 0) - ($estadisticas2->TirosApuerta ?? 0),
                'FuerasDeJuego' => ($estadisticas1->FuerasDeJuego ?? 0) - ($estadisticas2->FuerasDeJuego ?? 0),
                'PartidosJugados' => ($estadisticas1->PartidosJugados ?? 0) - ($estadisticas2->PartidosJugados ?? 0),
                'TarjetasAmarillas' => ($estadisticas1->TarjetasAmarillas ?? 0) - ($estadisticas2->TarjetasAmarillas ?? 0),
                'TarjetasRojas' => ($estadisticas1->TarjetasRojas ?? 0) - ($estadisticas2->TarjetasRojas ?? 0),
            ]
        ], 200);

    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'message' => 'Error al comparar jugadores',
            'error' => $e->getMessage()
        ], 500);
    }
}
}