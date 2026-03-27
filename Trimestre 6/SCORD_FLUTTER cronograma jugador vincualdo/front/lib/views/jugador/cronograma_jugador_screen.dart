import 'package:flutter/material.dart';
import '../../controllers/jugador/cronograma_jugador_controller.dart';
import '../../widgets/jugador/inicio_jugador/jugador_drawer_menu.dart';
import '../../widgets/jugador/cronograma/cronograma_partidos_jugador_section.dart';
import '../../widgets/jugador/cronograma/cronograma_entrenamientos_jugador_section.dart';

class CronogramaJugadorScreen extends StatefulWidget {
  const CronogramaJugadorScreen({Key? key}) : super(key: key);

  @override
  State<CronogramaJugadorScreen> createState() => _CronogramaJugadorScreenState();
}

class _CronogramaJugadorScreenState extends State<CronogramaJugadorScreen> {
  final CronogramaJugadorController _controller = CronogramaJugadorController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _controller.initialize();
    if (mounted) setState(() {});
  }

  void _handleDrawerItemTap(String routeName) {
    Navigator.of(context).pop();
    if (ModalRoute.of(context)?.settings.name != routeName) {
      Navigator.of(context).pushNamed(routeName);
    }
  }

  Future<void> _handleLogout() async {
    Navigator.of(context).pop();
    Navigator.of(context).pushReplacementNamed('/');
  }

  void _handleSearchPartido(String value) {
    setState(() {
      _controller.searchTermPartido = value;
      _controller.currentPagePartido = 1;
    });
  }

  void _handleSearchEntrenamiento(String value) {
    setState(() {
      _controller.searchTermEntrenamiento = value;
      _controller.currentPageEntrenamiento = 1;
    });
  }

  void _handlePageChangePartido(int page) {
    setState(() {
      _controller.currentPagePartido = page;
    });
  }

  void _handlePageChangeEntrenamiento(int page) {
    setState(() {
      _controller.currentPageEntrenamiento = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SCORD - Mi Calendario de Actividades',
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
      drawer: JugadorDrawerMenu(
        onItemTap: _handleDrawerItemTap,
        onLogout: _handleLogout,
      ),
      body: _controller.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xffe63946)),
            )
          : _controller.error != null
              ? _buildErrorView()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header con categoría
                      _buildCategoriaHeader(),
                      const SizedBox(height: 24),

                      // PRIMERO: PARTIDOS
                      CronogramaPartidosJugadorSection(
                        controller: _controller,
                        onSearch: _handleSearchPartido,
                        onPageChange: _handlePageChangePartido,
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
                      CronogramaEntrenamientosJugadorSection(
                        controller: _controller,
                        onSearch: _handleSearchEntrenamiento,
                        onPageChange: _handlePageChangeEntrenamiento,
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

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(
              _controller.error!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffe63946),
                foregroundColor: Colors.white,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriaHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffe63946),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.category, color: Colors.white, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tu Categoría',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _controller.miCategoria?.descripcion ?? 'Categoría ID: ${_controller.miIdCategoria}',
style: const TextStyle(
color: Colors.white,
fontSize: 18,
fontWeight: FontWeight.bold,
),
),
],
),
),
],
),
);
}
}