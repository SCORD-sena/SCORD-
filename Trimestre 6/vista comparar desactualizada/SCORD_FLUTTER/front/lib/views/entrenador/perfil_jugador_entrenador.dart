import 'package:flutter/material.dart';
import '../../controllers/entrenador/perfil_jugador_entrenador_controller.dart';
import '../../widgets/entrenador/perfil_jugadorE/seleccion_jugador_entrenador_card.dart';
import '../../widgets/entrenador/perfil_jugadorE/info_personal_entrenador_card.dart';
import '../../widgets/entrenador/perfil_jugadorE/info_contacto_entrenador_card.dart';
import '../../widgets/entrenador/perfil_jugadorE/info_tutores_entrenador_card.dart';
import '../../widgets/entrenador/perfil_jugadorE/info_deportiva_entrenador_card.dart';

class PerfilJugadorEntrenadorScreen extends StatefulWidget {
  const PerfilJugadorEntrenadorScreen({super.key});

  @override
  State<PerfilJugadorEntrenadorScreen> createState() => _PerfilJugadorEntrenadorScreenState();
}

class _PerfilJugadorEntrenadorScreenState extends State<PerfilJugadorEntrenadorScreen> {
  late PerfilJugadorEntrenadorController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = PerfilJugadorEntrenadorController();
    _controller.addListener(_onControllerChanged);
    _controller.inicializar().catchError((e) {
      _showSnackBar('Error al cargar datos iniciales: ${e.toString()}', isError: true);
    });
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
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

  Future<void> _onGuardarPressed() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Estás Seguro?'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              const Text('¿Desea actualizar los datos del jugador seleccionado?'),
              const Divider(),
              Text('Documento: ${_controller.controllers['numeroDocumento']!.text}'),
              Text('Nombre: ${_controller.controllers['primerNombre']!.text} ${_controller.controllers['primerApellido']!.text}'),
              Text('Dorsal: ${_controller.controllers['dorsal']!.text} — Posición: ${_controller.controllers['posicion']!.text}'),
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

    try {
      final exito = await _controller.guardarCambios();
      if (exito) {
        _showSnackBar('Los datos se actualizaron correctamente.');
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString().replaceAll('Exception: ', '')}', isError: true);
    }
  }

  Future<void> _onEliminarPressed() async {
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
      final exito = await _controller.eliminarJugador();
      if (exito) {
        _showSnackBar('El jugador se eliminó correctamente');
      }
    } catch (e) {
      _showSnackBar('Error: No se pudo eliminar el jugador', isError: true);
    }
  }

  void _onEditarPressed() {
    try {
      _controller.activarEdicion();
    } catch (e) {
      _showSnackBar(e.toString().replaceAll('Exception: ', ''), isError: true);
    }
  }

  Widget _buildDrawerItem(String title, IconData icon, String routeName) {
    return ListTile(
      leading: Icon(icon, color: Colors.red),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: () {
        Navigator.of(context).pop();

        if (routeName == '/Logout') {
          // Lógica de logout
        } else if (ModalRoute.of(context)?.settings.name != routeName) {
          Navigator.of(context).pushNamed(routeName);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            _buildDrawerItem('Inicio', Icons.home, '/InicioEntrenador'),
            _buildDrawerItem('Cronograma', Icons.calendar_month, '/CronogramaEntrenador'),
            _buildDrawerItem('Perfil Jugador', Icons.person_pin, '/PerfilJugadorEntrenador'),
            _buildDrawerItem('Estadísticas Jugadores', Icons.bar_chart, '/EstadisticasJugadoresEntrenador'),
            _buildDrawerItem('Evaluar Jugadores', Icons.rule, '/EvaluarJugadoresEntrenador'),
            const Divider(),
            _buildDrawerItem('Cerrar Sesión', Icons.logout, '/Logout'),
          ],
        ),
      ),
      body: _controller.loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Botones de acción (SIN AGREGAR)
                    Wrap(
                      spacing: 6.0,
                      runSpacing: 6.0,
                      alignment: WrapAlignment.center,
                      children: [
                        if (!_controller.modoEdicion) ...[
                          ElevatedButton.icon(
                            onPressed: _onEditarPressed,
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
                            onPressed: _onEliminarPressed,
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
                            onPressed: _onGuardarPressed,
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
                            onPressed: _controller.cancelarEdicion,
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

                    // Selección de jugador
                    SeleccionJugadorEntrenadorCard(
                      categorias: _controller.categoriasEntrenador, // ⭐ Solo sus categorías
                      jugadoresFiltrados: _controller.jugadoresFiltrados,
                      categoriaSeleccionada: _controller.categoriaSeleccionada,
                      jugadorSeleccionado: _controller.jugadorSeleccionado,
                      modoEdicion: _controller.modoEdicion,
                      onCategoriaChanged: _controller.seleccionarCategoria,
                      onJugadorChanged: _controller.seleccionarJugador,
                    ),
                    const SizedBox(height: 12),

                    // Información Personal
                    InfoPersonalEntrenadorCard(
                      modoEdicion: _controller.modoEdicion,
                      jugadorSeleccionado: _controller.jugadorSeleccionado,
                      controllers: _controller.controllers,
                      tiposDocumento: _controller.tiposDocumento,
                      selectedTipoDocumentoId: _controller.selectedTipoDocumentoId,
                      selectedGenero: _controller.selectedGenero,
                      selectedFechaNacimiento: _controller.selectedFechaNacimiento,
                      onTipoDocumentoChanged: _controller.actualizarTipoDocumento,
                      onGeneroChanged: _controller.actualizarGenero,
                      onFechaChanged: _controller.actualizarFechaNacimiento,
                      calcularEdad: _controller.calcularEdad,
                    ),
                    const SizedBox(height: 12),

                    // Información de Contacto
                    InfoContactoEntrenadorCard(
                      modoEdicion: _controller.modoEdicion,
                      jugadorSeleccionado: _controller.jugadorSeleccionado,
                      controllers: _controller.controllers,
                    ),
                    const SizedBox(height: 12),

                    // Información de Tutores
                    InfoTutoresEntrenadorCard(
                      modoEdicion: _controller.modoEdicion,
                      jugadorSeleccionado: _controller.jugadorSeleccionado,
                      controllers: _controller.controllers,
                    ),
                    const SizedBox(height: 12),

                    // Información Deportiva
                    InfoDeportivaEntrenadorCard(
                      modoEdicion: _controller.modoEdicion,
                      jugadorSeleccionado: _controller.jugadorSeleccionado,
                      controllers: _controller.controllers,
                      categorias: _controller.categoriasEntrenador, // ⭐ Solo sus categorías
                      selectedCategoriaId: _controller.selectedCategoriaId,
                      onCategoriaChanged: _controller.actualizarCategoria,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}