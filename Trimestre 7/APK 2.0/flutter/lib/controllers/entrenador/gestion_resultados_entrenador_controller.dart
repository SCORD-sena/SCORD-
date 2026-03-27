import 'package:flutter/material.dart';
import '../../models/categoria_model.dart';
import '../../models/competencia_model.dart';
import '../../models/partido_model.dart';
import '../../models/resultado_model.dart';
import '../../services/resultado_service.dart';
import '../../services/auth_service.dart';
import '../../services/entrenador_service.dart';
import '../../services/competencia_service.dart';
import '../../services/cronograma_service.dart';

class GestionResultadosEntrenadorController extends ChangeNotifier {
  final ResultadoService _resultadoService = ResultadoService();
  final AuthService _authService = AuthService();
  final EntrenadorService _entrenadorService = EntrenadorService();
  final CompetenciaService _competenciaService = CompetenciaService();
  final CronogramaService _cronogramaService = CronogramaService();

  // Estado
  List<Categoria> categorias = [];
  List<Categoria> categoriasEntrenador = []; // ⭐ Solo categorías del entrenador
  List<Competencia> competencias = [];
  List<Competencia> competenciasFiltradas = [];
  List<Partido> partidos = [];
  List<Partido> partidosFiltrados = [];
  List<Resultado> resultados = [];
  List<Resultado> resultadosFiltrados = [];

  String? categoriaSeleccionada;
  int? competenciaSeleccionada;
  int? partidoSeleccionado;

  bool loading = false;
  bool isLoadingCompetencias = false;
  bool isLoadingPartidos = false;
  bool isLoadingResultados = false;
  String? error;

  // Formulario
  final TextEditingController marcadorController = TextEditingController();
  final TextEditingController puntosController = TextEditingController();
  final TextEditingController observacionController = TextEditingController();

  bool modoEdicion = false;
  Resultado? resultadoEnEdicion;

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
      // Obtener datos del entrenador logueado
      final persona = await _authService.obtenerUsuario();
      
      if (persona == null) {
        throw Exception('No se pudo obtener el usuario logueado');
      }

      // Obtener el entrenador con sus categorías
      final entrenador = await _entrenadorService.getEntrenadorByPersonaId(persona.idPersonas);
      
      if (entrenador == null || entrenador.categorias == null || entrenador.categorias!.isEmpty) {
        throw Exception('El entrenador no tiene categorías asignadas');
      }

      // ⭐ Guardar solo las categorías del entrenador
      categoriasEntrenador = entrenador.categorias!;
      categorias = categoriasEntrenador; // Para los dropdowns
      
      await Future.wait([
        fetchCompetencias(),
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

  Future<void> fetchCompetencias() async {
    try {
      competencias = await _competenciaService.getCompetencias();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

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
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // FILTRADO
  // ============================================================

  Future<void> filtrarCompetenciasPorCategoria(int idCategoria) async {
    isLoadingCompetencias = true;
    notifyListeners();
    
    try {
      final data = await _competenciaService.getCompetenciasByCategoria(idCategoria);
      competenciasFiltradas = data; 
      competenciaSeleccionada = null;
      partidoSeleccionado = null;
      partidosFiltrados = [];
      resultadosFiltrados = [];
    } catch (e) {
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

  Future<void> seleccionarCategoria(String? categoriaId) async {
    categoriaSeleccionada = categoriaId;
    
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
      resultadosFiltrados = [];
      notifyListeners();
    }
  }

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

  // ============================================================
  // CREAR RESULTADO
  // ============================================================

  void abrirDialogoCrear() {
    modoEdicion = false;
    resultadoEnEdicion = null;
    limpiarFormulario();
    notifyListeners();
  }

  Future<bool> crearResultado() async {
    final error = validarFormulario();
    if (error != null) {
      throw Exception(error);
    }

    loading = true;
    notifyListeners();

    try {
      final resultadoData = {
        'Marcador': marcadorController.text.trim(),
        'PuntosObtenidos': int.parse(puntosController.text),
        'Observacion': observacionController.text.trim().isEmpty 
            ? null 
            : observacionController.text.trim(),
        'idPartidos': partidoSeleccionado!,
      };

      final exito = await _resultadoService.crearResultado(resultadoData);

      if (exito) {
        await fetchResultados();
        if (partidoSeleccionado != null) {
          await filtrarResultadosPorPartido(partidoSeleccionado!);
        }
        limpiarFormulario();
        return true;
      } else {
        throw Exception('Error al crear el resultado');
      }
    } catch (e) {
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // EDITAR RESULTADO
  // ============================================================

  void abrirDialogoEditar(Resultado resultado) {
    modoEdicion = true;
    resultadoEnEdicion = resultado;
    
    marcadorController.text = resultado.marcador;
    puntosController.text = resultado.puntosObtenidos.toString();
    observacionController.text = resultado.observacion ?? '';
    
    notifyListeners();
  }

  Future<bool> actualizarResultado() async {
    if (resultadoEnEdicion == null) {
      throw Exception('No hay resultado en edición');
    }

    final error = validarFormulario();
    if (error != null) {
      throw Exception(error);
    }

    loading = true;
    notifyListeners();

    try {
      final resultadoData = {
        'Marcador': marcadorController.text.trim(),
        'PuntosObtenidos': int.parse(puntosController.text),
        'Observacion': observacionController.text.trim().isEmpty 
            ? null 
            : observacionController.text.trim(),
        'idPartidos': resultadoEnEdicion!.idPartidos,
      };

      final exito = await _resultadoService.actualizarResultado(
        resultadoEnEdicion!.idResultados,
        resultadoData,
      );

      if (exito) {
        await fetchResultados();
        if (partidoSeleccionado != null) {
          await filtrarResultadosPorPartido(partidoSeleccionado!);
        }
        limpiarFormulario();
        return true;
      } else {
        throw Exception('Error al actualizar el resultado');
      }
    } catch (e) {
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // ELIMINAR RESULTADO
  // ============================================================

  Future<bool> eliminarResultado(int idResultado) async {
    loading = true;
    notifyListeners();

    try {
      final exito = await _resultadoService.eliminarResultado(idResultado);

      if (exito) {
        await fetchResultados();
        if (partidoSeleccionado != null) {
          await filtrarResultadosPorPartido(partidoSeleccionado!);
        }
        return true;
      } else {
        throw Exception('Error al eliminar el resultado');
      }
    } catch (e) {
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // VALIDACIÓN
  // ============================================================

  String? validarFormulario() {
    if (partidoSeleccionado == null) {
      return 'Debes seleccionar un partido';
    }

    if (marcadorController.text.trim().isEmpty) {
      return 'El marcador es obligatorio';
    }

    if (marcadorController.text.trim().length > 10) {
      return 'El marcador no puede tener más de 10 caracteres';
    }

    if (puntosController.text.trim().isEmpty) {
      return 'Los puntos obtenidos son obligatorios';
    }

    final puntos = int.tryParse(puntosController.text);
    if (puntos == null) {
      return 'Los puntos deben ser un número válido';
    }

    if (observacionController.text.trim().length > 100) {
      return 'La observación no puede tener más de 100 caracteres';
    }

    return null;
  }

  // ============================================================
  // UTILIDADES
  // ============================================================

  void limpiarFormulario() {
    marcadorController.clear();
    puntosController.clear();
    observacionController.clear();
    modoEdicion = false;
    resultadoEnEdicion = null;
  }

  @override
  void dispose() {
    marcadorController.dispose();
    puntosController.dispose();
    observacionController.dispose();
    super.dispose();
  }
}