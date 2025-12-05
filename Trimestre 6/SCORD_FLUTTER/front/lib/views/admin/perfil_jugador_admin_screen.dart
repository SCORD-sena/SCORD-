import 'package:flutter/material.dart';
import '../../models/jugador_model.dart'; 
import '../../models/categoria_model.dart';
import '../../models/tipo_documento_model.dart';
import '../../models/persona_model.dart';
import '../../services/jugador_service.dart';
import '../../utils/validator.dart';

class PerfilJugadorAdminScreen extends StatefulWidget {
  const PerfilJugadorAdminScreen({super.key});

  @override
  State<PerfilJugadorAdminScreen> createState() => _PerfilJugadorAdminScreenState();
}

class _PerfilJugadorAdminScreenState extends State<PerfilJugadorAdminScreen> {
  final JugadorService _jugadorService = JugadorService();
  
  List<Jugador> _jugadores = [];
  List<Categoria> _categorias = [];
  List<TipoDocumento> _tiposDocumento = [];
  String? _categoriaSeleccionada;
  Jugador? _jugadorSeleccionado;
  List<Jugador> _jugadoresFiltrados = [];
  bool _modoEdicion = false;
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  late Map<String, TextEditingController> _controllers;
  int? _selectedTipoDocumentoId;
  String? _selectedGenero;
  int? _selectedCategoriaId;
  DateTime? _selectedFechaNacimiento;
  
  @override
  void initState() {
    super.initState();
    _controllers = _initializeControllers();
    _fetchInitialData();
  }
  
  Map<String, TextEditingController> _initializeControllers() {
    return {
      'numeroDocumento': TextEditingController(), 'tipoDocumento': TextEditingController(),
      'primerNombre': TextEditingController(), 'segundoNombre': TextEditingController(),
      'primerApellido': TextEditingController(), 'segundoApellido': TextEditingController(),
      'genero': TextEditingController(), 'telefono': TextEditingController(),
      'direccion': TextEditingController(), 'fechaNacimiento': TextEditingController(),
      'correo': TextEditingController(), 'contrasena': TextEditingController(),
      'epsSisben': TextEditingController(), 'dorsal': TextEditingController(),
      'posicion': TextEditingController(), 'estatura': TextEditingController(),
      'upz': TextEditingController(), 'categoria': TextEditingController(),
      'nomTutor1': TextEditingController(), 'nomTutor2': TextEditingController(),
      'apeTutor1': TextEditingController(), 'apeTutor2': TextEditingController(),
      'telefonoTutor': TextEditingController(),
    };
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _filterJugadores() {
    if (_categoriaSeleccionada == null || _categoriaSeleccionada!.isEmpty) {
      setState(() {
        _jugadoresFiltrados = [];
        _jugadorSeleccionado = null;
        _modoEdicion = false;
      });
      return;
    }
    final int categoriaId = int.tryParse(_categoriaSeleccionada!) ?? 0;
    final filtrados = _jugadores.where((j) => j.idCategorias == categoriaId).toList();
    setState(() {
      _jugadoresFiltrados = filtrados;
      _jugadorSeleccionado = null;
      _modoEdicion = false;
    });
  }
  
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _fetchInitialData() async {
    setState(() => _loading = true);
    try {
      final jugadores = _jugadorService.fetchJugadores();
      final categorias = _jugadorService.fetchCategorias();
      final tiposDocumento = _jugadorService.fetchTiposDocumento();
      final results = await Future.wait([jugadores, categorias, tiposDocumento]);
      
      setState(() {
        _jugadores = results[0] as List<Jugador>;
        _categorias = results[1] as List<Categoria>;
        _tiposDocumento = results[2] as List<TipoDocumento>;
      });
    } catch (e) {
      _showSnackBar('Error al cargar datos iniciales: ${e.toString()}', isError: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _activarEdicion() {
    if (_jugadorSeleccionado == null) {
      _showSnackBar('Por favor selecciona un jugador primero', isError: true);
      return;
    }

    final persona = _jugadorSeleccionado!.persona;

    _controllers['numeroDocumento']!.text = persona.numeroDeDocumento;
    _controllers['primerNombre']!.text = persona.nombre1;
    _controllers['segundoNombre']!.text = persona.nombre2 ?? '';
    _controllers['primerApellido']!.text = persona.apellido1;
    _controllers['segundoApellido']!.text = persona.apellido2 ?? '';
    _controllers['telefono']!.text = persona.telefono;
    _controllers['direccion']!.text = persona.direccion;
    _controllers['correo']!.text = persona.correo;
    _controllers['contrasena']!.text = '';
    _controllers['epsSisben']!.text = persona.epsSisben ?? '';
    _controllers['dorsal']!.text = _jugadorSeleccionado!.dorsal.toString();
    _controllers['posicion']!.text = _jugadorSeleccionado!.posicion;
    _controllers['estatura']!.text = _jugadorSeleccionado!.estatura.toString();
    _controllers['upz']!.text = _jugadorSeleccionado!.upz ?? '';
    _controllers['nomTutor1']!.text = _jugadorSeleccionado!.nomTutor1;
    _controllers['nomTutor2']!.text = _jugadorSeleccionado!.nomTutor2 ?? '';
    _controllers['apeTutor1']!.text = _jugadorSeleccionado!.apeTutor1;
    _controllers['apeTutor2']!.text = _jugadorSeleccionado!.apeTutor2 ?? '';
    _controllers['telefonoTutor']!.text = _jugadorSeleccionado!.telefonoTutor;

    _selectedTipoDocumentoId = persona.idTiposDeDocumentos;
    _selectedGenero = persona.genero;
    _selectedCategoriaId = _jugadorSeleccionado!.idCategorias;
    _selectedFechaNacimiento = persona.fechaDeNacimiento;
    _controllers['fechaNacimiento']!.text = _selectedFechaNacimiento?.toIso8601String().split('T')[0] ?? '';

    setState(() {
      _modoEdicion = true;
    });
  }

  void _cancelarEdicion() {
    setState(() {
      _modoEdicion = false;
    });
  }
  
  Future<void> _guardarCambios() async {
    final validationMessages = _validateForm().toSet().toList();
    if (validationMessages.isNotEmpty) {
      _showSnackBar(validationMessages.join('\n'), isError: true);
      return;
    }
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Estás Seguro?'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              const Text('¿Desea actualizar los datos del jugador seleccionado?'),
              const Divider(),
              Text('Documento: ${_controllers['numeroDocumento']!.text}'),
              Text('Nombre: ${_controllers['primerNombre']!.text} ${_controllers['primerApellido']!.text}'),
              Text('Dorsal: ${_controllers['dorsal']!.text} — Posición: ${_controllers['posicion']!.text}'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(context).pop(false), 
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => Navigator.of(context).pop(true), 
            child: const Text('Sí, actualizar'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _loading = true);
    try {
      final personaData = Persona(
        idPersonas: _jugadorSeleccionado!.persona.idPersonas, 
        numeroDeDocumento: _controllers['numeroDocumento']!.text,
        idTiposDeDocumentos: _selectedTipoDocumentoId!,
        nombre1: _controllers['primerNombre']!.text,
        nombre2: _controllers['segundoNombre']!.text.isEmpty ? null : _controllers['segundoNombre']!.text,
        apellido1: _controllers['primerApellido']!.text,
        apellido2: _controllers['segundoApellido']!.text.isEmpty ? null : _controllers['segundoApellido']!.text,
        genero: _selectedGenero!,
        telefono: _controllers['telefono']!.text,
        direccion: _controllers['direccion']!.text,
        fechaDeNacimiento: _selectedFechaNacimiento!,
        correo: _controllers['correo']!.text,
        epsSisben: _controllers['epsSisben']!.text.isEmpty ? null : _controllers['epsSisben']!.text,
      );
      await _jugadorService.updatePersona(
        _jugadorSeleccionado!.persona.idPersonas, 
        personaData, 
        contrasena: _controllers['contrasena']!.text.isNotEmpty ? _controllers['contrasena']!.text : null
      );
      final jugadorData = Jugador(
        idJugadores: _jugadorSeleccionado!.idJugadores,
        idPersonas: _jugadorSeleccionado!.idPersonas,
        dorsal: int.parse(_controllers['dorsal']!.text),
        posicion: _controllers['posicion']!.text,
        upz: _controllers['upz']!.text.isEmpty ? null : _controllers['upz']!.text,
        estatura: double.parse(_controllers['estatura']!.text),
        nomTutor1: _controllers['nomTutor1']!.text,
        nomTutor2: _controllers['nomTutor2']!.text.isEmpty ? null : _controllers['nomTutor2']!.text,
        apeTutor1: _controllers['apeTutor1']!.text,
        apeTutor2: _controllers['apeTutor2']!.text.isEmpty ? null : _controllers['apeTutor2']!.text,
        telefonoTutor: _controllers['telefonoTutor']!.text,
        idCategorias: _selectedCategoriaId!,
        persona: personaData, 
      );
      await _jugadorService.updateJugador(_jugadorSeleccionado!.idJugadores, jugadorData);

      _showSnackBar('Los datos se actualizaron correctamente.');

      setState(() {
        _modoEdicion = false;
      });
      await _fetchInitialData();
      _filterJugadores();

    } catch (e) {
      _showSnackBar('Error: ${e.toString().replaceAll('Exception: ', '')}', isError: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  List<String> _validateForm() {
    final List<String> errors = [];
    
    if (_controllers['numeroDocumento']!.text.isEmpty) {
        errors.add('El número de documento es obligatorio.');
    }
    
    if (_formKey.currentState?.validate() == false) {
      errors.add('Hay errores en los campos marcados.');
    }

    return errors.toSet().toList();
  }

  Future<void> _eliminarJugador() async {
    if (_jugadorSeleccionado == null) {
      _showSnackBar('Por favor selecciona un jugador primero', isError: true);
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Estás seguro?'),
        content: const Text('Se eliminará el jugador. Esta acción es irreversible.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar', style: TextStyle(color: Colors.green)),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sí, eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    try {
      await _jugadorService.deleteJugador(_jugadorSeleccionado!.idJugadores);
      
      _showSnackBar('El jugador se eliminó correctamente');
      setState(() {
        _jugadorSeleccionado = null;
        _modoEdicion = false;
      });
      await _fetchInitialData();
      _filterJugadores();

    } catch (e) {
      _showSnackBar('Error: No se pudo eliminar el jugador', isError: true);
    }
  }

  String _calcularEdad(DateTime? fechaNacimiento) {
    if (fechaNacimiento == null) return "-";
    final hoy = DateTime.now();
    int edad = hoy.year - fechaNacimiento.year;
    final mes = hoy.month - fechaNacimiento.month;
    if (mes < 0 || (mes == 0 && hoy.day < fechaNacimiento.day)) {
      edad--;
    }
    return edad.toString();
  }

  Widget _buildInfoDisplay(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Color(0xffe63946),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title, IconData icon, String routeName) {
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

  @override
  Widget build(BuildContext context) {
    final persona = _jugadorSeleccionado?.persona;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SCORD - Perfil Jugador',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.red),
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
            _buildDrawerItem(context, 'Inicio', Icons.home, '/InicioAdmin'),
            _buildDrawerItem(context, 'Cronograma', Icons.calendar_month, '/Cronograma'),
            _buildDrawerItem(context, 'Perfil Jugador', Icons.person_pin, '/PerfilJugadorAdmin'),
            _buildDrawerItem(context, 'Estadísticas Jugadores', Icons.bar_chart, '/EstadisticasJugadores'),
            _buildDrawerItem(context, 'Perfil Entrenador', Icons.sports_gymnastics, '/PerfilEntrenador'),
            _buildDrawerItem(context, 'Evaluar Jugadores', Icons.rule, '/EvaluarJugadores'),
            const Divider(),
            _buildDrawerItem(context, 'Cerrar Sesión', Icons.logout, '/Logout'),
          ],
        ),
      ),
      
      body: _loading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(12.0),
            child: Form( 
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Botones compactos
                  Wrap(
                    spacing: 6.0,
                    runSpacing: 6.0,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/AgregarJugador');
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Agregar', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: const Size(0, 36),
                        ),
                      ),
                      
                      if (!_modoEdicion) ...[
                        ElevatedButton.icon(
                          onPressed: _activarEdicion,
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Editar', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: const Size(0, 36),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _eliminarJugador,
                          icon: const Icon(Icons.delete, size: 16),
                          label: const Text('Eliminar', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: const Size(0, 36),
                          ),
                        ),
                      ] else ...[
                        ElevatedButton.icon(
                          onPressed: _guardarCambios,
                          icon: const Icon(Icons.save, size: 16),
                          label: const Text('Guardar', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: const Size(0, 36),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _cancelarEdicion,
                          icon: const Icon(Icons.cancel, size: 16),
                          label: const Text('Cancelar', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: const Size(0, 36),
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  const SizedBox(height: 16),

                  // Dropdowns y foto
                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Seleccionar Categoría',
                              labelStyle: TextStyle(fontSize: 13),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            style: const TextStyle(fontSize: 13, color: Colors.black),
                            value: _categoriaSeleccionada,
                            hint: const Text('-- Selecciona categoría --'),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('-- Selecciona categoría --')),
                              ..._categorias.map((cat) => DropdownMenuItem(
                                value: cat.idCategorias.toString(),
                                child: Text(cat.descripcion),
                              )).toList(),
                            ],
                            onChanged: _modoEdicion ? null : (value) {
                              setState(() {
                                _categoriaSeleccionada = value;
                                _filterJugadores();
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                              labelText: 'Seleccionar Jugador',
                              labelStyle: TextStyle(fontSize: 13),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            style: const TextStyle(fontSize: 13, color: Colors.black),
                            value: _jugadorSeleccionado?.idJugadores,
                            hint: const Text('-- Selecciona jugador --'),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('-- Selecciona jugador --')),
                              ..._jugadoresFiltrados.map((jug) => DropdownMenuItem(
                                value: jug.idJugadores,
                                child: Text('${jug.persona.nombre1} ${jug.persona.apellido1}'),
                              )).toList(),
                            ],
                            onChanged: _categoriaSeleccionada == null || _modoEdicion ? null : (value) {
                              setState(() {
                                _jugadorSeleccionado = _jugadores.firstWhere((j) => j.idJugadores == value);
                                _modoEdicion = false;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          ClipOval(
                            child: Image.asset(
                              'assets/Foto_Perfil.webp',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Información Personal
                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('👤 Información Personal'),
                          if (!_modoEdicion) ...[
                            _buildInfoDisplay('Nombres:', '${persona?.nombre1 ?? ''} ${persona?.nombre2 ?? ''}'.trim().isEmpty ? '-' : '${persona?.nombre1 ?? ''} ${persona?.nombre2 ?? ''}'),
                            _buildInfoDisplay('Apellidos:', '${persona?.apellido1 ?? ''} ${persona?.apellido2 ?? ''}'.trim().isEmpty ? '-' : '${persona?.apellido1 ?? ''} ${persona?.apellido2 ?? ''}'),
                            _buildInfoDisplay('Edad:', _calcularEdad(persona?.fechaDeNacimiento)),
                            _buildInfoDisplay('Fecha de Nacimiento:', persona?.fechaDeNacimiento != null ? '${persona!.fechaDeNacimiento.day.toString().padLeft(2, '0')}/${persona.fechaDeNacimiento.month.toString().padLeft(2, '0')}/${persona.fechaDeNacimiento.year}' : '-'),
                            _buildInfoDisplay('Documento:', persona?.numeroDeDocumento ?? '-'),
                            _buildInfoDisplay('Tipo de Documento:', persona?.tiposDeDocumentos?.descripcion ?? '-'),
                            _buildInfoDisplay('Género:', persona?.genero == 'M' ? 'Masculino' : persona?.genero == 'F' ? 'Femenino' : '-'),
                          ] else ...[
                            _buildNameField(),
                            const SizedBox(height: 8),
                            _buildApellidoField(),
                            const SizedBox(height: 8),
                            _buildDateField('fechaNacimiento'),
                            const SizedBox(height: 8),
                            _buildEditableField('numeroDocumento', 'Documento', validator: (v) => Validator.validateRequired(v, 'Número de Documento')),
                            const SizedBox(height: 8),
                            _buildTipoDocumentoDropdown(),
                            const SizedBox(height: 8),
                            _buildGeneroDropdown(),
                            const SizedBox(height: 8),
                            _buildEditableField('contrasena', 'Contraseña (Opcional)', isOptional: true, isPassword: true, validator: Validator.validateContrasena),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Información de Contacto
                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('📞 Información de Contacto'),
                          if (!_modoEdicion) ...[
                            _buildInfoDisplay('Teléfono:', persona?.telefono ?? '-'),
                            _buildInfoDisplay('Dirección:', persona?.direccion ?? '-'),
                            _buildInfoDisplay('Email:', persona?.correo ?? '-'),
                            _buildInfoDisplay('EPS:', persona?.epsSisben ?? '-'),
                          ] else ...[
                            _buildEditableField('telefono', 'Teléfono', keyboardType: TextInputType.phone, validator: (v) => Validator.validateTelefono(v, 'Teléfono')),
                            const SizedBox(height: 8),
                            _buildEditableField('direccion', 'Dirección', validator: (v) => Validator.validateRequired(v, 'Dirección')),
                            const SizedBox(height: 8),
                            _buildEditableField('correo', 'Email', keyboardType: TextInputType.emailAddress, validator: Validator.validateCorreo),
                            const SizedBox(height: 8),
                            _buildEditableField('epsSisben', 'EPS/Sisbén', isOptional: true),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Información de Tutores
                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('👨‍👩‍👦 Información de Tutores'),
                          if (!_modoEdicion) ...[
                            _buildInfoDisplay('Nombre del Tutor:', '${_jugadorSeleccionado?.nomTutor1 ?? ''} ${_jugadorSeleccionado?.apeTutor1 ?? ''}'.trim().isEmpty ? '-' : '${_jugadorSeleccionado?.nomTutor1 ?? ''} ${_jugadorSeleccionado?.apeTutor1 ?? ''}'),
                            _buildInfoDisplay('Teléfono del Tutor:', _jugadorSeleccionado?.telefonoTutor ?? '-'),
                          ] else ...[
                            _buildTutorNameField(),
                            const SizedBox(height: 8),
                            _buildEditableField('telefonoTutor', 'Teléfono Tutor', keyboardType: TextInputType.phone, validator: (v) => Validator.validateTelefono(v, 'Teléfono del Tutor')),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Información Deportiva
                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('⚽ Información Deportiva'),
                          if (!_modoEdicion) ...[
                            _buildInfoDisplay('Dorsal:', _jugadorSeleccionado?.dorsal.toString() ?? '-'),
                            _buildInfoDisplay('Posición:', _jugadorSeleccionado?.posicion ?? '-'),
                            _buildInfoDisplay('Estatura:', _jugadorSeleccionado != null ? '${_jugadorSeleccionado!.estatura} cm' : '-'),
                            _buildInfoDisplay('UPZ:', _jugadorSeleccionado?.upz ?? '-'),
                            _buildInfoDisplay('Categoría:', _categorias.firstWhere((c) => c.idCategorias == _jugadorSeleccionado?.idCategorias, orElse: () => Categoria(idCategorias: 0, descripcion: '-')).descripcion),
                          ] else ...[
                            _buildEditableField('dorsal', 'Dorsal', keyboardType: TextInputType.number, validator: Validator.validateDorsal),
                            const SizedBox(height: 8),
                            _buildEditableField('posicion', 'Posición', validator: (v) => Validator.validateRequired(v, 'Posición')),
                            const SizedBox(height: 8),
                            _buildEditableField('estatura', 'Estatura (cm)', keyboardType: TextInputType.number, validator: Validator.validateEstatura),
                            const SizedBox(height: 8),
                            _buildEditableField('upz', 'UPZ (Opcional)', isOptional: true),
                            const SizedBox(height: 8),
                            _buildCategoriaDropdown(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildEditableField(
    String key,
    String label,
    {
      bool isOptional = false,
      TextInputType keyboardType = TextInputType.text,
      bool isPassword = false,
      String? Function(String?)? validator
    }
  ) {
    return TextFormField(
      controller: _controllers[key],
      keyboardType: keyboardType,
      obscureText: isPassword,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13),
        suffixText: isOptional ? '(Opcional)' : null,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        border: const OutlineInputBorder()
      ),
      validator: (value) {
        if (validator != null) {
          final error = validator(value);
          return error;
        }
        return null;
      },
    );
  }

  Widget _buildTutorNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildEditableField('nomTutor1', 'Nom. Tutor 1', validator: (v) => Validator.validateRequired(v, 'Nombre Tutor 1')),
        const SizedBox(height: 8),
        _buildEditableField('apeTutor1', 'Ape. Tutor 1', validator: (v) => Validator.validateRequired(v, 'Apellido Tutor 1')),
        const SizedBox(height: 8),
        _buildEditableField('nomTutor2', 'Nom. Tutor 2', isOptional: true),
        const SizedBox(height: 8),
        _buildEditableField('apeTutor2', 'Ape. Tutor 2', isOptional: true),
      ],
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildEditableField('primerNombre', 'Primer Nombre', validator: (v) => Validator.validateRequired(v, 'Primer Nombre')),
        const SizedBox(height: 8),
        _buildEditableField('segundoNombre', 'Segundo Nombre', isOptional: true),
      ],
    );
  }

  Widget _buildApellidoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildEditableField('primerApellido', 'Primer Apellido', validator: (v) => Validator.validateRequired(v, 'Primer Apellido')),
        const SizedBox(height: 8),
        _buildEditableField('segundoApellido', 'Segundo Apellido', isOptional: true),
      ],
    );
  }

  Widget _buildTipoDocumentoDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedTipoDocumentoId,
      hint: const Text('Tipo Doc.', style: TextStyle(fontSize: 13)),
      decoration: const InputDecoration(
        labelText: 'Tipo de Documento',
        labelStyle: TextStyle(fontSize: 13),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        border: OutlineInputBorder(),
      ),
      items: _tiposDocumento.map((td) => DropdownMenuItem(
        value: td.idTiposDeDocumentos,
        child: Text(td.descripcion, style: const TextStyle(fontSize: 13))
      )).toList(),
      onChanged: (value) {
        setState(() {
          _selectedTipoDocumentoId = value;
        });
      },
    );
  }

  Widget _buildGeneroDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGenero,
      hint: const Text('Género', style: TextStyle(fontSize: 13)),
      decoration: const InputDecoration(
        labelText: 'Género',
        labelStyle: TextStyle(fontSize: 13),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'M', child: Text('Masculino', style: TextStyle(fontSize: 13))),
        DropdownMenuItem(value: 'F', child: Text('Femenino', style: TextStyle(fontSize: 13)))
      ],
      onChanged: (value) {
        setState(() {
          _selectedGenero = value;
        });
      },
    );
  }

  Widget _buildCategoriaDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedCategoriaId,
      hint: const Text('Categoría', style: TextStyle(fontSize: 13)),
      decoration: const InputDecoration(
        labelText: 'Categoría',
        labelStyle: TextStyle(fontSize: 13),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        border: OutlineInputBorder(),
      ),
      items: _categorias.map((cat) => DropdownMenuItem(
        value: cat.idCategorias,
        child: Text(cat.descripcion, style: const TextStyle(fontSize: 13))
      )).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategoriaId = value;
        });
      },
    );
  }

  Widget _buildDateField(String key) {
    Future<void> _selectDate() async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedFechaNacimiento ?? DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now()
      );
      if (picked != null && picked != _selectedFechaNacimiento) {
        setState(() {
          _selectedFechaNacimiento = picked;
          _controllers[key]!.text = picked.toIso8601String().split('T')[0];
        });
      }
    }
    return GestureDetector(
      onTap: _selectDate,
      child: AbsorbPointer(
        child: TextFormField(
          controller: _controllers[key],
          style: const TextStyle(fontSize: 13),
          decoration: const InputDecoration(
            labelText: 'Fecha de Nacimiento',
            labelStyle: TextStyle(fontSize: 13),
            hintText: 'dd/mm/aaaa',
            suffixIcon: Icon(Icons.calendar_today, size: 18),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            border: OutlineInputBorder()
          ),
          validator: (v) => Validator.validateRequired(v, 'Fecha de Nacimiento'),
        ),
      ),
    );
  }
}