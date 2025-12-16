import 'package:flutter/material.dart';

import '../../controllers/admin/inicio_admin_controller.dart';
import '../../widgets/admin/inicio_admin/inicio_admin_widgets.dart';

class InicioAdmin extends StatefulWidget {
  const InicioAdmin({super.key});

  @override
  State<InicioAdmin> createState() => _InicioAdminState();
}

class _InicioAdminState extends State<InicioAdmin> {
  late InicioAdminController _controller;

  @override
  void initState() {
    super.initState();
    _controller = InicioAdminController(
      onLoadingChanged: () => setState(() {}),
      onNavigateToLogin: _navigateToLogin,
    );
    _controller.initializeAdminData();
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
      drawer: AdminDrawerMenu(
        onItemTap: _handleDrawerItemTap,
        onLogout: _handleLogout,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Sección de bienvenida
            AdminWelcomeHeader(adminData: _controller.adminData),

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