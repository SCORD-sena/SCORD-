import 'dart:convert';
import '../models/resultado_model.dart';
import '../models/resultado_eliminado_model.dart';
import 'api_service.dart';

class ResultadoService {
  final ApiService _apiService = ApiService();

  /// Obtener todos los resultados activos
  Future<List<Resultado>> getResultados() async {
    try {
      final response = await _apiService.get('/resultados');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Si es array vacío, devolver lista vacía
        if (data is List && data.isEmpty) {
          return [];
        }
        
        return (data as List).map((json) => Resultado.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Obtener un resultado por ID
  Future<Resultado?> getResultadoById(int id) async {
    try {
      final response = await _apiService.get('/resultados/$id');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Resultado.fromJson(data);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Crear nuevo resultado
  Future<bool> crearResultado(Map<String, dynamic> resultadoData) async {
    try {
      final response = await _apiService.post('/resultados', resultadoData);
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Actualizar resultado
  Future<bool> actualizarResultado(int id, Map<String, dynamic> resultadoData) async {
    try {
      final response = await _apiService.put('/resultados/$id', resultadoData);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Eliminar resultado (soft delete)
  Future<bool> eliminarResultado(int id) async {
    try {
      final response = await _apiService.delete('/resultados/$id');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  // ============================================================
  // MÉTODOS PARA HISTORIAL DE RESULTADOS
  // ============================================================

  /// Obtener resultados eliminados con información completa
  Future<List<ResultadoEliminado>> fetchResultadosEliminadosCompletos() async {
    try {
      final response = await _apiService.get('/resultados/trashed');

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        
        List<dynamic> resultadosList;
        if (data is Map && data.containsKey('data')) {
          resultadosList = data['data'] as List;
        } else {
          resultadosList = data as List;
        }
        return resultadosList.map((r) => ResultadoEliminado.fromJson(r)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Error al obtener resultados eliminados: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Restaurar resultado eliminado
  Future<bool> restaurarResultado(int id) async {
    try {
      final response = await _apiService.post(
        '/resultados/$id/restaurar',
        {},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error al restaurar resultado');
      }
    } catch (e) {
      throw Exception('Error al restaurar resultado: $e');
    }
  }

  /// Eliminar resultado permanentemente
  Future<bool> eliminarResultadoPermanentemente(int id) async {
    try {
      final response = await _apiService.delete(
        '/resultados/$id/forzar',
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error al eliminar permanentemente');
      }
    } catch (e) {
      throw Exception('Error al eliminar: $e');
    }
  }
}