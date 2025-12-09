import 'dart:convert';
import '../models/tipo_documento_model.dart';
import 'api_service.dart';

class TipoDocumentoService {
  final ApiService _apiService = ApiService();

  // Obtener todos los tipos de documento
  Future<List<TipoDocumento>> getTiposDocumento() async {
    try {
      final response = await _apiService.get('/tiposdedocumentos');

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