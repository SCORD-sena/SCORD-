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

    return response;
  }

  // POST con autenticación
  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final headers = await _authService.obtenerHeaders();
    final url = Uri.parse('$baseUrl$endpoint');

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );

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