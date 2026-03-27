import 'dart:convert';
import '../models/rendimiento_model.dart';
import 'api_service.dart'; // ✅ AGREGADO

class RendimientoService {
  final ApiService _apiService = ApiService(); // ✅ AGREGADO
  
  /// Obtiene las estadísticas totales de un jugador
  Future<EstadisticasTotales?> obtenerEstadisticasTotales(int idJugador) async {
    try {
      final response = await _apiService.get(
        '/rendimientospartidos/jugador/$idJugador/totales' // ✅ CAMBIADO
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
        '/rendimientospartidos/jugador/$idJugador/ultimo-registro' // ✅ CAMBIADO
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
        '/rendimientospartidos', // ✅ CAMBIADO
        datos, // ✅ CAMBIADO (ya no necesitas headers ni json.encode)
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
        '/rendimientospartidos/$idRendimiento', // ✅ CAMBIADO
        datos, // ✅ CAMBIADO
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
        '/rendimientospartidos/$idRendimiento' // ✅ CAMBIADO
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error al eliminar rendimiento: $e');
      return false;
    }
  }
}