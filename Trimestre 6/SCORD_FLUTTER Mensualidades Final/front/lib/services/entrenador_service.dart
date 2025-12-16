import 'dart:convert';
import '../models/entrenador_model.dart';
import 'api_service.dart';

class EntrenadorService {
  final ApiService _apiService = ApiService();

  // Obtener todos los entrenadores
  Future<List<Entrenador>> getEntrenadores() async {
    try {
      final response = await _apiService.get('/entrenadores');

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

    // Crear entrenador
  Future<Map<String, dynamic>> createEntrenador(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/entrenadores', data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error al crear entrenador');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener un entrenador por ID de persona
Future<Entrenador?> getEntrenadorByPersonaId(int idPersona) async {
  try {
    final response = await _apiService.get('/entrenadores/persona/$idPersona');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      
      // ⬇️ CORREGIR: Extraer 'data' del response
      final entrenadorData = jsonResponse['data'];
      
      if (entrenadorData == null) {
        return null;
      }
      
      return Entrenador.fromJson(entrenadorData);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Error al obtener entrenador: ${response.statusCode}');
    }
  } catch (e) {
    return null;
  }
}

  // Obtener categoría del entrenador por ID de persona
  Future<String?> obtenerCategoriaEntrenador(int idPersona) async {
  try {
    final entrenador = await getEntrenadorByPersonaId(idPersona);
    
    if (entrenador != null && entrenador.categorias != null && entrenador.categorias!.isNotEmpty) {
      // Convertir la lista de categorías a un String separado por comas
      return entrenador.categorias!.map((cat) => cat.descripcion).join(', ');
    }
    
    return 'No asignada';
  } catch (e) {
    return 'No disponible';
  }
}

  // Actualizar entrenador
  Future<bool> updateEntrenador(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('/entrenadores/$id', data);

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
      final response = await _apiService.delete('/entrenadores/$id');

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