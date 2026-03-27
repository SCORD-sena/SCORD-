import 'package:flutter/material.dart';
import '../../../models/cronograma_model.dart';
import '../../../services/cronograma_service.dart';

class HistorialEntrenamientosController extends ChangeNotifier {
  final CronogramaService _cronogramaService = CronogramaService();

  // State
  List<Cronograma> entrenamientosEliminados = [];
  bool loading = false;
  String? errorMessage;

  // Inicializar
  Future<void> inicializar() async {
    await cargarEntrenamientosEliminados();
  }

  // Cargar entrenamientos eliminados
  Future<void> cargarEntrenamientosEliminados() async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final cronogramasEliminados = await _cronogramaService.fetchCronogramasEliminados();
      
      // Filtrar solo entrenamientos
      entrenamientosEliminados = cronogramasEliminados
          .where((c) => c.tipoDeEventos.toLowerCase() == 'entrenamiento')
          .toList();
    } catch (e) {
      errorMessage = 'Error al cargar entrenamientos eliminados: ${e.toString()}';
      entrenamientosEliminados = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // Restaurar entrenamiento
  Future<bool> restaurarEntrenamiento(int idCronograma) async {
    try {
      final exito = await _cronogramaService.restaurarCronograma(idCronograma);
      
      if (exito) {
        // Remover de la lista local
        entrenamientosEliminados.removeWhere((c) => c.idCronogramas == idCronograma);
        notifyListeners();
      }
      
      return exito;
    } catch (e) {
      rethrow;
    }
  }

  // Eliminar permanentemente
  Future<bool> eliminarPermanentemente(int idCronograma) async {
    try {
      final exito = await _cronogramaService.eliminarPermanentemente(idCronograma);
      
      if (exito) {
        // Remover de la lista local
        entrenamientosEliminados.removeWhere((c) => c.idCronogramas == idCronograma);
        notifyListeners();
      }
      
      return exito;
    } catch (e) {
      rethrow;
    }
  }

  // Buscar entrenamiento por fecha, ubicación o sede
  List<Cronograma> buscarEntrenamientos(String query) {
    if (query.isEmpty) return entrenamientosEliminados;

    final queryLower = query.toLowerCase();
    
    return entrenamientosEliminados.where((entrenamiento) {
      final fecha = entrenamiento.fechaDeEventos.toLowerCase();
      final ubicacion = entrenamiento.ubicacion.toLowerCase();
      final descripcion = (entrenamiento.descripcion ?? '').toLowerCase();
      final sede = (entrenamiento.sedeEntrenamiento ?? '').toLowerCase();
      
      return fecha.contains(queryLower) ||
             ubicacion.contains(queryLower) ||
             descripcion.contains(queryLower) ||
             sede.contains(queryLower);
    }).toList();
  }
}