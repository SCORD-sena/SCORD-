import 'package:flutter/material.dart';
import '../../../models/jugador_model.dart';
import '../../../services/jugador_service.dart';

class HistorialJugadoresController extends ChangeNotifier {
  final JugadorService _jugadorService = JugadorService();

  // State
  List<Jugador> jugadoresEliminados = [];
  bool loading = false;
  String? errorMessage;

  // Inicializar
  Future<void> inicializar() async {
    await cargarJugadoresEliminados();
  }

  // Cargar jugadores eliminados
  Future<void> cargarJugadoresEliminados() async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      jugadoresEliminados = await _jugadorService.fetchJugadoresEliminados();
    } catch (e) {
      errorMessage = 'Error al cargar jugadores eliminados: ${e.toString()}';
      jugadoresEliminados = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // Restaurar jugador
  Future<bool> restaurarJugador(int idJugador) async {
    try {
      final exito = await _jugadorService.restaurarJugador(idJugador);
      
      if (exito) {
        // Remover de la lista local
        jugadoresEliminados.removeWhere((j) => j.idJugadores == idJugador);
        notifyListeners();
      }
      
      return exito;
    } catch (e) {
      rethrow;
    }
  }

  // Eliminar permanentemente
  Future<bool> eliminarPermanentemente(int idJugador) async {
    try {
      final exito = await _jugadorService.eliminarPermanentemente(idJugador);
      
      if (exito) {
        // Remover de la lista local
        jugadoresEliminados.removeWhere((j) => j.idJugadores == idJugador);
        notifyListeners();
      }
      
      return exito;
    } catch (e) {
      rethrow;
    }
  }

  // Buscar jugador por nombre, documento o dorsal
  List<Jugador> buscarJugadores(String query) {
    if (query.isEmpty) return jugadoresEliminados;

    final queryLower = query.toLowerCase();
    
    return jugadoresEliminados.where((jugador) {
      final nombreCompleto = jugador.persona.nombreCompleto.toLowerCase();
      final documento = jugador.persona.numeroDeDocumento.toLowerCase();
      final dorsal = jugador.dorsal.toString();
      final posicion = jugador.posicion.toLowerCase();
      
      return nombreCompleto.contains(queryLower) || 
             documento.contains(queryLower) ||
             dorsal.contains(queryLower) ||
             posicion.contains(queryLower);
    }).toList();
  }
}