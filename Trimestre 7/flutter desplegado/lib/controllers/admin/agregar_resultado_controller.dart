import 'package:flutter/material.dart';
import 'dart:convert';
import '../../models/categoria_model.dart';
import '../../models/competencia_model.dart';
import '../../models/partido_model.dart';
import '../../services/resultado_service.dart';
import '../../services/api_service.dart';
import '../../services/competencia_service.dart';
import '../../services/cronograma_service.dart';

class AgregarResultadoController extends ChangeNotifier {
  final ResultadoService _resultadoService = ResultadoService();
  final ApiService _apiService = ApiService();
  final CompetenciaService _competenciaService = CompetenciaService();
  final CronogramaService _cronogramaService = CronogramaService();

  // Estado
  bool loading = false;
  bool isLoadingCompetencias = false;
  bool isLoadingPartidos = false;
  
  List<Categoria> categorias = [];
  List<Competencia> competencias = [];
  List<Competencia> competenciasFiltradas = [];
  List<Partido> partidos = [];
  List<Partido> partidosFiltrados = [];
  
  String? categoriaSeleccionada;
  int? competenciaSeleccionada;
  int? partidoSeleccionado;

  // Controllers de texto
  final TextEditingController marcadorController = TextEditingController();
  final TextEditingController puntosController = TextEditingController();
  final TextEditingController observacionController = TextEditingController();

  // ============================================================
  // INICIALIZACIÓN
  // ============================================================

  Future<void> inicializar() async {
    await cargarDatos();
  }

  Future<void> cargarDatos() async {
    try {
      final categoriasRes = await _apiService.get('/categorias');

      if (categoriasRes.statusCode == 200) {
        final categoriasData = json.decode(categoriasRes.body);
        categorias = (categoriasData as List).map((c) => Categoria.fromJson(c)).toList();
        
        competencias = await _competenciaService.getCompetencias();
        partidos = await _cronogramaService.getPartidos();
        
        notifyListeners();
      }
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
    } catch (e) {
      partidosFiltrados = [];
    } finally {
      isLoadingPartidos = false;
      notifyListeners();
    }
  }

  // ============================================================
  // SELECCIÓN
  // ============================================================

  Future<void> seleccionarCategoria(String? value) async {
    categoriaSeleccionada = value;
    
    if (value != null) {
      final id = int.tryParse(value);
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

  Future<void> seleccionarCompetencia(int? value) async {
    competenciaSeleccionada = value;
    
    if (value != null) {
      await filtrarPartidosPorCompetencia(value);
    } else {
      partidosFiltrados = [];
      partidoSeleccionado = null;
      notifyListeners();
    }
  }

  void seleccionarPartido(int? value) {
    partidoSeleccionado = value;
    notifyListeners();
  }

  // ============================================================
  // VALIDACIÓN
  // ============================================================

  String? validarFormulario() {
    if (categoriaSeleccionada == null || categoriaSeleccionada!.isEmpty) {
      return 'Debes seleccionar una categoría';
    }

    if (competenciaSeleccionada == null) {
      return 'Debes seleccionar una competencia';
    }

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
  // CREAR RESULTADO
  // ============================================================

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

      if (!exito) {
        throw Exception('Error al guardar el resultado');
      }

      return true;
    } catch (e) {
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    marcadorController.dispose();
    puntosController.dispose();
    observacionController.dispose();
    super.dispose();
  }
}