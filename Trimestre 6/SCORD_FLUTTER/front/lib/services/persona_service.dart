import 'dart:convert';
import 'api_service.dart';

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
      final response = await _apiService.post('/personas', data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error al crear persona');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}