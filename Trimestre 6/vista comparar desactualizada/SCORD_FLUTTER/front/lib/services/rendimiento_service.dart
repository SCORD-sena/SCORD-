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
      print('Error al obtener estadísticas totales: $e');
      return null;
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
      print('Error al obtener último registro: $e');
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
      print('Error al crear rendimiento: $e');
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
      print('Error al actualizar rendimiento: $e');
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
      print('Error al eliminar rendimiento: $e');
      return false;
    }
  }

  /// Obtener todos los rendimientos de un jugador específico
  /// Se usa para calcular totales manualmente si el endpoint /totales no existe
  Future<List<Rendimiento>> obtenerRendimientosPorJugador(int idJugador) async {
    try {
      final response = await _apiService.get('/rendimientospartidos');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> rendimientosJson = data['data'] ?? data;

        // Filtrar por idJugador
        final rendimientosFiltrados = rendimientosJson
            .where((r) => r['idJugadores'] == idJugador)
            .map((json) => Rendimiento.fromJson(json))
            .toList();

        return rendimientosFiltrados;
      } else {
        print('Error al obtener rendimientos: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error al obtener rendimientos por jugador: $e');
      return [];
    }
  }

  /// Obtener totales de estadísticas de un jugador (método alternativo)
  /// Devuelve Map<String, int> para compatibilidad con el controller
  Future<Map<String, int>?> obtenerTotalesJugador(int idJugador) async {
    try {
      final response = await _apiService.get(
        '/rendimientospartidos/jugador/$idJugador/totales'
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final estadisticas = data['data'] ?? data;

        // Convertir a Map<String, int>
        return {
          'goles': estadisticas['goles'] ?? 0,
          'goles_cabeza': estadisticas['goles_cabeza'] ?? 0,
          'asistencias': estadisticas['asistencias'] ?? 0,
          'tiros_puerta': estadisticas['tiros_puerta'] ?? 0,
          'fueras_juego': estadisticas['fueras_juego'] ?? 0,
          'partidos_jugados': estadisticas['partidos_jugados'] ?? 0,
          'tarjetas_amarillas': estadisticas['tarjetas_amarillas'] ?? 0,
          'tarjetas_rojas': estadisticas['tarjetas_rojas'] ?? 0,
        };
      } else {
        print('Error al obtener totales: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error al obtener totales del jugador: $e');
      return null;
    }
  }
}