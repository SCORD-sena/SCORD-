import 'package:flutter/material.dart';
import '../../../controllers/admin/historiales/historial_categorias_controller.dart';
import '../../../models/categoria_model.dart';
import '../../../widgets/admin/historial/item_eliminado_card.dart';
import '../../../widgets/admin/historial/search_bar_historial.dart';
import '../../../widgets/admin/historial/contador_resultados.dart';
import '../../../widgets/admin/historial/empty_state.dart';
import '../../../widgets/common/admin_drawer.dart';

class HistorialCategoriasScreen extends StatefulWidget {
  const HistorialCategoriasScreen({super.key});

  @override
  State<HistorialCategoriasScreen> createState() => _HistorialCategoriasScreenState();
}

class _HistorialCategoriasScreenState extends State<HistorialCategoriasScreen> {
  late HistorialCategoriasController _controller;
  final TextEditingController _searchController = TextEditingController();
  List<Categoria> _categoriasFiltradas = [];

  @override
  void initState() {
    super.initState();
    _controller = HistorialCategoriasController();
    _controller.addListener(_onControllerChanged);
    _cargarDatos();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {
        _categoriasFiltradas = _controller.categoriasEliminadas;
      });
    }
  }

  Future<void> _cargarDatos() async {
    try {
      await _controller.inicializar();
      setState(() {
        _categoriasFiltradas = _controller.categoriasEliminadas;
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
      _categoriasFiltradas = _controller.buscarCategorias(query);
    });
  }

  Future<void> _onRestaurarPressed(Categoria categoria) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Restaurar Categoría?'),
        content: Text(
          '¿Desea restaurar la categoría "${categoria.descripcion}"?\n\n'
          'Tipo: ${categoria.tiposCategoria}\n\n'
          'Esta categoría volverá a estar activa en el sistema.',
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
      final exito = await _controller.restaurarCategoria(categoria.idCategorias);
      if (exito) {
        _showSnackBar('${categoria.descripcion} restaurada correctamente');
      }
    } catch (e) {
      _showSnackBar(
        'Error: ${e.toString().replaceAll('Exception: ', '')}',
        isError: true,
      );
    }
  }

  Future<void> _onEliminarPermanentePressed(Categoria categoria) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '⚠️ ELIMINAR PERMANENTEMENTE',
          style: TextStyle(color: Colors.red),
        ),
        content: Text(
          '¿Está COMPLETAMENTE SEGURO de eliminar la categoría "${categoria.descripcion}"?\n\n'
          'Tipo: ${categoria.tiposCategoria}\n\n'
          '⚠️ ESTA ACCIÓN NO SE PUEDE DESHACER.\n'
          'Se perderán TODOS los datos relacionados con esta categoría.',
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
      final exito = await _controller.eliminarPermanentemente(categoria.idCategorias);
      if (exito) {
        _showSnackBar('${categoria.descripcion} eliminada permanentemente');
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
        'SCORD - Categorías Eliminadas',
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
    
    drawer:AdminDrawer(currentRoute: '/HistorialCategorias'),
    
    body: _controller.loading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              // Barra de búsqueda
              SearchBarHistorial(
                controller: _searchController,
                onChanged: _onSearchChanged,
                hintText: 'Buscar por descripción o tipo de categoría...',
              ),

              // Contador
              ContadorResultados(
                cantidad: _categoriasFiltradas.length,
                texto: 'categoría(s) eliminada(s)',
              ),
              const SizedBox(height: 8),

              // Lista
              Expanded(
                child: _categoriasFiltradas.isEmpty
                    ? const EmptyState(
                        mensaje: 'No hay categorías eliminadas',
                        icono: Icons.category,
                      )
                    : ListView.builder(
                        itemCount: _categoriasFiltradas.length,
                        itemBuilder: (context, index) {
                          final categoria = _categoriasFiltradas[index];
                          return ItemEliminadoCard(
                            titulo: categoria.descripcion,
                            subtitulo1: 'Tipo: ${categoria.tiposCategoria}',
                            subtitulo2: null,
                            subtitulo3: null,
                            inicial: categoria.descripcion[0],
                            onRestaurar: () => _onRestaurarPressed(categoria),
                            onEliminarPermanente: () => _onEliminarPermanentePressed(categoria),
                          );
                        },
                      ),
              ),
            ],
          ),
  );
}
}