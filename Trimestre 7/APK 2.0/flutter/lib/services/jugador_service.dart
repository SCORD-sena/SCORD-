import 'dart:convert';
import '../models/jugador_model.dart';
import '../models/categoria_model.dart';
import '../models/tipo_documento_model.dart';
import '../models/persona_model.dart';
import 'api_service.dart';
import 'package:http/http.dart' as http;

class JugadorService {
  final ApiService _apiService = ApiService();

  Future<List<Jugador>> fetchJugadores() async {
    final response = await _apiService.get('/jugadores');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      List<dynamic> jugadoresList;
      if (data is Map && data.containsKey('data')) {
        jugadoresList = data['data'] as List;
      } else {
        jugadoresList = data as List;
      }
      
      return jugadoresList.map((j) => Jugador.fromJson(j)).toList();
    } else {
      throw Exception('Error al obtener jugadores: ${response.statusCode}');
    }
  }

  // ====== NUEVO: Obtener UN jugador por ID con datos completos ======
  Future<Jugador> show(int idJugador) async {
    try {   
      final response = await _apiService.get('/jugadores/$idJugador');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        return Jugador.fromJson(data);
      } else {
        throw Exception('Error al obtener jugador: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Obtener datos completos del jugador autenticado
  Future<Map<String, dynamic>?> fetchMisDatos() async {
    try {
      final response = await _apiService.get('/jugadores/misDatos');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        }
        
        return null;
      } else {
        throw Exception('Error al obtener mis datos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener datos del jugador: $e');
    }
  }
  /// Obtener jugadores por categoría específica
  Future<List<Jugador>> obtenerJugadoresPorCategoria(int id) async {
    try {
      final response = await _apiService.get('/categorias/$id/jugadores');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        List<dynamic> jugadoresList;
        if (data is Map && data.containsKey('data')) {
          jugadoresList = data['data'] as List;
        } else {
          jugadoresList = data as List;
        }
        
        return jugadoresList.map((j) => Jugador.fromJson(j)).toList();
      } else {
        throw Exception('Error al obtener jugadores por categoría: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener jugadores por categoría: $e');
    }
  }

  // ====== Registrar pago de mensualidad (solo admin) ======
  Future<Jugador> registrarPagoMensualidad(int idJugador) async {
    try {  
      final response = await _apiService.post(
        '/jugadores/$idJugador/registrar-pago',
        {},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['data'] != null) {
          return Jugador.fromJson(data['data']);
        } else {
          throw Exception('Respuesta invalida del servidor');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error al registrar pago');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Categoria>> fetchCategorias() async {
    final response = await _apiService.get('/categorias');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data as List).map((c) => Categoria.fromJson(c)).toList();
    } else {
      throw Exception('Error al obtener categorias');
    }
  }

  Future<List<TipoDocumento>> fetchTiposDocumento() async {
    final response = await _apiService.get('/tiposdedocumentos');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data as List).map((t) => TipoDocumento.fromJson(t)).toList();
    } else {
      throw Exception('Error al obtener tipos de documento');
    }
  }

  Future<void> updatePersona(int id, Persona persona, {String? contrasena}) async {
    final data = persona.toJson(contrasena: contrasena);
    final response = await _apiService.put('/personas/$id', data);

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar persona');
    }
  }

  Future<void> updateJugador(int id, Jugador jugador) async {
    final data = {
      'Dorsal': jugador.dorsal,
      'Posicion': jugador.posicion,
      'Upz': jugador.upz,
      'Estatura': jugador.estatura,
      'NomTutor1': jugador.nomTutor1,
      'NomTutor2': jugador.nomTutor2,
      'ApeTutor1': jugador.apeTutor1,
      'ApeTutor2': jugador.apeTutor2,
      'TelefonoTutor': jugador.telefonoTutor,
      'idCategorias': jugador.idCategorias,
    };
    
    final response = await _apiService.put('/jugadores/$id', data);

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar jugador');
    }
  }

  Future<int> createPersona(Map<String, dynamic> data) async {
  
  final response = await _apiService.post('/personas', data);
  

  if (response.statusCode == 201 || response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    return responseData['data']['idPersonas'] as int;
  } else {
    final errorData = jsonDecode(response.body);
    throw Exception(errorData['message'] ?? 'Error al crear persona');
  }
}

  Future<void> createJugador(Map<String, dynamic> data) async {
    final response = await _apiService.post('/jugadores', data);

    if (response.statusCode != 201 && response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Error al crear jugador');
    }
  }

  Future<void> deleteJugador(int id) async {
    final response = await _apiService.delete('/jugadores/$id');

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar jugador');
    }
  }

  Future<List<Jugador>> fetchJugadoresByCategoriasEntrenador(List<int> idsCategorias) async {
    try {
      final todosLosJugadores = await fetchJugadores();
      
      final jugadoresFiltrados = todosLosJugadores
          .where((jugador) => idsCategorias.contains(jugador.idCategorias))
          .toList();
      
      return jugadoresFiltrados;
    } catch (e) {
      throw Exception('Error al obtener jugadores del entrenador: $e');
    }
  }

  Future<Jugador?> fetchJugadorByPersonaId(int idPersona) async {
    try {
      final response = await _apiService.get('/jugadores');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        List<dynamic> jugadoresList;
        if (data is Map && data.containsKey('data')) {
          jugadoresList = data['data'] as List;
        } else {
          jugadoresList = data as List;
        }
        
        final jugadorData = jugadoresList.firstWhere(
          (j) => j['idPersonas'] == idPersona,
          orElse: () => null,
        );
        
        if (jugadorData != null) {
          return Jugador.fromJson(jugadorData);
        }
        
        return null;
      } else {
        throw Exception('Error al obtener jugador: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al buscar jugador: $e');
    }
  }
  // ====== NUEVOS MÉTODOS PARA HISTORIAL ======

  // Obtener jugadores eliminados (papelera)
  Future<List<Jugador>> fetchJugadoresEliminados() async {
    try {
      final response = await _apiService.get('/jugadores/trashed');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        List<dynamic> jugadoresList;
        if (data is Map && data.containsKey('data')) {
          jugadoresList = data['data'] as List;
        } else {
          jugadoresList = data as List;
        }
        
        return jugadoresList.map((j) => Jugador.fromJson(j)).toList();
      } else if (response.statusCode == 404) {
        // No hay jugadores eliminados
        return [];
      } else {
        throw Exception('Error al obtener jugadores eliminados: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Restaurar jugador eliminado
  Future<bool> restaurarJugador(int id) async {
    try {
      final response = await _apiService.post('/jugadores/$id/restore', {});

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error al restaurar jugador');
      }
    } catch (e) {
      throw Exception('Error al restaurar jugador: $e');
    }
  }

  // Eliminar permanentemente
  Future<bool> eliminarPermanentemente(int id) async {
    try {
      final response = await _apiService.delete('/jugadores/$id/force');

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error al eliminar permanentemente');
      }
    } catch (e) {
      throw Exception('Error al eliminar: $e');
    }
  }

  // Cambiar status de un jugador
  Future<bool> cambiarStatus(int id, String nuevoStatus) async {
    try {
      final response = await _apiService.patch('/jugadores/$id/status', {
        'status': nuevoStatus,
      });

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error al cambiar status');
      }
    } catch (e) {
      throw Exception('Error al cambiar status: $e');
    }
  }
}
