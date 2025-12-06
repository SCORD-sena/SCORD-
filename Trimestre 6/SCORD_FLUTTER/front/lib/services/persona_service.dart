import 'dart:convert';
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
}