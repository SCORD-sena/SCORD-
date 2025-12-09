import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/entrenador_model.dart';
import '../../models/categoria_model.dart';
import '../../models/tipo_documento_model.dart';
import '../../controllers/admin/entrenador_controller.dart';
import '../../widgets/admin/perfil_entrenador/entrenador_info_card.dart';
import '../../widgets/common/info_row.dart';
import '../../widgets/common/custom_button.dart';

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
        _mostrarError('Error al cargar datos: $e');
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
      _mostrarAdvertencia(
        'No hay entrenador seleccionado',
        'Por favor selecciona un entrenador primero',
      );
      return;
    }

    final persona = _entrenadorSeleccionado!.persona;
    if (persona == null) {
      _mostrarError('Error: No se encontró la información de la persona');
      return;
    }

    final categoriasIds = _entrenadorSeleccionado!.categorias
        ?.map((c) => c.idCategorias)
        .toList() ??
    [];
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
      _mostrarAdvertencia(
        'Categorías requeridas',
        'Debes seleccionar al menos una categoría',
      );
      return;
    }

    if (_fechaNacimiento == null) {
      _mostrarAdvertencia(
        'Fecha requerida',
        'Debes seleccionar una fecha de nacimiento',
      );
      return;
    }

    final confirmar = await _mostrarConfirmacion(
      '¿Estás Seguro?',
      'Documento: ${_numeroDocumentoController.text}\n'
          'Nombre: ${_primerNombreController.text} ${_segundoNombreController.text} ${_primerApellidoController.text}\n'
          'Cargo: ${_cargoController.text}\n'
          'Años de Experiencia: ${_anosExperienciaController.text}',
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

        _mostrarExito(
          'Entrenador actualizado',
          'Los datos se actualizaron correctamente',
        );

        await _cargarDatosIniciales();
        _filtrarEntrenadores();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        _mostrarError('Error al actualizar: $e');
      }
    }
  }

  Future<void> _eliminarEntrenador() async {
    if (_entrenadorSeleccionado == null) {
      _mostrarAdvertencia(
        'No hay entrenador seleccionado',
        'Por favor selecciona un entrenador primero',
      );
      return;
    }

    final confirmar = await _mostrarConfirmacion(
      '¿Estás seguro?',
      'Se eliminará el entrenador ${_entrenadorSeleccionado!.persona?.nombreCorto ?? ""}',
    );

    if (!confirmar) return;

    try {
      await _controller.eliminarEntrenador(
        _entrenadorSeleccionado!.idEntrenadores,
      );

      if (mounted) {
        _mostrarExito(
          'Entrenador eliminado',
          'El entrenador se eliminó correctamente',
        );

        setState(() {
          _entrenadorSeleccionado = null;
          _modoEdicion = false;
        });

        await _cargarDatosIniciales();
        _filtrarEntrenadores();
      }
    } catch (e) {
      _mostrarError('Error al eliminar: $e');
    }
  }

  // ============================================
  // MÉTODOS DE DIÁLOGOS
  // ============================================

  Future<bool> _mostrarConfirmacion(String titulo, String mensaje) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(titulo),
            content: Text(mensaje),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Confirmar'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _mostrarExito(String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Expanded(child: Text(titulo)),
          ],
        ),
        content: Text(mensaje),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _mostrarError(String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(mensaje),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _mostrarAdvertencia(String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.orange),
            const SizedBox(width: 8),
            Expanded(child: Text(titulo)),
          ],
        ),
        content: Text(mensaje),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil Entrenador'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Botones de acción
              _buildBotonesAccion(),
              const SizedBox(height: 24),

              // Selectores y foto
              _buildSelectoresYFoto(),
              const SizedBox(height: 24),

              // Información de contacto
              if (_entrenadorSeleccionado?.persona != null)
                _buildInformacionContacto(),
              const SizedBox(height: 16),

              // Información personal
              if (_entrenadorSeleccionado?.persona != null)
                _buildInformacionPersonal(),
              const SizedBox(height: 16),

              // Información deportiva
              if (_entrenadorSeleccionado != null) _buildInformacionDeportiva(),
              const SizedBox(height: 16),

              // Campo de contraseña en modo edición
              if (_modoEdicion) _buildCampoContrasena(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // WIDGETS BUILDERS
  // ============================================

  Widget _buildBotonesAccion() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        CustomButton(
          text: 'Agregar Entrenador',
          onPressed: () {
            Navigator.pushNamed(context, '/agregar-entrenador');
          },
          backgroundColor: Colors.green,
          icon: Icons.add,
        ),
        if (!_modoEdicion) ...[
          CustomButton(
            text: 'Editar',
            onPressed: _activarEdicion,
            backgroundColor: Colors.orange,
            icon: Icons.edit,
          ),
          CustomButton(
            text: 'Eliminar',
            onPressed: _eliminarEntrenador,
            backgroundColor: Colors.red,
            icon: Icons.delete,
          ),
        ] else ...[
          CustomButton(
            text: 'Guardar',
            onPressed: _guardarCambios,
            backgroundColor: Colors.green,
            isLoading: _loading,
            icon: Icons.save,
          ),
          CustomButton(
            text: 'Cancelar',
            onPressed: _cancelarEdicion,
            backgroundColor: Colors.grey,
            icon: Icons.cancel,
          ),
        ],
      ],
    );
  }

  Widget _buildSelectoresYFoto() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selector de categoría
            const Text(
              'Seleccionar Categoría:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _categoriaSeleccionada,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              hint: const Text('-- Selecciona una categoría --'),
              items: _categorias.map((cat) {
                return DropdownMenuItem(
                  value: cat.idCategorias,
                  child: Text(cat.descripcion),
                );
              }).toList(),
              onChanged: _modoEdicion
                  ? null
                  : (value) {
                      setState(() => _categoriaSeleccionada = value);
                      _filtrarEntrenadores();
                    },
            ),
            const SizedBox(height: 16),

            // Selector de entrenador
            const Text(
              'Seleccionar Entrenador:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _entrenadorSeleccionado?.idEntrenadores,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              hint: const Text('-- Selecciona un entrenador --'),
              items: _entrenadoresFiltrados.map((ent) {
                return DropdownMenuItem(
                  value: ent.idEntrenadores,
                  child: Text(ent.persona?.nombreCorto ?? 'Sin nombre'),
                );
              }).toList(),
              onChanged: _categoriaSeleccionada == null || _modoEdicion
                  ? null
                  : (value) {
                      setState(() {
                        _entrenadorSeleccionado = _entrenadores.firstWhere(
                          (ent) => ent.idEntrenadores == value,
                        );
                        _modoEdicion = false;
                      });
                    },
            ),
            const SizedBox(height: 20),

            // Foto de perfil
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.person, size: 60, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInformacionContacto() {
    final persona = _entrenadorSeleccionado!.persona!;

    return EntrenadorInfoCard(
      title: 'Información de Contacto',
      icon: Icons.contact_phone,
      children: [
        InfoRow(
          label: 'Teléfono:',
          value: persona.telefono,
          isEditing: _modoEdicion,
          editWidget: TextFormField(
            controller: _telefonoController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
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
          label: 'Dirección:',
          value: persona.direccion,
          isEditing: _modoEdicion,
          editWidget: TextFormField(
            controller: _direccionController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Campo obligatorio';
              }
              return null;
            },
          ),
        ),
        InfoRow(
          label: 'Email:',
          value: persona.correo,
          isEditing: _modoEdicion,
          editWidget: TextFormField(
            controller: _correoController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
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
          label: 'EPS:',
          value: persona.epsSisben ?? '-',
          isEditing: _modoEdicion,
          editWidget: TextFormField(
            controller: _epsSisbenController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
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
                  ),
                  validator: (value) =>
                      value?.trim().isEmpty ?? true ? 'Obligatorio' : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _segundoNombreController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    labelText: 'Segundo',
                  ),
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
                  ),
                  validator: (value) =>
                      value?.trim().isEmpty ?? true ? 'Obligatorio' : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _segundoApellidoController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    labelText: 'Segundo',
                  ),
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
              ),
              child: Text(
                _fechaNacimiento != null
                    ? DateFormat('dd/MM/yyyy').format(_fechaNacimiento!)
                    : 'Seleccionar fecha',
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
            ),
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
            ),
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
            ),
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
          label: 'Años de Experiencia:',
          value: _entrenadorSeleccionado!.anosDeExperiencia.toString(),
          isEditing: _modoEdicion,
          editWidget: TextFormField(
            controller: _anosExperienciaController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
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
          label: 'Cargo:',
          value: _entrenadorSeleccionado!.cargo,
          isEditing: _modoEdicion,
          editWidget: TextFormField(
            controller: _cargoController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
            validator: (value) =>
                value?.trim().isEmpty ??
                                value?.trim().isEmpty ?? true ? 'Campo obligatorio' : null,
          ),
        ),
        InfoRow(
  label: 'Categorías:',
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
        title: Text(cat.descripcion),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contraseña: Dejar vacío si no deseas cambiarla',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _contrasenaController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Nueva contraseña (8-12 caracteres)',
                isDense: true,
              ),
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