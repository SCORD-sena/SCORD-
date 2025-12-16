import 'package:flutter/material.dart';
import '/models/categoria_model.dart';
import '/models/tipo_documento_model.dart';
import '/../controllers/admin/entrenador_controller.dart';
import '/../widgets/admin/agregar_entrenador/formulario_datos_personales.dart';
import '../../widgets/admin/agregar_entrenador/formulario_datos_contacto.dart';
import '/../widgets/admin/agregar_entrenador/formulario_informacion_deportiva.dart';
import '../../widgets/common/custom_alert.dart';

class AgregarEntrenadorScreen extends StatefulWidget {
  const AgregarEntrenadorScreen({super.key});

  @override
  State<AgregarEntrenadorScreen> createState() => _AgregarEntrenadorScreenState();
}

class _AgregarEntrenadorScreenState extends State<AgregarEntrenadorScreen> {
  final EntrenadorController _controller = EntrenadorController();
  final _formKey = GlobalKey<FormState>();

  // Listas
  List<Categoria> _categorias = [];
  List<TipoDocumento> _tiposDocumento = [];

  // Estado
  bool _loading = false;
  bool _isLoadingData = true;

  // Controllers
  final _numeroDocumentoController = TextEditingController();
  final _primerNombreController = TextEditingController();
  final _segundoNombreController = TextEditingController();
  final _primerApellidoController = TextEditingController();
  final _segundoApellidoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _epsSisbenController = TextEditingController();
  final _anosExperienciaController = TextEditingController();
  final _cargoController = TextEditingController();

  // Variables de formulario
  int? _tipoDocumentoSeleccionado;
  String? _generoSeleccionado;
  DateTime? _fechaNacimiento;
  List<int> _categoriasSeleccionadas = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void dispose() {
    _numeroDocumentoController.dispose();
    _primerNombreController.dispose();
    _segundoNombreController.dispose();
    _primerApellidoController.dispose();
    _segundoApellidoController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _correoController.dispose();
    _contrasenaController.dispose();
    _epsSisbenController.dispose();
    _anosExperienciaController.dispose();
    _cargoController.dispose();
    super.dispose();
  }

  // ============================================
  // CARGA DE DATOS
  // ============================================

  Future<void> _cargarDatos() async {
    setState(() => _isLoadingData = true);

    try {
      final categorias = await _controller.fetchCategorias();
      final tiposDoc = await _controller.fetchTiposDocumento();

      if (mounted) {
        setState(() {
          _categorias = categorias;
          _tiposDocumento = tiposDoc;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingData = false);
        CustomAlert.mostrar(
          context,
          'Error',
          'Error al cargar datos: $e',
          Colors.red,
        );
      }
    }
  }

  // ============================================
  // VALIDACIÓN Y GUARDADO
  // ============================================

  Future<void> _guardarEntrenador() async {
    if (!_formKey.currentState!.validate()) return;

    // Validar categorías
    if (_categoriasSeleccionadas.isEmpty) {
      CustomAlert.mostrar(
        context,
        'Categorías requeridas',
        'Debes seleccionar al menos una categoría',
        Colors.orange,
      );
      return;
    }

    // Validar fecha de nacimiento
    if (_fechaNacimiento == null) {
      CustomAlert.mostrar(
        context,
        'Fecha requerida',
        'Debes seleccionar una fecha de nacimiento',
        Colors.orange,
      );
      return;
    }

    // Confirmación
    final confirmar = await CustomAlert.confirmar(
      context,
      '¿Estás Seguro?',
      'Documento: ${_numeroDocumentoController.text}\n'
          'Nombre: ${_primerNombreController.text} ${_segundoNombreController.text} ${_primerApellidoController.text}\n'
          'Teléfono: ${_telefonoController.text}\n'
          'Correo: ${_correoController.text}\n'
          'Cargo: ${_cargoController.text}\n'
          'Años de Experiencia: ${_anosExperienciaController.text}',
      'Sí, crear',
      Colors.green,
    );

    if (!confirmar) return;

    setState(() => _loading = true);

    try {
      // PASO 1: Preparar datos de persona
      final personaData = {
        'NumeroDeDocumento': _numeroDocumentoController.text.trim(),
        'Nombre1': _primerNombreController.text.trim(),
        'Nombre2': _segundoNombreController.text.trim().isEmpty
            ? null
            : _segundoNombreController.text.trim(),
        'Apellido1': _primerApellidoController.text.trim(),
        'Apellido2': _segundoApellidoController.text.trim().isEmpty
            ? null
            : _segundoApellidoController.text.trim(),
        'correo': _correoController.text.trim(),
        'contrasena': _contrasenaController.text,
        'contrasena_confirmation': _contrasenaController.text,
        'FechaDeNacimiento': _fechaNacimiento!.toIso8601String().split('T')[0],
        'Genero': _generoSeleccionado,
        'Telefono': _telefonoController.text.trim(),
        'Direccion': _direccionController.text.trim(),
        'EpsSisben': _epsSisbenController.text.trim().isEmpty
            ? null
            : _epsSisbenController.text.trim(),
        'idTiposDeDocumentos': _tipoDocumentoSeleccionado,
        'idRoles': 2, // Rol de entrenador
      };

      // PASO 2: Preparar datos de entrenador
      final entrenadorData = {
        'AnosDeExperiencia': int.parse(_anosExperienciaController.text),
        'Cargo': _cargoController.text.trim(),
        'categorias': _categoriasSeleccionadas,
      };

      // PASO 3: Crear entrenador
      await _controller.crearEntrenador(
        personaData: personaData,
        entrenadorData: entrenadorData,
      );

      if (mounted) {
        setState(() => _loading = false);

        CustomAlert.mostrar(
          context,
          '¡Entrenador creado!',
          'El entrenador se creó correctamente',
          Colors.green,
        );

        // Regresar a la pantalla anterior después de 1.5 segundos
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);

        String errorMsg = 'No se pudo crear el entrenador';

        if (e.toString().contains('documento ya está registrado')) {
          errorMsg = 'El número de documento ya está registrado en el sistema';
        } else if (e.toString().contains('correo ya está registrado')) {
          errorMsg = 'El correo electrónico ya está registrado en el sistema';
        } else {
          errorMsg = e.toString().replaceAll('Exception: ', '');
        }

        CustomAlert.mostrar(context, 'Error', errorMsg, Colors.red);
      }
    }
  }

  // ============================================
  // HANDLERS
  // ============================================

  void _onTipoDocumentoChanged(int? value) {
    setState(() => _tipoDocumentoSeleccionado = value);
  }

  void _onGeneroChanged(String? value) {
    setState(() => _generoSeleccionado = value);
  }

  Future<void> _onFechaPressed() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 años atrás
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (fecha != null) {
      setState(() => _fechaNacimiento = fecha);
    }
  }

  void _onCategoriaChanged(int categoriaId, bool selected) {
    setState(() {
      if (selected) {
        _categoriasSeleccionadas.add(categoriaId);
      } else {
        _categoriasSeleccionadas.remove(categoriaId);
      }
    });
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xffe63946)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Agregar Entrenador',
          style: TextStyle(
            color: Color(0xffe63946),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xffe63946)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Datos Personales
              FormularioDatosPersonales(
                numeroDocumentoController: _numeroDocumentoController,
                primerNombreController: _primerNombreController,
                segundoNombreController: _segundoNombreController,
                primerApellidoController: _primerApellidoController,
                segundoApellidoController: _segundoApellidoController,
                tiposDocumento: _tiposDocumento,
                tipoDocumentoSeleccionado: _tipoDocumentoSeleccionado,
                generoSeleccionado: _generoSeleccionado,
                fechaNacimiento: _fechaNacimiento,
                onTipoDocumentoChanged: _onTipoDocumentoChanged,
                onGeneroChanged: _onGeneroChanged,
                onFechaPressed: _onFechaPressed,
              ),
              const SizedBox(height: 16),

              // Datos de Contacto
              FormularioDatosContacto(
                telefonoController: _telefonoController,
                direccionController: _direccionController,
                correoController: _correoController,
                contrasenaController: _contrasenaController,
                epsSisbenController: _epsSisbenController,
              ),
              const SizedBox(height: 16),

              // Información Deportiva
              FormularioInformacionDeportiva(
                anosExperienciaController: _anosExperienciaController,
                cargoController: _cargoController,
                categorias: _categorias,
                categoriasSeleccionadas: _categoriasSeleccionadas,
                onCategoriaChanged: _onCategoriaChanged,
              ),
              const SizedBox(height: 24),

              // Botones
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _loading ? null : () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _loading ? null : _guardarEntrenador,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Guardar',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: const Text(
          '© 2025 SCORD | Escuela de Fútbol Quilmes | Todos los derechos reservados',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 10),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}