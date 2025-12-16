import 'package:flutter/material.dart';
import '../../controllers/admin/perfil_jugador_controller.dart';
import '../../widgets/admin/perfil_jugador/seleccion_jugador_card.dart';
import '../../widgets/admin/perfil_jugador/info_personal_card.dart';
import '../../widgets/admin/perfil_jugador/info_contacto_card.dart';
import '../../widgets/admin/perfil_jugador/info_tutores_card.dart';
import '../../widgets/admin/perfil_jugador/info_deportiva_card.dart';
import '../../widgets/admin/perfil_jugador/info_mensualidad_admin_card.dart'; // ← NUEVO IMPORT

class PerfilJugadorAdminScreen extends StatefulWidget {
  const PerfilJugadorAdminScreen({super.key});

  @override
  State<PerfilJugadorAdminScreen> createState() => _PerfilJugadorAdminScreenState();
}

class _PerfilJugadorAdminScreenState extends State<PerfilJugadorAdminScreen> {
  late PerfilJugadorController _controller;
  final _formKey = GlobalKey<FormState>();
  bool _procesandoPago = false; // ← NUEVA VARIABLE

  @override
  void initState() {
    super.initState();
    _controller = PerfilJugadorController();
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
        title: const Text('¿Estas Seguro?'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              const Text('¿Desea actualizar los datos del jugador seleccionado?'),
              const Divider(),
              Text('Documento: ${_controller.controllers['numeroDocumento']!.text}'),
              Text('Nombre: ${_controller.controllers['primerNombre']!.text} ${_controller.controllers['primerApellido']!.text}'),
              Text('Dorsal: ${_controller.controllers['dorsal']!.text} — Posicion: ${_controller.controllers['posicion']!.text}'),
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
            child: const Text('Si, actualizar'),
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
        title: const Text('¿Estas seguro?'),
        content: const Text('Se eliminara el jugador. Esta accion es irreversible.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar', style: TextStyle(color: Colors.green)),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Si, eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final exito = await _controller.eliminarJugador();
      if (exito) {
        _showSnackBar('El jugador se elimino correctamente');
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

  // ← NUEVO METODO
  Future<void> _onRegistrarPagoPressed() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Pago'),
        content: const Text(
          '¿Desea registrar el pago de mensualidad para este jugador?\n\n'
          'Esto actualizara la fecha de vencimiento al proximo mes.',
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Si, registrar pago'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _procesandoPago = true);

    try {
      await _controller.registrarPagoMensualidad();
      _showSnackBar('Pago registrado exitosamente. Mensualidad actualizada.');
    } catch (e) {
      _showSnackBar(
        'Error: ${e.toString().replaceAll('Exception: ', '')}',
        isError: true,
      );
    } finally {
      setState(() => _procesandoPago = false);
    }
  }

  Widget _buildDrawerItem(String title, IconData icon, String routeName) {
    return ListTile(
      leading: Icon(icon, color: Colors.red),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: () {
        Navigator.of(context).pop();

        if (routeName == '/Logout') {
          // Logica de deslogueo
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
                'Menu de Navegacion',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            _buildDrawerItem('Inicio', Icons.home, '/InicioAdmin'),
            _buildDrawerItem('Cronograma', Icons.calendar_month, '/CronogramaAdmin'),
            _buildDrawerItem('Perfil Jugador', Icons.person_pin, '/PerfilJugadorAdmin'),
            _buildDrawerItem('Estadisticas Jugadores', Icons.bar_chart, '/EstadisticasJugadores'),
            _buildDrawerItem('Perfil Entrenador', Icons.sports_gymnastics, '/PerfilEntrenadorAdmin'),
            _buildDrawerItem('Evaluar Jugadores', Icons.rule, '/EvaluarJugadores'),
            const Divider(),
            _buildDrawerItem('Cerrar Sesion', Icons.logout, '/Logout'),
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
                    // Botones de accion
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

                    SeleccionJugadorCard(
                      categorias: _controller.categorias,
                      jugadoresFiltrados: _controller.jugadoresFiltrados,
                      categoriaSeleccionada: _controller.categoriaSeleccionada,
                      jugadorSeleccionado: _controller.jugadorSeleccionado,
                      modoEdicion: _controller.modoEdicion,
                      onCategoriaChanged: _controller.seleccionarCategoria,
                      onJugadorChanged: _controller.seleccionarJugador,
                    ),
                    const SizedBox(height: 12),

                    InfoPersonalCard(
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

                    InfoContactoCard(
                      modoEdicion: _controller.modoEdicion,
                      jugadorSeleccionado: _controller.jugadorSeleccionado,
                      controllers: _controller.controllers,
                    ),
                    const SizedBox(height: 12),

                    InfoTutoresCard(
                      modoEdicion: _controller.modoEdicion,
                      jugadorSeleccionado: _controller.jugadorSeleccionado,
                      controllers: _controller.controllers,
                    ),
                    const SizedBox(height: 12),

                    InfoDeportivaCard(
                      modoEdicion: _controller.modoEdicion,
                      jugadorSeleccionado: _controller.jugadorSeleccionado,
                      controllers: _controller.controllers,
                      categorias: _controller.categorias,
                      selectedCategoriaId: _controller.selectedCategoriaId,
                      onCategoriaChanged: _controller.actualizarCategoria,
                    ),
                    const SizedBox(height: 12),

                    // ← NUEVO: Card de Mensualidad
                    InfoMensualidadAdminCard(
                      jugadorSeleccionado: _controller.jugadorSeleccionado,
                      onRegistrarPago: _onRegistrarPagoPressed,
                      procesandoPago: _procesandoPago,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}