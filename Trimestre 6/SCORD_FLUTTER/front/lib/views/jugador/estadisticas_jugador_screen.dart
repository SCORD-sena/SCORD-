import 'package:flutter/material.dart';
import '../../controllers/jugador/estadisticas_jugador_controller.dart';
import '../../widgets/jugador/rendimientos/info_jugador_con_filtros.dart';
import '../../widgets/jugador/rendimientos/jugador_estadisticas_card.dart';
import '../../widgets/common/custom_alert.dart';

class EstadisticasIndividualesScreen extends StatefulWidget {
  const EstadisticasIndividualesScreen({super.key});

  @override
  State<EstadisticasIndividualesScreen> createState() => _EstadisticasIndividualesScreenState();
}

class _EstadisticasIndividualesScreenState extends State<EstadisticasIndividualesScreen> {
  late EstadisticasJugadorController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EstadisticasJugadorController();
    _controller.addListener(_onControllerChanged);
    _inicializar();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _inicializar() async {
    try {
      await _controller.inicializar();
    } catch (e) {
      if (mounted) {
        if (e.toString().contains('iniciar sesión') || e.toString().contains('permisos')) {
          await Future.delayed(const Duration(seconds: 2));
          Navigator.pushReplacementNamed(context, '/');
        } else {
          CustomAlert.mostrar(
            context,
            'Error',
            e.toString().replaceAll('Exception: ', ''),
            Colors.red,
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
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
    // Verificar si está cargando
    if (_controller.loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xffe63946)),
        ),
      );
    }

    // Verificar si hay error
    if (_controller.error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 16),
                Text(
                  _controller.error!,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const CircularProgressIndicator(color: Color(0xffe63946)),
                const SizedBox(height: 8),
                const Text('Redirigiendo...'),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'QUILMES - Mis Estadísticas',
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
                    'Jugador',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem('Inicio', Icons.home, '/InicioJugador'),
            _buildDrawerItem('Mis Estadísticas', Icons.bar_chart, '/EstadisticasJugador'),
            const Divider(),
            _buildDrawerItem('Cerrar Sesión', Icons.logout, '/Logout'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título de bienvenida
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.bar_chart_rounded,
                    size: 48,
                    color: Color(0xffe63946),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mis Estadísticas',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffe63946),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _controller.jugadorPersona?.nombreCorto ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Layout responsivo
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  // Desktop/Tablet: dos columnas
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Columna izquierda: Filtros e info
                      Expanded(
                        child: InfoJugadorConFiltros(
                          jugadorData: _controller.jugadorData,
                          competenciasFiltradas: _controller.competenciasFiltradas,
                          partidosFiltrados: _controller.partidosFiltrados,
                          competenciaSeleccionada: _controller.competenciaSeleccionada,
                          partidoSeleccionado: _controller.partidoSeleccionado,
                          isLoadingPartidos: _controller.isLoadingPartidos,
                          onCompetenciaChanged: _controller.seleccionarCompetencia,
                          onPartidoChanged: _controller.seleccionarPartido,
                          calcularEdad: _controller.calcularEdad,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Columna derecha: Estadísticas
                      Expanded(
                        child: JugadorEstadisticasCard(
                          estadisticas: _controller.estadisticasTotales,
                        ),
                      ),
                    ],
                  );
                } else {
                  // Móvil: una columna
                  return Column(
                    children: [
                      InfoJugadorConFiltros(
                        jugadorData: _controller.jugadorData,
                        competenciasFiltradas: _controller.competenciasFiltradas,
                        partidosFiltrados: _controller.partidosFiltrados,
                        competenciaSeleccionada: _controller.competenciaSeleccionada,
                        partidoSeleccionado: _controller.partidoSeleccionado,
                        isLoadingPartidos: _controller.isLoadingPartidos,
                        onCompetenciaChanged: _controller.seleccionarCompetencia,
                        onPartidoChanged: _controller.seleccionarPartido,
                        calcularEdad: _controller.calcularEdad,
                      ),
                      const SizedBox(height: 16),
                      JugadorEstadisticasCard(
                        estadisticas: _controller.estadisticasTotales,
                      ),
                    ],
                  );
                }
              },
            ),
          ],
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