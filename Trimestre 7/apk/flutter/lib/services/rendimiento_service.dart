import 'dart:convert';
import '../models/rendimiento_model.dart';
import '../models/rendimiento_eliminado_model.dart';
import 'api_service.dart'; 
import 'package:http/http.dart' as http;

class RendimientoService {
  final ApiService _apiService = ApiService(); 
  
  /// Obtiene las estadísticas totales de un jugador
  Future<EstadisticasTotales?> obtenerEstadisticasTotales(int idJugador) async {
    try {
      final response = await _apiService.get(
        '/rendimientospartidos/jugador/$idJugador/totales' 
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          return EstadisticasTotales.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Obtener estadísticas filtradas por competencia
  Future<EstadisticasTotales?> obtenerEstadisticasPorCompetencia(
    int idJugador, 
    int idCompetencia
  ) async {
    try { 
      final response = await _apiService.get(
        '/rendimientos/jugador/$idJugador/competencia/$idCompetencia'
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          return EstadisticasTotales.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Obtener estadísticas de un partido específico
  Future<EstadisticasTotales?> obtenerEstadisticasPorPartido(
    int idJugador, 
    int idPartido
  ) async {
    try {
      final response = await _apiService.get(
        '/rendimientos/jugador/$idJugador/partido/$idPartido'
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          return EstadisticasTotales.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Obtener rendimiento de un jugador en un partido específico (para editar)
  Future<UltimoRegistro?> obtenerRendimientoPorPartido(int idJugador, int idPartido) async {
    try {
      final response = await _apiService.get(
        '/rendimientospartidos/jugador/$idJugador/partido/$idPartido'
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Si el backend devuelve {success: true, data: {...}}
        if (data['success'] == true && data['data'] != null) {
          return UltimoRegistro.fromJson(data['data']);
        }
        // Si devuelve un array, tomar el primer elemento
        else if (data is List && data.isNotEmpty) {
          return UltimoRegistro.fromJson(data[0]);
        }
        // Si devuelve un objeto directamente
        else if (data is Map<String, dynamic>) {
          return UltimoRegistro.fromJson(data);
        }
        
        return null;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Error al obtener rendimiento: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener rendimiento por partido: $e');
    }
  }

  /// Obtiene el último registro de rendimiento de un jugador
  Future<UltimoRegistro?> obtenerUltimoRegistro(int idJugador) async {
    try {
      final response = await _apiService.get(
        '/rendimientospartidos/jugador/$idJugador/ultimo-registro'
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return UltimoRegistro.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Crea un nuevo registro de rendimiento
  Future<bool> crearRendimiento(Map<String, dynamic> datos) async {
    try {
      final response = await _apiService.post(
        '/rendimientospartidos',
        datos,
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  /// Actualiza un registro de rendimiento existente
  Future<bool> actualizarRendimiento(int idRendimiento, Map<String, dynamic> datos) async {
    try {
      final response = await _apiService.put(
        '/rendimientospartidos/$idRendimiento',
        datos,
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Elimina un registro de rendimiento
  Future<bool> eliminarRendimiento(int idRendimiento) async {
    try {
      final response = await _apiService.delete(
        '/rendimientospartidos/$idRendimiento'
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // MÉTODOS PARA HISTORIAL DE RENDIMIENTOS
  // ============================================================

  /// Obtener rendimientos eliminados (papelera)
  Future<List<RendimientoEliminado>> fetchRendimientosEliminadosCompletos() async {
    try {
      final response = await _apiService.get('/rendimientospartidos/trashed');

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        
        List<dynamic> rendimientosList;
        if (data is Map && data.containsKey('data')) {
          rendimientosList = data['data'] as List;
        } else {
          rendimientosList = data as List;
        }
        
        return rendimientosList.map((r) => RendimientoEliminado.fromJson(r)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Error al obtener rendimientos eliminados: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en fetchRendimientosEliminadosCompletos: $e');
    }
  }

  /// Restaurar rendimiento eliminado
  Future<bool> restaurarRendimiento(int id) async {
    try {
      final response = await _apiService.post(
        '/rendimientospartidos/$id/restaurar',
        {},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error al restaurar rendimiento');
      }
    } catch (e) {
      throw Exception('Error al restaurar rendimiento: $e');
    }
  }

  /// Eliminar rendimiento permanentemente
  Future<bool> eliminarRendimientoPermanentemente(int id) async {
    try {
      final response = await _apiService.delete(
        '/rendimientospartidos/$id/forzar',
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