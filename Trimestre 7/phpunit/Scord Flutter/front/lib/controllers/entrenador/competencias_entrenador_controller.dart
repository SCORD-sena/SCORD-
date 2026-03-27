import 'package:flutter/material.dart';
import '../../../models/competencia_model.dart';
import '../../../models/categoria_model.dart';
import '../../../services/competencia_service.dart';
import '../../../services/entrenador_service.dart';
import '../../../services/auth_service.dart';

class CompetenciasEntrenadorController extends ChangeNotifier {
  final CompetenciaService _competenciaService = CompetenciaService();
  final EntrenadorService _entrenadorService = EntrenadorService();
  final AuthService _authService = AuthService();

  // State
  List<Categoria> categoriasEntrenador = [];
  List<Competencia> competencias = [];
  String? categoriaSeleccionada;
  bool loading = false;
  String? errorMessage;

  // Formulario
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController tipoController = TextEditingController();
  final TextEditingController anoController = TextEditingController();
  bool modoEdicion = false;
  int? idCompetenciaEditando;

  // ============================================================
  // INICIALIZACIÓN
  // ============================================================

  Future<void> inicializar() async {
    await cargarCategoriasEntrenador();
  }

  // ============================================================
  // CARGAR CATEGORÍAS DEL ENTRENADOR
  // ============================================================

  Future<void> cargarCategoriasEntrenador() async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final persona = await _authService.obtenerUsuario();
      if (persona == null) {
        throw Exception('Usuario no autenticado');
      }

      final entrenador = await _entrenadorService.getEntrenadorByPersonaId(persona.idPersonas);
      
      if (entrenador?.categorias == null || entrenador!.categorias!.isEmpty) {
        errorMessage = 'No tienes categorías asignadas';
        categoriasEntrenador = [];
      } else {
        categoriasEntrenador = entrenador.categorias!;
        
        // Seleccionar primera categoría automáticamente
        if (categoriasEntrenador.isNotEmpty) {
          categoriaSeleccionada = categoriasEntrenador.first.idCategorias.toString();
          await cargarCompetencias();
        }
      }
    } catch (e) {
      errorMessage = 'Error al cargar categorías: ${e.toString()}';
      categoriasEntrenador = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // CARGAR COMPETENCIAS POR CATEGORÍA
  // ============================================================

  Future<void> cargarCompetencias() async {
    if (categoriaSeleccionada == null) {
      competencias = [];
      notifyListeners();
      return;
    }

    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final idCategoria = int.parse(categoriaSeleccionada!);
      competencias = await _competenciaService.getCompetenciasByCategoria(idCategoria);
    } catch (e) {
      errorMessage = 'Error al cargar competencias: ${e.toString()}';
      competencias = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // SELECCIONAR CATEGORÍA
  // ============================================================

  void seleccionarCategoria(String? idCategoria) {
    categoriaSeleccionada = idCategoria;
    cargarCompetencias();
  }

  // ============================================================
  // CREAR COMPETENCIA
  // ============================================================

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
        'idCategorias': int.parse(categoriaSeleccionada!),
      };

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

  void prepararEdicion(Competencia competencia) {
    modoEdicion = true;
    idCompetenciaEditando = competencia.idCompetencias;
    nombreController.text = competencia.nombre;
    tipoController.text = competencia.tipoCompetencia;
    anoController.text = competencia.ano.toString();
    notifyListeners();
  }

  Future<bool> actualizarCompetencia() async {
    final error = validarFormulario();
    if (error != null) {
      throw Exception(error);
    }

    if (idCompetenciaEditando == null) {
      throw Exception('No hay competencia seleccionada para editar');
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
        idCompetenciaEditando!,
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
  // LIMPIAR FORMULARIO
  // ============================================================

  void limpiarFormulario() {
    modoEdicion = false;
    idCompetenciaEditando = null;
    nombreController.clear();
    tipoController.clear();
    anoController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    nombreController.dispose();
    tipoController.dispose();
    anoController.dispose();
    super.dispose();
  }
}