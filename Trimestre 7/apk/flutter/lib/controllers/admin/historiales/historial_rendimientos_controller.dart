import 'package:flutter/material.dart';
import '../../../models/rendimiento_eliminado_model.dart';
import '../../../models/categoria_model.dart';
import '../../../models/competencia_model.dart';
import '../../../services/rendimiento_service.dart';
import '../../../services/categoria_service.dart';
import '../../../services/competencia_service.dart';

class HistorialRendimientosController extends ChangeNotifier {
  final RendimientoService _rendimientoService = RendimientoService();
  final CategoriaService _categoriaService = CategoriaService();
  final CompetenciaService _competenciaService = CompetenciaService();

  // State
  List<RendimientoEliminado> _todosLosRendimientos = [];
  List<RendimientoEliminado> rendimientosFiltrados = [];
  List<Categoria> categorias = [];
  List<Competencia> competencias = [];
  
  bool loading = false;
  String? errorMessage;

  // Filtros seleccionados
  int? categoriaSeleccionadaId;
  int? jugadorSeleccionadoId;
  int? competenciaSeleccionadaId;

  // Listas dinámicas según filtros
  List<JugadorInfo> jugadoresDisponibles = [];
  List<Competencia> competenciasDisponibles = [];

  // Inicializar
  Future<void> inicializar() async {
    loading = true;
    notifyListeners();

    try {
      // Cargar datos en paralelo
      await Future.wait([
        _cargarCategorias(),
        _cargarCompetencias(),
        _cargarRendimientosEliminados(),
      ]);
    } catch (e) {
      errorMessage = 'Error al inicializar: ${e.toString()}';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // Cargar categorías
  Future<void> _cargarCategorias() async {
    try {
      categorias = await _categoriaService.getCategorias();
    } catch (e) {
      rethrow;
    }
  }

  // Cargar competencias
  Future<void> _cargarCompetencias() async {
    try {
      competencias = await _competenciaService.getCompetencias();
    } catch (e) {
      rethrow;
    }
  }

  // Cargar rendimientos eliminados
  Future<void> _cargarRendimientosEliminados() async {
    try {
      _todosLosRendimientos = await _rendimientoService.fetchRendimientosEliminadosCompletos();
      rendimientosFiltrados = _todosLosRendimientos;
    } catch (e) {
      errorMessage = 'Error al cargar rendimientos eliminados: ${e.toString()}';
      _todosLosRendimientos = [];
      rendimientosFiltrados = [];
    }
  }

  // Seleccionar categoría
  void seleccionarCategoria(int? idCategoria) {
    categoriaSeleccionadaId = idCategoria;
    jugadorSeleccionadoId = null;
    competenciaSeleccionadaId = null;

    if (idCategoria == null) {
      jugadoresDisponibles = [];
      competenciasDisponibles = [];
      rendimientosFiltrados = _todosLosRendimientos;
    } else {
      // Filtrar jugadores de esa categoría
      final jugadoresSet = <int, JugadorInfo>{};
      for (var rendimiento in _todosLosRendimientos) {
        if (rendimiento.jugador.categoria.idCategorias == idCategoria) {
          jugadoresSet[rendimiento.jugador.idJugadores] = rendimiento.jugador;
        }
      }
      jugadoresDisponibles = jugadoresSet.values.toList();
      
      // Filtrar rendimientos por categoría
      rendimientosFiltrados = _todosLosRendimientos
          .where((r) => r.jugador.categoria.idCategorias == idCategoria)
          .toList();
      
      // Actualizar competencias disponibles
      _actualizarCompetenciasDisponibles();
    }

    notifyListeners();
  }

  // Seleccionar jugador
  void seleccionarJugador(int? idJugador) {
    jugadorSeleccionadoId = idJugador;
    competenciaSeleccionadaId = null;

    if (idJugador == null) {
      // Volver a filtrar solo por categoría
      if (categoriaSeleccionadaId != null) {
        rendimientosFiltrados = _todosLosRendimientos
            .where((r) => r.jugador.categoria.idCategorias == categoriaSeleccionadaId)
            .toList();
      } else {
        rendimientosFiltrados = _todosLosRendimientos;
      }
    } else {
      // Filtrar por jugador
      rendimientosFiltrados = _todosLosRendimientos
          .where((r) => r.jugador.idJugadores == idJugador)
          .toList();
    }

    _actualizarCompetenciasDisponibles();
    notifyListeners();
  }

  // Seleccionar competencia
  void seleccionarCompetencia(int? idCompetencia) {
    competenciaSeleccionadaId = idCompetencia;

    if (idCompetencia == null) {
      // Volver a filtrar por categoría y/o jugador
      if (jugadorSeleccionadoId != null) {
        rendimientosFiltrados = _todosLosRendimientos
            .where((r) => r.jugador.idJugadores == jugadorSeleccionadoId)
            .toList();
      } else if (categoriaSeleccionadaId != null) {
        rendimientosFiltrados = _todosLosRendimientos
            .where((r) => r.jugador.categoria.idCategorias == categoriaSeleccionadaId)
            .toList();
      } else {
        rendimientosFiltrados = _todosLosRendimientos;
      }
    } else {
      // Filtrar por competencia
      var filtrados = _todosLosRendimientos.where((r) {
        return r.partido.cronograma.competencia?.idCompetencias == idCompetencia;
      });

      // Aplicar filtros adicionales
      if (jugadorSeleccionadoId != null) {
        filtrados = filtrados.where((r) => r.jugador.idJugadores == jugadorSeleccionadoId);
      } else if (categoriaSeleccionadaId != null) {
        filtrados = filtrados.where((r) => r.jugador.categoria.idCategorias == categoriaSeleccionadaId);
      }

      rendimientosFiltrados = filtrados.toList();
    }

    notifyListeners();
  }

  // Actualizar competencias disponibles según filtros
  void _actualizarCompetenciasDisponibles() {
    final competenciasSet = <int, Competencia>{};
    
    for (var rendimiento in rendimientosFiltrados) {
      if (rendimiento.partido.cronograma.competencia != null) {
        final compInfo = rendimiento.partido.cronograma.competencia!;
        
        // Buscar la competencia completa en la lista original
        final competenciaCompleta = competencias.firstWhere(
          (c) => c.idCompetencias == compInfo.idCompetencias,
          orElse: () => Competencia(
            idCompetencias: compInfo.idCompetencias,
            nombre: compInfo.nombre,
            tipoCompetencia: compInfo.tipoCompetencia,
            ano: compInfo.ano,
          ),
        );
        
        competenciasSet[compInfo.idCompetencias] = competenciaCompleta;
      }
    }
    
    competenciasDisponibles = competenciasSet.values.toList();
  }

  // Restaurar rendimiento
  Future<bool> restaurarRendimiento(int idRendimiento) async {
    try {
      final exito = await _rendimientoService.restaurarRendimiento(idRendimiento);
      
      if (exito) {
        // Remover de todas las listas
        _todosLosRendimientos.removeWhere((r) => r.idRendimientos == idRendimiento);
        rendimientosFiltrados.removeWhere((r) => r.idRendimientos == idRendimiento);
        
        // Actualizar listas dinámicas
        if (categoriaSeleccionadaId != null) {
          seleccionarCategoria(categoriaSeleccionadaId);
        }
        
        notifyListeners();
      }
      
      return exito;
    } catch (e) {
      rethrow;
    }
  }

  // Eliminar permanentemente
  Future<bool> eliminarPermanentemente(int idRendimiento) async {
    try {
      final exito = await _rendimientoService.eliminarRendimientoPermanentemente(idRendimiento);
      
      if (exito) {
        // Remover de todas las listas
        _todosLosRendimientos.removeWhere((r) => r.idRendimientos == idRendimiento);
        rendimientosFiltrados.removeWhere((r) => r.idRendimientos == idRendimiento);
        
        // Actualizar listas dinámicas
        if (categoriaSeleccionadaId != null) {
          seleccionarCategoria(categoriaSeleccionadaId);
        }
        
        notifyListeners();
      }
      
      return exito;
    } catch (e) {
      rethrow;
    }
  }

  // Buscar rendimiento por texto
  List<RendimientoEliminado> buscarRendimientos(String query) {
    if (query.isEmpty) return rendimientosFiltrados;

    final queryLower = query.toLowerCase();
    
    return rendimientosFiltrados.where((rendimiento) {
      final nombreJugador = rendimiento.jugador.nombreCompleto.toLowerCase();
      final equipoRival = rendimiento.partido.equipoRival.toLowerCase();
      final competencia = rendimiento.partido.cronograma.competencia?.nombre.toLowerCase() ?? '';
      final goles = rendimiento.goles.toString();
      final asistencias = rendimiento.asistencias.toString();
      
      return nombreJugador.contains(queryLower) ||
             equipoRival.contains(queryLower) ||
             competencia.contains(queryLower) ||
             goles.contains(queryLower) ||
             asistencias.contains(queryLower);
    }).toList();
  }
}