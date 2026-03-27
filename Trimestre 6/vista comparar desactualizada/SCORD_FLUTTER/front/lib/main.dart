import 'package:flutter/material.dart';

import 'views/auth/login_screen.dart';

import 'views/admin/inicio_admin.dart';
import 'views/admin/perfil_jugador_admin_screen.dart';
import 'views/admin/estadisticas_jugador_screen.dart';
import 'views/admin/agregar_jugador_screen.dart';
import 'views/admin/agregar_rendimiento_screen.dart';
import 'views/admin/perfil_entrenador_admin_screen.dart';
import 'views/admin/agregar_entrenador_screen.dart';
import 'views/admin/comparacion_jugadores_screen.dart';

import 'views/entrenador/inicio_entrenador.dart';
import 'views/entrenador/perfil_jugador_entrenador.dart';
import 'views/entrenador/comparacion_jugadores_entrenador_screen.dart';
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
        '/InicioEntrenador': (context) => const InicioEntrenador(),
        '/PerfilJugadorAdmin': (context) => const PerfilJugadorAdminScreen(),
        '/AgregarJugador': (context) => const AgregarJugadorScreen(),
        '/PerfilEntrenadorAdmin': (context) => const PerfilEntrenadorAdminScreen(),
        '/AgregarEntrenador': (context) => const AgregarEntrenadorScreen(),
        '/AgregarRendimiento': (context) => const AgregarRendimientoScreen(),
        '/EstadisticasJugadores': (context) => const EstadisticasJugadorScreen(),
        '/PerfilJugadorEntrenador': (context) => const PerfilJugadorEntrenadorScreen(),
        '/ComparacionJugadores': (context) => const ComparacionJugadoresScreen(),
        '/ComparacionJugadoresEntrenador': (context) => const ComparacionJugadoresEntrenadorScreen(),
      },
    );
  }
}