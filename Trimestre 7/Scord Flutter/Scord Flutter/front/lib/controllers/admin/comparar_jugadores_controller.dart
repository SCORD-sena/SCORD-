import 'package:flutter/material.dart';
import '../../models/categoria_model.dart';
import '../../models/competencia_model.dart';
import '../../services/categoria_service.dart';
import '../../services/competencia_service.dart';
import '../../services/jugador_service.dart';
import '../../services/rendimiento_service.dart';
import '../../models/jugador_model.dart';

class ComparacionJugadoresController {
  final CategoriaService _categoriaService = CategoriaService();
  final JugadorService _jugadorService = JugadorService();
  final RendimientoService _rendimientoService = RendimientoService();
  final CompetenciaService _competenciaService = CompetenciaService();

  Future<List<Categoria>> cargarCategorias() async {
    try {
      return await _categoriaService.getCategorias();
    } catch (e) {
      debugPrint('Error al cargar categorías: $e');
      rethrow;
    }
  }

  Future<List<Competencia>> cargarCompetenciasPorCategoria(int idCategoria) async {
    try {
      debugPrint('Cargando competencias para categoría: $idCategoria');
      final data = await _competenciaService.getCompetenciasByCategoria(idCategoria);
      
      final Map<int, Competencia> competenciasUnicas = {};
      for (var comp in data) {
        if (!competenciasUnicas.containsKey(comp.idCompetencias)) {
          competenciasUnicas[comp.idCompetencias] = comp;
        }
      }
      
      final competencias = competenciasUnicas.values.toList();
      debugPrint('Competencias cargadas: ${competencias.length}');
      return competencias;
    } catch (e) {
      debugPrint('Error al cargar competencias: $e');
      return [];
    }
  }

  Future<List<Jugador>> cargarJugadoresPorCategoria(int idCategoria) async {
    try {
      debugPrint('Cargando jugadores para categoría: $idCategoria');
      final jugadores = await _jugadorService.obtenerJugadoresPorCategoria(idCategoria);
      debugPrint('Jugadores cargados: ${jugadores.length}');
      return jugadores;
    } catch (e) {
      debugPrint('Error al obtener jugadores por categoría: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> cargarEstadisticasJugador(int idJugador) async {
    try {
      debugPrint('Cargando estadísticas totales del jugador: $idJugador');
      final estadisticas = await _rendimientoService.obtenerEstadisticasTotales(idJugador);
      
      if (estadisticas == null) {
        debugPrint('No hay estadísticas para el jugador: $idJugador');
        return {
          'jugador_id': idJugador,
          'estadisticas': null,
          'sinDatos': true,
        };
      }

      debugPrint('Estadísticas cargadas para jugador: $idJugador');
      return {
        'jugador_id': idJugador,
        'estadisticas': estadisticas.totales,
        'sinDatos': false,
      };
      
    } catch (e) {
      debugPrint('Error al cargar estadísticas del jugador $idJugador: $e');
      return {
        'jugador_id': idJugador,
        'estadisticas': null,
        'sinDatos': true,
        'error': true,
      };
    }
  }

  Future<Map<String, dynamic>> cargarEstadisticasJugadorPorCompetencia(
    int idJugador, 
    int idCompetencia
  ) async {
    try {
      debugPrint('Cargando estadísticas del jugador $idJugador en competencia $idCompetencia');
      final estadisticas = await _rendimientoService.obtenerEstadisticasPorCompetencia(
        idJugador, 
        idCompetencia
      );
      
      if (estadisticas == null) {
        debugPrint('No hay estadísticas para jugador $idJugador en competencia $idCompetencia');
        return {
          'jugador_id': idJugador,
          'estadisticas': null,
          'sinDatos': true,
        };
      }

      debugPrint('Estadísticas por competencia cargadas para jugador: $idJugador');
      return {
        'jugador_id': idJugador,
        'estadisticas': estadisticas.totales,
        'sinDatos': false,
      };
      
    } catch (e) {
      debugPrint('Error al cargar estadísticas del jugador $idJugador en competencia $idCompetencia: $e');
      return {
        'jugador_id': idJugador,
        'estadisticas': null,
        'sinDatos': true,
        'error': true,
      };
    }
  }

  Future<Map<String, dynamic>> cargarEstadisticasComparadas(
    int idJugador1, 
    int idJugador2
  ) async {
    try {
      debugPrint('Comparando jugadores: $idJugador1 vs $idJugador2 (TODAS las estadísticas)');
      
      final results = await Future.wait([
        cargarEstadisticasJugador(idJugador1),
        cargarEstadisticasJugador(idJugador2),
      ]);

      final comparacion = _procesarComparacion(results[0], results[1], idJugador1, idJugador2);
      debugPrint('Comparación completada');
      return comparacion;
    } catch (e) {
      debugPrint('Error al cargar estadísticas comparadas: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> cargarEstadisticasComparadasPorCompetencia(
    int idJugador1, 
    int idJugador2,
    int idCompetencia
  ) async {
    try {
      debugPrint('Comparando jugadores: $idJugador1 vs $idJugador2 en competencia $idCompetencia');
      
      final results = await Future.wait([
        cargarEstadisticasJugadorPorCompetencia(idJugador1, idCompetencia),
        cargarEstadisticasJugadorPorCompetencia(idJugador2, idCompetencia),
      ]);

      final comparacion = _procesarComparacion(results[0], results[1], idJugador1, idJugador2);
      debugPrint('Comparación por competencia completada');
      return comparacion;
    } catch (e) {
      debugPrint('Error al cargar estadísticas comparadas por competencia: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _procesarComparacion(
    Map<String, dynamic> stats1,
    Map<String, dynamic> stats2,
    int idJugador1,
    int idJugador2
  ) {
    Map<String, dynamic> estadisticasVacias = {
      'total_goles': "0",
      'total_goles_cabeza': "0",
      'total_minutos_jugados': "0",
      'total_asistencias': "0",
      'total_tiros_apuerta': "0",
      'total_tarjetas_rojas': "0",
      'total_tarjetas_amarillas': "0",
      'total_arco_en_cero': "0",
      'total_fueras_de_lugar': "0",
      'total_partidos_jugados': 0,
    };

    if (stats1['sinDatos'] == true) {
      debugPrint('Jugador $idJugador1 sin datos');
    }
    if (stats2['sinDatos'] == true) {
      debugPrint('Jugador $idJugador2 sin datos');
    }

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
  }
}