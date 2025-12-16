import 'package:flutter/material.dart';
import 'dart:convert';
import '../../models/categoria_model.dart';
import '../../models/jugador_model.dart';
import '../../models/persona_model.dart';
import '../../models/rendimiento_model.dart';
import '../../services/categoria_service.dart';
import '../../services/jugador_service.dart';
import '../../services/persona_service.dart';
import '../../services/rendimiento_service.dart';
import '../../services/api_service.dart';

class ComparacionJugadoresController {
  final CategoriaService _categoriaService = CategoriaService();
  final JugadorService _jugadorService = JugadorService();
  final PersonaService _personaService = PersonaService();
  final RendimientoService _rendimientoService = RendimientoService();
  final ApiService _apiService = ApiService();

  // Cargar todas las categorías
  Future<List<Categoria>> cargarCategorias() async {
    try {
      return await _categoriaService.getCategorias();
    } catch (e) {
      debugPrint('❌ Error al cargar categorías: $e');
      rethrow;
    }
  }

  // Cargar jugadores por categoría
  Future<List<Jugador>> cargarJugadoresPorCategoria(int idCategoria) async {
    try {
      debugPrint('🔍 Cargando jugadores de categoría: $idCategoria');
      
      final response = await _apiService.get('/categorias/$idCategoria/jugadores');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        List<dynamic> jugadoresList;
        if (data is Map && data.containsKey('data')) {
          jugadoresList = data['data'] as List;
        } else if (data is List) {
          jugadoresList = data;
        } else {
          throw Exception('Formato de respuesta no válido');
        }
        
        final jugadores = jugadoresList
            .map((j) => Jugador.fromJson(j))
            .toList();
        
        debugPrint('✅ ${jugadores.length} jugadores cargados');
        return jugadores;
        
      } else if (response.statusCode == 404) {
        debugPrint('⚠️ No hay jugadores en esta categoría');
        return [];
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error al cargar jugadores: $e');
      rethrow;
    }
  }

  // Cargar estadísticas totales de un jugador
  Future<Map<String, dynamic>> cargarEstadisticasJugador(int idJugador) async {
    try {
      // Intentar obtener totales directamente
      try {
        final totales = await _rendimientoService.obtenerTotalesJugador(idJugador);
        
        if (totales != null && totales.isNotEmpty) {
          return {
            'jugador_id': idJugador,
            'estadisticas': totales,
            'sinDatos': false,
          };
        }
      } catch (e) {
        debugPrint('⚠️ Endpoint totales no disponible, calculando manualmente');
      }

      // Método alternativo: calcular desde rendimientos
      final rendimientos = await _rendimientoService.obtenerRendimientosPorJugador(idJugador);

      if (rendimientos.isEmpty) {
        return {
          'jugador_id': idJugador,
          'estadisticas': null,
          'sinDatos': true,
        };
      }

      // Calcular totales
      Map<String, int> totales = {
        'goles': 0,
        'goles_cabeza': 0,
        'asistencias': 0,
        'tiros_puerta': 0,
        'fueras_juego': 0,
        'partidos_jugados': rendimientos.length,
        'tarjetas_amarillas': 0,
        'tarjetas_rojas': 0,
      };

      for (var r in rendimientos) {
        totales['goles'] = (totales['goles'] ?? 0) + (r.goles ?? 0);
        totales['goles_cabeza'] = (totales['goles_cabeza'] ?? 0) + (r.golesDeCabeza ?? 0);
        totales['asistencias'] = (totales['asistencias'] ?? 0) + (r.asistencias ?? 0);
        totales['tiros_puerta'] = (totales['tiros_puerta'] ?? 0) + (r.tirosAPuerta ?? 0);
        totales['fueras_juego'] = (totales['fueras_juego'] ?? 0) + (r.fuerasDeLuego ?? 0);
        totales['tarjetas_amarillas'] = (totales['tarjetas_amarillas'] ?? 0) + (r.tarjetasAmarillas ?? 0);
        totales['tarjetas_rojas'] = (totales['tarjetas_rojas'] ?? 0) + (r.tarjetasRojas ?? 0);
      }

      return {
        'jugador_id': idJugador,
        'estadisticas': totales,
        'sinDatos': false,
      };
      
    } catch (e) {
      debugPrint('❌ Error al cargar estadísticas del jugador $idJugador: $e');
      return {
        'jugador_id': idJugador,
        'estadisticas': null,
        'sinDatos': true,
        'error': true,
      };
    }
  }

  // Cargar estadísticas comparadas de dos jugadores
  Future<Map<String, dynamic>> cargarEstadisticasComparadas(
      int idJugador1, int idJugador2) async {
    try {
      final results = await Future.wait([
        cargarEstadisticasJugador(idJugador1),
        cargarEstadisticasJugador(idJugador2),
      ]);

      final stats1 = results[0];
      final stats2 = results[1];

      Map<String, int> estadisticasVacias = {
        'goles': 0,
        'goles_cabeza': 0,
        'asistencias': 0,
        'tiros_puerta': 0,
        'fueras_juego': 0,
        'partidos_jugados': 0,
        'tarjetas_amarillas': 0,
        'tarjetas_rojas': 0,
      };

      return {
        'jugador1': {
          'jugador_id': idJugador1,
          'estadisticas': stats1['estadisticas'] ?? estadisticasVacias,
          'sinDatos': stats1['sinDatos'] ?? true,
        },
        'jugador2': {
          'jugador_id': idJugador2,
          'estadisticas': stats2['estadisticas'] ?? estadisticasVacias,
          'sinDatos': stats2['sinDatos'] ?? true,
        },
        'error': (stats1['sinDatos'] == true && stats2['sinDatos'] == true)
            ? 'Ninguno de los jugadores tiene estadísticas registradas'
            : (stats1['sinDatos'] == true)
                ? 'El jugador 1 no tiene estadísticas registradas'
                : (stats2['sinDatos'] == true)
                    ? 'El jugador 2 no tiene estadísticas registradas'
                    : null,
      };
    } catch (e) {
      debugPrint('❌ Error al cargar estadísticas comparadas: $e');
      rethrow;
    }
  }
}