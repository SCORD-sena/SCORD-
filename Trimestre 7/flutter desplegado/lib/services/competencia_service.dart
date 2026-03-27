import 'dart:convert';
import '../models/competencia_model.dart';
import 'api_service.dart';

class CompetenciaService {
  final ApiService _apiService = ApiService();

  /// Obtener todas las competencias activas
  Future<List<Competencia>> getCompetencias() async {
    try {
      final response = await _apiService.get('/competencias');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Si es array vacío, devolver lista vacía
        if (data is List && data.isEmpty) {
          return [];
        }
        
        return (data as List).map((json) => Competencia.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Obtener competencias por categoría
  Future<List<Competencia>> getCompetenciasByCategoria(int idCategoria) async {
    try {
      final response = await _apiService.get('/competencias/categoria/$idCategoria');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data is List && data.isEmpty) {
          return [];
        }
        
        return (data as List).map((json) => Competencia.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Obtener una competencia por ID
  Future<Competencia?> getCompetenciaById(int id) async {
    try {
      final response = await _apiService.get('/competencias/$id');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Competencia.fromJson(data);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Crear nueva competencia (sin categoría)
  Future<bool> crearCompetencia(Map<String, dynamic> competenciaData) async {
    try {
      final response = await _apiService.post('/competencias', competenciaData);
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Crear competencia asociada con categoría (crea cronograma automáticamente)
  Future<bool> crearCompetenciaConCategoria(Map<String, dynamic> competenciaData) async {
    try {     
      final response = await _apiService.post('/competencias/with-categoria', competenciaData);    
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Actualizar competencia
  Future<bool> actualizarCompetencia(int id, Map<String, dynamic> competenciaData) async {
    try {
      final response = await _apiService.put('/competencias/$id', competenciaData);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Eliminar competencia (soft delete)
  Future<bool> eliminarCompetencia(int id) async {
    try {
      final response = await _apiService.delete('/competencias/$id');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  // ============================================================
  // MÉTODOS PARA HISTORIAL DE COMPETENCIAS
  // ============================================================

  /// Obtener competencias eliminadas (papelera)
  Future<List<Competencia>> fetchCompetenciasEliminadas() async {
    try {
      final response = await _apiService.get('/competencias/papelera/listar');

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        
        List<dynamic> competenciasList;
        if (data is Map && data.containsKey('data')) {
          competenciasList = data['data'] as List;
        } else {
          competenciasList = data as List;
        }

        return competenciasList.map((c) => Competencia.fromJson(c)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Error al obtener competencias eliminadas: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Restaurar competencia eliminada
  Future<bool> restaurarCompetencia(int id) async {
    try {
      final response = await _apiService.post(
        '/competencias/$id/restaurar',
        {},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error al restaurar competencia');
      }
    } catch (e) {
      throw Exception('Error al restaurar competencia: $e');
    }
  }

  /// Eliminar competencia permanentemente
  Future<bool> eliminarPermanentemente(int id) async {
    try {
      final response = await _apiService.delete(
        '/competencias/$id/forzar',
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