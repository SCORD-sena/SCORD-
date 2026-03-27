import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/partido_model.dart';

class PartidoService {
  // Obtener token de autenticación
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Headers con autenticación
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ============================================================
  // MÉTODOS BÁSICOS (si no los tienes ya)
  // ============================================================

  Future<List<Partido>> getPartidos() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/partidos'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((json) => Partido.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar partidos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> deletePartido(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/partidos/$id'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar partido: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ============================================================
  // MÉTODOS PARA HISTORIAL DE PARTIDOS
  // ============================================================

  /// Obtener partidos eliminados (papelera)
  Future<List<Partido>> fetchPartidosEliminados() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/partidos/papelera/listar'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        
        List<dynamic> partidosList;
        if (data is Map && data.containsKey('data')) {
          partidosList = data['data'] as List;
        } else {
          partidosList = data as List;
        }

        return partidosList.map((p) => Partido.fromJson(p)).toList();
      } else if (response.statusCode == 404) {

        return [];
      } else {
        throw Exception('Error al obtener partidos eliminados: ${response.statusCode}');
      }
    } catch (e) {

      rethrow;
    }
  }

  /// Restaurar partido eliminado
  Future<bool> restaurarPartido(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/partidos/$id/restaurar'),
        headers: headers,
        body: json.encode({}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error al restaurar partido');
      }
    } catch (e) {
      throw Exception('Error al restaurar partido: $e');
    }
  }

  /// Eliminar partido permanentemente
  Future<bool> eliminarPermanentemente(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/partidos/$id/forzar'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error al eliminar permanentemente');
      }
    } catch (e) {
      throw Exception('Error al eliminar: $e');
    }
  }
}