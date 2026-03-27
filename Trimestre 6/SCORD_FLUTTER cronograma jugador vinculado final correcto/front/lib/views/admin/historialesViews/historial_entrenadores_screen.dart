import 'package:flutter/material.dart';
import '../../../controllers/admin/historiales/historial_entrenadores_controller.dart';
import '../../../models/entrenador_model.dart';
import '../../../widgets/admin/historial/item_eliminado_card.dart';
import '../../../widgets/admin/historial/search_bar_historial.dart';
import '../../../widgets/admin/historial/contador_resultados.dart';
import '../../../widgets/admin/historial/empty_state.dart';

class HistorialEntrenadoresScreen extends StatefulWidget {
  const HistorialEntrenadoresScreen({super.key});

  @override
  State<HistorialEntrenadoresScreen> createState() => _HistorialEntrenadoresScreenState();
}

class _HistorialEntrenadoresScreenState extends State<HistorialEntrenadoresScreen> {
  late HistorialEntrenadoresController _controller;
  final TextEditingController _searchController = TextEditingController();
  List<Entrenador> _entrenadoresFiltrados = [];

  @override
  void initState() {
    super.initState();
    _controller = HistorialEntrenadoresController();
    _controller.addListener(_onControllerChanged);
    _cargarDatos();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {
        _entrenadoresFiltrados = _controller.entrenadoresEliminados;
      });
    }
  }

  Future<void> _cargarDatos() async {
    try {
      await _controller.inicializar();
      setState(() {
        _entrenadoresFiltrados = _controller.entrenadoresEliminados;
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
      _entrenadoresFiltrados = _controller.buscarEntrenadores(query);
    });
  }

  Future<void> _onRestaurarPressed(Entrenador entrenador) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Restaurar Entrenador?'),
        content: Text(
          '¿Desea restaurar a ${entrenador.persona?.nombreCompleto ?? "este entrenador"}?\n\n'
          'Cargo: ${entrenador.cargo}\n\n'
          'Este entrenador volverá a estar activo en el sistema.',
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
      final exito = await _controller.restaurarEntrenador(entrenador.idEntrenadores);
      if (exito) {
        _showSnackBar('${entrenador.persona?.nombreCorto ?? "Entrenador"} restaurado correctamente');
      }
    } catch (e) {
      _showSnackBar(
        'Error: ${e.toString().replaceAll('Exception: ', '')}',
        isError: true,
      );
    }
  }

  Future<void> _onEliminarPermanentePressed(Entrenador entrenador) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '⚠️ ELIMINAR PERMANENTEMENTE',
          style: TextStyle(color: Colors.red),
        ),
        content: Text(
          '¿Está COMPLETAMENTE SEGURO de eliminar a ${entrenador.persona?.nombreCompleto ?? "este entrenador"}?\n\n'
          'Cargo: ${entrenador.cargo}\n\n'
          '⚠️ ESTA ACCIÓN NO SE PUEDE DESHACER.\n'
          'Se perderán TODOS los datos relacionados.',
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
      final exito = await _controller.eliminarPermanentemente(entrenador.idEntrenadores);
      if (exito) {
        _showSnackBar('${entrenador.persona?.nombreCorto ?? "Entrenador"} eliminado permanentemente');
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
          'SCORD - Entrenadores Eliminados',
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
                _buildDrawerItem('  Entrenadores Eliminados', Icons.sports, '/HistorialEntrenadores'),
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
                  hintText: 'Buscar por nombre, documento o cargo...',
                ),

                // Contador
                ContadorResultados(
                  cantidad: _entrenadoresFiltrados.length,
                  texto: 'entrenador(es) eliminado(s)',
                ),
                const SizedBox(height: 8),

                // Lista
                Expanded(
                  child: _entrenadoresFiltrados.isEmpty
                      ? const EmptyState(
                          mensaje: 'No hay entrenadores eliminados',
                          icono: Icons.sports,
                        )
                      : ListView.builder(
                          itemCount: _entrenadoresFiltrados.length,
                          itemBuilder: (context, index) {
                            final entrenador = _entrenadoresFiltrados[index];
                            final persona = entrenador.persona;
                            
                            // Obtener categorías como string
                            final categoriasTexto = entrenador.categorias != null && entrenador.categorias!.isNotEmpty
                                ? entrenador.categorias!.map((c) => c.descripcion).join(', ')
                                : 'Sin categorías';
                            
                            return ItemEliminadoCard(
                              titulo: persona?.nombreCompleto ?? 'Sin nombre',
                              subtitulo1: 'Cargo: ${entrenador.cargo} • ${entrenador.anosDeExperiencia} años exp.',
                              subtitulo2: persona != null ? 'Teléfono: ${persona.telefono}' : null,
                              subtitulo3: categoriasTexto,
                              inicial: persona?.nombre1[0] ?? 'E',
                              onRestaurar: () => _onRestaurarPressed(entrenador),
                              onEliminarPermanente: () => _onEliminarPermanentePressed(entrenador),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}