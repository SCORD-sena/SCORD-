import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/competencia_model.dart';

class CompetenciaService {
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
  // COMPETENCIAS
  // ============================================================

  Future<List<Competencia>> getCompetencias() async {
  try {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/competencias'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      print('📦 COMPETENCIAS Response: ${response.body}'); // ← AGREGAR
      final List data = json.decode(response.body);
      
      for (var item in data) {
        print('🔍 Competencia: $item'); // ← AGREGAR
      }
      
      return data.map((json) => Competencia.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar competencias: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Error en getCompetencias: $e'); // ← AGREGAR
    throw Exception('Error de conexión: $e');
  }
}

  Future<Competencia> getCompetenciaById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/competencias/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Competencia.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al cargar competencia: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> createCompetencia(Competencia competencia) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/competencias'),
        headers: headers,
        body: json.encode(competencia.toJson()),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Error al crear competencia: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> updateCompetencia(int id, Competencia competencia) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/competencias/$id'),
        headers: headers,
        body: json.encode(competencia.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al actualizar competencia: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> deleteCompetencia(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/competencias/$id'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar competencia: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
  // 🆕 NUEVA FUNCIÓN
Future<List<Competencia>> getCompetenciasByCategoria(int idCategorias) async {
  try {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/competencias/categoria/$idCategorias'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Competencia.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar competencias: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error de conexión: $e');
  }
}
}