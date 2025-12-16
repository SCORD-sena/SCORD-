import '../../models/cronograma_model.dart';
import '../../models/partido_model.dart';
import '../../models/categoria_model.dart';
import '../../models/competencia_model.dart';
import '../../services/cronograma_service.dart';
import '../../services/competencia_service.dart'; // ← AGREGADO
import '../../services/auth_service.dart';
import '../../services/jugador_service.dart';

class CronogramaJugadorController {
  final CronogramaService _cronogramaService = CronogramaService();
  final CompetenciaService _competenciaService = CompetenciaService(); // ← AGREGADO
  final AuthService _authService = AuthService();
  final JugadorService _jugadorService = JugadorService();

  // Datos
  List<Cronograma> cronogramas = [];
  List<Cronograma> entrenamientos = [];
  List<Partido> partidos = [];
  List<Competencia> competencias = []; // ← AGREGADO
  Categoria? miCategoria;
  int? miIdCategoria;

  // Estados
  bool isLoading = true;
  String? error;

  // Búsqueda separada
  String searchTermPartido = '';
  String searchTermEntrenamiento = '';

  // Paginación
  int currentPagePartido = 1;
  int currentPageEntrenamiento = 1;
  final int itemsPerPage = 5;

  // ============================================================
  // INICIALIZAR
  // ============================================================

  Future<void> initialize() async {
    isLoading = true;
    error = null;

    try {
      await _obtenerMiCategoria();

      if (miIdCategoria == null) {
        error = 'No se pudo determinar tu categoría';
        isLoading = false;
        return;
      }

      await _cargarCompetencias(); // ← AGREGADO
      await _cargarCronogramas();

      isLoading = false;
    } catch (e) {
      print('❌ Error inicializando cronograma jugador: $e');
      error = 'Error al cargar el cronograma: $e';
      isLoading = false;
    }
  }

  // ============================================================
  // OBTENER CATEGORÍA DEL JUGADOR
  // ============================================================

  Future<void> _obtenerMiCategoria() async {
    try {
      final persona = await _authService.obtenerUsuario();
      
      if (persona == null) {
        throw Exception('No se encontró información del usuario');
      }

      final jugador = await _jugadorService.fetchJugadorByPersonaId(
        persona.idPersonas,
      );

      if (jugador == null) {
        throw Exception('No se encontró información deportiva');
      }

      miIdCategoria = jugador.idCategorias;
      miCategoria = jugador.categoria;

      print('✅ Categoría del jugador: ${miCategoria?.descripcion ?? "ID: $miIdCategoria"}');
    } catch (e) {
      print('❌ Error obteniendo categoría del jugador: $e');
      throw e;
    }
  }

  // ============================================================
  // CARGAR COMPETENCIAS - NUEVO
  // ============================================================

  Future<void> _cargarCompetencias() async {
    try {
      // ✅ SOLUCIÓN: Cargar solo las competencias de la categoría del jugador
      if (miIdCategoria != null) {
        competencias = await _competenciaService.getCompetenciasByCategoria(miIdCategoria!);
        print('✅ Competencias cargadas para categoría $miIdCategoria: ${competencias.length}');
        if (competencias.isNotEmpty) {
          print('   Primera competencia: ID ${competencias.first.idCompetencias} - ${competencias.first.nombre}');
        }
      } else {
        print('⚠️ No se puede cargar competencias: miIdCategoria es null');
        competencias = [];
      }
    } catch (e) {
      print('⚠️ Error cargando competencias: $e');
      competencias = [];
    }
  }

  // ============================================================
  // CARGAR CRONOGRAMAS
  // ============================================================

  Future<void> _cargarCronogramas() async {
    try {
      final todosCronogramas = await _cronogramaService.getCronogramas();

      cronogramas = todosCronogramas
          .where((c) => c.idCategorias == miIdCategoria)
          .toList();

      entrenamientos = cronogramas
          .where((c) => c.tipoDeEventos == 'Entrenamiento')
          .toList();

      final partidosCronogramas = cronogramas
          .where((c) => c.tipoDeEventos == 'Partido')
          .toList();

      final todosPartidos = await _cronogramaService.getPartidos();

      partidos = todosPartidos.where((p) {
        return partidosCronogramas.any((c) => c.idCronogramas == p.idCronogramas);
      }).toList();

      entrenamientos.sort((a, b) => 
        b.fechaDeEventos.compareTo(a.fechaDeEventos)
      );

      print('✅ Cronogramas cargados: ${cronogramas.length}');
      print('   - Entrenamientos: ${entrenamientos.length}');
      print('   - Partidos: ${partidos.length}');
    } catch (e) {
      print('❌ Error cargando cronogramas: $e');
      throw e;
    }
  }

  // ============================================================
  // FILTROS Y BÚSQUEDA
  // ============================================================

  List<Cronograma> get filteredEntrenamientos {
    if (searchTermEntrenamiento.isEmpty) return entrenamientos;

    return entrenamientos.where((e) {
      final searchLower = searchTermEntrenamiento.toLowerCase();
      return e.fechaDeEventos.toLowerCase().contains(searchLower) ||
          e.ubicacion.toLowerCase().contains(searchLower) ||
          (e.sedeEntrenamiento?.toLowerCase().contains(searchLower) ?? false) ||
          (e.descripcion?.toLowerCase().contains(searchLower) ?? false);
    }).toList();
  }

  List<Partido> get filteredPartidos {
    if (searchTermPartido.isEmpty) return partidos;

    return partidos.where((p) {
      final cronograma = cronogramas.firstWhere(
        (c) => c.idCronogramas == p.idCronogramas,
        orElse: () => Cronograma(
          idCronogramas: 0,
          tipoDeEventos: '',
          fechaDeEventos: '',
          ubicacion: '',
          idCategorias: 0,
        ),
      );

      final searchLower = searchTermPartido.toLowerCase();
      return p.formacion.toLowerCase().contains(searchLower) ||
          p.equipoRival.toLowerCase().contains(searchLower) ||
          cronograma.fechaDeEventos.toLowerCase().contains(searchLower) ||
          cronograma.ubicacion.toLowerCase().contains(searchLower);
    }).toList();
  }

  // ============================================================
  // PAGINACIÓN
  // ============================================================

  List<Cronograma> get paginatedEntrenamientos {
    final start = (currentPageEntrenamiento - 1) * itemsPerPage;
    final end = start + itemsPerPage;
    return filteredEntrenamientos.sublist(
      start,
      end > filteredEntrenamientos.length ? filteredEntrenamientos.length : end,
    );
  }

  List<Partido> get paginatedPartidos {
    final start = (currentPagePartido - 1) * itemsPerPage;
    final end = start + itemsPerPage;
    return filteredPartidos.sublist(
      start,
      end > filteredPartidos.length ? filteredPartidos.length : end,
    );
  }

  int get totalPagesEntrenamiento =>
      (filteredEntrenamientos.length / itemsPerPage).ceil();
  int get totalPagesPartido =>
      (filteredPartidos.length / itemsPerPage).ceil();

  get categorias => null;

  // ============================================================
  // HELPERS
  // ============================================================

  void actualizarBusqueda(String termino) {
    searchTermPartido = termino;
    searchTermEntrenamiento = termino;
    currentPagePartido = 1;
    currentPageEntrenamiento = 1;
  }

  Future<void> refrescar() async {
    await initialize();
  }

  Cronograma? getCronogramaById(int idCronograma) {
    try {
      return cronogramas.firstWhere((c) => c.idCronogramas == idCronograma);
    } catch (e) {
      return null;
    }
  }

  // ← MÉTODO NUEVO AGREGADO
  Competencia? getCompetenciaById(int? idCompetencia) {
    if (idCompetencia == null) return null;
    
    try {
      return competencias.firstWhere(
        (c) => c.idCompetencias == idCompetencia,
      );
    } catch (e) {
      return null;
    }
  }
}