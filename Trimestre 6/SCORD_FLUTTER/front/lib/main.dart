import 'package:flutter/material.dart';
import 'views/auth/login_screen.dart';
import 'views/admin/inicio_admin.dart';
import 'views/admin/perfil_jugador_admin_screen.dart';
import 'views/admin/estadisticas_jugador_screen.dart';
import 'views/admin/agregar_jugador_screen.dart';
import 'views/admin/agregar_rendimiento_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SCORD',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/InicioAdmin': (context) => const InicioAdmin(),
        '/PerfilJugadorAdmin': (context) => const PerfilJugadorAdminScreen(),
        '/EstadisticasJugadores': (context) => const EstadisticasJugadorScreen(),
        '/AgregarJugador': (context) => const AgregarJugadorScreen(),
        '/AgregarRendimiento': (context) => const AgregarRendimientoScreen(),
      },
    );
  }
}