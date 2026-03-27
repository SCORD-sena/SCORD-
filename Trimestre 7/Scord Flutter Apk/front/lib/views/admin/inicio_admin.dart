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
        iconTheme: const IconThemeData(color: Colors.red),
      ),
      
      // ✅ INTEGRACIÓN DEL DRAWER COMÚN
      drawer: AdminDrawerMenu(currentRoute: '/InicioAdmin'),
      
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