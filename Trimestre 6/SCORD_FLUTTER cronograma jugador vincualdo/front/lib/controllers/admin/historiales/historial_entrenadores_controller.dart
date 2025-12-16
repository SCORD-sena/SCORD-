import 'package:flutter/material.dart';
import '../../../models/entrenador_model.dart';
import '../../../services/entrenador_service.dart';

class HistorialEntrenadoresController extends ChangeNotifier {
  final EntrenadorService _entrenadorService = EntrenadorService();

  // State
  List<Entrenador> entrenadoresEliminados = [];
  bool loading = false;
  String? errorMessage;

  // Inicializar
  Future<void> inicializar() async {
    await cargarEntrenadoresEliminados();
  }

  // Cargar entrenadores eliminados
  Future<void> cargarEntrenadoresEliminados() async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      entrenadoresEliminados = await _entrenadorService.fetchEntrenadoresEliminados();
      print('✅ ${entrenadoresEliminados.length} entrenadores eliminados cargados');
    } catch (e) {
      errorMessage = 'Error al cargar entrenadores eliminados: ${e.toString()}';
      print('❌ $errorMessage');
      entrenadoresEliminados = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // Restaurar entrenador
  Future<bool> restaurarEntrenador(int idEntrenador) async {
    try {
      final exito = await _entrenadorService.restaurarEntrenador(idEntrenador);
      
      if (exito) {
        // Remover de la lista local
        entrenadoresEliminados.removeWhere((e) => e.idEntrenadores == idEntrenador);
        notifyListeners();
      }
      
      return exito;
    } catch (e) {
      print('❌ Error al restaurar entrenador: $e');
      rethrow;
    }
  }

  // Eliminar permanentemente
  Future<bool> eliminarPermanentemente(int idEntrenador) async {
    try {
      final exito = await _entrenadorService.eliminarPermanentemente(idEntrenador);
      
      if (exito) {
        // Remover de la lista local
        entrenadoresEliminados.removeWhere((e) => e.idEntrenadores == idEntrenador);
        notifyListeners();
      }
      
      return exito;
    } catch (e) {
      print('❌ Error al eliminar permanentemente: $e');
      rethrow;
    }
  }

  // Buscar entrenador por nombre, documento o cargo
  // Buscar entrenador por nombre, documento o cargo
  List<Entrenador> buscarEntrenadores(String query) {
    if (query.isEmpty) return entrenadoresEliminados;

    final queryLower = query.toLowerCase();
    
    return entrenadoresEliminados.where((entrenador) {
      final nombreCompleto = entrenador.persona?.nombreCompleto.toLowerCase() ?? '';
      final documento = entrenador.persona?.numeroDeDocumento.toLowerCase() ?? '';
      final cargo = entrenador.cargo.toLowerCase();
      
      return nombreCompleto.contains(queryLower) || 
             documento.contains(queryLower) ||
             cargo.contains(queryLower);
    }).toList();
  }
}