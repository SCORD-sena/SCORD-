import 'dart:convert';
<<<<<<< HEAD
import 'api_service.dart';

class PersonaService {
  final ApiService _apiService = ApiService();

  // Actualizar persona
  Future<bool> updatePersona(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('/personas/$id', data);
=======
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class PersonaService {
  // Actualizar persona
  Future<bool> updatePersona(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/personas/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
>>>>>>> 77fbf37e833f546a83348df26e99d07ab761018b

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
<<<<<<< HEAD

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
=======
>>>>>>> 77fbf37e833f546a83348df26e99d07ab761018b
}