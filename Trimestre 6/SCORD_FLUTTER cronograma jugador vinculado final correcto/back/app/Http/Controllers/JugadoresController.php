<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Jugadores;
use Illuminate\Support\Facades\Validator;
use Carbon\Carbon;

class JugadoresController extends Controller
{
    /**
     * Listar jugadores activos (no eliminados)
     */
    public function index()
{
    $jugadores = Jugadores::with([
                          'persona' => function($query) {
                              $query->withTrashed();
                          },
                          'persona.tiposDeDocumentos',
                          'categoria'
                      ])
                      ->get();
    
    // ====== CAMBIO: Devolver array vacío en lugar de 404 ======
    if($jugadores->isEmpty()){
        return response()->json([], 200); // ← Array vacío con status 200
    }

    // ====== CONVERTIR A ARRAY Y AGREGAR ATRIBUTOS CALCULADOS ======
    $jugadores = $jugadores->map(function ($jugador) {
        $data = $jugador->toArray();
        
        // Forzar inclusión de atributos calculados
        $data['tiempo_en_club'] = $jugador->tiempo_en_club;
        $data['dias_para_vencimiento'] = $jugador->dias_para_vencimiento;
        $data['mensualidad_vencida'] = $jugador->mensualidad_vencida;
        $data['estado_pago'] = $jugador->estado_pago;
        
        return $data;
    });

    return response()->json($jugadores, 200);
}

    /**
     * NUEVO: Listar jugadores eliminados (papelera)
     */
    public function trashed()
    {
        $jugadores = Jugadores::onlyTrashed()
                              ->with(['persona.tiposDeDocumentos', 'categoria'])
                              ->get();

        if ($jugadores->isEmpty()) {
            return response()->json([
                'message' => 'No hay jugadores eliminados',
                'status' => 404
            ], 404);
        }

        $jugadores = $jugadores->map(function ($jugador) {
            $data = $jugador->toArray();
            
            $data['tiempo_en_club'] = $jugador->tiempo_en_club;
            $data['dias_para_vencimiento'] = $jugador->dias_para_vencimiento;
            $data['mensualidad_vencida'] = $jugador->mensualidad_vencida;
            $data['estado_pago'] = $jugador->estado_pago;
            
            return $data;
        });

        return response()->json([
            'data' => $jugadores,
            'status' => 200
        ], 200);
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
            'fechaIngresoClub' => 'nullable|date',
            'fechaVencimientoMensualidad' => 'nullable|date',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Errores de validacion',
                'errors' => $validator->errors()
            ], 422);
        }

        $data = $request->all();
        if (!isset($data['fechaIngresoClub'])) {
            $data['fechaIngresoClub'] = Carbon::now()->toDateString();
        }
        if (!isset($data['fechaVencimientoMensualidad'])) {
            $data['fechaVencimientoMensualidad'] = Carbon::now()->addMonth()->toDateString();
        }

        $jugadores = Jugadores::create($data);
        
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

        // ====== CONVERTIR A ARRAY Y AGREGAR ATRIBUTOS CALCULADOS ======
        $response = $jugadores->toArray();
        
        // Forzar inclusion de atributos calculados
        $response['tiempo_en_club'] = $jugadores->tiempo_en_club;
        $response['dias_para_vencimiento'] = $jugadores->dias_para_vencimiento;
        $response['mensualidad_vencida'] = $jugadores->mensualidad_vencida;
        $response['estado_pago'] = $jugadores->estado_pago;

        return response()->json($response, 200);
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
            'fechaIngresoClub' => 'sometimes|date',
            'fechaVencimientoMensualidad' => 'sometimes|date',
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

    /**
     * MODIFICADO: Eliminar jugador (soft delete)
     */
    public function destroy($id)
    {
        $jugadores = Jugadores::find($id);

        if (!$jugadores) {
            return response()->json(['message' => 'Jugador no encontrado'], 404);
        }

        // Soft delete - solo pone fecha en deleted_at
        $jugadores->delete();

        return response()->json([
            'message' => 'Jugador eliminado correctamente (movido a papelera)'
        ], 200);
    }

    /**
     * NUEVO: Restaurar jugador eliminado
     */
    public function restore($id)
    {
        $jugadores = Jugadores::onlyTrashed()->find($id);

        if (!$jugadores) {
            return response()->json([
                'message' => 'Jugador no encontrado en papelera',
                'status' => 404
            ], 404);
        }

        $jugadores->restore();

        return response()->json([
            'message' => 'Jugador restaurado correctamente',
            'data' => $jugadores,
            'status' => 200
        ], 200);
    }

    /**
     * NUEVO: Eliminar permanentemente
     */
    public function forceDelete($id)
    {
        $jugadores = Jugadores::onlyTrashed()->find($id);

        if (!$jugadores) {
            return response()->json([
                'message' => 'Jugador no encontrado en papelera',
                'status' => 404
            ], 404);
        }

        $jugadores->forceDelete(); // Eliminación permanente

        return response()->json([
            'message' => 'Jugador eliminado permanentemente',
            'status' => 200
        ], 200);
    }


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
                    'message' => 'No se encontro registro de jugador para este usuario',
                    'status' => 404
                ], 404);
            }
            
            $response = [
                'Nombre1' => $jugador->persona->Nombre1,
                'Nombre2' => $jugador->persona->Nombre2,
                'Apellido1' => $jugador->persona->Apellido1,
                'Apellido2' => $jugador->persona->Apellido2,
                'FechaDeNacimiento' => $jugador->persona->FechaDeNacimiento,
                'Genero' => $jugador->persona->Genero,
                'Telefono' => $jugador->persona->Telefono,
                'correo' => $jugador->persona->correo,
                'Direccion' => $jugador->persona->Direccion,
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
                'Categoria' => $jugador->categoria->Descripcion ?? null,
                'idCategorias' => $jugador->idCategorias,
                'fechaIngresoClub' => $jugador->fechaIngresoClub 
                    ? $jugador->fechaIngresoClub->format('Y-m-d') 
                    : null,
                'tiempoEnClub' => $jugador->tiempo_en_club,
                'fechaVencimientoMensualidad' => $jugador->fechaVencimientoMensualidad 
                    ? $jugador->fechaVencimientoMensualidad->format('Y-m-d') 
                    : null,
                'diasParaVencimiento' => $jugador->dias_para_vencimiento,
                'mensualidadVencida' => $jugador->mensualidad_vencida,
                'estadoPago' => $jugador->estado_pago,
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

    public function registrarPago($id)
    {
        try {
            $persona = auth()->user();
            
            if (!$persona || !$persona->isAdmin()) {
                return response()->json([
                    'message' => 'No tienes permisos para realizar esta accion',
                    'status' => 403
                ], 403);
            }

            $jugador = Jugadores::find($id);

            if (!$jugador) {
                return response()->json([
                    'message' => 'Jugador no encontrado',
                    'status' => 404
                ], 404);
            }

            $jugador->registrarPago();
            $jugador->load(['persona.tiposDeDocumentos', 'categoria']);

            // ====== RESPUESTA CON ATRIBUTOS CALCULADOS ======
            $response = $jugador->toArray();
            $response['tiempo_en_club'] = $jugador->tiempo_en_club;
            $response['dias_para_vencimiento'] = $jugador->dias_para_vencimiento;
            $response['mensualidad_vencida'] = $jugador->mensualidad_vencida;
            $response['estado_pago'] = $jugador->estado_pago;

            return response()->json([
                'message' => 'Pago registrado exitosamente',
                'data' => $response,
                'nueva_fecha_vencimiento' => $jugador->fechaVencimientoMensualidad->format('Y-m-d')
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error al registrar pago',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}