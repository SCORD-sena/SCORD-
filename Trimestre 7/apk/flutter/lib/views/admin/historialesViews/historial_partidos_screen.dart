import 'package:flutter/material.dart';
import '../../../controllers/admin/historiales/historial_partidos_controller.dart';
import '../../../models/partido_model.dart';
import '../../../widgets/admin/historial/item_eliminado_card.dart';
import '../../../widgets/admin/historial/search_bar_historial.dart';
import '../../../widgets/admin/historial/contador_resultados.dart';
import '../../../widgets/admin/historial/empty_state.dart';
import '../../../widgets/common/admin_drawer.dart';

class HistorialPartidosScreen extends StatefulWidget {
  const HistorialPartidosScreen({super.key});

  @override
  State<HistorialPartidosScreen> createState() => _HistorialPartidosScreenState();
}

class _HistorialPartidosScreenState extends State<HistorialPartidosScreen> {
  late HistorialPartidosController _controller;
  final TextEditingController _searchController = TextEditingController();
  List<Partido> _partidosFiltrados = [];

  @override
  void initState() {
    super.initState();
    _controller = HistorialPartidosController();
    _controller.addListener(_onControllerChanged);
    _cargarDatos();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {
        _partidosFiltrados = _controller.partidosEliminados;
      });
    }
  }

  Future<void> _cargarDatos() async {
    try {
      await _controller.inicializar();
      setState(() {
        _partidosFiltrados = _controller.partidosEliminados;
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
      _partidosFiltrados = _controller.buscarPartidos(query);
    });
  }

  Future<void> _onRestaurarPressed(Partido partido) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Restaurar Partido?'),
        content: Text(
          '¿Desea restaurar este partido?\n\n'
          'Rival: ${partido.equipoRival}\n'
          'Formación: ${partido.formacion}\n\n'
          'Este partido volverá a estar activo en el sistema.',
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
      final exito = await _controller.restaurarPartido(partido.idPartidos);
      if (exito) {
        _showSnackBar('Partido vs ${partido.equipoRival} restaurado correctamente');
      }
    } catch (e) {
      _showSnackBar(
        'Error: ${e.toString().replaceAll('Exception: ', '')}',
        isError: true,
      );
    }
  }

  Future<void> _onEliminarPermanentePressed(Partido partido) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '⚠️ ELIMINAR PERMANENTEMENTE',
          style: TextStyle(color: Colors.red),
        ),
        content: Text(
          '¿Está COMPLETAMENTE SEGURO de eliminar este partido?\n\n'
          'Rival: ${partido.equipoRival}\n'
          'Formación: ${partido.formacion}\n\n'
          '⚠️ ESTA ACCIÓN NO SE PUEDE DESHACER.\n'
          'Se perderán TODOS los datos relacionados con este partido.',
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
      final exito = await _controller.eliminarPermanentemente(partido.idPartidos);
      if (exito) {
        _showSnackBar('Partido vs ${partido.equipoRival} eliminado permanentemente');
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
        'SCORD - Partidos Eliminados',
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
    drawer: AdminDrawer(currentRoute: '/HistorialPartidos'),
    
    body: _controller.loading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              // Barra de búsqueda
              SearchBarHistorial(
                controller: _searchController,
                onChanged: _onSearchChanged,
                hintText: 'Buscar por rival o formación...',
              ),

              // Contador
              ContadorResultados(
                cantidad: _partidosFiltrados.length,
                texto: 'partido(s) eliminado(s)',
              ),
              const SizedBox(height: 8),

              // Lista
              Expanded(
                child: _partidosFiltrados.isEmpty
                    ? const EmptyState(
                        mensaje: 'No hay partidos eliminados',
                        icono: Icons.sports,
                      )
                    : ListView.builder(
                        itemCount: _partidosFiltrados.length,
                        itemBuilder: (context, index) {
                          final partido = _partidosFiltrados[index];
                          
                          return ItemEliminadoCard(
                            titulo: 'vs ${partido.equipoRival}',
                            subtitulo1: 'Formación: ${partido.formacion}',
                            subtitulo2: null,
                            subtitulo3: null,
                            inicial: partido.equipoRival[0],
                            onRestaurar: () => _onRestaurarPressed(partido),
                            onEliminarPermanente: () => _onEliminarPermanentePressed(partido),
                          );
                        },
                      ),
              ),
            ],
          ),
  );
}

}