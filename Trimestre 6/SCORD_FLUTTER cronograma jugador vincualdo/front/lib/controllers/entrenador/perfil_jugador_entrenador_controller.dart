import 'package:flutter/material.dart';
import '../../models/jugador_model.dart';
import '../../models/categoria_model.dart';
import '../../models/tipo_documento_model.dart';
import '../../models/persona_model.dart';
import '../../services/jugador_service.dart';
import '../../services/auth_service.dart';
import '../../services/entrenador_service.dart';

class PerfilJugadorEntrenadorController extends ChangeNotifier {
  final JugadorService _jugadorService = JugadorService();
  final AuthService _authService = AuthService();
  final EntrenadorService _entrenadorService = EntrenadorService();

  // State
  List<Jugador> jugadores = [];
  List<Categoria> categorias = [];
  List<Categoria> categoriasEntrenador = []; // ⭐ Solo las categorías que dirige el entrenador
  List<TipoDocumento> tiposDocumento = [];
  String? categoriaSeleccionada;
  Jugador? jugadorSeleccionado;
  List<Jugador> jugadoresFiltrados = [];
  bool modoEdicion = false;
  bool loading = false;
  
  // Form state
  int? selectedTipoDocumentoId;
  String? selectedGenero;
  int? selectedCategoriaId;
  DateTime? selectedFechaNacimiento;

  // Controllers
  late Map<String, TextEditingController> controllers;

  PerfilJugadorEntrenadorController() {
    controllers = _initializeControllers();
  }

  Map<String, TextEditingController> _initializeControllers() {
    return {
      'numeroDocumento': TextEditingController(),
      'tipoDocumento': TextEditingController(),
      'primerNombre': TextEditingController(),
      'segundoNombre': TextEditingController(),
      'primerApellido': TextEditingController(),
      'segundoApellido': TextEditingController(),
      'genero': TextEditingController(),
      'telefono': TextEditingController(),
      'direccion': TextEditingController(),
      'fechaNacimiento': TextEditingController(),
      'correo': TextEditingController(),
      'contrasena': TextEditingController(),
      'epsSisben': TextEditingController(),
      'dorsal': TextEditingController(),
      'posicion': TextEditingController(),
      'estatura': TextEditingController(),
      'upz': TextEditingController(),
      'categoria': TextEditingController(),
      'nomTutor1': TextEditingController(),
      'nomTutor2': TextEditingController(),
      'apeTutor1': TextEditingController(),
      'apeTutor2': TextEditingController(),
      'telefonoTutor': TextEditingController(),
    };
  }

  // Inicialización
  Future<void> inicializar() async {
    await fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    loading = true;
    notifyListeners();

    try {
      // Obtener datos del entrenador logueado
      final persona = await _authService.obtenerUsuario();
      
      if (persona == null) {
        throw Exception('No se pudo obtener el usuario logueado');
      }

      // Obtener el entrenador con sus categorías
      final entrenador = await _entrenadorService.getEntrenadorByPersonaId(persona.idPersonas);
      
      if (entrenador == null || entrenador.categorias == null || entrenador.categorias!.isEmpty) {
        throw Exception('El entrenador no tiene categorías asignadas');
      }

      // Guardar las categorías del entrenador
      categoriasEntrenador = entrenador.categorias!;
      
      // Obtener IDs de las categorías del entrenador
      final idsCategorias = categoriasEntrenador.map((c) => c.idCategorias).toList();

      // Obtener jugadores filtrados por las categorías del entrenador
      final results = await Future.wait([
        _jugadorService.fetchJugadoresByCategoriasEntrenador(idsCategorias),
        _jugadorService.fetchCategorias(),
        _jugadorService.fetchTiposDocumento(),
      ]);

      jugadores = results[0] as List<Jugador>;
      categorias = results[1] as List<Categoria>;
      tiposDocumento = results[2] as List<TipoDocumento>;
      
    } catch (e) {
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // Filtrado
  void filtrarJugadores() {
    if (categoriaSeleccionada == null || categoriaSeleccionada!.isEmpty) {
      jugadoresFiltrados = [];
      jugadorSeleccionado = null;
      modoEdicion = false;
      notifyListeners();
      return;
    }

    final int categoriaId = int.tryParse(categoriaSeleccionada!) ?? 0;
    jugadoresFiltrados = jugadores.where((j) => j.idCategorias == categoriaId).toList();
    jugadorSeleccionado = null;
    modoEdicion = false;
    notifyListeners();
  }

  void seleccionarCategoria(String? value) {
    categoriaSeleccionada = value;
    filtrarJugadores();
  }

  void seleccionarJugador(int? idJugador) {
    if (idJugador != null) {
      jugadorSeleccionado = jugadores.firstWhere((j) => j.idJugadores == idJugador);
      modoEdicion = false;
    } else {
      jugadorSeleccionado = null;
    }
    notifyListeners();
  }

  // Edición
  void activarEdicion() {
    if (jugadorSeleccionado == null) {
      throw Exception('Por favor selecciona un jugador primero');
    }

    final persona = jugadorSeleccionado!.persona;

    controllers['numeroDocumento']!.text = persona.numeroDeDocumento;
    controllers['primerNombre']!.text = persona.nombre1;
    controllers['segundoNombre']!.text = persona.nombre2 ?? '';
    controllers['primerApellido']!.text = persona.apellido1;
    controllers['segundoApellido']!.text = persona.apellido2 ?? '';
    controllers['telefono']!.text = persona.telefono;
    controllers['direccion']!.text = persona.direccion;
    controllers['correo']!.text = persona.correo;
    controllers['contrasena']!.text = '';
    controllers['epsSisben']!.text = persona.epsSisben ?? '';
    controllers['dorsal']!.text = jugadorSeleccionado!.dorsal.toString();
    controllers['posicion']!.text = jugadorSeleccionado!.posicion;
    controllers['estatura']!.text = jugadorSeleccionado!.estatura.toString();
    controllers['upz']!.text = jugadorSeleccionado!.upz ?? '';
    controllers['nomTutor1']!.text = jugadorSeleccionado!.nomTutor1;
    controllers['nomTutor2']!.text = jugadorSeleccionado!.nomTutor2 ?? '';
    controllers['apeTutor1']!.text = jugadorSeleccionado!.apeTutor1;
    controllers['apeTutor2']!.text = jugadorSeleccionado!.apeTutor2 ?? '';
    controllers['telefonoTutor']!.text = jugadorSeleccionado!.telefonoTutor;

    selectedTipoDocumentoId = persona.idTiposDeDocumentos;
    selectedGenero = persona.genero;
    selectedCategoriaId = jugadorSeleccionado!.idCategorias;
    selectedFechaNacimiento = persona.fechaDeNacimiento;
    controllers['fechaNacimiento']!.text = selectedFechaNacimiento?.toIso8601String().split('T')[0] ?? '';

    modoEdicion = true;
    notifyListeners();
  }

  void cancelarEdicion() {
    modoEdicion = false;
    notifyListeners();
  }

  // Validación
  List<String> validateForm() {
    final List<String> errors = [];

    if (controllers['numeroDocumento']!.text.isEmpty) {
      errors.add('El número de documento es obligatorio.');
    }

    return errors.toSet().toList();
  }

  // Guardar cambios
  Future<bool> guardarCambios() async {
    final validationMessages = validateForm();
    if (validationMessages.isNotEmpty) {
      throw Exception(validationMessages.join('\n'));
    }

    loading = true;
    notifyListeners();

    try {
      final personaData = Persona(
        idPersonas: jugadorSeleccionado!.persona.idPersonas,
        numeroDeDocumento: controllers['numeroDocumento']!.text,
        idTiposDeDocumentos: selectedTipoDocumentoId!,
        nombre1: controllers['primerNombre']!.text,
        nombre2: controllers['segundoNombre']!.text.isEmpty ? null : controllers['segundoNombre']!.text,
        apellido1: controllers['primerApellido']!.text,
        apellido2: controllers['segundoApellido']!.text.isEmpty ? null : controllers['segundoApellido']!.text,
        genero: selectedGenero!,
        telefono: controllers['telefono']!.text,
        direccion: controllers['direccion']!.text,
        fechaDeNacimiento: selectedFechaNacimiento!,
        correo: controllers['correo']!.text,
        epsSisben: controllers['epsSisben']!.text.isEmpty ? null : controllers['epsSisben']!.text,
      );

      await _jugadorService.updatePersona(
        jugadorSeleccionado!.persona.idPersonas,
        personaData,
        contrasena: controllers['contrasena']!.text.isNotEmpty ? controllers['contrasena']!.text : null,
      );

      final jugadorData = Jugador(
        idJugadores: jugadorSeleccionado!.idJugadores,
        idPersonas: jugadorSeleccionado!.idPersonas,
        dorsal: int.parse(controllers['dorsal']!.text),
        posicion: controllers['posicion']!.text,
        upz: controllers['upz']!.text.isEmpty ? null : controllers['upz']!.text,
        estatura: double.parse(controllers['estatura']!.text),
        nomTutor1: controllers['nomTutor1']!.text,
        nomTutor2: controllers['nomTutor2']!.text.isEmpty ? null : controllers['nomTutor2']!.text,
        apeTutor1: controllers['apeTutor1']!.text,
        apeTutor2: controllers['apeTutor2']!.text.isEmpty ? null : controllers['apeTutor2']!.text,
        telefonoTutor: controllers['telefonoTutor']!.text,
        idCategorias: selectedCategoriaId!,
        persona: personaData,
      );

      await _jugadorService.updateJugador(jugadorSeleccionado!.idJugadores, jugadorData);

      modoEdicion = false;
      await fetchInitialData();
      filtrarJugadores();

      return true;
    } catch (e) {
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // Eliminar jugador
  Future<bool> eliminarJugador() async {
    if (jugadorSeleccionado == null) {
      throw Exception('Por favor selecciona un jugador primero');
    }

    try {
      await _jugadorService.deleteJugador(jugadorSeleccionado!.idJugadores);

      jugadorSeleccionado = null;
      modoEdicion = false;
      await fetchInitialData();
      filtrarJugadores();

      return true;
    } catch (e) {
      rethrow;
    }
  }

  // Actualizar campos
  void actualizarTipoDocumento(int? value) {
    selectedTipoDocumentoId = value;
    notifyListeners();
  }

  void actualizarGenero(String? value) {
    selectedGenero = value;
    notifyListeners();
  }

  void actualizarCategoria(int? value) {
    selectedCategoriaId = value;
    notifyListeners();
  }

  void actualizarFechaNacimiento(DateTime? fecha) {
    selectedFechaNacimiento = fecha;
    if (fecha != null) {
      controllers['fechaNacimiento']!.text = fecha.toIso8601String().split('T')[0];
    }
    notifyListeners();
  }

  // Helpers
  String calcularEdad(DateTime? fechaNacimiento) {
    if (fechaNacimiento == null) return "-";
    final hoy = DateTime.now();
    int edad = hoy.year - fechaNacimiento.year;
    final mes = hoy.month - fechaNacimiento.month;
    if (mes < 0 || (mes == 0 && hoy.day < fechaNacimiento.day)) {
      edad--;
    }
    return edad.toString();
  }

  @override
  void dispose() {
    controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }
}