import 'package:flutter/material.dart';
import '../../models/competencia_model.dart';
import '../../models/partido_model.dart';
import '../../models/resultado_model.dart';
import '../../models/jugador_model.dart';
import '../../services/resultado_service.dart';
import '../../services/auth_service.dart';
import '../../services/jugador_service.dart';
import '../../services/competencia_service.dart';
import '../../services/cronograma_service.dart';

class ResultadosJugadorController extends ChangeNotifier {
  final ResultadoService _resultadoService = ResultadoService();
  final AuthService _authService = AuthService();
  final JugadorService _jugadorService = JugadorService();
  final CompetenciaService _competenciaService = CompetenciaService();
  final CronogramaService _cronogramaService = CronogramaService();

  // Estado
  Jugador? jugadorData;
  List<Competencia> competencias = [];
  List<Competencia> competenciasFiltradas = [];
  List<Partido> partidos = [];
  List<Partido> partidosFiltrados = [];
  List<Resultado> resultados = [];
  List<Resultado> resultadosFiltrados = [];

  int? competenciaSeleccionada;
  int? partidoSeleccionado;

  bool loading = false;
  bool isLoadingCompetencias = false;
  bool isLoadingPartidos = false;
  bool isLoadingResultados = false;
  String? error;

  // ============================================================
  // INICIALIZACIÓN
  // ============================================================

  Future<void> inicializar() async {
    await cargarDatosIniciales();
  }

  Future<void> cargarDatosIniciales() async {
    loading = true;
    notifyListeners();

    try {
      // Obtener datos del jugador logueado
      final persona = await _authService.obtenerUsuario();
      
      if (persona == null) {
        throw Exception('No se pudo obtener el usuario logueado');
      }

      // Obtener el jugador con su categoría
      final jugador = await _jugadorService.fetchJugadorByPersonaId(persona.idPersonas);
      
      if (jugador == null) {
        throw Exception('No se encontró el jugador');
      }

      jugadorData = jugador;
      
      // Cargar competencias de su categoría
      if (jugador.categoria != null) {
        competenciasFiltradas = await _competenciaService.getCompetenciasByCategoria(
          jugador.categoria!.idCategorias
        );
      }
      
      await Future.wait([
        fetchPartidos(),
        fetchResultados(),
      ]);
    } catch (e) {
      error = 'Error al cargar datos: $e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // FETCH DE DATOS
  // ============================================================

  Future<void> fetchPartidos() async {
    try {
      partidos = await _cronogramaService.getPartidos();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchResultados() async {
    try {
      resultados = await _resultadoService.getResultados();
      resultadosFiltrados = resultados;
      if (resultados.isEmpty) {
      } else {
      }
      
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // FILTRADO
  // ============================================================

  Future<void> filtrarPartidosPorCompetencia(int idCompetencia) async {
    isLoadingPartidos = true;
    notifyListeners();
    
    try {
      final todosLosPartidos = await _cronogramaService.getPartidos();
      final cronogramas = await _cronogramaService.getCronogramas();
      final cronogramasDeCompetencia = cronogramas
          .where((c) => c.idCompetencias == idCompetencia && c.tipoDeEventos == 'Partido')
          .toList();
      
      partidosFiltrados = todosLosPartidos.where((partido) {
        return cronogramasDeCompetencia.any(
          (cronograma) => cronograma.idCronogramas == partido.idCronogramas
        );
      }).toList();
      
      partidoSeleccionado = null;
      resultadosFiltrados = [];
    } catch (e) {
      partidosFiltrados = [];
    } finally {
      isLoadingPartidos = false;
      notifyListeners();
    }
  }

  Future<void> filtrarResultadosPorPartido(int idPartido) async {
    isLoadingResultados = true;
    notifyListeners();
    
    try {
      resultadosFiltrados = resultados.where((r) => r.idPartidos == idPartido).toList();
      
      if (resultadosFiltrados.isEmpty) {
      } else {
      }
    } catch (e) {
      resultadosFiltrados = [];
    } finally {
      isLoadingResultados = false;
      notifyListeners();
    }
  }

  // ============================================================
  // SELECCIÓN
  // ============================================================

  Future<void> seleccionarCompetencia(int? idCompetencia) async {
    competenciaSeleccionada = idCompetencia;
    
    if (idCompetencia != null) {
      await filtrarPartidosPorCompetencia(idCompetencia);
    } else {
      partidosFiltrados = [];
      partidoSeleccionado = null;
      resultadosFiltrados = [];
      notifyListeners();
    }
  }

  Future<void> seleccionarPartido(int? idPartido) async {
    partidoSeleccionado = idPartido;
    
    if (idPartido != null) {
      await filtrarResultadosPorPartido(idPartido);
    } else {
      resultadosFiltrados = [];
      notifyListeners();
    }
  }
}