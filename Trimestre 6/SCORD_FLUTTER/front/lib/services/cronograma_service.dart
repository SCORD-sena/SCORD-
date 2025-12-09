import 'dart:convert'; 
import 'package:http/http.dart' as http; 
import 'package:shared_preferences/shared_preferences.dart'; 
import '../config/api_config.dart'; 
import '../models/cronograma_model.dart'; 
import '../models/partido_model.dart'; 
import '../models/categoria_model.dart'; 
 
class CronogramaService { 
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
  // CRONOGRAMAS 
  // ============================================================ 
 
  Future<List<Cronograma>> getCronogramas() async { 
    try { 
      final headers = await _getHeaders(); 
      final response = await http.get( 
        Uri.parse('$baseUrl/cronogramas'), 
        headers: headers, 
      ); 
 
      if (response.statusCode == 200) { 
        final List data = json.decode(response.body); 
        return data.map((json) => Cronograma.fromJson(json)).toList(); 
      } else { 
        throw Exception('Error al cargar cronogramas: ${response.statusCode}'); 
      } 
    } catch (e) { 
      throw Exception('Error de conexión: $e'); 
    } 
  } 
 
  Future<Cronograma> getCronogramaById(int id) async { 
    try { 
      final headers = await _getHeaders(); 
      final response = await http.get( 
        Uri.parse('$baseUrl/cronogramas/$id'), 
        headers: headers, 
      ); 
 
      if (response.statusCode == 200) { 
        return Cronograma.fromJson(json.decode(response.body)); 
      } else { 
        throw Exception('Error al cargar cronograma: ${response.statusCode}'); 
      } 
    } catch (e) { 
      throw Exception('Error de conexión: $e'); 
    } 
  } 
 
  Future<void> createCronograma(Cronograma cronograma) async { 
    try { 
      final headers = await _getHeaders(); 
      final response = await http.post( 
        Uri.parse('$baseUrl/cronogramas'), 
        headers: headers, 
        body: json.encode(cronograma.toJson()), 
      ); 
 
      if (response.statusCode != 200 && response.statusCode != 201) { 
        throw Exception('Error al crear cronograma: ${response.statusCode}'); 
      } 
    } catch (e) { 
      throw Exception('Error de conexión: $e'); 
    } 
  } 
 
  Future<void> updateCronograma(int id, Cronograma cronograma) async { 
    try { 
      final headers = await _getHeaders(); 
      final response = await http.put( 
        Uri.parse('$baseUrl/cronogramas/$id'), 
        headers: headers, 
        body: json.encode(cronograma.toJson()), 
      ); 
 
      if (response.statusCode != 200) { 
        throw Exception('Error al actualizar cronograma: ${response.statusCode}'); 
      } 
    } catch (e) { 
      throw Exception('Error de conexión: $e'); 
    } 
  } 
 
  Future<void> deleteCronograma(int id) async { 
    try { 
      final headers = await _getHeaders(); 
      final response = await http.delete( 
        Uri.parse('$baseUrl/cronogramas/$id'), 
        headers: headers, 
      ); 
 
      if (response.statusCode != 200) { 
        throw Exception('Error al eliminar cronograma: ${response.statusCode}'); 
      } 
    } catch (e) { 
      throw Exception('Error de conexión: $e'); 
    } 
  } 
 
  // ============================================================ 
  // PARTIDOS 
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
 
  Future<Map<String, dynamic>> createPartido(Partido partido) async { 
    try { 
      final headers = await _getHeaders(); 
      final response = await http.post( 
        Uri.parse('$baseUrl/partidos'), 
        headers: headers, 
        body: json.encode(partido.toJson()), 
      ); 
 
      if (response.statusCode == 200 || response.statusCode == 201) { 
        return json.decode(response.body); 
      } else { 
        throw Exception('Error al crear partido: ${response.statusCode}'); 
      } 
    } catch (e) { 
      throw Exception('Error de conexión: $e'); 
    } 
  } 
 
  Future<void> updatePartido(int id, Partido partido) async { 
    try { 
      final headers = await _getHeaders(); 
      final response = await http.put( 
        Uri.parse('$baseUrl/partidos/$id'), 
        headers: headers, 
        body: json.encode(partido.toJson()), 
      ); 
 
      if (response.statusCode != 200) { 
        throw Exception('Error al actualizar partido: ${response.statusCode}'); 
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
  // CATEGORÍAS 
  // ============================================================ 
 
  Future<List<Categoria>> getCategorias() async { 
    try { 
      final headers = await _getHeaders(); 
      final response = await http.get( 
        Uri.parse('$baseUrl/categorias'), 
        headers: headers, 
      ); 
 
      if (response.statusCode == 200) { 
        final List data = json.decode(response.body); 
        return data.map((json) => Categoria.fromJson(json)).toList(); 
      } else { 
        throw Exception('Error al cargar categorías: ${response.statusCode}'); 
      } 
    } catch (e) { 
      throw Exception('Error de conexión: $e'); 
    } 
  } 

  // ============================================================
  // ENTRENADORES - CATEGORÍAS
  // ============================================================

  Future<List<Categoria>> getMisCategorias() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/entrenadores/misCategorias'),
        headers: headers,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic jsonResponse = json.decode(response.body);
        
        // Verificar si la respuesta tiene estructura {data: [...]}
        if (jsonResponse is Map && jsonResponse.containsKey('data')) {
          final List data = jsonResponse['data'];
          return data.map((json) => Categoria.fromJson(json)).toList();
        } 
        // Si la respuesta es directamente un array
        else if (jsonResponse is List) {
          return jsonResponse.map((json) => Categoria.fromJson(json)).toList();
        }
        
        throw Exception('Formato de respuesta inesperado');
      } else {
        throw Exception('Error al cargar categorías del entrenador: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error en getMisCategorias: $e');
      throw Exception('Error de conexión al obtener categorías: $e');
    }
  }
}