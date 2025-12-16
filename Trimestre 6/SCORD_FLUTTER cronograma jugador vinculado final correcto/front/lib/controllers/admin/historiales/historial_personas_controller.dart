import 'package:flutter/material.dart';
import '../../../models/persona_model.dart';
import '../../../services/persona_service.dart';

class HistorialPersonasController extends ChangeNotifier {
  final PersonaService _personaService = PersonaService();

  // State
  List<Persona> personasEliminadas = [];
  bool loading = false;
  String? errorMessage;

  // Inicializar
  Future<void> inicializar() async {
    await cargarPersonasEliminadas();
  }

  // Cargar personas eliminadas
  Future<void> cargarPersonasEliminadas() async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      personasEliminadas = await _personaService.fetchPersonasEliminadas();
    } catch (e) {
      errorMessage = 'Error al cargar personas eliminadas: ${e.toString()}';
      personasEliminadas = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // Restaurar persona
  Future<bool> restaurarPersona(int idPersona) async {
    try {
      final exito = await _personaService.restaurarPersona(idPersona);
      
      if (exito) {
        // Remover de la lista local
        personasEliminadas.removeWhere((p) => p.idPersonas == idPersona);
        notifyListeners();
      }
      
      return exito;
    } catch (e) {
      rethrow;
    }
  }

  // Eliminar permanentemente
  Future<bool> eliminarPermanentemente(int idPersona) async {
    try {
      final exito = await _personaService.eliminarPermanentemente(idPersona);
      
      if (exito) {
        // Remover de la lista local
        personasEliminadas.removeWhere((p) => p.idPersonas == idPersona);
        notifyListeners();
      }
      
      return exito;
    } catch (e) {
      rethrow;
    }
  }

  // Buscar persona por nombre o documento
  List<Persona> buscarPersonas(String query) {
    if (query.isEmpty) return personasEliminadas;

    final queryLower = query.toLowerCase();
    
    return personasEliminadas.where((persona) {
      final nombreCompleto = persona.nombreCompleto.toLowerCase();
      final documento = persona.numeroDeDocumento.toLowerCase();
      
      return nombreCompleto.contains(queryLower) || 
             documento.contains(queryLower);
    }).toList();
  }
}