import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/categoria_model.dart';
import '../../models/tipo_documento_model.dart';
import '../../services/jugador_service.dart';
import '../../widgets/admin/agregar_jugador/jugador_form_widgets.dart';

class AgregarJugadorScreen extends StatefulWidget {
  const AgregarJugadorScreen({super.key});

  @override
  State<AgregarJugadorScreen> createState() => _AgregarJugadorScreenState();
}

class _AgregarJugadorScreenState extends State<AgregarJugadorScreen> {
  final _jugadorService = JugadorService();
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Estado
  bool _loading = false;
  List<Categoria> _categorias = [];
  List<TipoDocumento> _tiposDocumento = [];
  
  // Valores seleccionados en Dropdown
  int? _selectedTipoDocumentoId;
  String? _selectedGenero;
  int? _selectedCategoriaId;
  
  // Controladores de Texto
  final Map<String, TextEditingController> _controllers = {
    'numeroDocumento': TextEditingController(),
    'primerNombre': TextEditingController(),
    'segundoNombre': TextEditingController(),
    'primerApellido': TextEditingController(),
    'segundoApellido': TextEditingController(),
    'fechaNacimiento': TextEditingController(),
    'telefono': TextEditingController(),
    'direccion': TextEditingController(),
    'correo': TextEditingController(),
    'contrasena': TextEditingController(),
    'epsSisben': TextEditingController(),
    'nomTutor1': TextEditingController(),
    'nomTutor2': TextEditingController(),
    'apeTutor1': TextEditingController(),
    'apeTutor2': TextEditingController(),
    'telefonoTutor': TextEditingController(),
    'dorsal': TextEditingController(),
    'posicion': TextEditingController(),
    'estatura': TextEditingController(),
    'upz': TextEditingController(),
    // ====== NUEVOS CONTROLADORES PARA MENSUALIDAD ======
    'fechaIngresoClub': TextEditingController(),
    'fechaVencimientoMensualidad': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) => controller.dispose());
    _scrollController.dispose();
    super.dispose();
  }

  // === Helpers para SnackBar y Dialogos ===

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _showErrorDialog(String title, String content) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(color: Colors.red)),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aceptar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // === Lógica de Carga Inicial (GET) ===

  Future<void> _cargarDatosIniciales() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _jugadorService.fetchCategorias(),
        _jugadorService.fetchTiposDocumento(),
      ]);
      
      setState(() {
        _categorias = results[0] as List<Categoria>;
        _tiposDocumento = results[1] as List<TipoDocumento>;
      });
    } catch (e) {
      _showSnackbar('Error al cargar datos: ${e.toString()}', isError: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  // === Lógica de Validación ===

  bool _validarFormulario() {
    // 1. Validación de campos vacíos
    if (!_formKey.currentState!.validate()) {
      _showSnackbar('Por favor, completa todos los campos requeridos.', isError: true);
      return false;
    }

    // 2. Validación de Dropdowns
    if (_selectedTipoDocumentoId == null || _selectedGenero == null || _selectedCategoriaId == null) {
      _showSnackbar('Por favor, selecciona las opciones en los desplegables obligatorios.', isError: true);
      return false;
    }

    final values = _controllers.map((key, controller) => MapEntry(key, controller.text));
    
    // 3. Validación de Teléfono
    final telRegex = RegExp(r'^3\d{9}$');
    if (!telRegex.hasMatch(values['telefono']!)) {
      _showErrorDialog("Telefono invalido", "El telefono debe iniciar con 3 y tener 10 digitos.");
      return false;
    }

    if (!telRegex.hasMatch(values['telefonoTutor']!)) {
      _showErrorDialog("Telefono del tutor invalido", "El telefono del tutor debe iniciar con 3 y tener 10 digitos.");
      return false;
    }
    
    // 4. Validación de Correo
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'); 
    if (!emailRegex.hasMatch(values['correo']!)) {
       _showErrorDialog("Correo invalido", "Ingresa un correo valido.");
      return false;
    }

    // 5. Validación de Contraseña
    if (values['contrasena']!.length < 8 || values['contrasena']!.length > 12) {
      _showErrorDialog("Contrasena invalida", "La contrasena debe tener entre 8 y 12 caracteres.");
      return false;
    }

    // 6. Validación de Dorsal
    final dorsal = int.tryParse(values['dorsal']!);
    if (dorsal == null || dorsal < 1 || dorsal > 99) {
      _showErrorDialog("Dorsal invalido", "El dorsal debe ser entre 1 y 99.");
      return false;
    }

    // 7. Validación de Estatura
    final estatura = double.tryParse(values['estatura']!);
    if (estatura == null || estatura < 120 || estatura > 220) {
      _showErrorDialog("Estatura invalida", "La estatura debe estar entre 120 y 220 cm.");
      return false;
    }

    return true;
  }

  // === Lógica de Creación ===

  Future<void> _crearJugador() async {
    // 1. Validar el formulario antes de continuar
    if (!_validarFormulario()) return;

    final values = _controllers.map((key, controller) => MapEntry(key, controller.text));

    // 2. Mostrar Confirmación 
    final bool? confirmation = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmacionDialog(valores: values),
    );

    if (confirmation == null || !confirmation) return;

    setState(() => _loading = true);

    try {
      // 3. PASO 1: Crear la Persona (POST /personas)
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
        'Genero': _selectedGenero,
        'Telefono': values['telefono'],
        'Direccion': values['direccion'],
        'EpsSisben': values['epsSisben']!.isEmpty ? null : values['epsSisben'],
        'idTiposDeDocumentos': _selectedTipoDocumentoId!,
        'idRoles': 3, // Rol de Jugador
      };
      
      final int idPersonas = await _jugadorService.createPersona(personaData);

      // 4. PASO 2: Crear el Jugador (POST /jugadores)
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
        'idCategorias': _selectedCategoriaId!,
        // ====== AGREGAR FECHAS DE MENSUALIDAD (OPCIONALES) ======
        if (values['fechaIngresoClub']!.isNotEmpty)
          'fechaIngresoClub': values['fechaIngresoClub'],
        if (values['fechaVencimientoMensualidad']!.isNotEmpty)
          'fechaVencimientoMensualidad': values['fechaVencimientoMensualidad'],
      };

      await _jugadorService.createJugador(jugadorData);

      // 5. Éxito
      _showErrorDialog("¡Jugador creado!", "El jugador se creo correctamente.");

      // Limpiar formulario y navegar
      _resetForm();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/PerfilJugadorAdmin');
      }

    } catch (e) {
      String errorMsg = e.toString().contains('Exception:') 
          ? e.toString().replaceFirst('Exception: ', '') 
          : 'Error desconocido al crear jugador: ${e.toString()}';
      
      _showErrorDialog("Error", errorMsg);

    } finally {
      setState(() => _loading = false);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _controllers.forEach((key, controller) => controller.clear());
    setState(() {
      _selectedTipoDocumentoId = null;
      _selectedGenero = null;
      _selectedCategoriaId = null;
    });
  }

  // Helper para el selector de fecha de nacimiento
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      _controllers['fechaNacimiento']!.text = formattedDate;
    }
  }

  // ====== NUEVO: Selector de fecha de ingreso ======
  Future<void> _selectFechaIngreso() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      _controllers['fechaIngresoClub']!.text = formattedDate;
    }
  }

  // ====== NUEVO: Selector de fecha de vencimiento ======
  Future<void> _selectFechaVencimiento() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      _controllers['fechaVencimientoMensualidad']!.text = formattedDate;
    }
  }

  // === BUILD ===

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Agregar Jugador',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _loading && _categorias.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // === Sección de Datos Personales ===
                    FormSection(
                      title: 'Datos Personales',
                      children: [
                        CustomTextField(
                          label: 'Numero de Documento',
                          controller: _controllers['numeroDocumento']!,
                          required: true,
                        ),
                        TipoDocumentoDropdown(
                          value: _selectedTipoDocumentoId,
                          tiposDocumento: _tiposDocumento,
                          onChanged: (value) => setState(() => _selectedTipoDocumentoId = value),
                        ),
                        CustomTextField(
                          label: 'Primer Nombre',
                          controller: _controllers['primerNombre']!,
                          required: true,
                        ),
                        CustomTextField(
                          label: 'Segundo Nombre',
                          controller: _controllers['segundoNombre']!,
                        ),
                        CustomTextField(
                          label: 'Primer Apellido',
                          controller: _controllers['primerApellido']!,
                          required: true,
                        ),
                        CustomTextField(
                          label: 'Segundo Apellido',
                          controller: _controllers['segundoApellido']!,
                        ),
                        GeneroDropdown(
                          value: _selectedGenero,
                          onChanged: (value) => setState(() => _selectedGenero = value),
                        ),
                        DatePickerField(
                          controller: _controllers['fechaNacimiento']!,
                          label: 'Fecha de Nacimiento',
                          onTap: _selectDate,
                        ),
                      ],
                    ),

                    // === Sección de Datos de Contacto ===
                    FormSection(
                      title: 'Datos de Contacto',
                      children: [
                        CustomTextField(
                          label: 'Telefono',
                          controller: _controllers['telefono']!,
                          required: true,
                          keyboardType: TextInputType.phone,
                          hintText: '3XXXXXXXXX',
                          maxLength: 10,
                        ),
                        CustomTextField(
                          label: 'Direccion',
                          controller: _controllers['direccion']!,
                          required: true,
                        ),
                        CustomTextField(
                          label: 'Correo Electronico',
                          controller: _controllers['correo']!,
                          required: true,
                          isEmail: true,
                        ),
                        CustomTextField(
                          label: 'Contrasena',
                          controller: _controllers['contrasena']!,
                          required: true,
                          isPassword: true,
                          helperText: '8–12 caracteres',
                        ),
                        CustomTextField(
                          label: 'EPS/Sisben',
                          controller: _controllers['epsSisben']!,
                        ),
                      ],
                    ),

                    // === Sección de Datos del Tutor ===
                    FormSection(
                      title: 'Datos del Tutor',
                      children: [
                        CustomTextField(
                          label: 'Nombre del Tutor',
                          controller: _controllers['nomTutor1']!,
                          required: true,
                        ),
                        CustomTextField(
                          label: 'Segundo Nombre del Tutor',
                          controller: _controllers['nomTutor2']!,
                        ),
                        CustomTextField(
                          label: 'Apellido del Tutor',
                          controller: _controllers['apeTutor1']!,
                          required: true,
                        ),
                        CustomTextField(
                          label: 'Segundo Apellido del Tutor',
                          controller: _controllers['apeTutor2']!,
                        ),
                        CustomTextField(
                          label: 'Telefono del Tutor',
                          controller: _controllers['telefonoTutor']!,
                          required: true,
                          keyboardType: TextInputType.phone,
                          hintText: '3XXXXXXXXX',
                          maxLength: 10,
                        ),
                      ],
                    ),

                    // === Sección de Información Deportiva ===
                    FormSection(
                      title: 'Informacion Deportiva',
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: CustomTextField(
                                label: 'Dorsal',
                                controller: _controllers['dorsal']!,
                                required: true,
                                keyboardType: TextInputType.number,
                                maxLength: 2,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Flexible(
                              child: CustomTextField(
                                label: 'Estatura (cm)',
                                controller: _controllers['estatura']!,
                                required: true,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        CustomTextField(
                          label: 'Posicion',
                          controller: _controllers['posicion']!,
                          required: true,
                        ),
                        CustomTextField(
                          label: 'UPZ',
                          controller: _controllers['upz']!,
                        ),
                        CategoriaDropdown(
                          value: _selectedCategoriaId,
                          categorias: _categorias,
                          onChanged: (value) => setState(() => _selectedCategoriaId = value),
                        ),
                      ],
                    ),

                    // ====== NUEVA SECCION: Informacion de Mensualidad ======
                    FormSection(
                      title: 'Informacion de Mensualidad (Obligatorio)',
                      children: [
                        DatePickerField(
                          controller: _controllers['fechaIngresoClub']!,
                          label: 'Fecha de Ingreso al Club',
                          onTap: _selectFechaIngreso,
                          required: false,
                        ),
                        DatePickerField(
                          controller: _controllers['fechaVencimientoMensualidad']!,
                          label: 'Fecha de Vencimiento de Mensualidad',
                          onTap: _selectFechaVencimiento,
                          required: false,
                        ),
                      ],
                    ),

                    // === Botones de Acción ===
                    FormActionButtons(
                      loading: _loading,
                      onCancel: () => Navigator.of(context).pushReplacementNamed('/PerfilJugadorAdmin'),
                      onSave: _crearJugador,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}