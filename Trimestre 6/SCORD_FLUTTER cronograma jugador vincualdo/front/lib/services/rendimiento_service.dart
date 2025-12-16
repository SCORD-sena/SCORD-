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
    print('📤 GET /rendimientos/jugador/$idJugador/partido/$idPartido'); // ← AGREGAR
    
    final response = await _apiService.get(
      '/rendimientos/jugador/$idJugador/partido/$idPartido'
    );
    
    print('📥 Status: ${response.statusCode}'); // ← AGREGAR
    print('📥 Response: ${response.body}'); // ← AGREGAR
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      if (data['success'] == true && data['data'] != null) {
        return EstadisticasTotales.fromJson(data['data']);
      }
    }
    return null;
  } catch (e) {
    print('❌ Error: $e'); // ← AGREGAR
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
      return false;
    }
  }

  /// Actualiza un registro de rendimiento existente
Future<bool> actualizarRendimiento(int idRendimiento, Map<String, dynamic> datos) async {
  try {
    print('📤 PUT /rendimientospartidos/$idRendimiento'); // ← AGREGAR
    print('Body: ${json.encode(datos)}'); // ← AGREGAR
    
    final response = await _apiService.put(
      '/rendimientospartidos/$idRendimiento',
      datos,
    );

    print('📥 Status: ${response.statusCode}'); // ← AGREGAR
    print('📥 Response: ${response.body}'); // ← AGREGAR

    return response.statusCode == 200;
  } catch (e) {
    print('❌ Error: $e'); // ← AGREGAR
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
      return false;
    }
  }
}