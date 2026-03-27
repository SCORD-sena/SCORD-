import 'package:flutter/material.dart';
import '../../controllers/admin/comparar_jugadores_controller.dart';
import '../../models/categoria_model.dart';
import '../../models/jugador_model.dart';
import '../../models/competencia_model.dart';
import '../../widgets/admin/comparar_jugadores/comparacion_chart_widget.dart';
import '../../widgets/admin/comparar_jugadores/comparacion_table_widget.dart';
import '../../widgets/common/admin_drawer.dart';

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
  List<Jugador> _jugadores = [];
  List<Competencia> _competencias = [];
  
  int? _competenciaSeleccionada;
  String _tipoFiltro = 'todos';

  int? _jugador1Id;
  int? _jugador2Id;
  String? _jugador1Nombre;
  String? _jugador2Nombre;

  Map<String, dynamic>? _estadisticasComparadas;

  bool _isLoadingCategorias = true;
  bool _isLoadingJugadores = false;
  bool _isLoadingEstadisticas = false;
  bool _isLoadingCompetencias = false;
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

  Future<void> _cargarCompetenciasPorCategoria(int idCategoria) async {
    setState(() {
      _isLoadingCompetencias = true;
      _competencias = [];
      _competenciaSeleccionada = null;
    });

    try {
      final competencias = await _controller.cargarCompetenciasPorCategoria(idCategoria);
      setState(() {
        _competencias = competencias;
        _isLoadingCompetencias = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar competencias';
        _isLoadingCompetencias = false;
      });
    }
  }

  Future<void> _cargarJugadoresPorCategoria(int idCategoria) async {
    setState(() {
      _isLoadingJugadores = true;
      _jugadores = [];
      _jugador1Id = null;
      _jugador2Id = null;
      _jugador1Nombre = null;
      _jugador2Nombre = null;
      _estadisticasComparadas = null;
      _errorMessage = null;
    });

    try {
      final jugadores =
          await _controller.cargarJugadoresPorCategoria(idCategoria);
      setState(() {
        _jugadores = jugadores;
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
      Map<String, dynamic> estadisticas;

      if (_tipoFiltro == 'competencia' && _competenciaSeleccionada != null) {
        estadisticas = await _controller.cargarEstadisticasComparadasPorCompetencia(
          _jugador1Id!,
          _jugador2Id!,
          _competenciaSeleccionada!,
        );
      } else {
        estadisticas = await _controller.cargarEstadisticasComparadas(
          _jugador1Id!,
          _jugador2Id!,
        );
      }

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
      return jugador.persona.nombreCompleto;
    } catch (e) {
      return 'Jugador $jugadorId';
    }
  }

  void _validarYCargarEstadisticas() {
    if (_jugador1Id == null || _jugador2Id == null) return;

    bool puedeCargar = false;

    if (_tipoFiltro == 'todos') {
      puedeCargar = true;
    } else if (_tipoFiltro == 'competencia' && _competenciaSeleccionada != null) {
      puedeCargar = true;
    }

    if (puedeCargar) {
      _cargarEstadisticasComparadas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'SCORD',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFFE63946)),
      ),
      
      drawer: AdminDrawer(currentRoute: '/ComparacionJugadores'),
      
      body: _isLoadingCategorias
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE63946)))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header moderno similar al de inicio
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFE63946), Color(0xFFD62839)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.compare_arrows,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Comparación de Jugadores',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Compare estadísticas entre jugadores',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Contenido principal
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mensaje de error
                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red[200]!),
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

                        // Card de filtros principales
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Selección de categoría
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE63946).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.category,
                                      color: Color(0xFFE63946),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Seleccione una Categoría',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: DropdownButtonFormField<Categoria>(
                                  value: _categoriaSeleccionada,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  hint: const Text('Seleccione una categoría'),
                                  items: _categorias.map((categoria) {
                                    return DropdownMenuItem<Categoria>(
                                      value: categoria,
                                      child: Text(categoria.descripcion),
                                    );
                                  }).toList(),
                                  onChanged: (Categoria? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _categoriaSeleccionada = newValue;
                                        _tipoFiltro = 'todos';
                                        _competenciaSeleccionada = null;
                                        _estadisticasComparadas = null;
                                      });
                                      _cargarJugadoresPorCategoria(newValue.idCategorias);
                                      _cargarCompetenciasPorCategoria(newValue.idCategorias);
                                    }
                                  },
                                ),
                              ),

                              if (_categoriaSeleccionada != null) ...[
                                const SizedBox(height: 24),
                                const Divider(),
                                const SizedBox(height: 24),

                                // Tipo de comparación
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE63946).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.tune,
                                        color: Color(0xFFE63946),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Tipo de Comparación',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SegmentedButton<String>(
                                  style: SegmentedButton.styleFrom(
                                    selectedBackgroundColor: const Color(0xFFE63946),
                                    selectedForegroundColor: Colors.white,
                                  ),
                                  segments: const [
                                    ButtonSegment(
                                      value: 'todos',
                                      label: Text('Todos'),
                                      icon: Icon(Icons.all_inclusive, size: 18),
                                    ),
                                    ButtonSegment(
                                      value: 'competencia',
                                      label: Text('Por Competencia'),
                                      icon: Icon(Icons.emoji_events, size: 18),
                                    ),
                                  ],
                                  selected: {_tipoFiltro},
                                  onSelectionChanged: (Set<String> newSelection) {
                                    setState(() {
                                      _tipoFiltro = newSelection.first;
                                      _estadisticasComparadas = null;
                                      
                                      if (_tipoFiltro == 'todos') {
                                        _competenciaSeleccionada = null;
                                      }
                                      
                                      if (_jugador1Id != null && _jugador2Id != null) {
                                        if (_tipoFiltro == 'todos') {
                                          _cargarEstadisticasComparadas();
                                        }
                                      }
                                    });
                                  },
                                ),

                                // Dropdown de competencia
                                if (_tipoFiltro == 'competencia') ...[
                                  const SizedBox(height: 20),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: DropdownButtonFormField<int>(
                                      value: _competenciaSeleccionada,
                                      isExpanded: true,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        prefixIcon: Icon(Icons.emoji_events, color: Color(0xFFE63946)),
                                      ),
                                      hint: _isLoadingCompetencias
                                          ? const Text('Cargando competencias...')
                                          : const Text('Seleccione una competencia'),
                                      items: _competencias.map((competencia) {
                                        return DropdownMenuItem<int>(
                                          value: competencia.idCompetencias,
                                          child: Text(competencia.nombre),
                                        );
                                      }).toList(),
                                      onChanged: _isLoadingCompetencias
                                          ? null
                                          : (int? value) {
                                              setState(() {
                                                _competenciaSeleccionada = value;
                                                _estadisticasComparadas = null;
                                              });
                                              
                                              if (value != null) {
                                                if (_tipoFiltro == 'competencia' && 
                                                    _jugador1Id != null && 
                                                    _jugador2Id != null) {
                                                  _cargarEstadisticasComparadas();
                                                }
                                              }
                                            },
                                    ),
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),

                        // Selección de jugadores
                        if (_categoriaSeleccionada != null) ...[
                          const SizedBox(height: 20),
                          
                          // Jugador 1
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.blue,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Jugador 1',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: DropdownButtonFormField<int>(
                                    value: _jugador1Id,
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                    hint: const Text('Seleccione jugador'),
                                    items: _jugadores.map((jugador) {
                                      return DropdownMenuItem<int>(
                                        value: jugador.idJugadores,
                                        child: Text(
                                          jugador.persona.nombreCompleto,
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
                                                  ? _obtenerNombreJugador(value)
                                                  : null;
                                              _estadisticasComparadas = null;
                                            });
                                            
                                            _validarYCargarEstadisticas();
                                          },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // VS Indicator
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE63946),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'VS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Jugador 2
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.orange,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Jugador 2',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: DropdownButtonFormField<int>(
                                    value: _jugador2Id,
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                    hint: const Text('Seleccione jugador'),
                                    items: _jugadores.map((jugador) {
                                      return DropdownMenuItem<int>(
                                        value: jugador.idJugadores,
                                        child: Text(
                                          jugador.persona.nombreCompleto,
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
                                                  ? _obtenerNombreJugador(value)
                                                  : null;
                                              _estadisticasComparadas = null;
                                            });
                                            
                                            _validarYCargarEstadisticas();
                                          },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Loading de estadísticas
                        if (_isLoadingEstadisticas)
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Column(
                                children: [
                                  CircularProgressIndicator(
                                    color: Color(0xFFE63946),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Cargando estadísticas...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Resultados de comparación
                        if (_estadisticasComparadas != null && !_isLoadingEstadisticas) ...[
                          ComparacionTableWidget(
                            estadisticasComparadas: _estadisticasComparadas!,
                            jugador1Nombre: _jugador1Nombre ?? 'Jugador 1',
                            jugador2Nombre: _jugador2Nombre ?? 'Jugador 2',
                          ),
                          const SizedBox(height: 20),
                          ComparacionChartWidget(
                            estadisticasComparadas: _estadisticasComparadas!,
                            jugador1Nombre: _jugador1Nombre ?? 'Jugador 1',
                            jugador2Nombre: _jugador2Nombre ?? 'Jugador 2',
                          ),
                        ],

                        // Mensajes informativos
                        if (_categoriaSeleccionada == null)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, color: Colors.blue, size: 24),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    'Seleccione una categoría para comenzar la comparación',
                                    style: TextStyle(
                                      color: Colors.blue[900],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (_categoriaSeleccionada != null &&
                            _jugadores.isEmpty &&
                            !_isLoadingJugadores)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.orange[200]!),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber, color: Colors.orange, size: 24),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    'No hay jugadores disponibles en esta categoría',
                                    style: TextStyle(
                                      color: Colors.orange[900],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
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