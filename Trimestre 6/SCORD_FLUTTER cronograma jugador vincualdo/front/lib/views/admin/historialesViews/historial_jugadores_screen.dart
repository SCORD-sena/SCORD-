import 'package:flutter/material.dart';
import '../../../controllers/admin/historiales/historial_jugadores_controller.dart';
import '../../../models/jugador_model.dart';
import '../../../widgets/admin/historial/item_eliminado_card.dart';
import '../../../widgets/admin/historial/search_bar_historial.dart';
import '../../../widgets/admin/historial/contador_resultados.dart';
import '../../../widgets/admin/historial/empty_state.dart';

class HistorialJugadoresScreen extends StatefulWidget {
  const HistorialJugadoresScreen({super.key});

  @override
  State<HistorialJugadoresScreen> createState() => _HistorialJugadoresScreenState();
}

class _HistorialJugadoresScreenState extends State<HistorialJugadoresScreen> {
  late HistorialJugadoresController _controller;
  final TextEditingController _searchController = TextEditingController();
  List<Jugador> _jugadoresFiltrados = [];

  @override
  void initState() {
    super.initState();
    _controller = HistorialJugadoresController();
    _controller.addListener(_onControllerChanged);
    _cargarDatos();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {
        _jugadoresFiltrados = _controller.jugadoresEliminados;
      });
    }
  }

  Future<void> _cargarDatos() async {
    try {
      await _controller.inicializar();
      setState(() {
        _jugadoresFiltrados = _controller.jugadoresEliminados;
      });
    } catch (e) {
      _showSnackBar('Error al cargar datos: ${e.toString()}', isError: true);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _searchController.dispose();
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

  void _onSearchChanged(String query) {
    setState(() {
      _jugadoresFiltrados = _controller.buscarJugadores(query);
    });
  }

  Future<void> _onRestaurarPressed(Jugador jugador) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Restaurar Jugador?'),
        content: Text(
          '¿Desea restaurar a ${jugador.persona.nombreCompleto}?\n\n'
          'Dorsal: ${jugador.dorsal} - ${jugador.posicion}\n\n'
          'Este jugador volverá a estar activo en el sistema.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Sí, restaurar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final exito = await _controller.restaurarJugador(jugador.idJugadores);
      if (exito) {
        _showSnackBar('${jugador.persona.nombreCorto} restaurado correctamente');
      }
    } catch (e) {
      _showSnackBar(
        'Error: ${e.toString().replaceAll('Exception: ', '')}',
        isError: true,
      );
    }
  }

  Future<void> _onEliminarPermanentePressed(Jugador jugador) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '⚠️ ELIMINAR PERMANENTEMENTE',
          style: TextStyle(color: Colors.red),
        ),
        content: Text(
          '¿Está COMPLETAMENTE SEGURO de eliminar a ${jugador.persona.nombreCompleto}?\n\n'
          'Dorsal: ${jugador.dorsal} - ${jugador.posicion}\n\n'
          '⚠️ ESTA ACCIÓN NO SE PUEDE DESHACER.\n'
          'Se perderán TODOS los datos relacionados (estadísticas, rendimientos, etc.).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.green)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sí, eliminar permanentemente'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final exito = await _controller.eliminarPermanentemente(jugador.idJugadores);
      if (exito) {
        _showSnackBar('${jugador.persona.nombreCorto} eliminado permanentemente');
      }
    } catch (e) {
      _showSnackBar(
        'Error: ${e.toString().replaceAll('Exception: ', '')}',
        isError: true,
      );
    }
  }

  Widget _buildDrawerItem(String title, IconData icon, String routeName) {
    return ListTile(
      leading: Icon(icon, color: Colors.red),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: () {
        Navigator.of(context).pop();
        if (ModalRoute.of(context)?.settings.name != routeName) {
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
          'SCORD - Jugadores Eliminados',
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
            _buildDrawerItem('Inicio', Icons.home, '/InicioAdmin'),
            _buildDrawerItem('Cronograma', Icons.calendar_month, '/CronogramaAdmin'),
            _buildDrawerItem('Perfil Jugador', Icons.person_pin, '/PerfilJugadorAdmin'),
            _buildDrawerItem('Estadísticas Jugadores', Icons.bar_chart, '/EstadisticasJugadores'),
            _buildDrawerItem('Perfil Entrenador', Icons.sports_gymnastics, '/PerfilEntrenadorAdmin'),
            _buildDrawerItem('Evaluar Jugadores', Icons.rule, '/EvaluarJugadores'),
            const Divider(),
            ExpansionTile(
              leading: const Icon(Icons.history, color: Colors.red),
              title: const Text('Historial', style: TextStyle(fontSize: 16)),
              children: [
                _buildDrawerItem('  Jugadores Eliminados', Icons.sports_soccer, '/HistorialJugadores'),
                // Aquí irán Entrenadores, etc.
              ],
            ),
            const Divider(),
            _buildDrawerItem('Cerrar Sesión', Icons.logout, '/Logout'),
          ],
        ),
      ),
      body: _controller.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Barra de búsqueda
                SearchBarHistorial(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  hintText: 'Buscar por nombre, documento, dorsal o posición...',
                ),

                // Contador
                ContadorResultados(
                  cantidad: _jugadoresFiltrados.length,
                  texto: 'jugador(es) eliminado(s)',
                ),
                const SizedBox(height: 8),

                // Lista
                Expanded(
                  child: _jugadoresFiltrados.isEmpty
                      ? const EmptyState(
                          mensaje: 'No hay jugadores eliminados',
                          icono: Icons.sports_soccer,
                        )
                      : ListView.builder(
                          itemCount: _jugadoresFiltrados.length,
                          itemBuilder: (context, index) {
                            final jugador = _jugadoresFiltrados[index];
                            return ItemEliminadoCard(
  titulo: jugador.persona.nombreCompleto,
  subtitulo1: 'Dorsal: ${jugador.dorsal} • ${jugador.posicion}',
  subtitulo2: 'Teléfono: ${jugador.persona.telefono}',
  subtitulo3: jugador.categoria?.descripcion ?? 'Sin categoría',
  inicial: jugador.persona.nombre1[0],
  onRestaurar: () => _onRestaurarPressed(jugador),
  onEliminarPermanente: () => _onEliminarPermanentePressed(jugador),
);
                          },
                        ),
                ),
              ],
            ),
    );
  }
}