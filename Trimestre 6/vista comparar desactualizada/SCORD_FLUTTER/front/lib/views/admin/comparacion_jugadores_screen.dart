import 'package:flutter/material.dart';
import '../../controllers/admin/comparacion_jugadores_controller.dart';
import '../../models/categoria_model.dart';
import '../../models/jugador_model.dart'; // ✅ IMPORTAR EL MODELO
import '../../widgets/admin/comparar_jugadores/comparacion_chart_widget.dart';
import '../../widgets/admin/comparar_jugadores/comparacion_table_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ComparacionJugadoresScreen extends StatefulWidget {
  const ComparacionJugadoresScreen({Key? key}) : super(key: key);

  @override
  State<ComparacionJugadoresScreen> createState() =>
      _ComparacionJugadoresScreenState();
}

class _ComparacionJugadoresScreenState
    extends State<ComparacionJugadoresScreen> {
  final ComparacionJugadoresController _controller =
      ComparacionJugadoresController();

  List<Categoria> _categorias = [];
  Categoria? _categoriaSeleccionada;
  List<Jugador> _jugadores = []; // ✅ CAMBIADO DE Map A Jugador

  int? _jugador1Id;
  int? _jugador2Id;
  String? _jugador1Nombre;
  String? _jugador2Nombre;

  Map<String, dynamic>? _estadisticasComparadas;

  bool _isLoadingCategorias = true;
  bool _isLoadingJugadores = false;
  bool _isLoadingEstadisticas = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  Future<void> _cargarCategorias() async {
    setState(() {
      _isLoadingCategorias = true;
      _errorMessage = null;
    });

    try {
      final categorias = await _controller.cargarCategorias();
      setState(() {
        _categorias = categorias;
        _isLoadingCategorias = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar las categorías';
        _isLoadingCategorias = false;
      });
    }
  }

  Future<void> _cargarJugadoresPorCategoria(int idCategoria) async {
    setState(() {
      _isLoadingJugadores = true;
      _jugadores = []; // ✅ CORREGIDO
      _jugador1Id = null;
      _jugador2Id = null;
      _jugador1Nombre = null;
      _jugador2Nombre = null;
      _estadisticasComparadas = null;
      _errorMessage = null;
    });

    try {
      final jugadores =
          await _controller.cargarJugadoresPorCategoria(idCategoria); // ✅ CAMBIADO
      setState(() {
        _jugadores = jugadores; // ✅ CORREGIDO
        _isLoadingJugadores = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar los jugadores';
        _isLoadingJugadores = false;
      });
    }
  }

  Future<void> _cargarEstadisticasComparadas() async {
    if (_jugador1Id == null || _jugador2Id == null) return;

    setState(() {
      _isLoadingEstadisticas = true;
      _errorMessage = null;
    });

    try {
      final estadisticas = await _controller.cargarEstadisticasComparadas(
        _jugador1Id!,
        _jugador2Id!,
      );

      setState(() {
        _estadisticasComparadas = estadisticas;
        _isLoadingEstadisticas = false;

        if (estadisticas['error'] != null) {
          _errorMessage = estadisticas['error'];
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar las estadísticas';
        _isLoadingEstadisticas = false;
      });
    }
  }

  String _obtenerNombreJugador(int jugadorId) {
    try {
      final jugador = _jugadores.firstWhere(
        (j) => j.idJugadores == jugadorId,
      );
      // ✅ CORREGIDO con campos correctos de la BD
      final nombre1 = jugador.persona?.nombre1 ?? '';
      final nombre2 = jugador.persona?.nombre2 ?? '';
      final apellido1 = jugador.persona?.apellido1 ?? '';
      final apellido2 = jugador.persona?.apellido2 ?? '';
      
      return '$nombre1 $nombre2 $apellido1 $apellido2'.trim().replaceAll(RegExp(r'\s+'), ' ');
    } catch (e) {
      return 'Jugador $jugadorId';
    }
  }

  Widget _buildDrawerItem(String title, IconData icon, String routeName) {
    return ListTile(
      leading: Icon(icon, color: Color(0xffe63946)),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: () {
        Navigator.of(context).pop();

        Future<void> _logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  // Navegar al login y eliminar historial
  if (mounted) {
    Navigator.of(context).pushNamedAndRemoveUntil('/Login', (route) => false);
  }
}


        if (routeName == '/Logout') {
          _logout();// Implementar función de logout
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
        title: const Text('Comparación de Jugadores'),
        backgroundColor: const Color(0xFFE63946),
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xffe63946)),
              child: Text(
                'Menú de Navegación',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
            ),

            _buildDrawerItem('Inicio', Icons.home, '/InicioAdmin'),
            _buildDrawerItem('Cronograma', Icons.calendar_month, '/Cronograma'),
            _buildDrawerItem(
                'Perfil Jugador', Icons.person_pin, '/PerfilJugadorAdmin'),
            _buildDrawerItem('Estadísticas Jugadores', Icons.bar_chart,
                '/EstadisticasJugadores'),
            _buildDrawerItem('Perfil Entrenador', Icons.sports_gymnastics,
                '/PerfilEntrenadorAdmin'),
            _buildDrawerItem(
                'Comparar Jugadores', Icons.rule, '/ComparacionJugadores'),

            const Divider(),

            _buildDrawerItem('Cerrar Sesión', Icons.logout, '/Logout'),
          ],
        ),
      ),
      body: _isLoadingCategorias
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Comparación de Jugadores',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Compare estadísticas entre jugadores para identificar fortalezas, áreas de mejora y crear estrategias más efectivas.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        border: Border.all(color: Colors.red[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () {
                              setState(() {
                                _errorMessage = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '📋 Seleccione una Categoría',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<Categoria>(
                            value: _categoriaSeleccionada,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            hint: const Text('Seleccione una categoría'),
                            items: _categorias.map((categoria) {
                              return DropdownMenuItem<Categoria>(
                                value: categoria,
                                child: Text(categoria.descripcion ?? ''),
                              );
                            }).toList(),
                            onChanged: (Categoria? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _categoriaSeleccionada = newValue;
                                });
                                _cargarJugadoresPorCategoria(
                                    newValue.idCategorias!);
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          if (_categoriaSeleccionada != null) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '👤 Jugador 1',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      DropdownButtonFormField<int>(
                                        value: _jugador1Id,
                                        isExpanded: true,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                        ),
                                        hint: const Text('Seleccione jugador'),
                                        items: _jugadores.map((jugador) { // ✅ CORREGIDO
                                          // ✅ Usar campos correctos de la BD
                                          final nombre1 = jugador.persona?.nombre1 ?? '';
                                          final nombre2 = jugador.persona?.nombre2 ?? '';
                                          final apellido1 = jugador.persona?.apellido1 ?? '';
                                          final apellido2 = jugador.persona?.apellido2 ?? '';
                                          final nombreCompleto = '$nombre1 $nombre2 $apellido1 $apellido2'.trim().replaceAll(RegExp(r'\s+'), ' ');
                                          
                                          return DropdownMenuItem<int>(
                                            value: jugador.idJugadores,
                                            child: Text(
                                              nombreCompleto.isNotEmpty ? nombreCompleto : 'Sin nombre',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: _isLoadingJugadores
                                            ? null
                                            : (int? value) {
                                                setState(() {
                                                  _jugador1Id = value;
                                                  _jugador1Nombre = value != null
                                                      ? _obtenerNombreJugador(
                                                          value)
                                                      : null;
                                                  _estadisticasComparadas = null;
                                                });
                                                if (_jugador1Id != null &&
                                                    _jugador2Id != null) {
                                                  _cargarEstadisticasComparadas();
                                                }
                                              },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '👤 Jugador 2',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      DropdownButtonFormField<int>(
                                        value: _jugador2Id,
                                        isExpanded: true,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                        ),
                                        hint: const Text('Seleccione jugador'),
                                        items: _jugadores.map((jugador) { // ✅ CORREGIDO
                                          // ✅ Usar campos correctos de la BD
                                          final nombre1 = jugador.persona?.nombre1 ?? '';
                                          final nombre2 = jugador.persona?.nombre2 ?? '';
                                          final apellido1 = jugador.persona?.apellido1 ?? '';
                                          final apellido2 = jugador.persona?.apellido2 ?? '';
                                          final nombreCompleto = '$nombre1 $nombre2 $apellido1 $apellido2'.trim().replaceAll(RegExp(r'\s+'), ' ');
                                          
                                          return DropdownMenuItem<int>(
                                            value: jugador.idJugadores,
                                            child: Text(
                                              nombreCompleto.isNotEmpty ? nombreCompleto : 'Sin nombre',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: _isLoadingJugadores
                                            ? null
                                            : (int? value) {
                                                setState(() {
                                                  _jugador2Id = value;
                                                  _jugador2Nombre = value != null
                                                      ? _obtenerNombreJugador(
                                                          value)
                                                      : null;
                                                  _estadisticasComparadas = null;
                                                });
                                                if (_jugador1Id != null &&
                                                    _jugador2Id != null) {
                                                  _cargarEstadisticasComparadas();
                                                }
                                              },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (_isLoadingEstadisticas)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            CircularProgressIndicator(
                              color: Color(0xFFE63946),
                            ),
                            SizedBox(height: 16),
                            Text('Cargando estadísticas...'),
                          ],
                        ),
                      ),
                    ),

                  if (_estadisticasComparadas != null &&
                      !_isLoadingEstadisticas) ...[
                    ComparacionTableWidget(
                      estadisticasComparadas: _estadisticasComparadas!,
                      jugador1Nombre: _jugador1Nombre ?? 'Jugador 1',
                      jugador2Nombre: _jugador2Nombre ?? 'Jugador 2',
                    ),
                    const SizedBox(height: 24),

                    ComparacionChartWidget(
                      estadisticasComparadas: _estadisticasComparadas!,
                      jugador1Nombre: _jugador1Nombre ?? 'Jugador 1',
                      jugador2Nombre: _jugador2Nombre ?? 'Jugador 2',
                    ),
                  ],

                  if (!_isLoadingEstadisticas &&
                      _estadisticasComparadas == null &&
                      (_jugador1Id != null || _jugador2Id != null))
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'ℹ️ Seleccione ambos jugadores para ver la comparación',
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (_categoriaSeleccionada == null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.arrow_upward, color: Colors.grey),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '⬆️ Seleccione una categoría para comenzar',
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (_categoriaSeleccionada != null &&
                      _jugadores.isEmpty && // ✅ CORREGIDO
                      !_isLoadingJugadores)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber, color: Colors.orange),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '⚠️ No hay jugadores disponibles en esta categoría',
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }
  
}