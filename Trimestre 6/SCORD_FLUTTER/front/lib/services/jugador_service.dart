import 'dart:convert';
import '../models/jugador_model.dart';
import '../models/categoria_model.dart';
import '../models/tipo_documento_model.dart';
import '../models/persona_model.dart';
import 'api_service.dart';

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

  Future<List<Categoria>> fetchCategorias() async {
    final response = await _apiService.get('/categorias');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data as List).map((c) => Categoria.fromJson(c)).toList();
    } else {
      throw Exception('Error al obtener categorías');
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
  // Obtener jugadores filtrados por categorías del entrenador
Future<List<Jugador>> fetchJugadoresByCategoriasEntrenador(List<int> idsCategorias) async {
  try {
    // Obtener todos los jugadores
    final todosLosJugadores = await fetchJugadores();
    
    // Filtrar por las categorías del entrenador
    final jugadoresFiltrados = todosLosJugadores
        .where((jugador) => idsCategorias.contains(jugador.idCategorias))
        .toList();
    
    return jugadoresFiltrados;
  } catch (e) {
    throw Exception('Error al obtener jugadores del entrenador: $e');
  }
}

// Obtener jugador por idPersona (para el usuario logueado)
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
        
        // Buscar el jugador que tenga el idPersonas coincidente
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
}