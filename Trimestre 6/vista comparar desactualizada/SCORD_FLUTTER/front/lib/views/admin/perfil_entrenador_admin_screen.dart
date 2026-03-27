import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/../models/entrenador_model.dart';
import '/../models/categoria_model.dart';
import '/../models/tipo_documento_model.dart';
import '/../controllers/admin/entrenador_controller.dart';
import '/../widgets/admin/perfil_entrenador/entrenador_botones_accion.dart';
import '/../widgets/admin/perfil_entrenador/selector_entrenador_card.dart';
import '/../widgets/admin/perfil_entrenador/entrenador_info_card.dart';
import '/../widgets/common/info_row.dart';
import '/../widgets/common/custom_alert.dart';

class PerfilEntrenadorAdminScreen extends StatefulWidget {
  const PerfilEntrenadorAdminScreen({super.key});

  @override
  State<PerfilEntrenadorAdminScreen> createState() =>
      _PerfilEntrenadorAdminScreenState();
}

class _PerfilEntrenadorAdminScreenState
    extends State<PerfilEntrenadorAdminScreen> {
  // Controller
  final EntrenadorController _controller = EntrenadorController();

  // Listas de datos
  List<Entrenador> _entrenadores = [];
  List<Categoria> _categorias = [];
  List<TipoDocumento> _tiposDocumento = [];
  List<Entrenador> _entrenadoresFiltrados = [];

  // Estado de la UI
  int? _categoriaSeleccionada;
  Entrenador? _entrenadorSeleccionado;
  bool _modoEdicion = false;
  bool _loading = false;
  bool _isLoadingData = true;

  // Form
  final _formKey = GlobalKey<FormState>();

  // Controllers de campos de texto
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
  List<int> _categoriasAsignadas = [];

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
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
  // MÉTODOS DE CARGA DE DATOS
  // ============================================

  Future<void> _cargarDatosIniciales() async {
    setState(() => _isLoadingData = true);

    try {
      final entrenadores = await _controller.fetchEntrenadores();
      final categorias = await _controller.fetchCategorias();
      final tiposDoc = await _controller.fetchTiposDocumento();

      if (mounted) {
        setState(() {
          _entrenadores = entrenadores;
          _categorias = categorias;
          _tiposDocumento = tiposDoc;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingData = false);
        CustomAlert.mostrar(context, 'Error', 'Error al cargar datos: $e', Colors.red);
      }
    }
  }

  void _filtrarEntrenadores() {
    if (_categoriaSeleccionada != null) {
      setState(() {
        _entrenadoresFiltrados = _controller.filtrarEntrenadoresPorCategoria(
          _entrenadores,
          _categoriaSeleccionada!,
        );
        _entrenadorSeleccionado = null;
        _modoEdicion = false;
      });
    } else {
      setState(() {
        _entrenadoresFiltrados = [];
        _entrenadorSeleccionado = null;
        _modoEdicion = false;
      });
    }
  }

  // ============================================
  // MÉTODOS DE EDICIÓN
  // ============================================

  void _activarEdicion() {
    if (_entrenadorSeleccionado == null) {
      CustomAlert.mostrar(
        context,
        'No hay entrenador seleccionado',
        'Por favor selecciona un entrenador primero',
        Colors.orange,
      );
      return;
    }

    final persona = _entrenadorSeleccionado!.persona;
    if (persona == null) {
      CustomAlert.mostrar(context, 'Error', 'No se encontró la información de la persona', Colors.red);
      return;
    }

    final categoriasIds = _entrenadorSeleccionado!.categorias
            ?.map((c) => c.idCategorias)
            .toList() ??
        [];

    setState(() {
      _numeroDocumentoController.text = persona.numeroDeDocumento;
      _tipoDocumentoSeleccionado = persona.idTiposDeDocumentos;
      _primerNombreController.text = persona.nombre1;
      _segundoNombreController.text = persona.nombre2 ?? '';
      _primerApellidoController.text = persona.apellido1;
      _segundoApellidoController.text = persona.apellido2 ?? '';
      _generoSeleccionado = persona.genero;
      _telefonoController.text = persona.telefono;
      _direccionController.text = persona.direccion;
      _fechaNacimiento = persona.fechaDeNacimiento;
      _correoController.text = persona.correo;
      _contrasenaController.text = '';
      _epsSisbenController.text = persona.epsSisben ?? '';
      _anosExperienciaController.text =
          _entrenadorSeleccionado!.anosDeExperiencia.toString();
      _cargoController.text = _entrenadorSeleccionado!.cargo;
      _categoriasAsignadas = categoriasIds;
      _modoEdicion = true;
    });
  }

  void _cancelarEdicion() {
    setState(() {
      _modoEdicion = false;
      _limpiarFormulario();
    });
  }

  void _limpiarFormulario() {
    _numeroDocumentoController.clear();
    _primerNombreController.clear();
    _segundoNombreController.clear();
    _primerApellidoController.clear();
    _segundoApellidoController.clear();
    _telefonoController.clear();
    _direccionController.clear();
    _correoController.clear();
    _contrasenaController.clear();
    _epsSisbenController.clear();
    _anosExperienciaController.clear();
    _cargoController.clear();
    _tipoDocumentoSeleccionado = null;
    _generoSeleccionado = null;
    _fechaNacimiento = null;
    _categoriasAsignadas = [];
  }

  // ============================================
  // MÉTODOS DE GUARDADO Y ELIMINACIÓN
  // ============================================

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    if (_categoriasAsignadas.isEmpty) {
      CustomAlert.mostrar(
        context,
        'Categorías requeridas',
        'Debes seleccionar al menos una categoría',
        Colors.orange,
      );
      return;
    }

    if (_fechaNacimiento == null) {
      CustomAlert.mostrar(
        context,
        'Fecha requerida',
        'Debes seleccionar una fecha de nacimiento',
        Colors.orange,
      );
      return;
    }

    final confirmar = await CustomAlert.confirmar(
      context,
      '¿Estás Seguro?',
      'Documento: ${_numeroDocumentoController.text}\n'
          'Nombre: ${_primerNombreController.text} ${_segundoNombreController.text} ${_primerApellidoController.text}\n'
          'Cargo: ${_cargoController.text}\n'
          'Años de Experiencia: ${_anosExperienciaController.text}',
      'Sí, actualizar',
      Colors.green,
    );

    if (!confirmar) return;

    setState(() => _loading = true);

    try {
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
        'FechaDeNacimiento': _fechaNacimiento!.toIso8601String().split('T')[0],
        'Genero': _generoSeleccionado,
        'Telefono': _telefonoController.text.trim(),
        'Direccion': _direccionController.text.trim(),
        'EpsSisben': _epsSisbenController.text.trim().isEmpty
            ? null
            : _epsSisbenController.text.trim(),
        'idTiposDeDocumentos': _tipoDocumentoSeleccionado,
      };

      if (_contrasenaController.text.isNotEmpty) {
        personaData['contrasena'] = _contrasenaController.text;
      }

      final entrenadorData = {
        'AnosDeExperiencia': int.parse(_anosExperienciaController.text),
        'Cargo': _cargoController.text.trim(),
        'categorias': _categoriasAsignadas,
      };

      await _controller.actualizarEntrenador(
        idPersona: _entrenadorSeleccionado!.idPersonas,
        idEntrenador: _entrenadorSeleccionado!.idEntrenadores,
        personaData: personaData,
        entrenadorData: entrenadorData,
      );

      if (mounted) {
        setState(() {
          _loading = false;
          _modoEdicion = false;
        });

        CustomAlert.mostrar(
          context,
          'Entrenador actualizado',
          'Los datos se actualizaron correctamente',
          Colors.green,
        );

        await _cargarDatosIniciales();
        _filtrarEntrenadores();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        CustomAlert.mostrar(context, 'Error', 'Error al actualizar: $e', Colors.red);
      }
    }
  }

  Future<void> _eliminarEntrenador() async {
    if (_entrenadorSeleccionado == null) {
      CustomAlert.mostrar(
        context,
        'No hay entrenador seleccionado',
        'Por favor selecciona un entrenador primero',
        Colors.orange,
      );
      return;
    }

    final confirmar = await CustomAlert.confirmar(
      context,
      '¿Estás seguro?',
      'Se eliminará el entrenador ${_entrenadorSeleccionado!.persona?.nombreCorto ?? ""}',
      'Sí, eliminar',
      Colors.red,
    );

    if (!confirmar) return;

    try {
      await _controller.eliminarEntrenador(
        _entrenadorSeleccionado!.idEntrenadores,
      );

      if (mounted) {
        CustomAlert.mostrar(
          context,
          'Entrenador eliminado',
          'El entrenador se eliminó correctamente',
          Colors.green,
        );

        setState(() {
          _entrenadorSeleccionado = null;
          _modoEdicion = false;
        });

        await _cargarDatosIniciales();
        _filtrarEntrenadores();
      }
    } catch (e) {
      CustomAlert.mostrar(context, 'Error', 'Error al eliminar: $e', Colors.red);
    }
  }

  // ============================================
  // HANDLERS DE BOTONES
  // ============================================

  void _onAgregarPressed() {
    Navigator.pushNamed(context, '/AgregarEntrenador');
  }

  void _onEditarPressed() {
    _activarEdicion();
  }

  void _onGuardarPressed() {
    _guardarCambios();
  }

  void _onEliminarPressed() {
    _eliminarEntrenador();
  }

  void _onCancelarPressed() {
    _cancelarEdicion();
  }

  // ============================================
  // DRAWER
  // ============================================

  Widget _buildDrawerItem(String title, IconData icon, String routeName) {
    return ListTile(
      leading: Icon(icon, color: Colors.red),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: () {
        Navigator.of(context).pop();
        
        if (routeName == '/Logout') {
          // Lógica de deslogueo
        } else if (ModalRoute.of(context)?.settings.name != routeName) {
          Navigator.of(context).pushNamed(routeName);
        }
      },
    );
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xffe63946))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SCORD - Perfil Entrenador',
          style: TextStyle(
            color: Color(0xffe63946),
            fontWeight: FontWeight.bold,
            fontSize: 18
          )
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xffe63946)),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.red),
              child: Text(
                'Menú de Navegación',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            _buildDrawerItem('Inicio', Icons.home, '/InicioAdmin'),
            _buildDrawerItem('Cronograma', Icons.calendar_month, '/Cronograma'),
            _buildDrawerItem('Perfil Jugador', Icons.person_pin, '/PerfilJugadorAdmin'),
            _buildDrawerItem('Estadísticas Jugadores', Icons.bar_chart, '/EstadisticasJugadores'),
            _buildDrawerItem('Perfil Entrenador', Icons.sports_gymnastics, '/PerfilEntrenadorAdmin'),
            _buildDrawerItem('Evaluar Jugadores', Icons.rule, '/EvaluarJugadores'),
            const Divider(),
            _buildDrawerItem('Cerrar Sesión', Icons.logout, '/Logout'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Botones de acción
          EntrenadorBotonesAccion(
            modoEdicion: _modoEdicion,
            loading: _loading,
            onAgregar: _onAgregarPressed,
            onEditar: _onEditarPressed,
            onEliminar: _onEliminarPressed,
            onGuardar: _onGuardarPressed,
            onCancelar: _onCancelarPressed,
          ),

          // Contenido principal
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Selector de entrenador
                    SelectorEntrenadorCard(
                      categorias: _categorias,
                      entrenadoresFiltrados: _entrenadoresFiltrados,
                      categoriaSeleccionada: _categoriaSeleccionada,
                      entrenadorSeleccionado: _entrenadorSeleccionado,
                      modoEdicion: _modoEdicion,
                      onCategoriaChanged: (value) {
                        setState(() => _categoriaSeleccionada = value);
                        _filtrarEntrenadores();
                      },
                      onEntrenadorChanged: (value) {
                        setState(() {
                          _entrenadorSeleccionado = _entrenadores.firstWhere(
                            (ent) => ent.idEntrenadores == value,
                          );
                          _modoEdicion = false;
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    // Información de contacto
                    if (_entrenadorSeleccionado?.persona != null)
                      _buildInformacionContacto(),
                    
                    const SizedBox(height: 12),

                    // Información personal
                    if (_entrenadorSeleccionado?.persona != null)
                      _buildInformacionPersonal(),
                    
                    const SizedBox(height: 12),

                    // Información deportiva
                    if (_entrenadorSeleccionado != null)
                      _buildInformacionDeportiva(),
                    
                    const SizedBox(height: 12),

                    // Campo de contraseña en modo edición
                    if (_modoEdicion) _buildCampoContrasena(),
                  ],
                ),
              ),
            ),
          ),
        ],
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

  // ============================================
  // WIDGETS BUILDERS
  // ============================================

  Widget _buildInformacionContacto() {
    final persona = _entrenadorSeleccionado!.persona!;

    return EntrenadorInfoCard(
      title: 'Información de Contacto',
      icon: Icons.contact_phone,
      children: [
        InfoRow(
          label: '📞 Teléfono:',
          value: persona.telefono,
          isEditing: _modoEdicion,
          editWidget: TextFormField(
            controller: _telefonoController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            ),
            style: const TextStyle(fontSize: 13),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Campo obligatorio';
              }
              if (!RegExp(r'^3\d{9}$').hasMatch(value)) {
                return 'Debe iniciar con 3 y tener 10 dígitos';
              }
              return null;
            },
          ),
        ),
        InfoRow(
          label: '📍 Dirección:',
          value: persona.direccion,
          isEditing: _modoEdicion,
          editWidget: TextFormField(
            controller: _direccionController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            ),
            style: const TextStyle(fontSize: 13),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Campo obligatorio';
              }
              return null;
            },
          ),
        ),
        InfoRow(
          label: '📧 Email:',
          value: persona.correo,
          isEditing: _modoEdicion,
          editWidget: TextFormField(
            controller: _correoController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            ),
            style: const TextStyle(fontSize: 13),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Campo obligatorio';
              }
              if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                return 'Correo inválido';
              }
              return null;
            },
          ),
        ),
        InfoRow(
          label: '🏥 EPS:',
          value: persona.epsSisben ?? '-',
          isEditing: _modoEdicion,
          editWidget: TextFormField(
            controller: _epsSisbenController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            ),
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildInformacionPersonal() {
    final persona = _entrenadorSeleccionado!.persona!;

    return EntrenadorInfoCard(
      title: 'Información Personal',
      icon: Icons.person,
      children: [
        InfoRow(
          label: 'Nombres:',
          value: '${persona.nombre1} ${persona.nombre2 ?? ''}'.trim(),
          isEditing: _modoEdicion,
          editWidget: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _primerNombreController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    labelText: 'Primer',
                    labelStyle: TextStyle(fontSize: 11),
                    contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  ),
                  style: const TextStyle(fontSize: 13),
                  validator: (value) =>
                      value?.trim().isEmpty ?? true ? 'Obligatorio' : null,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: TextFormField(
                  controller: _segundoNombreController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    labelText: 'Segundo',
                    labelStyle: TextStyle(fontSize: 11),
                    contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        InfoRow(
          label: 'Apellidos:',
          value: '${persona.apellido1} ${persona.apellido2 ?? ''}'.trim(),
          isEditing: _modoEdicion,
          editWidget: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _primerApellidoController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    labelText: 'Primer',
                    labelStyle: TextStyle(fontSize: 11),
                    contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  ),
                  style: const TextStyle(fontSize: 13),
                  validator: (value) =>
                      value?.trim().isEmpty ?? true ? 'Obligatorio' : null,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: TextFormField(
                  controller: _segundoApellidoController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    labelText: 'Segundo',
                    labelStyle: TextStyle(fontSize: 11),
                    contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        InfoRow(
          label: 'Edad:',
          value: persona.edad?.toString() ?? '-',
          isEditing: false,
        ),
        InfoRow(
          label: 'Fecha de Nacimiento:',
          value: DateFormat('dd/MM/yyyy').format(persona.fechaDeNacimiento),
          isEditing: _modoEdicion,
          editWidget: InkWell(
            onTap: () async {
              final fecha = await showDatePicker(
                context: context,
                initialDate: _fechaNacimiento ?? DateTime.now(),
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
              );
              if (fecha != null) setState(() => _fechaNacimiento = fecha);
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              ),
              child: Text(
                _fechaNacimiento != null
                    ? DateFormat('dd/MM/yyyy').format(_fechaNacimiento!)
                    : 'Seleccionar fecha',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
        ),
        InfoRow(
          label: 'Documento:',
          value: persona.numeroDeDocumento,
          isEditing: _modoEdicion,
          editWidget: TextFormField(
            controller: _numeroDocumentoController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            ),
            style: const TextStyle(fontSize: 13),
            keyboardType: TextInputType.number,
            validator: (value) =>
                value?.trim().isEmpty ?? true ? 'Campo obligatorio' : null,
          ),
        ),
        InfoRow(
          label: 'Tipo de Documento:',
          value: persona.tiposDeDocumentos?.descripcion ?? '-',
          isEditing: _modoEdicion,
          editWidget: DropdownButtonFormField<int>(
            value: _tipoDocumentoSeleccionado,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            ),
            style: const TextStyle(fontSize: 13, color: Colors.black),
            items: _tiposDocumento.map((tipo) {
              return DropdownMenuItem(
                value: tipo.idTiposDeDocumentos,
                child: Text(tipo.descripcion),
              );
            }).toList(),
            onChanged: (value) =>
                setState(() => _tipoDocumentoSeleccionado = value),
            validator: (value) => value == null ? 'Selecciona un tipo' : null,
          ),
        ),
        InfoRow(
          label: 'Género:',
          value: persona.genero == 'M' ? 'Masculino' : 'Femenino',
          isEditing: _modoEdicion,
          editWidget: DropdownButtonFormField<String>(
            value: _generoSeleccionado,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            ),
            style: const TextStyle(fontSize: 13, color: Colors.black),
            items: const [
              DropdownMenuItem(value: 'M', child: Text('Masculino')),
              DropdownMenuItem(value: 'F', child: Text('Femenino')),
            ],
            onChanged: (value) => setState(() => _generoSeleccionado = value),
            validator: (value) => value == null ? 'Selecciona un género' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildInformacionDeportiva() {
    return EntrenadorInfoCard(
      title: 'Información Deportiva',
      icon: Icons.sports_soccer,
      children: [
        InfoRow(
          label: '⏱️ Años de Experiencia:',
          value: _entrenadorSeleccionado!.anosDeExperiencia.toString(),
          isEditing: _modoEdicion,
          editWidget: TextFormField(
            controller: _anosExperienciaController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            ),
            style: const TextStyle(fontSize: 13),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value?.trim().isEmpty ?? true) return 'Campo obligatorio';
              final anos = int.tryParse(value!);
              if (anos == null || anos < 0 || anos > 50) {
                return 'Debe estar entre 0 y 50';
              }
              return null;
            },
          ),
        ),
        InfoRow(
          label: '👔 Cargo:',
          value: _entrenadorSeleccionado!.cargo,
          isEditing: _modoEdicion,
          editWidget: TextFormField(
            controller: _cargoController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            ),
            style: const TextStyle(fontSize: 13),
validator: (value) =>
value?.trim().isEmpty ?? true ? 'Campo obligatorio' : null,
),
),
InfoRow(
label: '⚽ Categorías:',
value: _entrenadorSeleccionado!.categorias != null &&
_entrenadorSeleccionado!.categorias!.isNotEmpty
? _entrenadorSeleccionado!.categorias!
.map((c) => c.descripcion)
.join(', ')
: '-',
isEditing: _modoEdicion,
editWidget: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: _categorias.map((cat) {
return CheckboxListTile(
title: Text(
cat.descripcion,
style: const TextStyle(fontSize: 13),
),
value: _categoriasAsignadas.contains(cat.idCategorias),
dense: true,
contentPadding: EdgeInsets.zero,
onChanged: (value) {
setState(() {
if (value == true) {
_categoriasAsignadas.add(cat.idCategorias);
} else {
_categoriasAsignadas.remove(cat.idCategorias);
}
});
},
);
}).toList(),
),
),
],
);
}
Widget _buildCampoContrasena() {
return Card(
color: Colors.blue[50],
elevation: 3,
child: Padding(
padding: const EdgeInsets.all(14.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'🔒 Contraseña: Dejar vacío si no deseas cambiarla',
style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
),
const SizedBox(height: 8),
TextFormField(
controller: _contrasenaController,
decoration: const InputDecoration(
border: OutlineInputBorder(),
hintText: 'Nueva contraseña (8-12 caracteres)',
isDense: true,
contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
),
style: const TextStyle(fontSize: 13),
obscureText: true,
validator: (value) {
if (value != null &&
value.isNotEmpty &&
(value.length < 8 || value.length > 12)) {
return 'Debe tener entre 8 y 12 caracteres';
}
return null;
},
),
],
),
),
);
}
}