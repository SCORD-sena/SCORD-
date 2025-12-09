import 'dart:convert';
import '../models/categoria_model.dart';
import 'api_service.dart';

class CategoriaService {
  final ApiService _apiService = ApiService();

  // Obtener todas las categorías
  Future<List<Categoria>> getCategorias() async {
    try {
      final response = await _apiService.get('/categorias');

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse
            .map((json) => Categoria.fromJson(json))
            .toList();
      } else {
        throw Exception('Error al cargar categorías: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}