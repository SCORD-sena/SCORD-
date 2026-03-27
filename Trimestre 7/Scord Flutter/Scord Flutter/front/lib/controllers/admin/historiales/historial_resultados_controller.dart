import 'package:flutter/material.dart';
import '../../../models/resultado_eliminado_model.dart';
import '../../../models/categoria_model.dart';
import '../../../models/competencia_model.dart';
import '../../../services/resultado_service.dart';
import '../../../services/categoria_service.dart';
import '../../../services/competencia_service.dart';

class HistorialResultadosController extends ChangeNotifier {
  final ResultadoService _resultadoService = ResultadoService();
  final CategoriaService _categoriaService = CategoriaService();
  final CompetenciaService _competenciaService = CompetenciaService();

  // State
  List<ResultadoEliminado> _todosLosResultados = [];
  List<ResultadoEliminado> resultadosFiltrados = [];
  List<Categoria> categorias = [];
  List<Competencia> competencias = [];
  
  bool loading = false;
  String? errorMessage;

  // Filtros seleccionados
  int? categoriaSeleccionadaId;
  int? competenciaSeleccionadaId;

  // Listas dinámicas según filtros
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
        _cargarResultadosEliminados(),
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

  // Cargar resultados eliminados
  Future<void> _cargarResultadosEliminados() async {
    try {
      _todosLosResultados = await _resultadoService.fetchResultadosEliminadosCompletos();
      resultadosFiltrados = _todosLosResultados;
      _actualizarCompetenciasDisponibles();
    } catch (e) {
      errorMessage = 'Error al cargar resultados eliminados: ${e.toString()}';
      _todosLosResultados = [];
      resultadosFiltrados = [];
    }
  }

  // Seleccionar categoría
  void seleccionarCategoria(int? idCategoria) {
    categoriaSeleccionadaId = idCategoria;
    competenciaSeleccionadaId = null;

    if (idCategoria == null) {
      competenciasDisponibles = [];
      resultadosFiltrados = _todosLosResultados;
    } else {
      // Filtrar resultados por categoría
      resultadosFiltrados = _todosLosResultados
          .where((r) => r.partido.cronograma.categoria?.idCategorias == idCategoria)
          .toList();
      
      // Actualizar competencias disponibles
      _actualizarCompetenciasDisponibles();
    }

    notifyListeners();
  }

  // Seleccionar competencia
  void seleccionarCompetencia(int? idCompetencia) {
    competenciaSeleccionadaId = idCompetencia;

    if (idCompetencia == null) {
      // Volver a filtrar solo por categoría
      if (categoriaSeleccionadaId != null) {
        resultadosFiltrados = _todosLosResultados
            .where((r) => r.partido.cronograma.categoria?.idCategorias == categoriaSeleccionadaId)
            .toList();
      } else {
        resultadosFiltrados = _todosLosResultados;
      }
    } else {
      // Filtrar por competencia
      var filtrados = _todosLosResultados.where((r) {
        return r.partido.cronograma.competencia?.idCompetencias == idCompetencia;
      });

      // Aplicar filtro adicional de categoría si existe
      if (categoriaSeleccionadaId != null) {
        filtrados = filtrados.where((r) => 
          r.partido.cronograma.categoria?.idCategorias == categoriaSeleccionadaId
        );
      }

      resultadosFiltrados = filtrados.toList();
    }

    notifyListeners();
  }

  // Actualizar competencias disponibles según filtros
  void _actualizarCompetenciasDisponibles() {
    final competenciasSet = <int, Competencia>{};
    
    for (var resultado in resultadosFiltrados) {
      if (resultado.partido.cronograma.competencia != null) {
        final compInfo = resultado.partido.cronograma.competencia!;
        
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

  // Restaurar resultado
  Future<bool> restaurarResultado(int idResultado) async {
    try {
      final exito = await _resultadoService.restaurarResultado(idResultado);
      
      if (exito) {
        // Remover de todas las listas
        _todosLosResultados.removeWhere((r) => r.idResultados == idResultado);
        resultadosFiltrados.removeWhere((r) => r.idResultados == idResultado);
        
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
  Future<bool> eliminarPermanentemente(int idResultado) async {
    try {
      final exito = await _resultadoService.eliminarResultadoPermanentemente(idResultado);
      
      if (exito) {
        // Remover de todas las listas
        _todosLosResultados.removeWhere((r) => r.idResultados == idResultado);
        resultadosFiltrados.removeWhere((r) => r.idResultados == idResultado);
        
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

  // Buscar resultado por texto
  List<ResultadoEliminado> buscarResultados(String query) {
    if (query.isEmpty) return resultadosFiltrados;

    final queryLower = query.toLowerCase();
    
    return resultadosFiltrados.where((resultado) {
      final equipoRival = resultado.partido.equipoRival.toLowerCase();
      final marcador = resultado.marcador.toLowerCase();
      final competencia = resultado.partido.cronograma.competencia?.nombre.toLowerCase() ?? '';
      final puntos = resultado.puntosObtenidos.toString();
      
      return equipoRival.contains(queryLower) ||
             marcador.contains(queryLower) ||
             competencia.contains(queryLower) ||
             puntos.contains(queryLower);
    }).toList();
  }
}