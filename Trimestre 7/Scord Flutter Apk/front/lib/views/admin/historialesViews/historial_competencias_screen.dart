import 'package:flutter/material.dart';
import '../../../controllers/admin/historiales/historial_competencias_controller.dart';
import '../../../models/competencia_model.dart';
import '../../../widgets/admin/historial/item_eliminado_card.dart';
import '../../../widgets/admin/historial/search_bar_historial.dart';
import '../../../widgets/admin/historial/contador_resultados.dart';
import '../../../widgets/admin/historial/empty_state.dart';
import '../../../widgets/common/admin_drawer.dart';

class HistorialCompetenciasScreen extends StatefulWidget {
  const HistorialCompetenciasScreen({super.key});

  @override
  State<HistorialCompetenciasScreen> createState() => _HistorialCompetenciasScreenState();
}

class _HistorialCompetenciasScreenState extends State<HistorialCompetenciasScreen> {
  late HistorialCompetenciasController _controller;
  final TextEditingController _searchController = TextEditingController();
  List<Competencia> _competenciasFiltradas = [];

  @override
  void initState() {
    super.initState();
    _controller = HistorialCompetenciasController();
    _controller.addListener(_onControllerChanged);
    _cargarDatos();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {
        _competenciasFiltradas = _controller.competenciasEliminadas;
      });
    }
  }

  Future<void> _cargarDatos() async {
    try {
      await _controller.inicializar();
      setState(() {
        _competenciasFiltradas = _controller.competenciasEliminadas;
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
      _competenciasFiltradas = _controller.buscarCompetencias(query);
    });
  }

  Future<void> _onRestaurarPressed(Competencia competencia) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Restaurar Competencia?'),
        content: Text(
          '¿Desea restaurar esta competencia?\n\n'
          'Nombre: ${competencia.nombre}\n'
          'Tipo: ${competencia.tipoCompetencia}\n'
          'Año: ${competencia.ano}\n\n'
          'Esta competencia volverá a estar activa en el sistema.',
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
      final exito = await _controller.restaurarCompetencia(competencia.idCompetencias);
      if (exito) {
        _showSnackBar('${competencia.nombre} restaurada correctamente');
      }
    } catch (e) {
      _showSnackBar(
        'Error: ${e.toString().replaceAll('Exception: ', '')}',
        isError: true,
      );
    }
  }

  Future<void> _onEliminarPermanentePressed(Competencia competencia) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '⚠️ ELIMINAR PERMANENTEMENTE',
          style: TextStyle(color: Colors.red),
        ),
        content: Text(
          '¿Está COMPLETAMENTE SEGURO de eliminar esta competencia?\n\n'
          'Nombre: ${competencia.nombre}\n'
          'Tipo: ${competencia.tipoCompetencia}\n'
          'Año: ${competencia.ano}\n\n'
          '⚠️ ESTA ACCIÓN NO SE PUEDE DESHACER.\n'
          'Se perderán TODOS los datos relacionados con esta competencia.',
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
      final exito = await _controller.eliminarPermanentemente(competencia.idCompetencias);
      if (exito) {
        _showSnackBar('${competencia.nombre} eliminada permanentemente');
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
        'SCORD - Competencias Eliminadas',
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
    drawer: AdminDrawer(currentRoute: '/HistorialCompetencias'),
    
    body: _controller.loading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              // Barra de búsqueda
              SearchBarHistorial(
                controller: _searchController,
                onChanged: _onSearchChanged,
                hintText: 'Buscar por nombre, tipo o año...',
              ),

              // Contador
              ContadorResultados(
                cantidad: _competenciasFiltradas.length,
                texto: 'competencia(s) eliminada(s)',
              ),
              const SizedBox(height: 8),

              // Lista
              Expanded(
                child: _competenciasFiltradas.isEmpty
                    ? const EmptyState(
                        mensaje: 'No hay competencias eliminadas',
                        icono: Icons.workspace_premium,
                      )
                    : ListView.builder(
                        itemCount: _competenciasFiltradas.length,
                        itemBuilder: (context, index) {
                          final competencia = _competenciasFiltradas[index];
                          
                          return ItemEliminadoCard(
                            titulo: competencia.nombre,
                            subtitulo1: 'Tipo: ${competencia.tipoCompetencia}',
                            subtitulo2: 'Año: ${competencia.ano}',
                            subtitulo3: null,
                            inicial: competencia.nombre[0],
                            onRestaurar: () => _onRestaurarPressed(competencia),
                            onEliminarPermanente: () => _onEliminarPermanentePressed(competencia),
                          );
                        },
                      ),
              ),
            ],
          ),
  );
}
}