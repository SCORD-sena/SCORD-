import 'package:flutter/material.dart';
import '../../models/categoria_model.dart';
import '../../services/categoria_service.dart';

class GestionCategoriasController extends ChangeNotifier {
  final CategoriaService _categoriaService = CategoriaService();

  // Estado
  List<Categoria> categorias = [];
  bool loading = false;
  String? error;

  // Formulario
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController tiposCategoriaController = TextEditingController();

  bool modoEdicion = false;
  Categoria? categoriaEnEdicion;

  // ============================================================
  // INICIALIZACIÓN
  // ============================================================

  Future<void> inicializar() async {
    await cargarCategorias();
  }

  Future<void> cargarCategorias() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      categorias = await _categoriaService.getCategorias();
      print('✅ Categorías cargadas: ${categorias.length}');
    } catch (e) {
      error = 'Error al cargar categorías: $e';
      print('❌ $error');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // CREAR CATEGORÍA
  // ============================================================

  void abrirDialogoCrear() {
    modoEdicion = false;
    categoriaEnEdicion = null;
    limpiarFormulario();
    notifyListeners();
  }

  Future<bool> crearCategoria() async {
    final error = validarFormulario();
    if (error != null) {
      throw Exception(error);
    }

    loading = true;
    notifyListeners();

    try {
      final categoriaData = {
        'Descripcion': descripcionController.text.trim(),
        'TiposCategoria': tiposCategoriaController.text.trim(),
      };

      final exito = await _categoriaService.crearCategoria(categoriaData);

      if (exito) {
        await cargarCategorias();
        limpiarFormulario();
        return true;
      } else {
        throw Exception('Error al crear la categoría');
      }
    } catch (e) {
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // EDITAR CATEGORÍA
  // ============================================================

  void abrirDialogoEditar(Categoria categoria) {
    modoEdicion = true;
    categoriaEnEdicion = categoria;
    
    descripcionController.text = categoria.descripcion;
    tiposCategoriaController.text = categoria.tiposCategoria;
    
    notifyListeners();
  }

  Future<bool> actualizarCategoria() async {
    if (categoriaEnEdicion == null) {
      throw Exception('No hay categoría en edición');
    }

    final error = validarFormulario();
    if (error != null) {
      throw Exception(error);
    }

    loading = true;
    notifyListeners();

    try {
      final categoriaData = {
        'Descripcion': descripcionController.text.trim(),
        'TiposCategoria': tiposCategoriaController.text.trim(),
      };

      final exito = await _categoriaService.actualizarCategoria(
        categoriaEnEdicion!.idCategorias,
        categoriaData,
      );

      if (exito) {
        await cargarCategorias();
        limpiarFormulario();
        return true;
      } else {
        throw Exception('Error al actualizar la categoría');
      }
    } catch (e) {
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // ELIMINAR CATEGORÍA
  // ============================================================

  Future<bool> eliminarCategoria(int idCategoria) async {
    loading = true;
    notifyListeners();

    try {
      final exito = await _categoriaService.eliminarCategoria(idCategoria);

      if (exito) {
        await cargarCategorias();
        return true;
      } else {
        throw Exception('Error al eliminar la categoría');
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
    if (descripcionController.text.trim().isEmpty) {
      return 'La descripción es obligatoria';
    }

    if (tiposCategoriaController.text.trim().isEmpty) {
      return 'El tipo de categoría es obligatorio';
    }

    return null; // Sin errores
  }

  // ============================================================
  // UTILIDADES
  // ============================================================

  void limpiarFormulario() {
    descripcionController.clear();
    tiposCategoriaController.clear();
    modoEdicion = false;
    categoriaEnEdicion = null;
  }

  @override
  void dispose() {
    descripcionController.dispose();
    tiposCategoriaController.dispose();
    super.dispose();
  }
}