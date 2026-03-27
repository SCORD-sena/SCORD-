import 'package:flutter/material.dart';
import '../../../models/competencia_model.dart';
import '../../../models/categoria_model.dart';
import '../../../services/competencia_service.dart';
import '../../../services/jugador_service.dart';
import '../../../services/auth_service.dart';

class CompetenciasJugadorController extends ChangeNotifier {
  final CompetenciaService _competenciaService = CompetenciaService();
  final JugadorService _jugadorService = JugadorService();
  final AuthService _authService = AuthService();

  // State
  Categoria? categoriaJugador;
  List<Competencia> competencias = [];
  bool loading = false;
  String? errorMessage;

  // ============================================================
  // INICIALIZACIÓN
  // ============================================================

  Future<void> inicializar() async {
    await cargarCategoriaYCompetencias();
  }

  // ============================================================
  // CARGAR CATEGORÍA DEL JUGADOR Y SUS COMPETENCIAS
  // ============================================================

  Future<void> cargarCategoriaYCompetencias() async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Obtener persona autenticada
      final persona = await _authService.obtenerUsuario();
      if (persona == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener jugador con su categoría
      final jugador = await _jugadorService.fetchJugadorByPersonaId(persona.idPersonas);
      
      if (jugador?.categoria == null) {
        errorMessage = 'No tienes categoría asignada';
        categoriaJugador = null;
        competencias = [];
      } else {
        categoriaJugador = jugador!.categoria;
        
        // Cargar competencias de la categoría
        competencias = await _competenciaService.getCompetenciasByCategoria(
          categoriaJugador!.idCategorias,
        );
      }
    } catch (e) {
      errorMessage = 'Error al cargar datos: ${e.toString()}';
      categoriaJugador = null;
      competencias = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // BUSCAR COMPETENCIAS
  // ============================================================

  List<Competencia> buscarCompetencias(String query) {
    if (query.isEmpty) return competencias;

    final queryLower = query.toLowerCase();
    return competencias.where((competencia) {
      final nombre = competencia.nombre.toLowerCase();
      final tipo = competencia.tipoCompetencia.toLowerCase();
      final ano = competencia.ano.toString();
      
      return nombre.contains(queryLower) || 
             tipo.contains(queryLower) ||
             ano.contains(queryLower);
    }).toList();
  }
}