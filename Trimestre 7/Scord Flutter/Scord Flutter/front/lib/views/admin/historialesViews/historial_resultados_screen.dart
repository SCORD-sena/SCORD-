import 'package:flutter/material.dart';
import '../../../controllers/admin/historiales/historial_resultados_controller.dart';
import '../../../models/resultado_eliminado_model.dart';
import '../../../widgets/admin/historial/item_eliminado_card.dart';
import '../../../widgets/admin/historial/search_bar_historial.dart';
import '../../../widgets/admin/historial/contador_resultados.dart';
import '../../../widgets/admin/historial/empty_state.dart';
import '../../../widgets/common/admin_drawer.dart';

class HistorialResultadosScreen extends StatefulWidget {
  const HistorialResultadosScreen({super.key});

  @override
  State<HistorialResultadosScreen> createState() => _HistorialResultadosScreenState();
}

class _HistorialResultadosScreenState extends State<HistorialResultadosScreen> {
  late HistorialResultadosController _controller;
  final TextEditingController _searchController = TextEditingController();
  List<ResultadoEliminado> _resultadosFiltrados = [];

  @override
  void initState() {
    super.initState();
    _controller = HistorialResultadosController();
    _controller.addListener(_onControllerChanged);
    _cargarDatos();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {
        _resultadosFiltrados = _controller.resultadosFiltrados;
      });
    }
  }

  Future<void> _cargarDatos() async {
    try {
      await _controller.inicializar();
      setState(() {
        _resultadosFiltrados = _controller.resultadosFiltrados;
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
      _resultadosFiltrados = _controller.buscarResultados(query);
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

  Future<void> _onRestaurarPressed(ResultadoEliminado resultado) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Restaurar Resultado?'),
        content: Text(
          '¿Desea restaurar este resultado?\n\n'
          'Partido: vs ${resultado.partido.equipoRival}\n'
          'Marcador: ${resultado.marcador}\n'
          'Puntos: ${resultado.puntosObtenidos}\n'
          'Competencia: ${resultado.partido.cronograma.competencia?.nombre ?? "Sin competencia"}\n\n'
          'Este resultado volverá a estar activo en el sistema.',
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
      final exito = await _controller.restaurarResultado(resultado.idResultados);
      if (exito) {
        _showSnackBar('Resultado restaurado correctamente');
      }
    } catch (e) {
      _showSnackBar(
        'Error: ${e.toString().replaceAll('Exception: ', '')}',
        isError: true,
      );
    }
  }

  Future<void> _onEliminarPermanentePressed(ResultadoEliminado resultado) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '⚠️ ELIMINAR PERMANENTEMENTE',
          style: TextStyle(color: Colors.red),
        ),
        content: Text(
          '¿Está COMPLETAMENTE SEGURO de eliminar este resultado?\n\n'
          'Partido: vs ${resultado.partido.equipoRival}\n'
          'Marcador: ${resultado.marcador}\n'
          'Puntos: ${resultado.puntosObtenidos}\n'
          'Competencia: ${resultado.partido.cronograma.competencia?.nombre ?? "Sin competencia"}\n\n'
          '⚠️ ESTA ACCIÓN NO SE PUEDE DESHACER.\n'
          'Se perderán TODOS los datos de este resultado.',
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
      final exito = await _controller.eliminarPermanentemente(resultado.idResultados);
      if (exito) {
        _showSnackBar('Resultado eliminado permanentemente');
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
        'SCORD - Resultados Eliminados',
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
    drawer: AdminDrawer(currentRoute: '/HistorialResultados'),
    
    body: _controller.loading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              // Filtros en cascada
              Container(
                color: Colors.grey.shade100,
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    // Dropdown Categoría
                    DropdownButtonFormField<int>(
                      value: _controller.categoriaSeleccionadaId,
                      decoration: InputDecoration(
                        labelText: 'Categoría',
                        prefixIcon: const Icon(Icons.category, color: Colors.red),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('Todas las categorías'),
                        ),
                        ..._controller.categorias.map((categoria) {
                          return DropdownMenuItem<int>(
                            value: categoria.idCategorias,
                            child: Text(categoria.descripcion),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        _controller.seleccionarCategoria(value);
                      },
                    ),

                    const SizedBox(height: 12),

                    // Dropdown Competencia
                    DropdownButtonFormField<int>(
                      value: _controller.competenciaSeleccionadaId,
                      decoration: InputDecoration(
                        labelText: 'Competencia',
                        prefixIcon: const Icon(Icons.emoji_events, color: Colors.red),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('Todas las competencias'),
                        ),
                        ..._controller.competenciasDisponibles.map((competencia) {
                          return DropdownMenuItem<int>(
                            value: competencia.idCompetencias,
                            child: Text('${competencia.nombre} (${competencia.ano})'),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        _controller.seleccionarCompetencia(value);
                      },
                    ),
                  ],
                ),
              ),

              // Barra de búsqueda
              SearchBarHistorial(
                controller: _searchController,
                onChanged: _onSearchChanged,
                hintText: 'Buscar por rival, marcador o competencia...',
              ),

              // Contador
              ContadorResultados(
                cantidad: _resultadosFiltrados.length,
                texto: 'resultado(s) eliminado(s)',
              ),
              const SizedBox(height: 8),

              // Lista
              Expanded(
                child: _resultadosFiltrados.isEmpty
                    ? const EmptyState(
                        mensaje: 'No hay resultados eliminados',
                        icono: Icons.emoji_events,
                      )
                    : ListView.builder(
                        itemCount: _resultadosFiltrados.length,
                        itemBuilder: (context, index) {
                          final resultado = _resultadosFiltrados[index];
                          
                          return ItemEliminadoCard(
                            titulo: 'vs ${resultado.partido.equipoRival}',
                            subtitulo1: '🏆 Marcador: ${resultado.marcador} • 📊 Puntos: ${resultado.puntosObtenidos}',
                            subtitulo2: '📅 ${_formatearFecha(resultado.partido.cronograma.fechaDeEventos)} • ${resultado.partido.cronograma.competencia?.nombre ?? "Sin competencia"}',
                            subtitulo3: resultado.observacion != null && resultado.observacion!.isNotEmpty
                                ? '📝 ${resultado.observacion}'
                                : null,
                            inicial: resultado.partido.equipoRival[0],
                            onRestaurar: () => _onRestaurarPressed(resultado),
                            onEliminarPermanente: () => _onEliminarPermanentePressed(resultado),
                          );
                        },
                      ),
              ),
            ],
          ),
  );
}
}