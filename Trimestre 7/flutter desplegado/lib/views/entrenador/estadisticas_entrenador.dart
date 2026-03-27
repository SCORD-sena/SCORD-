import 'package:flutter/material.dart';
import '../../controllers/entrenador/estadisticas_entrenador_controller.dart';
import '../../widgets/entrenador/estadisticas/botones_accion_entrenador.dart';
import '../../widgets/entrenador/estadisticas/info_jugador_entrenador_card.dart';
import '../../widgets/entrenador/estadisticas/estadisticas_entrenador_card.dart';
import '../../widgets/admin/estadisticas/seleccionar_competencia_partido_dialog.dart'; // 🆕 Reutilizamos el mismo diálogo
import '../../widgets/common/custom_alert.dart';
import '../../widgets/common/EntrenadorDrawer.dart';
import 'agregar_rendimiento_entrenador_screen.dart';


class EstadisticasJugadorEntrenadorScreen extends StatefulWidget {
  const EstadisticasJugadorEntrenadorScreen({super.key});

  @override
  State<EstadisticasJugadorEntrenadorScreen> createState() => _EstadisticasJugadorEntrenadorScreenState();
}

class _EstadisticasJugadorEntrenadorScreenState extends State<EstadisticasJugadorEntrenadorScreen> {
  late EstadisticasEntrenadorController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EstadisticasEntrenadorController();
    _controller.addListener(_onControllerChanged);
    _controller.inicializar();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  // --- Handlers de botones ---

  void _onAgregarPressed() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AgregarRendimientoEntrenadorScreen()),
    );
    if (_controller.jugadorSeleccionado != null) {
      await _controller.fetchEstadisticasTotales(_controller.jugadorSeleccionado!.idJugadores);
    }
  }

  // 🆕 HANDLER EDITAR CON SELECCIÓN DE COMPETENCIA Y PARTIDO
  void _onEditarPressed() async {
    // Validar que hay jugador seleccionado
    if (_controller.jugadorSeleccionado == null) {
      await CustomAlert.mostrar(
        context,
        'Sin jugador',
        'Por favor selecciona un jugador primero',
        Colors.orange,
      );
      return;
    }

    // Validar que hay competencias disponibles
    if (_controller.competenciasFiltradas.isEmpty) {
      await CustomAlert.mostrar(
        context,
        'Sin competencias',
        'No hay competencias disponibles para esta categoría',
        Colors.orange,
      );
      return;
    }

    // 🔍 Mostrar diálogo para seleccionar competencia y partido
    final resultado = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => SeleccionarCompetenciaPartidoDialog(
        competencias: _controller.competenciasFiltradas,
        onCompetenciaSeleccionada: (idCompetencia) async {
          // Cargar partidos de esa competencia
          return await _controller.cargarPartidosPorCompetenciaParaEditar(idCompetencia);
        },
      ),
    );

    // Si el usuario canceló
    if (resultado == null) return;

    // resultado = {'idCompetencia': X, 'idPartido': Y}
    
    try {
      // 🔄 Cargar estadísticas específicas del partido seleccionado
      await _controller.cargarEstadisticasParaEditar(
        resultado['idCompetencia'],
        resultado['idPartido'],
      );
      
      // ✅ Activar modo edición
      _controller.activarEdicion();
      
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

  void _onGuardarPressed() async {
    final confirm = await CustomAlert.confirmar(
      context,
      '¿Estás Seguro?',
      'Goles: ${_controller.formData['goles']}\nAsistencias: ${_controller.formData['asistencias']}\nMinutos: ${_controller.formData['minutosJugados']}',
      'Sí, actualizar',
      Colors.green,
    );

    if (!confirm) return;

    if (!mounted) return;

    try {
      final exito = await _controller.guardarCambios(context);
      if (exito) {
      }
    } catch (e) {
      rethrow;
    }
  }

  void _onEliminarPressed() async {
    final confirm = await CustomAlert.confirmar(
      context,
      '¿Estás seguro?',
      'Se eliminará el último registro de estadísticas',
      'Sí, eliminar',
      Colors.red,
    );

    if (!confirm) return;

    try {
      final exito = await _controller.eliminarEstadistica();
      if (exito) {
      }
    } catch (e) {
      rethrow;
    }
  }


  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'SCORD - Estadísticas',
        style: TextStyle(
          color: Color(0xffe63946),
          fontWeight: FontWeight.bold,
          fontSize: 18
        )
      ),
      backgroundColor: Colors.white,
      elevation: 1,
      iconTheme: const IconThemeData(color: Color(0xffe63946)),
    ),
    drawer: EntrenadorDrawer(currentRoute: '/EstadisticasJugadoresEntrenador'), // ✅ NUEVO
    body: Column(
      children: [
        // Botones de acción con curvas
        BotonesAccionEntrenador(
          modoEdicion: _controller.modoEdicion,
          loading: _controller.loading,
          onAgregar: _onAgregarPressed,
          onEditar: _onEditarPressed,
          onEliminar: _onEliminarPressed,
          onGuardar: _onGuardarPressed,
          onCancelar: _controller.cancelarEdicion,
        ),
        
        // Contenido principal
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card de Información del Jugador con filtros
                InfoJugadorEntrenadorCard(
                  categorias: _controller.categoriasEntrenador, // ⭐ Solo sus categorías
                  jugadoresFiltrados: _controller.jugadoresFiltrados,
                  competenciasFiltradas: _controller.competenciasFiltradas,
                  partidosFiltrados: _controller.partidosFiltrados,
                  categoriaSeleccionadaId: _controller.categoriaSeleccionadaId,
                  competenciaSeleccionada: _controller.competenciaSeleccionada,
                  partidoSeleccionado: _controller.partidoSeleccionado,
                  jugadorSeleccionado: _controller.jugadorSeleccionado,
                  modoEdicion: _controller.modoEdicion,
                  isLoadingCompetencias: _controller.isLoadingCompetencias,
                  isLoadingPartidos: _controller.isLoadingPartidos,
                  onCategoriaChanged: _controller.seleccionarCategoria,
                  onJugadorChanged: _controller.seleccionarJugador,
                  onCompetenciaChanged: _controller.seleccionarCompetencia,
                  onPartidoChanged: _controller.seleccionarPartido,
                  calcularEdad: _controller.calcularEdad,
                ),

                const SizedBox(height: 16),

                // Card de Estadísticas
                EstadisticasEntrenadorCard(
                  loading: _controller.loading,
                  modoEdicion: _controller.modoEdicion,
                  estadisticasTotales: _controller.estadisticasTotales,
                  formData: _controller.formData,
                  onCampoChanged: _controller.actualizarCampo,
                ),
              ],
            ),
          ),
        ),
      ],
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