import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/entrenador_model.dart';
import '../config/api_config.dart';

class EntrenadorService {
  // Obtener todos los entrenadores
  Future<List<Entrenador>> getEntrenadores() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/entrenadores'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        // Maneja tanto { data: [...] } como directamente [...]
        final List<dynamic> entrenadoresJson = 
            jsonResponse.containsKey('data') 
                ? jsonResponse['data'] 
                : jsonResponse as List<dynamic>;

        return entrenadoresJson
            .map((json) => Entrenador.fromJson(json))
            .toList();
      } else {
        throw Exception('Error al cargar entrenadores: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener un entrenador por ID
  Future<Entrenador> getEntrenadorById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/entrenadores/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return Entrenador.fromJson(jsonResponse);
      } else {
        throw Exception('Error al cargar entrenador: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Actualizar entrenador
  Future<bool> updateEntrenador(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/entrenadores/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error al actualizar entrenador');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Eliminar entrenador
  Future<bool> deleteEntrenador(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/entrenadores/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Error al eliminar entrenador: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}