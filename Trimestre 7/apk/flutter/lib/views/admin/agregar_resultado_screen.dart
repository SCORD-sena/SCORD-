import 'package:flutter/material.dart';
import '../../controllers/admin/agregar_resultado_controller.dart';
import '../../widgets/admin/resultados/formulario_seleccion_resultado.dart';
import '../../widgets/admin/resultados/formulario_datos_resultado.dart';
import '../../widgets/common/custom_alert.dart';

class AgregarResultadoScreen extends StatefulWidget {
  const AgregarResultadoScreen({super.key});

  @override
  State<AgregarResultadoScreen> createState() => _AgregarResultadoScreenState();
}

class _AgregarResultadoScreenState extends State<AgregarResultadoScreen> {
  late AgregarResultadoController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AgregarResultadoController();
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

  // ============================================================
  // HANDLERS
  // ============================================================

  Future<void> _handleGuardar() async {
    try {
      final exito = await _controller.crearResultado();
      if (exito && mounted) {
        await CustomAlert.mostrar(
          context,
          'Éxito',
          'Resultado creado correctamente',
          Colors.green,
        );
        
        // Volver a la pantalla anterior después de 1 segundo
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.of(context).pop(true); // Retorna true para indicar éxito
        }
      }
    } catch (e) {
      if (mounted) {
        await CustomAlert.mostrar(
          context,
          'Error',
          e.toString().replaceAll('Exception: ', ''),
          Colors.red,
        );
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SCORD - Agregar Resultado',
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
      body: SingleChildScrollView(
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
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add_circle,
                    color: Colors.green,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Nuevo Resultado',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Formulario de selección (Categoría → Competencia → Partido)
            FormularioSeleccionResultado(
              categorias: _controller.categorias,
              competenciasFiltradas: _controller.competenciasFiltradas,
              partidosFiltrados: _controller.partidosFiltrados,
              categoriaSeleccionada: _controller.categoriaSeleccionada,
              competenciaSeleccionada: _controller.competenciaSeleccionada,
              partidoSeleccionado: _controller.partidoSeleccionado,
              isLoadingCompetencias: _controller.isLoadingCompetencias,
              isLoadingPartidos: _controller.isLoadingPartidos,
              onCategoriaChanged: _controller.seleccionarCategoria,
              onCompetenciaChanged: _controller.seleccionarCompetencia,
              onPartidoChanged: _controller.seleccionarPartido,
            ),
            const SizedBox(height: 20),

            // Formulario de datos del resultado
            FormularioDatosResultado(controller: _controller),
            const SizedBox(height: 24),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _controller.loading ? null : _handleGuardar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: _controller.loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Guardar Resultado',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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