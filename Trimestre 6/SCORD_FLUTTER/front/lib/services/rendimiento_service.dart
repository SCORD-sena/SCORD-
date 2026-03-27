import 'dart:convert';
import '../models/rendimiento_model.dart';
<<<<<<< HEAD
import 'api_service.dart'; 

class RendimientoService {
  final ApiService _apiService = ApiService(); 
=======
import 'api_service.dart'; // ✅ AGREGADO

class RendimientoService {
  final ApiService _apiService = ApiService(); // ✅ AGREGADO
>>>>>>> 77fbf37e833f546a83348df26e99d07ab761018b
  
  /// Obtiene las estadísticas totales de un jugador
  Future<EstadisticasTotales?> obtenerEstadisticasTotales(int idJugador) async {
    try {
      final response = await _apiService.get(
<<<<<<< HEAD
        '/rendimientospartidos/jugador/$idJugador/totales' 
=======
        '/rendimientospartidos/jugador/$idJugador/totales' // ✅ CAMBIADO
>>>>>>> 77fbf37e833f546a83348df26e99d07ab761018b
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          return EstadisticasTotales.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
<<<<<<< HEAD
=======
      print('Error al obtener estadísticas totales: $e');
>>>>>>> 77fbf37e833f546a83348df26e99d07ab761018b
      return null;
    }
  }

<<<<<<< HEAD
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

=======
>>>>>>> 77fbf37e833f546a83348df26e99d07ab761018b
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
<<<<<<< HEAD
=======
      print('Error al obtener último registro: $e');
>>>>>>> 77fbf37e833f546a83348df26e99d07ab761018b
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
<<<<<<< HEAD
=======
      print('Error al crear rendimiento: $e');
>>>>>>> 77fbf37e833f546a83348df26e99d07ab761018b
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
<<<<<<< HEAD
=======
      print('Error al actualizar rendimiento: $e');
>>>>>>> 77fbf37e833f546a83348df26e99d07ab761018b
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
<<<<<<< HEAD
=======
      print('Error al eliminar rendimiento: $e');
>>>>>>> 77fbf37e833f546a83348df26e99d07ab761018b
      return false;
    }
  }
}