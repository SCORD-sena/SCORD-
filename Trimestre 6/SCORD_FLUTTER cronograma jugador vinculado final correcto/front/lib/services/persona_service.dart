import 'dart:convert';
import 'api_service.dart';
import '../models/persona_model.dart';

class PersonaService {
  final ApiService _apiService = ApiService();

  // Actualizar persona
  Future<bool> updatePersona(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('/personas/$id', data);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error al actualizar persona');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Crear persona
 Future<Map<String, dynamic>> createPersona(Map<String, dynamic> data) async {
  try {
    print('📤 Enviando a /personas:');
    print('Body: ${json.encode(data)}'); // ← AGREGAR ESTO
    
    final response = await _apiService.post('/personas', data);
    
    print('📥 Status: ${response.statusCode}'); // ← AGREGAR ESTO
    print('📥 Response: ${response.body}'); // ← AGREGAR ESTO

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      print('❌ Error del backend: $errorData'); // ← AGREGAR ESTO
      throw Exception(errorData['message'] ?? 'Error al crear persona');
    }
  } catch (e) {
    print('❌ Error completo: $e'); // ← YA LO TIENES
    throw Exception('Error de conexión: $e');
  }
}

  // ====== NUEVOS MÉTODOS PARA HISTORIAL ======

  // Obtener personas eliminadas (papelera)
  Future<List<Persona>> fetchPersonasEliminadas() async {
    try {
      final response = await _apiService.get('/personas/trashed');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        List<dynamic> personasList;
        if (data is Map && data.containsKey('data')) {
          personasList = data['data'] as List;
        } else {
          personasList = data as List;
        }
        
        return personasList.map((p) => Persona.fromJson(p)).toList();
      } else if (response.statusCode == 404) {
        // No hay personas eliminadas
        return [];
      } else {
        throw Exception('Error al obtener personas eliminadas: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en fetchPersonasEliminadas: $e');
      rethrow;
    }
  }

  // Restaurar persona eliminada
  Future<bool> restaurarPersona(int id) async {
    try {
      final response = await _apiService.post('/personas/$id/restore', {});

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error al restaurar persona');
      }
    } catch (e) {
      print('Error en restaurarPersona: $e');
      throw Exception('Error al restaurar persona: $e');
    }
  }

  // Eliminar permanentemente
  Future<bool> eliminarPermanentemente(int id) async {
    try {
      final response = await _apiService.delete('/personas/$id/force');

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error al eliminar permanentemente');
      }
    } catch (e) {
      print('Error en eliminarPermanentemente: $e');
      throw Exception('Error al eliminar: $e');
    }
  }

  // Cambiar status de una persona
  Future<bool> cambiarStatus(int id, String nuevoStatus) async {
    try {
      final response = await _apiService.patch('/personas/$id/status', {
        'status': nuevoStatus,
      });

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error al cambiar status');
      }
    } catch (e) {
      print('Error en cambiarStatus: $e');
      throw Exception('Error al cambiar status: $e');
    }
  }
}