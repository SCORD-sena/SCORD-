import 'dart:convert';
import '../models/rendimiento_model.dart';
import 'api_service.dart'; 

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

  /// 🆕 Obtener estadísticas filtradas por competencia
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

  /// 🆕 Obtener estadísticas de un partido específico
  Future<EstadisticasTotales?> obtenerEstadisticasPorPartido(
    int idJugador, 
    int idPartido
  ) async {
    try {
      print('📤 GET /rendimientos/jugador/$idJugador/partido/$idPartido');
      
      final response = await _apiService.get(
        '/rendimientos/jugador/$idJugador/partido/$idPartido'
      );
      
      print('📥 Status: ${response.statusCode}');
      print('📥 Response: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          return EstadisticasTotales.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('❌ Error: $e');
      return null;
    }
  }

  /// 🆕 Obtener rendimiento de un jugador en un partido específico (para editar)
  Future<UltimoRegistro?> obtenerRendimientoPorPartido(int idJugador, int idPartido) async {
    try {
      print('📤 GET /rendimientospartidos/jugador/$idJugador/partido/$idPartido');
      
      final response = await _apiService.get(
        '/rendimientospartidos/jugador/$idJugador/partido/$idPartido'
      );

      print('📥 Status: ${response.statusCode}');
      print('📥 Response: ${response.body}');

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
        print('⚠️ No hay registro para ese partido');
        return null;
      } else {
        throw Exception('Error al obtener rendimiento: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error al obtener rendimiento por partido: $e');
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
      print('📤 PUT /rendimientospartidos/$idRendimiento');
      print('Body: ${json.encode(datos)}');
      
      final response = await _apiService.put(
        '/rendimientospartidos/$idRendimiento',
        datos,
      );

      print('📥 Status: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error: $e');
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
}