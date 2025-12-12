import '../../models/entrenador_model.dart';
import '../../models/categoria_model.dart';
import '../../models/tipo_documento_model.dart';
import '../../services/entrenador_service.dart';
import '../../services/categoria_service.dart';
import '../../services/tipo_documento_service.dart';
import '../../services/persona_service.dart';

class EntrenadorController {
  final EntrenadorService _entrenadorService = EntrenadorService();
  final CategoriaService _categoriaService = CategoriaService();
  final TipoDocumentoService _tipoDocumentoService = TipoDocumentoService();
  final PersonaService _personaService = PersonaService();

  // Obtener todos los entrenadores
  Future<List<Entrenador>> fetchEntrenadores() async {
    try {
      return await _entrenadorService.getEntrenadores();
    } catch (e) {
      throw Exception('Error al obtener entrenadores: $e');
    }
  }

  // Obtener todas las categorías
  Future<List<Categoria>> fetchCategorias() async {
    try {
      return await _categoriaService.getCategorias();
    } catch (e) {
      throw Exception('Error al obtener categorías: $e');
    }
  }

  // Obtener todos los tipos de documento
  Future<List<TipoDocumento>> fetchTiposDocumento() async {
    try {
      return await _tipoDocumentoService.getTiposDocumento();
    } catch (e) {
      throw Exception('Error al obtener tipos de documento: $e');
    }
  }

  // Filtrar entrenadores por categoría
  List<Entrenador> filtrarEntrenadoresPorCategoria(
    List<Entrenador> entrenadores,
    int categoriaId,
  ) {
    return entrenadores.where((entrenador) {
      return entrenador.categorias?.any(
            (cat) => cat.idCategorias == categoriaId,
          ) ??
          false;
    }).toList();
  }

  // Actualizar entrenador completo (persona + entrenador)
  Future<bool> actualizarEntrenador({
    required int idPersona,
    required int idEntrenador,
    required Map<String, dynamic> personaData,
    required Map<String, dynamic> entrenadorData,
  }) async {
    try {
      // Actualizar persona primero
      await _personaService.updatePersona(idPersona, personaData);

      // Luego actualizar entrenador
      await _entrenadorService.updateEntrenador(idEntrenador, entrenadorData);

      return true;
    } catch (e) {
      throw Exception('Error al actualizar entrenador: $e');
    }
  }

  // Eliminar entrenador
  Future<bool> eliminarEntrenador(int idEntrenador) async {
    try {
      return await _entrenadorService.deleteEntrenador(idEntrenador);
    } catch (e) {
      throw Exception('Error al eliminar entrenador: $e');
    }
  }

  // Calcular edad desde fecha de nacimiento
  int calcularEdad(String? fechaNacimiento) {
    if (fechaNacimiento == null || fechaNacimiento.isEmpty) return 0;

    try {
      final nacimiento = DateTime.parse(fechaNacimiento);
      final hoy = DateTime.now();
      int edad = hoy.year - nacimiento.year;

      if (hoy.month < nacimiento.month ||
          (hoy.month == nacimiento.month && hoy.day < nacimiento.day)) {
        edad--;
      }

      return edad;
    } catch (e) {
      return 0;
    }
  }
}