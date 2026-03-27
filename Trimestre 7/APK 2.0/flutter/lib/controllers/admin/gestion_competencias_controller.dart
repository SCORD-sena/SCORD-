import 'package:flutter/material.dart';
import 'dart:convert';
import '../../models/competencia_model.dart';
import '../../models/categoria_model.dart';
import '../../services/competencia_service.dart';
import '../../services/api_service.dart';

class GestionCompetenciasController extends ChangeNotifier {
  final CompetenciaService _competenciaService = CompetenciaService();
  final ApiService _apiService = ApiService();

  // Estado
  List<Competencia> competencias = [];
  List<Categoria> categorias = [];
  bool loading = false;
  String? error;

  // Formulario
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController tipoController = TextEditingController();
  final TextEditingController anoController = TextEditingController();
  
  String? categoriaSeleccionada; // ⭐ NUEVO

  bool modoEdicion = false;
  Competencia? competenciaEnEdicion;

  // ============================================================
  // INICIALIZACIÓN
  // ============================================================

  Future<void> inicializar() async {
    await Future.wait([
      cargarCompetencias(),
      cargarCategorias(),
    ]);
  }

  Future<void> cargarCompetencias() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      competencias = await _competenciaService.getCompetencias();
      
    } catch (e) {
      error = 'Error al cargar competencias: $e';
    
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ⭐ NUEVO: Cargar categorías
  Future<void> cargarCategorias() async {
    try {
      final response = await _apiService.get('/categorias');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        categorias = (data as List).map((i) => Categoria.fromJson(i)).toList();
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // CREAR COMPETENCIA
  // ============================================================

  void abrirDialogoCrear() {
    modoEdicion = false;
    competenciaEnEdicion = null;
    limpiarFormulario();
    notifyListeners();
  }

  Future<bool> crearCompetencia() async {
    final error = validarFormulario();
    if (error != null) {
      throw Exception(error);
    }

    loading = true;
    notifyListeners();

    try {
      final competenciaData = {
        'Nombre': nombreController.text.trim(),
        'TipoCompetencia': tipoController.text.trim(),
        'Ano': int.parse(anoController.text),
        'idCategorias': int.parse(categoriaSeleccionada!), // ⭐ Enviar categoría
      };


      // Usar el método que crea competencia + cronograma
      final exito = await _competenciaService.crearCompetenciaConCategoria(competenciaData);

      if (exito) {
        await cargarCompetencias();
        limpiarFormulario();
        return true;
      } else {
        throw Exception('Error al crear la competencia');
      }
    } catch (e) {
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // EDITAR COMPETENCIA
  // ============================================================

  void abrirDialogoEditar(Competencia competencia) {
    modoEdicion = true;
    competenciaEnEdicion = competencia;
    
    nombreController.text = competencia.nombre;
    tipoController.text = competencia.tipoCompetencia;
    anoController.text = competencia.ano.toString();
    
    notifyListeners();
  }

  Future<bool> actualizarCompetencia() async {
    if (competenciaEnEdicion == null) {
      throw Exception('No hay competencia en edición');
    }

    final error = validarFormulario();
    if (error != null) {
      throw Exception(error);
    }

    loading = true;
    notifyListeners();

    try {
      final competenciaData = {
        'Nombre': nombreController.text.trim(),
        'TipoCompetencia': tipoController.text.trim(),
        'Ano': int.parse(anoController.text),
      };

      

      final exito = await _competenciaService.actualizarCompetencia(
        competenciaEnEdicion!.idCompetencias,
        competenciaData,
      );

      if (exito) {
        await cargarCompetencias();
        limpiarFormulario();
        return true;
      } else {
        throw Exception('Error al actualizar la competencia');
      }
    } catch (e) {
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // ELIMINAR COMPETENCIA
  // ============================================================

  Future<bool> eliminarCompetencia(int idCompetencia) async {
    loading = true;
    notifyListeners();

    try {
      final exito = await _competenciaService.eliminarCompetencia(idCompetencia);

      if (exito) {
        await cargarCompetencias();
        return true;
      } else {
        throw Exception('Error al eliminar la competencia');
      }
    } catch (e) {
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ⭐ NUEVO: Seleccionar categoría
  void seleccionarCategoria(String? value) {
    categoriaSeleccionada = value;
    notifyListeners();
  }

  // ============================================================
  // VALIDACIÓN
  // ============================================================

  String? validarFormulario() {
    if (categoriaSeleccionada == null || categoriaSeleccionada!.isEmpty) {
      return 'Debes seleccionar una categoría';
    }

    if (nombreController.text.trim().isEmpty) {
      return 'El nombre es obligatorio';
    }

    if (nombreController.text.trim().length > 50) {
      return 'El nombre no puede tener más de 50 caracteres';
    }

    if (tipoController.text.trim().isEmpty) {
      return 'El tipo de competencia es obligatorio';
    }

    if (tipoController.text.trim().length > 30) {
      return 'El tipo no puede tener más de 30 caracteres';
    }

    if (anoController.text.trim().isEmpty) {
      return 'El año es obligatorio';
    }

    final ano = int.tryParse(anoController.text);
    if (ano == null) {
      return 'El año debe ser un número válido';
    }

    if (ano < 2000 || ano > 2100) {
      return 'El año debe estar entre 2000 y 2100';
    }

    return null;
  }

  // ============================================================
  // UTILIDADES
  // ============================================================

  void limpiarFormulario() {
    nombreController.clear();
    tipoController.clear();
    anoController.clear();
    categoriaSeleccionada = null; // ⭐ NUEVO
    modoEdicion = false;
    competenciaEnEdicion = null;
  }

  @override
  void dispose() {
    nombreController.dispose();
    tipoController.dispose();
    anoController.dispose();
    super.dispose();
  }
}