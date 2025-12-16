import 'package:flutter/material.dart';
import '../../controllers/admin/estadisticas_controller.dart';
import '../../widgets/admin/estadisticas/botones_accion.dart';
import '../../widgets/admin/estadisticas/info_jugador_card.dart';
import '../../widgets/admin/estadisticas/estadisticas_card.dart';
import '../../widgets/admin/estadisticas/seleccionar_tipo_reporte_dialog.dart';
import '../../widgets/common/custom_alert.dart';
import '../../models/pdf_report_config.dart';
import 'agregar_rendimiento_screen.dart';

class EstadisticasJugadorScreen extends StatefulWidget {
  const EstadisticasJugadorScreen({super.key});

  @override
  State<EstadisticasJugadorScreen> createState() => _EstadisticasJugadorScreenState();
}

class _EstadisticasJugadorScreenState extends State<EstadisticasJugadorScreen> {
  late EstadisticasController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = EstadisticasController();
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
      MaterialPageRoute(builder: (context) => const AgregarRendimientoScreen()),
    );
    if (_controller.jugadorSeleccionado != null) {
      await _controller.fetchEstadisticasTotales(_controller.jugadorSeleccionado!.idJugadores);
    }
  }

  void _onEditarPressed() {
    try {
      _controller.activarEdicion();
    } catch (e) {
      CustomAlert.mostrar(context, 'Error', e.toString(), Colors.orange);
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

    try {
      final exito = await _controller.guardarCambios(context);
      if (exito) {
        CustomAlert.mostrar(context, 'Estadísticas actualizadas', 'Los datos se actualizaron correctamente.', Colors.green);
      }
    } catch (e) {
      CustomAlert.mostrar(context, 'Error', 'No se pudo actualizar las estadísticas', Colors.red);
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
        CustomAlert.mostrar(context, '¡Estadística eliminada!', 'El último registro se eliminó correctamente', Colors.green);
      }
    } catch (e) {
      CustomAlert.mostrar(context, 'Error', e.toString(), Colors.red);
    }
  }
  
  // 🆕 BOTÓN PDF CON SELECCIÓN DE TIPO DE REPORTE
  void _onGenerarReportePressed() async {
    if (_controller.jugadorSeleccionado == null) {
      CustomAlert.mostrar(
        context,
        'Sin jugador',
        'Por favor selecciona un jugador primero',
        Colors.orange,
      );
      return;
    }

    // 🔍 DEBUG: Imprimir competencias
    print('DEBUG: Competencias filtradas: ${_controller.competenciasFiltradas}');
    print('DEBUG: Primera competencia: ${_controller.competenciasFiltradas.isNotEmpty ? _controller.competenciasFiltradas.first : "vacío"}');

    final competencias = _controller.competenciasFiltradas
        .map((comp) {
          print('DEBUG: idCompetencias = ${comp.idCompetencias} (tipo: ${comp.idCompetencias.runtimeType})');
          print('DEBUG: nombre = ${comp.nombre}');
          
          return {
            'idCompetencias': comp.idCompetencias,
            'Nombre': comp.nombre,
            'Descripcion': comp.descripcion ?? '',
          };
        })
        .toList();

    print('DEBUG: Competencias mapeadas: $competencias');

    showDialog(
      context: context,
      builder: (context) => SeleccionarTipoReporteDialog(
        competencias: competencias,
        onSeleccionar: (config) async {
          print('DEBUG: Config seleccionado - idCompetencia: ${config.idCompetencia}');
          await _generarPdf(config);
        },
      ),
    );
  }

  // 🆕 GENERAR PDF CON CONFIGURACIÓN
  Future<void> _generarPdf(PdfReportConfig config) async {
    if (_controller.jugadorSeleccionado == null) return;

    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generando reporte PDF...'),
                ],
              ),
            ),
          ),
        ),
      );

      final rutaArchivo = await _controller.generarReporteJugador(config);

      // Cerrar indicador de carga
      if (mounted) Navigator.of(context).pop();

      if (rutaArchivo != null) {
        if (mounted) {
          CustomAlert.mostrar(
            context,
            'Reporte Generado',
            rutaArchivo,
            Colors.green,
          );
        }
      }
    } catch (e) {
      // Cerrar indicador de carga
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (mounted) {
        CustomAlert.mostrar(
          context,
          'Error',
          e.toString().replaceAll('Exception: ', ''),
          Colors.red,
        );
      }
    }
  }

  Widget _buildDrawerItem(String title, IconData icon, String routeName) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xffe63946)),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: () {
        Navigator.of(context).pop();
        
        if (routeName == '/Logout') {
          // Lógica de deslogueo
        } else if (ModalRoute.of(context)?.settings.name != routeName) {
            Navigator.of(context).pushNamed(routeName); 
        }
      },
    );
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.picture_as_pdf, color: Color(0xffe63946), size: 28),
              tooltip: 'Generar Reporte PDF',
              onPressed: _controller.loading ? null : _onGenerarReportePressed,
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xffe63946)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Icon(Icons.sports_soccer, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'SCORD',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Text(
                    'Menú de Navegación',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem('Inicio', Icons.home, '/InicioAdmin'),
            _buildDrawerItem('Cronograma', Icons.calendar_month, '/CronogramaAdmin'),
            _buildDrawerItem('Perfil Jugador', Icons.person_pin, '/PerfilJugadorAdmin'),
            _buildDrawerItem('Estadísticas Jugadores', Icons.bar_chart, '/EstadisticasJugadores'),
            _buildDrawerItem('Perfil Entrenador', Icons.sports_gymnastics, '/PerfilEntrenadorAdmin'),
            _buildDrawerItem('Evaluar Jugadores', Icons.rule, '/EvaluarJugadores'),
            const Divider(),
            _buildDrawerItem('Cerrar Sesión', Icons.logout, '/Logout'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Botones de acción (sin PDF duplicado)
          BotonesAccion(
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
                  // Card de Información del Jugador
                  InfoJugadorCard(
                    categorias: _controller.categorias,
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
                  EstadisticasCard(
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