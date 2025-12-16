import 'package:flutter/material.dart';
import '../../models/categoria_model.dart';
import '../../models/tipo_documento_model.dart';
import '../../services/jugador_service.dart';

/// Controlador para la lógica de negocio de agregar jugador
class AgregarJugadorController {
  final JugadorService _jugadorService = JugadorService();
  
  // Callbacks para actualizar el estado en el widget
  final VoidCallback onLoadingChanged;
  final Function(String message, bool isError) onShowSnackbar;
  final Function(String title, String content) onShowErrorDialog;
  final VoidCallback onSuccess;
  
  // Estado
  bool _loading = false;
  List<Categoria> _categorias = [];
  List<TipoDocumento> _tiposDocumento = [];
  
  AgregarJugadorController({
    required this.onLoadingChanged,
    required this.onShowSnackbar,
    required this.onShowErrorDialog,
    required this.onSuccess,
  });
  
  // Getters
  bool get loading => _loading;
  List<Categoria> get categorias => _categorias;
  List<TipoDocumento> get tiposDocumento => _tiposDocumento;
  
  // Setter para loading con callback
  set loading(bool value) {
    _loading = value;
    onLoadingChanged();
  }
  
  /// Carga inicial de datos desde la API
  Future<void> cargarDatosIniciales() async {
    loading = true;
    try {
      final results = await Future.wait([
        _jugadorService.fetchCategorias(),
        _jugadorService.fetchTiposDocumento(),
      ]);
      
      _categorias = results[0] as List<Categoria>;
      _tiposDocumento = results[1] as List<TipoDocumento>;
      onLoadingChanged();
    } catch (e) {
      onShowSnackbar('Error al cargar datos: ${e.toString()}', true);
    } finally {
      loading = false;
    }
  }
  
  /// Validación de formulario
  bool validarFormulario({
    required GlobalKey<FormState> formKey,
    required Map<String, String> values,
    required int? tipoDocumentoId,
    required String? genero,
    required int? categoriaId,
  }) {
    // 1. Validación de campos vacíos
    if (!formKey.currentState!.validate()) {
      onShowSnackbar('Por favor, completa todos los campos requeridos.', true);
      return false;
    }

    // 2. Validación de Dropdowns
    if (tipoDocumentoId == null || genero == null || categoriaId == null) {
      onShowSnackbar('Por favor, selecciona las opciones en los desplegables obligatorios.', true);
      return false;
    }
    
    // 3. Validación de Teléfono
    final telRegex = RegExp(r'^3\d{9}$');
    if (!telRegex.hasMatch(values['telefono']!)) {
      onShowErrorDialog("Teléfono inválido", "El teléfono debe iniciar con 3 y tener 10 dígitos.");
      return false;
    }

    if (!telRegex.hasMatch(values['telefonoTutor']!)) {
      onShowErrorDialog("Teléfono del tutor inválido", "El teléfono del tutor debe iniciar con 3 y tener 10 dígitos.");
      return false;
    }
    
    // 4. Validación de Correo
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'); 
    if (!emailRegex.hasMatch(values['correo']!)) {
      onShowErrorDialog("Correo inválido", "Ingresa un correo válido.");
      return false;
    }

    // 5. Validación de Contraseña
    if (values['contrasena']!.length < 8 || values['contrasena']!.length > 12) {
      onShowErrorDialog("Contraseña inválida", "La contraseña debe tener entre 8 y 12 caracteres.");
      return false;
    }

    // 6. Validación de Dorsal
    final dorsal = int.tryParse(values['dorsal']!);
    if (dorsal == null || dorsal < 1 || dorsal > 99) {
      onShowErrorDialog("Dorsal inválido", "El dorsal debe ser entre 1 y 99.");
      return false;
    }

    // 7. Validación de Estatura
    final estatura = double.tryParse(values['estatura']!);
    if (estatura == null || estatura < 120 || estatura > 220) {
      onShowErrorDialog("Estatura inválida", "La estatura debe estar entre 120 y 220 cm.");
      return false;
    }

    return true;
  }
  
  /// Crear jugador (llamadas a API)
  Future<void> crearJugador({
    required Map<String, String> values,
    required int tipoDocumentoId,
    required String genero,
    required int categoriaId,
  }) async {
    loading = true;

    try {
      // PASO 1: Crear la Persona
      final personaData = {
        'NumeroDeDocumento': values['numeroDocumento'],
        'Nombre1': values['primerNombre'],
        'Nombre2': values['segundoNombre']!.isEmpty ? null : values['segundoNombre'],
        'Apellido1': values['primerApellido'],
        'Apellido2': values['segundoApellido']!.isEmpty ? null : values['segundoApellido'],
        'correo': values['correo'],
        'contrasena': values['contrasena'],
        'contrasena_confirmation': values['contrasena'],
        'FechaDeNacimiento': values['fechaNacimiento'],
        'Genero': genero,
        'Telefono': values['telefono'],
        'Direccion': values['direccion'],
        'EpsSisben': values['epsSisben']!.isEmpty ? null : values['epsSisben'],
        'idTiposDeDocumentos': tipoDocumentoId,
        'idRoles': 3, // Rol de Jugador
      };
      
      final int idPersonas = await _jugadorService.createPersona(personaData);

      // PASO 2: Crear el Jugador
      final jugadorData = {
        'Dorsal': int.parse(values['dorsal']!),
        'Posicion': values['posicion'],
        'Upz': values['upz']!.isEmpty ? null : values['upz'],
        'Estatura': double.parse(values['estatura']!),
        'NomTutor1': values['nomTutor1'],
        'NomTutor2': values['nomTutor2']!.isEmpty ? null : values['nomTutor2'],
        'ApeTutor1': values['apeTutor1'],
        'ApeTutor2': values['apeTutor2']!.isEmpty ? null : values['apeTutor2'],
        'TelefonoTutor': values['telefonoTutor'],
        'idPersonas': idPersonas,
        'idCategorias': categoriaId,
      };

      await _jugadorService.createJugador(jugadorData);

      // Éxito
      onShowErrorDialog("¡Jugador creado!", "El jugador se creó correctamente.");
      onSuccess();

    } catch (e) {
      String errorMsg = e.toString().contains('Exception:') 
          ? e.toString().replaceFirst('Exception: ', '') 
          : 'Error desconocido al crear jugador: ${e.toString()}';
      
      onShowErrorDialog("Error", errorMsg);

    } finally {
      loading = false;
    }
  }
}