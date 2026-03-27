import 'package:flutter/material.dart';
import '../../../models/competencia_model.dart';
import '../../../services/competencia_service.dart';

class HistorialCompetenciasController extends ChangeNotifier {
  final CompetenciaService _competenciaService = CompetenciaService();

  // State
  List<Competencia> competenciasEliminadas = [];
  bool loading = false;
  String? errorMessage;

  // Inicializar
  Future<void> inicializar() async {
    await cargarCompetenciasEliminadas();
  }

  // Cargar competencias eliminadas
  Future<void> cargarCompetenciasEliminadas() async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      competenciasEliminadas = await _competenciaService.fetchCompetenciasEliminadas();
    } catch (e) {
      errorMessage = 'Error al cargar competencias eliminadas: ${e.toString()}';
      competenciasEliminadas = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // Restaurar competencia
  Future<bool> restaurarCompetencia(int idCompetencia) async {
    try {
      final exito = await _competenciaService.restaurarCompetencia(idCompetencia);
      
      if (exito) {
        // Remover de la lista local
        competenciasEliminadas.removeWhere((c) => c.idCompetencias == idCompetencia);
        notifyListeners();
      }
      
      return exito;
    } catch (e) {
      rethrow;
    }
  }

  // Eliminar permanentemente
  Future<bool> eliminarPermanentemente(int idCompetencia) async {
    try {
      final exito = await _competenciaService.eliminarPermanentemente(idCompetencia);
      
      if (exito) {
        // Remover de la lista local
        competenciasEliminadas.removeWhere((c) => c.idCompetencias == idCompetencia);
        notifyListeners();
      }
      
      return exito;
    } catch (e) {
      rethrow;
    }
  }

  // Buscar competencia por nombre, tipo o año
  List<Competencia> buscarCompetencias(String query) {
    if (query.isEmpty) return competenciasEliminadas;

    final queryLower = query.toLowerCase();
    
    return competenciasEliminadas.where((competencia) {
      final nombre = competencia.nombre.toLowerCase();
      final tipo = competencia.tipoCompetencia.toLowerCase();
      final ano = competencia.ano.toString();
      
      return nombre.contains(queryLower) || 
             tipo.contains(queryLower) ||
             ano.contains(queryLower);
    }).toList();
  }
}