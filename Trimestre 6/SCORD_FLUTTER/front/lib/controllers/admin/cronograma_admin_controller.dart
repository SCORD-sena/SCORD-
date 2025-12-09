import 'package:flutter/material.dart';
import '../../models/cronograma_model.dart';
import '../../models/partido_model.dart';
import '../../models/categoria_model.dart';
import '../../services/cronograma_service.dart';

class CronogramaAdminController {
  final CronogramaService _service = CronogramaService();

  // Datos
  List<Cronograma> cronogramas = [];
  List<Cronograma> entrenamientos = [];
  List<Cronograma> partidos = [];
  List<Partido> partidosAPI = [];
  List<Categoria> categorias = [];

  // Estados de carga
  bool isLoading = true;
  bool isLoadingCategorias = true;

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

  // ============================================================
  // CARGAR DATOS
  // ============================================================

  Future<void> loadData() async {
    isLoading = true;
    try {
      await Future.wait([
        loadCronogramas(),
        loadPartidos(),
        loadCategorias(),
      ]);
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  Future<void> loadCronogramas() async {
    final data = await _service.getCronogramas();
    cronogramas = data;
    entrenamientos = data.where((c) => c.tipoDeEventos == 'Entrenamiento').toList();
    partidos = data.where((c) => c.tipoDeEventos == 'Partido').toList();
  }

  Future<void> loadPartidos() async {
    final data = await _service.getPartidos();
    partidosAPI = data;
  }

  Future<void> loadCategorias() async {
    isLoadingCategorias = true;
    try {
      final data = await _service.getCategorias();
      categorias = data;
    } finally {
      isLoadingCategorias = false;
    }
  }

  // ============================================================
  // CRUD ENTRENAMIENTOS
  // ============================================================

  Future<void> agregarEntrenamiento() async {
    if (categoriaEntrenamientoSeleccionada == null) {
      throw Exception('Por favor seleccione una categoría');
    }

    final cronograma = Cronograma(
      idCronogramas: 0,
      tipoDeEventos: 'Entrenamiento',
      fechaDeEventos: fechaEntrenamientoController.text,
      ubicacion: ubicacionEntrenamientoController.text,
      sedeEntrenamiento: sedeEntrenamientoSeleccionada,
      descripcion: descripcionEntrenamientoController.text,
      idCategorias: categoriaEntrenamientoSeleccionada!,
    );

    await _service.createCronograma(cronograma);
    await loadCronogramas();
    limpiarFormularioEntrenamiento();
  }

  Future<void> actualizarEntrenamiento() async {
    if (editingId == null) return;

    final cronograma = Cronograma(
      idCronogramas: editingId!,
      tipoDeEventos: 'Entrenamiento',
      fechaDeEventos: fechaEntrenamientoController.text,
      ubicacion: ubicacionEntrenamientoController.text,
      sedeEntrenamiento: sedeEntrenamientoSeleccionada,
      descripcion: descripcionEntrenamientoController.text,
      idCategorias: categoriaEntrenamientoSeleccionada!,
    );

    await _service.updateCronograma(editingId!, cronograma);
    await loadCronogramas();
    cancelarEdicion();
  }

  Future<void> eliminarEntrenamiento(int id) async {
    await _service.deleteCronograma(id);
    await loadCronogramas();
  }

  void editarEntrenamiento(Cronograma cronograma) {
    editingId = cronograma.idCronogramas;
    editingType = 'Entrenamiento';
    fechaEntrenamientoController.text = cronograma.fechaDeEventos;
    ubicacionEntrenamientoController.text = cronograma.ubicacion;
    descripcionEntrenamientoController.text = cronograma.descripcion ?? '';
    sedeEntrenamientoSeleccionada = cronograma.sedeEntrenamiento;
    categoriaEntrenamientoSeleccionada = cronograma.idCategorias;
  }

  // ============================================================
  // CRUD PARTIDOS
  // ============================================================

  Future<void> agregarPartido() async {
    if (categoriaPartidoSeleccionada == null) {
      throw Exception('Por favor seleccione una categoría');
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

  void editarPartido(Partido partido) {
    final cronograma = cronogramas.firstWhere((c) => c.idCronogramas == partido.idCronogramas);

    editingId = partido.idPartidos;
    editingType = 'PartidoAPI';
    fechaPartidoController.text = cronograma.fechaDeEventos;
    ubicacionPartidoController.text = cronograma.ubicacion;
    canchaPartidoController.text = cronograma.canchaPartido ?? '';
    equipoRivalController.text = partido.equipoRival;
    formacionController.text = partido.formacion;
    categoriaPartidoSeleccionada = cronograma.idCategorias;
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
      final categoria = categorias.firstWhere(
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
        ),
      );

      final categoria = categorias.firstWhere(
        (c) => c.idCategorias == cronograma.idCategorias,
        orElse: () => Categoria(idCategorias: 0, descripcion: ''),
      );

      final searchLower = searchTermPartido.toLowerCase();
      return p.formacion.toLowerCase().contains(searchLower) ||
          p.equipoRival.toLowerCase().contains(searchLower) ||
          cronograma.fechaDeEventos.toLowerCase().contains(searchLower) ||
          cronograma.ubicacion.toLowerCase().contains(searchLower) ||
          categoria.descripcion.toLowerCase().contains(searchLower);
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