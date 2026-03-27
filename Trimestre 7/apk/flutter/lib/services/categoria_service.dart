import 'dart:convert';
import '../models/categoria_model.dart';
import 'api_service.dart';
import 'package:http/http.dart' as http;

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

  /// Eliminar categoría (soft delete)
  Future<bool> eliminarCategoria(int id) async {
    try {
      final response = await _apiService.delete('/categorias/$id');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ====== MÉTODOS PARA HISTORIAL ======

  /// Obtener categorías eliminadas (papelera)
  Future<List<Categoria>> fetchCategoriasEliminadas() async {
    try {
      final response = await _apiService.get('/categorias/papelera/listar');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        List<dynamic> categoriasList;
        if (data is Map && data.containsKey('data')) {
          categoriasList = data['data'] as List;
        } else {
          categoriasList = data as List;
        }
        
        return categoriasList.map((c) => Categoria.fromJson(c)).toList();
      } else if (response.statusCode == 404) {
        // No hay categorías eliminadas
        return [];
      } else {
        throw Exception('Error al obtener categorías eliminadas: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Restaurar categoría eliminada
  Future<bool> restaurarCategoria(int id) async {
    try {
      final response = await _apiService.post('/categorias/$id/restaurar', {});

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error al restaurar categoría');
      }
    } catch (e) {
      throw Exception('Error al restaurar categoría: $e');
    }
  }

  /// Eliminar permanentemente
  Future<bool> eliminarPermanentemente(int id) async {
    try {
      final response = await _apiService.delete('/categorias/$id/forzar');

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error al eliminar permanentemente');
      }
    } catch (e) {
      throw Exception('Error al eliminar: $e');
    }
  }
}