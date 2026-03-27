import 'package:flutter/material.dart';
import 'dart:convert';
import '../../models/categoria_model.dart';
import '../../models/jugador_model.dart';
import '../../models/rendimiento_model.dart';
import '../../models/competencia_model.dart';
import '../../models/partido_model.dart';
import '../../services/rendimiento_service.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/entrenador_service.dart';
import '../../services/jugador_service.dart';
import '../../services/competencia_service.dart';
import '../../services/cronograma_service.dart';
import '../../utils/validator.dart';

class EstadisticasEntrenadorController extends ChangeNotifier {
  final RendimientoService _rendimientoService = RendimientoService();
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final EntrenadorService _entrenadorService = EntrenadorService();
  final JugadorService _jugadorService = JugadorService();
  final CompetenciaService _competenciaService = CompetenciaService();
  final CronogramaService _cronogramaService = CronogramaService();

  // State
  List<Jugador> jugadores = [];
  List<Categoria> categorias = [];
  List<Categoria> categoriasEntrenador = []; // ⭐ Solo categorías del entrenador
  List<Competencia> competencias = [];
  List<Competencia> competenciasFiltradas = [];
  List<Partido> partidos = [];
  List<Partido> partidosFiltrados = [];
  
  String? categoriaSeleccionadaId;
  int? competenciaSeleccionada;
  int? partidoSeleccionado;
  
  Jugador? jugadorSeleccionado;
  List<Jugador> jugadoresFiltrados = [];
  EstadisticasTotales? estadisticasTotales;
  bool modoEdicion = false;
  bool loading = false;
  bool isLoadingCompetencias = false;
  bool isLoadingPartidos = false;
  UltimoRegistro? ultimoRegistro;

  Map<String, String> formData = {
    'goles': "",
    'golesDeCabeza': "",
    'minutosJugados': "",
    'asistencias': "",
    'tirosApuerta': "",
    'tarjetasRojas': "",
    'tarjetasAmarillas': "",
    'fuerasDeLugar': "",
    'arcoEnCero': "",
  };

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
      final persona = await _authService.obtenerUsuario();
      
      if (persona == null) {
        throw Exception('No se pudo obtener el usuario logueado');
      }

      final entrenador = await _entrenadorService.getEntrenadorByPersonaId(persona.idPersonas);
      
      if (entrenador == null || entrenador.categorias == null || entrenador.categorias!.isEmpty) {
        throw Exception('El entrenador no tiene categorías asignadas');
      }

      categoriasEntrenador = entrenador.categorias!;
      final idsCategorias = categoriasEntrenador.map((c) => c.idCategorias).toList();
      jugadores = await _jugadorService.fetchJugadoresByCategoriasEntrenador(idsCategorias);
      
      await fetchCategorias();
      
      competencias = await _competenciaService.getCompetencias();
      partidos = await _cronogramaService.getPartidos();
      
    } catch (e) {
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // FILTRADO
  // ============================================================

  void filtrarJugadores(String? categoriaId) {
    if (categoriaId != null) {
      final id = int.tryParse(categoriaId);
      jugadoresFiltrados = jugadores.where((j) => j.categoria?.idCategorias == id).toList();
      jugadorSeleccionado = null;
      estadisticasTotales = null;
      modoEdicion = false;
    } else {
      jugadoresFiltrados = [];
      jugadorSeleccionado = null;
      estadisticasTotales = null;
      modoEdicion = false;
    }
    notifyListeners();
  }

  Future<void> filtrarCompetenciasPorCategoria(int idCategoria) async {
  isLoadingCompetencias = true;
  notifyListeners();
  
  try {
    final data = await _competenciaService.getCompetenciasByCategoria(idCategoria);
    
    // 🆕 FILTRAR DUPLICADOS por idCompetencias
    final Map<int, Competencia> competenciasUnicas = {};
    for (var comp in data) {
      if (!competenciasUnicas.containsKey(comp.idCompetencias)) {
        competenciasUnicas[comp.idCompetencias] = comp;
      } else {
        print('⚠️ Competencia duplicada encontrada: ID=${comp.idCompetencias}, Nombre=${comp.nombre}');
      }
    }
    
    competenciasFiltradas = competenciasUnicas.values.toList();
    
    print('✅ Competencias únicas cargadas: ${competenciasFiltradas.length}');
    competenciasFiltradas.forEach((c) => print('  - ID: ${c.idCompetencias}, Nombre: ${c.nombre}'));
    
    competenciaSeleccionada = null;
    partidoSeleccionado = null;
    partidosFiltrados = [];
  } catch (e) {
    print('❌ Error filtrando competencias: $e');
    competenciasFiltradas = [];
  } finally {
    isLoadingCompetencias = false;
    notifyListeners();
  }
}

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
    } catch (e) {
      partidosFiltrados = [];
    } finally {
      isLoadingPartidos = false;
      notifyListeners();
    }
  }

  // ============================================================
  // FETCH DE DATOS
  // ============================================================

  Future<void> fetchCategorias() async {
    try {
      final res = await _apiService.get('/categorias');
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        categorias = (data as List).map((i) => Categoria.fromJson(i)).toList();
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchEstadisticasTotales(int idJugador) async {
    loading = true;
    notifyListeners();
    
    try {
      final estadisticas = await _rendimientoService.obtenerEstadisticasTotales(idJugador);
      if (estadisticas != null) {
        estadisticasTotales = estadisticas;
      }
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
  // EDICIÓN
  // ============================================================

  void activarEdicion() {
    if (jugadorSeleccionado == null) {
      throw Exception('No hay jugador seleccionado');
    }
    
    // Este método se llama DESPUÉS de cargarEstadisticasParaEditar
    // cuando el usuario ya seleccionó competencia y partido
    modoEdicion = true;
    notifyListeners();
  }

  Future<void> cargarUltimoRegistroParaEditar() async {
    try {
      final idJugador = jugadorSeleccionado!.idJugadores;
      final registro = await _rendimientoService.obtenerUltimoRegistro(idJugador);

      if (registro != null) {
        ultimoRegistro = registro;
        formData = {
          'goles': registro.goles.toString(),
          'golesDeCabeza': registro.golesDeCabeza.toString(),
          'minutosJugados': registro.minutosJugados.toString(),
          'asistencias': registro.asistencias.toString(),
          'tirosApuerta': registro.tirosApuerta.toString(),
          'tarjetasRojas': registro.tarjetasRojas.toString(),
          'tarjetasAmarillas': registro.tarjetasAmarillas.toString(),
          'fuerasDeLugar': registro.fuerasDeLugar.toString(),
          'arcoEnCero': registro.arcoEnCero.toString(),
        };
        modoEdicion = true;
        notifyListeners();
      } else {
        throw Exception('No hay estadísticas registradas para este jugador');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> guardarCambios(BuildContext context) async {
    if (!Validator.validarEstadisticas(formData, context)) return false;

    loading = true;
    notifyListeners();

    try {
      if (ultimoRegistro == null || jugadorSeleccionado == null) {
        throw Exception("No se encontró el registro o el jugador para actualizar.");
      }

      final dataToUpdate = UltimoRegistro(
        idRendimientos: ultimoRegistro!.idRendimientos,
        idPartidos: ultimoRegistro!.idPartidos,
        goles: int.tryParse(formData['goles']!) ?? 0,
        golesDeCabeza: int.tryParse(formData['golesDeCabeza']!) ?? 0,
        minutosJugados: int.tryParse(formData['minutosJugados']!) ?? 0,
        asistencias: int.tryParse(formData['asistencias']!) ?? 0,
        tirosApuerta: int.tryParse(formData['tirosApuerta']!) ?? 0,
        tarjetasRojas: int.tryParse(formData['tarjetasRojas']!) ?? 0,
        tarjetasAmarillas: int.tryParse(formData['tarjetasAmarillas']!) ?? 0,
        fuerasDeLugar: int.tryParse(formData['fuerasDeLugar']!) ?? 0,
        arcoEnCero: int.tryParse(formData['arcoEnCero']!) ?? 0,
      ).toUpdateJson(jugadorSeleccionado!.idJugadores);

      final exito = await _rendimientoService.actualizarRendimiento(
        ultimoRegistro!.idRendimientos, 
        dataToUpdate
      );

      if (exito) {
        // 🆕 Recargar estadísticas según filtros activos
        if (partidoSeleccionado != null) {
          await fetchEstadisticasPorPartido(jugadorSeleccionado!.idJugadores, partidoSeleccionado!);
        } else if (competenciaSeleccionada != null) {
          await fetchEstadisticasPorCompetencia(jugadorSeleccionado!.idJugadores, competenciaSeleccionada!);
        } else {
          await fetchEstadisticasTotales(jugadorSeleccionado!.idJugadores);
        }
        
        cancelarEdicion();
        return true;
      } else {
        throw Exception('Error al actualizar');
      }
    } catch (e) {
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void cancelarEdicion() {
    modoEdicion = false;
    ultimoRegistro = null;
    formData = {
      'goles': "",
      'golesDeCabeza': "",
      'minutosJugados': "",
      'asistencias': "",
      'tirosApuerta': "",
      'tarjetasRojas': "",
      'tarjetasAmarillas': "",
      'fuerasDeLugar': "",
      'arcoEnCero': "",
    };
    notifyListeners();
  }

  Future<bool> eliminarEstadistica() async {
    if (jugadorSeleccionado == null) {
      throw Exception('No hay jugador seleccionado');
    }

    loading = true;
    notifyListeners();

    try {
      final idJugador = jugadorSeleccionado!.idJugadores;
      final registro = await _rendimientoService.obtenerUltimoRegistro(idJugador);

      if (registro != null) {
        final exito = await _rendimientoService.eliminarRendimiento(registro.idRendimientos);

        if (exito) {
          // 🆕 Recargar estadísticas según filtros activos
          if (partidoSeleccionado != null) {
            await fetchEstadisticasPorPartido(idJugador, partidoSeleccionado!);
          } else if (competenciaSeleccionada != null) {
            await fetchEstadisticasPorCompetencia(idJugador, competenciaSeleccionada!);
          } else {
            await fetchEstadisticasTotales(idJugador);
          }
          
          cancelarEdicion();
          return true;
        } else {
          throw Exception('Error al eliminar');
        }
      } else {
        throw Exception('No hay estadísticas para eliminar');
      }
    } catch (e) {
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // SELECCIONES
  // ============================================================

  Future<void> seleccionarJugador(int? idJugador) async {
    if (idJugador != null) {
      jugadorSeleccionado = jugadores.firstWhere((j) => j.idJugadores == idJugador);
      
      // 🆕 Recargar estadísticas según filtros activos
      if (partidoSeleccionado != null) {
        await fetchEstadisticasPorPartido(idJugador, partidoSeleccionado!);
      } else if (competenciaSeleccionada != null) {
        await fetchEstadisticasPorCompetencia(idJugador, competenciaSeleccionada!);
      } else {
        await fetchEstadisticasTotales(idJugador);
      }
    } else {
      jugadorSeleccionado = null;
      estadisticasTotales = null;
    }
    notifyListeners();
  }

  Future<void> seleccionarCategoria(String? categoriaId) async {
    categoriaSeleccionadaId = categoriaId;
    filtrarJugadores(categoriaId);
    
    if (categoriaId != null) {
      final id = int.tryParse(categoriaId);
      if (id != null) {
        await filtrarCompetenciasPorCategoria(id);
      }
    } else {
      competenciasFiltradas = [];
      competenciaSeleccionada = null;
      partidosFiltrados = [];
      partidoSeleccionado = null;
      notifyListeners();
    }
  }

  Future<void> seleccionarCompetencia(int? idCompetencia) async {
    competenciaSeleccionada = idCompetencia;
    
    if (idCompetencia != null) {
      await filtrarPartidosPorCompetencia(idCompetencia);
      
      // 🆕 Recargar estadísticas filtradas por competencia
      if (jugadorSeleccionado != null) {
        await fetchEstadisticasPorCompetencia(
          jugadorSeleccionado!.idJugadores, 
          idCompetencia
        );
      }
    } else {
      partidosFiltrados = [];
      partidoSeleccionado = null;
      
      // 🆕 Volver a estadísticas totales
      if (jugadorSeleccionado != null) {
        await fetchEstadisticasTotales(jugadorSeleccionado!.idJugadores);
      }
      
      notifyListeners();
    }
  }

  Future<void> seleccionarPartido(int? idPartido) async {
    partidoSeleccionado = idPartido;
    
    // 🆕 Recargar estadísticas del partido específico
    if (idPartido != null && jugadorSeleccionado != null) {
      await fetchEstadisticasPorPartido(
        jugadorSeleccionado!.idJugadores, 
        idPartido
      );
    } else if (competenciaSeleccionada != null && jugadorSeleccionado != null) {
      await fetchEstadisticasPorCompetencia(
        jugadorSeleccionado!.idJugadores, 
        competenciaSeleccionada!
      );
    } else if (jugadorSeleccionado != null) {
      await fetchEstadisticasTotales(jugadorSeleccionado!.idJugadores);
    } else {
      notifyListeners();
    }
  }

  // ============================================================
  // UTILIDADES
  // ============================================================

  void actualizarCampo(String campo, String valor) {
    formData[campo] = valor;
    notifyListeners();
  }

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
  // ============================================================
  //  MÉTODOS PARA EDICIÓN CON SELECCIÓN DE PARTIDO
  // ============================================================

  /// Cargar partidos por competencia (para el diálogo de edición)
  Future<List<Partido>> cargarPartidosPorCompetenciaParaEditar(int idCompetencia) async {
    try {
      final todosLosPartidos = await _cronogramaService.getPartidos();
      final cronogramas = await _cronogramaService.getCronogramas();
      final cronogramasDeCompetencia = cronogramas
          .where((c) => c.idCompetencias == idCompetencia && c.tipoDeEventos == 'Partido')
          .toList();
      
      final partidosFiltrados = todosLosPartidos.where((partido) {
        return cronogramasDeCompetencia.any(
          (cronograma) => cronograma.idCronogramas == partido.idCronogramas
        );
      }).toList();
      return partidosFiltrados;
    } catch (e) {
      return [];
    }
  }
      
    

  /// Cargar estadísticas específicas de un partido para editar
  Future<void> cargarEstadisticasParaEditar(int idCompetencia, int idPartido) async {
    if (jugadorSeleccionado == null) {
      throw Exception('No hay jugador seleccionado');
    }

    loading = true;
    notifyListeners();

    try {
      final idJugador = jugadorSeleccionado!.idJugadores;
      
      print('🔍 Buscando rendimiento: Jugador=$idJugador, Partido=$idPartido');
      
      // Obtener el registro específico del partido
      final registro = await _rendimientoService.obtenerRendimientoPorPartido(
        idJugador, 
        idPartido
      );

      if (registro != null) {
        print('✅ Registro encontrado: ${registro.goles} goles, ${registro.asistencias} asistencias');
        
        ultimoRegistro = registro;
        
        // Cargar el formData con los valores del partido seleccionado
        formData = {
          'goles': registro.goles.toString(),
          'golesDeCabeza': registro.golesDeCabeza.toString(),
          'minutosJugados': registro.minutosJugados.toString(),
          'asistencias': registro.asistencias.toString(),
          'tirosApuerta': registro.tirosApuerta.toString(),
          'tarjetasRojas': registro.tarjetasRojas.toString(),
          'tarjetasAmarillas': registro.tarjetasAmarillas.toString(),
          'fuerasDeLugar': registro.fuerasDeLugar.toString(),
          'arcoEnCero': registro.arcoEnCero.toString(),
        };

        // Guardar los IDs para la actualización posterior
        competenciaSeleccionada = idCompetencia;
        partidoSeleccionado = idPartido;
        
        print('📝 FormData cargado: $formData');
        
      } else {
        throw Exception('No se encontraron estadísticas para este partido');
      }
    } catch (e) {
      print('❌ Error en cargarEstadisticasParaEditar: $e');
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

}