import 'package:flutter/material.dart';
import '../../models/cronograma_model.dart';
import '../../models/partido_model.dart';
import '../../models/categoria_model.dart';
import '../../models/competencia_model.dart';
import '../../services/cronograma_service.dart';
import '../../services/competencia_service.dart';

class CronogramaEntrenadorController {
  final CronogramaService _service = CronogramaService();
  final CompetenciaService _competenciaService = CompetenciaService();

  // Datos
  List<Cronograma> cronogramas = [];
  List<Cronograma> entrenamientos = [];
  List<Cronograma> partidos = [];
  List<Partido> partidosAPI = [];
  List<Categoria> categoriasAPI = [];
  List<int> misCategoriasIds = [];
  List<Competencia> competencias = [];
  List<Competencia> competenciasFiltradas = [];

  // Estados de carga
  bool isLoading = true;
  bool isLoadingCategorias = true;
  bool isLoadingCompetencias = true;

  // Búsqueda y paginación - Entrenamientos
  String searchTermEntrenamiento = '';
  int currentPageEntrenamiento = 1;
  final int itemsPerPage = 5;

  // Búsqueda y paginación - Partidos
  String searchTermPartido = '';
  int currentPagePartido = 1;

  // Edición
  int? editingId;
  String? editingType;

  // Controladores Entrenamiento
  final TextEditingController fechaEntrenamientoController = TextEditingController();
  final TextEditingController ubicacionEntrenamientoController = TextEditingController();
  final TextEditingController descripcionEntrenamientoController = TextEditingController();
  String? sedeEntrenamientoSeleccionada;
  int? categoriaEntrenamientoSeleccionada;

  // Controladores Partido
  final TextEditingController fechaPartidoController = TextEditingController();
  final TextEditingController ubicacionPartidoController = TextEditingController();
  final TextEditingController canchaPartidoController = TextEditingController();
  final TextEditingController equipoRivalController = TextEditingController();
  final TextEditingController formacionController = TextEditingController();
  int? categoriaPartidoSeleccionada;
  int? competenciaPartidoSeleccionada;

  // ============================================================
  // CARGAR DATOS
  // ============================================================

  Future<void> loadData() async {
    isLoading = true;
    try {
      // Primero cargar las categorías del entrenador
      await loadMisCategorias();
      
      // Luego cargar el resto de datos
      if (misCategoriasIds.isNotEmpty) {
        await Future.wait([
          loadCronogramas(),
          loadPartidos(),
          loadCategoriasAPI(),
          loadCompetencias(),
        ]);
      }
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  Future<void> loadMisCategorias() async {
    try {
      final categorias = await _service.getMisCategorias();
      misCategoriasIds = categorias.map((cat) => cat.idCategorias).toList();
    } catch (e) {
      throw Exception('No se pudieron cargar tus categorías. Contacta al administrador.');
    }
  }

  Future<void> loadCronogramas() async {
    final data = await _service.getCronogramas();
    // Filtrar solo cronogramas de las categorías del entrenador
    final misCronogramas = data.where((c) => misCategoriasIds.contains(c.idCategorias)).toList();
    
    cronogramas = misCronogramas;
    entrenamientos = misCronogramas.where((c) => c.tipoDeEventos == 'Entrenamiento').toList();
    partidos = misCronogramas.where((c) => c.tipoDeEventos == 'Partido').toList();
  }

  Future<void> loadPartidos() async {
    final data = await _service.getPartidos();
    // Filtrar solo partidos de las categorías del entrenador
    partidosAPI = data.where((p) {
      final cronograma = cronogramas.firstWhere(
        (c) => c.idCronogramas == p.idCronogramas,
        orElse: () => Cronograma(
          idCronogramas: 0,
          tipoDeEventos: '',
          fechaDeEventos: '',
          ubicacion: '',
          idCategorias: 0,
          idCompetencias: null,
        ),
      );
      return misCategoriasIds.contains(cronograma.idCategorias);
    }).toList();
  }

  Future<void> loadCategoriasAPI() async {
    isLoadingCategorias = true;
    try {
      final data = await _service.getCategorias();
      // Filtrar solo las categorías del entrenador
      categoriasAPI = data.where((cat) => misCategoriasIds.contains(cat.idCategorias)).toList();
    } finally {
      isLoadingCategorias = false;
    }
  }

  Future<void> loadCompetencias() async {
    isLoadingCompetencias = true;
    try {
      competencias = await _competenciaService.getCompetencias();
    } finally {
      isLoadingCompetencias = false;
    }
  }

  // ============================================================
  // COMPETENCIAS FILTRADAS
  // ============================================================

  Future<void> loadCompetenciasByCategoria(int idCategorias) async {
    isLoadingCompetencias = true;
    try {
      final data = await _competenciaService.getCompetenciasByCategoria(idCategorias);
      competenciasFiltradas = data;
    } catch (e) {
      competenciasFiltradas = [];
    } finally {
      isLoadingCompetencias = false;
    }
  }

  // ============================================================
  // VALIDACIONES DE PERMISOS
  // ============================================================

  bool puedeGestionarCategoria(int idCategoria) {
    return misCategoriasIds.contains(idCategoria);
  }

  // ============================================================
  // CRUD ENTRENAMIENTOS
  // ============================================================

  Future<void> agregarEntrenamiento() async {
    if (categoriaEntrenamientoSeleccionada == null) {
      throw Exception('Por favor seleccione una categoría');
    }

    if (!puedeGestionarCategoria(categoriaEntrenamientoSeleccionada!)) {
      throw Exception('No puedes agregar entrenamientos a esta categoría');
    }

    final cronograma = Cronograma(
      idCronogramas: 0,
      tipoDeEventos: 'Entrenamiento',
      fechaDeEventos: fechaEntrenamientoController.text,
      ubicacion: ubicacionEntrenamientoController.text,
      sedeEntrenamiento: sedeEntrenamientoSeleccionada,
      descripcion: descripcionEntrenamientoController.text,
      idCategorias: categoriaEntrenamientoSeleccionada!,
      idCompetencias: null, // ✅ NULL para entrenamientos
    );

    await _service.createCronograma(cronograma);
    await loadCronogramas();
    limpiarFormularioEntrenamiento();
  }

  Future<void> actualizarEntrenamiento() async {
    if (editingId == null) return;

    if (categoriaEntrenamientoSeleccionada != null && 
        !puedeGestionarCategoria(categoriaEntrenamientoSeleccionada!)) {
      throw Exception('No tienes permiso para actualizar este entrenamiento');
    }

    final cronograma = Cronograma(
      idCronogramas: editingId!,
      tipoDeEventos: 'Entrenamiento',
      fechaDeEventos: fechaEntrenamientoController.text,
      ubicacion: ubicacionEntrenamientoController.text,
      sedeEntrenamiento: sedeEntrenamientoSeleccionada,
      descripcion: descripcionEntrenamientoController.text,
      idCategorias: categoriaEntrenamientoSeleccionada!,
      idCompetencias: null, // ✅ NULL para entrenamientos
    );

    await _service.updateCronograma(editingId!, cronograma);
    await loadCronogramas();
    cancelarEdicion();
  }

  Future<void> eliminarEntrenamiento(int id) async {
    await _service.deleteCronograma(id);
    await loadCronogramas();
  }

  Future<void> editarEntrenamiento(Cronograma cronograma) async {
    editingId = cronograma.idCronogramas;
    editingType = 'Entrenamiento';
    fechaEntrenamientoController.text = cronograma.fechaDeEventos;
    ubicacionEntrenamientoController.text = cronograma.ubicacion;
    descripcionEntrenamientoController.text = cronograma.descripcion ?? '';
    sedeEntrenamientoSeleccionada = cronograma.sedeEntrenamiento;
    categoriaEntrenamientoSeleccionada = cronograma.idCategorias;
    
    // Cargar competencias
    await loadCompetenciasByCategoria(cronograma.idCategorias);
  }

  // ============================================================
  // CRUD PARTIDOS
  // ============================================================

  Future<void> agregarPartido() async {
    if (categoriaPartidoSeleccionada == null) {
      throw Exception('Por favor seleccione una categoría');
    }

    if (competenciaPartidoSeleccionada == null) {
      throw Exception('Por favor seleccione una competencia');
    }

    if (!puedeGestionarCategoria(categoriaPartidoSeleccionada!)) {
      throw Exception('No puedes agregar partidos a esta categoría');
    }

    // Crear cronograma
    final cronograma = Cronograma(
      idCronogramas: 0,
      tipoDeEventos: 'Partido',
      fechaDeEventos: fechaPartidoController.text,
      ubicacion: ubicacionPartidoController.text,
      canchaPartido: canchaPartidoController.text,
      sedeEntrenamiento: '',
      descripcion: 'Partido vs ${equipoRivalController.text}',
      idCategorias: categoriaPartidoSeleccionada!,
      idCompetencias: competenciaPartidoSeleccionada!, // ✅ ID de competencia
    );

    await _service.createCronograma(cronograma);

    // Recargar para obtener el ID del cronograma creado
    await loadCronogramas();
    final nuevoCronograma = cronogramas.lastWhere((c) => c.tipoDeEventos == 'Partido');

    // Crear partido
    final partido = Partido(
      idPartidos: 0,
      formacion: formacionController.text,
      equipoRival: equipoRivalController.text,
      idCronogramas: nuevoCronograma.idCronogramas,
    );

    await _service.createPartido(partido);
    await loadPartidos();
    await loadCronogramas();
    limpiarFormularioPartido();
  }

  Future<void> actualizarPartido() async {
    if (editingId == null) return;

    final partidoActual = partidosAPI.firstWhere((p) => p.idPartidos == editingId);

    if (categoriaPartidoSeleccionada != null && 
        !puedeGestionarCategoria(categoriaPartidoSeleccionada!)) {
      throw Exception('No tienes permiso para actualizar este partido');
    }

    // Actualizar cronograma
    final cronograma = Cronograma(
      idCronogramas: partidoActual.idCronogramas,
      tipoDeEventos: 'Partido',
      fechaDeEventos: fechaPartidoController.text,
      ubicacion: ubicacionPartidoController.text,
      canchaPartido: canchaPartidoController.text,
      sedeEntrenamiento: '',
      descripcion: 'Partido vs ${equipoRivalController.text}',
      idCategorias: categoriaPartidoSeleccionada!,
      idCompetencias: competenciaPartidoSeleccionada!, // ✅ ID de competencia
    );

    await _service.updateCronograma(partidoActual.idCronogramas, cronograma);

    // Actualizar partido
    final partido = Partido(
      idPartidos: editingId!,
      formacion: formacionController.text,
      equipoRival: equipoRivalController.text,
      idCronogramas: partidoActual.idCronogramas,
    );

    await _service.updatePartido(editingId!, partido);
    await loadPartidos();
    await loadCronogramas();
    cancelarEdicion();
  }

  Future<void> eliminarPartido(int id) async {
    await _service.deletePartido(id);
    await loadPartidos();
    await loadCronogramas();
  }

  Future<void> editarPartido(Partido partido) async {
    final cronograma = cronogramas.firstWhere((c) => c.idCronogramas == partido.idCronogramas);

    editingId = partido.idPartidos;
    editingType = 'PartidoAPI';
    fechaPartidoController.text = cronograma.fechaDeEventos;
    ubicacionPartidoController.text = cronograma.ubicacion;
    canchaPartidoController.text = cronograma.canchaPartido ?? '';
    equipoRivalController.text = partido.equipoRival;
    formacionController.text = partido.formacion;
    categoriaPartidoSeleccionada = cronograma.idCategorias;

    // Cargar competencias primero
    await loadCompetenciasByCategoria(cronograma.idCategorias);
    
    // Asignar la competencia después de cargar
    competenciaPartidoSeleccionada = cronograma.idCompetencias;
  }

  // ============================================================
  // FUNCIONES DE UTILIDAD
  // ============================================================

  void limpiarFormularioEntrenamiento() {
    fechaEntrenamientoController.clear();
    ubicacionEntrenamientoController.clear();
    descripcionEntrenamientoController.clear();
    sedeEntrenamientoSeleccionada = null;
    categoriaEntrenamientoSeleccionada = null;
  }

  void limpiarFormularioPartido() {
    fechaPartidoController.clear();
    ubicacionPartidoController.clear();
    canchaPartidoController.clear();
    equipoRivalController.clear();
    formacionController.clear();
    categoriaPartidoSeleccionada = null;
    competenciaPartidoSeleccionada = null;
    competenciasFiltradas = [];
  }

  void cancelarEdicion() {
    limpiarFormularioEntrenamiento();
    limpiarFormularioPartido();
    editingId = null;
    editingType = null;
  }

  // ============================================================
  // FILTRADO Y PAGINACIÓN
  // ============================================================

  List<Cronograma> get filteredEntrenamientos {
    if (searchTermEntrenamiento.isEmpty) return entrenamientos;

    return entrenamientos.where((e) {
      final categoria = categoriasAPI.firstWhere(
        (c) => c.idCategorias == e.idCategorias,
        orElse: () => Categoria(idCategorias: 0, descripcion: ''),
      );

      final searchLower = searchTermEntrenamiento.toLowerCase();
      return e.fechaDeEventos.toLowerCase().contains(searchLower) ||
          e.ubicacion.toLowerCase().contains(searchLower) ||
          (e.sedeEntrenamiento?.toLowerCase().contains(searchLower) ?? false) ||
          (e.descripcion?.toLowerCase().contains(searchLower) ?? false) ||
          categoria.descripcion.toLowerCase().contains(searchLower);
    }).toList();
  }

  List<Partido> get filteredPartidos {
    if (searchTermPartido.isEmpty) return partidosAPI;

    return partidosAPI.where((p) {
      final cronograma = cronogramas.firstWhere(
        (c) => c.idCronogramas == p.idCronogramas,
        orElse: () => Cronograma(
          idCronogramas: 0,
          tipoDeEventos: '',
          fechaDeEventos: '',
          ubicacion: '',
          idCategorias: 0,
          idCompetencias: null,
        ),
      );

      final categoria = categoriasAPI.firstWhere(
        (c) => c.idCategorias == cronograma.idCategorias,
        orElse: () => Categoria(idCategorias: 0, descripcion: ''),
      );

      final competencia = competencias.firstWhere(
        (c) => c.idCompetencias == cronograma.idCompetencias,
        orElse: () => Competencia(
          idCompetencias: 0,
          nombre: '',
          tipoCompetencia: '',
          ano: 0,
          idEquipos: 0,
        ),
      );

      final searchLower = searchTermPartido.toLowerCase();
      return p.formacion.toLowerCase().contains(searchLower) ||
          p.equipoRival.toLowerCase().contains(searchLower) ||
          cronograma.fechaDeEventos.toLowerCase().contains(searchLower) ||
          cronograma.ubicacion.toLowerCase().contains(searchLower) ||
          categoria.descripcion.toLowerCase().contains(searchLower) ||
          competencia.nombre.toLowerCase().contains(searchLower);
    }).toList();
  }

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

  int get totalPagesEntrenamiento => (filteredEntrenamientos.length / itemsPerPage).ceil();
  int get totalPagesPartido => (filteredPartidos.length / itemsPerPage).ceil();

  // ============================================================
  // DISPOSE
  // ============================================================

  void dispose() {
    fechaEntrenamientoController.dispose();
    ubicacionEntrenamientoController.dispose();
    descripcionEntrenamientoController.dispose();
    fechaPartidoController.dispose();
    ubicacionPartidoController.dispose();
    canchaPartidoController.dispose();
    equipoRivalController.dispose();
    formacionController.dispose();
  }
}