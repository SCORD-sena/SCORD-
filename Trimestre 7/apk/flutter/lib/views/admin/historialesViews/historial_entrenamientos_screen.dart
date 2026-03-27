import 'package:flutter/material.dart';
import '../../../controllers/admin/historiales/historial_entrenamientos_controller.dart';
import '../../../models/cronograma_model.dart';
import '../../../widgets/admin/historial/item_eliminado_card.dart';
import '../../../widgets/admin/historial/search_bar_historial.dart';
import '../../../widgets/admin/historial/contador_resultados.dart';
import '../../../widgets/admin/historial/empty_state.dart';
import '../../../widgets/common/admin_drawer.dart';

class HistorialEntrenamientosScreen extends StatefulWidget {
  const HistorialEntrenamientosScreen({super.key});

  @override
  State<HistorialEntrenamientosScreen> createState() => _HistorialEntrenamientosScreenState();
}

class _HistorialEntrenamientosScreenState extends State<HistorialEntrenamientosScreen> {
  late HistorialEntrenamientosController _controller;
  final TextEditingController _searchController = TextEditingController();
  List<Cronograma> _entrenamientosFiltrados = [];

  @override
  void initState() {
    super.initState();
    _controller = HistorialEntrenamientosController();
    _controller.addListener(_onControllerChanged);
    _cargarDatos();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {
        _entrenamientosFiltrados = _controller.entrenamientosEliminados;
      });
    }
  }

  Future<void> _cargarDatos() async {
    try {
      await _controller.inicializar();
      setState(() {
        _entrenamientosFiltrados = _controller.entrenamientosEliminados;
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
      _entrenamientosFiltrados = _controller.buscarEntrenamientos(query);
    });
  }

  String _formatearFecha(String fecha) {
    try {
      final partes = fecha.split('-');
      if (partes.length == 3) {
        return '${partes[2]}/${partes[1]}/${partes[0]}';
      }
      return fecha;
    } catch (e) {
      return fecha;
    }
  }

  Future<void> _onRestaurarPressed(Cronograma entrenamiento) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Restaurar Entrenamiento?'),
        content: Text(
          '¿Desea restaurar este entrenamiento?\n\n'
          'Fecha: ${_formatearFecha(entrenamiento.fechaDeEventos)}\n'
          'Ubicación: ${entrenamiento.ubicacion}\n\n'
          'Este entrenamiento volverá a estar activo en el sistema.',
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
      final exito = await _controller.restaurarEntrenamiento(entrenamiento.idCronogramas);
      if (exito) {
        _showSnackBar('Entrenamiento restaurado correctamente');
      }
    } catch (e) {
      _showSnackBar(
        'Error: ${e.toString().replaceAll('Exception: ', '')}',
        isError: true,
      );
    }
  }

  Future<void> _onEliminarPermanentePressed(Cronograma entrenamiento) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '⚠️ ELIMINAR PERMANENTEMENTE',
          style: TextStyle(color: Colors.red),
        ),
        content: Text(
          '¿Está COMPLETAMENTE SEGURO de eliminar este entrenamiento?\n\n'
          'Fecha: ${_formatearFecha(entrenamiento.fechaDeEventos)}\n'
          'Ubicación: ${entrenamiento.ubicacion}\n\n'
          '⚠️ ESTA ACCIÓN NO SE PUEDE DESHACER.\n'
          'Se perderán TODOS los datos relacionados con este entrenamiento.',
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
      final exito = await _controller.eliminarPermanentemente(entrenamiento.idCronogramas);
      if (exito) {
        _showSnackBar('Entrenamiento eliminado permanentemente');
      }
    } catch (e) {
      _showSnackBar(
        'Error: ${e.toString().replaceAll('Exception: ', '')}',
        isError: true,
      );
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'SCORD - Entrenamientos Eliminados',
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 1,
      centerTitle: false,
      iconTheme: const IconThemeData(color: Colors.red),
    ),
    
    // ✅ SOLO ESTA LÍNEA CAMBIA:
    drawer: AdminDrawer(currentRoute: '/HistorialEntrenamientos'),
    
    body: _controller.loading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              // Barra de búsqueda
              SearchBarHistorial(
                controller: _searchController,
                onChanged: _onSearchChanged,
                hintText: 'Buscar por fecha, ubicación o sede...',
              ),

              // Contador
              ContadorResultados(
                cantidad: _entrenamientosFiltrados.length,
                texto: 'entrenamiento(s) eliminado(s)',
              ),
              const SizedBox(height: 8),

              // Lista
              Expanded(
                child: _entrenamientosFiltrados.isEmpty
                    ? const EmptyState(
                        mensaje: 'No hay entrenamientos eliminados',
                        icono: Icons.fitness_center,
                      )
                    : ListView.builder(
                        itemCount: _entrenamientosFiltrados.length,
                        itemBuilder: (context, index) {
                          final entrenamiento = _entrenamientosFiltrados[index];
                          
                          // Construir subtítulos para entrenamiento
                          final subtitulo1 = 'Entrenamiento • ${_formatearFecha(entrenamiento.fechaDeEventos)}';
                          final subtitulo2 = entrenamiento.hora != null 
                              ? 'Hora: ${entrenamiento.hora}' 
                              : null;
                          final subtitulo3 = entrenamiento.sedeEntrenamiento != null 
                              ? 'Sede: ${entrenamiento.sedeEntrenamiento}' 
                              : null;

                          return ItemEliminadoCard(
                            titulo: entrenamiento.ubicacion,
                            subtitulo1: subtitulo1,
                            subtitulo2: subtitulo2,
                            subtitulo3: subtitulo3,
                            inicial: 'E',
                            onRestaurar: () => _onRestaurarPressed(entrenamiento),
                            onEliminarPermanente: () => _onEliminarPermanentePressed(entrenamiento),
                          );
                        },
                      ),
              ),
            ],
          ),
  );
}
}