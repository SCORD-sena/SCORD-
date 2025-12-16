import 'dart:convert';
import '../models/categoria_model.dart';
import 'api_service.dart';

class CategoriaService {
  final ApiService _apiService = ApiService();

  /// Obtener todas las categorías
  Future<List<Categoria>> getCategorias() async {
    try {
      final response = await _apiService.get('/categorias');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((json) => Categoria.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Obtener una categoría por ID
  Future<Categoria?> getCategoriaById(int id) async {
    try {
      final response = await _apiService.get('/categorias/$id');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Categoria.fromJson(data);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Crear nueva categoría
  Future<bool> crearCategoria(Map<String, dynamic> categoriaData) async {
    try {
      final response = await _apiService.post('/categorias', categoriaData);
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Actualizar categoría
  Future<bool> actualizarCategoria(int id, Map<String, dynamic> categoriaData) async {
    try {
      final response = await _apiService.put('/categorias/$id', categoriaData);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Eliminar categoría
  Future<bool> eliminarCategoria(int id) async {
    try {
      final response = await _apiService.delete('/categorias/$id');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}