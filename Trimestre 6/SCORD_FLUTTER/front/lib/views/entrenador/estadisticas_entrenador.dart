import 'package:flutter/material.dart';
import '../../controllers/entrenador/estadisticas_entrenador_controller.dart';
import '../../widgets/entrenador/estadisticas/botones_accion_entrenador.dart';
import '../../widgets/entrenador/estadisticas/info_jugador_entrenador_card.dart';
import '../../widgets/entrenador/estadisticas/estadisticas_entrenador_card.dart';
import '../../widgets/common/custom_alert.dart';
import 'agregar_rendimiento_entrenador_screen.dart';

class EstadisticasJugadorEntrenadorScreen extends StatefulWidget {
  const EstadisticasJugadorEntrenadorScreen({super.key});

  @override
  State<EstadisticasJugadorEntrenadorScreen> createState() => _EstadisticasJugadorEntrenadorScreenState();
}

class _EstadisticasJugadorEntrenadorScreenState extends State<EstadisticasJugadorEntrenadorScreen> {
  late EstadisticasEntrenadorController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EstadisticasEntrenadorController();
    _controller.addListener(_onControllerChanged);
    _controller.inicializar();
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

  // --- Handlers de botones ---

  void _onAgregarPressed() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AgregarRendimientoEntrenadorScreen()),
    );
    if (_controller.jugadorSeleccionado != null) {
      await _controller.fetchEstadisticasTotales(_controller.jugadorSeleccionado!.idJugadores);
    }
  }

  void _onEditarPressed() {
    try {
      _controller.activarEdicion();
    } catch (e) {
      CustomAlert.mostrar(context, 'Error', e.toString(), Colors.orange);
    }
  }

  void _onGuardarPressed() async {
    final confirm = await CustomAlert.confirmar(
      context,
      '¿Estás Seguro?',
      'Goles: ${_controller.formData['goles']}\nAsistencias: ${_controller.formData['asistencias']}\nMinutos: ${_controller.formData['minutosJugados']}',
      'Sí, actualizar',
      Colors.green,
    );

    if (!confirm) return;

    try {
      final exito = await _controller.guardarCambios(context);
      if (exito) {
        CustomAlert.mostrar(context, 'Estadísticas actualizadas', 'Los datos se actualizaron correctamente.', Colors.green);
      }
    } catch (e) {
      CustomAlert.mostrar(context, 'Error', 'No se pudo actualizar las estadísticas', Colors.red);
    }
  }

  void _onEliminarPressed() async {
    final confirm = await CustomAlert.confirmar(
      context,
      '¿Estás seguro?',
      'Se eliminará el último registro de estadísticas',
      'Sí, eliminar',
      Colors.red,
    );

    if (!confirm) return;

    try {
      final exito = await _controller.eliminarEstadistica();
      if (exito) {
        CustomAlert.mostrar(context, '¡Estadística eliminada!', 'El último registro se eliminó correctamente', Colors.green);
      }
    } catch (e) {
      CustomAlert.mostrar(context, 'Error', e.toString(), Colors.red);
    }
  }

  Widget _buildDrawerItem(String title, IconData icon, String routeName) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xffe63946)),
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
          'SCORD - Estadísticas',
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
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xffe63946)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Icon(Icons.sports_soccer, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'SCORD',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Text(
                    'Entrenador',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
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
      body: Column(
        children: [
          // Botones de acción con curvas
          BotonesAccionEntrenador(
            modoEdicion: _controller.modoEdicion,
            loading: _controller.loading,
            onAgregar: _onAgregarPressed,
            onEditar: _onEditarPressed,
            onEliminar: _onEliminarPressed,
            onGuardar: _onGuardarPressed,
            onCancelar: _controller.cancelarEdicion,
          ),
          
          // Contenido principal
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Card de Información del Jugador con filtros
                  InfoJugadorEntrenadorCard(
                    categorias: _controller.categoriasEntrenador, // ⭐ Solo sus categorías
                    jugadoresFiltrados: _controller.jugadoresFiltrados,
                    competenciasFiltradas: _controller.competenciasFiltradas,
                    partidosFiltrados: _controller.partidosFiltrados,
                    categoriaSeleccionadaId: _controller.categoriaSeleccionadaId,
                    competenciaSeleccionada: _controller.competenciaSeleccionada,
                    partidoSeleccionado: _controller.partidoSeleccionado,
                    jugadorSeleccionado: _controller.jugadorSeleccionado,
                    modoEdicion: _controller.modoEdicion,
                    isLoadingCompetencias: _controller.isLoadingCompetencias,
                    isLoadingPartidos: _controller.isLoadingPartidos,
                    onCategoriaChanged: _controller.seleccionarCategoria,
                    onJugadorChanged: _controller.seleccionarJugador,
                    onCompetenciaChanged: _controller.seleccionarCompetencia,
                    onPartidoChanged: _controller.seleccionarPartido,
                    calcularEdad: _controller.calcularEdad,
                  ),

                  const SizedBox(height: 16),

                  // Card de Estadísticas
                  EstadisticasEntrenadorCard(
                    loading: _controller.loading,
                    modoEdicion: _controller.modoEdicion,
                    estadisticasTotales: _controller.estadisticasTotales,
                    formData: _controller.formData,
                    onCampoChanged: _controller.actualizarCampo,
                  ),
                ],
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
}