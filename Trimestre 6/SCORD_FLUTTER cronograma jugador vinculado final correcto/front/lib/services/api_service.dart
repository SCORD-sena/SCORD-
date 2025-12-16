import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import 'auth_service.dart';

class ApiService {
  final AuthService _authService = AuthService();

  // GET con autenticación
  Future<http.Response> get(String endpoint) async {
    final headers = await _authService.obtenerHeaders();
    final url = Uri.parse('$baseUrl$endpoint');   
    final response = await http.get(url, headers: headers);

    if (response.statusCode != 200) {
      print('⚠️ GET $endpoint - Status: ${response.statusCode}');
      print('Response: ${response.body}');
    }
    return response;
  }

  // POST con autenticación
  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final headers = await _authService.obtenerHeaders();
    final url = Uri.parse('$baseUrl$endpoint');
    
    print('📤 POST $endpoint'); // ← AGREGAR
    print('Headers: $headers'); // ← AGREGAR
    print('Body enviado: ${jsonEncode(data)}'); // ← AGREGAR
    
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );
    
    print('📥 Response Status: ${response.statusCode}'); // ← AGREGAR
    print('📥 Response Body: ${response.body}'); // ← AGREGAR
    
    if (response.statusCode >= 400) {
      print('❌ Error en POST $endpoint');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
    }
    
    return response;
  }

  // PUT con autenticación
  Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    final headers = await _authService.obtenerHeaders();
    final url = Uri.parse('$baseUrl$endpoint');
    
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(data),
    );
    
    return response;
  }

  // PATCH con autenticación
  Future<http.Response> patch(String endpoint, Map<String, dynamic> data) async {
    final headers = await _authService.obtenerHeaders();
    final url = Uri.parse('$baseUrl$endpoint');
    
    final response = await http.patch(
      url,
      headers: headers,
      body: jsonEncode(data),
    );
    
    return response;
  }

  // DELETE con autenticación
  Future<http.Response> delete(String endpoint) async {
    final headers = await _authService.obtenerHeaders();
    final url = Uri.parse('$baseUrl$endpoint');
    
    final response = await http.delete(url, headers: headers);
    
    return response;
  }
}