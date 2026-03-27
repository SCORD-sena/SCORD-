import 'package:flutter/material.dart';
import '../../controllers/entrenador/agregar_rendimiento_entrenador_controller.dart';
import '../../widgets/entrenador/agregar_rendimiento/formulario_seleccion_entrenador.dart';
import '../../widgets/entrenador/agregar_rendimiento/formulario_estadisticas_entrenador.dart';
import '../../widgets/common/custom_alert.dart';

class AgregarRendimientoEntrenadorScreen extends StatefulWidget {
  const AgregarRendimientoEntrenadorScreen({super.key});

  @override
  State<AgregarRendimientoEntrenadorScreen> createState() => _AgregarRendimientoEntrenadorScreenState();
}

class _AgregarRendimientoEntrenadorScreenState extends State<AgregarRendimientoEntrenadorScreen> {
  late AgregarRendimientoEntrenadorController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AgregarRendimientoEntrenadorController();
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
      CustomAlert.mostrar(
        context,
        'Error',
        'No se pudieron cargar los datos necesarios: ${e.toString()}',
        Colors.red,
      );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onGuardarPressed() async {
    final confirm = await CustomAlert.confirmar(
      context,
      '¿Guardar Estadística?',
      'Goles: ${_controller.golesController.text}\nAsistencias: ${_controller.asistenciasController.text}\nMinutos: ${_controller.minutosJugadosController.text}',
      'Sí, guardar',
      Colors.green,
    );

    if (!confirm) return;

    try {
      final exito = await _controller.crearEstadistica();
      if (exito) {
        await CustomAlert.mostrar(
          context,
          'Estadística guardada',
          'Los datos se registraron correctamente.',
          Colors.green,
        );
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      CustomAlert.mostrar(
        context,
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        e.toString().contains('seleccionar') ? Colors.orange : Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SCORD',
          style: TextStyle(
            color: Color(0xffe63946),
            fontWeight: FontWeight.bold
          )
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xffe63946)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: Text(
                'Agregar Registro Estadístico',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffe63946)
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Formulario de selección
            FormularioSeleccionEntrenador(
              categorias: _controller.categoriasEntrenador, // ⭐ Solo sus categorías
              jugadoresFiltrados: _controller.jugadoresFiltrados,
              partidos: _controller.partidos,
              categoriaSeleccionada: _controller.categoriaSeleccionada,
              jugadorSeleccionado: _controller.jugadorSeleccionado,
              partidoSeleccionado: _controller.partidoSeleccionado,
              onCategoriaChanged: _controller.seleccionarCategoria,
              onJugadorChanged: _controller.seleccionarJugador,
              onPartidoChanged: _controller.seleccionarPartido,
            ),
            const SizedBox(height: 20),

            // Formulario de estadísticas
            FormularioEstadisticasEntrenador(
              golesController: _controller.golesController,
              asistenciasController: _controller.asistenciasController,
              minutosJugadosController: _controller.minutosJugadosController,
              golesDeCabezaController: _controller.golesDeCabezaController,
              tirosApuertaController: _controller.tirosApuertaController,
              fuerasDeLugarController: _controller.fuerasDeLugarController,
              tarjetasAmarillasController: _controller.tarjetasAmarillasController,
              tarjetasRojasController: _controller.tarjetasRojasController,
              arcoEnCeroController: _controller.arcoEnCeroController,
            ),
            const SizedBox(height: 20),

            // Botones de acción
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _controller.loading ? null : _onGuardarPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: Text(
                    _controller.loading ? 'Guardando...' : 'Guardar',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _controller.loading ? null : () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffe63946),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ],
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