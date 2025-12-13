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
            // Título con icono
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xffe63946).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add_chart,
                    color: Color(0xffe63946),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Agregar Registro Estadístico',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xffe63946)
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Formulario de selección con filtros
            FormularioSeleccionEntrenador(
              categorias: _controller.categoriasEntrenador, // ⭐ Solo sus categorías
              jugadoresFiltrados: _controller.jugadoresFiltrados,
              competenciasFiltradas: _controller.competenciasFiltradas,
              partidosFiltrados: _controller.partidosFiltrados,
              categoriaSeleccionada: _controller.categoriaSeleccionada,
              competenciaSeleccionada: _controller.competenciaSeleccionada,
              jugadorSeleccionado: _controller.jugadorSeleccionado,
              partidoSeleccionado: _controller.partidoSeleccionado,
              isLoadingCompetencias: _controller.isLoadingCompetencias,
              isLoadingPartidos: _controller.isLoadingPartidos,
              onCategoriaChanged: _controller.seleccionarCategoria,
              onCompetenciaChanged: _controller.seleccionarCompetencia,
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
            const SizedBox(height: 24),

            // Botones de acción con CURVAS
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: _controller.loading ? null : _onGuardarPressed,
                  icon: _controller.loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.save, size: 20),
                  label: Text(
                    _controller.loading ? 'Guardando...' : 'Guardar',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25), // 🎨 CURVAS
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _controller.loading ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.cancel, size: 20),
                  label: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffe63946),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25), // 🎨 CURVAS
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