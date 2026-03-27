import 'dart:convert';
<<<<<<< HEAD
import '../models/categoria_model.dart';
import 'api_service.dart';

class CategoriaService {
  final ApiService _apiService = ApiService();

  // Obtener todas las categorías
  Future<List<Categoria>> getCategorias() async {
    try {
      final response = await _apiService.get('/categorias');
=======
import 'package:http/http.dart' as http;
import '../models/categoria_model.dart';
import '../config/api_config.dart';

class CategoriaService {
  // Obtener todas las categorías
  Future<List<Categoria>> getCategorias() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categorias'),
        headers: {'Content-Type': 'application/json'},
      );
>>>>>>> 77fbf37e833f546a83348df26e99d07ab761018b

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