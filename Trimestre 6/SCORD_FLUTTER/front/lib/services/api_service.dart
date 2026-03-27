import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import 'auth_service.dart';

class ApiService {
  final AuthService _authService = AuthService();

  // GET con autenticación
  Future<http.Response> get(String endpoint) async {
    final headers = await _authService.obtenerHeaders();
<<<<<<< HEAD
    final url = Uri.parse('$baseUrl$endpoint');   
    final response = await http.get(url, headers: headers);

    if (response.statusCode != 200) {
    }
=======
    final url = Uri.parse('$baseUrl$endpoint');
    
    print('🌐 GET: $url');
    print('📋 Headers: $headers');
    
    final response = await http.get(url, headers: headers);
    
    print('✅ Status: ${response.statusCode}');
    if (response.statusCode != 200) {
      print('❌ Error body: ${response.body}');
    }
    
>>>>>>> 77fbf37e833f546a83348df26e99d07ab761018b
    return response;
  }

  // POST con autenticación
  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final headers = await _authService.obtenerHeaders();
    final url = Uri.parse('$baseUrl$endpoint');
<<<<<<< HEAD
=======
    
    print('🌐 POST: $url');
    print('📋 Headers: $headers');
    print('📦 Body: ${jsonEncode(data)}');
    
>>>>>>> 77fbf37e833f546a83348df26e99d07ab761018b
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );
<<<<<<< HEAD
    if (response.statusCode >= 400) {
=======
    
    print('✅ Status: ${response.statusCode}');
    if (response.statusCode >= 400) {
      print('❌ Error body: ${response.body}');
>>>>>>> 77fbf37e833f546a83348df26e99d07ab761018b
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

  // DELETE con autenticación
  Future<http.Response> delete(String endpoint) async {
    final headers = await _authService.obtenerHeaders();
    final url = Uri.parse('$baseUrl$endpoint');
    
    final response = await http.delete(url, headers: headers);
    
    return response;
  }
}