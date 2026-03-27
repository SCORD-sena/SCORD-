import 'package:flutter/material.dart';
import '../../controllers/admin/gestion_resultados_controller.dart';
import '../../models/resultado_model.dart';
import '../../widgets/admin/resultados/filtros_resultados.dart';
import '../../widgets/admin/resultados/dialogo_resultado.dart';
import '../../widgets/admin/resultados/tabla_resultados.dart';
import '../../widgets/common/custom_alert.dart';
import '../../widgets/common/admin_drawer.dart';

class GestionResultadosScreen extends StatefulWidget {
  const GestionResultadosScreen({super.key});

  @override
  State<GestionResultadosScreen> createState() => _GestionResultadosScreenState();
}

class _GestionResultadosScreenState extends State<GestionResultadosScreen> {
  late GestionResultadosController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GestionResultadosController();
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

  Future<void> _handleNuevoResultado() async {
    // Navegar a la pantalla de agregar resultado
    final resultado = await Navigator.of(context).pushNamed('/AgregarResultado');
    
    // Si se agregó exitosamente, recargar datos
    if (resultado == true) {
      await _controller.fetchResultados();
      
      // Si hay filtros activos, reaplicarlos
      if (_controller.partidoSeleccionado != null) {
        await _controller.filtrarResultadosPorPartido(_controller.partidoSeleccionado!);
      }
    }
  }

  Future<void> _handleEditarResultado(Resultado resultado) async {
    _controller.abrirDialogoEditar(resultado);
    final res = await showDialog<bool>(
      context: context,
      builder: (context) => DialogoResultado(controller: _controller),
    );

    if (res == true) {
      await _ejecutarActualizar();
    } else {
      _controller.limpiarFormulario();
    }
  }

  Future<void> _handleEliminarResultado(Resultado resultado) async {
    final confirmar = await CustomAlert.confirmar(
      context,
      '¿Eliminar Resultado?',
      '¿Estás seguro de eliminar el resultado "${resultado.marcador}"?\n\nEsta acción moverá el resultado a la papelera.',
      'Sí, eliminar',
      Colors.red,
    );

    if (confirmar) {
      await _ejecutarEliminar(resultado);
    }
  }

  Future<void> _ejecutarActualizar() async {
    try {
      final exito = await _controller.actualizarResultado();
      if (exito && mounted) {
        await CustomAlert.mostrar(
          context,
          'Éxito',
          'Resultado actualizado correctamente',
          Colors.green,
        );
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

  Future<void> _ejecutarEliminar(Resultado resultado) async {
    try {
      final exito = await _controller.eliminarResultado(resultado.idResultados);
      if (exito && mounted) {
        await CustomAlert.mostrar(
          context,
          'Éxito',
          'Resultado eliminado correctamente',
          Colors.green,
        );
      }
    } catch (e) {
      if (mounted) {
        await CustomAlert.mostrar(
          context,
          'Error',
          'No se pudo eliminar el resultado: ${e.toString()}',
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
        'SCORD - Gestión de Resultados',
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
    
    // ✅ SOLO ESTA LÍNEA CAMBIA:
    drawer: AdminDrawer(currentRoute: '/GestionResultados'),
    
    body: _controller.loading && _controller.categorias.isEmpty
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
                    const Text(
                      'Gestión de Resultados',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xffe63946),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Filtros
                FiltrosResultados(
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

                // Botón Agregar
                ElevatedButton.icon(
                  onPressed: _handleNuevoResultado,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text(
                    'Agregar Resultado',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
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
                  TablaResultados(
                    resultados: _controller.resultadosFiltrados,
                    partidoSeleccionado: _controller.partidoSeleccionado,
                    onEditar: _handleEditarResultado,
                    onEliminar: _handleEliminarResultado,
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