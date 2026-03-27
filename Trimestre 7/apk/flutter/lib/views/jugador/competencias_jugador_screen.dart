import 'package:flutter/material.dart';
import '../../controllers/jugador/competencias_jugador_controller.dart';
import '../../widgets/common/jugador_drawer.dart';

class CompetenciasJugadorScreen extends StatefulWidget {
  const CompetenciasJugadorScreen({super.key});

  @override
  State<CompetenciasJugadorScreen> createState() => _CompetenciasJugadorScreenState();
}

class _CompetenciasJugadorScreenState extends State<CompetenciasJugadorScreen> {
  late CompetenciasJugadorController _controller;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _competenciasFiltradas = [];

  @override
  void initState() {
    super.initState();
    _controller = CompetenciasJugadorController();
    _controller.addListener(_onControllerChanged);
    _inicializar();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {
        _competenciasFiltradas = _controller.competencias;
      });
    }
  }

  Future<void> _inicializar() async {
    await _controller.inicializar();
    setState(() {
      _competenciasFiltradas = _controller.competencias;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _competenciasFiltradas = _controller.buscarCompetencias(query);
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'Competencias',
        style: TextStyle(
          color: Color(0xFFE63946),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 1,
      iconTheme: const IconThemeData(color: Color(0xFFE63946)),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
    ),
    // ✅ NUEVO DRAWER CON LOGOUT FUNCIONAL
    drawer: const JugadorDrawer(currentRoute: '/CompetenciasJugador'),
    
    body: _controller.loading
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFE63946)))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE63946).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.emoji_events, color: Color(0xFFE63946), size: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mis Competencias',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE63946),
                            ),
                          ),
                          Text(
                            _controller.categoriaJugador != null 
                                ? 'Categoría: ${_controller.categoriaJugador!.descripcion}'
                                : 'Sin categoría asignada',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Buscador
                if (_controller.categoriaJugador != null && _controller.competencias.isNotEmpty)
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Buscar por nombre, tipo o año',
                      labelStyle: const TextStyle(color: Color(0xFFE63946)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFFE63946)),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                    ),
                    onChanged: _onSearchChanged,
                  ),
                const SizedBox(height: 20),

                // Mensajes de error o sin datos
                if (_controller.errorMessage != null)
                  Card(
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.orange),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _controller.errorMessage!,
                              style: const TextStyle(color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_controller.categoriaJugador != null && _competenciasFiltradas.isEmpty)
                  Card(
                    color: Colors.blue.shade50,
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'No hay competencias registradas para tu categoría',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Tabla de competencias
                if (_controller.categoriaJugador != null && _competenciasFiltradas.isNotEmpty)
                  _buildTablaCompetencias(),
              ],
            ),
          ),
  );
}

Widget _buildTablaCompetencias() {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Competencias (${_competenciasFiltradas.length})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE63946),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFE63946).withOpacity(0.1)),
              columns: const [
                DataColumn(label: Text('Nombre', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Tipo', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Año', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: _competenciasFiltradas.map((competencia) {
                return DataRow(
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          const Icon(Icons.emoji_events, color: Color(0xFFE63946), size: 16),
                          const SizedBox(width: 8),
                          Text(competencia.nombre),
                        ],
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          competencia.tipoCompetencia,
                          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          competencia.ano.toString(),
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    ),
  );
}
}