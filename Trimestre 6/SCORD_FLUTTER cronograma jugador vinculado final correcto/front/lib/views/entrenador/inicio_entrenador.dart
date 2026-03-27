import 'package:flutter/material.dart';

import '../../controllers/entrenador/inicio_entrenador_controller.dart';
import '../../widgets/entrenador/inicio_entrenador/inicio_entrenador_widgets.dart';

class InicioEntrenador extends StatefulWidget {
  const InicioEntrenador({super.key});

  @override
  State<InicioEntrenador> createState() => _InicioEntrenadorState();
}

class _InicioEntrenadorState extends State<InicioEntrenador> {
  late InicioEntrenadorController _controller;

  @override
  void initState() {
    super.initState();
    _controller = InicioEntrenadorController(
      onLoadingChanged: () => setState(() {}),
      onNavigateToLogin: _navigateToLogin,
    );
    _controller.initializeEntrenadorData();
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
          child: CircularProgressIndicator(color: Colors.red),
        ),
      );
    }

    if (_controller.error != null) {
      return Scaffold(
        body: ErrorDisplay(
          error: _controller.error!,
          showRedirect: _controller.shouldShowRedirect(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SCORD',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.red),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: EntrenadorDrawerMenu(
        onItemTap: _handleDrawerItemTap,
        onLogout: _handleLogout,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Sección de bienvenida
            EntrenadorWelcomeHeader(
              entrenadorData: _controller.entrenadorData,
              categoria: _controller.categoriaEntrenador,
            ),

            // Carrusel de información
            const SizedBox(height: 32),
            const InstitutionalCarousel(),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: const AppFooter(),
    );
  }
}