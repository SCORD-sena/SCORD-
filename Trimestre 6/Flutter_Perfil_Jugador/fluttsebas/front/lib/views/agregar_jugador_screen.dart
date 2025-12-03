import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Necesario para formatear la fecha

// Modelos y Servicios
import '../models/categoria_model.dart';
import '../models/tipo_documento_model.dart';
import '../services/jugador_service.dart';
// import '../utils/validator.dart'; // Ya no es necesario si usamos regex en línea


class AgregarJugadorScreen extends StatefulWidget {
  const AgregarJugadorScreen({super.key});

  @override
  State<AgregarJugadorScreen> createState() => _AgregarJugadorScreenState();
}

class _AgregarJugadorScreenState extends State<AgregarJugadorScreen> {
  final _jugadorService = JugadorService();
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Estado (equivalente a useState)
  bool _loading = false;
  List<Categoria> _categorias = [];
  List<TipoDocumento> _tiposDocumento = [];
  
  // Valores seleccionados en Dropdown (se guardan como ID del modelo)
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

  // === Helpers para SnackBar y Dialogos (Se mantienen igual) ===

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
      // ✅ CORRECCIÓN 1: Usamos dynamic y casteamos después.
      final results = await Future.wait([
        _jugadorService.fetchCategorias(),
        _jugadorService.fetchTiposDocumento(),
      ]);
      
      setState(() {
        // Casteo explícito del resultado de Future.wait
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
    // 1. Validación de campos vacíos (usa el FormKey de Flutter)
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
      _showErrorDialog("Teléfono inválido", "El teléfono debe iniciar con 3 y tener 10 dígitos.");
      return false;
    }

    if (!telRegex.hasMatch(values['telefonoTutor']!)) {
      _showErrorDialog("Teléfono del tutor inválido", "El teléfono del tutor debe iniciar con 3 y tener 10 dígitos.");
      return false;
    }
    
    // 4. Validación de Correo
    // ✅ CORRECCIÓN 3: Validación de correo con regex local
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'); 
    if (!emailRegex.hasMatch(values['correo']!)) {
       _showErrorDialog("Correo inválido", "Ingresa un correo válido.");
      return false;
    }

    // 5. Validación de Contraseña
    if (values['contrasena']!.length < 8 || values['contrasena']!.length > 12) {
      _showErrorDialog("Contraseña inválida", "La contraseña debe tener entre 8 y 12 caracteres.");
      return false;
    }

    // 6. Validación de Dorsal
    final dorsal = int.tryParse(values['dorsal']!);
    if (dorsal == null || dorsal < 1 || dorsal > 99) {
      _showErrorDialog("Dorsal inválido", "El dorsal debe ser entre 1 y 99.");
      return false;
    }

    // 7. Validación de Estatura
    final estatura = double.tryParse(values['estatura']!);
    if (estatura == null || estatura < 120 || estatura > 220) {
      _showErrorDialog("Estatura inválida", "La estatura debe estar entre 120 y 220 cm.");
      return false;
    }

    return true;
  }

  // === Lógica de Creación (Se mantiene igual) ===

  Future<void> _crearJugador() async {
    // 1. Validar el formulario antes de continuar
    if (!_validarFormulario()) return;

    final values = _controllers.map((key, controller) => MapEntry(key, controller.text));

    // 2. Mostrar Confirmación 
    final bool? confirmation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Estás Seguro?"),
        icon: const Icon(Icons.help_outline, color: Colors.blue),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text("Documento: ${values['numeroDocumento']}", style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("Nombre: ${values['primerNombre']} ${values['segundoNombre'] ?? ''} ${values['primerApellido']}"),
              Text("Teléfono: ${values['telefono']}"),
              Text("Correo: ${values['correo']}"),
              const Divider(height: 10),
              Text("Tutor: ${values['nomTutor1']} ${values['apeTutor1']}"),
              Text("Dorsal: ${values['dorsal']} — Posición: ${values['posicion']}"),
              Text("Estatura: ${values['estatura']} cm"),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Sí, crear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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
      };

      await _jugadorService.createJugador(jugadorData);

      // 5. Éxito
      _showErrorDialog("¡Jugador creado!", "El jugador se creó correctamente.");

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

  // Helper para el selector de fecha (Se mantiene igual)
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

  // === WIDGETS DE CONSTRUCCIÓN ===
  
  // ... (El resto de los métodos _build se mantienen igual, solo se actualizan las propiedades 'descripcion')

  Widget _buildTipoDocumentoDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<int>(
        value: _selectedTipoDocumentoId,
        decoration: const InputDecoration(
          labelText: 'Tipo de Documento *',
          border: OutlineInputBorder(),
          isDense: true,
          contentPadding: EdgeInsets.all(12),
        ),
        items: _tiposDocumento.map((tipo) {
          return DropdownMenuItem(
            value: tipo.idTiposDeDocumentos,
            // ✅ CORRECCIÓN 2a
            child: Text(tipo.descripcion), 
          );
        }).toList(),
        onChanged: (int? newValue) {
          setState(() {
            _selectedTipoDocumentoId = newValue;
          });
        },
        validator: (value) => value == null ? 'Selecciona un tipo de documento.' : null,
      ),
    );
  }

  Widget _buildGeneroDropdown() {
    // Se mantiene igual
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<String>(
        value: _selectedGenero,
        decoration: const InputDecoration(
          labelText: 'Género *',
          border: OutlineInputBorder(),
          isDense: true,
          contentPadding: EdgeInsets.all(12),
        ),
        items: const [
          DropdownMenuItem(value: 'M', child: Text('Masculino')),
          DropdownMenuItem(value: 'F', child: Text('Femenino')),
        ],
        onChanged: (String? newValue) {
          setState(() {
            _selectedGenero = newValue;
          });
        },
        validator: (value) => value == null ? 'Selecciona un género.' : null,
      ),
    );
  }
  
  Widget _buildCategoriaDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<int>(
        value: _selectedCategoriaId,
        decoration: const InputDecoration(
          labelText: 'Categoría *',
          border: OutlineInputBorder(),
          isDense: true,
          contentPadding: EdgeInsets.all(12),
        ),
        items: _categorias.map((cat) {
          return DropdownMenuItem(
            value: cat.idCategorias,
            // ✅ CORRECCIÓN 2b
            child: Text(cat.descripcion), 
          );
        }).toList(),
        onChanged: (int? newValue) {
          setState(() {
            _selectedCategoriaId = newValue;
          });
        },
        validator: (value) => value == null ? 'Selecciona una categoría.' : null,
      ),
    );
  }
  
  Widget _buildTextField({
    required String label,
    required String key,
    bool required = false,
    bool isNumber = false,
    bool isEmail = false,
    bool isPassword = false,
    String? hintText,
    String? helperText,
    TextInputType? keyboardType,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: _controllers[key],
        keyboardType: keyboardType ?? (isNumber ? TextInputType.number : (isEmail ? TextInputType.emailAddress : TextInputType.text)),
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          hintText: hintText,
          helperText: helperText,
          border: const OutlineInputBorder(),
          isDense: true,
          contentPadding: const EdgeInsets.all(12),
        ),
        maxLength: maxLength,
        validator: (value) {
          if (required && (value == null || value.isEmpty)) {
            return 'Este campo es obligatorio.';
          }
          if (isEmail && value != null && !value.contains('@') && value.isNotEmpty) {
            return 'Formato de correo inválido.';
          }
          return null;
        },
      ),
    );
  }
  
  Widget _buildFormSection(String title, List<Widget> fields) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
          ),
        ),
        ...fields,
        const Divider(),
      ],
    );
  }

  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: _selectDate,
        child: AbsorbPointer(
          child: TextFormField(
            controller: _controllers['fechaNacimiento'],
            decoration: const InputDecoration(
              labelText: 'Fecha de Nacimiento *',
              hintText: 'YYYY-MM-DD',
              suffixIcon: Icon(Icons.calendar_today),
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.all(12),
            ),
            validator: (value) => value == null || value.isEmpty ? 'Campo obligatorio.' : null,
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Jugador', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
                    _buildFormSection('Datos Personales', [
                      _buildTextField(label: 'Número de Documento', key: 'numeroDocumento', required: true),
                      _buildTipoDocumentoDropdown(),
                      _buildTextField(label: 'Primer Nombre', key: 'primerNombre', required: true),
                      _buildTextField(label: 'Segundo Nombre', key: 'segundoNombre', required: false),
                      _buildTextField(label: 'Primer Apellido', key: 'primerApellido', required: true),
                      _buildTextField(label: 'Segundo Apellido', key: 'segundoApellido', required: false),
                      _buildGeneroDropdown(),
                      _buildDateField(),
                    ]),

                    // === Sección de Datos de Contacto y Tutor ===
                    _buildFormSection('Datos de Contacto', [
                      _buildTextField(label: 'Teléfono', key: 'telefono', required: true, keyboardType: TextInputType.phone, hintText: '3XXXXXXXXX', maxLength: 10),
                      _buildTextField(label: 'Dirección', key: 'direccion', required: true),
                      _buildTextField(label: 'Correo Electrónico', key: 'correo', required: true, isEmail: true),
                      _buildTextField(label: 'Contraseña', key: 'contrasena', required: true, isPassword: true, helperText: '8–12 caracteres'),
                      _buildTextField(label: 'EPS/Sisben', key: 'epsSisben', required: false),
                    ]),

                    _buildFormSection('Datos del Tutor', [
                      _buildTextField(label: 'Nombre del Tutor', key: 'nomTutor1', required: true),
                      _buildTextField(label: 'Segundo Nombre del Tutor', key: 'nomTutor2', required: false),
                      _buildTextField(label: 'Apellido del Tutor', key: 'apeTutor1', required: true),
                      _buildTextField(label: 'Segundo Apellido del Tutor', key: 'apeTutor2', required: false),
                      _buildTextField(label: 'Teléfono del Tutor', key: 'telefonoTutor', required: true, keyboardType: TextInputType.phone, hintText: '3XXXXXXXXX', maxLength: 10),
                    ]),

                    // === Sección de Información Deportiva ===
                    _buildFormSection('Información Deportiva', [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: _buildTextField(label: 'Dorsal', key: 'dorsal', required: true, keyboardType: TextInputType.number, maxLength: 2),
                          ),
                          const SizedBox(width: 16),
                          Flexible(
                            child: _buildTextField(label: 'Estatura (cm)', key: 'estatura', required: true, keyboardType: TextInputType.number),
                          ),
                        ],
                      ),
                      _buildTextField(label: 'Posición', key: 'posicion', required: true),
                      _buildTextField(label: 'UPZ', key: 'upz', required: false),
                      _buildCategoriaDropdown(),
                    ]),

                    // === Botones de Acción ===
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: _loading ? null : () => Navigator.of(context).pushReplacementNamed('/PerfilJugadorAdmin'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            child: const Text('Cancelar'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: _loading ? null : _crearJugador,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text('Guardar'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}