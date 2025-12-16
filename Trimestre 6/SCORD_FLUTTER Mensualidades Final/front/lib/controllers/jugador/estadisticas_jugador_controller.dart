import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/jugador_service.dart';
import '../../services/rendimiento_service.dart';
import '../../services/competencia_service.dart';
import '../../services/cronograma_service.dart';
import '../../models/persona_model.dart';
import '../../models/jugador_model.dart';
import '../../models/rendimiento_model.dart';
import '../../models/competencia_model.dart';
import '../../models/partido_model.dart';

class EstadisticasJugadorController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final JugadorService _jugadorService = JugadorService();
  final RendimientoService _rendimientoService = RendimientoService();
  final CompetenciaService _competenciaService = CompetenciaService();
  final CronogramaService _cronogramaService = CronogramaService();

  // Estado
  bool loading = true;
  bool isLoadingCompetencias = false;
  bool isLoadingPartidos = false;
  String? error;
  
  Persona? jugadorPersona;
  Jugador? jugadorData;
  EstadisticasTotales? estadisticasTotales;
  
  List<Competencia> competencias = [];
  List<Competencia> competenciasFiltradas = [];
  List<Partido> partidos = [];
  List<Partido> partidosFiltrados = [];
  
  int? competenciaSeleccionada;
  int? partidoSeleccionado;

  // ============================================================
  // INICIALIZACIÓN
  // ============================================================

  Future<void> inicializar() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      // Verificar autenticación
      final isLoggedIn = await _authService.estaLogueado();
      if (!isLoggedIn) {
        throw Exception('Debe iniciar sesión para acceder');
      }

      // Verificar rol de jugador (idRoles = 3)
      final rol = await _authService.obtenerRol();
      if (rol != 3) {
        throw Exception('No tiene permisos de jugador');
      }

      // Obtener datos de la persona
      jugadorPersona = await _authService.obtenerUsuario();
      if (jugadorPersona == null) {
        throw Exception('No se pudieron cargar los datos del usuario');
      }

      // Obtener datos deportivos del jugador
      await _obtenerDatosJugador();

      // Cargar competencias de la categoría del jugador
      if (jugadorData?.categoria?.idCategorias != null) {
        await _cargarCompetenciasDelJugador();
      }

      // Cargar estadísticas totales
      if (jugadorData != null) {
        await fetchEstadisticasTotales(jugadorData!.idJugadores);
      }

      loading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      loading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _obtenerDatosJugador() async {
    try {
      if (jugadorPersona?.idPersonas == null) return;

      jugadorData = await _jugadorService.fetchJugadorByPersonaId(
        jugadorPersona!.idPersonas,
      );

      if (jugadorData != null) {
      } else {
        throw Exception('No se encontró información deportiva del jugador');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _cargarCompetenciasDelJugador() async {
    try {
      final idCategoria = jugadorData!.categoria!.idCategorias;
      
      competenciasFiltradas = await _competenciaService.getCompetenciasByCategoria(idCategoria);
      
    } catch (e) {
      competenciasFiltradas = [];
    }
  }

  // ============================================================
  // FILTRADO
  // ============================================================

  Future<void> seleccionarCompetencia(int? idCompetencia) async {
    competenciaSeleccionada = idCompetencia;
    
    // Filtrar partidos si hay competencia seleccionada
    if (idCompetencia != null) {
      await filtrarPartidosPorCompetencia(idCompetencia);
      
      // 🆕 Recargar estadísticas filtradas por competencia
      if (jugadorData != null) {
        await fetchEstadisticasPorCompetencia(
          jugadorData!.idJugadores, 
          idCompetencia
        );
      }
    } else {
      partidosFiltrados = [];
      partidoSeleccionado = null;
      
      // 🆕 Volver a estadísticas totales
      if (jugadorData != null) {
        await fetchEstadisticasTotales(jugadorData!.idJugadores);
      }
      
      notifyListeners();
    }
  }

  Future<void> filtrarPartidosPorCompetencia(int idCompetencia) async {
    isLoadingPartidos = true;
    notifyListeners();
    
    try {     
      // Obtener todos los partidos
      final todosLosPartidos = await _cronogramaService.getPartidos();
      
      // Obtener cronogramas de esta competencia
      final cronogramas = await _cronogramaService.getCronogramas();
      final cronogramasDeCompetencia = cronogramas
          .where((c) => c.idCompetencias == idCompetencia && c.tipoDeEventos == 'Partido')
          .toList();
      
      // Filtrar partidos que pertenecen a esos cronogramas
      partidosFiltrados = todosLosPartidos.where((partido) {
        return cronogramasDeCompetencia.any(
          (cronograma) => cronograma.idCronogramas == partido.idCronogramas
        );
      }).toList();
      
      // Resetear selección de partido
      partidoSeleccionado = null;
    } catch (e) {
      partidosFiltrados = [];
    } finally {
      isLoadingPartidos = false;
      notifyListeners();
    }
  }

  Future<void> seleccionarPartido(int? idPartido) async {
    partidoSeleccionado = idPartido;
    
    // 🆕 Recargar estadísticas del partido específico
    if (idPartido != null && jugadorData != null) {
      await fetchEstadisticasPorPartido(
        jugadorData!.idJugadores, 
        idPartido
      );
    } else if (competenciaSeleccionada != null && jugadorData != null) {
      // Si deselecciona el partido pero hay competencia, mostrar estadísticas de la competencia
      await fetchEstadisticasPorCompetencia(
        jugadorData!.idJugadores, 
        competenciaSeleccionada!
      );
    } else if (jugadorData != null) {
      // Si no hay filtros, mostrar estadísticas totales
      await fetchEstadisticasTotales(jugadorData!.idJugadores);
    } else {
      notifyListeners();
    }
  }

  // ============================================================
  // ESTADÍSTICAS
  // ============================================================

  Future<void> fetchEstadisticasTotales(int idJugador) async {
    loading = true;
    notifyListeners();
    
    try {
      final estadisticas = await _rendimientoService.obtenerEstadisticasTotales(idJugador);
      if (estadisticas != null) {
        estadisticasTotales = estadisticas;
      }
    } catch (e) {
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// 🆕 Obtener estadísticas filtradas por competencia
  Future<void> fetchEstadisticasPorCompetencia(int idJugador, int idCompetencia) async {
    loading = true;
    notifyListeners();
    
    try {
      final estadisticas = await _rendimientoService.obtenerEstadisticasPorCompetencia(
        idJugador, 
        idCompetencia
      );
      
      if (estadisticas != null) {
        estadisticasTotales = estadisticas;
      } else {
        // Si no hay estadísticas, crear objeto vacío
        estadisticasTotales = EstadisticasTotales(
          totales: {
            'total_goles': 0,
            'total_goles_cabeza': 0,
            'total_minutos_jugados': 0,
            'total_asistencias': 0,
            'total_tiros_apuerta': 0,
            'total_tarjetas_rojas': 0,
            'total_tarjetas_amarillas': 0,
            'total_arco_en_cero': 0,
            'total_fueras_de_lugar': 0,
            'total_partidos_jugados': 0,
          },
          promedios: {
            'goles_por_partido': 0.0,
            'asistencias_por_partido': 0.0,
            'minutos_por_partido': 0.0,
            'tiros_apuerta_por_partido': 0.0,
          },
        );
      }
    } catch (e) {
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// 🆕 Obtener estadísticas de un partido específico
  Future<void> fetchEstadisticasPorPartido(int idJugador, int idPartido) async {
    loading = true;
    notifyListeners();
    
    try {
      final estadisticas = await _rendimientoService.obtenerEstadisticasPorPartido(
        idJugador, 
        idPartido
      );
      
      if (estadisticas != null) {
        estadisticasTotales = estadisticas;
      } else {
        // Si no hay estadísticas, crear objeto vacío
        estadisticasTotales = EstadisticasTotales(
          totales: {
            'total_goles': 0,
            'total_goles_cabeza': 0,
            'total_minutos_jugados': 0,
            'total_asistencias': 0,
            'total_tiros_apuerta': 0,
            'total_tarjetas_rojas': 0,
            'total_tarjetas_amarillas': 0,
            'total_arco_en_cero': 0,
            'total_fueras_de_lugar': 0,
            'total_partidos_jugados': 0,
          },
          promedios: {
            'goles_por_partido': 0.0,
            'asistencias_por_partido': 0.0,
            'minutos_por_partido': 0.0,
            'tiros_apuerta_por_partido': 0.0,
          },
        );
      }
    } catch (e) {
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // UTILIDADES
  // ============================================================

  String calcularEdad(DateTime? fechaNacimiento) { 
    if (fechaNacimiento == null) return "-";
    
    final hoy = DateTime.now();
    int edad = hoy.year - fechaNacimiento.year;
    final mes = hoy.month - fechaNacimiento.month;
    
    if (mes < 0 || (mes == 0 && hoy.day < fechaNacimiento.day)) {
      edad--;
    }
    
    return edad.toString();
  }
}