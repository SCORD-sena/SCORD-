import 'package:flutter/material.dart';
import '../../../controllers/admin/historiales/historial_rendimientos_controller.dart';
import '../../../models/rendimiento_eliminado_model.dart';
import '../../../widgets/admin/historial/item_eliminado_card.dart';
import '../../../widgets/admin/historial/search_bar_historial.dart';
import '../../../widgets/admin/historial/contador_resultados.dart';
import '../../../widgets/admin/historial/empty_state.dart';
import '../../../widgets/common/admin_drawer.dart';

class HistorialRendimientosScreen extends StatefulWidget {
  const HistorialRendimientosScreen({super.key});

  @override
  State<HistorialRendimientosScreen> createState() => _HistorialRendimientosScreenState();
}

class _HistorialRendimientosScreenState extends State<HistorialRendimientosScreen> {
  late HistorialRendimientosController _controller;
  final TextEditingController _searchController = TextEditingController();
  List<RendimientoEliminado> _rendimientosFiltrados = [];

  @override
  void initState() {
    super.initState();
    _controller = HistorialRendimientosController();
    _controller.addListener(_onControllerChanged);
    _cargarDatos();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {
        _rendimientosFiltrados = _controller.rendimientosFiltrados;
      });
    }
  }

  Future<void> _cargarDatos() async {
    try {
      await _controller.inicializar();
      setState(() {
        _rendimientosFiltrados = _controller.rendimientosFiltrados;
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
      _rendimientosFiltrados = _controller.buscarRendimientos(query);
    });
  }

  Future<void> _onRestaurarPressed(RendimientoEliminado rendimiento) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Restaurar Rendimiento?'),
        content: Text(
          '¿Desea restaurar este registro de rendimiento?\n\n'
          'Jugador: ${rendimiento.jugador.nombreCompleto}\n'
          'Partido: vs ${rendimiento.partido.equipoRival}\n'
          'Competencia: ${rendimiento.partido.cronograma.competencia?.nombre ?? "Sin competencia"}\n'
          'Goles: ${rendimiento.goles} • Asistencias: ${rendimiento.asistencias}\n\n'
          'Este rendimiento volverá a estar activo en el sistema.',
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
      final exito = await _controller.restaurarRendimiento(rendimiento.idRendimientos);
      if (exito) {
        _showSnackBar('Rendimiento restaurado correctamente');
      }
    } catch (e) {
      _showSnackBar(
        'Error: ${e.toString().replaceAll('Exception: ', '')}',
        isError: true,
      );
    }
  }

  Future<void> _onEliminarPermanentePressed(RendimientoEliminado rendimiento) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '⚠️ ELIMINAR PERMANENTEMENTE',
          style: TextStyle(color: Colors.red),
        ),
        content: Text(
          '¿Está COMPLETAMENTE SEGURO de eliminar este rendimiento?\n\n'
          'Jugador: ${rendimiento.jugador.nombreCompleto}\n'
          'Partido: vs ${rendimiento.partido.equipoRival}\n'
          'Competencia: ${rendimiento.partido.cronograma.competencia?.nombre ?? "Sin competencia"}\n'
          'Goles: ${rendimiento.goles} • Asistencias: ${rendimiento.asistencias}\n\n'
          '⚠️ ESTA ACCIÓN NO SE PUEDE DESHACER.\n'
          'Se perderán TODAS las estadísticas de este rendimiento.',
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
      final exito = await _controller.eliminarPermanentemente(rendimiento.idRendimientos);
      if (exito) {
        _showSnackBar('Rendimiento eliminado permanentemente');
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
        'SCORD - Rendimientos Eliminados',
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
    drawer: AdminDrawer(currentRoute: '/HistorialRendimientos'),
    
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

                    // Dropdown Jugador
                    DropdownButtonFormField<int>(
                      value: _controller.jugadorSeleccionadoId,
                      decoration: InputDecoration(
                        labelText: 'Jugador',
                        prefixIcon: const Icon(Icons.person, color: Colors.red),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('Todos los jugadores'),
                        ),
                        ..._controller.jugadoresDisponibles.map((jugador) {
                          return DropdownMenuItem<int>(
                            value: jugador.idJugadores,
                            child: Text('${jugador.nombreCompleto} (#${jugador.dorsal})'),
                          );
                        }),
                      ],
                      onChanged: _controller.categoriaSeleccionadaId == null
                          ? null
                          : (value) {
                              _controller.seleccionarJugador(value);
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
                hintText: 'Buscar por jugador, rival, competencia...',
              ),

              // Contador
              ContadorResultados(
                cantidad: _rendimientosFiltrados.length,
                texto: 'rendimiento(s) eliminado(s)',
              ),
              const SizedBox(height: 8),

              // Lista
              Expanded(
                child: _rendimientosFiltrados.isEmpty
                    ? const EmptyState(
                        mensaje: 'No hay rendimientos eliminados',
                        icono: Icons.trending_up,
                      )
                    : ListView.builder(
                        itemCount: _rendimientosFiltrados.length,
                        itemBuilder: (context, index) {
                          final rendimiento = _rendimientosFiltrados[index];
                          
                          return ItemEliminadoCard(
                            titulo: rendimiento.jugador.nombreCompleto,
                            subtitulo1: 'vs ${rendimiento.partido.equipoRival} • ${rendimiento.partido.cronograma.competencia?.nombre ?? "Sin competencia"}',
                            subtitulo2: '⚽ ${rendimiento.goles}G • 🎯 ${rendimiento.asistencias}A • ⏱️ ${rendimiento.minutosJugados}\'',
                            subtitulo3: '🟨 ${rendimiento.tarjetasAmarillas} • 🟥 ${rendimiento.tarjetasRojas} • 🎯 ${rendimiento.tirosApuerta} tiros',
                            inicial: rendimiento.jugador.persona.nombre1[0],
                            onRestaurar: () => _onRestaurarPressed(rendimiento),
                            onEliminarPermanente: () => _onEliminarPermanentePressed(rendimiento),
                          );
                        },
                      ),
              ),
            ],
          ),
  );
}
}