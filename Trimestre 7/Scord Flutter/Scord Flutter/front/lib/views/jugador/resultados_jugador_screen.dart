import 'package:flutter/material.dart';
import '../../controllers/jugador/resultados_jugador_controller.dart';
import '../../widgets/jugador/resultados/filtros_resultados_jugador.dart';
import '../../widgets/jugador/resultados/tabla_resultados_jugador.dart';
import '../../widgets/common/custom_alert.dart';
import '../../widgets/common/jugador_drawer.dart';

class ResultadosJugadorScreen extends StatefulWidget {
  const ResultadosJugadorScreen({super.key});

  @override
  State<ResultadosJugadorScreen> createState() => _ResultadosJugadorScreenState();
}

class _ResultadosJugadorScreenState extends State<ResultadosJugadorScreen> {
  late ResultadosJugadorController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ResultadosJugadorController();
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
        await CustomAlert.mostrar(
          context,
          'Error',
          'No se pudieron cargar los datos: ${e.toString()}',
          Colors.red,
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'SCORD - Mis Resultados',
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
      
      // ✅ REEMPLAZAR EL DRAWER ACTUAL CON EL WIDGET COMÚN
      drawer: const JugadorDrawer(
        currentRoute: '/ResultadosJugador',
      ),
      
      body: _controller.loading && _controller.jugadorData == null
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xffe63946)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Título
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xffe63946).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.assessment,
                          color: Color(0xffe63946),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mis Resultados',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xffe63946),
                              ),
                            ),
                            Text(
                              'Consulta los resultados de tus partidos',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Filtros
                  FiltrosResultadosJugador(
                    competenciasFiltradas: _controller.competenciasFiltradas,
                    partidosFiltrados: _controller.partidosFiltrados,
                    competenciaSeleccionada: _controller.competenciaSeleccionada,
                    partidoSeleccionado: _controller.partidoSeleccionado,
                    isLoadingPartidos: _controller.isLoadingPartidos,
                    onCompetenciaChanged: _controller.seleccionarCompetencia,
                    onPartidoChanged: _controller.seleccionarPartido,
                  ),
                  const SizedBox(height: 20),

                  // Tabla de resultados
                  if (_controller.isLoadingResultados)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(color: Color(0xffe63946)),
                      ),
                    )
                  else
                    TablaResultadosJugador(
                      resultados: _controller.resultadosFiltrados,
                      partidoSeleccionado: _controller.partidoSeleccionado,
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

  // ✅ YA NO NECESITAS ESTE MÉTODO - SE ELIMINÓ
  // Widget _buildDrawerItem(String title, IconData icon, String routeName) { ... }
}
