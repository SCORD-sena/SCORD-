import 'package:flutter/material.dart';
import '../../../models/partido_model.dart';
import '../../../services/partido_service.dart';

class HistorialPartidosController extends ChangeNotifier {
  final PartidoService _partidoService = PartidoService();

  // State
  List<Partido> partidosEliminados = [];
  bool loading = false;
  String? errorMessage;

  // Inicializar
  Future<void> inicializar() async {
    await cargarPartidosEliminados();
  }

  // Cargar partidos eliminados
  Future<void> cargarPartidosEliminados() async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      partidosEliminados = await _partidoService.fetchPartidosEliminados();
    } catch (e) {
      errorMessage = 'Error al cargar partidos eliminados: ${e.toString()}';
      partidosEliminados = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // Restaurar partido
  Future<bool> restaurarPartido(int idPartido) async {
    try {
      final exito = await _partidoService.restaurarPartido(idPartido);
      
      if (exito) {
        // Remover de la lista local
        partidosEliminados.removeWhere((p) => p.idPartidos == idPartido);
        notifyListeners();
      }
      
      return exito;
    } catch (e) {
      rethrow;
    }
  }

  // Eliminar permanentemente
  Future<bool> eliminarPermanentemente(int idPartido) async {
    try {
      final exito = await _partidoService.eliminarPermanentemente(idPartido);
      
      if (exito) {
        // Remover de la lista local
        partidosEliminados.removeWhere((p) => p.idPartidos == idPartido);
        notifyListeners();
      }
      
      return exito;
    } catch (e) {
      rethrow;
    }
  }

  // Buscar partido por rival o formación
  List<Partido> buscarPartidos(String query) {
    if (query.isEmpty) return partidosEliminados;

    final queryLower = query.toLowerCase();
    
    return partidosEliminados.where((partido) {
      final equipoRival = partido.equipoRival.toLowerCase();
      final formacion = partido.formacion.toLowerCase();
      
      return equipoRival.contains(queryLower) || 
             formacion.contains(queryLower);
    }).toList();
  }
}