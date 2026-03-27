import 'dart:convert';
<<<<<<< HEAD
import '../models/tipo_documento_model.dart';
import 'api_service.dart';

class TipoDocumentoService {
  final ApiService _apiService = ApiService();

  // Obtener todos los tipos de documento
  Future<List<TipoDocumento>> getTiposDocumento() async {
    try {
      final response = await _apiService.get('/tiposdedocumentos');
=======
import 'package:http/http.dart' as http;
import '../models/tipo_documento_model.dart';
import '../config/api_config.dart';

class TipoDocumentoService {
  // Obtener todos los tipos de documento
  Future<List<TipoDocumento>> getTiposDocumento() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tiposdedocumentos'),
        headers: {'Content-Type': 'application/json'},
      );
>>>>>>> 77fbf37e833f546a83348df26e99d07ab761018b

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse
            .map((json) => TipoDocumento.fromJson(json))
            .toList();
      } else {
        throw Exception('Error al cargar tipos de documento: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}