import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/jugador_model.dart';
import '../models/categoria_model.dart';
import '../models/tipo_documento_model.dart';
import '../models/persona_model.dart';

class JugadorService {
  final String _baseUrl = ApiConfig.baseUrl; // Usamos la URL base

  // === FETCH JUGADORES (CON DEBUGGING) ===
  Future<List<Jugador>> fetchJugadores() async {
    try {
      final url = Uri.parse('$_baseUrl/jugadores');
      final response = await http.get(url);
      
      // 🚀 DEBUG: Muestra la URL y el código de estado
      print('DEBUG - URL Jugadores: $url');
      print('DEBUG - Status Code Jugadores: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        // Muestra los primeros 100 caracteres del JSON para verificar el formato
        print('DEBUG - Body Jugadores (OK - First 100 chars): ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}...');
        
        // ⚠️ Nota: Asumiendo que tu API Laravel devuelve un array directo de jugadores
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Jugador.fromJson(json)).toList();
      } else {
        // La API devolvió un error (ej. 404, 500)
        print('DEBUG - Error Body Jugadores: ${response.body}');
        throw Exception('Failed to load jugadores. Status: ${response.statusCode}');
      }
    } catch (e) {
      // Error de conexión (ej. SocketException)
      print('❌ ERROR CONEXIÓN Jugadores: $e');
      throw Exception('Error de red al cargar jugadores: $e');
    }
  }

  // === FETCH CATEGORIAS (CON DEBUGGING) ===
  Future<List<Categoria>> fetchCategorias() async {
    try {
      final url = Uri.parse('$_baseUrl/categorias');
      final response = await http.get(url);
      
      print('DEBUG - URL Categorias: $url');
      print('DEBUG - Status Code Categorias: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('DEBUG - Body Categorias (OK - First 100 chars): ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}...');
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Categoria.fromJson(json)).toList();
      } else {
        print('DEBUG - Error Body Categorias: ${response.body}');
        throw Exception('Failed to load categorias. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR CONEXIÓN Categorias: $e');
      throw Exception('Error de red al cargar categorías: $e');
    }
  }

  // === FETCH TIPOS DOCUMENTO (CON DEBUGGING) ===
  Future<List<TipoDocumento>> fetchTiposDocumento() async {
    try {
      final url = Uri.parse('$_baseUrl/tiposdedocumentos');
      final response = await http.get(url);
      
      print('DEBUG - URL Tipos Documento: $url');
      print('DEBUG - Status Code Tipos Documento: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('DEBUG - Body Tipos Documento (OK - First 100 chars): ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}...');
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => TipoDocumento.fromJson(json)).toList();
      } else {
        print('DEBUG - Error Body Tipos Documento: ${response.body}');
        throw Exception('Failed to load tipos de documento. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR CONEXIÓN Tipos Documento: $e');
      throw Exception('Error de red al cargar tipos de documento: $e');
    }
  }

  // === ✅ NUEVO MÉTODO: POST /personas (Crear Persona) ===
  Future<int> createPersona(Map<String, dynamic> personaData) async {
    final url = Uri.parse('$_baseUrl/personas');
    print('DEBUG - URL POST Persona: $url');
    print('DEBUG - Body POST Persona: ${jsonEncode(personaData)}');

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(personaData),
    );
    
    print('DEBUG - Status Code POST Persona: ${response.statusCode}');

    if (response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      
      // ⚠️ Extracción del ID: Ajustado para buscar en data.idPersonas
      // Basado en tu código React: { message, data: { idPersonas: 123 }, status }
      if (jsonResponse['data'] != null && jsonResponse['data']['idPersonas'] != null) {
        final id = jsonResponse['data']['idPersonas'];
        // Aseguramos que se devuelva un int (maneja si es string o int)
        if (id is int) return id;
        if (id is String) return int.parse(id);
      }
      
      // Si no se encuentra el ID o el formato es inesperado
      throw Exception('Persona creada, pero no se pudo obtener el ID de respuesta (idPersonas no encontrado).');

    } else {
      String errorMsg = 'No se pudo crear la persona.';
      try {
        final errorData = json.decode(response.body);
        if (errorData['errors'] != null) {
          // Si hay errores de validación (ej. documento/correo duplicado)
          errorMsg = 'Error de validación:\n' + errorData['errors'].values.expand((e) => e).join('\n');
        } else if (errorData['message'] != null) {
          errorMsg = errorData['message'];
        }
      } catch (_) {
        errorMsg = 'Error ${response.statusCode}: ${response.body}';
      }
      throw Exception(errorMsg);
    }
  }

  // === ✅ NUEVO MÉTODO: POST /jugadores (Crear Jugador) ===
  Future<void> createJugador(Map<String, dynamic> jugadorData) async {
    final url = Uri.parse('$_baseUrl/jugadores');
    print('DEBUG - URL POST Jugador: $url');
    print('DEBUG - Body POST Jugador: ${jsonEncode(jugadorData)}');

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(jugadorData),
    );
    
    print('DEBUG - Status Code POST Jugador: ${response.statusCode}');

    if (response.statusCode != 201) {
      String errorMsg = 'No se pudo crear el jugador.';
      try {
        final errorData = json.decode(response.body);
        if (errorData['errors'] != null) {
          errorMsg = 'Error de validación:\n' + errorData['errors'].values.expand((e) => e).join('\n');
        } else if (errorData['message'] != null) {
          errorMsg = errorData['message'];
        }
      } catch (_) {
        errorMsg = 'Error ${response.statusCode}: ${response.body}';
      }
      throw Exception(errorMsg);
    }
  }
  
  // === UPDATE PERSONA (CON DEBUGGING) ===
  Future<void> updatePersona(int idPersona, Persona personaData, {String? contrasena}) async {
    // ... (El código de updatePersona se mantiene)
    try {
      final url = Uri.parse('$_baseUrl/personas/$idPersona');
      final response = await http.put(
          url,
          headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(personaData.toJson(contrasena: contrasena)),
      );

      print('DEBUG - URL Update Persona: $url');
      print('DEBUG - Status Code Update Persona: ${response.statusCode}');
      
      if (response.statusCode != 200) {
          final errorData = json.decode(response.body);
          String errorMsg = 'No se pudo actualizar la persona.';
          if (errorData['errors'] != null) {
              errorMsg = errorData['errors'].values.expand((e) => e).join('\n');
          } else if (errorData['message'] != null) {
              errorMsg = errorData['message'];
          }
          throw Exception(errorMsg);
      }
    } catch (e) {
      print('❌ ERROR Update Persona: $e');
      throw Exception('Error al actualizar persona: $e');
    }
  }

  // === UPDATE JUGADOR (CON DEBUGGING) ===
  Future<void> updateJugador(int idJugador, Jugador jugadorData) async {
    // ... (El código de updateJugador se mantiene)
    try {
      final url = Uri.parse('$_baseUrl/jugadores/$idJugador');
      final response = await http.put(
          url,
          headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(jugadorData.toJson()),
      );
      
      print('DEBUG - URL Update Jugador: $url');
      print('DEBUG - Status Code Update Jugador: ${response.statusCode}');

      if (response.statusCode != 200) {
          final errorData = json.decode(response.body);
          String errorMsg = 'No se pudo actualizar el jugador.';
          if (errorData['errors'] != null) {
              errorMsg = errorData['errors'].values.expand((e) => e).join('\n');
          } else if (errorData['message'] != null) {
              errorMsg = errorData['message'];
          }
          throw Exception(errorMsg);
      }
    } catch (e) {
      print('❌ ERROR Update Jugador: $e');
      throw Exception('Error al actualizar jugador: $e');
    }
  }

  // === DELETE JUGADOR (CON DEBUGGING) ===
  Future<void> deleteJugador(int idJugador) async {
    // ... (El código de deleteJugador se mantiene)
    try {
      final url = Uri.parse('$_baseUrl/jugadores/$idJugador');
      final response = await http.delete(url);

      print('DEBUG - URL Delete Jugador: $url');
      print('DEBUG - Status Code Delete Jugador: ${response.statusCode}');

      if (response.statusCode != 200) {
          throw Exception('Failed to delete jugador. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR Delete Jugador: $e');
      throw Exception('Error al eliminar jugador: $e');
    }
  }
}