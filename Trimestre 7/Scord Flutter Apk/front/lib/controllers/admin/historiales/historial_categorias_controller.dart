import 'package:flutter/material.dart';
import '../../../models/categoria_model.dart';
import '../../../services/categoria_service.dart';

class HistorialCategoriasController extends ChangeNotifier {
  final CategoriaService _categoriaService = CategoriaService();

  // State
  List<Categoria> categoriasEliminadas = [];
  bool loading = false;
  String? errorMessage;

  // Inicializar
  Future<void> inicializar() async {
    await cargarCategoriasEliminadas();
  }

  // Cargar categorías eliminadas
  Future<void> cargarCategoriasEliminadas() async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      categoriasEliminadas = await _categoriaService.fetchCategoriasEliminadas();
    } catch (e) {
      errorMessage = 'Error al cargar categorías eliminadas: ${e.toString()}';
      categoriasEliminadas = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // Restaurar categoría
  Future<bool> restaurarCategoria(int idCategoria) async {
    try {
      final exito = await _categoriaService.restaurarCategoria(idCategoria);
      
      if (exito) {
        // Remover de la lista local
        categoriasEliminadas.removeWhere((c) => c.idCategorias == idCategoria);
        notifyListeners();
      }
      
      return exito;
    } catch (e) {
      rethrow;
    }
  }

  // Eliminar permanentemente
  Future<bool> eliminarPermanentemente(int idCategoria) async {
    try {
      final exito = await _categoriaService.eliminarPermanentemente(idCategoria);
      
      if (exito) {
        // Remover de la lista local
        categoriasEliminadas.removeWhere((c) => c.idCategorias == idCategoria);
        notifyListeners();
      }
      
      return exito;
    } catch (e) {
      rethrow;
    }
  }

  // Buscar categoría por descripción o tipo
  List<Categoria> buscarCategorias(String query) {
    if (query.isEmpty) return categoriasEliminadas;

    final queryLower = query.toLowerCase();
    
    return categoriasEliminadas.where((categoria) {
      final descripcion = categoria.descripcion.toLowerCase();
      final tipoCategoria = categoria.tiposCategoria.toLowerCase();
      
      return descripcion.contains(queryLower) || 
             tipoCategoria.contains(queryLower);
    }).toList();
  }
}