import 'package:flutter/material.dart';
import '/../controllers/jugador/inicio_jugador_controller.dart';
import '/../widgets/jugador/inicio_jugador/jugador_info_personal_card.dart';
import '/../widgets/jugador/inicio_jugador/jugador_info_deportiva_card.dart';
import '/../widgets/jugador/inicio_jugador/jugador_drawer_menu.dart';

class InicioJugadorScreen extends StatefulWidget {
  const InicioJugadorScreen({super.key});

  @override
  State<InicioJugadorScreen> createState() => _InicioJugadorScreenState();
}

class _InicioJugadorScreenState extends State<InicioJugadorScreen> {
  late InicioJugadorController _controller;

  @override
  void initState() {
    super.initState();
    _controller = InicioJugadorController(
      onLoadingChanged: () => setState(() {}),
      onNavigateToLogin: _navigateToLogin,
    );
    _controller.initializeJugadorData();
  }

  void _navigateToLogin() {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  void _handleDrawerItemTap(String routeName) {
    Navigator.of(context).pop(); // Cerrar drawer
    
    if (ModalRoute.of(context)?.settings.name != routeName) {
      Navigator.of(context).pushNamed(routeName);
    }
  }

  Future<void> _handleLogout() async {
    Navigator.of(context).pop(); // Cerrar drawer
    await _controller.logout();
  }

  @override
  Widget build(BuildContext context) {
    // Verificar autenticación antes de renderizar
    if (_controller.loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xffe63946)),
        ),
      );
    }

    if (_controller.error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  _controller.error!,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                if (_controller.shouldShowRedirect()) ...[
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(color: Color(0xffe63946)),
                  const SizedBox(height: 8),
                  const Text('Redirigiendo al login...'),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SCORD',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Bienvenida
            Center(
              child: Text(
                'Bienvenido(a), ${_controller.jugadorPersona?.nombreCorto ?? ""}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffe63946),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // Cards de información
            JugadorInfoPersonalCard(
              persona: _controller.jugadorPersona,
            ),
            const SizedBox(height: 16),
            JugadorInfoDeportivaCard(
              jugador: _controller.jugadorData,
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