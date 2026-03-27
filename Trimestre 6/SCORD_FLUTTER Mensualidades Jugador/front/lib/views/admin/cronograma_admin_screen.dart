import 'package:flutter/material.dart';
import '../../controllers/admin/cronograma_admin_controller.dart';
import '../../widgets/admin/cronogramas/cronograma_entrenamientos_section.dart';
import '../../widgets/admin/cronogramas/cronograma_partidos_section.dart';

class CronogramaAdminScreen extends StatefulWidget {
  const CronogramaAdminScreen({Key? key}) : super(key: key);

  @override
  State<CronogramaAdminScreen> createState() => _CronogramaAdminScreenState();
}

class _CronogramaAdminScreenState extends State<CronogramaAdminScreen> {
  final CronogramaAdminController _controller = CronogramaAdminController();
  final GlobalKey<FormState> _formKeyEntrenamiento = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyPartido = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ============================================================
  // CARGAR DATOS
  // ============================================================

  Future<void> _loadData() async {
    try {
      await _controller.loadData();
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error al cargar datos', e.toString());
      }
    }
  }

  // ============================================================
  // DIÁLOGOS
  // ============================================================

  Future<void> _showSuccessDialog(String message) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¡Éxito!'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xffe63946))),
          ),
        ],
      ),
    );
  }

  Future<void> _showErrorDialog(String title, String message) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xffe63946))),
          ),
        ],
      ),
    );
  }

  Future<void> _showWarningDialog(String message) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Advertencia'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xffe63946))),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showConfirmDialog(String title, String message) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sí, eliminar'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HANDLERS PARTIDOS
  // ============================================================

  Future<void> _handleAgregarPartido() async {
    if (!_formKeyPartido.currentState!.validate()) return;

    if (_controller.categoriaPartidoSeleccionada == null) {
      _showWarningDialog('Por favor seleccione una categoría');
      return;
    }

    if (_controller.competenciaPartidoSeleccionada == null) {
      _showWarningDialog('Por favor seleccione una competencia');
      return;
    }

    try {
      await _controller.agregarPartido();
      if (mounted) {
        setState(() {});
        _showSuccessDialog('Partido agregado exitosamente');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error al agregar partido', e.toString());
      }
    }
  }

  Future<void> _handleActualizarPartido() async {
    if (!_formKeyPartido.currentState!.validate()) return;

    try {
      await _controller.actualizarPartido();
      if (mounted) {
        setState(() {});
        _showSuccessDialog('Partido actualizado exitosamente');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error al actualizar partido', e.toString());
      }
    }
  }

  Future<void> _handleEliminarPartido(int id) async {
    final confirm = await _showConfirmDialog(
      '¿Estás seguro?',
      'Esta acción no se puede deshacer',
    );

    if (confirm == true) {
      try {
        await _controller.eliminarPartido(id);
        if (mounted) {
          setState(() {});
          _showSuccessDialog('Partido eliminado exitosamente');
        }
      } catch (e) {
        if (mounted) {
          _showErrorDialog('Error al eliminar partido', e.toString());
        }
      }
    }
  }

  // ✅ CORREGIDO: Ahora con await
  Future<void> _handleEditarPartido(int idPartido) async {
    final partido = _controller.partidosAPI.firstWhere(
      (p) => p.idPartidos == idPartido,
    );
    
    await _controller.editarPartido(partido); // ✅ Esperar a que carguen las competencias
    
    if (mounted) {
      setState(() {});
    }
  }

  // ✅ HANDLER ACTUALIZADO - Categoría Partido (optimizado)
  Future<void> _handleCategoriaPartidoChanged(int? value) async {
    print('📝 Categoría seleccionada: $value');
    
    // No hacer setState aquí para evitar reconstrucción prematura
    _controller.categoriaPartidoSeleccionada = value;
    _controller.competenciaPartidoSeleccionada = null; // Resetear competencia

    if (value != null) {
      try {
        await _controller.loadCompetenciasByCategoria(value);
        print('✅ Competencias cargadas: ${_controller.competenciasFiltradas.length}');
      } catch (e) {
        print('❌ Error: $e');
        if (mounted) {
          _showErrorDialog('Error', 'No se pudieron cargar las competencias');
        }
      }
    } else {
      _controller.competenciasFiltradas = [];
    }
    
    // Un solo setState al final
    if (mounted) setState(() {});
  }

  // ✅ HANDLER - Competencia Partido
  void _handleCompetenciaPartidoChanged(int? value) {
    setState(() {
      _controller.competenciaPartidoSeleccionada = value;
    });
  }

  // ============================================================
  // HANDLERS ENTRENAMIENTOS
  // ============================================================

  Future<void> _handleAgregarEntrenamiento() async {
    if (!_formKeyEntrenamiento.currentState!.validate()) return;

    if (_controller.categoriaEntrenamientoSeleccionada == null) {
      _showWarningDialog('Por favor seleccione una categoría');
      return;
    }

    try {
      await _controller.agregarEntrenamiento();
      if (mounted) {
        setState(() {});
        _showSuccessDialog('Entrenamiento agregado exitosamente');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error al agregar entrenamiento', e.toString());
      }
    }
  }

  Future<void> _handleActualizarEntrenamiento() async {
    if (!_formKeyEntrenamiento.currentState!.validate()) return;

    try {
      await _controller.actualizarEntrenamiento();
      if (mounted) {
        setState(() {});
        _showSuccessDialog('Entrenamiento actualizado exitosamente');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error al actualizar entrenamiento', e.toString());
      }
    }
  }

  Future<void> _handleEliminarEntrenamiento(int id) async {
    final confirm = await _showConfirmDialog(
      '¿Estás seguro?',
      'Esta acción no se puede deshacer',
    );

    if (confirm == true) {
      try {
        await _controller.eliminarEntrenamiento(id);
        if (mounted) {
          setState(() {});
          _showSuccessDialog('Entrenamiento eliminado exitosamente');
        }
      } catch (e) {
        if (mounted) {
          _showErrorDialog('Error al eliminar entrenamiento', e.toString());
        }
      }
    }
  }

  // ✅ CORREGIDO: Ahora con await
  Future<void> _handleEditarEntrenamiento(int idCronograma) async {
    final cronograma = _controller.cronogramas.firstWhere(
      (c) => c.idCronogramas == idCronograma,
    );
    
    await _controller.editarEntrenamiento(cronograma); // ✅ Esperar a que carguen las competencias
    
    if (mounted) {
      setState(() {});
    }
  }

  // ✅ HANDLER - Categoría Entrenamiento (optimizado para evitar scroll jump)
  Future<void> _handleCategoriaEntrenamientoChanged(int? value) async {
    // No hacer setState aquí para evitar reconstrucción prematura
    _controller.categoriaEntrenamientoSeleccionada = value;

    if (value != null) {
      try {
        await _controller.loadCompetenciasByCategoria(value);
      } catch (e) {
        if (mounted) {
          _showErrorDialog('Error', 'No se pudieron cargar las competencias');
        }
      }
    }
    
    // Un solo setState al final
    if (mounted) setState(() {});
  }

  // ============================================================
  // OTROS HANDLERS
  // ============================================================

  void _handleCancelarEdicion() {
    setState(() {
      _controller.cancelarEdicion();
    });
  }

  void _handleSearchEntrenamiento(String value) {
    setState(() {
      _controller.searchTermEntrenamiento = value;
      _controller.currentPageEntrenamiento = 1;
    });
  }

  void _handleSearchPartido(String value) {
    setState(() {
      _controller.searchTermPartido = value;
      _controller.currentPagePartido = 1;
    });
  }

  void _handlePageChangeEntrenamiento(int page) {
    setState(() {
      _controller.currentPageEntrenamiento = page;
    });
  }

  void _handlePageChangePartido(int page) {
    setState(() {
      _controller.currentPagePartido = page;
    });
  }

  // ============================================================
  // DRAWER
  // ============================================================

  Widget _buildDrawerItem(String title, IconData icon, String routeName) {
    return ListTile(
      leading: Icon(icon, color: Colors.red),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: () {
        Navigator.of(context).pop();
        
        if (routeName == '/Logout') {
          Navigator.of(context).pushReplacementNamed('/');
        } else if (ModalRoute.of(context)?.settings.name != routeName) {
          Navigator.of(context).pushNamed(routeName);
        }
      },
    );
  }

  // ============================================================
  // BUILD UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SCORD - Calendario de Actividades',
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.red),
              child: Text(
                'Menú de Navegación',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
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
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PRIMERO: PARTIDOS
                  CronogramaPartidosSection(
                    controller: _controller,
                    formKey: _formKeyPartido,
                    onAgregar: _handleAgregarPartido,
                    onActualizar: _handleActualizarPartido,
                    onEliminar: _handleEliminarPartido,
                    onEditar: _handleEditarPartido,
                    onCancelar: _handleCancelarEdicion,
                    onSearch: _handleSearchPartido,
                    onPageChange: _handlePageChangePartido,
                    onCategoriaChanged: _handleCategoriaPartidoChanged,
                    onCompetenciaChanged: _handleCompetenciaPartidoChanged,
                  ),
                  
                  // SEPARADOR VISUAL
                  const SizedBox(height: 32),
                  Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.withOpacity(0.1),
                          Colors.red,
                          Colors.red.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // SEGUNDO: ENTRENAMIENTOS
                  CronogramaEntrenamientosSection(
                    controller: _controller,
                    formKey: _formKeyEntrenamiento,
                    onAgregar: _handleAgregarEntrenamiento,
                    onActualizar: _handleActualizarEntrenamiento,
                    onEliminar: _handleEliminarEntrenamiento,
                    onEditar: _handleEditarEntrenamiento,
                    onCancelar: _handleCancelarEdicion,
                    onSearch: _handleSearchEntrenamiento,
                    onPageChange: _handlePageChangeEntrenamiento,
                    onCategoriaChanged: _handleCategoriaEntrenamientoChanged,
                    onSedeChanged: (value) {
                      setState(() {
                        _controller.sedeEntrenamientoSeleccionada = value;
                      });
                    },
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